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
    BilateralAsymmetryResponse,
    BodyCompositionResponse,
    BodyPartBalanceResponse,
    CompositeScoreResponse,
    ConsistencyResponse,
    ExerciseVarietyResponse,
    FitnessFatigueResponse,
    LoadDistributionResponse,
    MuscleFrequencyResponse,
    MuscleWorkloadResponse,
    PerformanceForecastResponse,
    PeriodizationResponse,
    ProgressiveOverloadResponse,
    RecoveryResponse,
    RelativeStrengthResponse,
    RestAnalysisResponse,
    SessionQualityResponse,
    SleepPerformanceResponse,
    StalenessResponse,
    StrengthStandardsResponse,
    TimePerformanceResponse,
    TrainingDensityResponse,
    VolumeLandmarksResponse,
)
from app.services.acwr_service import compute_acwr
from app.services.bilateral_asymmetry_service import compute_bilateral_asymmetry
from app.services.body_composition_service import compute_body_composition
from app.services.composite_score_service import compute_composite_score
from app.services.consistency_service import compute_consistency
from app.services.exercise_variety_service import compute_exercise_variety
from app.services.fitness_fatigue_service import compute_fitness_fatigue
from app.services.load_distribution_service import compute_load_distribution
from app.services.muscle_frequency_service import compute_muscle_frequency
from app.services.muscle_workload_service import compute_muscle_workload
from app.services.performance_forecast_service import compute_performance_forecast
from app.services.periodization_service import (
    compute_body_part_balance,
    compute_periodization,
)
from app.services.progressive_overload_service import compute_progressive_overload
from app.services.recovery_service import compute_recovery
from app.services.relative_strength_service import compute_relative_strength
from app.services.rest_analysis_service import compute_rest_analysis
from app.services.session_quality_service import compute_session_quality
from app.services.sleep_performance_service import compute_sleep_performance
from app.services.staleness_service import compute_staleness
from app.services.strength_standards_service import compute_strength_standards
from app.services.time_performance_service import compute_time_performance
from app.services.training_density_service import compute_training_density
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


@router.get("/composite-score", response_model=CompositeScoreResponse)
async def get_composite_score(
    period: int = Query(default=28, ge=7, le=365, description="Period in days"),
    user_id: str = Depends(get_current_user),
    db_pool: asyncpg.Pool = Depends(_get_db_pool),
) -> CompositeScoreResponse:
    """Single 0-100 composite training quality score.

    Aggregates consistency, progressive overload, volume adequacy,
    recovery, balance, and session quality into one actionable number.
    """
    return await compute_composite_score(user_id, db_pool, period_days=period)


@router.get("/muscle-frequency", response_model=MuscleFrequencyResponse)
async def get_muscle_frequency(
    weeks: int = Query(default=4, ge=2, le=52, description="Lookback weeks"),
    user_id: str = Depends(get_current_user),
    db_pool: asyncpg.Pool = Depends(_get_db_pool),
) -> MuscleFrequencyResponse:
    """Per-muscle training frequency vs evidence-based targets.

    Compares actual weekly frequency per muscle group against optimal
    ranges from Schoenfeld (2016) meta-analysis and NSCA guidelines.
    """
    return await compute_muscle_frequency(user_id, db_pool, weeks=weeks)


@router.get("/staleness", response_model=StalenessResponse)
async def get_staleness(
    weeks: int = Query(default=4, ge=2, le=52, description="Lookback weeks"),
    user_id: str = Depends(get_current_user),
    db_pool: asyncpg.Pool = Depends(_get_db_pool),
) -> StalenessResponse:
    """Workout staleness and exercise rotation detection.

    Uses Jaccard similarity between consecutive workouts to detect
    when exercise selection becomes too repetitive.
    """
    return await compute_staleness(user_id, db_pool, weeks=weeks)


@router.get("/load-distribution", response_model=LoadDistributionResponse)
async def get_load_distribution(
    weeks: int = Query(default=4, ge=2, le=52, description="Lookback weeks"),
    user_id: str = Depends(get_current_user),
    db_pool: asyncpg.Pool = Depends(_get_db_pool),
) -> LoadDistributionResponse:
    """Training load distribution across the week.

    Analyzes how evenly volume is spread across training days.
    Flags concentrated or poorly distributed loading patterns.
    """
    return await compute_load_distribution(user_id, db_pool, weeks=weeks)


