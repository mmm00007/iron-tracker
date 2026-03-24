import ssl as _ssl
from collections.abc import AsyncIterator
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.config import get_settings
from app.models.schemas import HealthResponse
from app.routers import ai, analytics
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
            min_size=1,
            max_size=10,
            ssl=ctx,
        )
        logger.info("Database pool initialized")
    except Exception as e:
        logger.error("Failed to initialize database pool: %s", e)
        app.state.db_pool = None

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
        debug=settings.DEBUG,
        lifespan=lifespan,
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

    @app.get("/health", response_model=HealthResponse, tags=["health"])
    async def health_check() -> HealthResponse:
        return HealthResponse(status="ok")

    @app.get("/api/rollout-flags", tags=["config"])
    async def rollout_flags() -> dict:
        return {
            "plansEnabled": True,
            "analysisEnabled": True,
            "sorenessEnabled": True,
            "prBoardEnabled": True,
            "dataExportEnabled": True,
            "weightSuggestionEnabled": True,
            "diagnosticsEnabled": True,
        }

    return app


app = create_app()
