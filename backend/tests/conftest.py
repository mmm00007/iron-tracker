import pytest
from fastapi.testclient import TestClient

from app.auth import get_current_user
from app.main import app

FAKE_USER_ID = "test-user-00000000-0000-0000-0000-000000000001"


async def override_get_current_user() -> str:
    """Return a fake user_id, bypassing JWT verification in tests."""
    return FAKE_USER_ID


@pytest.fixture
def test_client() -> TestClient:
    """FastAPI TestClient with auth dependency overridden."""
    app.dependency_overrides[get_current_user] = override_get_current_user
    with TestClient(app, raise_server_exceptions=True) as client:
        yield client
    app.dependency_overrides.clear()
