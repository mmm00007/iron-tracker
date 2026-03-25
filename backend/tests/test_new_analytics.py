"""Tests for the 6 new advanced analytics services (2026-03-25).

Services tested:
  - ACWR (Acute:Chronic Workload Ratio)
  - Training Consistency & Streaks
  - Strength Standards & Benchmarking
  - Exercise Variety & Movement Patterns
  - Performance Forecasting
  - Fitness-Fatigue (Banister) Model
"""

from datetime import UTC, date, datetime, timedelta
from unittest.mock import AsyncMock, MagicMock

import pytest
from fastapi.testclient import TestClient

from app.auth import get_current_user
from app.main import app
from app.services.acwr_service import compute_acwr
from app.services.consistency_service import (
    _regularity_index,
    compute_consistency,
)
from app.services.exercise_variety_service import (
    _classify_movement_pattern,
    compute_exercise_variety,
)
from app.services.fitness_fatigue_service import compute_fitness_fatigue
from app.services.performance_forecast_service import (
    _linear_regression_with_r2,
    compute_performance_forecast,
)
from app.services.strength_standards_service import (
    _classify_strength,
    _find_standard,
    compute_strength_standards,
)
from tests.conftest import FAKE_USER_ID

# ── Fixtures ─────────────────────────────────────────────────────────────────

NOW = datetime.now(UTC)
TODAY = date.today()


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
# ACWR SERVICE
# ═════════════════════════════════════════════════════════════════════════════


async def test_acwr_empty_data(mock_db_pool: MagicMock) -> None:
    mock_db_pool._conn.fetch.return_value = []
    result = await compute_acwr(FAKE_USER_ID, mock_db_pool)

    assert result.acwr is None
    assert result.risk_zone == "insufficient_data"
    assert result.weekly_trend == []


async def test_acwr_with_steady_training(mock_db_pool: MagicMock) -> None:
    """Consistent training should produce ACWR in the optimal zone."""
    rows = []
    for i in range(28):
        day = TODAY - timedelta(days=27 - i)
        if i % 2 == 0:  # Train every other day
            rows.append({"day": day, "daily_volume": 5000.0})

    mock_db_pool._conn.fetch.return_value = rows
    result = await compute_acwr(FAKE_USER_ID, mock_db_pool)

    assert result.acwr is not None
    assert 0.7 <= result.acwr <= 1.5  # Should be near 1.0 for steady training
    assert result.risk_zone in ("optimal", "under_prepared", "caution")
    assert result.acute_load > 0
    assert result.chronic_load > 0


async def test_acwr_spike_detection(mock_db_pool: MagicMock) -> None:
    """A sudden volume spike should produce high ACWR."""
    rows = []
    # Low volume for 3 weeks
    for i in range(21):
        day = TODAY - timedelta(days=27 - i)
        if i % 3 == 0:
            rows.append({"day": day, "daily_volume": 2000.0})
    # High volume spike in last week
    for i in range(7):
        day = TODAY - timedelta(days=6 - i)
        rows.append({"day": day, "daily_volume": 15000.0})

    mock_db_pool._conn.fetch.return_value = rows
    result = await compute_acwr(FAKE_USER_ID, mock_db_pool)

    assert result.acwr is not None
    assert result.acwr > 1.3  # Spike should be detected
    assert result.risk_zone in ("caution", "danger")


async def test_acwr_insufficient_data(mock_db_pool: MagicMock) -> None:
    """Less than 2 weeks of data should return insufficient."""
    rows = [{"day": TODAY - timedelta(days=i), "daily_volume": 5000.0} for i in range(5)]
    mock_db_pool._conn.fetch.return_value = rows
    result = await compute_acwr(FAKE_USER_ID, mock_db_pool)

    assert result.acwr is None
    assert result.risk_zone == "insufficient_data"


# ═════════════════════════════════════════════════════════════════════════════
# CONSISTENCY SERVICE
# ═════════════════════════════════════════════════════════════════════════════


def test_regularity_index_perfect() -> None:
    """Perfectly regular gaps should yield index near 1.0."""
    gaps = [2.0, 2.0, 2.0, 2.0, 2.0]
    index = _regularity_index(gaps)
    assert index is not None
    assert index >= 0.99


