from pydantic import BaseModel, ConfigDict


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


class HealthResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    status: str
