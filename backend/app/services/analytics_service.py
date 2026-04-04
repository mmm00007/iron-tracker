from datetime import UTC, date, datetime, timedelta
from typing import Any

import asyncpg

from app.models.schemas import ExerciseE1RM, WeeklySummary

# ─── Weekly summary ───────────────────────────────────────────────────────────


async def compute_weekly_summary(
    user_id: str,
    db_pool: asyncpg.Pool,
) -> WeeklySummary:
    """Compute weekly training summary comparing this week to last week.

    Uses window functions to compute both periods in a single query.
    """
    # Determine week boundaries (ISO week: Monday 00:00 UTC)
    today = date.today()
    days_since_monday = today.weekday()  # 0 = Monday
    this_week_start = datetime(today.year, today.month, today.day, tzinfo=UTC) - timedelta(
        days=days_since_monday
    )
    last_week_start = this_week_start - timedelta(weeks=1)

    async with db_pool.acquire() as conn:
        rows = await conn.fetch(
            """
            SELECT
                COUNT(*)                           AS total_sets,
                COALESCE(SUM(weight * reps), 0)    AS total_volume,
                COUNT(DISTINCT DATE(logged_at))    AS training_days,
                CASE
                    WHEN logged_at >= $3 THEN 'this'
                    ELSE 'last'
                END                                AS period
            FROM sets
            WHERE
                user_id = $1
                AND logged_at >= $2
            GROUP BY period
            """,
            user_id,
            last_week_start,
            this_week_start,
        )

    stats: dict[str, dict[str, Any]] = {"this": {}, "last": {}}
    for row in rows:
        period = row["period"]
        stats[period] = {
            "sets": int(row["total_sets"]),
            "volume": float(row["total_volume"]),
            "days": int(row["training_days"]),
        }

    this = stats.get("this", {"sets": 0, "volume": 0.0, "days": 0})
    last = stats.get("last", {"sets": 0, "volume": 0.0, "days": 0})

    # Percentage deltas (None when baseline is 0)
    def pct_delta(current: int | float, previous: int | float) -> int | None:
        if previous == 0:
            return None
        return round((current - previous) / previous * 100)

    return WeeklySummary(
        total_sets=this["sets"],
        total_volume=this["volume"],
        training_days=this["days"],
        delta_sets=pct_delta(this["sets"], last["sets"]),
        delta_volume=pct_delta(this["volume"], last["volume"]),
    )


# ─── 1RM trend ────────────────────────────────────────────────────────────────


async def compute_1rm_trend(
    user_id: str,
    exercise_id: str,
    db_pool: asyncpg.Pool,
) -> list[ExerciseE1RM]:
    """Compute the best estimated 1RM per day for a given exercise.

    Returns data points sorted oldest → newest.
    """
    async with db_pool.acquire() as conn:
        rows = await conn.fetch(
            """
            SELECT
                DATE(logged_at) AS day,
                MAX(
                    CASE WHEN reps <= 1 THEN weight
                         ELSE weight * (1 + reps / 30.0)
                    END
                ) AS best_e1rm
            FROM sets
            WHERE
                user_id = $1
                AND exercise_id = $2
                AND weight > 0
                AND reps > 0
            GROUP BY DATE(logged_at)
            ORDER BY day ASC
            """,
            user_id,
            exercise_id,
        )

    return [
        ExerciseE1RM(
            exercise_id=exercise_id,
            date=str(row["day"]),
            estimated_1rm=round(float(row["best_e1rm"]), 2),
        )
        for row in rows
    ]
