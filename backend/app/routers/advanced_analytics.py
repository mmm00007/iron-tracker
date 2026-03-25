"""Advanced analytics endpoints providing deep training insights.

All endpoints require authentication and return rich analytics data
computed server-side from the user's training history.
"""

import asyncio

import asyncpg
from fastapi import APIRouter, Depends, HTTPException, Query, Request

from app.auth import get_current_user
from app.models.schemas import (
    ACWRResponse,
    AdvancedAnalyticsDashboard,
    BodyPartBalanceResponse,
    ConsistencyResponse,
    ExerciseVarietyResponse,
    FitnessFatigueResponse,
    MuscleWorkloadResponse,
    PerformanceForecastResponse,
    PeriodizationResponse,
    ProgressiveOverloadResponse,
    RecoveryResponse,
    SessionQualityResponse,
    StrengthStandardsResponse,
    VolumeLandmarksResponse,
)
from app.services.acwr_service import compute_acwr
from app.services.consistency_service import compute_consistency
from app.services.exercise_variety_service import compute_exercise_variety
from app.services.fitness_fatigue_service import compute_fitness_fatigue
from app.services.muscle_workload_service import compute_muscle_workload
from app.services.performance_forecast_service import compute_performance_forecast
from app.services.periodization_service import (
    compute_body_part_balance,
    compute_periodization,
)
from app.services.progressive_overload_service import compute_progressive_overload
from app.services.recovery_service import compute_recovery
from app.services.session_quality_service import compute_session_quality
from app.services.strength_standards_service import compute_strength_standards
from app.services.volume_landmarks_service import compute_volume_landmarks

router = APIRouter(prefix="/api/analytics/advanced", tags=["advanced-analytics"])


def _get_db_pool(request: Request) -> asyncpg.Pool:
    pool = request.app.state.db_pool
    if pool is None:
        raise HTTPException(status_code=503, detail="Database unavailable")
    return pool


# ─── Individual endpoints ────────────────────────────────────────────────────


@router.get("/muscle-workload", response_model=MuscleWorkloadResponse)
async def get_muscle_workload(
    period: int = Query(default=7, ge=1, le=365, description="Period in days"),
    user_id: str = Depends(get_current_user),
    db_pool: asyncpg.Pool = Depends(_get_db_pool),
) -> MuscleWorkloadResponse:
    """Weighted muscle workload analysis with balance scoring.

    Shows volume distribution across muscle groups with primary/secondary
    weighting, baseline normalization, and Shannon entropy balance index.
    """
    return await compute_muscle_workload(user_id, db_pool, period_days=period)


@router.get("/progressive-overload", response_model=ProgressiveOverloadResponse)
async def get_progressive_overload(
    weeks: int = Query(default=8, ge=3, le=52, description="Lookback weeks"),
    user_id: str = Depends(get_current_user),
    db_pool: asyncpg.Pool = Depends(_get_db_pool),
) -> ProgressiveOverloadResponse:
    """Per-exercise progressive overload analysis.

    Computes overload rate (kg/week via linear regression on e1RM),
    detects plateaus (stagnant e1RM), and classifies each exercise as
    progressing, plateau, or regressing.
    """
    return await compute_progressive_overload(user_id, db_pool, weeks=weeks)


@router.get("/volume-landmarks", response_model=VolumeLandmarksResponse)
async def get_volume_landmarks(
    user_id: str = Depends(get_current_user),
    db_pool: asyncpg.Pool = Depends(_get_db_pool),
) -> VolumeLandmarksResponse:
    """Weekly set volume vs research-based volume landmarks per muscle.

    Compares current weekly sets against MV (Maintenance), MEV (Minimum
    Effective), MAV (Maximum Adaptive), and MRV (Maximum Recoverable)
    thresholds from Renaissance Periodization research.
    """
    return await compute_volume_landmarks(user_id, db_pool)


@router.get("/recovery", response_model=RecoveryResponse)
async def get_recovery(
    user_id: str = Depends(get_current_user),
    db_pool: asyncpg.Pool = Depends(_get_db_pool),
) -> RecoveryResponse:
    """Per-muscle recovery status and overall readiness score.

    Combines training recency, volume, and soreness reports to estimate
    recovery status for each muscle group and compute an overall
    readiness score (0-100).
    """
    return await compute_recovery(user_id, db_pool)


