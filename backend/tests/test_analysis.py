import json
from datetime import date
from unittest.mock import AsyncMock, MagicMock, patch

import pytest
from fastapi.testclient import TestClient

from app.auth import get_current_user
from app.config import Settings, get_settings
from app.main import app
from app.routers.ai import _rate_limit_store
from tests.conftest import FAKE_USER_ID


# ── Fixtures ─────────────────────────────────────────────────────────────────


@pytest.fixture(autouse=True)
def clear_rate_limit() -> None:
    _rate_limit_store.clear()
    yield
    _rate_limit_store.clear()


def _make_settings() -> Settings:
    return Settings(
        SUPABASE_URL="https://test.supabase.co",
        SUPABASE_DB_URL="postgresql://localhost/test",
        SUPABASE_JWT_SECRET="secret",
        ANTHROPIC_API_KEY="sk-ant-test",
        AI_RATE_LIMIT_PER_DAY=5,
    )


@pytest.fixture
def analysis_client() -> TestClient:
    """TestClient with auth and settings overrides.

    The analyze endpoint reads db_pool from request.app.state, which is
    set during lifespan. We patch app.state.db_pool directly after the
    client is created to avoid needing a real database connection.
    """
    async def override_user() -> str:
        return FAKE_USER_ID

    app.dependency_overrides[get_current_user] = override_user
    app.dependency_overrides[get_settings] = _make_settings

    with TestClient(app, raise_server_exceptions=False) as client:
        yield client

    app.dependency_overrides.clear()


# ── Analyze endpoint ─────────────────────────────────────────────────────────


def test_analyze_endpoint_success(analysis_client: TestClient) -> None:
    """POST /api/ai/analyze should return analysis response on success."""
    mock_result = {
        "id": "report-123",
        "summary": "Good training week with balanced volume.",
        "insights": [
            {
                "metric": "Volume",
                "finding": "Total volume is on track",
                "delta": "+10%",
                "recommendation": "Maintain current load",
            },
        ],
        "created_at": "2026-03-24T00:00:00",
    }

    with patch(
        "app.routers.ai.analyze_training",
        new_callable=AsyncMock,
        return_value=mock_result,
    ):
        # Set db_pool on app state so the endpoint doesn't 503
        app.state.db_pool = MagicMock()

        response = analysis_client.post(
            "/api/ai/analyze",
            json={
                "scope_type": "week",
                "scope_start": "2026-03-17",
                "scope_end": "2026-03-23",
                "goals": ["strength"],
            },
        )

        app.state.db_pool = None

    assert response.status_code == 200
    data = response.json()
    assert data["id"] == "report-123"
    assert data["summary"] == "Good training week with balanced volume."
    assert isinstance(data["insights"], list)
    assert len(data["insights"]) == 1
    assert data["insights"][0]["metric"] == "Volume"
    assert data["insights"][0]["recommendation"] == "Maintain current load"
    assert "created_at" in data


def test_analyze_rate_limit(analysis_client: TestClient) -> None:
    """Exceeding the daily rate limit should return 429."""
    # The analyze endpoint uses min(AI_RATE_LIMIT_PER_DAY, 5) = 5
    # Pre-fill the rate limit store to the limit
    _rate_limit_store[FAKE_USER_ID] = (date.today().isoformat(), 5)

    response = analysis_client.post(
        "/api/ai/analyze",
        json={
            "scope_type": "week",
            "scope_start": "2026-03-17",
            "scope_end": "2026-03-23",
            "goals": [],
        },
    )

    assert response.status_code == 429
    assert "limit" in response.json()["detail"].lower()
