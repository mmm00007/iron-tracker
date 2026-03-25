"""Composite Training Score — single 0-100 number grading overall training quality.

Aggregates signals from multiple analytics services into one actionable score,
similar to a credit score for training. Helps users quickly assess whether
their overall training program is on track.

Dimensions (weighted):
  Consistency (20%) — Are you showing up regularly?
  Progressive Overload (20%) — Are you getting stronger?
  Volume Adequacy (15%) — Are you doing enough work per muscle?
  Recovery Management (15%) — Are you recovering between sessions?
  Training Balance (15%) — Is your program well-rounded?
  Session Quality (15%) — Is your effort level appropriate?

Each dimension scores 0-100, then the weighted average produces the composite.
Cold-start: dimensions with insufficient data are excluded from the average
(their weight is redistributed proportionally to available dimensions).
"""

from datetime import UTC, datetime, timedelta

import asyncpg

from app.models.schemas import (
    CompositeScoreResponse,
    ScoreDimension,
)

# Dimension weights (must sum to 1.0)
_WEIGHTS = {
    "consistency": 0.20,
    "progressive_overload": 0.20,
    "volume_adequacy": 0.15,
    "recovery": 0.15,
    "balance": 0.15,
    "session_quality": 0.15,
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
              AND set_type IN ('working', 'top')
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
        dimensions.append(ScoreDimension(
            name="consistency",
            score=consistency_score,
            label=_label(consistency_score),
            weight=_WEIGHTS["consistency"],
            detail=f"{days_per_week:.1f} training days/week",
        ))

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
            dimensions.append(ScoreDimension(
                name="progressive_overload",
                score=overload_score,
                label=_label(overload_score),
                weight=_WEIGHTS["progressive_overload"],
                detail=f"{progressing}/{total} exercises progressing",
            ))

    # ── Volume Adequacy (0-100) ─────────────────────────────────────────
    if muscle_rows:
        muscle_sets: dict[str, float] = {}
        for row in muscle_rows:
            name = row["muscle_group"]
            factor = 1.0 if row["is_primary"] else 0.5
            muscle_sets[name] = muscle_sets.get(name, 0) + int(row["set_count"]) * factor

        # Score: % of muscles hitting MEV (8+ sets/week)
        weekly_sets = {m: s / weeks for m, s in muscle_sets.items()}
        above_mev = sum(1 for s in weekly_sets.values() if s >= 8)
        volume_score = round(above_mev / max(len(weekly_sets), 1) * 100)
        dimensions.append(ScoreDimension(
            name="volume_adequacy",
            score=volume_score,
            label=_label(volume_score),
            weight=_WEIGHTS["volume_adequacy"],
            detail=f"{above_mev}/{len(weekly_sets)} muscles above MEV",
        ))

    # ── Recovery (0-100) ─────────────────────────────────────────────────
    if recovery_rows:
        recovery_hours = {
            "Quadriceps": 72, "Hamstrings": 72, "Glutes": 72, "Lats": 72,
            "Chest": 56, "Shoulders": 56, "Biceps": 48, "Triceps": 48,
        }
        adequate = 0
        total_muscles = 0
        for row in recovery_rows:
            name = row["muscle_group"]
            hours_since = (now - row["last_trained"]).total_seconds() / 3600
            expected = recovery_hours.get(name, 56)
            total_muscles += 1
            if hours_since >= expected * 0.7:  # 70% of expected = adequate
                adequate += 1

        recovery_score = round(adequate / max(total_muscles, 1) * 100)
        dimensions.append(ScoreDimension(
            name="recovery",
            score=recovery_score,
            label=_label(recovery_score),
            weight=_WEIGHTS["recovery"],
            detail=f"{adequate}/{total_muscles} muscles adequately recovered",
        ))

    # ── Balance (0-100) ──────────────────────────────────────────────────
    if muscle_rows and len(set(r["muscle_group"] for r in muscle_rows)) >= 3:
        import math
        volumes = list(muscle_sets.values())
        total_vol = sum(volumes)
        if total_vol > 0:
            proportions = [v / total_vol for v in volumes]
            entropy = -sum(p * math.log(p) for p in proportions if p > 0)
            max_entropy = math.log(len(volumes))
            balance_ratio = entropy / max_entropy if max_entropy > 0 else 0
            balance_score = round(balance_ratio * 100)
            dimensions.append(ScoreDimension(
                name="balance",
                score=balance_score,
                label=_label(balance_score),
                weight=_WEIGHTS["balance"],
                detail=f"Balance index: {balance_ratio:.2f}",
            ))

    # ── Session Quality (0-100) ──────────────────────────────────────────
    if quality_rows:
        rpe_values = [float(r["rpe"]) for r in quality_rows if r["rpe"] is not None]
        if rpe_values:
            avg_rpe = sum(rpe_values) / len(rpe_values)
            # Ideal working RPE: 7-8.5. Score drops below 6 and above 9.
            if 7 <= avg_rpe <= 8.5:
                quality_score = 100
            elif 6 <= avg_rpe < 7:
                quality_score = round(60 + (avg_rpe - 6) * 40)
            elif 8.5 < avg_rpe <= 9.5:
                quality_score = round(100 - (avg_rpe - 8.5) * 40)
            else:
                quality_score = max(20, round(60 - abs(avg_rpe - 7.5) * 20))

            dimensions.append(ScoreDimension(
                name="session_quality",
                score=quality_score,
                label=_label(quality_score),
                weight=_WEIGHTS["session_quality"],
                detail=f"Avg working RPE: {avg_rpe:.1f}",
            ))

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
