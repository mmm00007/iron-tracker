"""Body composition analytics: BMI, FFMI, and weight trends.

Computes body composition metrics from logged weight entries and profile data.
Uses a 7-day Exponential Moving Average (EMA) for trend smoothing, BMI with
WHO classification, and FFMI with the Kouri et al. (1995) height normalization.

Key formulas:
  BMI = weight_kg / height_m^2
  FFMI = lean_mass_kg / height_m^2
  FFMI_normalized = FFMI + 6.1 * (1.8 - height_m)  (Kouri et al. 1995)
  EMA: alpha = 2/(7+1) = 0.25; ema_t = weight * alpha + ema_{t-1} * (1 - alpha)

Domain expert validations:
  - Fitness: EMA window, FFMI formula, classification thresholds
  - Sports medicine: Disclaimer text, measurement error margins
  - Data science: EMA initialization, cold-start handling
"""

from datetime import UTC, datetime, timedelta

import asyncpg

from app.models.schemas import BodyCompositionResponse, WeightTrendEntry

# EMA smoothing factor: alpha = 2 / (span + 1) where span = 7 days
_EMA_ALPHA = 2 / (7 + 1)  # 0.25

# Unit conversion
_LB_TO_KG = 0.453592

_DISCLAIMER = (
    "Body composition metrics are estimates and vary by measurement method. "
    "BMI does not distinguish muscle from fat and is unreliable for trained "
    "individuals. Body fat percentage from consumer devices has 3-5% error "
    "margins. These metrics do not define health."
)


def _classify_bmi(bmi: float) -> str:
    """Classify BMI per WHO categories."""
    if bmi < 18.5:
        return "underweight"
    if bmi < 25.0:
        return "normal"
    if bmi < 30.0:
        return "overweight"
    return "obese"


def _classify_ffmi(ffmi_normalized: float, sex: str) -> str:
    """Classify FFMI by sex-specific thresholds.

    Male thresholds (Kouri et al. 1995, Schutz et al. 2002):
      <18 below_average, 18-20 average, 20-22 above_average,
      22-25 excellent, 25+ exceptional

    Female thresholds (adapted from Schutz et al. 2002):
      <15 below_average, 15-17 average, 17-19 above_average,
      19-22 excellent, 22+ exceptional
    """
    if sex == "female":
        if ffmi_normalized < 15.0:
            return "below_average"
        if ffmi_normalized < 17.0:
            return "average"
        if ffmi_normalized < 19.0:
            return "above_average"
        if ffmi_normalized < 22.0:
            return "excellent"
        return "exceptional"

    # Default to male thresholds
    if ffmi_normalized < 18.0:
        return "below_average"
    if ffmi_normalized < 20.0:
        return "average"
    if ffmi_normalized < 22.0:
        return "above_average"
    if ffmi_normalized < 25.0:
        return "excellent"
    return "exceptional"


