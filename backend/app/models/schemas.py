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