@router.get("/session-quality", response_model=SessionQualityResponse)
async def get_session_quality(
    period: int = Query(default=7, ge=1, le=365, description="Period in days"),
    user_id: str = Depends(get_current_user),
    db_pool: asyncpg.Pool = Depends(_get_db_pool),
) -> SessionQualityResponse:
    """Training quality metrics: intensity, effective volume, junk volume.

    Analyzes set type distribution, average RPE/RIR, relative intensity
    (% of 1RM), effective volume (sets near failure), and junk volume
    (low-stimulus non-warmup sets).
    """
    return await compute_session_quality(user_id, db_pool, period_days=period)


@router.get("/periodization", response_model=PeriodizationResponse)
async def get_periodization(
    weeks: int = Query(default=8, ge=4, le=52, description="Lookback weeks"),
    user_id: str = Depends(get_current_user),
    db_pool: asyncpg.Pool = Depends(_get_db_pool),
) -> PeriodizationResponse:
    """Training periodization analysis.

    Computes weekly volume trends, Foster's training monotony and strain,
    and detects the current mesocycle phase (building/maintaining/deloading).
    """
    return await compute_periodization(user_id, db_pool, weeks=weeks)


@router.get("/body-part-balance", response_model=BodyPartBalanceResponse)
async def get_body_part_balance(
    period: int = Query(default=7, ge=1, le=365, description="Period in days"),
    user_id: str = Depends(get_current_user),
    db_pool: asyncpg.Pool = Depends(_get_db_pool),
) -> BodyPartBalanceResponse:
    """Push/pull and upper/lower volume balance analysis.

    Evaluates volume ratios between push and pull muscle groups,
    upper and lower body, and per-muscle training frequency.
    Flags significant imbalances that may increase injury risk.
    """
    return await compute_body_part_balance(user_id, db_pool, period_days=period)


# ─── New analytics endpoints ────────────────────────────────────────────────


@router.get("/acwr", response_model=ACWRResponse)
async def get_acwr(
    user_id: str = Depends(get_current_user),
    db_pool: asyncpg.Pool = Depends(_get_db_pool),
) -> ACWRResponse:
    """Acute:Chronic Workload Ratio for injury risk monitoring.

    Compares acute load (7-day EWMA) against chronic load (28-day EWMA).
    The ACWR sweet spot is 0.8-1.3; values above 1.5 indicate high
    injury risk from training spikes (Gabbett 2016).
    """
    return await compute_acwr(user_id, db_pool)


@router.get("/consistency", response_model=ConsistencyResponse)
async def get_consistency(
    weeks: int = Query(default=12, ge=4, le=52, description="Lookback weeks"),
    user_id: str = Depends(get_current_user),
    db_pool: asyncpg.Pool = Depends(_get_db_pool),
) -> ConsistencyResponse:
    """Training consistency and streak analysis.

    Tracks weekly training frequency, current and longest streaks,
    consistency score, and training regularity index (how predictable
    the training schedule is).
    """
    return await compute_consistency(user_id, db_pool, weeks=weeks)


@router.get("/strength-standards", response_model=StrengthStandardsResponse)
async def get_strength_standards(
    weeks: int = Query(default=12, ge=4, le=52, description="Lookback weeks"),
    user_id: str = Depends(get_current_user),
    db_pool: asyncpg.Pool = Depends(_get_db_pool),
) -> StrengthStandardsResponse:
    """Benchmark lifts against population strength standards.

    Classifies each benchmarkable exercise as beginner/novice/intermediate/
    advanced/elite based on estimated 1RM vs population norms.
    """
    return await compute_strength_standards(user_id, db_pool, weeks=weeks)


@router.get("/exercise-variety", response_model=ExerciseVarietyResponse)
async def get_exercise_variety(
    period: int = Query(default=28, ge=7, le=365, description="Period in days"),
    user_id: str = Depends(get_current_user),
    db_pool: asyncpg.Pool = Depends(_get_db_pool),
) -> ExerciseVarietyResponse:
    """Exercise variety and movement pattern analysis.

    Measures training diversity via Shannon entropy on exercise selection,
    maps exercises to fundamental movement patterns, and identifies
    missing patterns for balanced programming.
    """
    return await compute_exercise_variety(user_id, db_pool, period_days=period)


@router.get("/performance-forecast", response_model=PerformanceForecastResponse)
async def get_performance_forecast(
    weeks: int = Query(default=12, ge=4, le=52, description="Lookback weeks"),
    user_id: str = Depends(get_current_user),
    db_pool: asyncpg.Pool = Depends(_get_db_pool),
) -> PerformanceForecastResponse:
    """Strength forecasting via 1RM trend extrapolation.

    Projects future 1RM values at 4, 8, and 12 weeks based on linear
    regression of daily best e1RM. Includes R²-based confidence scoring
    and milestone predictions for compound lifts.
    """
    return await compute_performance_forecast(user_id, db_pool, weeks=weeks)


