"""Training load distribution analysis — how evenly volume is spread across the week.

Well-distributed training (spreading volume across 3-5 days) is associated with:
  1. Better recovery between sessions (Helms et al. 2015)
  2. More consistent muscle protein synthesis stimulus (Dankel et al. 2017)
  3. Lower per-session fatigue, reducing injury risk

Flags problematic patterns:
  - Front-loaded: >60% of weekly volume in first 2 training days
  - Back-loaded: >60% of weekly volume in last 2 training days
  - Concentrated: >50% of weekly volume in a single day
  - Well-distributed: no single day exceeds 35% of weekly volume

Uses the coefficient of variation (CV) of daily volumes within each week
as the primary distribution metric. Lower CV = more evenly distributed.
"""

import math
from datetime import UTC, date, datetime, timedelta

import asyncpg

from app.models.schemas import (
    DayLoadEntry,
    LoadDistributionResponse,
    WeekDistributionEntry,
)

_DAY_NAMES = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]


def _distribution_label(cv: float) -> str:
    """Classify distribution evenness based on CV of training-day volumes."""
    if cv < 0.25:
        return "very_even"
    if cv < 0.5:
        return "well_distributed"
    if cv < 0.75:
        return "moderately_uneven"
    return "highly_concentrated"


async def compute_load_distribution(
    user_id: str,
    db_pool: asyncpg.Pool,
    weeks: int = 4,
) -> LoadDistributionResponse:
    """Analyze how training volume is distributed across the week.

    Returns per-day-of-week volume averages, distribution evenness,
    and flags for problematic loading patterns.
    """
    since = datetime.now(UTC) - timedelta(weeks=weeks)

    async with db_pool.acquire() as conn:
        rows = await conn.fetch(
            """
            SELECT
                DATE(logged_at)              AS day,
                EXTRACT(DOW FROM logged_at)  AS dow,
                SUM(weight * reps)           AS daily_volume
            FROM sets
            WHERE user_id = $1
              AND logged_at >= $2
              AND weight > 0
              AND reps > 0
            GROUP BY DATE(logged_at), EXTRACT(DOW FROM logged_at)
            ORDER BY DATE(logged_at)
            """,
            user_id,
            since,
        )

    if not rows:
        return LoadDistributionResponse(
            day_averages=[],
            week_breakdown=[],
            distribution_cv=None,
            distribution_label="insufficient_data",
            flags=[],
            busiest_day=None,
            lightest_day=None,
            period_weeks=weeks,
        )

    # Aggregate by day of week (0=Sunday in PG, convert to Monday=0)
    dow_volumes: dict[int, list[float]] = {i: [] for i in range(7)}
    day_volumes: dict[date, tuple[float, int]] = {}

    for row in rows:
        # PG DOW: 0=Sunday, 1=Monday, ..., 6=Saturday
        # Convert to Monday=0
        pg_dow = int(row["dow"])
        py_dow = (pg_dow - 1) % 7  # Monday=0
        vol = float(row["daily_volume"])
        dow_volumes[py_dow].append(vol)
        day_volumes[row["day"]] = (vol, py_dow)

    # Per-day-of-week averages
    day_averages: list[DayLoadEntry] = []
    for dow in range(7):
        vols = dow_volumes[dow]
        avg = round(sum(vols) / len(vols), 1) if vols else 0.0
        day_averages.append(
            DayLoadEntry(
                day_of_week=dow,
                day_name=_DAY_NAMES[dow],
                avg_volume=avg,
                session_count=len(vols),
            )
        )

    # Weekly breakdown
    today = date.today()
    week_entries: list[WeekDistributionEntry] = []
    for w in range(weeks):
        week_start = today - timedelta(days=today.weekday() + 7 * (weeks - 1 - w))
        week_days = []
        week_vol = 0.0
        for d in range(7):
            day = week_start + timedelta(days=d)
            if day in day_volumes:
                vol, _ = day_volumes[day]
                week_days.append(vol)
                week_vol += vol
            else:
                week_days.append(0.0)

        training_day_vols = [v for v in week_days if v > 0]
        if training_day_vols:
            mean_v = sum(training_day_vols) / len(training_day_vols)
            variance = sum((v - mean_v) ** 2 for v in training_day_vols) / len(training_day_vols)
            cv = round(math.sqrt(variance) / mean_v, 3) if mean_v > 0 else 0.0
            max_day_pct = round(max(training_day_vols) / week_vol * 100, 1) if week_vol > 0 else 0
        else:
            cv = 0.0
            max_day_pct = 0.0

        week_entries.append(
            WeekDistributionEntry(
                week_start=str(week_start),
                total_volume=round(week_vol),
                training_days=len(training_day_vols),
                cv=cv,
                max_day_percentage=max_day_pct,
            )
        )

    # Overall CV across all training days
    all_training_vols = [v for vols in dow_volumes.values() for v in vols]
    if len(all_training_vols) >= 3:
        mean_all = sum(all_training_vols) / len(all_training_vols)
        var_all = sum((v - mean_all) ** 2 for v in all_training_vols) / len(all_training_vols)
        overall_cv = round(math.sqrt(var_all) / mean_all, 3) if mean_all > 0 else None
    else:
        overall_cv = None

    # Flags
    flags: list[str] = []
    active_days = [d for d in day_averages if d.session_count > 0]

    if active_days:
        total_avg = sum(d.avg_volume for d in active_days)
        sorted_by_vol = sorted(active_days, key=lambda d: -d.avg_volume)

        if total_avg > 0:
            top_day_pct = sorted_by_vol[0].avg_volume / total_avg * 100
            if top_day_pct > 50:
                flags.append(
                    f"Concentrated: {sorted_by_vol[0].day_name} averages "
                    f"{top_day_pct:.0f}% of weekly volume"
                )

        if len(active_days) <= 2 and weeks >= 2:
            flags.append(
                "Low frequency: training only "
                f"{len(active_days)} day(s)/week limits volume distribution"
            )

    busiest = max(day_averages, key=lambda d: d.avg_volume) if day_averages else None
    lightest_active = [d for d in day_averages if d.session_count > 0]
    lightest = min(lightest_active, key=lambda d: d.avg_volume) if lightest_active else None

    return LoadDistributionResponse(
        day_averages=day_averages,
        week_breakdown=week_entries,
        distribution_cv=overall_cv,
        distribution_label=(
            _distribution_label(overall_cv) if overall_cv is not None
            else "insufficient_data"
        ),
        flags=flags,
        busiest_day=busiest.day_name if busiest and busiest.avg_volume > 0 else None,
        lightest_day=lightest.day_name if lightest else None,
        period_weeks=weeks,
    )
