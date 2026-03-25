"""Plan adherence tracking and trend analysis.

Monitors how consistently a user follows their training plan over time by
comparing planned vs completed sets per week. Uses linear regression on
weekly adherence ratios to detect improving or declining trends.

Burnout risk is flagged when adherence is declining steeply (slope < -0.03)
AND average RPE over the last 4 weeks exceeds 8.0 — a combination that
suggests accumulated fatigue rather than simple schedule conflicts
(Halson 2014, Meeusen et al. 2013).

Exceedance tracking counts weeks where the user performed surplus sets
beyond the plan, which may indicate poor autoregulation or plan mismatch.
"""

from datetime import UTC, datetime, timedelta

import asyncpg

from functools import partial

from app.models.schemas import AdherenceWeekEntry, PlanAdherenceResponse
from app.services.utils import linear_regression

_DISCLAIMER = (
    "Plan adherence reflects consistency with your training plan. "
    "Declining adherence combined with high perceived effort may indicate "
    "accumulated fatigue. This is not medical advice."
)

_MIN_WEEKS_FOR_TREND = 4

_IMPROVING_THRESHOLD = 0.02
_DECLINING_THRESHOLD = -0.02
_BURNOUT_SLOPE_THRESHOLD = -0.03
_BURNOUT_RPE_THRESHOLD = 8.0

_linear_regression = partial(linear_regression, min_points=_MIN_WEEKS_FOR_TREND)


def _classify_trend(slope: float | None) -> str:
    """Classify adherence trend direction from regression slope."""
    if slope is None:
        return "insufficient_data"
    if slope > _IMPROVING_THRESHOLD:
        return "improving"
    if slope < _DECLINING_THRESHOLD:
        return "declining"
    return "stable"


async def compute_plan_adherence(
    user_id: str,
    db_pool: asyncpg.Pool,
    weeks: int = 12,
) -> PlanAdherenceResponse:
    """Compute plan adherence metrics over the requested period.

    Returns weekly breakdown, trend direction via linear regression,
    burnout risk assessment, and exceedance count.
    """
    cutoff = datetime.now(UTC) - timedelta(weeks=weeks)

    async with db_pool.acquire() as conn:
        rows = await conn.fetch(
            """
            SELECT
                DATE_TRUNC('week', pal.training_date)::date::text AS week_start,
                AVG(pal.adherence_ratio)::float                   AS avg_adherence,
                SUM(pal.planned_sets)                             AS planned_sets,
                SUM(pal.completed_sets)                           AS completed_sets,
                SUM(COALESCE(pal.surplus_sets, 0))                AS surplus_sets,
                SUM(COALESCE(pal.items_skipped, 0))               AS items_skipped
            FROM plan_adherence_log pal
            WHERE pal.user_id = $1
              AND pal.training_date >= $2
            GROUP BY DATE_TRUNC('week', pal.training_date)
            ORDER BY week_start ASC
            """,
            user_id,
            cutoff,
        )

    # Build weekly entries
    week_entries: list[AdherenceWeekEntry] = [
        AdherenceWeekEntry(
            week_start=row["week_start"],
            avg_adherence=round(row["avg_adherence"], 3),
            planned_sets=int(row["planned_sets"]),
            completed_sets=int(row["completed_sets"]),
            surplus_sets=int(row["surplus_sets"]),
            items_skipped=int(row["items_skipped"]),
        )
        for row in rows
    ]

    if not week_entries:
        return PlanAdherenceResponse(
            weeks=[],
            current_adherence=None,
            trend_direction="insufficient_data",
            trend_slope=None,
            burnout_risk=False,
            exceedance_weeks=0,
            period_weeks=weeks,
            disclaimer=_DISCLAIMER,
        )

    # Current adherence = most recent week
    current_adherence = week_entries[-1].avg_adherence

    # Linear regression on weekly adherence ratios
    xs = list(range(len(week_entries)))
    ys = [w.avg_adherence for w in week_entries]
    slope, _intercept = _linear_regression(
        [float(x) for x in xs], ys
    )
    trend_direction = _classify_trend(slope)

    # Burnout risk: steep decline + high recent RPE
    burnout_risk = False
    if slope is not None and slope < _BURNOUT_SLOPE_THRESHOLD:
        async with db_pool.acquire() as conn:
            rpe_row = await conn.fetchrow(
                """
                SELECT AVG(tds.avg_rpe) AS recent_avg_rpe
                FROM training_day_summary tds
                WHERE tds.user_id = $1
                  AND tds.training_date >= (CURRENT_DATE - INTERVAL '28 days')
                  AND tds.avg_rpe IS NOT NULL
                """,
                user_id,
            )
        if rpe_row and rpe_row["recent_avg_rpe"] is not None:
            burnout_risk = float(rpe_row["recent_avg_rpe"]) > _BURNOUT_RPE_THRESHOLD

    # Exceedance = weeks with surplus sets > 0
    exceedance_weeks = sum(1 for w in week_entries if w.surplus_sets > 0)

    return PlanAdherenceResponse(
        weeks=week_entries,
        current_adherence=current_adherence,
        trend_direction=trend_direction,
        trend_slope=round(slope, 4) if slope is not None else None,
        burnout_risk=burnout_risk,
        exceedance_weeks=exceedance_weeks,
        period_weeks=weeks,
        disclaimer=_DISCLAIMER,
    )
