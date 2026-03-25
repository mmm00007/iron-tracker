"""Performance forecasting via 1RM trend extrapolation.

Projects future strength levels for each exercise based on the observed
rate of progress. Uses linear regression on daily best e1RM values with
R²-based confidence scoring.

Key features:
- 4/8/12 week projections with confidence intervals
- Milestone predictions (e.g., "estimated to reach 100kg in 6 weeks")
- R² goodness-of-fit for prediction reliability
- Accounts for diminishing returns by flagging low R² (non-linear progress)

References:
- Zourdos et al. (2016) — novel resistance training-specific RPE scale
- Rønnestad et al. (2016) — strength gain trajectories in trained lifters
"""

from datetime import UTC, date, datetime, timedelta

import asyncpg

from app.models.schemas import (
    ExerciseForecastEntry,
    ForecastMilestone,
    PerformanceForecastResponse,
)


def _linear_regression_with_r2(
    xs: list[float], ys: list[float]
) -> tuple[float, float, float]:
    """OLS regression returning (slope, intercept, r_squared)."""
    n = len(xs)
    if n < 2:
        return 0.0, (ys[0] if ys else 0.0), 0.0

    sum_x = sum(xs)
    sum_y = sum(ys)
    sum_xy = sum(x * y for x, y in zip(xs, ys))
    sum_x2 = sum(x * x for x in xs)

    denom = n * sum_x2 - sum_x * sum_x
    if denom == 0:
        return 0.0, sum_y / n, 0.0

    slope = (n * sum_xy - sum_x * sum_y) / denom
    intercept = (sum_y - slope * sum_x) / n

    # R² calculation
    y_mean = sum_y / n
    ss_tot = sum((y - y_mean) ** 2 for y in ys)
    ss_res = sum((y - (slope * x + intercept)) ** 2 for x, y in zip(xs, ys))

    r_squared = 1 - (ss_res / ss_tot) if ss_tot > 0 else 0.0
    return slope, intercept, max(0.0, r_squared)


def _confidence_label(r2: float, data_points: int) -> str:
    """Classify prediction confidence based on R² and sample size."""
    if data_points < 5:
        return "low"
    if r2 >= 0.7 and data_points >= 8:
        return "high"
    if r2 >= 0.4:
        return "moderate"
    return "low"


# Common milestone targets (kg) for compound lifts
_MILESTONES: dict[str, list[float]] = {
    "bench press": [40, 60, 80, 100, 120, 140, 160],
    "barbell bench press": [40, 60, 80, 100, 120, 140, 160],
    "squat": [60, 80, 100, 120, 140, 160, 180, 200],
    "barbell squat": [60, 80, 100, 120, 140, 160, 180, 200],
    "deadlift": [60, 100, 120, 140, 160, 180, 200, 220, 250],
    "barbell deadlift": [60, 100, 120, 140, 160, 180, 200, 220, 250],
    "overhead press": [30, 40, 50, 60, 70, 80, 90, 100],
    "barbell overhead press": [30, 40, 50, 60, 70, 80, 90, 100],
    "barbell row": [40, 60, 80, 100, 120],
    "bent over row": [40, 60, 80, 100, 120],
}


def _find_milestones(exercise_name: str) -> list[float]:
    """Find milestone targets for an exercise."""
    lower = exercise_name.lower().strip()
    if lower in _MILESTONES:
        return _MILESTONES[lower]
    for key, vals in _MILESTONES.items():
        if key in lower or lower in key:
            return vals
    return []


