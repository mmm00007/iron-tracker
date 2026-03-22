from fastapi.testclient import TestClient


def test_health_check(test_client: TestClient) -> None:
    """GET /health should return 200 with status ok."""
    response = test_client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}
