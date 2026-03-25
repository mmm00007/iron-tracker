"""Workout staleness and exercise rotation detection.

Detects when training becomes too repetitive, which can lead to:
  1. Accommodation — muscles adapt to the same stimulus (Kraemer & Ratamess 2004)
  2. Overuse injuries — repetitive loading of the same movement patterns
  3. Motivational staleness — boredom from lack of variation

Uses Jaccard similarity between recent workout exercise selections.
When consecutive workouts share >80% of exercises, staleness is flagged.

The principle of progressive variation (not the same as muscle confusion)
suggests rotating exercise selection every 4-8 weeks while maintaining
the same movement patterns (Kraemer & Ratamess 2004, NSCA guidelines).
"""

from datetime import UTC, date, datetime, timedelta

import asyncpg

from app.models.schemas import (
    StalenessResponse,
    WorkoutSimilarityEntry,
)


def _jaccard_similarity(set_a: set[str], set_b: set[str]) -> float:
    """Compute Jaccard similarity between two sets (0.0 to 1.0)."""
    if not set_a or not set_b:
        return 0.0
    intersection = len(set_a & set_b)
    union = len(set_a | set_b)
    return round(intersection / union, 3) if union > 0 else 0.0


async def compute_staleness(
    user_id: str,
    db_pool: asyncpg.Pool,
    weeks: int = 4,
) -> StalenessResponse:
    """Analyze workout similarity and detect exercise staleness.

    Compares exercise selection across training days. High average
    similarity indicates the user is doing the same exercises repeatedly.
    """
    since = datetime.now(UTC) - timedelta(weeks=weeks)

    async with db_pool.acquire() as conn:
        rows = await conn.fetch(
            """
            SELECT
                DATE(s.logged_at)  AS training_date,
                e.name             AS exercise_name
            FROM sets s
            JOIN exercises e ON e.id = s.exercise_id
            WHERE s.user_id = $1
              AND s.logged_at >= $2
            ORDER BY DATE(s.logged_at)
            """,
            user_id,
            since,
        )

    if not rows:
        return StalenessResponse(
            staleness_index=0.0,
            staleness_label="insufficient_data",
            avg_similarity=0.0,
            workout_comparisons=[],
            unique_exercises=0,
            total_workouts=0,
            recommendation="",
            period_weeks=weeks,
        )

    # Group exercises by training date
    workouts: dict[date, set[str]] = {}
    all_exercises: set[str] = set()
    for row in rows:
        day = row["training_date"]
        if day not in workouts:
            workouts[day] = set()
        workouts[day].add(row["exercise_name"])
        all_exercises.add(row["exercise_name"])

    sorted_dates = sorted(workouts.keys())

    if len(sorted_dates) < 2:
        return StalenessResponse(
            staleness_index=0.0,
            staleness_label="insufficient_data",
            avg_similarity=0.0,
            workout_comparisons=[],
            unique_exercises=len(all_exercises),
            total_workouts=1,
            recommendation="Need at least 2 workouts to assess staleness.",
            period_weeks=weeks,
        )

    # Compute pairwise similarity between consecutive workouts
    comparisons: list[WorkoutSimilarityEntry] = []
    similarities: list[float] = []

    for i in range(len(sorted_dates) - 1):
        d1 = sorted_dates[i]
        d2 = sorted_dates[i + 1]
        sim = _jaccard_similarity(workouts[d1], workouts[d2])
        similarities.append(sim)
        shared = workouts[d1] & workouts[d2]
        comparisons.append(
            WorkoutSimilarityEntry(
                date_a=str(d1),
                date_b=str(d2),
                similarity=sim,
                shared_exercises=sorted(shared),
                exercises_a=len(workouts[d1]),
                exercises_b=len(workouts[d2]),
            )
        )

    avg_sim = round(sum(similarities) / len(similarities), 3)

    # Staleness index: weighted toward recent similarity (last 3 comparisons)
    recent = similarities[-3:] if len(similarities) >= 3 else similarities
    staleness_index = round(sum(recent) / len(recent), 3)

    # Classification
    if staleness_index >= 0.8:
        label = "very_stale"
        rec = (
            "Your recent workouts are highly repetitive (>80% overlap). "
            "Consider rotating 2-3 exercises while keeping the same movement "
            "patterns. This promotes adaptation without losing specificity."
        )
    elif staleness_index >= 0.6:
        label = "moderately_stale"
        rec = (
            "Moderate exercise repetition detected. Some variation in exercise "
            "selection every 4-6 weeks can help drive continued adaptation."
        )
    elif staleness_index >= 0.3:
        label = "balanced"
        rec = "Good exercise variation. Your program has healthy diversity."
    else:
        label = "highly_varied"
        rec = (
            "Very high exercise variation. While variety can be beneficial, "
            "ensure you maintain enough consistency to track progressive "
            "overload on key lifts."
        )

    return StalenessResponse(
        staleness_index=staleness_index,
        staleness_label=label,
        avg_similarity=avg_sim,
        workout_comparisons=comparisons[-10:],  # Last 10 only
        unique_exercises=len(all_exercises),
        total_workouts=len(sorted_dates),
        recommendation=rec,
        period_weeks=weeks,
    )