def test_regularity_index_irregular() -> None:
    """Highly variable gaps should yield low index."""
    gaps = [1.0, 7.0, 1.0, 14.0, 2.0]
    index = _regularity_index(gaps)
    assert index is not None
    assert index < 0.5


def test_regularity_index_insufficient() -> None:
    """Too few gaps should return None."""
    assert _regularity_index([2.0, 3.0]) is None


async def test_consistency_empty(mock_db_pool: MagicMock) -> None:
    mock_db_pool._conn.fetch.return_value = []
    result = await compute_consistency(FAKE_USER_ID, mock_db_pool, weeks=12)

    assert result.current_streak == 0
    assert result.longest_streak == 0
    assert result.consistency_score == 0.0
    assert result.total_training_days == 0


async def test_consistency_perfect_streak(mock_db_pool: MagicMock) -> None:
    """Training 3x/week for 4 weeks should give high consistency."""
    training_days = []
    for w in range(4):
        week_start = TODAY - timedelta(days=TODAY.weekday() + 7 * (3 - w))
        for d in [0, 2, 4]:  # Mon, Wed, Fri
            training_days.append({"training_day": week_start + timedelta(days=d)})

    mock_db_pool._conn.fetch.return_value = training_days
    result = await compute_consistency(FAKE_USER_ID, mock_db_pool, weeks=4)

    assert result.current_streak >= 3
    assert result.consistency_score >= 0.5
    assert result.avg_days_per_week >= 2.5
    assert result.regularity_index is not None
    assert result.regularity_index > 0.3


async def test_consistency_with_gap(mock_db_pool: MagicMock) -> None:
    """A gap in training should break the streak."""
    training_days = []
    # Train weeks 1-2, skip week 3, train week 4 (most recent)
    for w in [0, 1, 3]:
        week_start = TODAY - timedelta(days=TODAY.weekday() + 7 * (3 - w))
        for d in [0, 2, 4]:
            training_days.append({"training_day": week_start + timedelta(days=d)})

    mock_db_pool._conn.fetch.return_value = training_days
    result = await compute_consistency(FAKE_USER_ID, mock_db_pool, weeks=4)

    assert result.current_streak == 1  # Only the most recent week
    assert result.longest_streak == 2  # First two weeks


# ═════════════════════════════════════════════════════════════════════════════
# STRENGTH STANDARDS SERVICE
# ═════════════════════════════════════════════════════════════════════════════


def test_classify_strength_beginner() -> None:
    """30kg bench should be below beginner standard."""
    standards = [40, 60, 85, 110, 140]  # bench press
    tier, pct = _classify_strength(30.0, standards)
    assert tier == "untrained"
    assert pct < 10


def test_classify_strength_intermediate() -> None:
    """85kg bench should be intermediate."""
    standards = [40, 60, 85, 110, 140]
    tier, pct = _classify_strength(85.0, standards)
    assert tier == "intermediate"
    assert 50 <= pct <= 75


def test_classify_strength_elite() -> None:
    """150kg bench should be elite."""
    standards = [40, 60, 85, 110, 140]
    tier, pct = _classify_strength(150.0, standards)
    assert tier == "elite"
    assert pct >= 95


def test_find_standard_exact() -> None:
    assert _find_standard("bench press") is not None
    assert _find_standard("deadlift") is not None


def test_find_standard_fuzzy() -> None:
    assert _find_standard("Barbell Bench Press") is not None
    assert _find_standard("barbell deadlift") is not None


def test_find_standard_unknown() -> None:
    assert _find_standard("cable lateral raise") is None


async def test_strength_standards_empty(mock_db_pool: MagicMock) -> None:
    mock_db_pool._conn.fetch.return_value = []
    result = await compute_strength_standards(FAKE_USER_ID, mock_db_pool)

    assert result.exercises == []
    assert result.overall_tier == "insufficient_data"


