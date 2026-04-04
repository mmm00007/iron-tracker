import ssl as _ssl
from collections.abc import AsyncIterator
from contextlib import asynccontextmanager

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware

from app.config import get_settings
from app.models.schemas import HealthResponse
from app.routers import advanced_analytics, ai, analytics
from app.sentry import init_sentry


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncIterator[None]:
    """Initialize and teardown application resources."""
    import logging

    import asyncpg

    logger = logging.getLogger(__name__)
    settings = get_settings()

    # Supabase requires SSL for external connections
    ctx = _ssl.create_default_context()

    try:
        # Initialize asyncpg connection pool (direct Postgres)
        app.state.db_pool = await asyncpg.create_pool(
            dsn=settings.SUPABASE_DB_URL,
            min_size=2,
            max_size=20,
            ssl=ctx,
            command_timeout=30,
            max_inactive_connection_lifetime=300,
        )
        logger.info("Database pool initialized")
    except Exception as e:
        logger.error("Failed to initialize database pool: %s", e)
        app.state.db_pool = None

    # Initialize AIService singleton for connection reuse across requests
    from app.services.ai_service import AIService

    app.state.ai_service = AIService(api_key=settings.ANTHROPIC_API_KEY)

    if not settings.CRON_SECRET:
        logger.warning(
            "CRON_SECRET is not set — the weekly trends cron endpoint will reject all requests. "
            "Set the CRON_SECRET environment variable to enable cron jobs."
        )

    if not settings.ANTHROPIC_API_KEY:
        logger.warning(
            "ANTHROPIC_API_KEY is not set — AI endpoints will fail "
            "at runtime. Set the environment variable to enable "
            "machine identification and training analysis."
        )

    yield

    # Cleanup
    if app.state.db_pool:
        await app.state.db_pool.close()


def create_app() -> FastAPI:
    init_sentry()
    settings = get_settings()

    app = FastAPI(
        title="Iron Tracker API",
        description="Backend API for the Iron Tracker gym tracking PWA",
        version="0.1.0",
        lifespan=lifespan,
        docs_url="/docs" if settings.DEBUG else None,
        redoc_url="/redoc" if settings.DEBUG else None,
        openapi_url="/openapi.json" if settings.DEBUG else None,
    )

    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.allowed_origins_list,
        allow_credentials=True,
        allow_methods=["GET", "POST", "OPTIONS"],
        allow_headers=["Authorization", "Content-Type"],
    )

    app.include_router(ai.router)
    app.include_router(analytics.router)
    app.include_router(advanced_analytics.router)

    @app.get("/health", response_model=HealthResponse, tags=["health"])
    async def health_check(request: Request) -> HealthResponse:
        from fastapi import HTTPException

        db_pool = getattr(request.app.state, "db_pool", None)
        if db_pool is None:
            raise HTTPException(status_code=503, detail="Database unavailable")
        try:
            async with db_pool.acquire() as conn:
                await conn.fetchval("SELECT 1")
        except Exception:
            raise HTTPException(status_code=503, detail="Database unreachable")
        return HealthResponse(status="ok")

    @app.get("/api/rollout-flags", tags=["config"])
    async def rollout_flags() -> dict:
        return {
            "plansEnabled": settings.FLAG_PLANS,
            "analysisEnabled": settings.FLAG_ANALYSIS,
            "sorenessEnabled": settings.FLAG_SORENESS,
            "prBoardEnabled": settings.FLAG_PR_BOARD,
            "dataExportEnabled": settings.FLAG_DATA_EXPORT,
            "weightSuggestionEnabled": settings.FLAG_WEIGHT_SUGGESTION,
            "diagnosticsEnabled": settings.FLAG_DIAGNOSTICS,
            "advancedAnalyticsEnabled": settings.FLAG_ADVANCED_ANALYTICS,
        }

    return app


app = create_app()