# ─── Deep insight endpoints ─────────────────���──────────────────────────────


@router.get("/bilateral-asymmetry", response_model=BilateralAsymmetryResponse)
async def get_bilateral_asymmetry(
    period: int = Query(default=90, ge=7, le=365, description="Period in days"),
    user_id: str = Depends(get_current_user),
    db_pool: asyncpg.Pool = Depends(_get_db_pool),
) -> BilateralAsymmetryResponse:
    """Bilateral strength asymmetry detection using Limb Symmetry Index.

    Compares left vs right e1RM and volume for unilateral exercises.
    Uses the LSI formula (weaker/stronger × 100) with thresholds from
    Knapik et al. (1991) and Bishop et al. (2018).
    """
    return await compute_bilateral_asymmetry(user_id, db_pool, period_days=period)


@router.get("/body-composition", response_model=BodyCompositionResponse)
async def get_body_composition(
    period: int = Query(default=90, ge=7, le=365, description="Period in days"),
    user_id: str = Depends(get_current_user),
    db_pool: asyncpg.Pool = Depends(_get_db_pool),
) -> BodyCompositionResponse:
    """Body composition analytics: BMI, FFMI, weight trends.

    Computes BMI, Fat-Free Mass Index (Kouri et al. 1995 normalized),
    7-day EMA weight trend, and body fat tracking. FFMI is the preferred
    metric for trained individuals over BMI.
    """
    return await compute_body_composition(user_id, db_pool, period_days=period)


@router.get("/training-density", response_model=TrainingDensityResponse)
async def get_training_density(
    period: int = Query(default=28, ge=7, le=365, description="Period in days"),
    user_id: str = Depends(get_current_user),
    db_pool: asyncpg.Pool = Depends(_get_db_pool),
) -> TrainingDensityResponse:
    """Training density and efficiency metrics.

    Computes effective sets per hour and volume per minute per session.
    Tracks density trends over time via linear regression.
    """
    return await compute_training_density(user_id, db_pool, period_days=period)


@router.get("/sleep-performance", response_model=SleepPerformanceResponse)
async def get_sleep_performance(
    period: int = Query(default=90, ge=7, le=365, description="Period in days"),
    user_id: str = Depends(get_current_user),
    db_pool: asyncpg.Pool = Depends(_get_db_pool),
) -> SleepPerformanceResponse:
    """Sleep-performance correlation analysis.

    Computes Spearman rank correlations between self-reported sleep
    metrics and training performance. Includes bucket analysis
    (poor/fair/good/excellent) for actionable insights.
    """
    return await compute_sleep_performance(user_id, db_pool, period_days=period)


@router.get("/time-performance", response_model=TimePerformanceResponse)
async def get_time_performance(
    period: int = Query(default=90, ge=7, le=365, description="Period in days"),
    user_id: str = Depends(get_current_user),
    db_pool: asyncpg.Pool = Depends(_get_db_pool),
) -> TimePerformanceResponse:
    """Time-of-day performance analysis.

    Analyzes training performance across four time windows
    (morning/afternoon/evening/night) using circadian rhythm
    research as context (Chtourou & Souissi, 2012).
    """
    return await compute_time_performance(user_id, db_pool, period_days=period)


@router.get("/rest-analysis", response_model=RestAnalysisResponse)
async def get_rest_analysis(
    period: int = Query(default=28, ge=7, le=365, description="Period in days"),
    user_id: str = Depends(get_current_user),
    db_pool: asyncpg.Pool = Depends(_get_db_pool),
) -> RestAnalysisResponse:
    """Rest period distribution and analysis.

    Analyzes rest periods segmented by exercise mechanic
    (compound/isolation) against NSCA-recommended ranges.
    Includes weekly trend tracking and safety flags.
    """
    return await compute_rest_analysis(user_id, db_pool, period_days=period)


