"""Tests for phase 2 analytics services (2026-03-25).

Services tested:
  - Strength Standards (revised: female norms + BW-relative)
  - Composite Training Score
  - Muscle Frequency Optimization
  - Workout Staleness Detection
  - Training Load Distribution
"""

from datetime import UTC, date, datetime, timedelta
from unittest.mock import AsyncMock, MagicMock

import pytest
from fastapi.testclient import TestClient

from app.auth import get_current_user
from app.main import app
from app.services.composite_score_service import compute_composite_score
from app.services.load_distribution_service import compute_load_distribution
from app.services.muscle_frequency_service import compute_muscle_frequency
from app.services.staleness_service import _jaccard_similarity, compute_staleness
from app.services.strength_standards_service import (
    _classify_strength,
    _find_standard,
    compute_strength_standards,
)
from tests.conftest import FAKE_USER_ID

NOW = datetime.now(UTC)
TODAY = date.today()


@pytest.fixture
def mock_db_pool() -> MagicMock:
    pool = MagicMock()
    conn = AsyncMock()
    ctx = AsyncMock()
    ctx.__aenter__ = AsyncMock(return_value=conn)
    ctx.__aexit__ = AsyncMock(return_value=False)
    pool.acquire.return_value = ctx
    pool._conn = conn
    return pool


@pytest.fixture
def adv_client(mock_db_pool: MagicMock) -> TestClient:
    from app.routers.advanced_analytics import _get_db_pool

    async def override_user() -> str:
        return FAKE_USER_ID

    app.dependency_overrides[get_current_user] = override_user
    app.dependency_overrides[_get_db_pool] = lambda: mock_db_pool

    with TestClient(app, raise_server_exceptions=True) as client:
        yield client

    app.dependency_overrides.clear()


# ═════════════════════════════════════════════════════════════════════════════
# STRENGTH STANDARDS (revised)
# ═════════════════════════════════════════════════════════════════════════════


def test_find_standard_female() -> None:
    """Female standards should be different from male."""
    male = _find_standard("bench press", sex="male")
    female = _find_standard("bench press", sex="female")
    assert male is not None
    assert female is not None
    assert female[2] < male[2]  # Female intermediate < male intermediate


def test_find_standard_bw_relative() -> None:
    """BW-relative standards should scale with bodyweight."""
    standards_60 = _find_standard("bench press", sex="male", bodyweight=60.0)
    standards_100 = _find_standard("bench press", sex="male", bodyweight=100.0)
    assert standards_60 is not None
    assert standards_100 is not None
    assert standards_100[2] > standards_60[2]  # Heavier lifter has higher thresholds


def test_classify_strength_female_intermediate() -> None:
    """45kg bench should be intermediate for a female lifter."""
    female_bench = [20, 30, 45, 60, 80]  # From _FEMALE_STANDARDS
    tier, pct = _classify_strength(45.0, female_bench)
    assert tier == "intermediate"
    assert 50 <= pct <= 75


async def test_strength_standards_with_profile(mock_db_pool: MagicMock) -> None:
    """Service should use profile data for sex/bodyweight when available."""
    mock_db_pool._conn.fetch.return_value = [
        {"exercise_id": "1", "exercise_name": "Bench Press", "best_e1rm": 50.0},
    ]
    mock_db_pool._conn.fetchrow.return_value = {"sex": "female", "bodyweight": 60.0}

    result = await compute_strength_standards(FAKE_USER_ID, mock_db_pool)

    assert "female" in result.disclaimer.lower()
    assert result.exercises_benchmarked == 1


async def test_strength_standards_no_profile(mock_db_pool: MagicMock) -> None:
    """Service should default to male absolute when no profile exists."""
    mock_db_pool._conn.fetch.return_value = [
        {"exercise_id": "1", "exercise_name": "Squat", "best_e1rm": 120.0},
    ]
    mock_db_pool._conn.fetchrow.return_value = None

    result = await compute_strength_standards(FAKE_USER_ID, mock_db_pool)

    assert "male" in result.disclaimer.lower()


# ═════════════════════════════════════════════════════════════════════════════
# COMPOSITE TRAINING SCORE
# ═════════════════════════════════════════════════════════════════════════════


async def test_composite_score_empty(mock_db_pool: MagicMock) -> None:
    mock_db_pool._conn.fetch.return_value = []
    mock_db_pool._conn.fetchrow.return_value = None
    result = await compute_composite_score(FAKE_USER_ID, mock_db_pool)

    assert result.score == 0
    assert result.label == "insufficient_data"
    assert result.dimensions == []


