"""Muscle frequency optimization — compare actual vs evidence-based frequency.

Training frequency is a key driver of hypertrophy and strength outcomes.
Schoenfeld et al. (2016) meta-analysis found that training each muscle
group 2x/week produced greater hypertrophy than 1x/week.

NSCA guidelines recommend:
  - Hypertrophy: 2-3x/week per muscle group
  - Strength: 2-4x/week for primary lifts
  - General: 2x/week minimum per major muscle group

This service compares the user's actual per-muscle training frequency
against these evidence-based targets and identifies undertrained and
overtrained muscle groups.
"""

from datetime import UTC, date, datetime, timedelta

import asyncpg

from app.models.schemas import (
    MuscleFrequencyEntry,
    MuscleFrequencyResponse,
)

# Evidence-based frequency targets (sessions per week).
# Based on Schoenfeld (2016), NSCA, and Renaissance Periodization.
# Format: {muscle: (min_optimal, max_optimal)}
_FREQUENCY_TARGETS: dict[str, tuple[float, float]] = {
    "Chest": (1.5, 3.0),
    "Lats": (1.5, 3.0),
    "Shoulders": (2.0, 3.5),  # Recover faster, tolerate higher frequency
    "Quadriceps": (1.5, 3.0),
    "Hamstrings": (1.5, 3.0),
    "Glutes": (2.0, 3.5),
    "Biceps": (2.0, 4.0),  # Small muscles recover fast
    "Triceps": (2.0, 4.0),
    "Trapezius": (1.5, 3.0),
    "Calves": (2.0, 4.0),
    "Abdominals": (2.0, 4.0),
    "Forearms": (2.0, 4.0),
    "Lower Back": (1.5, 2.5),  # Lower tolerance, needs more recovery
    "Obliques": (2.0, 3.5),
}

_DEFAULT_TARGET = (2.0, 3.0)


def _frequency_status(actual: float, min_opt: float, max_opt: float) -> str:
    """Classify training frequency relative to optimal range."""
    if actual < min_opt * 0.5:
        return "severely_undertrained"
    if actual < min_opt:
        return "undertrained"
    if actual <= max_opt:
        return "optimal"
    if actual <= max_opt * 1.3:
        return "high_frequency"
    return "overfrequency"


async def compute_muscle_frequency(
    user_id: str,
    db_pool: asyncpg.Pool,
    weeks: int = 4,
) -> MuscleFrequencyResponse:
    """Analyze per-muscle training frequency vs evidence-based targets.

    Uses distinct training dates per muscle group over the period,
    divided by weeks, to compute actual weekly frequency.
    """
    since = datetime.now(UTC) - timedelta(weeks=weeks)

    async with db_pool.acquire() as conn:
        rows = await conn.fetch(
            """
            SELECT
                mg.name                 AS muscle_group,
                em.is_primary,
                DATE(s.logged_at)       AS training_date
            FROM sets s
            JOIN exercise_muscles em ON em.exercise_id = s.exercise_id
            JOIN muscle_groups mg    ON mg.id = em.muscle_group_id
            WHERE s.user_id = $1
              AND s.logged_at >= $2
            """,
            user_id,
            since,
        )

    if not rows:
        return MuscleFrequencyResponse(
            muscles=[],
            undertrained_count=0,
            overtrained_count=0,
            optimal_count=0,
            overall_status="insufficient_data",
            period_weeks=weeks,
        )

    # Count distinct training dates per muscle (primary hits = full session,
    # secondary = still counts as stimulus)
    muscle_dates: dict[str, set[date]] = {}
    for row in rows:
        name = row["muscle_group"]
        if name not in muscle_dates:
            muscle_dates[name] = set()
        muscle_dates[name].add(row["training_date"])

    entries: list[MuscleFrequencyEntry] = []
    under = 0
    over = 0
    optimal = 0

    for name, dates in sorted(muscle_dates.items(), key=lambda x: -len(x[1])):
        actual_freq = round(len(dates) / weeks, 1)
        min_opt, max_opt = _FREQUENCY_TARGETS.get(name, _DEFAULT_TARGET)
        status = _frequency_status(actual_freq, min_opt, max_opt)

        if status in ("severely_undertrained", "undertrained"):
            recommendation = f"Increase to {min_opt:.0f}-{max_opt:.0f}x/week"
            under += 1
        elif status == "optimal":
            recommendation = "On target"
            optimal += 1
        elif status == "high_frequency":
            recommendation = "Monitor recovery — frequency is above typical range"
            over += 1
        else:
            recommendation = f"Consider reducing to {max_opt:.0f}x/week max"
            over += 1

        entries.append(
            MuscleFrequencyEntry(
                muscle_group=name,
                actual_frequency=actual_freq,
                min_optimal=min_opt,
                max_optimal=max_opt,
                status=status,
                recommendation=recommendation,
                sessions_in_period=len(dates),
            )
        )

    if under > optimal and under > over:
        overall = "undertrained"
    elif over > optimal:
        overall = "overfrequency"
    elif optimal >= under + over:
        overall = "well_optimized"
    else:
        overall = "mixed"

    return MuscleFrequencyResponse(
        muscles=entries,
        undertrained_count=under,
        overtrained_count=over,
        optimal_count=optimal,
        overall_status=overall,
        period_weeks=weeks,
    )
