"""Nutrition-performance correlation analysis using Spearman rank correlation."""

from datetime import UTC, datetime, timedelta

import asyncpg

from app.models.schemas import NutritionBucketEntry, NutritionPerformanceResponse

# ─── Protein adequacy buckets ────────────────────────────────────────────────
# Thresholds informed by ISSN position stand and ACSM guidelines.
# >1.6 g/kg aligns with the upper end of the 1.4-2.0 g/kg recommendation
# for strength athletes.

PROTEIN_BUCKETS: list[dict[str, str | float]] = [
    {"name": "low", "label": "<1.2 g/kg", "lo": 0.0, "hi": 1.2},
    {"name": "moderate", "label": "1.2-1.6 g/kg", "lo": 1.2, "hi": 1.6},
    {"name": "adequate", "label": ">1.6 g/kg", "lo": 1.6, "hi": 100.0},
]

DISCLAIMER = (
    "These correlations show associations in your data, not causal "
    "relationships. Consult a registered dietitian for personalized "
    "nutrition guidance."
)

MIN_PAIRED_DAYS = 14

# ─── Spearman rank correlation (pure Python) ─────────────────────────────────


def _rank(values: list[float]) -> list[float]:
    """Assign ranks to values (1-based, no tie correction)."""
    sorted_indices = sorted(range(len(values)), key=lambda i: values[i])
    ranks = [0.0] * len(values)
    for rank, idx in enumerate(sorted_indices, 1):
        ranks[idx] = float(rank)
    return ranks


def _spearman(xs: list[float], ys: list[float]) -> float | None:
    """Compute Spearman rank correlation coefficient.

    Returns None if fewer than 5 data points (insufficient for ranking).
    """
    if len(xs) < 5:
        return None
    rx, ry = _rank(xs), _rank(ys)
    n = len(rx)
    mx = sum(rx) / n
    my = sum(ry) / n
    num = sum((a - mx) * (b - my) for a, b in zip(rx, ry))
    dx = sum((a - mx) ** 2 for a in rx) ** 0.5
    dy = sum((b - my) ** 2 for b in ry) ** 0.5
    if dx == 0 or dy == 0:
        return 0.0
    return round(num / (dx * dy), 3)


# ─── SQL queries ─────────────────────────────────────────────────────────────

_NUTRITION_TRAINING_QUERY = """\
SELECT n.logged_date::text,
       n.protein_g::float,
       n.calories_kcal,
       n.carbs_g::float,
       tds.total_volume_kg::float,
       tds.avg_rpe::float,
       (SELECT MAX(estimated_1rm)
        FROM sets
        WHERE user_id = $1
          AND training_date = n.logged_date
          AND estimated_1rm > 0) AS best_e1rm
FROM nutrition_logs n
JOIN training_day_summary tds
  ON tds.user_id = n.user_id AND tds.training_date = n.logged_date
WHERE n.user_id = $1
  AND n.logged_date >= $2
ORDER BY n.logged_date
"""

_BODY_WEIGHT_QUERY = """\
SELECT weight, weight_unit
FROM body_weight_log
WHERE user_id = $1
ORDER BY logged_at DESC
LIMIT 1
"""


# ─── Bucket aggregation ─────────────────────────────────────────────────────


def _protein_bucket_for(protein_per_kg: float) -> dict[str, str | float] | None:
    for b in PROTEIN_BUCKETS:
        if b["lo"] <= protein_per_kg < b["hi"]:  # type: ignore[operator]
            return b
    return None


def _aggregate_protein_buckets(
    rows: list[asyncpg.Record],
    body_weight_kg: float,
) -> list[NutritionBucketEntry]:
    """Group rows into protein adequacy buckets and compute per-bucket averages."""
    accum: dict[str, dict] = {}
    for b in PROTEIN_BUCKETS:
        accum[str(b["name"])] = {
            "label": str(b["label"]),
            "volumes": [],
            "e1rms": [],
            "rpes": [],
        }

    for row in rows:
        protein_g = row["protein_g"]
        if protein_g is None:
            continue
        protein_per_kg = float(protein_g) / body_weight_kg
        bucket = _protein_bucket_for(protein_per_kg)
        if bucket is None:
            continue
        name = str(bucket["name"])

        vol = row["total_volume_kg"]
        if vol is not None:
            accum[name]["volumes"].append(float(vol))
        e1rm = row["best_e1rm"]
        if e1rm is not None:
            accum[name]["e1rms"].append(float(e1rm))
        rpe = row["avg_rpe"]
        if rpe is not None:
            accum[name]["rpes"].append(float(rpe))

    entries: list[NutritionBucketEntry] = []
    for b in PROTEIN_BUCKETS:
        name = str(b["name"])
        data = accum[name]
        count = len(data["volumes"])
        if count == 0:
            continue
        avg_vol = round(sum(data["volumes"]) / count, 1)
        avg_e1rm = (
            round(sum(data["e1rms"]) / len(data["e1rms"]), 1)
            if data["e1rms"]
            else None
        )
        avg_rpe = (
            round(sum(data["rpes"]) / len(data["rpes"]), 1)
            if data["rpes"]
            else None
        )
        entries.append(
            NutritionBucketEntry(
                bucket=name,
                range_label=data["label"],
                days=count,
                avg_volume_kg=avg_vol,
                avg_e1rm=avg_e1rm,
                avg_rpe=avg_rpe,
            )
        )
    return entries


