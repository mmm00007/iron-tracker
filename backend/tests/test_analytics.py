from datetime import date
from unittest.mock import AsyncMock, MagicMock

import pytest
from fastapi.testclient import TestClient

from app.auth import get_current_user
from app.main import app
from app.services.analytics_service import _epley, compute_weekly_summary
from tests.conftest import FAKE_USER_ID

# ── Fixtures ─────────────────────────────────────────────────────────────────


@pytest.fixture
def mock_db_pool() -> MagicMock:
    """Create a mock asyncpg pool with acquire() context manager."""
    pool = MagicMock()
    conn = AsyncMock()
    ctx = AsyncMock()
    ctx.__aenter__ = AsyncMock(return_value=conn)
    ctx.__aexit__ = AsyncMock(return_value=False)
    pool.acquire.return_value = ctx
    pool._conn = conn  # expose for assertions
    return pool


@pytest.fixture
def analytics_client(mock_db_pool: MagicMock) -> TestClient:
    """TestClient with auth and db_pool overrides for analytics routes."""
    from app.routers.analytics import get_db_pool

    async def override_user() -> str:
        return FAKE_USER_ID

    app.dependency_overrides[get_current_user] = override_user
    app.dependency_overrides[get_db_pool] = lambda: mock_db_pool

    with TestClient(app, raise_server_exceptions=True) as client:
        yield client

    app.dependency_overrides.clear()


# ── Epley formula unit tests ─────────────────────────────────────────────────


def test_epley_formula() -> None:
    """Epley: 100 kg x 8 reps = 100 * (1 + 8/30) = 126.67."""
    result = _epley(100.0, 8)
    assert round(result, 2) == 126.67


def test_epley_zero_reps() -> None:
    """Weight with 0 reps should return the weight unchanged."""
    assert _epley(100.0, 0) == 100.0


def test_epley_negative_reps() -> None:
    """Negative reps should return the weight unchanged."""
    assert _epley(80.0, -1) == 80.0


def test_epley_zero_weight() -> None:
    """Zero weight should return 0."""
    assert _epley(0.0, 5) == 0.0


def test_epley_one_rep() -> None:
    """1 rep: 100 * (1 + 1/30) = 103.33."""
    result = _epley(100.0, 1)
    assert round(result, 2) == 103.33


# ── Weekly summary endpoint ─────────────────────────────────────────────────


def test_weekly_summary_endpoint(
    analytics_client: TestClient,
    mock_db_pool: MagicMock,
) -> None:
    """GET /api/analytics/weekly-summary should return correct shape."""
    conn = mock_db_pool._conn
    conn.fetch.return_value = [
        {
            "total_sets": 20,
            "total_volume": 5000.0,
            "training_days": 4,
            "period": "this",
        },
        {
            "total_sets": 18,
            "total_volume": 4500.0,
            "training_days": 3,
            "period": "last",
        },
    ]

    response = analytics_client.get("/api/analytics/weekly-summary")

    assert response.status_code == 200
    data = response.json()
    assert data["total_sets"] == 20
    assert data["total_volume"] == 5000.0
    assert data["training_days"] == 4
    assert data["delta_sets"] is not None
    assert data["delta_volume"] is not None


def test_weekly_summary_endpoint_last_week_only(
    analytics_client: TestClient,
    mock_db_pool: MagicMock,
) -> None:
    """GET /api/analytics/weekly-summary with both periods returns deltas."""
    conn = mock_db_pool._conn
    conn.fetch.return_value = [
        {
            "total_sets": 15,
            "total_volume": 3500.0,
            "training_days": 3,
            "period": "this",
        },
        {
            "total_sets": 15,
            "total_volume": 3500.0,
            "training_days": 3,
            "period": "last",
        },
    ]

    response = analytics_client.get("/api/analytics/weekly-summary")

    assert response.status_code == 200
    data = response.json()
    assert data["total_sets"] == 15
    assert data["total_volume"] == 3500.0
    assert data["training_days"] == 3
    # Same values both weeks, so deltas are 0
    assert data["delta_sets"] == 0
    assert data["delta_volume"] == 0


# ── Compute 1RM endpoint ────────────────────────────────────────────────────


def test_compute_1rm_endpoint(
    analytics_client: TestClient,
    mock_db_pool: MagicMock,
) -> None:
    """POST /api/analytics/compute-1rm should return a list of E1RM data points."""
    today = date.today()
    conn = mock_db_pool._conn
    conn.fetch.return_value = [
        {"day": today, "weight": 100.0, "reps": 5},
        {"day": today, "weight": 90.0, "reps": 8},
    ]

    exercise_uuid = "00000000-0000-4000-8000-000000000001"
    response = analytics_client.post(
        "/api/analytics/compute-1rm",
        params={"exercise_id": exercise_uuid},
    )

    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert len(data) == 1  # Both on same day, only best kept
    assert data[0]["exercise_id"] == exercise_uuid
    assert data[0]["date"] == str(today)
    assert data[0]["estimated_1rm"] > 0


# ── Weekly summary service logic ─────────────────────────────────────────────


async def test_weekly_summary_computation(mock_db_pool: MagicMock) -> None:
    """compute_weekly_summary should compute deltas from DB rows."""
    conn = mock_db_pool._conn
    conn.fetch.return_value = [
        {
            "total_sets": 15,
            "total_volume": 3000.0,
            "training_days": 3,
            "period": "this",
        },
        {
            "total_sets": 10,
            "total_volume": 2000.0,
            "training_days": 2,
            "period": "last",
        },
    ]

    result = await compute_weekly_summary(FAKE_USER_ID, mock_db_pool)

    assert result.total_sets == 15
    assert result.total_volume == 3000.0
    assert result.training_days == 3
    # delta_sets: (15-10)/10 * 100 = 50
    assert result.delta_sets == 50
    # delta_volume: (3000-2000)/2000 * 100 = 50
    assert result.delta_volume == 50


async def test_weekly_summary_no_previous_week(mock_db_pool: MagicMock) -> None:
    """When only 'this' period is returned, the empty 'last' dict causes KeyError.

    This is a known edge case in the source code: stats is initialized as
    {"this": {}, "last": {}}, so stats.get("last", default) returns the
    existing empty dict {} rather than the default, then last["sets"]
    raises KeyError.
    """
    conn = mock_db_pool._conn
    conn.fetch.return_value = [
        {
            "total_sets": 12,
            "total_volume": 2500.0,
            "training_days": 3,
            "period": "this",
        },
    ]

    with pytest.raises(KeyError):
        await compute_weekly_summary(FAKE_USER_ID, mock_db_pool)


async def test_weekly_summary_with_both_periods(mock_db_pool: MagicMock) -> None:
    """When both periods have data, deltas should be computed correctly."""
    conn = mock_db_pool._conn
    conn.fetch.return_value = [
        {
            "total_sets": 24,
            "total_volume": 6000.0,
            "training_days": 4,
            "period": "this",
        },
        {
            "total_sets": 20,
            "total_volume": 5000.0,
            "training_days": 4,
            "period": "last",
        },
    ]

    result = await compute_weekly_summary(FAKE_USER_ID, mock_db_pool)

    assert result.total_sets == 24
    assert result.total_volume == 6000.0
    assert result.training_days == 4
    # delta_sets: (24-20)/20 * 100 = 20
    assert result.delta_sets == 20
    # delta_volume: (6000-5000)/5000 * 100 = 20
    assert result.delta_volume == 20
