"""Strength standards and population benchmarking.

Classifies the user's lifts against evidence-based strength standards.
Supports both male and female norms, and bodyweight-relative classification
when user bodyweight is available in the profiles table.

Sources:
  - NSCA Essentials of Strength Training (4th ed.) Table 18.7
  - ExRx.net strength standards
  - Rippetoe & Kilgore, Practical Programming (2006)
  - Hoffman, Norms for Fitness (2006) — female norms

Classification tiers:
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

# Absolute 1RM standards (kg): [beginner, novice, intermediate, advanced, elite]
# Calibrated for ~80kg male / ~60kg female.

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

# Female standards (NSCA Table 18.7, Hoffman 2006, ExRx female norms).
# These are NOT a blanket 60% of male — ratios vary by lift:
#   Upper body: ~55-60% of male
#   Lower body: ~65-75% of male
# Calibrated for ~60kg female.
_FEMALE_STANDARDS: dict[str, list[float]] = {
    "bench press": [20, 30, 45, 60, 80],
    "barbell bench press": [20, 30, 45, 60, 80],
    "squat": [30, 50, 75, 100, 130],
    "barbell squat": [30, 50, 75, 100, 130],
    "deadlift": [40, 65, 95, 125, 160],
    "barbell deadlift": [40, 65, 95, 125, 160],
    "overhead press": [12, 20, 30, 42, 55],
    "barbell overhead press": [12, 20, 30, 42, 55],
    "military press": [12, 20, 30, 42, 55],
    "barbell row": [18, 30, 45, 65, 85],
    "bent over row": [18, 30, 45, 65, 85],
    "barbell bent over row": [18, 30, 45, 65, 85],
    "pull up": [0, 0, 5, 15, 30],
    "chin up": [0, 0, 5, 15, 30],
    "dip": [0, 0, 10, 25, 40],
    "barbell curl": [8, 14, 22, 32, 42],
    "dumbbell bench press": [8, 14, 20, 28, 36],
    "dumbbell shoulder press": [6, 10, 16, 24, 32],
    "romanian deadlift": [25, 42, 65, 90, 115],
    "front squat": [22, 38, 60, 82, 105],
    "leg press": [55, 100, 160, 230, 310],
    "lat pulldown": [18, 30, 45, 62, 78],
    "cable row": [15, 25, 38, 52, 68],
    "seated cable row": [15, 25, 38, 52, 68],
}

# Bodyweight-relative multipliers for key lifts (BW ratio standards).
# Format: {exercise: [beginner, novice, intermediate, advanced, elite]}
# Used when user bodyweight is available. More accurate than absolute values.
_MALE_BW_RATIOS: dict[str, list[float]] = {
    "bench press": [0.50, 0.75, 1.0, 1.35, 1.75],
    "barbell bench press": [0.50, 0.75, 1.0, 1.35, 1.75],
    "squat": [0.65, 1.0, 1.45, 1.85, 2.35],
    "barbell squat": [0.65, 1.0, 1.45, 1.85, 2.35],
    "deadlift": [0.75, 1.2, 1.7, 2.2, 2.75],
    "barbell deadlift": [0.75, 1.2, 1.7, 2.2, 2.75],
    "overhead press": [0.30, 0.50, 0.70, 0.95, 1.20],
    "barbell overhead press": [0.30, 0.50, 0.70, 0.95, 1.20],
    "military press": [0.30, 0.50, 0.70, 0.95, 1.20],
    "barbell row": [0.40, 0.65, 0.95, 1.25, 1.60],
    "bent over row": [0.40, 0.65, 0.95, 1.25, 1.60],
}

_FEMALE_BW_RATIOS: dict[str, list[float]] = {
    "bench press": [0.30, 0.45, 0.65, 0.90, 1.20],
    "barbell bench press": [0.30, 0.45, 0.65, 0.90, 1.20],
    "squat": [0.50, 0.80, 1.20, 1.55, 2.00],
    "barbell squat": [0.50, 0.80, 1.20, 1.55, 2.00],
    "deadlift": [0.60, 1.0, 1.45, 1.90, 2.40],
    "barbell deadlift": [0.60, 1.0, 1.45, 1.90, 2.40],
    "overhead press": [0.20, 0.35, 0.50, 0.70, 0.90],
    "barbell overhead press": [0.20, 0.35, 0.50, 0.70, 0.90],
    "military press": [0.20, 0.35, 0.50, 0.70, 0.90],
    "barbell row": [0.30, 0.45, 0.65, 0.90, 1.20],
    "bent over row": [0.30, 0.45, 0.65, 0.90, 1.20],
}

_TIERS = ["beginner", "novice", "intermediate", "advanced", "elite"]
_TIER_ORDER = {t: i for i, t in enumerate(_TIERS)}
_TIER_ORDER["untrained"] = -1


def _classify_strength(e1rm: float, standards: list[float]) -> tuple[str, float]:
    """Return (tier, percentile) for a given e1RM against standards."""
    tier_percentiles = [10, 30, 50, 75, 95]

    if e1rm < standards[0]:
        return "untrained", max(0, round(e1rm / standards[0] * 10, 1))

    for i in range(len(standards) - 1):
        if e1rm < standards[i + 1]:
            frac = (e1rm - standards[i]) / (standards[i + 1] - standards[i])
            pct = tier_percentiles[i] + frac * (tier_percentiles[i + 1] - tier_percentiles[i])
            return _TIERS[i], round(pct, 1)

    return "elite", min(99.0, round(95 + (e1rm - standards[-1]) / standards[-1] * 4, 1))


def _find_standard(
    exercise_name: str,
    *,
    sex: str = "male",
    bodyweight: float | None = None,
) -> list[float] | None:
    """Match an exercise name to standards (case-insensitive).

    When bodyweight is available, returns BW-relative standards (multiplied
    by bodyweight) which are more accurate than absolute thresholds.
    """
    lower = exercise_name.lower().strip()

    # Choose the correct tables based on sex
    if bodyweight and bodyweight > 0:
        bw_table = _FEMALE_BW_RATIOS if sex == "female" else _MALE_BW_RATIOS
        # Try BW-relative first
        ratios = bw_table.get(lower)
        if ratios is None:
            for key, r in bw_table.items():
                if key in lower or lower in key:
                    ratios = r
                    break
        if ratios:
            return [round(r * bodyweight, 1) for r in ratios]

    # Fall back to absolute standards
    abs_table = _FEMALE_STANDARDS if sex == "female" else _MALE_STANDARDS

    if lower in abs_table:
        return abs_table[lower]
    for key, standards in abs_table.items():
        if key in lower or lower in key:
            return standards
    return None


async def compute_strength_standards(
    user_id: str,
    db_pool: asyncpg.Pool,
    weeks: int = 12,
) -> StrengthStandardsResponse:
    """Benchmark the user's best estimated 1RM per exercise against population norms.

    Auto-detects user sex from profiles table (defaults to male if unset).
    Uses bodyweight-relative standards when bodyweight is available.
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

        # Try to get user profile for sex and bodyweight
        profile = await conn.fetchrow(
            """
            SELECT sex, current_body_weight_kg
            FROM profiles
            WHERE id = $1
            """,
            user_id,
        )

    sex = "male"
    bodyweight: float | None = None
    if profile:
        if profile.get("sex") in ("female", "f"):
            sex = "female"
        bw = profile.get("current_body_weight_kg")
        if bw and float(bw) > 0:
            bodyweight = float(bw)

    using_bw_relative = bodyweight is not None

    entries: list[ExerciseStandardEntry] = []
    tier_counts: dict[str, int] = {}

    for row in rows:
        name = row["exercise_name"]
        standards = _find_standard(name, sex=sex, bodyweight=bodyweight)
        if standards is None:
            continue

        e1rm = float(row["best_e1rm"])
        tier, percentile = _classify_strength(e1rm, standards)

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

    # Overall tier: most common tier, with tie-breaking by tier order (higher wins)
    if tier_counts:
        overall_tier = max(
            tier_counts,
            key=lambda t: (tier_counts[t], _TIER_ORDER.get(t, -1)),
        )
    else:
        overall_tier = "insufficient_data"

    # Build context-aware disclaimer
    if sex == "female" and using_bw_relative:
        basis = "female bodyweight-relative norms"
    elif sex == "female":
        basis = "female absolute standards (calibrated for ~60 kg)"
    elif using_bw_relative:
        basis = "male bodyweight-relative norms"
    else:
        basis = "male absolute standards (calibrated for ~80 kg)"

    return StrengthStandardsResponse(
        exercises=entries,
        overall_tier=overall_tier,
        exercises_benchmarked=len(entries),
        tier_distribution=tier_counts,
        disclaimer=(
            f"Standards based on {basis}. "
            "Individual variation depends on training age, genetics, and technique. "
            "Use as a rough guide, not a definitive measure."
        ),
    )