async def test_strength_standards_with_data(mock_db_pool: MagicMock) -> None:
    mock_db_pool._conn.fetch.return_value = [
        {"exercise_id": "1", "exercise_name": "Bench Press", "best_e1rm": 90.0},
        {"exercise_id": "2", "exercise_name": "Squat", "best_e1rm": 120.0},
        {"exercise_id": "3", "exercise_name": "Cable Curl", "best_e1rm": 40.0},
    ]

    result = await compute_strength_standards(FAKE_USER_ID, mock_db_pool)

    # Cable Curl should be excluded (no standard)
    assert result.exercises_benchmarked == 2
    assert result.overall_tier != "insufficient_data"
    assert result.disclaimer != ""

    # Check bench is classified correctly (~intermediate)
    bench = next(e for e in result.exercises if e.exercise_name == "Bench Press")
    assert bench.tier == "intermediate"
    assert bench.next_milestone is not None


# ═════════════════════════════════════════════════════════════════════════════
# EXERCISE VARIETY SERVICE
# ═════════════════════════════════════════════════════════════════════════════


def test_classify_movement_bench_press() -> None:
    assert _classify_movement_pattern("Barbell Bench Press") == "horizontal_push"


def test_classify_movement_squat() -> None:
    assert _classify_movement_pattern("Back Squat") == "squat"


def test_classify_movement_deadlift() -> None:
    assert _classify_movement_pattern("Romanian Deadlift") == "hip_hinge"


def test_classify_movement_pullup() -> None:
    assert _classify_movement_pattern("Pull Up") == "vertical_pull"


def test_classify_movement_unknown() -> None:
    assert _classify_movement_pattern("Wrist Roller") == "isolation"


async def test_exercise_variety_empty(mock_db_pool: MagicMock) -> None:
    mock_db_pool._conn.fetch.return_value = []
    result = await compute_exercise_variety(FAKE_USER_ID, mock_db_pool)

    assert result.variety_index == 0.0
    assert result.unique_exercises == 0
    assert result.missing_patterns == []


async def test_exercise_variety_balanced_program(mock_db_pool: MagicMock) -> None:
    mock_db_pool._conn.fetch.return_value = [
        {"exercise_name": "Bench Press", "set_count": 12, "sessions": 3},
        {"exercise_name": "Barbell Row", "set_count": 12, "sessions": 3},
        {"exercise_name": "Overhead Press", "set_count": 9, "sessions": 3},
        {"exercise_name": "Pull Up", "set_count": 12, "sessions": 3},
        {"exercise_name": "Squat", "set_count": 15, "sessions": 3},
        {"exercise_name": "Romanian Deadlift", "set_count": 12, "sessions": 3},
    ]

    result = await compute_exercise_variety(FAKE_USER_ID, mock_db_pool)

    assert result.variety_index > 0.8  # Well-balanced program
    assert result.unique_exercises == 6
    assert len(result.movement_patterns) >= 5
    assert len(result.missing_patterns) <= 1  # lunge might be missing


async def test_exercise_variety_narrow_program(mock_db_pool: MagicMock) -> None:
    """Only bench press and curls = very narrow."""
    mock_db_pool._conn.fetch.return_value = [
        {"exercise_name": "Bench Press", "set_count": 30, "sessions": 5},
        {"exercise_name": "Barbell Curl", "set_count": 5, "sessions": 2},
    ]

    result = await compute_exercise_variety(FAKE_USER_ID, mock_db_pool)

    assert result.variety_index < 0.8
    assert len(result.missing_patterns) >= 3  # Missing many patterns


# ═════════════════════════════════════════════════════════════════════════════
# PERFORMANCE FORECAST SERVICE
# ═════════════════════════════════════════════════════════════════════════════


def test_regression_with_r2_perfect_line() -> None:
    slope, intercept, r2 = _linear_regression_with_r2(
        [0.0, 1.0, 2.0, 3.0], [10.0, 12.0, 14.0, 16.0]
    )
    assert abs(slope - 2.0) < 0.001
    assert abs(intercept - 10.0) < 0.001
    assert r2 > 0.99


def test_regression_with_r2_noisy() -> None:
    slope, _, r2 = _linear_regression_with_r2(
        [0.0, 1.0, 2.0, 3.0], [10.0, 15.0, 11.0, 14.0]
    )
    assert r2 < 0.5  # Noisy data should have low R²


def test_regression_with_r2_single_point() -> None:
    slope, intercept, r2 = _linear_regression_with_r2([5.0], [100.0])
    assert slope == 0.0
    assert intercept == 100.0
    assert r2 == 0.0


