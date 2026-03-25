from unittest.mock import MagicMock

from fastapi.testclient import TestClient

from app.main import app


def test_health_check(test_client: TestClient) -> None:
    """GET /health should return 200 with status ok when db_pool is available."""
    app.state.db_pool = MagicMock()
    response = test_client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}
    app.state.db_pool = None


def test_health_check_no_db(test_client: TestClient) -> None:
    """GET /health should return 503 when db_pool is unavailable."""
    app.state.db_pool = None
    response = test_client.get("/health")
    assert response.status_code == 503
