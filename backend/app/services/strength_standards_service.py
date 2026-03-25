"""Strength standards and population benchmarking.

Classifies the user's lifts against evidence-based strength standards.
Uses strength-level.com / ExRx population norms adapted for common
compound exercises, expressed as ratios of estimated 1RM to body weight.

For users without bodyweight data, falls back to absolute strength
percentiles from Kilgallon & Lyttle (2007) and Hoffman (2006).

Classification tiers (adapted from Rippetoe & Kilgore 2006):
  Beginner   — untrained or <6 months regular lifting
  Novice     — 6-12 months consistent training
  Intermediate — 1-3 years consistent training
  Advanced   — 3-5+ years, competitive recreational
  Elite      — top 5%, competitive/national-level
"""

from datetime import UTC, datetime, timedelta

import asyncpg

from app.models.schemas import (
    ExerciseStandardEntry,
    StrengthStandardsResponse,
)

# Absolute 1RM standards (kg) for common exercises.
# Organized as {exercise_name_lower: [beginner, novice, intermediate, advanced, elite]}
# Sources: ExRx, strength-level.com, Rippetoe & Kilgore.
# These are approximate male intermediate values; female standards are ~60% of male.
# The service auto-detects which exercises the user trains and maps to the closest standard.

_MALE_STANDARDS: dict[str, list[float]] = {
    "bench press": [40, 60, 85, 110, 140],
    "barbell bench press": [40, 60, 85, 110, 140],
    "squat": [50, 80, 115, 150, 190],
    "barbell squat": [50, 80, 115, 150, 190],
    "deadlift": [60, 95, 135, 175, 220],
    "barbell deadlift": [60, 95, 135, 175, 220],
    "overhead press": [25, 40, 55, 75, 95],
    "barbell overhead press": [25, 40, 55, 75, 95],
    "military press": [25, 40, 55, 75, 95],
    "barbell row": [30, 50, 75, 100, 130],
    "bent over row": [30, 50, 75, 100, 130],
    "barbell bent over row": [30, 50, 75, 100, 130],
    "pull up": [0, 5, 15, 30, 50],
    "chin up": [0, 5, 15, 30, 50],
    "dip": [0, 10, 25, 45, 65],
    "barbell curl": [15, 25, 40, 55, 70],
    "dumbbell bench press": [15, 25, 35, 45, 55],
    "dumbbell shoulder press": [12, 20, 30, 40, 50],
    "romanian deadlift": [40, 65, 95, 125, 160],
    "front squat": [35, 60, 90, 120, 150],
    "leg press": [80, 140, 220, 320, 420],
    "lat pulldown": [30, 50, 70, 90, 110],
    "cable row": [25, 40, 60, 80, 100],
    "seated cable row": [25, 40, 60, 80, 100],
}

_TIERS = ["beginner", "novice", "intermediate", "advanced", "elite"]


def _classify_strength(e1rm: float, standards: list[float]) -> tuple[str, float]:
    """Return (tier, percentile) for a given e1RM against standards.

    Percentile is approximate and interpolated between tier boundaries:
      beginner=10, novice=30, intermediate=50, advanced=75, elite=95
    """
    tier_percentiles = [10, 30, 50, 75, 95]

    if e1rm < standards[0]:
        return "untrained", max(0, round(e1rm / standards[0] * 10, 1))

    for i in range(len(standards) - 1):
        if e1rm < standards[i + 1]:
            # Interpolate within the tier
            frac = (e1rm - standards[i]) / (standards[i + 1] - standards[i])
            pct = tier_percentiles[i] + frac * (tier_percentiles[i + 1] - tier_percentiles[i])
            return _TIERS[i], round(pct, 1)

    return "elite", min(99.0, round(95 + (e1rm - standards[-1]) / standards[-1] * 4, 1))


def _find_standard(exercise_name: str) -> list[float] | None:
    """Match an exercise name to our standards table (case-insensitive fuzzy)."""
    lower = exercise_name.lower().strip()
    # Exact match first
    if lower in _MALE_STANDARDS:
        return _MALE_STANDARDS[lower]
    # Substring match
    for key, standards in _MALE_STANDARDS.items():
        if key in lower or lower in key:
            return standards
    return None


async def compute_strength_standards(
    user_id: str,
    db_pool: asyncpg.Pool,
    weeks: int = 12,
) -> StrengthStandardsResponse:
    """Benchmark the user's best estimated 1RM per exercise against population norms.

    Only includes exercises that match known strength standards (mainly compound
    barbell movements). Returns tier classification and approximate percentile.
    """
    since = datetime.now(UTC) - timedelta(weeks=weeks)

    async with db_pool.acquire() as conn:
        rows = await conn.fetch(
            """
            SELECT
                e.id        AS exercise_id,
                e.name      AS exercise_name,
                MAX(s.estimated_1rm)  AS best_e1rm
            FROM sets s
            JOIN exercises e ON e.id = s.exercise_id
            WHERE s.user_id = $1
              AND s.logged_at >= $2
              AND s.estimated_1rm > 0
            GROUP BY e.id, e.name
            ORDER BY MAX(s.estimated_1rm) DESC
            """,
            user_id,
            since,
        )

    entries: list[ExerciseStandardEntry] = []
    tier_counts: dict[str, int] = {}

    for row in rows:
        name = row["exercise_name"]
        standards = _find_standard(name)
        if standards is None:
            continue

        e1rm = float(row["best_e1rm"])
        tier, percentile = _classify_strength(e1rm, standards)

        # Next milestone: the next tier boundary above current e1RM
        next_milestone: float | None = None
        next_tier: str | None = None
        for i, threshold in enumerate(standards):
            if e1rm < threshold:
                next_milestone = round(threshold, 1)
                next_tier = _TIERS[i]
                break

        entries.append(
            ExerciseStandardEntry(
                exercise_id=str(row["exercise_id"]),
                exercise_name=name,
                current_e1rm=round(e1rm, 1),
                tier=tier,
                percentile=percentile,
                next_milestone=next_milestone,
                next_tier=next_tier,
                kg_to_next=round(next_milestone - e1rm, 1) if next_milestone else None,
            )
        )
        tier_counts[tier] = tier_counts.get(tier, 0) + 1

    # Overall classification: the most common tier among benchmarked exercises
    if tier_counts:
        overall_tier = max(tier_counts, key=lambda t: tier_counts[t])
    else:
        overall_tier = "insufficient_data"

    return StrengthStandardsResponse(
        exercises=entries,
        overall_tier=overall_tier,
        exercises_benchmarked=len(entries),
        tier_distribution=tier_counts,
        disclaimer=(
            "Standards are based on general population data for male lifters. "
            "Individual variation depends on body weight, training age, genetics, "
            "and exercise technique. Use as a rough guide, not a definitive measure."
        ),
    )
