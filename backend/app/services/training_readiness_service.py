"""Training Readiness Score — composite readiness from multiple fatigue dimensions.

Combines five data sources into a single 0-100 readiness score:
  1. Sleep (weight 0.30): self-reported sleep quality and hours from workout feedback
  2. Soreness (weight 0.20): max active soreness from last 72 hours
  3. Recovery (weight 0.20): per-muscle recovery readiness from recovery_service
  4. ACWR (weight 0.15): acute:chronic workload ratio from acwr_service
  5. Fitness-Fatigue (weight 0.15): Banister model preparedness from fitness_fatigue_service

Missing dimensions are handled via proportional weight redistribution so the score
degrades gracefully when data is incomplete. With zero available dimensions the
score defaults to 75 (neutral).

Algorithm validated by data science expert.
"""

import asyncio

import asyncpg

from app.models.schemas import ReadinessDimension, TrainingReadinessResponse
from app.services.acwr_service import compute_acwr
from app.services.fitness_fatigue_service import compute_fitness_fatigue
from app.services.recovery_service import compute_recovery

# ─── Dimension weights ──────────────────────────────────────────────────────

WEIGHTS = {
    "sleep": 0.30,
    "soreness": 0.20,
    "recovery": 0.20,
    "acwr": 0.15,
    "fitness_fatigue": 0.15,
}

DISCLAIMER = (
    "This readiness score reflects recent training load, sleep, and recovery "
    "data. It is not medical advice. A low score suggests accumulated fatigue "
    "— consider adjusting session intensity, not necessarily skipping training."
)

_RECOMMENDATIONS = {
    "ready": "Good to train. Your recovery indicators look favorable.",
    "moderate": "Moderate readiness. Consider a standard session.",
    "fatigued": (
        "Elevated fatigue detected. Consider reducing intensity or volume today."
    ),
    "rest_recommended": (
        "Multiple fatigue indicators are elevated. A rest day or light active "
        "recovery session is suggested."
    ),
}


# ─── Lightweight DB helpers ─────────────────────────────────────────────────


async def _fetch_latest_feedback(
    user_id: str, db_pool: asyncpg.Pool
) -> asyncpg.Record | None:
    """Return the most recent workout feedback row (sleep + stress)."""
    async with db_pool.acquire() as conn:
        return await conn.fetchrow(
            """
            SELECT prior_sleep_quality, sleep_hours, stress_level
            FROM workout_feedback
            WHERE user_id = $1
            ORDER BY training_date DESC
            LIMIT 1
            """,
            user_id,
        )


async def _fetch_max_soreness(user_id: str, db_pool: asyncpg.Pool) -> int | None:
    """Return the max soreness level reported in the last 72 hours."""
    async with db_pool.acquire() as conn:
        row = await conn.fetchrow(
            """
            SELECT MAX(level) AS max_soreness
            FROM soreness_reports
            WHERE user_id = $1
              AND reported_at >= NOW() - INTERVAL '72 hours'
            """,
            user_id,
        )
    if row is None:
        return None
    val = row["max_soreness"]
    return int(val) if val is not None else None


# ─── Sub-score normalisers ──────────────────────────────────────────────────


def _sleep_score(feedback: asyncpg.Record | None) -> tuple[int | None, str]:
    """Normalise sleep data to 0-100.

    Uses a 50/50 blend of quality (1-5 Likert) and hours (capped at 9h).
    Falls back to quality-only when hours are missing.
    """
    if feedback is None:
        return None, "No recent sleep data available."

    sleep_quality: int | None = (
        int(feedback["prior_sleep_quality"])
        if feedback["prior_sleep_quality"] is not None
        else None
    )
    sleep_hours: float | None = (
        float(feedback["sleep_hours"])
        if feedback["sleep_hours"] is not None
        else None
    )

    if sleep_quality is None:
        return None, "No sleep quality reported."

    if sleep_hours is not None:
        norm = (sleep_quality / 5.0 * 0.5 + min(sleep_hours, 9) / 9.0 * 0.5) * 100
        detail = f"Quality {sleep_quality}/5, {sleep_hours:.1f}h sleep."
    else:
        norm = sleep_quality / 5.0 * 100
        detail = f"Quality {sleep_quality}/5 (hours not reported)."

    return round(norm), detail


def _soreness_score(max_soreness: int | None) -> tuple[int | None, str]:
    """Normalise soreness to 0-100 (lower soreness = higher score).

    Scale: 0 (no soreness) → 100, 4 (max) → 0.
    """
    if max_soreness is None:
        return None, "No soreness reports in the last 72 hours."

    score = round((4 - max_soreness) / 4.0 * 100)
    score = max(0, min(100, score))
    detail = f"Max soreness {max_soreness}/4 in the last 72 hours."
    return score, detail


