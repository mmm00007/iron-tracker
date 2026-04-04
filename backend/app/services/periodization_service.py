"""Periodization analysis: monotony, strain, mesocycle detection, body part balance."""

import math
from datetime import UTC, date, datetime, timedelta

import asyncpg

from app.models.schemas import BodyPartBalanceResponse, PeriodizationResponse

# ─── Push/pull muscle classification ─────────────────────────────────────────

PUSH_MUSCLES = {"chest", "shoulders", "triceps"}
PULL_MUSCLES = {"lats", "biceps", "forearms", "traps", "lower back"}
UPPER_MUSCLES = {"chest", "shoulders", "triceps", "lats", "biceps", "forearms", "traps"}
LOWER_MUSCLES = {"quadriceps", "hamstrings", "glutes", "calves"}


# ─── Periodization ──────────────────────────────────────────────────────────


async def compute_periodization(
    user_id: str,
    db_pool: asyncpg.Pool,
    weeks: int = 8,
) -> PeriodizationResponse:
    """Analyze training periodization over the given number of weeks.

    Computes:
    - Weekly volume trend (total weight × reps per ISO week)
    - Foster's training monotony: mean(daily_volume) / std(daily_volume)
      High monotony (>2.0) correlates with increased injury risk.
    - Training strain: weekly_volume × monotony
    - Current phase detection (building / maintaining / deloading)
    """
    since = datetime.now(UTC) - timedelta(weeks=weeks)

    async with db_pool.acquire() as conn:
        rows = await conn.fetch(
            """
            SELECT
                DATE(logged_at)              AS day,
                SUM(weight * reps)           AS daily_volume
            FROM sets
            WHERE user_id = $1
              AND logged_at >= $2
              AND weight > 0
              AND reps > 0
            GROUP BY DATE(logged_at)
            ORDER BY DATE(logged_at)
            """,
            user_id,
            since,
        )

    if not rows:
        return PeriodizationResponse(
            weekly_volumes=[],
            monotony=None,
            strain=None,
            monotony_status="insufficient_data",
            current_phase="unknown",
            volume_trend_pct=None,
        )

    # Build daily volumes (including rest days as 0)
    day_volumes: dict[date, float] = {row["day"]: float(row["daily_volume"]) for row in rows}

    first_day = min(day_volumes.keys())
    last_day = max(day_volumes.keys())
    all_days: list[float] = []
    current = first_day
    while current <= last_day:
        all_days.append(day_volumes.get(current, 0.0))
        current += timedelta(days=1)

    # Weekly aggregation
    weekly_volumes: list[dict] = []
    today = date.today()
    for w in range(weeks):
        week_start = today - timedelta(days=today.weekday() + 7 * (weeks - 1 - w))
        week_end = week_start + timedelta(days=6)
        vol = sum(day_volumes.get(week_start + timedelta(days=d), 0.0) for d in range(7))
        training_days = sum(
            1 for d in range(7) if day_volumes.get(week_start + timedelta(days=d), 0.0) > 0
        )
        weekly_volumes.append(
            {
                "week_start": str(week_start),
                "week_end": str(week_end),
                "volume": round(vol),
                "training_days": training_days,
            }
        )

    # Foster's monotony (last 7 days)
    last_7 = all_days[-7:] if len(all_days) >= 7 else all_days
    # Include rest days as 0 for monotony calculation
    while len(last_7) < 7:
        last_7.insert(0, 0.0)

    mean_vol = sum(last_7) / len(last_7)
    variance = sum((v - mean_vol) ** 2 for v in last_7) / max(len(last_7) - 1, 1)
    std_vol = math.sqrt(variance) if variance > 0 else 0.0

    monotony = round(mean_vol / std_vol, 2) if std_vol > 0 else None
    weekly_load = sum(last_7)
    strain = round(weekly_load * monotony, 1) if monotony is not None else None

    # Threshold lowered to 1.5 for resistance training per sports medicine
    # expert review (Foster's original 2.0 was calibrated for endurance sports).
    if monotony is None:
        monotony_status = "insufficient_data"
    elif monotony > 1.5:
        monotony_status = "high_risk"
    elif monotony > 1.2:
        monotony_status = "elevated"
    else:
        monotony_status = "normal"

    # Phase detection from last 4 weeks of volume
    recent_weeks = [w["volume"] for w in weekly_volumes[-4:] if w["volume"] > 0]
    if len(recent_weeks) >= 3:
        # Compare last week to average of prior weeks
        last_week_vol = recent_weeks[-1]
        prior_avg = sum(recent_weeks[:-1]) / len(recent_weeks[:-1])

        if prior_avg > 0:
            change_pct = round((last_week_vol - prior_avg) / prior_avg * 100, 1)
        else:
            change_pct = None

        if change_pct is not None:
            if change_pct < -30:
                current_phase = "deloading"
            elif change_pct < -10:
                current_phase = "tapering"
            elif change_pct > 10:
                current_phase = "building"
            else:
                current_phase = "maintaining"
        else:
            current_phase = "unknown"
    else:
        change_pct = None
        current_phase = "unknown"

    return PeriodizationResponse(
        weekly_volumes=weekly_volumes,
        monotony=monotony,
        strain=strain,
        monotony_status=monotony_status,
        current_phase=current_phase,
        volume_trend_pct=change_pct,
    )


