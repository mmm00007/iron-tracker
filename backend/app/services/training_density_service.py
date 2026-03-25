"""Training density and efficiency metrics: sets per hour, volume per minute, trend."""

from datetime import UTC, datetime, timedelta

import asyncpg

from app.models.schemas import SessionDensityEntry, TrainingDensityResponse


def _linear_regression(
    xs: list[float], ys: list[float]
) -> tuple[float | None, float | None]:
    """Pure-Python simple linear regression. Returns (slope, intercept)."""
    n = len(xs)
    if n < 3:
        return None, None
    x_mean = sum(xs) / n
    y_mean = sum(ys) / n
    num = sum((x - x_mean) * (y - y_mean) for x, y in zip(xs, ys))
    den = sum((x - x_mean) ** 2 for x in xs)
    if den == 0:
        return 0.0, y_mean
    slope = num / den
    intercept = y_mean - slope * x_mean
    return slope, intercept


async def compute_training_density(
    user_id: str,
    db_pool: asyncpg.Pool,
    period_days: int = 28,
) -> TrainingDensityResponse:
    """Compute training density metrics over the given period.

    Primary metric: sets_per_hour (working sets / session hours).
    Secondary metric: volume_per_minute (total volume kg / session minutes).
    Trend: linear regression of sets_per_hour over chronological sessions.

    Sessions shorter than 5 min or longer than 180 min are excluded.
    """
    since = datetime.now(UTC) - timedelta(days=period_days)

    async with db_pool.acquire() as conn:
        rows = await conn.fetch(
            """
            SELECT
                s.workout_cluster_id,
                s.training_date::text AS training_date,
                MIN(s.logged_at) AS session_start,
                MAX(s.logged_at) AS session_end,
                EXTRACT(EPOCH FROM MAX(s.logged_at) - MIN(s.logged_at)) / 60
                    AS duration_minutes,
                SUM(
                    CASE WHEN s.weight_unit = 'lb'
                         THEN s.weight * 0.453592
                         ELSE s.weight
                    END * s.reps
                ) AS volume_kg,
                COUNT(*) FILTER (WHERE s.set_type = 'working') AS working_sets,
                COUNT(DISTINCT s.exercise_id) AS exercise_count
            FROM sets s
            WHERE s.user_id = $1
              AND s.logged_at >= $2
              AND s.workout_cluster_id IS NOT NULL
              AND s.reps > 0
            GROUP BY s.workout_cluster_id, s.training_date
            HAVING EXTRACT(EPOCH FROM MAX(s.logged_at) - MIN(s.logged_at)) / 60
                   BETWEEN 5 AND 180
            ORDER BY s.training_date DESC
            """,
            user_id,
            since,
        )

    disclaimer = (
        "Training density reflects workout pace, not quality. "
        "Higher density is not inherently better. Heavy compound lifts "
        "require longer rest periods (2-5 minutes) for safe execution."
    )

    if not rows:
        return TrainingDensityResponse(
            sessions=[],
            avg_sets_per_hour=None,
            avg_volume_per_minute=None,
            trend_direction="stable",
            trend_slope=None,
            period_days=period_days,
            disclaimer=disclaimer,
        )

    sessions: list[SessionDensityEntry] = []
    sph_values: list[float] = []
    vpm_values: list[float] = []

    for row in rows:
        duration = float(row["duration_minutes"])
        working_sets = int(row["working_sets"])
        volume_kg = float(row["volume_kg"]) if row["volume_kg"] else 0.0

        sets_per_hour = working_sets / (duration / 60) if duration > 0 else 0.0
        volume_per_minute = volume_kg / duration if duration > 0 else 0.0

        sessions.append(
            SessionDensityEntry(
                training_date=row["training_date"],
                cluster_id=str(row["workout_cluster_id"]),
                duration_minutes=round(duration, 1),
                working_sets=working_sets,
                total_volume_kg=round(volume_kg, 1),
                sets_per_hour=round(sets_per_hour, 1),
                volume_per_minute=round(volume_per_minute, 2),
                exercise_count=int(row["exercise_count"]),
            )
        )

        sph_values.append(sets_per_hour)
        vpm_values.append(volume_per_minute)

    avg_sets_per_hour = round(sum(sph_values) / len(sph_values), 1)
    avg_volume_per_minute = round(sum(vpm_values) / len(vpm_values), 2)

    # Trend: linear regression of sets_per_hour in chronological order.
    # Sessions are ordered DESC from the query, so reverse for chronological.
    chronological_sph = list(reversed(sph_values))
    xs = list(range(len(chronological_sph)))
    slope, _ = _linear_regression(
        [float(x) for x in xs], chronological_sph
    )

    if slope is None:
        trend_direction = "stable"
    elif slope > 0.1:
        trend_direction = "increasing"
    elif slope < -0.1:
        trend_direction = "decreasing"
    else:
        trend_direction = "stable"

    return TrainingDensityResponse(
        sessions=sessions,
        avg_sets_per_hour=avg_sets_per_hour,
        avg_volume_per_minute=avg_volume_per_minute,
        trend_direction=trend_direction,
        trend_slope=round(slope, 4) if slope is not None else None,
        period_days=period_days,
        disclaimer=disclaimer,
    )
