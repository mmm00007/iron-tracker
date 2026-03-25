"""Recovery and readiness scoring based on training recency, volume, and soreness."""

from datetime import UTC, datetime, timedelta

import asyncpg

from app.models.schemas import MuscleRecoveryEntry, RecoveryResponse

# ─── Expected recovery hours by muscle group ─────────────────────────────────
# Larger muscles generally require more recovery time.
# Based on NSCA guidelines and practical coaching recommendations.
# These are population-level defaults; individual variation exists.

RECOVERY_HOURS: dict[str, float] = {
    "Quadriceps": 72,
    "Hamstrings": 72,
    "Glutes": 72,
    "Lats": 72,
    "Lower Back": 72,
    "Chest": 56,
    "Shoulders": 56,
    "Trapezius": 56,
    "Abdominals": 48,
    "Obliques": 48,
    "Biceps": 48,
    "Triceps": 48,
    "Calves": 48,
    "Forearms": 48,
}

DEFAULT_RECOVERY_HOURS = 56.0

DISCLAIMER = (
    "Recovery scores are estimates based on training data and general "
    "exercise science guidelines. They do not constitute medical advice. "
    "Listen to your body and consult a healthcare professional if you "
    "experience pain beyond normal muscle soreness."
)


def _recovery_status(hours_since: float, expected_hours: float, soreness: int | None) -> str:
    """Classify muscle recovery status.

    Four tiers per sports medicine expert review:
    - fresh: fully recovered, ready for high-intensity work
    - recovered: adequate recovery for moderate training
    - fatigued: insufficient recovery or elevated soreness
    - at_risk: high soreness or very recent heavy training (warn user)
    """
    ratio = hours_since / expected_hours if expected_hours > 0 else 1.0
    severe_soreness = soreness is not None and soreness >= 4
    high_soreness = soreness is not None and soreness >= 3

    if severe_soreness:
        return "at_risk"
    if high_soreness:
        return "fatigued"
    if ratio >= 1.3:
        return "fresh"
    if ratio >= 0.8:
        return "recovered"
    return "fatigued"


def _readiness_score(muscles: list[MuscleRecoveryEntry]) -> int:
    """Compute overall readiness score (0-100)."""
    if not muscles:
        return 100  # No data = assume fresh

    status_scores = {"fresh": 100, "recovered": 70, "fatigued": 30, "at_risk": 10}
    total = sum(status_scores.get(m.recovery_status, 50) for m in muscles)
    return min(100, max(0, round(total / len(muscles))))


def _readiness_label(score: int) -> str:
    if score >= 80:
        return "ready"
    if score >= 60:
        return "moderate"
    if score >= 40:
        return "fatigued"
    return "overtrained"


async def compute_recovery(
    user_id: str,
    db_pool: asyncpg.Pool,
) -> RecoveryResponse:
    """Compute per-muscle recovery status and overall readiness.

    Factors:
    - Hours since last training for each muscle group
    - Number of sets in last session targeting that muscle
    - Most recent soreness report for each muscle group
    """
    now = datetime.now(UTC)
    lookback = now - timedelta(days=14)

    async with db_pool.acquire() as conn:
        # Latest training date and set count per muscle group
        training_rows = await conn.fetch(
            """
            SELECT
                mg.name                     AS muscle_group,
                MAX(s.logged_at)            AS last_trained,
                COUNT(*)                    AS set_count
            FROM sets s
            JOIN exercise_muscles em ON em.exercise_id = s.exercise_id
            JOIN muscle_groups mg    ON mg.id = em.muscle_group_id
            WHERE s.user_id = $1
              AND s.logged_at >= $2
            GROUP BY mg.name
            """,
            user_id,
            lookback,
        )

        # Latest soreness report per muscle group
        soreness_rows = await conn.fetch(
            """
            SELECT DISTINCT ON (mg.name)
                mg.name     AS muscle_group,
                sr.severity
            FROM soreness_reports sr
            JOIN muscle_groups mg ON mg.id = sr.muscle_group_id
            WHERE sr.user_id = $1
              AND sr.reported_at >= $2
            ORDER BY mg.name, sr.reported_at DESC
            """,
            user_id,
            lookback,
        )

    soreness_map = {row["muscle_group"]: int(row["severity"]) for row in soreness_rows}

    entries: list[MuscleRecoveryEntry] = []
    for row in training_rows:
        name = row["muscle_group"]
        last_trained = row["last_trained"]
        hours_since = (now - last_trained).total_seconds() / 3600
        expected = RECOVERY_HOURS.get(name, DEFAULT_RECOVERY_HOURS)
        soreness = soreness_map.get(name)

        entries.append(
            MuscleRecoveryEntry(
                muscle_group=name,
                hours_since_trained=round(hours_since, 1),
                recovery_status=_recovery_status(hours_since, expected, soreness),
                last_soreness=soreness,
                sets_last_session=int(row["set_count"]),
            )
        )

    # Sort: at_risk first, then fatigued, then recovered, then fresh
    status_order = {"at_risk": 0, "fatigued": 1, "recovered": 2, "fresh": 3}
    entries.sort(key=lambda e: status_order.get(e.recovery_status, 4))

    score = _readiness_score(entries)

    return RecoveryResponse(
        readiness_score=score,
        readiness_label=_readiness_label(score),
        muscles=entries,
        disclaimer=DISCLAIMER,
    )
