"""Rest period distribution and analysis by exercise mechanic."""

from datetime import UTC, datetime, timedelta

import asyncpg

from app.models.schemas import (
    RestAnalysisResponse,
    RestByTypeEntry,
    RestTrendEntry,
)

# ─── NSCA-based optimal rest ranges (hypertrophy default) ────────────────────
# Compound + hypertrophy: 90-180s
# Isolation + hypertrophy: 60-120s
# Unknown: wide 60-180s

_OPTIMAL_RANGES: dict[str, tuple[int, int]] = {
    "compound": (90, 180),
    "isolation": (60, 120),
    "unknown": (60, 180),
}

DISCLAIMER = (
    "Rest period recommendations vary by training goal and exercise intensity. "
    "Heavy compound lifts generally require 2-5 minutes of rest for full "
    "recovery. Individuals with cardiovascular conditions should consult "
    "their physician."
)

# ─── SQL ─────────────────────────────────────────────────────────────────────

_SQL_REST_BY_TYPE = """
SELECT
    COALESCE(e.mechanic, 'unknown') AS mechanic,
    COALESCE(e.exercise_type, 'unknown') AS exercise_type,
    s.set_type,
    COUNT(*) AS set_count,
    AVG(s.rest_seconds) AS avg_rest,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY s.rest_seconds) AS median_rest,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY s.rest_seconds) AS p25_rest,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY s.rest_seconds) AS p75_rest
FROM sets s
JOIN exercises e ON e.id = s.exercise_id
WHERE s.user_id = $1
  AND s.logged_at >= $2
  AND s.rest_seconds IS NOT NULL
  AND s.rest_seconds BETWEEN 15 AND 600
  AND s.set_type = 'working'
GROUP BY COALESCE(e.mechanic, 'unknown'), COALESCE(e.exercise_type, 'unknown'), s.set_type
ORDER BY avg_rest DESC
"""

_SQL_WEEKLY_TREND = """
SELECT
    DATE_TRUNC('week', s.logged_at)::date::text AS week_start,
    AVG(s.rest_seconds) AS avg_rest,
    COUNT(*) AS sets_with_rest
FROM sets s
WHERE s.user_id = $1
  AND s.logged_at >= $2
  AND s.rest_seconds IS NOT NULL
  AND s.rest_seconds BETWEEN 15 AND 600
GROUP BY DATE_TRUNC('week', s.logged_at)
ORDER BY week_start ASC
"""

_SQL_TOTAL_WORKING_SETS = """
SELECT COUNT(*) AS total_working_sets
FROM sets
WHERE user_id = $1
  AND logged_at >= $2
  AND set_type = 'working'
"""


def _classify_mechanic(mechanic: str) -> str:
    """Normalise mechanic to one of: compound, isolation, unknown."""
    lower = mechanic.lower()
    if lower == "compound":
        return "compound"
    if lower in ("isolation", "isolated"):
        return "isolation"
    return "unknown"


