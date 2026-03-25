import asyncpg
from fastapi import APIRouter, Depends, Header, HTTPException, Request

from app.auth import get_current_user
from app.config import Settings, get_settings
from app.models.schemas import ExerciseE1RM, WeeklySummary
from app.services import analytics_service
from app.services.weekly_summary_service import generate_weekly_summaries

router = APIRouter(prefix="/api/analytics", tags=["analytics"])


def get_db_pool(request: Request) -> asyncpg.Pool:
    """Extract the asyncpg connection pool from app state."""
    pool = request.app.state.db_pool
    if pool is None:
        raise HTTPException(status_code=503, detail="Database unavailable")
    return pool


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


@router.post("/jobs/generate-weekly-trends")
async def generate_weekly_trends(
    x_cron_secret: str = Header(..., alias="X-Cron-Secret"),
    settings: Settings = Depends(get_settings),
    db_pool: asyncpg.Pool = Depends(get_db_pool),
) -> dict:
    """Generate weekly training summaries for all active users.

    Designed to be called by a cron job (e.g., Monday 6 AM UTC).
    Protected by a shared secret passed via the X-Cron-Secret header.
    """
    if not settings.CRON_SECRET or x_cron_secret != settings.CRON_SECRET:
        raise HTTPException(status_code=403, detail="Forbidden")

    count = await generate_weekly_summaries(db_pool)
    return {"status": "ok", "summaries_generated": count}
