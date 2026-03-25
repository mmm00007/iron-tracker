"""Progressive overload tracking with plateau detection."""

from datetime import UTC, date, datetime, timedelta

import asyncpg

from app.models.schemas import (
    ExerciseOverloadEntry,
    ProgressiveOverloadResponse,
)


def _epley(weight: float, reps: int) -> float:
    if reps <= 0 or weight <= 0:
        return weight
    return weight * (1 + reps / 30)


def _linear_regression(xs: list[float], ys: list[float]) -> tuple[float, float]:
    """Simple OLS linear regression. Returns (slope, intercept).

    Pure Python implementation — no numpy dependency required.
    """
    n = len(xs)
    if n < 2:
        return 0.0, (ys[0] if ys else 0.0)

    sum_x = sum(xs)
    sum_y = sum(ys)
    sum_xy = sum(x * y for x, y in zip(xs, ys))
    sum_x2 = sum(x * x for x in xs)

    denom = n * sum_x2 - sum_x * sum_x
    if denom == 0:
        return 0.0, sum_y / n

    slope = (n * sum_xy - sum_x * sum_y) / denom
    intercept = (sum_y - slope * sum_x) / n
    return slope, intercept


def _detect_plateau(weekly_e1rms: list[float], threshold: float = 0.05) -> int:
    """Count consecutive recent weeks where e1RM is within `threshold` CV.

    Uses 5% CV threshold (fitness expert recommendation — 2% was too aggressive
    and produced false positives from normal training variation).
    Returns the number of plateau weeks (0 if not in a plateau).
    """
    if len(weekly_e1rms) < 4:
        return 0

    # Walk backward from most recent week
    plateau_weeks = 0
    for i in range(len(weekly_e1rms) - 1, 1, -1):
        window = weekly_e1rms[max(0, i - 2) : i + 1]  # 3-week window
        mean_val = sum(window) / len(window)
        if mean_val == 0:
            break
        variance = sum((v - mean_val) ** 2 for v in window) / len(window)
        std_dev = variance**0.5
        cv = std_dev / mean_val
        if cv < threshold:
            plateau_weeks += 1
        else:
            break

    return plateau_weeks


async def compute_progressive_overload(
    user_id: str,
    db_pool: asyncpg.Pool,
    weeks: int = 8,
) -> ProgressiveOverloadResponse:
    """Analyze progressive overload across all exercises trained in the period.

    For each exercise with sufficient data (≥3 sessions):
    - Computes overload rate via linear regression on best daily e1RM
    - Detects plateaus (e1RM within 2% CV for 3+ weeks)
    - Classifies as progressing / plateau / regressing
    """
    since = datetime.now(UTC) - timedelta(weeks=weeks)

    async with db_pool.acquire() as conn:
        rows = await conn.fetch(
            """
            SELECT
                s.exercise_id,
                e.name AS exercise_name,
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
            exercise_data[eid] = {
                "name": row["exercise_name"],
                "day_best": {},
            }
        day: date = row["day"]
        e1rm = _epley(float(row["weight"]), int(row["reps"]))
        current_best = exercise_data[eid]["day_best"].get(day, 0.0)
        if e1rm > current_best:
            exercise_data[eid]["day_best"][day] = e1rm

    entries: list[ExerciseOverloadEntry] = []
    for eid, data in exercise_data.items():
        day_best = data["day_best"]
        if len(day_best) < 3:
            continue

        sorted_days = sorted(day_best.keys())
        origin = sorted_days[0]
        xs = [(d - origin).days for d in sorted_days]
        ys = [day_best[d] for d in sorted_days]

        slope, _ = _linear_regression([float(x) for x in xs], ys)
        overload_rate = slope * 7  # kg per week

        # Weekly best for plateau detection
        weekly_best: dict[int, float] = {}
        for d, e1rm in day_best.items():
            week_num = (d - origin).days // 7
            if e1rm > weekly_best.get(week_num, 0.0):
                weekly_best[week_num] = e1rm

        weekly_values = [weekly_best[w] for w in sorted(weekly_best.keys())]
        plateau_weeks = _detect_plateau(weekly_values)

        current_e1rm = ys[-1]
        weeks_tracked = max(1, (sorted_days[-1] - sorted_days[0]).days // 7 + 1)

        # Plateau requires BOTH low variation AND near-zero overload rate.
        # This prevents flagging steady, consistent progressions as plateaus
        # (which have low CV within any window but positive slope).
        if plateau_weeks >= 4 and abs(overload_rate) < 0.5:
            status = "plateau"
        elif overload_rate > 0:
            status = "progressing"
        else:
            status = "regressing"

        entries.append(
            ExerciseOverloadEntry(
                exercise_id=eid,
                exercise_name=data["name"],
                overload_rate=round(overload_rate, 2),
                status=status,
                current_e1rm=round(current_e1rm, 1),
                weeks_tracked=weeks_tracked,
                plateau_weeks=plateau_weeks,
            )
        )

    # Sort: plateaus first, then regressions, then progressions
    status_order = {"plateau": 0, "regressing": 1, "progressing": 2}
    entries.sort(key=lambda e: (status_order.get(e.status, 3), -abs(e.overload_rate)))

    counts = {"progressing": 0, "plateau": 0, "regressing": 0}
    for e in entries:
        counts[e.status] = counts.get(e.status, 0) + 1

    if not entries:
        overall = "insufficient_data"
    elif counts["progressing"] >= counts["plateau"] + counts["regressing"]:
        overall = "progressing"
    elif counts["plateau"] > counts["regressing"]:
        overall = "mixed_plateaus"
    else:
        overall = "attention_needed"

    return ProgressiveOverloadResponse(
        exercises=entries,
        overall_status=overall,
        progressing_count=counts["progressing"],
        plateau_count=counts["plateau"],
        regressing_count=counts["regressing"],
    )