async def compute_rest_analysis(
    user_id: str,
    db_pool: asyncpg.Pool,
    period_days: int = 28,
) -> RestAnalysisResponse:
    """Analyse rest period distribution and compliance over *period_days*.

    Steps:
    1. Query sets with rest_seconds between 15-600 (outlier filter).
    2. Segment by exercise mechanic (compound / isolation / unknown).
    3. Compute distribution stats (avg, median, p25, p75).
    4. Weekly trend of average rest.
    5. NSCA-based compliance: % of sets within optimal range per type.
    6. Generate actionable flags.
    """

    since = datetime.now(UTC) - timedelta(days=period_days)

    async with db_pool.acquire() as conn:
        type_rows = await conn.fetch(_SQL_REST_BY_TYPE, user_id, since)
        trend_rows = await conn.fetch(_SQL_WEEKLY_TREND, user_id, since)
        total_row = await conn.fetchrow(_SQL_TOTAL_WORKING_SETS, user_id, since)

    total_working_sets: int = total_row["total_working_sets"] if total_row else 0

    # ── Build by-type entries ────────────────────────────────────────────
    by_type: list[RestByTypeEntry] = []
    all_avg_rests: list[float] = []
    all_median_rests: list[float] = []
    total_sets_with_rest = 0
    compound_sets_short_rest = 0
    compound_sets_total = 0
    compound_avg_rest: float | None = None

    for row in type_rows:
        mechanic_raw: str = row["mechanic"]
        category = _classify_mechanic(mechanic_raw)
        set_count: int = row["set_count"]
        avg_rest: float = float(row["avg_rest"])
        median_rest: float = float(row["median_rest"])
        p25_rest: float = float(row["p25_rest"])
        p75_rest: float = float(row["p75_rest"])

        low, high = _OPTIMAL_RANGES.get(category, (60, 180))

        # Count sets within optimal range for compliance.
        # We approximate from the distribution: sets whose rest is in [low, high].
        # Since we only have aggregate stats, we re-query per category below.
        # For efficiency we compute compliance from median/IQR heuristic:
        # but the precise way is to count in SQL.  We'll use the p25/p75 as a
        # rough proxy — but to be accurate, we count via a subquery approach
        # using the available stats.  The simplest correct method: we already
        # have the full aggregation, so we store and compute compliance after
        # a dedicated count query below.

        total_sets_with_rest += set_count

        if category == "compound":
            compound_sets_total += set_count
            compound_avg_rest = avg_rest

        all_avg_rests.append(avg_rest * set_count)
        all_median_rests.append(median_rest)

        by_type.append(
            RestByTypeEntry(
                category=category,
                mechanic=mechanic_raw if mechanic_raw != "unknown" else None,
                set_count=set_count,
                avg_rest=round(avg_rest, 1),
                median_rest=round(median_rest, 1),
                p25_rest=round(p25_rest, 1),
                p75_rest=round(p75_rest, 1),
                optimal_range_low=float(low),
                optimal_range_high=float(high),
                compliance_pct=0.0,  # filled below
            )
        )

    # ── Compliance: count sets within optimal range per category ──────────
    if by_type:
        async with db_pool.acquire() as conn:
            for entry in by_type:
                opt_low = entry.optimal_range_low
                opt_high = entry.optimal_range_high
                mechanic_val = entry.mechanic if entry.mechanic else "unknown"
                compliant = await conn.fetchval(
                    """
                    SELECT COUNT(*)
                    FROM sets s
                    JOIN exercises e ON e.id = s.exercise_id
                    WHERE s.user_id = $1
                      AND s.logged_at >= $2
                      AND s.rest_seconds IS NOT NULL
                      AND s.rest_seconds BETWEEN 15 AND 600
                      AND s.set_type = 'working'
                      AND COALESCE(e.mechanic, 'unknown') = $3
                      AND s.rest_seconds BETWEEN $4 AND $5
                    """,
                    user_id,
                    since,
                    mechanic_val,
                    opt_low,
                    opt_high,
                )
                entry.compliance_pct = (
                    round(compliant / entry.set_count * 100, 1) if entry.set_count > 0 else 0.0
                )

            # Short-rest compounds (< 60s)
            compound_sets_short_rest = await conn.fetchval(
                """
                SELECT COUNT(*)
                FROM sets s
                JOIN exercises e ON e.id = s.exercise_id
                WHERE s.user_id = $1
                  AND s.logged_at >= $2
                  AND s.rest_seconds IS NOT NULL
                  AND s.rest_seconds BETWEEN 15 AND 600
                  AND s.set_type = 'working'
                  AND COALESCE(e.mechanic, 'unknown') = 'compound'
                  AND s.rest_seconds < 60
                """,
                user_id,
                since,
            )

    # ── Weekly trend ─────────────────────────────────────────────────────
    weekly_trend = [
        RestTrendEntry(
            week_start=row["week_start"],
            avg_rest=round(float(row["avg_rest"]), 1),
            sets_with_rest=row["sets_with_rest"],
        )
        for row in trend_rows
    ]

    # ── Overall aggregates ───────────────────────────────────────────────
    overall_avg: float | None = None
    overall_median: float | None = None
    if total_sets_with_rest > 0:
        overall_avg = round(sum(all_avg_rests) / total_sets_with_rest, 1)
    if all_median_rests:
        sorted_medians = sorted(all_median_rests)
        mid = len(sorted_medians) // 2
        if len(sorted_medians) % 2 == 0 and len(sorted_medians) >= 2:
            overall_median = round((sorted_medians[mid - 1] + sorted_medians[mid]) / 2, 1)
        else:
            overall_median = round(sorted_medians[mid], 1)

    rest_coverage_pct = (
        round(total_sets_with_rest / total_working_sets * 100, 1) if total_working_sets > 0 else 0.0
    )

    # ── Flags ────────────────────────────────────────────────────────────
    flags: list[str] = []

    if compound_sets_total > 0 and compound_sets_short_rest > 0:
        pct = round(compound_sets_short_rest / compound_sets_total * 100, 1)
        if pct > 0:
            flags.append(f"Short rest on compounds: {pct}% of compound sets have rest < 60s")

    # Count very-long-rest sets (> 300s excluded by the 600s ceiling,
    # but we flag sets between 300-600 as "very long").
    async with db_pool.acquire() as conn:
        very_long_count = await conn.fetchval(
            """
            SELECT COUNT(*)
            FROM sets
            WHERE user_id = $1
              AND logged_at >= $2
              AND rest_seconds IS NOT NULL
              AND rest_seconds > 300
              AND set_type = 'working'
            """,
            user_id,
            since,
        )
    if very_long_count and very_long_count > 0:
        flags.append(
            f"Very long rest: {very_long_count} sets had rest > 5 minutes (excluded from analysis)"
        )

    if compound_avg_rest is not None and compound_avg_rest < 60:
        flags.append(
            "Consider longer rest periods between heavy compound sets for safety and recovery"
        )

    return RestAnalysisResponse(
        by_type=by_type,
        weekly_trend=weekly_trend,
        overall_avg_rest=overall_avg,
        overall_median_rest=overall_median,
        rest_coverage_pct=rest_coverage_pct,
        flags=flags,
        period_days=period_days,
        disclaimer=DISCLAIMER,
    )