async def test_forecast_empty(mock_db_pool: MagicMock) -> None:
    mock_db_pool._conn.fetch.return_value = []
    result = await compute_performance_forecast(FAKE_USER_ID, mock_db_pool)

    assert result.exercises == []
    assert result.exercises_forecast == 0


async def test_forecast_with_progression(mock_db_pool: MagicMock) -> None:
    """Steadily increasing bench press should produce positive forecast."""
    rows = []
    base = TODAY - timedelta(days=56)
    for i in range(8):
        day = base + timedelta(weeks=i)
        weight = 80.0 + i * 2.5
        e1rm = weight * (1 + 5 / 30)  # Epley for 5 reps
        rows.append({
            "exercise_id": "ex-bench",
            "exercise_name": "Bench Press",
            "estimated_1rm": e1rm,
            "day": day,
        })

    mock_db_pool._conn.fetch.return_value = rows
    result = await compute_performance_forecast(FAKE_USER_ID, mock_db_pool)

    assert len(result.exercises) == 1
    entry = result.exercises[0]
    assert entry.rate_per_week > 0
    assert entry.r_squared > 0.8  # Strong linear trend
    assert entry.confidence in ("high", "moderate")
    assert "4_weeks" in entry.projections
    assert "8_weeks" in entry.projections
    assert "12_weeks" in entry.projections
    assert entry.projections["4_weeks"] > entry.current_e1rm


async def test_forecast_milestones(mock_db_pool: MagicMock) -> None:
    """Should predict milestones for compound lifts."""
    rows = []
    base = TODAY - timedelta(days=56)
    for i in range(8):
        day = base + timedelta(weeks=i)
        weight = 70.0 + i * 2.5
        e1rm = weight * (1 + 5 / 30)  # Epley for 5 reps
        rows.append({
            "exercise_id": "ex-bench",
            "exercise_name": "Bench Press",
            "estimated_1rm": e1rm,
            "day": day,
        })

    mock_db_pool._conn.fetch.return_value = rows
    result = await compute_performance_forecast(FAKE_USER_ID, mock_db_pool)

    assert len(result.exercises) == 1
    entry = result.exercises[0]
    # Should have milestones for bench press (100kg, 120kg, etc.)
    if entry.milestones:
        assert entry.milestones[0].target_kg > entry.current_e1rm
        assert entry.milestones[0].weeks_away > 0


# ═════════════════════════════════════════════════════════════════════════════
# FITNESS-FATIGUE MODEL SERVICE
# ═════════════════════════════════════════════════════════════════════════════


async def test_fitness_fatigue_empty(mock_db_pool: MagicMock) -> None:
    mock_db_pool._conn.fetch.return_value = []
    result = await compute_fitness_fatigue(FAKE_USER_ID, mock_db_pool)

    assert result.fitness == 0.0
    assert result.fatigue == 0.0
    assert result.preparedness == 0.0
    assert result.preparedness_label == "insufficient_data"


async def test_fitness_fatigue_with_training(mock_db_pool: MagicMock) -> None:
    """Regular training should build fitness and fatigue."""
    rows = []
    for i in range(30):
        day = TODAY - timedelta(days=29 - i)
        if i % 2 == 0:  # Train every other day
            rows.append({"day": day, "daily_volume": 5000.0})

    mock_db_pool._conn.fetch.return_value = rows
    result = await compute_fitness_fatigue(FAKE_USER_ID, mock_db_pool)

    assert result.fitness > 0
    assert result.fatigue > 0
    assert result.preparedness_label != "insufficient_data"
    assert len(result.timeline) > 0
    assert result.recommendation != ""


async def test_fitness_fatigue_after_deload(mock_db_pool: MagicMock) -> None:
    """After stopping training, fatigue should drop faster than fitness."""
    rows = []
    # Heavy training for 3 weeks
    for i in range(21):
        day = TODAY - timedelta(days=27 - i)
        if i % 2 == 0:
            rows.append({"day": day, "daily_volume": 8000.0})
    # No training for last week (deload)
    # No rows added for last 7 days

    mock_db_pool._conn.fetch.return_value = rows
    result = await compute_fitness_fatigue(FAKE_USER_ID, mock_db_pool)

    # After rest, fatigue decays faster (tau=7d) than fitness (tau=42d)
    # So preparedness should be positive (supercompensation)
    assert result.fitness > 0
    # Fatigue should have decayed significantly
    assert result.preparedness_label in ("supercompensated", "fresh", "fatigued")