def _acwr_score(acwr_value: float | None) -> tuple[int | None, str]:
    """Normalise ACWR ratio to 0-100.

    Sweet spot (0.8-1.3) maps to 100.
    Below 0.8 scales linearly down.
    Above 1.3 scales linearly down through the danger zone (up to 2.0).
    """
    if acwr_value is None:
        return None, "Insufficient training data for ACWR."

    if 0.8 <= acwr_value <= 1.3:
        score = 100
        detail = f"ACWR {acwr_value:.2f} — in the optimal sweet spot."
    elif acwr_value < 0.8:
        score = max(0, round(acwr_value / 0.8 * 100))
        detail = f"ACWR {acwr_value:.2f} — under-prepared, load is low."
    else:
        score = max(0, round(100 - (acwr_value - 1.3) / 0.7 * 100))
        detail = f"ACWR {acwr_value:.2f} — elevated spike risk."

    return score, detail


def _preparedness_score(preparedness: float) -> tuple[int, str]:
    """Normalise Banister preparedness to 0-100.

    Preparedness is an unbounded signed value. Map via:
      score = 50 + preparedness * 25
    clamped to [0, 100].
    """
    score = max(0, min(100, round(50 + preparedness * 25)))
    if preparedness > 0:
        detail = f"Preparedness {preparedness:.2f} — positive (supercompensating)."
    elif preparedness == 0:
        detail = "Preparedness 0.00 — neutral."
    else:
        detail = f"Preparedness {preparedness:.2f} — fatigue dominant."
    return score, detail


# ─── Composite scoring ──────────────────────────────────────────────────────


def _readiness_label(score: int) -> str:
    if score >= 80:
        return "ready"
    if score >= 60:
        return "moderate"
    if score >= 40:
        return "fatigued"
    return "rest_recommended"


def _build_composite(dimensions: list[ReadinessDimension]) -> int:
    """Weighted sum with proportional redistribution for missing dimensions."""
    available = [d for d in dimensions if d.available]
    if not available:
        return 75  # Neutral default when no data

    total_weight = sum(d.weight for d in available)
    weighted_sum = sum(d.score * (d.weight / total_weight) for d in available)
    return max(0, min(100, round(weighted_sum)))


# ─── Main entry point ───────────────────────────────────────────────────────


async def compute_training_readiness(
    user_id: str, db_pool: asyncpg.Pool
) -> TrainingReadinessResponse:
    """Compute composite training readiness from five fatigue dimensions.

    Reuses existing services (recovery, ACWR, fitness-fatigue) via
    asyncio.gather and adds two lightweight queries for sleep feedback
    and recent soreness.
    """
    # Parallel fetch of all data sources
    recovery_result, acwr_result, ff_result, feedback, max_soreness = (
        await asyncio.gather(
            compute_recovery(user_id, db_pool),
            compute_acwr(user_id, db_pool),
            compute_fitness_fatigue(user_id, db_pool),
            _fetch_latest_feedback(user_id, db_pool),
            _fetch_max_soreness(user_id, db_pool),
        )
    )

    # ── Normalise each dimension to 0-100 ──

    sleep_val, sleep_detail = _sleep_score(feedback)
    soreness_val, soreness_detail = _soreness_score(max_soreness)

    # Recovery: readiness_score is already 0-100
    recovery_val = recovery_result.readiness_score
    recovery_detail = f"Recovery readiness {recovery_val}/100 ({recovery_result.readiness_label})."

    # ACWR
    acwr_val, acwr_detail = _acwr_score(acwr_result.acwr)

    # Fitness-Fatigue preparedness
    if ff_result.preparedness_label == "insufficient_data":
        ff_val: int | None = None
        ff_detail = "Insufficient training history for fitness-fatigue model."
    else:
        ff_val, ff_detail = _preparedness_score(ff_result.preparedness)

    # ── Build dimension list ──

    dimensions = [
        ReadinessDimension(
            name="sleep",
            score=sleep_val if sleep_val is not None else 0,
            weight=WEIGHTS["sleep"],
            available=sleep_val is not None,
            detail=sleep_detail,
        ),
        ReadinessDimension(
            name="soreness",
            score=soreness_val if soreness_val is not None else 0,
            weight=WEIGHTS["soreness"],
            available=soreness_val is not None,
            detail=soreness_detail,
        ),
        ReadinessDimension(
            name="recovery",
            score=recovery_val,
            weight=WEIGHTS["recovery"],
            available=True,
            detail=recovery_detail,
        ),
        ReadinessDimension(
            name="acwr",
            score=acwr_val if acwr_val is not None else 0,
            weight=WEIGHTS["acwr"],
            available=acwr_val is not None,
            detail=acwr_detail,
        ),
        ReadinessDimension(
            name="fitness_fatigue",
            score=ff_val if ff_val is not None else 0,
            weight=WEIGHTS["fitness_fatigue"],
            available=ff_val is not None,
            detail=ff_detail,
        ),
    ]

    available_count = sum(1 for d in dimensions if d.available)
    composite = _build_composite(dimensions)
    label = _readiness_label(composite)

    return TrainingReadinessResponse(
        readiness_score=composite,
        readiness_label=label,
        dimensions=dimensions,
        available_dimensions=available_count,
        recommendation=_RECOMMENDATIONS[label],
        disclaimer=DISCLAIMER,
    )
