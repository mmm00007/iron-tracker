"""Relative strength tracking using DOTS scores.

Computes relative strength for benchmarkable compound lifts by combining
estimated 1RM values with bodyweight data. Uses two complementary metrics:

  1. DOTS score (IPF 2019 coefficients) — the gold standard for comparing
     strength across bodyweight classes in powerlifting. Designed to be sex-
     and bodyweight-fair.
  2. Simple BW ratio (e1RM / bodyweight) — intuitive but biased toward
     lighter lifters; included as a secondary reference.

Historical trend uses body weight interpolation to pair each training date
with the closest recorded bodyweight, enabling DOTS tracking over time.

Domain expert validations:
  - Fitness: DOTS formula coefficients, benchmarkable exercise list, clamping
  - Data science: Body weight interpolation strategy, trend aggregation
"""

from datetime import UTC, datetime, timedelta

import asyncpg

from app.models.schemas import (
    RelativeStrengthEntry,
    RelativeStrengthResponse,
    RelativeStrengthTrendEntry,
)

# ─── DOTS coefficients (IPF 2019) ───────────────────────────────────────────

_MALE_DOTS = [-0.0000010930, 0.0007391293, -0.1918759221, 24.0900756, -307.75076]
_FEMALE_DOTS = [-0.0000010706, 0.0005158568, -0.1126655495, 13.6175032, -57.96288]

# Unit conversion
_LB_TO_KG = 0.453592

_DISCLAIMER = (
    "Relative strength scores compare your strength to your bodyweight. "
    "DOTS scores use IPF (2019) coefficients designed for powerlifting. "
    "Improving this score through weight loss is not recommended \u2014 focus on "
    "getting stronger. Estimated 1RM values are approximations based on the "
    "Epley formula."
)

# Exercises eligible for DOTS scoring (case-insensitive match)
_BENCHMARKABLE = {
    "barbell bench press",
    "bench press",
    "flat barbell bench press",
    "barbell squat",
    "squat",
    "back squat",
    "barbell back squat",
    "deadlift",
    "barbell deadlift",
    "conventional deadlift",
    "overhead press",
    "barbell overhead press",
    "military press",
}


# ─── Helpers ─────────────────────────────────────────────────────────────────


def _dots_coefficient(bw_kg: float, sex: str) -> float:
    """Compute DOTS coefficient for a given bodyweight and sex."""
    bw_kg = max(40.0, min(200.0, bw_kg))  # Clamp to valid range
    coeffs = _FEMALE_DOTS if sex == "female" else _MALE_DOTS
    denom = sum(c * bw_kg ** (4 - i) for i, c in enumerate(coeffs))
    if denom <= 0:
        return 0.0
    return 500.0 / denom


def _to_kg(weight: float, unit: str) -> float:
    """Convert a weight value to kilograms."""
    if unit and unit.lower() in ("lb", "lbs", "pound", "pounds"):
        return weight * _LB_TO_KG
    return weight


def _interpolate_bw(
    target_date: str,
    bw_entries: list[dict],
) -> float | None:
    """Return the closest body weight (kg) to *target_date* from sorted entries.

    Uses simple nearest-neighbor interpolation: for each target date, pick the
    entry whose day is closest.  Returns None if no entries exist.
    """
    if not bw_entries:
        return None

    best: dict | None = None
    best_delta: int | None = None
    for entry in bw_entries:
        delta = abs((entry["day"] - _parse_date(target_date)).days)
        if best_delta is None or delta < best_delta:
            best_delta = delta
            best = entry
    return best["weight_kg"] if best else None


def _parse_date(date_str: str):
    """Parse a YYYY-MM-DD string into a date object."""
    from datetime import date as _date

    parts = date_str.split("-")
    return _date(int(parts[0]), int(parts[1]), int(parts[2]))


# ─── Main computation ────────────────────────────────────────────────────────


