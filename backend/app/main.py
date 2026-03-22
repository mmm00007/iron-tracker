from contextlib import asynccontextmanager
from typing import AsyncIterator

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.config import get_settings
from app.models.schemas import HealthResponse
from app.routers import ai, analytics


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncIterator[None]:
    """Initialize and teardown application resources."""
    settings = get_settings()

    # Initialize Supabase client
    from supabase import Client, create_client

    supabase: Client = create_client(settings.SUPABASE_URL, settings.SUPABASE_SERVICE_KEY)
    app.state.supabase = supabase

    yield

    # Cleanup (if needed)
    app.state.supabase = None


def create_app() -> FastAPI:
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
