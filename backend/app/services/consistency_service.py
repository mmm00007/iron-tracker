"""Training consistency and streak analysis.

Consistency is the strongest predictor of long-term training outcomes
(Schoenfeld & Grgic 2020). This service tracks:

- Weekly consistency score: fraction of weeks with sufficient training
- Current and longest streaks: consecutive weeks meeting a threshold
- Training regularity index: how predictable the training pattern is
  (low variance in inter-session gaps = high regularity)
"""

import math
from datetime import UTC, date, datetime, timedelta

import asyncpg

from app.models.schemas import (
    ConsistencyResponse,
    ConsistencyWeekEntry,
)

# Minimum training days per week to count as "active"
_MIN_DAYS_PER_WEEK = 2


def _regularity_index(gaps: list[float]) -> float | None:
    """Compute training regularity index (0-1).

    Uses coefficient of variation of inter-session gaps, inverted and
    clamped to [0, 1]. Low CV = high regularity. A perfectly regular
    schedule (e.g., every 48h) yields 1.0.

    Returns None if insufficient data (<3 gaps).
    """
    if len(gaps) < 3:
        return None

    mean_gap = sum(gaps) / len(gaps)
    if mean_gap <= 0:
        return None

    variance = sum((g - mean_gap) ** 2 for g in gaps) / len(gaps)
    cv = math.sqrt(variance) / mean_gap

    # CV of 0 = perfect regularity (1.0), CV of 1+ = irregular (→ 0)
    return round(max(0.0, min(1.0, 1.0 - cv)), 3)


def _regularity_label(index: float | None) -> str:
    if index is None:
        return "insufficient_data"
    if index >= 0.75:
        return "very_regular"
    if index >= 0.5:
        return "regular"
    if index >= 0.25:
        return "somewhat_irregular"
    return "irregular"


async def compute_consistency(
    user_id: str,
    db_pool: asyncpg.Pool,
    weeks: int = 12,
) -> ConsistencyResponse:
    """Compute training consistency metrics over the given period.

    Returns:
    - Per-week training day counts
    - Current streak (consecutive weeks with ≥2 training days)
    - Longest streak
    - Overall consistency score (% of weeks meeting threshold)
    - Training regularity index
    """
    since = datetime.now(UTC) - timedelta(weeks=weeks)

    async with db_pool.acquire() as conn:
        rows = await conn.fetch(
            """
            SELECT DISTINCT DATE(logged_at) AS training_day
            FROM sets
            WHERE user_id = $1
              AND logged_at >= $2
            ORDER BY training_day
            """,
            user_id,
            since,
        )

    training_days: set[date] = {row["training_day"] for row in rows}

    if not training_days:
        return ConsistencyResponse(
            weeks=[],
            current_streak=0,
            longest_streak=0,
            consistency_score=0.0,
            consistency_label="insufficient_data",
            total_training_days=0,
            avg_days_per_week=0.0,
            regularity_index=None,
            regularity_label="insufficient_data",
        )

    # Build per-week entries
    today = date.today()
    week_entries: list[ConsistencyWeekEntry] = []
    active_weeks = 0

    for w in range(weeks):
        week_start = today - timedelta(days=today.weekday() + 7 * (weeks - 1 - w))
        days_in_week = sum(1 for d in range(7) if (week_start + timedelta(days=d)) in training_days)
        is_active = days_in_week >= _MIN_DAYS_PER_WEEK
        if is_active:
            active_weeks += 1
        week_entries.append(
            ConsistencyWeekEntry(
                week_start=str(week_start),
                training_days=days_in_week,
                is_active=is_active,
            )
        )

    # Streak calculation (consecutive active weeks from most recent)
    current_streak = 0
    for entry in reversed(week_entries):
        if entry.is_active:
            current_streak += 1
        else:
            break

    # Longest streak
    longest_streak = 0
    running = 0
    for entry in week_entries:
        if entry.is_active:
            running += 1
            longest_streak = max(longest_streak, running)
        else:
            running = 0

    # Consistency score
    consistency_score = round(active_weeks / weeks, 3) if weeks > 0 else 0.0

    if consistency_score >= 0.85:
        consistency_label = "excellent"
    elif consistency_score >= 0.65:
        consistency_label = "good"
    elif consistency_score >= 0.4:
        consistency_label = "moderate"
    else:
        consistency_label = "needs_improvement"

    # Training regularity (CV of inter-session gaps)
    sorted_days = sorted(training_days)
    gaps = [(sorted_days[i + 1] - sorted_days[i]).days for i in range(len(sorted_days) - 1)]
    regularity = _regularity_index([float(g) for g in gaps])

    total_days = len(training_days)
    avg_per_week = round(total_days / weeks, 1) if weeks > 0 else 0.0

    return ConsistencyResponse(
        weeks=week_entries,
        current_streak=current_streak,
        longest_streak=longest_streak,
        consistency_score=consistency_score,
        consistency_label=consistency_label,
        total_training_days=total_days,
        avg_days_per_week=avg_per_week,
        regularity_index=regularity,
        regularity_label=_regularity_label(regularity),
    )