async def test_composite_score_with_data(mock_db_pool: MagicMock) -> None:
    """With training data, should produce a meaningful score."""
    # 1. Training days (consistency)
    training_days = [{"day": TODAY - timedelta(days=i)} for i in range(0, 28, 2)]

    # 2. Overload data
    overload_data = []
    for i in range(6):
        overload_data.append({
            "exercise_id": "ex1",
            "day": TODAY - timedelta(days=24 - i * 4),
            "best_e1rm": 80.0 + i * 2.0,
        })

    # 3. Muscle volume
    muscle_data = [
        {"muscle_group": "Chest", "is_primary": True, "set_count": 20},
        {"muscle_group": "Lats", "is_primary": True, "set_count": 18},
        {"muscle_group": "Quadriceps", "is_primary": True, "set_count": 22},
    ]

    # 4. Recovery
    recovery_data = [
        {"muscle_group": "Chest", "last_trained": NOW - timedelta(hours=60)},
        {"muscle_group": "Lats", "last_trained": NOW - timedelta(hours=72)},
    ]

    # 5. Quality
    quality_data = [
        {"rpe": 7.5, "set_type": "working"},
        {"rpe": 8.0, "set_type": "working"},
        {"rpe": 8.5, "set_type": "amrap"},
    ]

    mock_db_pool._conn.fetch.side_effect = [
        training_days, overload_data, muscle_data, recovery_data, quality_data,
    ]

    result = await compute_composite_score(FAKE_USER_ID, mock_db_pool)

    assert result.score > 0
    assert result.label != "insufficient_data"
    assert len(result.dimensions) >= 3  # At least consistency, overload, volume


# ═════════════════════════════════════════════════════════════════════════════
# MUSCLE FREQUENCY
# ═════════════════════════════════════════════════════════════════════════════


async def test_muscle_frequency_empty(mock_db_pool: MagicMock) -> None:
    mock_db_pool._conn.fetch.return_value = []
    result = await compute_muscle_frequency(FAKE_USER_ID, mock_db_pool)

    assert result.muscles == []
    assert result.overall_status == "insufficient_data"


async def test_muscle_frequency_optimal(mock_db_pool: MagicMock) -> None:
    """Training chest 2x/week for 4 weeks should be optimal."""
    rows = []
    for w in range(4):
        for d in [0, 3]:  # Monday and Thursday
            day = TODAY - timedelta(days=TODAY.weekday() + 7 * (3 - w)) + timedelta(days=d)
            rows.append({
                "muscle_group": "Chest",
                "is_primary": True,
                "training_date": day,
            })

    mock_db_pool._conn.fetch.return_value = rows
    result = await compute_muscle_frequency(FAKE_USER_ID, mock_db_pool, weeks=4)

    assert len(result.muscles) == 1
    chest = result.muscles[0]
    assert chest.actual_frequency >= 1.5
    assert chest.status == "optimal"
    assert result.optimal_count == 1


async def test_muscle_frequency_undertrained(mock_db_pool: MagicMock) -> None:
    """Training chest only 1x in 4 weeks should be undertrained."""
    rows = [
        {"muscle_group": "Chest", "is_primary": True, "training_date": TODAY},
    ]

    mock_db_pool._conn.fetch.return_value = rows
    result = await compute_muscle_frequency(FAKE_USER_ID, mock_db_pool, weeks=4)

    assert result.muscles[0].status in ("undertrained", "severely_undertrained")
    assert result.undertrained_count >= 1


# ═════════════════════════════════════════════════════════════════════════════
# STALENESS DETECTION
# ═════════════════════════════════════════════════════════════════════════════


def test_jaccard_identical() -> None:
    assert _jaccard_similarity({"A", "B", "C"}, {"A", "B", "C"}) == 1.0


def test_jaccard_no_overlap() -> None:
    assert _jaccard_similarity({"A", "B"}, {"C", "D"}) == 0.0


def test_jaccard_partial() -> None:
    sim = _jaccard_similarity({"A", "B", "C"}, {"B", "C", "D"})
    assert 0.4 <= sim <= 0.6  # 2/4 = 0.5


def test_jaccard_empty() -> None:
    assert _jaccard_similarity(set(), {"A"}) == 0.0


async def test_staleness_empty(mock_db_pool: MagicMock) -> None:
    mock_db_pool._conn.fetch.return_value = []
    result = await compute_staleness(FAKE_USER_ID, mock_db_pool)

    assert result.staleness_index == 0.0
    assert result.staleness_label == "insufficient_data"


