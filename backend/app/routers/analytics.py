import asyncpg
from fastapi import APIRouter, Depends, Request

from app.auth import get_current_user
from app.models.schemas import ExerciseE1RM, WeeklySummary
from app.services import analytics_service

router = APIRouter(prefix="/api/analytics", tags=["analytics"])


def get_db_pool(request: Request) -> asyncpg.Pool:
    """Extract the asyncpg connection pool from app state."""
    return request.app.state.db_pool


@router.get("/weekly-summary", response_model=WeeklySummary)
async def get_weekly_summary(
    user_id: str = Depends(get_current_user),
    db_pool: asyncpg.Pool = Depends(get_db_pool),
) -> WeeklySummary:
    """Return weekly training volume, sets, and training days for the authenticated user.

    Compares the current ISO week against the previous ISO week and includes
    percentage deltas for each metric.
    """
    return await analytics_service.compute_weekly_summary(user_id, db_pool)


@router.post("/compute-1rm", response_model=list[ExerciseE1RM])
async def compute_1rm(
    exercise_id: str,
    user_id: str = Depends(get_current_user),
    db_pool: asyncpg.Pool = Depends(get_db_pool),
) -> list[ExerciseE1RM]:
    """Compute estimated 1RM trend for a given exercise for the authenticated user.

    Returns one data point per calendar day (best e1RM across all sets that day),
    sorted oldest to newest.
    """
    return await analytics_service.compute_1rm_trend(user_id, exercise_id, db_pool)
