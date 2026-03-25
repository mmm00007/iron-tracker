"""Milestone velocity — tracks the pace at which a lifter achieves new PRs.

Milestone velocity is a higher-order training metric that measures how
frequently an athlete achieves meaningful milestones (1RM PRs, volume PRs,
bodyweight-relative thresholds, etc.). The velocity of milestone accumulation
is a strong indicator of effective programming — accelerating velocity
suggests the program is well-matched to the athlete's recovery capacity and
training age, while decelerating velocity may signal the need for periodization
changes (Zourdos et al. 2016, Helms et al. 2014).

Trend classification uses a rolling comparison:
  - Last 3 inter-milestone intervals vs overall average
  - < 80% of average → accelerating (PRs coming faster)
  - > 120% of average → decelerating (PRs slowing down)
  - Otherwise → stable

Cold start thresholds:
  - < 2 milestones: list only (no velocity computation)
  - < 3 milestones with intervals: no trend (insufficient data points)
"""

from datetime import UTC, datetime, timedelta
from statistics import mean

import asyncpg

from app.models.schemas import MilestoneEntry, MilestoneVelocityResponse

_DISCLAIMER = (
    "Past performance does not guarantee future results. Progress rates vary "
    "based on training age, nutrition, sleep, and individual genetics."
)

_MILESTONE_QUERY = """
SELECT
    tm.id::text,
    tm.milestone_type,
    tm.exercise_id::text,
    e.name AS exercise_name,
    tm.value::float,
    tm.unit,
    tm.achieved_at::text,
    tm.body_weight_at::float,
    LAG(tm.achieved_at) OVER (
        PARTITION BY tm.user_id, tm.exercise_id, tm.milestone_type
        ORDER BY tm.achieved_at
    ) AS prev_achieved_at
FROM training_milestones tm
LEFT JOIN exercises e ON e.id = tm.exercise_id
WHERE tm.user_id = $1
  AND tm.achieved_at >= $2
ORDER BY tm.achieved_at DESC
"""


async def compute_milestone_velocity(
    user_id: str,
    db_pool: asyncpg.Pool,
    period_days: int = 180,
) -> MilestoneVelocityResponse:
    """Compute milestone accumulation velocity and trend over a period.

    Returns milestone list with inter-milestone intervals, 30d/90d counts,
    average interval between milestones, and an acceleration trend indicator.
    """
    cutoff = datetime.now(UTC) - timedelta(days=period_days)

    async with db_pool.acquire() as conn:
        rows = await conn.fetch(_MILESTONE_QUERY, user_id, cutoff)

    if not rows:
        return MilestoneVelocityResponse(
            milestones=[],
            total_count=0,
            milestones_30d=0,
            milestones_90d=0,
            avg_interval_days=None,
            velocity_trend="insufficient_data",
            period_days=period_days,
            disclaimer=_DISCLAIMER,
        )

    now = datetime.now(UTC)
    threshold_30d = now - timedelta(days=30)
    threshold_90d = now - timedelta(days=90)

    milestones: list[MilestoneEntry] = []
    intervals: list[int] = []
    count_30d = 0
    count_90d = 0

    for row in rows:
        achieved_str: str = row["achieved_at"]
        achieved_at = datetime.fromisoformat(achieved_str)

        # Compute days since previous milestone for same exercise+type
        days_since: int | None = None
        if row["prev_achieved_at"] is not None:
            prev_dt = row["prev_achieved_at"]
            if isinstance(prev_dt, str):
                prev_dt = datetime.fromisoformat(prev_dt)
            delta = achieved_at - prev_dt
            days_since = delta.days
            if days_since >= 0:
                intervals.append(days_since)

        # Count milestones in recent windows
        if achieved_at.tzinfo is None:
            achieved_aware = achieved_at.replace(tzinfo=UTC)
        else:
            achieved_aware = achieved_at
        if achieved_aware >= threshold_30d:
            count_30d += 1
        if achieved_aware >= threshold_90d:
            count_90d += 1

        milestones.append(
            MilestoneEntry(
                milestone_type=row["milestone_type"],
                exercise_name=row["exercise_name"],
                value=row["value"],
                unit=row["unit"],
                achieved_at=achieved_str,
                body_weight_at=row["body_weight_at"],
                days_since_previous=days_since,
            )
        )

    total_count = len(milestones)

    # Need at least 2 milestones (producing >= 1 interval) for velocity
    avg_interval: float | None = None
    if intervals:
        avg_interval = round(mean(intervals), 1)

    # Need at least 3 intervals for a meaningful trend comparison
    velocity_trend = _compute_trend(intervals, avg_interval)

    return MilestoneVelocityResponse(
        milestones=milestones,
        total_count=total_count,
        milestones_30d=count_30d,
        milestones_90d=count_90d,
        avg_interval_days=avg_interval,
        velocity_trend=velocity_trend,
        period_days=period_days,
        disclaimer=_DISCLAIMER,
    )


def _compute_trend(
    intervals: list[int],
    avg_interval: float | None,
) -> str:
    """Determine velocity trend from inter-milestone intervals.

    Compares the average of the last 3 intervals against the overall average.
    A shorter recent interval means milestones are arriving faster (accelerating).

    Returns one of: accelerating, stable, decelerating, insufficient_data.
    """
    if avg_interval is None or len(intervals) < 3:
        return "insufficient_data"

    # Intervals are appended in descending achieved_at order (newest first),
    # so the first 3 entries are the most recent intervals.
    last_3_avg = mean(intervals[:3])

    if last_3_avg < avg_interval * 0.8:
        return "accelerating"
    if last_3_avg > avg_interval * 1.2:
        return "decelerating"
    return "stable"
