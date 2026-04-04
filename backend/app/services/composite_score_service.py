"""Composite Training Score — single 0-100 number grading overall training quality.

Aggregates signals from multiple analytics services into one actionable score,
similar to a credit score for training. Helps users quickly assess whether
their overall training program is on track.

Dimensions (weighted):
  Consistency (15%) — Are you showing up regularly?
  Progressive Overload (15%) — Are you getting stronger?
  Volume Adequacy (12%) — Are you doing enough work per muscle?
  Recovery Management (12%) — Are you recovering between sessions?
  Training Balance (10%) — Is your program well-rounded?
  Session Quality (10%) — Is your effort level appropriate?
  Nutrition Compliance (10%) — Are you hitting protein targets?
  Training Readiness (8%) — Are you well-rested before sessions?
  Plan Adherence (8%) — Are you following the prescribed program?

Each dimension scores 0-100, then the weighted average produces the composite.
Cold-start: dimensions with insufficient data are excluded from the average
(their weight is redistributed proportionally to available dimensions).
"""

import math
from datetime import UTC, datetime, timedelta

import asyncpg

from app.models.schemas import (
    CompositeScoreResponse,
    ScoreDimension,
)
from app.services.recovery_service import RECOVERY_HOURS
from app.services.volume_landmarks_service import DEFAULT_LANDMARKS, VOLUME_LANDMARKS

# Dimension weights (must sum to 1.0)
_WEIGHTS = {
    "consistency": 0.15,
    "progressive_overload": 0.15,
    "volume_adequacy": 0.12,
    "recovery": 0.12,
    "balance": 0.10,
    "session_quality": 0.10,
    "nutrition_compliance": 0.10,
    "training_readiness": 0.08,
    "plan_adherence": 0.08,
}


def _label(score: float) -> str:
    if score >= 85:
        return "excellent"
    if score >= 70:
        return "good"
    if score >= 50:
        return "moderate"
    if score >= 30:
        return "needs_work"
    return "poor"


