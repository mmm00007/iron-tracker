from unittest.mock import AsyncMock, MagicMock

import pytest
from fastapi.testclient import TestClient

from app.auth import get_current_user
from app.main import app

FAKE_USER_ID = "test-user-00000000-0000-0000-0000-000000000001"


async def override_get_current_user() -> str:
    """Return a fake user_id, bypassing JWT verification in tests."""
    return FAKE_USER_ID


@pytest.fixture
def mock_db_pool() -> MagicMock:
    """Create a mock asyncpg pool with acquire() context manager."""
    pool = MagicMock()
    conn = AsyncMock()
    conn.fetchrow.return_value = None  # Default: no profile data
    ctx = AsyncMock()
    ctx.__aenter__ = AsyncMock(return_value=conn)
    ctx.__aexit__ = AsyncMock(return_value=False)
    pool.acquire.return_value = ctx
    pool._conn = conn  # expose for assertions
    return pool


@pytest.fixture
def test_client() -> TestClient:
    """FastAPI TestClient with auth dependency overridden."""
    app.dependency_overrides[get_current_user] = override_get_current_user
    with TestClient(app, raise_server_exceptions=True) as client:
        mock_pool = MagicMock()
        mock_pool.close = AsyncMock()
        app.state.db_pool = mock_pool
        yield client
    app.dependency_overrides.clear()
