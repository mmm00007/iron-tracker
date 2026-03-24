import json
import logging
import uuid
from datetime import datetime, timedelta

import asyncpg

logger = logging.getLogger(__name__)


async def generate_weekly_summaries(db_pool: asyncpg.Pool) -> int:
    """Generate weekly training summaries for all active users.

    Returns the number of summaries generated.
    """
    # Find users who trained in the last 7 days
    week_ago = datetime.utcnow() - timedelta(days=7)

    async with db_pool.acquire() as conn:
        user_ids = await conn.fetch(
            """
            SELECT DISTINCT user_id FROM sets
            WHERE logged_at >= $1
            """,
            week_ago,
        )

    count = 0
    for row in user_ids:
        user_id = str(row["user_id"])
        try:
            await _generate_user_summary(db_pool, user_id, week_ago)
            count += 1
        except Exception as e:
            logger.error("Failed to generate summary for user %s: %s", user_id, e)

    return count


async def _generate_user_summary(
    db_pool: asyncpg.Pool,
    user_id: str,
    since: datetime,
) -> None:
    async with db_pool.acquire() as conn:
        # This week's stats
        rows = await conn.fetch(
            """
            SELECT s.weight, s.reps, s.logged_at, e.name AS exercise_name, e.category
            FROM sets s
            JOIN exercises e ON s.exercise_id = e.id
            WHERE s.user_id = $1 AND s.logged_at >= $2
            ORDER BY s.logged_at
            """,
            user_id,
            since,
        )

        if not rows:
            return

        total_sets = len(rows)
        total_volume = sum(r["weight"] * r["reps"] for r in rows)
        training_days = len(set(r["logged_at"].strftime("%Y-%m-%d") for r in rows))
        exercises = {}
        for r in rows:
            name = r["exercise_name"]
            if name not in exercises:
                exercises[name] = {"sets": 0, "volume": 0}
            exercises[name]["sets"] += 1
            exercises[name]["volume"] += r["weight"] * r["reps"]

        top_exercises = sorted(exercises.items(), key=lambda x: -x[1]["volume"])[:5]

        summary = {
            "week_ending": datetime.utcnow().strftime("%Y-%m-%d"),
            "total_sets": total_sets,
            "total_volume": round(total_volume),
            "training_days": training_days,
            "top_exercises": [
                {"name": name, "sets": data["sets"], "volume": round(data["volume"])}
                for name, data in top_exercises
            ],
        }

        # Store as an analysis report with scope_type='week'
        report_id = str(uuid.uuid4())
        summary_text = (
            f"This week: {total_sets} sets across {training_days} days, "
            f"{round(total_volume)} total volume. "
            f"Top exercise: {top_exercises[0][0] if top_exercises else 'N/A'}."
        )

        await conn.execute(
            """
            INSERT INTO analysis_reports (id, user_id, scope_type, scope_start, scope_end, goals, summary, insights)
            VALUES ($1, $2, 'week', $3::date, $4::date, $5, $6, $7::jsonb)
            ON CONFLICT DO NOTHING
            """,
            report_id,
            user_id,
            (datetime.utcnow() - timedelta(days=7)).strftime("%Y-%m-%d"),
            datetime.utcnow().strftime("%Y-%m-%d"),
            ["weekly_summary"],
            summary_text,
            json.dumps(
                [
                    {
                        "metric": "Weekly Overview",
                        "finding": summary_text,
                        "delta": None,
                        "recommendation": f"You trained {training_days} days. {'Great consistency!' if training_days >= 4 else 'Try to add another training day next week.'}",
                    }
                ]
            ),
        )