async def compute_relative_strength(
    user_id: str,
    db_pool: asyncpg.Pool,
    period_days: int = 90,
) -> RelativeStrengthResponse:
    """Compute relative strength metrics for benchmarkable compounds.

    Steps:
      1. Fetch latest body weight and sex from profile.
      2. Fetch best e1RM per benchmarkable exercise in the period.
      3. Compute DOTS score per lift and total DOTS.
      4. Compute simple BW ratio per lift.
      5. Build historical trend using body weight interpolation.
    """
    since = datetime.now(UTC) - timedelta(days=period_days)
    exercise_names = list(_BENCHMARKABLE)

    async with db_pool.acquire() as conn:
        # Query 1: latest body weight
        bw_row = await conn.fetchrow(
            """
            SELECT weight, weight_unit, logged_at
            FROM body_weight_log
            WHERE user_id = $1
            ORDER BY logged_at DESC LIMIT 1
            """,
            user_id,
        )

        # Query 2: profile sex
        profile_row = await conn.fetchrow(
            """
            SELECT COALESCE(sex, 'male') AS sex FROM profiles WHERE id = $1
            """,
            user_id,
        )

        # Query 3: best e1RM per benchmarkable exercise
        e1rm_rows = await conn.fetch(
            """
            SELECT
                s.exercise_id,
                e.name AS exercise_name,
                MAX(s.estimated_1rm) AS best_e1rm
            FROM sets s
            JOIN exercises e ON e.id = s.exercise_id
            WHERE s.user_id = $1
              AND s.logged_at >= $2
              AND s.estimated_1rm > 0
              AND s.set_type = 'working'
              AND LOWER(e.name) = ANY($3)
            GROUP BY s.exercise_id, e.name
            ORDER BY MAX(s.estimated_1rm) DESC
            """,
            user_id,
            since,
            exercise_names,
        )

        # Query 4a: historical e1RM per training date (for trend)
        trend_rows = await conn.fetch(
            """
            SELECT
                s.training_date::text AS training_date,
                MAX(s.estimated_1rm) AS best_e1rm
            FROM sets s
            JOIN exercises e ON e.id = s.exercise_id
            WHERE s.user_id = $1
              AND s.logged_at >= $2
              AND s.estimated_1rm > 0
              AND LOWER(e.name) = ANY($3)
            GROUP BY s.training_date
            ORDER BY s.training_date ASC
            """,
            user_id,
            since,
            exercise_names,
        )

        # Query 4b: historical body weight entries (for interpolation)
        bw_history_rows = await conn.fetch(
            """
            SELECT weight, weight_unit, logged_at::date AS day
            FROM body_weight_log
            WHERE user_id = $1 AND logged_at >= $2
            ORDER BY logged_at ASC
            """,
            user_id,
            since,
        )

    # ── Resolve body weight ──────────────────────────────────────────────

    sex = profile_row["sex"] if profile_row else "male"
    bodyweight_kg: float | None = None
    bw_data_age_days: int | None = None

    if bw_row:
        bodyweight_kg = _to_kg(float(bw_row["weight"]), bw_row["weight_unit"])
        bw_data_age_days = (datetime.now(UTC) - bw_row["logged_at"]).days

    # ── Build exercise entries ───────────────────────────────────────────

    exercises: list[RelativeStrengthEntry] = []
    total_dots = 0.0
    has_dots = False

    for row in e1rm_rows:
        e1rm = float(row["best_e1rm"])
        bw_ratio = round(e1rm / bodyweight_kg, 2) if bodyweight_kg else 0.0
        dots_score: float | None = None

        if bodyweight_kg:
            coeff = _dots_coefficient(bodyweight_kg, sex)
            dots_score = round(e1rm * coeff, 1)
            total_dots += dots_score
            has_dots = True

        exercises.append(
            RelativeStrengthEntry(
                exercise_id=row["exercise_id"],
                exercise_name=row["exercise_name"],
                e1rm_kg=round(e1rm, 1),
                bw_ratio=bw_ratio,
                dots_score=dots_score,
            )
        )

    # ── Build historical trend ───────────────────────────────────────────

    bw_history = [
        {
            "day": r["day"],
            "weight_kg": _to_kg(float(r["weight"]), r["weight_unit"]),
        }
        for r in bw_history_rows
    ]

    trend: list[RelativeStrengthTrendEntry] = []
    for row in trend_rows:
        training_date = row["training_date"]
        interp_bw = _interpolate_bw(training_date, bw_history)
        if interp_bw is None:
            # Cannot compute DOTS without body weight
            continue
        best_e1rm = float(row["best_e1rm"])
        coeff = _dots_coefficient(interp_bw, sex)
        day_dots = round(best_e1rm * coeff, 1)
        trend.append(
            RelativeStrengthTrendEntry(
                date=training_date,
                total_dots=day_dots,
                bodyweight_kg=round(interp_bw, 1),
            )
        )

    return RelativeStrengthResponse(
        exercises=exercises,
        total_dots=round(total_dots, 1) if has_dots else None,
        bodyweight_kg=round(bodyweight_kg, 1) if bodyweight_kg else None,
        sex=sex,
        bw_data_age_days=bw_data_age_days,
        trend=trend,
        period_days=period_days,
        disclaimer=_DISCLAIMER,
    )