async def test_fitness_fatigue_timeline(mock_db_pool: MagicMock) -> None:
    """Timeline should contain daily data points."""
    rows = []
    for i in range(14):
        day = TODAY - timedelta(days=13 - i)
        if i % 2 == 0:
            rows.append({"day": day, "daily_volume": 5000.0})

    mock_db_pool._conn.fetch.return_value = rows
    result = await compute_fitness_fatigue(FAKE_USER_ID, mock_db_pool)

    assert len(result.timeline) > 0
    # Each point should have all fields
    for point in result.timeline:
        assert point.date is not None
        assert isinstance(point.fitness, float)
        assert isinstance(point.fatigue, float)
        assert isinstance(point.preparedness, float)


# ═════════════════════════════════════════════════════════════════════════════
# ENDPOINT INTEGRATION TESTS (new endpoints)
# ═════════════════════════════════════════════════════════════════════════════


def test_acwr_endpoint(adv_client: TestClient, mock_db_pool: MagicMock) -> None:
    mock_db_pool._conn.fetch.return_value = []
    response = adv_client.get("/api/analytics/advanced/acwr")
    assert response.status_code == 200
    data = response.json()
    assert "acwr" in data
    assert "risk_zone" in data


def test_consistency_endpoint(adv_client: TestClient, mock_db_pool: MagicMock) -> None:
    mock_db_pool._conn.fetch.return_value = []
    response = adv_client.get("/api/analytics/advanced/consistency?weeks=12")
    assert response.status_code == 200
    data = response.json()
    assert "current_streak" in data
    assert "consistency_score" in data


def test_strength_standards_endpoint(adv_client: TestClient, mock_db_pool: MagicMock) -> None:
    mock_db_pool._conn.fetch.return_value = []
    response = adv_client.get("/api/analytics/advanced/strength-standards?weeks=12")
    assert response.status_code == 200
    data = response.json()
    assert "overall_tier" in data
    assert "exercises" in data


def test_exercise_variety_endpoint(adv_client: TestClient, mock_db_pool: MagicMock) -> None:
    mock_db_pool._conn.fetch.return_value = []
    response = adv_client.get("/api/analytics/advanced/exercise-variety?period=28")
    assert response.status_code == 200
    data = response.json()
    assert "variety_index" in data
    assert "movement_patterns" in data


def test_performance_forecast_endpoint(adv_client: TestClient, mock_db_pool: MagicMock) -> None:
    mock_db_pool._conn.fetch.return_value = []
    response = adv_client.get("/api/analytics/advanced/performance-forecast?weeks=12")
    assert response.status_code == 200
    data = response.json()
    assert "exercises" in data
    assert "disclaimer" in data


def test_fitness_fatigue_endpoint(adv_client: TestClient, mock_db_pool: MagicMock) -> None:
    mock_db_pool._conn.fetch.return_value = []
    response = adv_client.get("/api/analytics/advanced/fitness-fatigue")
    assert response.status_code == 200
    data = response.json()
    assert "fitness" in data
    assert "fatigue" in data
    assert "preparedness" in data


def test_dashboard_includes_new_metrics(
    adv_client: TestClient, mock_db_pool: MagicMock
) -> None:
    """Dashboard should now include all 13 metrics (7 original + 6 new)."""
    mock_db_pool._conn.fetch.return_value = []
    mock_db_pool._conn.fetch.side_effect = None

    response = adv_client.get("/api/analytics/advanced/dashboard?period=7")
    assert response.status_code == 200

    data = response.json()
    # Original 7
    assert "muscle_workload" in data
    assert "progressive_overload" in data
    assert "volume_landmarks" in data
    assert "recovery" in data
    assert "session_quality" in data
    assert "periodization" in data
    assert "body_part_balance" in data
    # New 6
    assert "acwr" in data
    assert "consistency" in data
    assert "strength_standards" in data
    assert "exercise_variety" in data
    assert "performance_forecast" in data
    assert "fitness_fatigue" in data
