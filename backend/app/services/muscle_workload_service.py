"""Muscle workload analysis with weighted contributions and balance scoring."""

import math
from datetime import UTC, datetime, timedelta

import asyncpg

from app.models.schemas import (
    MuscleWorkloadEntry,
    MuscleWorkloadResponse,
)

# ─── Muscle baseline coefficients ────────────────────────────────────────────
# Relative expected volume per muscle group for an intermediate lifter.
# Used to normalize raw volume so that higher-capacity muscles (legs, back)
# don't dominate the balance index. Based on Renaissance Periodization
# and general training volume literature.

MUSCLE_BASELINES: dict[str, float] = {
    "Chest": 1.0,
    "Lats": 1.0,
    "Trapezius": 0.5,
    "Shoulders": 0.8,
    "Biceps": 0.55,
    "Triceps": 0.65,
    "Quadriceps": 1.0,
    "Hamstrings": 0.8,
    "Glutes": 1.0,
    "Calves": 0.5,
    "Abdominals": 0.6,
    "Forearms": 0.45,
    "Lower Back": 0.5,
    "Obliques": 0.5,
}

# Minimum sessions before we trust the normalized score.
# Below this, we shrink the score toward 1.0 (neutral).
MIN_SESSIONS_FOR_SCOPE: dict[str, int] = {
    "week": 1,
    "month": 2,
    "3months": 3,
    "all": 3,
}


def _balance_label(index: float) -> str:
    if index >= 0.85:
        return "well_balanced"
    if index >= 0.65:
        return "moderate"
    if index >= 0.45:
        return "imbalanced"
    return "very_imbalanced"


async def compute_muscle_workload(
    user_id: str,
    db_pool: asyncpg.Pool,
    period_days: int = 7,
) -> MuscleWorkloadResponse:
    """Compute weighted muscle workload with balance scoring.

    Each set's volume (weight × reps) is distributed across muscles:
    - Primary muscles receive 100% of volume
    - Secondary muscles receive 50% of volume

    Returns normalized scores, balance index (Shannon entropy), and
    per-muscle breakdown.
    """
    since = datetime.now(UTC) - timedelta(days=period_days)
    scope_key = (
        "week"
        if period_days <= 7
        else "month"
        if period_days <= 31
        else "3months"
        if period_days <= 93
        else "all"
    )
    min_sessions = MIN_SESSIONS_FOR_SCOPE[scope_key]

    async with db_pool.acquire() as conn:
        rows = await conn.fetch(
            """
            SELECT
                mg.name                     AS muscle_group,
                em.is_primary,
                s.weight * s.reps           AS set_volume,
                DATE(s.logged_at)           AS training_date
            FROM sets s
            JOIN exercise_muscles em ON em.exercise_id = s.exercise_id
            JOIN muscle_groups mg    ON mg.id = em.muscle_group_id
            WHERE s.user_id = $1
              AND s.logged_at >= $2
              AND s.weight > 0
              AND s.reps > 0
            ORDER BY mg.name
            """,
            user_id,
            since,
        )

    # Aggregate per muscle group
    muscle_data: dict[str, dict] = {}
    for row in rows:
        name = row["muscle_group"]
        if name not in muscle_data:
            muscle_data[name] = {
                "raw_volume": 0.0,
                "dates": set(),
                "set_count": 0.0,
            }
        weight_factor = 1.0 if row["is_primary"] else 0.5
        muscle_data[name]["raw_volume"] += float(row["set_volume"]) * weight_factor
        muscle_data[name]["dates"].add(row["training_date"])
        muscle_data[name]["set_count"] += weight_factor

    if not muscle_data:
        return MuscleWorkloadResponse(
            muscles=[],
            balance_index=0.0,
            balance_label="insufficient_data",
            period_days=period_days,
        )

    # Compute global median volume for normalization
    volumes = [d["raw_volume"] for d in muscle_data.values()]
    sorted_vols = sorted(volumes)
    mid = len(sorted_vols) // 2
    global_median = (
        sorted_vols[mid]
        if len(sorted_vols) % 2 == 1
        else (sorted_vols[mid - 1] + sorted_vols[mid]) / 2
    )
    if global_median == 0:
        global_median = 1.0

    # Build entries with normalization and sparse-data shrinkage
    entries: list[MuscleWorkloadEntry] = []
    for name, data in sorted(muscle_data.items()):
        baseline = MUSCLE_BASELINES.get(name, 0.8)
        sessions = len(data["dates"])
        raw_score = data["raw_volume"] / (baseline * global_median)

        # Shrink toward 1.0 when data is sparse
        if sessions < min_sessions:
            shrinkage = sessions / min_sessions
            raw_score = 1.0 + (raw_score - 1.0) * shrinkage

        weeks = max(period_days / 7, 1)
        entries.append(
            MuscleWorkloadEntry(
                muscle_group=name,
                raw_volume=round(data["raw_volume"], 1),
                normalized_score=round(raw_score, 2),
                weekly_sets=round(data["set_count"] / weeks, 1),
                sessions=sessions,
            )
        )

    # Shannon entropy for balance index
    total_vol = sum(e.raw_volume for e in entries)
    if total_vol > 0 and len(entries) > 1:
        proportions = [e.raw_volume / total_vol for e in entries]
        entropy = -sum(p * math.log(p) for p in proportions if p > 0)
        max_entropy = math.log(len(entries))
        balance_index = round(entropy / max_entropy, 3) if max_entropy > 0 else 0.0
    else:
        balance_index = 0.0

    return MuscleWorkloadResponse(
        muscles=entries,
        balance_index=balance_index,
        balance_label=_balance_label(balance_index),
        period_days=period_days,
    )