@router.get("/fitness-fatigue", response_model=FitnessFatigueResponse)
async def get_fitness_fatigue(
    user_id: str = Depends(get_current_user),
    db_pool: asyncpg.Pool = Depends(_get_db_pool),
) -> FitnessFatigueResponse:
    """Banister fitness-fatigue impulse-response model.

    Decomposes training response into fitness (slow-decaying adaptation)
    and fatigue (fast-decaying stress). Preparedness = Fitness - Fatigue.
    More scientifically grounded than simple recovery-hours estimates.
    """
    return await compute_fitness_fatigue(user_id, db_pool)


# ─── Aggregated dashboard ───────────────────────────────────────────────────


@router.get("/dashboard", response_model=AdvancedAnalyticsDashboard)
async def get_dashboard(
    period: int = Query(default=7, ge=1, le=365, description="Period in days"),
    user_id: str = Depends(get_current_user),
    db_pool: asyncpg.Pool = Depends(_get_db_pool),
) -> AdvancedAnalyticsDashboard:
    """Comprehensive analytics dashboard aggregating all advanced metrics.

    Runs all analytics queries in parallel for optimal performance.
    Uses return_exceptions=True so one failing metric doesn't break the
    entire dashboard — failed metrics get empty defaults.
    """
    # Original 7 metrics + 6 new metrics, all in parallel
    results = await asyncio.gather(
        compute_muscle_workload(user_id, db_pool, period_days=period),
        compute_progressive_overload(user_id, db_pool, weeks=max(period // 7, 3)),
        compute_volume_landmarks(user_id, db_pool),
        compute_recovery(user_id, db_pool),
        compute_session_quality(user_id, db_pool, period_days=period),
        compute_periodization(user_id, db_pool, weeks=max(period // 7, 4)),
        compute_body_part_balance(user_id, db_pool, period_days=period),
        compute_acwr(user_id, db_pool),
        compute_consistency(user_id, db_pool, weeks=max(period // 7, 4)),
        compute_strength_standards(user_id, db_pool, weeks=max(period // 7, 4)),
        compute_exercise_variety(user_id, db_pool, period_days=max(period, 28)),
        compute_performance_forecast(user_id, db_pool, weeks=max(period // 7, 4)),
        compute_fitness_fatigue(user_id, db_pool),
        return_exceptions=True,
    )

    # Fall back to empty defaults if any individual metric fails
    defaults = [
        MuscleWorkloadResponse(
            muscles=[],
            balance_index=0,
            balance_label="error",
            period_days=period,
        ),
        ProgressiveOverloadResponse(
            exercises=[],
            overall_status="error",
            progressing_count=0,
            plateau_count=0,
            regressing_count=0,
        ),
        VolumeLandmarksResponse(
            muscles=[],
            total_weekly_sets=0,
            muscles_over_mrv=0,
            muscles_below_mev=0,
        ),
        RecoveryResponse(
            readiness_score=0,
            readiness_label="error",
            muscles=[],
            disclaimer="",
        ),
        SessionQualityResponse(
            avg_rpe=None,
            avg_rir=None,
            relative_intensity=None,
            effective_sets=0,
            total_working_sets=0,
            effective_ratio=None,
            low_stimulus_sets=0,
            set_distribution=[],
            period_days=period,
        ),
        PeriodizationResponse(
            weekly_volumes=[],
            monotony=None,
            strain=None,
            monotony_status="error",
            current_phase="unknown",
            volume_trend_pct=None,
        ),
        BodyPartBalanceResponse(
            push_pull_ratio=None,
            push_pull_status="error",
            upper_lower_ratio=None,
            upper_lower_status="error",
            muscle_frequencies=[],
            imbalances=[],
        ),
        None,  # acwr
        None,  # consistency
        None,  # strength_standards
        None,  # exercise_variety
        None,  # performance_forecast
        None,  # fitness_fatigue
    ]

    resolved = [
        default if isinstance(result, BaseException) else result
        for result, default in zip(results, defaults)
    ]

    return AdvancedAnalyticsDashboard(
        muscle_workload=resolved[0],
        progressive_overload=resolved[1],
        volume_landmarks=resolved[2],
        recovery=resolved[3],
        session_quality=resolved[4],
        periodization=resolved[5],
        body_part_balance=resolved[6],
        acwr=resolved[7],
        consistency=resolved[8],
        strength_standards=resolved[9],
        exercise_variety=resolved[10],
        performance_forecast=resolved[11],
        fitness_fatigue=resolved[12],
    )
