from typing import Annotated

from pydantic import BaseModel, ConfigDict, Field


class TargetMuscles(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    primary: list[str]
    secondary: list[str]


class MachineIdentificationResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    exercise_names: list[str]
    equipment_type: str
    manufacturer: str | None
    target_muscles: TargetMuscles
    form_tips: list[str]
    confidence: str


class WeeklySummary(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    total_sets: int
    total_volume: float
    training_days: int
    delta_sets: int | None
    delta_volume: float | None


class ExerciseE1RM(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    exercise_id: str
    date: str
    estimated_1rm: float


class AnalysisInsight(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    metric: str
    finding: str
    delta: str | None = None
    recommendation: str


class AnalysisRequest(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    scope_type: str  # 'day', 'week', 'month'
    scope_start: str  # ISO date
    scope_end: str  # ISO date
    goals: list[Annotated[str, Field(max_length=200)]] = Field(default=[], max_length=10)


class AnalysisResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    summary: str
    insights: list[AnalysisInsight]
    created_at: str


class HealthResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    status: str


# ─── Advanced Analytics Models ───────────────────────────────────────────────


class MuscleWorkloadEntry(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    muscle_group: str
    raw_volume: float
    normalized_score: float
    weekly_sets: float
    sessions: int


class MuscleWorkloadResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    muscles: list[MuscleWorkloadEntry]
    balance_index: float
    balance_label: str
    period_days: int


class ExerciseOverloadEntry(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    exercise_id: str
    exercise_name: str
    overload_rate: float
    status: str
    current_e1rm: float
    weeks_tracked: int
    plateau_weeks: int


class ProgressiveOverloadResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    exercises: list[ExerciseOverloadEntry]
    overall_status: str
    progressing_count: int
    plateau_count: int
    regressing_count: int


class MuscleLandmarkEntry(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    muscle_group: str
    current_sets: float
    mv: float
    mev: float
    mav: float
    mrv: float
    status: str
    recommendation: str


class VolumeLandmarksResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    muscles: list[MuscleLandmarkEntry]
    total_weekly_sets: float
    muscles_over_mrv: int
    muscles_below_mev: int


class MuscleRecoveryEntry(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    muscle_group: str
    hours_since_trained: float | None
    recovery_status: str
    last_soreness: int | None
    sets_last_session: int


class RecoveryResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    readiness_score: int
    readiness_label: str
    muscles: list[MuscleRecoveryEntry]
    disclaimer: str


class SetTypeDistribution(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    set_type: str
    count: int
    percentage: float


class SessionQualityResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    avg_rpe: float | None
    avg_rir: float | None
    relative_intensity: float | None
    effective_sets: int
    total_working_sets: int
    effective_ratio: float | None
    low_stimulus_sets: int
    set_distribution: list[SetTypeDistribution]
    period_days: int


class PeriodizationResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    weekly_volumes: list[dict]
    monotony: float | None
    strain: float | None
    monotony_status: str
    current_phase: str
    volume_trend_pct: float | None


class BodyPartBalanceResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    push_pull_ratio: float | None
    push_pull_status: str
    upper_lower_ratio: float | None
    upper_lower_status: str
    muscle_frequencies: list[dict]
    imbalances: list[str]


class AdvancedAnalyticsDashboard(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    muscle_workload: MuscleWorkloadResponse
    progressive_overload: ProgressiveOverloadResponse
    volume_landmarks: VolumeLandmarksResponse
    recovery: RecoveryResponse
    session_quality: SessionQualityResponse
    periodization: PeriodizationResponse
    body_part_balance: BodyPartBalanceResponse
    acwr: "ACWRResponse | None" = None
    consistency: "ConsistencyResponse | None" = None
    strength_standards: "StrengthStandardsResponse | None" = None
    exercise_variety: "ExerciseVarietyResponse | None" = None
    performance_forecast: "PerformanceForecastResponse | None" = None
    fitness_fatigue: "FitnessFatigueResponse | None" = None


# ─── ACWR Models ─────────────────────────────────────────────────────────────


class ACWRWeeklyEntry(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    week_start: str
    week_end: str
    acwr: float | None
    acute_load: float
    chronic_load: float
    weekly_volume: float


class ACWRResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    acwr: float | None
    risk_zone: str
    risk_description: str
    weekly_trend: list[ACWRWeeklyEntry]
    acute_load: float
    chronic_load: float


# ─── Consistency Models ──────────────────────────────────────────────────────


class ConsistencyWeekEntry(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    week_start: str
    training_days: int
    is_active: bool


class ConsistencyResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    weeks: list[ConsistencyWeekEntry]
    current_streak: int
    longest_streak: int
    consistency_score: float
    consistency_label: str
    total_training_days: int
    avg_days_per_week: float
    regularity_index: float | None
    regularity_label: str


# ─── Strength Standards Models ───────────────────────────────────────────────


class ExerciseStandardEntry(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    exercise_id: str
    exercise_name: str
    current_e1rm: float
    tier: str
    percentile: float
    next_milestone: float | None
    next_tier: str | None
    kg_to_next: float | None


class StrengthStandardsResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    exercises: list[ExerciseStandardEntry]
    overall_tier: str
    exercises_benchmarked: int
    tier_distribution: dict[str, int]
    disclaimer: str


# ─── Exercise Variety Models ─────────────────────────────────────────────────


class MovementPatternEntry(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    pattern: str
    sets: int
    exercise_count: int
    examples: list[str]
    percentage: float


class ExerciseVarietyResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    variety_index: float
    variety_label: str
    unique_exercises: int
    movement_patterns: list[MovementPatternEntry]
    missing_patterns: list[str]
    top_exercises: list[dict]
    period_days: int


# ─── Performance Forecast Models ─────────────────────────────────────────────


class ForecastMilestone(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    target_kg: float
    estimated_date: str
    weeks_away: float


class ExerciseForecastEntry(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    exercise_id: str
    exercise_name: str
    current_e1rm: float
    rate_per_week: float
    r_squared: float
    confidence: str
    projections: dict[str, float]
    milestones: list[ForecastMilestone]
    data_points: int


class PerformanceForecastResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    exercises: list[ExerciseForecastEntry]
    exercises_forecast: int
    high_confidence_count: int
    disclaimer: str


# ─── Fitness-Fatigue Model ───────────────────────────────────────────────────


class FitnessFatigueTimePoint(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    date: str
    fitness: float
    fatigue: float
    preparedness: float
    training_load: float


class FitnessFatigueResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    fitness: float
    fatigue: float
    preparedness: float
    preparedness_label: str
    recommendation: str
    timeline: list[FitnessFatigueTimePoint]
    peak_preparedness_date: str | None
