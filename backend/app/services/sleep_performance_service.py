"""Sleep-performance correlation analysis using Spearman rank correlation."""

from datetime import UTC, datetime, timedelta

import asyncpg

from app.models.schemas import SleepBucketEntry, SleepPerformanceResponse

# ─── Sleep buckets ────────────────────────────────────────────────────────────
# Thresholds informed by AASM and sports-science literature.
# "Good" (6-7.5h) and "excellent" (>7.5h) align with the 7-9h recommendation.

SLEEP_BUCKETS: list[dict[str, str | float]] = [
    {"name": "poor", "label": "<5h", "lo": 3.0, "hi": 5.0},
    {"name": "fair", "label": "5-6h", "lo": 5.0, "hi": 6.0},
    {"name": "good", "label": "6-7.5h", "lo": 6.0, "hi": 7.5},
    {"name": "excellent", "label": ">7.5h", "lo": 7.5, "hi": 24.0},
]

DISCLAIMER = (
    "Sleep data is self-reported and reflects general patterns. "
    "Sleep-performance correlations are observational associations "
    "and may not reflect causation. Persistent difficulty sleeping "
    "may indicate a sleep disorder \u2014 consult your physician."
)

# ─── Confidence tiers ─────────────────────────────────────────────────────────
# <5 points  = insufficient
# 5-9        = preliminary
# 10-19      = moderate
# 20+        = reliable


def _confidence_tier(n: int) -> str:
    if n < 5:
        return "insufficient"
    if n < 10:
        return "preliminary"
    if n < 20:
        return "moderate"
    return "reliable"


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


def _correlation_label(rho: float | None) -> str:
    """Classify the absolute magnitude of the correlation."""
    if rho is None:
        return "insufficient_data"
    abs_rho = abs(rho)
    if abs_rho > 0.6:
        return "strong"
    if abs_rho >= 0.3:
        return "moderate"
    return "weak"


# ─── Bucket aggregation ──────────────────────────────────────────────────────


def _bucket_for(sleep_hours: float) -> dict[str, str | float] | None:
    for b in SLEEP_BUCKETS:
        if b["lo"] <= sleep_hours < b["hi"]:  # type: ignore[operator]
            return b
    return None


def _aggregate_buckets(
    rows: list[asyncpg.Record],
) -> list[SleepBucketEntry]:
    """Group rows into sleep buckets and compute per-bucket averages."""
    accum: dict[str, dict] = {}
    for b in SLEEP_BUCKETS:
        accum[str(b["name"])] = {
            "label": str(b["label"]),
            "volumes": [],
            "e1rms": [],
            "rpes": [],
        }

    for row in rows:
        bucket = _bucket_for(float(row["sleep_hours"]))
        if bucket is None:
            continue
        name = str(bucket["name"])
        vol = row["session_volume_kg"]
        if vol is not None:
            accum[name]["volumes"].append(float(vol))
        e1rm = row["best_e1rm"]
        if e1rm is not None:
            accum[name]["e1rms"].append(float(e1rm))
        rpe = row["session_rpe"]
        if rpe is not None:
            accum[name]["rpes"].append(float(rpe))

    entries: list[SleepBucketEntry] = []
    for b in SLEEP_BUCKETS:
        name = str(b["name"])
        data = accum[name]
        count = len(data["volumes"])
        if count == 0:
            continue
        avg_vol = round(sum(data["volumes"]) / count, 1)
        avg_e1rm = round(sum(data["e1rms"]) / len(data["e1rms"]), 1) if data["e1rms"] else None
        avg_rpe = round(sum(data["rpes"]) / len(data["rpes"]), 1) if data["rpes"] else None
        entries.append(
            SleepBucketEntry(
                bucket=name,
                sleep_range=data["label"],
                session_count=count,
                avg_volume_kg=avg_vol,
                avg_e1rm=avg_e1rm,
                avg_rpe=avg_rpe,
            )
        )
    return entries


def _optimal_bucket(buckets: list[SleepBucketEntry]) -> str | None:
    """Return the bucket name with the highest average volume."""
    if not buckets:
        return None
    best = max(buckets, key=lambda b: b.avg_volume_kg)
    return best.sleep_range


