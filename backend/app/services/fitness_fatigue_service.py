"""Fitness-Fatigue model (Banister Impulse-Response).

The Banister model (1975, refined by Busso et al. 1997) is a bicomponent
model that decomposes training response into:

  Fitness (positive, slow-decaying adaptation)
  - Time constant: ~42 days (tau_fit)
  - Represents accumulated training adaptations

  Fatigue (negative, fast-decaying stress)
  - Time constant: ~7 days (tau_fat)
  - Represents acute fatigue that suppresses performance

  Preparedness = Fitness - Fatigue
  - When positive: athlete is in a state of supercompensation
  - When negative: fatigue dominates, performance is suppressed
  - Peak preparedness occurs 1-3 weeks after a taper

This is more scientifically grounded than simple "hours since last training"
recovery estimates, as it accounts for the cumulative effect of training
over time.

Parameters from Busso et al. (1997) and Clarke & Skiba (2013):
  tau_fitness = 42 days
  tau_fatigue = 7 days
  k_fitness = 1.0 (fitness gain per unit training impulse)
  k_fatigue = 2.0 (fatigue gain — fatigue responds more strongly but decays faster)
"""

import math
from datetime import UTC, date, datetime, timedelta

import asyncpg

from app.models.schemas import (
    FitnessFatigueResponse,
    FitnessFatigueTimePoint,
)

# Banister impulse-response model (Banister 1991, Busso 2003)
TAU_FITNESS = 42.0  # days
TAU_FATIGUE = 7.0   # days
K_FITNESS = 1.0     # fitness gain coefficient
K_FATIGUE = 2.0     # fatigue gain coefficient (higher: fatigue responds more)


def _preparedness_label(preparedness: float, fitness: float) -> str:
    """Classify preparedness state relative to fitness level.

    Uses "high_fatigue" instead of "overreached" because true overreaching
    is a clinical diagnosis requiring performance, hormonal, and mood data
    that a volume-based model cannot provide (sports medicine expert review).
    """
    if fitness < 0.01:
        return "insufficient_data"
    ratio = preparedness / fitness
    if ratio > 0.3:
        return "supercompensated"
    if ratio > 0:
        return "fresh"
    if ratio > -0.3:
        return "fatigued"
    return "high_fatigue"


def _taper_recommendation(preparedness: float, fatigue: float, fitness: float) -> str:
    """Generate taper/training recommendation based on model state."""
    if fitness <= 0:
        return "Not enough training data for recommendations."

    fatigue_ratio = fatigue / fitness if fitness > 0 else 0

    if fatigue_ratio > 0.8:
        return (
            "High fatigue accumulation detected. Consider a deload week "
            "(reduce volume by 40-60%) to allow supercompensation."
        )
    if fatigue_ratio > 0.5:
        return (
            "Moderate fatigue. Training load is sustainable but monitor "
            "recovery markers (sleep, soreness, motivation)."
        )
    if fatigue_ratio < 0.2 and fitness > 0:
        return (
            "Low fatigue relative to fitness. You have room to increase "
            "training load or add volume."
        )
    return "Training load is well-balanced relative to your fitness."


async def compute_fitness_fatigue(
    user_id: str,
    db_pool: asyncpg.Pool,
) -> FitnessFatigueResponse:
    """Compute the Banister fitness-fatigue model from training history.

    Uses the last 90 days of data to build the model. Returns daily
    fitness, fatigue, and preparedness values, plus current state
    classification and training recommendations.
    """
    lookback = datetime.now(UTC) - timedelta(days=90)

    async with db_pool.acquire() as conn:
        rows = await conn.fetch(
            """
            SELECT
                DATE(logged_at)       AS day,
                SUM(weight * reps)    AS daily_volume
            FROM sets
            WHERE user_id = $1
              AND logged_at >= $2
              AND weight > 0
              AND reps > 0
            GROUP BY DATE(logged_at)
            ORDER BY DATE(logged_at)
            """,
            user_id,
            lookback,
        )

    if not rows:
        return FitnessFatigueResponse(
            fitness=0.0,
            fatigue=0.0,
            preparedness=0.0,
            preparedness_label="insufficient_data",
            recommendation="Start logging workouts to build your fitness-fatigue profile.",
            timeline=[],
            peak_preparedness_date=None,
        )

    # Build complete daily series
    day_volumes: dict[date, float] = {row["day"]: float(row["daily_volume"]) for row in rows}
    first_day = min(day_volumes.keys())
    last_day = date.today()

    # Normalize training impulse (scale to manageable numbers)
    # Use median daily volume as the normalization factor
    vol_values = sorted(day_volumes.values())
    median_vol = vol_values[len(vol_values) // 2] if vol_values else 1.0
    if median_vol <= 0:
        median_vol = 1.0

    # Run the model day by day
    fitness = 0.0
    fatigue = 0.0
    timeline: list[FitnessFatigueTimePoint] = []
    peak_prep = float("-inf")
    peak_date: str | None = None

    current = first_day
    while current <= last_day:
        raw_vol = day_volumes.get(current, 0.0)
        # Training impulse normalized to median session
        impulse = raw_vol / median_vol

        # Exponential decay + new impulse
        decay_fit = math.exp(-1.0 / TAU_FITNESS)
        decay_fat = math.exp(-1.0 / TAU_FATIGUE)

        fitness = fitness * decay_fit + K_FITNESS * impulse
        fatigue = fatigue * decay_fat + K_FATIGUE * impulse
        preparedness = fitness - fatigue

        # Only include last 60 days in timeline to keep response size reasonable
        if (last_day - current).days <= 60:
            timeline.append(
                FitnessFatigueTimePoint(
                    date=str(current),
                    fitness=round(fitness, 2),
                    fatigue=round(fatigue, 2),
                    preparedness=round(preparedness, 2),
                    training_load=round(raw_vol),
                )
            )

        if preparedness > peak_prep and (last_day - current).days <= 60:
            peak_prep = preparedness
            peak_date = str(current)

        current += timedelta(days=1)

    label = _preparedness_label(preparedness, fitness)
    recommendation = _taper_recommendation(preparedness, fatigue, fitness)

    return FitnessFatigueResponse(
        fitness=round(fitness, 2),
        fatigue=round(fatigue, 2),
        preparedness=round(preparedness, 2),
        preparedness_label=label,
        recommendation=recommendation,
        timeline=timeline,
        peak_preparedness_date=peak_date,
        disclaimer=(
            "This model provides a theoretical estimate of training readiness "
            "based on volume data only. It does not account for sleep, nutrition, "
            "stress, illness, or injury. Always listen to your body and consult a "
            "healthcare provider if experiencing persistent fatigue, pain, or "
            "performance decline."
        ),
    )