async def compute_performance_forecast(
    user_id: str,
    db_pool: asyncpg.Pool,
    weeks: int = 12,
) -> PerformanceForecastResponse:
    """Forecast future 1RM values for exercises with sufficient training history.

    Returns projections at 4, 8, and 12 weeks, plus milestone predictions
    for compound lifts.
    """
    since = datetime.now(UTC) - timedelta(weeks=weeks)

    async with db_pool.acquire() as conn:
        rows = await conn.fetch(
            """
            SELECT
                s.exercise_id,
                e.name       AS exercise_name,
                s.weight,
                s.reps,
                DATE(s.logged_at) AS day
            FROM sets s
            JOIN exercises e ON e.id = s.exercise_id
            WHERE s.user_id = $1
              AND s.logged_at >= $2
              AND s.weight > 0
              AND s.reps > 0
            ORDER BY s.exercise_id, s.logged_at
            """,
            user_id,
            since,
        )

    # Group by exercise, compute best daily e1RM
    exercise_data: dict[str, dict] = {}
    for row in rows:
        eid = str(row["exercise_id"])
        if eid not in exercise_data:
            exercise_data[eid] = {"name": row["exercise_name"], "day_best": {}}
        day: date = row["day"]
        weight = float(row["weight"])
        reps = int(row["reps"])
        e1rm = weight * (1 + reps / 30) if reps > 0 else weight
        current_best = exercise_data[eid]["day_best"].get(day, 0.0)
        if e1rm > current_best:
            exercise_data[eid]["day_best"][day] = e1rm

    entries: list[ExerciseForecastEntry] = []
    for eid, data in exercise_data.items():
        day_best = data["day_best"]
        if len(day_best) < 4:
            continue

        sorted_days = sorted(day_best.keys())
        origin = sorted_days[0]
        xs = [float((d - origin).days) for d in sorted_days]
        ys = [day_best[d] for d in sorted_days]

        slope, intercept, r2 = _linear_regression_with_r2(xs, ys)
        current_e1rm = ys[-1]
        current_day_offset = xs[-1]

        # Projections at 4, 8, 12 weeks ahead
        projections: dict[str, float] = {}
        for label, future_weeks in [("4_weeks", 4), ("8_weeks", 8), ("12_weeks", 12)]:
            future_x = current_day_offset + future_weeks * 7
            projected = slope * future_x + intercept
            # Don't project unreasonable values (negative or >3x current)
            projected = max(0, min(projected, current_e1rm * 3))
            projections[label] = round(projected, 1)

        # Milestone predictions
        milestones_list = _find_milestones(data["name"])
        milestones: list[ForecastMilestone] = []
        if slope > 0 and milestones_list:
            for target in milestones_list:
                if target <= current_e1rm:
                    continue
                # days_to_target = (target - current_value) / slope
                current_value = slope * current_day_offset + intercept
                if current_value >= target:
                    continue
                days_needed = (target - current_value) / slope
                if 0 < days_needed <= 365:
                    target_date = date.today() + timedelta(days=int(days_needed))
                    milestones.append(
                        ForecastMilestone(
                            target_kg=target,
                            estimated_date=str(target_date),
                            weeks_away=round(days_needed / 7, 1),
                        )
                    )

        confidence = _confidence_label(r2, len(day_best))
        rate_per_week = round(slope * 7, 2)

        entries.append(
            ExerciseForecastEntry(
                exercise_id=eid,
                exercise_name=data["name"],
                current_e1rm=round(current_e1rm, 1),
                rate_per_week=rate_per_week,
                r_squared=round(r2, 3),
                confidence=confidence,
                projections=projections,
                milestones=milestones,
                data_points=len(day_best),
            )
        )

    # Sort by confidence (high first), then by data points
    confidence_order = {"high": 0, "moderate": 1, "low": 2}
    entries.sort(key=lambda e: (confidence_order.get(e.confidence, 3), -e.data_points))

    high_confidence = sum(1 for e in entries if e.confidence == "high")

    return PerformanceForecastResponse(
        exercises=entries,
        exercises_forecast=len(entries),
        high_confidence_count=high_confidence,
        disclaimer=(
            "Forecasts assume linear progression, which is typical for novice and "
            "intermediate lifters. Advanced lifters experience diminishing returns — "
            "low R² values indicate non-linear progress where projections are less reliable."
        ),
    )