async def test_staleness_identical_workouts(mock_db_pool: MagicMock) -> None:
    """Same exercises every day should be very stale."""
    rows = []
    for i in range(5):
        day = TODAY - timedelta(days=4 - i)
        for ex in ["Bench Press", "Squat", "Deadlift"]:
            rows.append({"training_date": day, "exercise_name": ex})

    mock_db_pool._conn.fetch.return_value = rows
    result = await compute_staleness(FAKE_USER_ID, mock_db_pool)

    assert result.staleness_index >= 0.8
    assert result.staleness_label == "very_stale"
    assert result.unique_exercises == 3


async def test_staleness_varied_workouts(mock_db_pool: MagicMock) -> None:
    """Different exercises each day should not be stale."""
    rows = [
        {"training_date": TODAY - timedelta(days=3), "exercise_name": "Bench Press"},
        {"training_date": TODAY - timedelta(days=3), "exercise_name": "Tricep Dip"},
        {"training_date": TODAY - timedelta(days=2), "exercise_name": "Squat"},
        {"training_date": TODAY - timedelta(days=2), "exercise_name": "Leg Press"},
        {"training_date": TODAY - timedelta(days=1), "exercise_name": "Deadlift"},
        {"training_date": TODAY - timedelta(days=1), "exercise_name": "Pull Up"},
        {"training_date": TODAY, "exercise_name": "Overhead Press"},
        {"training_date": TODAY, "exercise_name": "Lateral Raise"},
    ]

    mock_db_pool._conn.fetch.return_value = rows
    result = await compute_staleness(FAKE_USER_ID, mock_db_pool)

    assert result.staleness_index < 0.3
    assert result.staleness_label in ("highly_varied", "balanced")
    assert result.unique_exercises == 8


# ═════════════════════════════════════════════════════════════════════════════
# LOAD DISTRIBUTION
# ═════════════════════════════════════════════════════════════════════════════


async def test_load_distribution_empty(mock_db_pool: MagicMock) -> None:
    mock_db_pool._conn.fetch.return_value = []
    result = await compute_load_distribution(FAKE_USER_ID, mock_db_pool)

    assert result.day_averages == []
    assert result.distribution_label == "insufficient_data"


async def test_load_distribution_with_data(mock_db_pool: MagicMock) -> None:
    rows = []
    for i in range(14):
        day = TODAY - timedelta(days=13 - i)
        if day.weekday() in (0, 2, 4):  # Mon, Wed, Fri
            rows.append({
                "day": day,
                "dow": (day.weekday() + 1) % 7,  # PG DOW (0=Sun)
                "daily_volume": 5000.0,
            })

    mock_db_pool._conn.fetch.return_value = rows
    result = await compute_load_distribution(FAKE_USER_ID, mock_db_pool)

    assert len(result.day_averages) == 7
    assert result.busiest_day is not None
    assert len(result.week_breakdown) > 0


# ═════════════════════════════════════════════════════════════════════════════
# ENDPOINT INTEGRATION TESTS
# ═════════════════════════════════════════════════════════════════════════════


def test_composite_score_endpoint(adv_client: TestClient, mock_db_pool: MagicMock) -> None:
    mock_db_pool._conn.fetch.return_value = []
    response = adv_client.get("/api/analytics/advanced/composite-score?period=28")
    assert response.status_code == 200
    assert "score" in response.json()


def test_muscle_frequency_endpoint(adv_client: TestClient, mock_db_pool: MagicMock) -> None:
    mock_db_pool._conn.fetch.return_value = []
    response = adv_client.get("/api/analytics/advanced/muscle-frequency?weeks=4")
    assert response.status_code == 200
    assert "muscles" in response.json()


def test_staleness_endpoint(adv_client: TestClient, mock_db_pool: MagicMock) -> None:
    mock_db_pool._conn.fetch.return_value = []
    response = adv_client.get("/api/analytics/advanced/staleness?weeks=4")
    assert response.status_code == 200
    assert "staleness_index" in response.json()


def test_load_distribution_endpoint(adv_client: TestClient, mock_db_pool: MagicMock) -> None:
    mock_db_pool._conn.fetch.return_value = []
    response = adv_client.get("/api/analytics/advanced/load-distribution?weeks=4")
    assert response.status_code == 200
    assert "day_averages" in response.json()


def test_dashboard_includes_phase2_metrics(
    adv_client: TestClient, mock_db_pool: MagicMock,
) -> None:
    """Dashboard should now include all 17 metrics."""
    mock_db_pool._conn.fetch.return_value = []
    mock_db_pool._conn.fetch.side_effect = None
    mock_db_pool._conn.fetchrow.return_value = None

    response = adv_client.get("/api/analytics/advanced/dashboard?period=7")
    assert response.status_code == 200

    data = response.json()
    # Phase 2 additions
    assert "composite_score" in data
    assert "muscle_frequency" in data
    assert "staleness" in data
    assert "load_distribution" in data