async def compute_body_composition(
    user_id: str,
    db_pool: asyncpg.Pool,
    period_days: int = 90,
) -> BodyCompositionResponse:
    """Compute body composition analytics for a user.

    Requires at least 1 weight entry for basic metrics, 3+ for a meaningful
    trend, and body_fat_pct entries for FFMI calculations. If height_cm is
    not set in the profile, BMI and FFMI are skipped.
    """
    since = datetime.now(UTC) - timedelta(days=period_days)

    async with db_pool.acquire() as conn:
        weight_rows = await conn.fetch(
            """
            SELECT weight, weight_unit, body_fat_pct, logged_at::date AS day
            FROM body_weight_log
            WHERE user_id = $1 AND logged_at >= $2
            ORDER BY logged_at ASC
            """,
            user_id,
            since,
        )

        profile_row = await conn.fetchrow(
            "SELECT height_cm, sex FROM profiles WHERE id = $1",
            user_id,
        )

    # --- Cold-start: no data at all ---
    if not weight_rows:
        return BodyCompositionResponse(
            current_weight_kg=None,
            weight_trend=[],
            weight_change_kg=None,
            weight_change_pct=None,
            bmi=None,
            bmi_label=None,
            ffmi=None,
            ffmi_normalized=None,
            ffmi_label=None,
            body_fat_pct=None,
            lean_mass_kg=None,
            data_points=0,
            period_days=period_days,
            disclaimer=_DISCLAIMER,
        )

    # --- Profile data ---
    height_cm: float | None = None
    sex: str = "male"
    if profile_row:
        height_cm = profile_row["height_cm"]
        sex = profile_row["sex"] or "male"

    height_m: float | None = height_cm / 100.0 if height_cm else None

    # --- Normalize weights to kg and compute EMA ---
    trend: list[WeightTrendEntry] = []
    ema: float | None = None
    latest_weight_kg: float = 0.0
    latest_bf_pct: float | None = None

    for row in weight_rows:
        weight_raw: float = float(row["weight"])
        unit: str = row["weight_unit"] or "kg"
        bf_pct: float | None = (
            float(row["body_fat_pct"]) if row["body_fat_pct"] is not None else None
        )
        day_str: str = str(row["day"])

        weight_kg = weight_raw * _LB_TO_KG if unit == "lb" else weight_raw

        # EMA: initialize to first value, then apply smoothing
        if ema is None:
            ema = weight_kg
        else:
            ema = weight_kg * _EMA_ALPHA + ema * (1 - _EMA_ALPHA)

        trend.append(
            WeightTrendEntry(
                date=day_str,
                weight_kg=round(weight_kg, 2),
                ema_kg=round(ema, 2),
                body_fat_pct=round(bf_pct, 1) if bf_pct is not None else None,
            )
        )

        latest_weight_kg = weight_kg
        if bf_pct is not None:
            latest_bf_pct = bf_pct

    data_points = len(trend)

    # --- Weight change (earliest EMA vs latest EMA) ---
    weight_change_kg: float | None = None
    weight_change_pct: float | None = None
    if data_points >= 3:
        earliest_ema = trend[0].ema_kg
        latest_ema = trend[-1].ema_kg
        weight_change_kg = round(latest_ema - earliest_ema, 2)
        if earliest_ema > 0:
            weight_change_pct = round(
                (weight_change_kg / earliest_ema) * 100, 1
            )

    # --- BMI ---
    bmi: float | None = None
    bmi_label: str | None = None
    if height_m and height_m > 0:
        bmi = round(latest_weight_kg / (height_m ** 2), 1)
        bmi_label = _classify_bmi(bmi)

    # --- FFMI (requires body fat percentage and height) ---
    ffmi: float | None = None
    ffmi_normalized: float | None = None
    ffmi_label: str | None = None
    lean_mass_kg: float | None = None

    if latest_bf_pct is not None and height_m and height_m > 0:
        lean_mass_kg = round(latest_weight_kg * (1 - latest_bf_pct / 100), 2)
        ffmi_raw = lean_mass_kg / (height_m ** 2)
        ffmi = round(ffmi_raw, 1)
        ffmi_norm = ffmi_raw + 6.1 * (1.8 - height_m)
        ffmi_normalized = round(ffmi_norm, 1)
        ffmi_label = _classify_ffmi(ffmi_norm, sex)

    return BodyCompositionResponse(
        current_weight_kg=round(latest_weight_kg, 2),
        weight_trend=trend,
        weight_change_kg=weight_change_kg,
        weight_change_pct=weight_change_pct,
        bmi=bmi,
        bmi_label=bmi_label,
        ffmi=ffmi,
        ffmi_normalized=ffmi_normalized,
        ffmi_label=ffmi_label,
        body_fat_pct=round(latest_bf_pct, 1) if latest_bf_pct is not None else None,
        lean_mass_kg=lean_mass_kg,
        data_points=data_points,
        period_days=period_days,
        disclaimer=_DISCLAIMER,
    )