@router.get("/relative-strength", response_model=RelativeStrengthResponse)
async def get_relative_strength(
    period: int = Query(default=90, ge=7, le=365, description="Period in days"),
    user_id: str = Depends(get_current_user),
    db_pool: asyncpg.Pool = Depends(_get_db_pool),
) -> RelativeStrengthResponse:
    """Relative strength tracking using DOTS scores.

    Computes IPF DOTS scores (2019) and simple bodyweight ratios
    for benchmarkable compound lifts. Tracks relative strength
    over time as bodyweight changes.
    """
    return await compute_relative_strength(user_id, db_pool, period_days=period)


# ─── Aggregated dashboard ──────────���─────────────────────────────────────��──


@router.get("/dashboard", response_model=AdvancedAnalyticsDashboard)
async def get_dashboard(
    period: int = Query(default=7, ge=1, le=365, description="Period in days"),
    user_id: str = Depends(get_current_user),
    db_pool: asyncpg.Pool = Depends(_get_db_pool),
) -> AdvancedAnalyticsDashboard:
    """Comprehensive analytics dashboard aggregating all 24 advanced metrics.

    Runs all analytics queries in parallel for optimal performance.
    Uses return_exceptions=True so one failing metric doesn't break the
    entire dashboard — failed metrics get empty defaults.
    """
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
        compute_composite_score(user_id, db_pool, period_days=max(period, 28)),
        compute_muscle_frequency(user_id, db_pool, weeks=max(period // 7, 2)),
        compute_staleness(user_id, db_pool, weeks=max(period // 7, 2)),
        compute_load_distribution(user_id, db_pool, weeks=max(period // 7, 2)),
        # Deep insight analytics
        compute_bilateral_asymmetry(user_id, db_pool, period_days=max(period, 90)),
        compute_body_composition(user_id, db_pool, period_days=max(period, 90)),
        compute_training_density(user_id, db_pool, period_days=max(period, 28)),
        compute_sleep_performance(user_id, db_pool, period_days=max(period, 90)),
        compute_time_performance(user_id, db_pool, period_days=max(period, 90)),
        compute_rest_analysis(user_id, db_pool, period_days=max(period, 28)),
        compute_relative_strength(user_id, db_pool, period_days=max(period, 90)),
        return_exceptions=True,
    )

    defaults = [
        MuscleWorkloadResponse(
            muscles=[], balance_index=0, balance_label="error", period_days=period,
        ),
        ProgressiveOverloadResponse(
            exercises=[], overall_status="error",
            progressing_count=0, plateau_count=0, regressing_count=0,
        ),
        VolumeLandmarksResponse(
            muscles=[], total_weekly_sets=0, muscles_over_mrv=0, muscles_below_mev=0,
        ),
        RecoveryResponse(
            readiness_score=0, readiness_label="error", muscles=[], disclaimer="",
        ),
        SessionQualityResponse(
            avg_rpe=None, avg_rir=None, relative_intensity=None,
            effective_sets=0, total_working_sets=0, effective_ratio=None,
            low_stimulus_sets=0, set_distribution=[], period_days=period,
        ),
        PeriodizationResponse(
            weekly_volumes=[], monotony=None, strain=None,
            monotony_status="error", current_phase="unknown", volume_trend_pct=None,
        ),
        BodyPartBalanceResponse(
            push_pull_ratio=None, push_pull_status="error",
            upper_lower_ratio=None, upper_lower_status="error",
            muscle_frequencies=[], imbalances=[],
        ),
        None, None, None, None, None, None,  # acwr..fitness_fatigue
        None, None, None, None,  # composite..load_distribution
        None, None, None, None, None, None, None,  # 7 deep insight analytics
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
        composite_score=resolved[13],
        muscle_frequency=resolved[14],
        staleness=resolved[15],
        load_distribution=resolved[16],
        bilateral_asymmetry=resolved[17],
        body_composition=resolved[18],
        training_density=resolved[19],
        sleep_performance=resolved[20],
        time_performance=resolved[21],
        rest_analysis=resolved[22],
        relative_strength=resolved[23],
    )
