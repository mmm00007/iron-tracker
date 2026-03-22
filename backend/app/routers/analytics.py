from fastapi import APIRouter, Depends

from app.auth import get_current_user
from app.models.schemas import ExerciseE1RM, WeeklySummary
from app.services import analytics_service

router = APIRouter(prefix="/api/analytics", tags=["analytics"])


@router.get("/weekly-summary", response_model=WeeklySummary)
async def get_weekly_summary(
    user_id: str = Depends(get_current_user),
) -> WeeklySummary:
    """Return weekly training volume, sets, and session count for the authenticated user."""
    # Supabase client wiring will be added when lifespan state is threaded through
    return await analytics_service.compute_weekly_summary(user_id, supabase_client=None)


@router.post("/compute-1rm", response_model=list[ExerciseE1RM])
async def compute_1rm(
    exercise_id: str,
    user_id: str = Depends(get_current_user),
) -> list[ExerciseE1RM]:
    """Compute estimated 1RM trend for a given exercise for the authenticated user."""
    return await analytics_service.compute_1rm_trend(
        user_id, exercise_id, supabase_client=None
    )
