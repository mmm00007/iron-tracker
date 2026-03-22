from pydantic import BaseModel, ConfigDict


class MachineIdentificationResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    exercise_name: str
    equipment_type: str
    manufacturer: str | None
    muscles: list[str]
    form_tips: list[str]


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