# ─── Main service function ────────────────────────────────────────────────────

_QUERY = """\
SELECT
    wf.training_date::text AS training_date,
    wf.sleep_hours,
    wf.prior_sleep_quality,
    wf.session_rpe,
    SUM(
      CASE WHEN s.weight_unit = 'lb'
           THEN s.weight * 0.453592
           ELSE s.weight END * s.reps
    ) AS session_volume_kg,
    COUNT(*) FILTER (WHERE s.set_type = 'working') AS working_sets,
    MAX(s.estimated_1rm) AS best_e1rm
FROM workout_feedback wf
JOIN sets s ON s.user_id = wf.user_id AND s.training_date = wf.training_date
WHERE wf.user_id = $1
  AND wf.training_date >= $2::date
  AND wf.sleep_hours IS NOT NULL
  AND wf.sleep_hours >= 3
  AND s.reps > 0
GROUP BY wf.training_date, wf.sleep_hours, wf.prior_sleep_quality, wf.session_rpe
ORDER BY wf.training_date ASC
"""


async def compute_sleep_performance(
    user_id: str,
    db_pool: asyncpg.Pool,
    period_days: int = 90,
) -> SleepPerformanceResponse:
    """Analyse correlation between self-reported sleep and training performance.

    Uses Spearman rank correlation (non-parametric, robust to outliers)
    and bucket analysis for intuitive sleep-range comparisons.
    """
    cutoff = (datetime.now(UTC) - timedelta(days=period_days)).date()

    async with db_pool.acquire() as conn:
        rows = await conn.fetch(_QUERY, user_id, cutoff)

    n = len(rows)

    # ── Insufficient data ─────────────────────────────────────────────────
    if n == 0:
        return SleepPerformanceResponse(
            correlation_sleep_volume=None,
            correlation_sleep_e1rm=None,
            correlation_sleep_rpe=None,
            correlation_label="insufficient_data",
            confidence="insufficient",
            sleep_buckets=[],
            avg_sleep_hours=None,
            optimal_sleep_range=None,
            data_points=0,
            period_days=period_days,
            disclaimer=DISCLAIMER,
        )

    # ── Extract parallel arrays ───────────────────────────────────────────
    sleep_vals: list[float] = [float(r["sleep_hours"]) for r in rows]
    volume_vals: list[float] = [
        float(r["session_volume_kg"]) if r["session_volume_kg"] is not None else 0.0 for r in rows
    ]
    e1rm_vals: list[float] = [float(r["best_e1rm"]) for r in rows if r["best_e1rm"] is not None]
    e1rm_sleep: list[float] = [float(r["sleep_hours"]) for r in rows if r["best_e1rm"] is not None]
    rpe_vals: list[float] = [float(r["session_rpe"]) for r in rows if r["session_rpe"] is not None]
    rpe_sleep: list[float] = [float(r["sleep_hours"]) for r in rows if r["session_rpe"] is not None]

    # ── Spearman correlations ─────────────────────────────────────────────
    corr_volume = _spearman(sleep_vals, volume_vals)
    corr_e1rm = _spearman(e1rm_sleep, e1rm_vals)
    corr_rpe = _spearman(rpe_sleep, rpe_vals)

    # Use volume correlation as the primary signal for labelling.
    label = _correlation_label(corr_volume)

    # ── Bucket analysis ───────────────────────────────────────────────────
    buckets = _aggregate_buckets(rows)
    optimal = _optimal_bucket(buckets)

    avg_sleep = round(sum(sleep_vals) / n, 1) if n > 0 else None

    return SleepPerformanceResponse(
        correlation_sleep_volume=corr_volume,
        correlation_sleep_e1rm=corr_e1rm,
        correlation_sleep_rpe=corr_rpe,
        correlation_label=label,
        confidence=_confidence_tier(n),
        sleep_buckets=buckets,
        avg_sleep_hours=avg_sleep,
        optimal_sleep_range=optimal,
        data_points=n,
        period_days=period_days,
        disclaimer=DISCLAIMER,
    )