async def compute_composite_score(
    user_id: str,
    db_pool: asyncpg.Pool,
    period_days: int = 28,
) -> CompositeScoreResponse:
    """Compute the composite training score from multiple signals.

    Queries raw data once and computes lightweight scores for each dimension,
    avoiding the overhead of calling the full individual analytics services.
    """
    since = datetime.now(UTC) - timedelta(days=period_days)
    now = datetime.now(UTC)

    async with db_pool.acquire() as conn:
        # 1. Training days for consistency
        day_rows = await conn.fetch(
            """
            SELECT DISTINCT DATE(logged_at) AS day
            FROM sets
            WHERE user_id = $1 AND logged_at >= $2
            """,
            user_id,
            since,
        )

        # 2. Progressive overload: best daily e1RM per exercise
        overload_rows = await conn.fetch(
            """
            SELECT
                s.exercise_id,
                DATE(s.logged_at) AS day,
                MAX(s.estimated_1rm) AS best_e1rm
            FROM sets s
            WHERE s.user_id = $1
              AND s.logged_at >= $2
              AND s.estimated_1rm > 0
            GROUP BY s.exercise_id, DATE(s.logged_at)
            ORDER BY s.exercise_id, DATE(s.logged_at)
            """,
            user_id,
            since,
        )

        # 3. Muscle volume for balance + volume adequacy
        muscle_rows = await conn.fetch(
            """
            SELECT
                mg.name AS muscle_group,
                em.is_primary,
                COUNT(*) AS set_count
            FROM sets s
            JOIN exercise_muscles em ON em.exercise_id = s.exercise_id
            JOIN muscle_groups mg ON mg.id = em.muscle_group_id
            WHERE s.user_id = $1
              AND s.logged_at >= $2
            GROUP BY mg.name, em.is_primary
            """,
            user_id,
            since,
        )

        # 4. Recovery: hours since last training per muscle
        recovery_rows = await conn.fetch(
            """
            SELECT
                mg.name AS muscle_group,
                MAX(s.logged_at) AS last_trained
            FROM sets s
            JOIN exercise_muscles em ON em.exercise_id = s.exercise_id
            JOIN muscle_groups mg ON mg.id = em.muscle_group_id
            WHERE s.user_id = $1
              AND s.logged_at >= $2
            GROUP BY mg.name
            """,
            user_id,
            since,
        )

        # 5. Session quality: RPE data
        quality_rows = await conn.fetch(
            """
            SELECT rpe, set_type
            FROM sets
            WHERE user_id = $1
              AND logged_at >= $2
              AND set_type IN ('working', 'amrap', 'failure')
            """,
            user_id,
            since,
        )

        # 6. Nutrition compliance: protein adequacy
        bw_row = await conn.fetchrow(
            "SELECT current_body_weight_kg FROM profiles WHERE id = $1",
            user_id,
        )
        bw_kg = (
            float(bw_row["current_body_weight_kg"])
            if bw_row and bw_row["current_body_weight_kg"]
            else None
        )

        nutrition_row = (
            await conn.fetchrow(
                """
            SELECT COUNT(*) FILTER (
                WHERE protein_g / NULLIF($3::numeric, 0) >= 1.6
            ) AS adequate_days, COUNT(*) AS total_days
            FROM nutrition_logs
            WHERE user_id = $1 AND logged_date >= $2
            """,
                user_id,
                since,
                bw_kg,
            )
            if bw_kg
            else None
        )

        # 7. Training readiness: sleep quality from latest workout feedback
        readiness_row = await conn.fetchrow(
            """
            SELECT prior_sleep_quality, sleep_hours
            FROM workout_feedback
            WHERE user_id = $1
            ORDER BY training_date DESC
            LIMIT 1
            """,
            user_id,
        )

        # 8. Plan adherence: average adherence ratio
        adherence_row = await conn.fetchrow(
            """
            SELECT AVG(adherence_ratio)::float AS avg_adherence,
                   COUNT(*) AS total_records
            FROM plan_adherence_log
            WHERE user_id = $1 AND training_date >= $2
            """,
            user_id,
            since,
        )

    dimensions: list[ScoreDimension] = []
    training_days = {row["day"] for row in day_rows}

    # ── Consistency (0-100) ─────────────────────────────────────────────
    weeks = max(period_days / 7, 1)
    days_per_week = len(training_days) / weeks
    # Ideal: 3-5 days/week. Score peaks at 4 days/week.
    if days_per_week >= 3:
        consistency_score = min(100, round(days_per_week / 4 * 100))
    elif days_per_week >= 1:
        consistency_score = round(days_per_week / 3 * 70)
    else:
        consistency_score = 0
    consistency_score = min(100, consistency_score)

    if len(training_days) >= 2:
        dimensions.append(
            ScoreDimension(
                name="consistency",
                score=consistency_score,
                label=_label(consistency_score),
                weight=_WEIGHTS["consistency"],
                detail=f"{days_per_week:.1f} training days/week",
            )
        )

    # ── Progressive Overload (0-100) ────────────────────────────────────
    if overload_rows:
        # Group by exercise, check if latest e1RM > earliest
        exercise_progress: dict[str, dict] = {}
        for row in overload_rows:
            eid = str(row["exercise_id"])
            if eid not in exercise_progress:
                exercise_progress[eid] = {"first": float(row["best_e1rm"]), "last": 0.0, "days": 0}
            exercise_progress[eid]["last"] = float(row["best_e1rm"])
            exercise_progress[eid]["days"] += 1

        progressing = 0
        total = 0
        for data in exercise_progress.values():
            if data["days"] >= 3:
                total += 1
                if data["last"] > data["first"]:
                    progressing += 1

        if total > 0:
            overload_score = round(progressing / total * 100)
            dimensions.append(
                ScoreDimension(
                    name="progressive_overload",
                    score=overload_score,
                    label=_label(overload_score),
                    weight=_WEIGHTS["progressive_overload"],
                    detail=f"{progressing}/{total} exercises progressing",
                )
            )

    # ── Volume Adequacy (0-100) ─────────────────────────────────────────
    if muscle_rows:
        muscle_sets: dict[str, float] = {}
        for row in muscle_rows:
            name = row["muscle_group"]
            factor = 1.0 if row["is_primary"] else 0.5
            muscle_sets[name] = muscle_sets.get(name, 0) + int(row["set_count"]) * factor

        # Score: % of muscles hitting their per-muscle MEV threshold
        weekly_sets = {m: s / weeks for m, s in muscle_sets.items()}
        above_mev = sum(
            1 for m, s in weekly_sets.items()
            if s >= VOLUME_LANDMARKS.get(m, DEFAULT_LANDMARKS)["MEV"]
        )
        volume_score = round(above_mev / max(len(weekly_sets), 1) * 100)
        dimensions.append(
            ScoreDimension(
                name="volume_adequacy",
                score=volume_score,
                label=_label(volume_score),
                weight=_WEIGHTS["volume_adequacy"],
                detail=f"{above_mev}/{len(weekly_sets)} muscles above MEV",
            )
        )

    # ── Recovery (0-100) ─────────────────────────────────────────────────
    if recovery_rows:
        # Use canonical recovery hours from recovery_service (lowercase keys matching DB)
        adequate = 0
        total_muscles = 0
        for row in recovery_rows:
            name = row["muscle_group"]
            hours_since = (now - row["last_trained"]).total_seconds() / 3600
            expected = RECOVERY_HOURS.get(name, 56)
            total_muscles += 1
            if hours_since >= expected * 0.7:  # 70% of expected = adequate
                adequate += 1

        recovery_score = round(adequate / max(total_muscles, 1) * 100)
        dimensions.append(
            ScoreDimension(
                name="recovery",
                score=recovery_score,
                label=_label(recovery_score),
                weight=_WEIGHTS["recovery"],
                detail=f"{adequate}/{total_muscles} muscles adequately recovered",
            )
        )

    # ── Balance (0-100) ──────────────────────────────────────────────────
    if muscle_rows and len(set(r["muscle_group"] for r in muscle_rows)) >= 3:
        volumes = list(muscle_sets.values())
        total_vol = sum(volumes)
        if total_vol > 0:
            proportions = [v / total_vol for v in volumes]
            entropy = -sum(p * math.log(p) for p in proportions if p > 0)
            max_entropy = math.log(len(volumes))
            balance_ratio = entropy / max_entropy if max_entropy > 0 else 0
            balance_score = round(balance_ratio * 100)
            dimensions.append(
                ScoreDimension(
                    name="balance",
                    score=balance_score,
                    label=_label(balance_score),
                    weight=_WEIGHTS["balance"],
                    detail=f"Balance index: {balance_ratio:.2f}",
                )
            )

    # ── Session Quality (0-100) ──────────────────────────────────────────
    if quality_rows:
        rpe_values = [float(r["rpe"]) for r in quality_rows if r["rpe"] is not None]
        if rpe_values:
            avg_rpe = sum(rpe_values) / len(rpe_values)
            # Ideal working RPE: 7-8.5 per Helms et al. (2016) RPE-RIR scale
            if 7 <= avg_rpe <= 8.5:
                quality_score = 100
            elif 6 <= avg_rpe < 7:
                quality_score = round(60 + (avg_rpe - 6) * 40)
            elif 8.5 < avg_rpe <= 9.5:
                quality_score = round(100 - (avg_rpe - 8.5) * 40)
            else:
                quality_score = max(20, round(60 - abs(avg_rpe - 7.5) * 20))

            dimensions.append(
                ScoreDimension(
                    name="session_quality",
                    score=quality_score,
                    label=_label(quality_score),
                    weight=_WEIGHTS["session_quality"],
                    detail=f"Avg working RPE: {avg_rpe:.1f}",
                )
            )

    # ── Nutrition Compliance (0-100) ───────────────────────────────────
    if nutrition_row and int(nutrition_row["total_days"]) >= 7:
        adequate = int(nutrition_row["adequate_days"])
        total = int(nutrition_row["total_days"])
        nutrition_score = round(adequate / total * 100)
        dimensions.append(
            ScoreDimension(
                name="nutrition_compliance",
                score=nutrition_score,
                label=_label(nutrition_score),
                weight=_WEIGHTS["nutrition_compliance"],
                detail=f"{adequate}/{total} days protein >= 1.6g/kg",
            )
        )

    # ── Training Readiness (0-100) ─────────────────────────────────────
    if readiness_row and readiness_row["prior_sleep_quality"] is not None:
        quality = float(readiness_row["prior_sleep_quality"])
        hours = float(readiness_row["sleep_hours"]) if readiness_row["sleep_hours"] else 0.0
        readiness_score = round((quality / 5 * 0.5 + min(hours, 9) / 9 * 0.5) * 100)
        readiness_score = min(100, max(0, readiness_score))
        dimensions.append(
            ScoreDimension(
                name="training_readiness",
                score=readiness_score,
                label=_label(readiness_score),
                weight=_WEIGHTS["training_readiness"],
                detail=f"Sleep: {hours:.1f}h, quality {quality:.0f}/5",
            )
        )

    # ── Plan Adherence (0-100) ─────────────────────────────────────────
    has_adherence = (
        adherence_row
        and adherence_row["avg_adherence"] is not None
        and int(adherence_row["total_records"]) >= 5
    )
    if has_adherence:
        avg_adherence = float(adherence_row["avg_adherence"])
        adherence_score = round(avg_adherence * 100)
        adherence_score = min(100, max(0, adherence_score))
        dimensions.append(
            ScoreDimension(
                name="plan_adherence",
                score=adherence_score,
                label=_label(adherence_score),
                weight=_WEIGHTS["plan_adherence"],
                detail=f"Avg adherence: {avg_adherence:.0%}",
            )
        )

    # ── Compute Weighted Composite ──────────────────────────────────────
    if not dimensions:
        return CompositeScoreResponse(
            score=0,
            label="insufficient_data",
            dimensions=[],
            available_dimensions=0,
            period_days=period_days,
        )

    # Redistribute weights proportionally for available dimensions
    total_weight = sum(d.weight for d in dimensions)
    composite = sum(d.score * d.weight / total_weight for d in dimensions)
    composite = round(min(100, max(0, composite)))

    return CompositeScoreResponse(
        score=composite,
        label=_label(composite),
        dimensions=dimensions,
        available_dimensions=len(dimensions),
        period_days=period_days,
    )