# ─── Body Part Balance ──────────────────────────────────────────────────────


async def compute_body_part_balance(
    user_id: str,
    db_pool: asyncpg.Pool,
    period_days: int = 7,
) -> BodyPartBalanceResponse:
    """Analyze push/pull and upper/lower volume balance.

    Also computes per-muscle-group weekly training frequency.
    """
    since = datetime.now(UTC) - timedelta(days=period_days)

    async with db_pool.acquire() as conn:
        rows = await conn.fetch(
            """
            SELECT
                mg.name                  AS muscle_group,
                em.is_primary,
                s.weight * s.reps        AS set_volume,
                DATE(s.logged_at)        AS training_date
            FROM sets s
            JOIN exercise_muscles em ON em.exercise_id = s.exercise_id
            JOIN muscle_groups mg    ON mg.id = em.muscle_group_id
            WHERE s.user_id = $1
              AND s.logged_at >= $2
              AND s.weight > 0
              AND s.reps > 0
            """,
            user_id,
            since,
        )

    if not rows:
        return BodyPartBalanceResponse(
            push_pull_ratio=None,
            push_pull_status="insufficient_data",
            upper_lower_ratio=None,
            upper_lower_status="insufficient_data",
            muscle_frequencies=[],
            imbalances=[],
        )

    # Aggregate volume per muscle group
    muscle_volume: dict[str, float] = {}
    muscle_dates: dict[str, set] = {}
    for row in rows:
        name = row["muscle_group"]
        factor = 1.0 if row["is_primary"] else 0.5
        vol = float(row["set_volume"]) * factor
        muscle_volume[name] = muscle_volume.get(name, 0.0) + vol
        if name not in muscle_dates:
            muscle_dates[name] = set()
        muscle_dates[name].add(row["training_date"])

    # Push/pull ratio
    push_vol = sum(muscle_volume.get(m, 0) for m in PUSH_MUSCLES)
    pull_vol = sum(muscle_volume.get(m, 0) for m in PULL_MUSCLES)

    push_pull_ratio = round(push_vol / pull_vol, 2) if pull_vol > 0 else None

    if push_pull_ratio is None:
        push_pull_status = "insufficient_data"
    elif 0.77 <= push_pull_ratio <= 1.0:
        push_pull_status = "optimal"
    elif 0.6 <= push_pull_ratio <= 1.2:
        push_pull_status = "acceptable"
    else:
        push_pull_status = "imbalanced"

    # Upper/lower ratio
    upper_vol = sum(muscle_volume.get(m, 0) for m in UPPER_MUSCLES)
    lower_vol = sum(muscle_volume.get(m, 0) for m in LOWER_MUSCLES)

    upper_lower_ratio = round(upper_vol / lower_vol, 2) if lower_vol > 0 else None

    if upper_lower_ratio is None:
        upper_lower_status = "insufficient_data"
    elif 0.8 <= upper_lower_ratio <= 1.5:
        upper_lower_status = "balanced"
    else:
        upper_lower_status = "imbalanced"

    # Per-muscle weekly frequency
    weeks = max(period_days / 7, 1)
    muscle_frequencies = [
        {
            "muscle_group": name,
            "sessions_per_week": round(len(dates) / weeks, 1),
            "volume": round(muscle_volume.get(name, 0), 1),
        }
        for name, dates in sorted(muscle_dates.items(), key=lambda x: -len(x[1]))
    ]

    # Detect imbalances
    imbalances: list[str] = []
    if push_pull_ratio is not None and push_pull_ratio > 1.3:
        imbalances.append(
            f"Push-dominant ({push_pull_ratio}:1) — add more pulling exercises "
            "to reduce shoulder injury risk."
        )
    elif push_pull_ratio is not None and push_pull_ratio < 0.6:
        imbalances.append(
            f"Pull-dominant ({push_pull_ratio}:1) — consider adding more pressing movements."
        )

    if upper_lower_ratio is not None and upper_lower_ratio > 2.0:
        imbalances.append(
            f"Upper-body dominant ({upper_lower_ratio}:1) — increase leg training "
            "for balanced development."
        )
    elif upper_lower_ratio is not None and upper_lower_ratio < 0.5:
        imbalances.append(
            f"Lower-body dominant ({upper_lower_ratio}:1) — consider adding more upper-body work."
        )

    # Check individual muscle frequency
    for mf in muscle_frequencies:
        if mf["sessions_per_week"] >= 5 and period_days >= 7:
            imbalances.append(
                f"{mf['muscle_group']} trained {mf['sessions_per_week']}x/week — "
                "may exceed recovery capacity."
            )

    return BodyPartBalanceResponse(
        push_pull_ratio=push_pull_ratio,
        push_pull_status=push_pull_status,
        upper_lower_ratio=upper_lower_ratio,
        upper_lower_status=upper_lower_status,
        muscle_frequencies=muscle_frequencies,
        imbalances=imbalances,
    )