# ─── Main service function ───────────────────────────────────────────────────


async def compute_nutrition_performance(
    user_id: str,
    db_pool: asyncpg.Pool,
    period_days: int = 90,
) -> NutritionPerformanceResponse:
    """Analyse correlation between nutrition intake and training performance.

    Uses Spearman rank correlation (non-parametric, robust to outliers)
    and protein-adequacy bucket analysis for intuitive comparisons.
    Requires at least 14 paired nutrition+training days for cold start.
    """
    cutoff = (datetime.now(UTC) - timedelta(days=period_days)).date()

    async with db_pool.acquire() as conn:
        rows = await conn.fetch(_NUTRITION_TRAINING_QUERY, user_id, cutoff)
        weight_row = await conn.fetchrow(_BODY_WEIGHT_QUERY, user_id)

    n = len(rows)

    # ── Resolve body weight (kg) ───────────────────────────────────────────
    body_weight_kg: float | None = None
    if weight_row is not None:
        w = float(weight_row["weight"])
        unit = weight_row["weight_unit"]
        body_weight_kg = w * 0.453592 if unit == "lb" else w

    # ── Insufficient data (cold start: need >= 14 paired days) ─────────────
    if n < MIN_PAIRED_DAYS:
        return NutritionPerformanceResponse(
            correlation_protein_volume=None,
            correlation_calories_volume=None,
            correlation_carbs_rpe=None,
            protein_buckets=[],
            avg_protein_per_kg=None,
            avg_calories=None,
            paired_days=n,
            period_days=period_days,
            disclaimer=DISCLAIMER,
        )

    # ── Extract parallel arrays ────────────────────────────────────────────
    protein_vals: list[float] = []
    calorie_vals: list[float] = []
    carb_vals: list[float] = []
    volume_vals: list[float] = []
    rpe_vals: list[float] = []
    carb_rpe_carbs: list[float] = []
    carb_rpe_rpes: list[float] = []

    for row in rows:
        vol = row["total_volume_kg"]
        if vol is None:
            continue
        vol_f = float(vol)

        protein = row["protein_g"]
        if protein is not None:
            protein_vals.append(float(protein))
            volume_vals.append(vol_f)

        cal = row["calories_kcal"]
        if cal is not None:
            calorie_vals.append(float(cal))

        carb = row["carbs_g"]
        rpe = row["avg_rpe"]
        if carb is not None:
            carb_vals.append(float(carb))
        if carb is not None and rpe is not None:
            carb_rpe_carbs.append(float(carb))
            carb_rpe_rpes.append(float(rpe))

    # Build calorie-volume pairs (aligned with protein/volume pairs)
    calorie_volume_cals: list[float] = []
    calorie_volume_vols: list[float] = []
    for row in rows:
        vol = row["total_volume_kg"]
        cal = row["calories_kcal"]
        if vol is not None and cal is not None:
            calorie_volume_cals.append(float(cal))
            calorie_volume_vols.append(float(vol))

    # ── Spearman correlations ──────────────────────────────────────────────
    corr_protein_volume = _spearman(protein_vals, volume_vals)
    corr_calories_volume = _spearman(calorie_volume_cals, calorie_volume_vols)
    corr_carbs_rpe = _spearman(carb_rpe_carbs, carb_rpe_rpes)

    # ── Per-kg and average calculations ────────────────────────────────────
    avg_protein_per_kg: float | None = None
    if body_weight_kg is not None and protein_vals:
        avg_protein = sum(protein_vals) / len(protein_vals)
        avg_protein_per_kg = round(avg_protein / body_weight_kg, 2)

    avg_calories: float | None = None
    if calorie_vals:
        avg_calories = round(sum(calorie_vals) / len(calorie_vals), 0)

    # ── Protein adequacy bucket analysis ───────────────────────────────────
    protein_buckets: list[NutritionBucketEntry] = []
    if body_weight_kg is not None:
        protein_buckets = _aggregate_protein_buckets(rows, body_weight_kg)

    return NutritionPerformanceResponse(
        correlation_protein_volume=corr_protein_volume,
        correlation_calories_volume=corr_calories_volume,
        correlation_carbs_rpe=corr_carbs_rpe,
        protein_buckets=protein_buckets,
        avg_protein_per_kg=avg_protein_per_kg,
        avg_calories=avg_calories,
        paired_days=n,
        period_days=period_days,
        disclaimer=DISCLAIMER,
    )
