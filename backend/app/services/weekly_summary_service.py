import json
import logging
import uuid
from datetime import UTC, datetime, timedelta

import asyncpg

from app.services.muscle_workload_service import compute_muscle_workload
from app.services.periodization_service import compute_body_part_balance
from app.services.volume_landmarks_service import compute_volume_landmarks

logger = logging.getLogger(__name__)


async def generate_weekly_summaries(db_pool: asyncpg.Pool) -> int:
    """Generate enriched weekly training summaries for all active users.

    Returns the number of summaries generated.
    """
    week_ago = datetime.now(UTC) - timedelta(days=7)

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
    # ── Phase 1: Fetch set data, then release the connection ──
    async with db_pool.acquire() as conn:
        rows = await conn.fetch(
            """
            SELECT s.weight, s.reps, s.rpe, s.set_type, s.logged_at,
                   e.name AS exercise_name, e.category
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

    # ── Phase 2: Compute metrics from fetched data (no connection held) ──
    total_sets = len(rows)
    total_volume = sum(r["weight"] * r["reps"] for r in rows)
    training_days = len(set(r["logged_at"].strftime("%Y-%m-%d") for r in rows))

    exercises: dict[str, dict] = {}
    for r in rows:
        name = r["exercise_name"]
        if name not in exercises:
            exercises[name] = {"sets": 0, "volume": 0}
        exercises[name]["sets"] += 1
        exercises[name]["volume"] += r["weight"] * r["reps"]

    top_exercises = sorted(exercises.items(), key=lambda x: -x[1]["volume"])[:5]

    working_types = {"working", "amrap", "dropset", "backoff", "failure"}
    rpe_values = [
        float(r["rpe"])
        for r in rows
        if r["rpe"] is not None and (r["set_type"] or "working") in working_types
    ]
    avg_rpe = round(sum(rpe_values) / len(rpe_values), 1) if rpe_values else None
    effective_sets = sum(1 for r in rows if r["rpe"] is not None and float(r["rpe"]) >= 7)

    # Sub-services each acquire and release their own connections sequentially.
    # No outer connection is held during these calls, so peak usage is 1 conn.
    try:
        workload = await compute_muscle_workload(user_id, db_pool, period_days=7)
        balance_index = workload.balance_index
        balance_label = workload.balance_label
    except Exception as exc:
        logger.warning("Muscle workload failed for user %s: %s", user_id, exc)
        balance_index = None
        balance_label = None

    try:
        landmarks = await compute_volume_landmarks(user_id, db_pool)
        muscles_over_mrv = landmarks.muscles_over_mrv
        muscles_below_mev = landmarks.muscles_below_mev
    except Exception as exc:
        logger.warning("Volume landmarks failed for user %s: %s", user_id, exc)
        muscles_over_mrv = 0
        muscles_below_mev = 0

    try:
        balance = await compute_body_part_balance(user_id, db_pool, period_days=7)
        push_pull_ratio = balance.push_pull_ratio
        push_pull_status = balance.push_pull_status
    except Exception as exc:
        logger.warning("Body part balance failed for user %s: %s", user_id, exc)
        push_pull_ratio = None
        push_pull_status = None

    # ── Build insights array ──
    insights = []

    # Core overview
    summary_text = (
        f"This week: {total_sets} sets across {training_days} days, "
        f"{round(total_volume)} total volume. "
        f"Top exercise: {top_exercises[0][0] if top_exercises else 'N/A'}."
    )

    consistency_rec = (
        "Great consistency!" if training_days >= 4 else "Try to add another training day next week."
    )
    insights.append(
        {
            "metric": "Weekly Overview",
            "finding": summary_text,
            "delta": None,
            "recommendation": f"You trained {training_days} days. {consistency_rec}",
        }
    )

    # Intensity insight
    if avg_rpe is not None:
        if avg_rpe > 8.5:
            rpe_rec = "Average RPE is very high. Consider incorporating lighter sessions to manage fatigue."
        elif avg_rpe < 6.0:
            rpe_rec = "Average RPE is low. You may benefit from pushing closer to failure on working sets."
        else:
            rpe_rec = "Good intensity management. Most sets are in the productive RPE range."
        insights.append(
            {
                "metric": "Training Intensity",
                "finding": f"Average RPE: {avg_rpe}. Effective sets (RPE≥7): {effective_sets}/{total_sets}.",
                "delta": None,
                "recommendation": rpe_rec,
            }
        )

    # Balance insight
    if balance_index is not None:
        if balance_label == "well_balanced":
            bal_rec = "Excellent muscle group coverage this week."
        elif balance_label == "moderate":
            bal_rec = "Consider diversifying exercises to cover underrepresented muscle groups."
        else:
            bal_rec = "Training is heavily concentrated on few muscle groups. Broaden your exercise selection."
        insights.append(
            {
                "metric": "Workload Balance",
                "finding": f"Balance index: {balance_index:.2f} ({balance_label}).",
                "delta": None,
                "recommendation": bal_rec,
            }
        )

    # Volume landmarks insight
    if muscles_over_mrv > 0:
        insights.append(
            {
                "metric": "Volume Warning",
                "finding": f"{muscles_over_mrv} muscle group(s) exceed Maximum Recoverable Volume.",
                "delta": None,
                "recommendation": "Consider reducing volume for overloaded muscle groups or planning a deload.",
            }
        )
    if muscles_below_mev > 0:
        insights.append(
            {
                "metric": "Volume Gap",
                "finding": f"{muscles_below_mev} muscle group(s) below Minimum Effective Volume.",
                "delta": None,
                "recommendation": "Add sets for underserved muscle groups to stimulate growth.",
            }
        )

    # Push/pull insight
    if push_pull_ratio is not None and push_pull_status == "imbalanced":
        direction = "push-dominant" if push_pull_ratio > 1.0 else "pull-dominant"
        insights.append(
            {
                "metric": "Push/Pull Balance",
                "finding": f"Push/pull ratio: {push_pull_ratio:.2f} ({direction}).",
                "delta": None,
                "recommendation": (
                    "Add more pulling exercises (rows, pulldowns) to balance shoulder health."
                    if push_pull_ratio > 1.0
                    else "Consider adding more pressing movements."
                ),
            }
        )

    # ── Phase 3: Re-acquire a connection for the INSERT ──
    report_id = str(uuid.uuid4())
    now = datetime.now(UTC)

    async with db_pool.acquire() as conn:
        await conn.execute(
            """
            INSERT INTO analysis_reports (id, user_id, scope_type, scope_start, scope_end, goals, summary, insights)
            VALUES ($1, $2, 'week', $3::date, $4::date, $5, $6, $7::jsonb)
            ON CONFLICT DO NOTHING
            """,
            report_id,
            user_id,
            (now - timedelta(days=7)).strftime("%Y-%m-%d"),
            now.strftime("%Y-%m-%d"),
            ["weekly_summary"],
            summary_text,
            json.dumps(insights),
        )
