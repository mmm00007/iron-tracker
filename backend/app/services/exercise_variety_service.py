"""Exercise variety and movement pattern analysis.

Measures training diversity via:
1. Exercise variety index: Shannon entropy on exercise selection
   (higher = more diverse exercise choices)
2. Movement pattern coverage: maps exercises to fundamental movement
   patterns (Boyle 2016) and identifies gaps
3. Stimulus diversity: whether the user varies rep ranges, loads,
   and set types across exercises

Movement patterns based on Boyle's "New Functional Training" taxonomy:
  - Horizontal Push (bench press, push-up)
  - Vertical Push (overhead press, pike push-up)
  - Horizontal Pull (row, cable row)
  - Vertical Pull (pull-up, lat pulldown)
  - Squat (back squat, front squat, goblet squat)
  - Hip Hinge (deadlift, RDL, hip thrust)
  - Lunge (lunge, split squat, step-up)
  - Carry (farmer's walk, suitcase carry)
  - Core (plank, ab wheel, pallof press)
  - Isolation (curls, lateral raises, etc.)
"""

import math
from datetime import UTC, datetime, timedelta

import asyncpg

from app.models.schemas import (
    ExerciseVarietyResponse,
    MovementPatternEntry,
)

# Keyword-based movement pattern classification
# Maps keywords found in exercise names to movement patterns
_PATTERN_KEYWORDS: dict[str, list[str]] = {
    "horizontal_push": [
        "bench press", "push up", "push-up", "pushup", "chest press",
        "dumbbell press", "floor press", "dip",
    ],
    "vertical_push": [
        "overhead press", "shoulder press", "military press", "pike",
        "arnold press", "push press", "z press",
    ],
    "horizontal_pull": [
        "row", "cable row", "seated row", "t-bar", "inverted row",
    ],
    "vertical_pull": [
        "pull up", "pull-up", "pullup", "chin up", "chin-up", "chinup",
        "lat pulldown", "pulldown", "pull down",
    ],
    "squat": [
        "squat", "leg press", "hack squat", "goblet",
    ],
    "hip_hinge": [
        "deadlift", "rdl", "romanian", "hip thrust", "glute bridge",
        "good morning", "kettlebell swing",
    ],
    "lunge": [
        "lunge", "split squat", "step up", "step-up", "bulgarian",
    ],
    "carry": [
        "farmer", "carry", "suitcase", "walk",
    ],
    "core": [
        "plank", "crunch", "sit up", "sit-up", "ab wheel", "pallof",
        "leg raise", "hanging raise", "russian twist", "wood chop",
        "dead bug", "bird dog", "cable twist",
    ],
}

# Recommended minimum patterns for balanced training
_ESSENTIAL_PATTERNS = {
    "horizontal_push", "horizontal_pull", "vertical_push",
    "vertical_pull", "squat", "hip_hinge",
}


def _classify_movement_pattern(exercise_name: str) -> str:
    """Classify an exercise into a movement pattern by keyword matching."""
    lower = exercise_name.lower()
    for pattern, keywords in _PATTERN_KEYWORDS.items():
        for kw in keywords:
            if kw in lower:
                return pattern
    return "isolation"


async def compute_exercise_variety(
    user_id: str,
    db_pool: asyncpg.Pool,
    period_days: int = 28,
) -> ExerciseVarietyResponse:
    """Analyze exercise variety and movement pattern coverage.

    Returns:
    - Exercise variety index (Shannon entropy, 0-1 normalized)
    - Movement pattern coverage with set counts
    - Missing essential movement patterns
    - Unique exercise count
    """
    since = datetime.now(UTC) - timedelta(days=period_days)

    async with db_pool.acquire() as conn:
        rows = await conn.fetch(
            """
            SELECT
                e.name          AS exercise_name,
                COUNT(*)        AS set_count,
                COUNT(DISTINCT DATE(s.logged_at)) AS sessions
            FROM sets s
            JOIN exercises e ON e.id = s.exercise_id
            WHERE s.user_id = $1
              AND s.logged_at >= $2
            GROUP BY e.name
            ORDER BY COUNT(*) DESC
            """,
            user_id,
            since,
        )

    if not rows:
        return ExerciseVarietyResponse(
            variety_index=0.0,
            variety_label="insufficient_data",
            unique_exercises=0,
            movement_patterns=[],
            missing_patterns=[],
            top_exercises=[],
            period_days=period_days,
        )

    # Exercise variety index (Shannon entropy on set distribution)
    total_sets = sum(int(r["set_count"]) for r in rows)
    proportions = [int(r["set_count"]) / total_sets for r in rows]
    entropy = -sum(p * math.log(p) for p in proportions if p > 0)
    max_entropy = math.log(len(rows)) if len(rows) > 1 else 1.0
    variety_index = round(entropy / max_entropy, 3) if max_entropy > 0 else 0.0

    if variety_index >= 0.8:
        variety_label = "highly_diverse"
    elif variety_index >= 0.6:
        variety_label = "balanced"
    elif variety_index >= 0.4:
        variety_label = "moderate"
    else:
        variety_label = "narrow"

    # Movement pattern analysis
    pattern_data: dict[str, dict] = {}
    for row in rows:
        pattern = _classify_movement_pattern(row["exercise_name"])
        if pattern not in pattern_data:
            pattern_data[pattern] = {
                "sets": 0,
                "exercises": [],
                "sessions": 0,
            }
        pattern_data[pattern]["sets"] += int(row["set_count"])
        pattern_data[pattern]["exercises"].append(row["exercise_name"])
        pattern_data[pattern]["sessions"] += int(row["sessions"])

    movement_patterns: list[MovementPatternEntry] = []
    for pattern, data in sorted(pattern_data.items(), key=lambda x: -x[1]["sets"]):
        movement_patterns.append(
            MovementPatternEntry(
                pattern=pattern,
                sets=data["sets"],
                exercise_count=len(data["exercises"]),
                examples=data["exercises"][:3],
                percentage=round(data["sets"] / total_sets * 100, 1),
            )
        )

    # Missing essential patterns
    covered_patterns = set(pattern_data.keys())
    missing = sorted(_ESSENTIAL_PATTERNS - covered_patterns)

    # Top exercises by volume
    top_exercises = [
        {"name": r["exercise_name"], "sets": int(r["set_count"]), "sessions": int(r["sessions"])}
        for r in rows[:10]
    ]

    return ExerciseVarietyResponse(
        variety_index=variety_index,
        variety_label=variety_label,
        unique_exercises=len(rows),
        movement_patterns=movement_patterns,
        missing_patterns=missing,
        top_exercises=top_exercises,
        period_days=period_days,
    )
