"""Session quality metrics: intensity profile, effective volume, junk volume."""

from datetime import UTC, datetime, timedelta

import asyncpg

from app.models.schemas import SessionQualityResponse, SetTypeDistribution


async def compute_session_quality(
    user_id: str,
    db_pool: asyncpg.Pool,
    period_days: int = 7,
) -> SessionQualityResponse:
    """Compute session quality metrics for the given period.

    Metrics:
    - Set type distribution (warmup/working/top/drop/backoff/failure)
    - Average RPE and RIR across working sets
    - Relative intensity: avg weight used as % of exercise's estimated 1RM
    - Effective volume: sets at RPE >= 7 (sufficient stimulus)
    - Low-stimulus sets: non-warmup sets at RPE < 4 (insufficient stimulus for adaptation)
    """
    since = datetime.now(UTC) - timedelta(days=period_days)

    async with db_pool.acquire() as conn:
        rows = await conn.fetch(
            """
            SELECT
                s.set_type,
                s.rpe,
                s.rir,
                s.weight,
                s.reps,
                s.estimated_1rm
            FROM sets s
            WHERE s.user_id = $1
              AND s.logged_at >= $2
              AND s.weight > 0
              AND s.reps > 0
            """,
            user_id,
            since,
        )

    if not rows:
        return SessionQualityResponse(
            avg_rpe=None,
            avg_rir=None,
            relative_intensity=None,
            effective_sets=0,
            total_working_sets=0,
            effective_ratio=None,
            low_stimulus_sets=0,
            set_distribution=[],
            period_days=period_days,
        )

    # Set type distribution
    type_counts: dict[str, int] = {}
    total_sets = len(rows)
    for row in rows:
        st = row["set_type"] or "working"
        type_counts[st] = type_counts.get(st, 0) + 1

    distribution = [
        SetTypeDistribution(
            set_type=st,
            count=count,
            percentage=round(count / total_sets * 100, 1),
        )
        for st, count in sorted(type_counts.items(), key=lambda x: -x[1])
    ]

    # RPE/RIR averages (working sets only)
    working_types = {"working", "amrap", "dropset", "backoff", "failure"}
    working_rpes: list[float] = []
    working_rirs: list[float] = []
    for row in rows:
        st = row["set_type"] or "working"
        if st in working_types:
            if row["rpe"] is not None:
                working_rpes.append(float(row["rpe"]))
            if row["rir"] is not None:
                working_rirs.append(float(row["rir"]))

    avg_rpe = round(sum(working_rpes) / len(working_rpes), 1) if working_rpes else None
    avg_rir = round(sum(working_rirs) / len(working_rirs), 1) if working_rirs else None

    # Relative intensity: avg (weight / e1RM) for sets with estimated_1rm
    rel_intensities: list[float] = []
    for row in rows:
        e1rm = row["estimated_1rm"]
        if e1rm and float(e1rm) > 0:
            rel_intensities.append(float(row["weight"]) / float(e1rm) * 100)

    relative_intensity = (
        round(sum(rel_intensities) / len(rel_intensities), 1) if rel_intensities else None
    )

    # Effective volume: working sets at RPE >= 7
    effective_sets = 0
    total_working_sets = 0
    low_stimulus_sets = 0

    for row in rows:
        st = row["set_type"] or "working"
        if st in working_types:
            total_working_sets += 1
            rpe = row["rpe"]
            if rpe is not None and float(rpe) >= 7:
                effective_sets += 1

        # Low-stimulus sets: non-warmup, non-backoff sets at RPE < 4
        # Threshold lowered to <4 per sports medicine expert (RPE 4-6 can be
        # deliberate technique work). Backoff sets are excluded.
        if st not in ("warmup", "backoff") and row["rpe"] is not None and float(row["rpe"]) < 4:
            low_stimulus_sets += 1

    effective_ratio = (
        round(effective_sets / total_working_sets, 2) if total_working_sets > 0 else None
    )

    return SessionQualityResponse(
        avg_rpe=avg_rpe,
        avg_rir=avg_rir,
        relative_intensity=relative_intensity,
        effective_sets=effective_sets,
        total_working_sets=total_working_sets,
        effective_ratio=effective_ratio,
        low_stimulus_sets=low_stimulus_sets,
        set_distribution=distribution,
        period_days=period_days,
    )
