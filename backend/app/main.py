from contextlib import asynccontextmanager
from typing import AsyncIterator

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.config import get_settings
from app.models.schemas import HealthResponse
from app.routers import ai, analytics
from app.sentry import init_sentry


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncIterator[None]:
    """Initialize and teardown application resources."""
    import asyncpg

    settings = get_settings()

    # Initialize asyncpg connection pool (direct Postgres, service role)
    app.state.db_pool = await asyncpg.create_pool(
        dsn=settings.SUPABASE_DB_URL,
        min_size=2,
        max_size=10,
    )

    yield

    # Cleanup
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
        allow_origins=settings.ALLOWED_ORIGINS,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    app.include_router(ai.router)
    app.include_router(analytics.router)

    @app.get("/health", response_model=HealthResponse, tags=["health"])
    async def health_check() -> HealthResponse:
        return HealthResponse(status="ok")

    return app


app = create_app()
