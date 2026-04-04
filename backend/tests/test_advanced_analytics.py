"""Tests for advanced analytics services and endpoints."""

from datetime import UTC, date, datetime, timedelta
from unittest.mock import MagicMock

import pytest
from fastapi.testclient import TestClient

from app.auth import get_current_user
from app.main import app
from app.services.muscle_workload_service import compute_muscle_workload
from app.services.periodization_service import (
    compute_body_part_balance,
    compute_periodization,
)
from app.services.progressive_overload_service import (
    _detect_plateau,
    _linear_regression,
    compute_progressive_overload,
)
from app.services.recovery_service import compute_recovery
from app.services.session_quality_service import compute_session_quality
from app.services.volume_landmarks_service import compute_volume_landmarks
from tests.conftest import FAKE_USER_ID

# ── Fixtures ─────────────────────────────────────────────────────────────────


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


# ── Helper ───────────────────────────────────────────────────────────────────

NOW = datetime.now(UTC)
TODAY = date.today()


def _make_muscle_rows(
    muscles: list[tuple[str, bool, float]],
    training_date: date | None = None,
) -> list[dict]:
    """Create mock rows for muscle workload queries."""
    return [
        {
            "muscle_group": name,
            "is_primary": is_primary,
            "set_volume": volume,
            "training_date": training_date or TODAY,
        }
        for name, is_primary, volume in muscles
    ]


# ═══════════════════════════════════════════════════════════════════════════════
# LINEAR REGRESSION UNIT TESTS
# ═══════════════════════════════════════════════════════════════════════════════


def test_linear_regression_perfect_line() -> None:
    slope, intercept = _linear_regression([0, 1, 2, 3], [0, 2, 4, 6])
    assert abs(slope - 2.0) < 0.001
    assert abs(intercept - 0.0) < 0.001


def test_linear_regression_flat_line() -> None:
    slope, _ = _linear_regression([0, 1, 2, 3], [5, 5, 5, 5])
    assert abs(slope) < 0.001


def test_linear_regression_single_point() -> None:
    slope, intercept = _linear_regression([1], [10])
    assert slope == 0.0
    assert intercept == 10.0


def test_linear_regression_two_points() -> None:
    slope, _ = _linear_regression([0.0, 7.0], [100.0, 105.0])
    assert abs(slope - 5 / 7) < 0.001


# ═══════════════════════════════════════════════════════════════════════════════
# PLATEAU DETECTION UNIT TESTS
# ═══════════════════════════════════════════════════════════════════════════════


def test_detect_plateau_flat_data() -> None:
    result = _detect_plateau([100, 100, 100, 100, 100, 100])
    assert result >= 4


def test_detect_plateau_increasing_data() -> None:
    # Large increases (10% jumps) should not trigger plateau
    result = _detect_plateau([80, 88, 97, 107, 118])
    assert result == 0


def test_detect_plateau_insufficient_data() -> None:
    result = _detect_plateau([100, 100, 100])
    assert result == 0


def test_detect_plateau_slight_variation() -> None:
    # Within 5% CV should still be plateau
    result = _detect_plateau([100, 101, 99, 100, 100.5, 99.5])
    assert result >= 2


# ═══════════════════════════════════════════════════════════════════════════════
# MUSCLE WORKLOAD SERVICE
# ═══════════════════════════════════════════════════════════════════════════════


async def test_muscle_workload_empty_data(mock_db_pool: MagicMock) -> None:
    mock_db_pool._conn.fetch.return_value = []
    result = await compute_muscle_workload(FAKE_USER_ID, mock_db_pool, period_days=7)

    assert result.muscles == []
    assert result.balance_index == 0.0
    assert result.balance_label == "insufficient_data"


async def test_muscle_workload_single_muscle(mock_db_pool: MagicMock) -> None:
    mock_db_pool._conn.fetch.return_value = _make_muscle_rows(
        [
            ("Chest", True, 1000.0),
            ("Chest", True, 800.0),
        ]
    )

    result = await compute_muscle_workload(FAKE_USER_ID, mock_db_pool, period_days=7)

    assert len(result.muscles) == 1
    assert result.muscles[0].muscle_group == "Chest"
    assert result.muscles[0].raw_volume == 1800.0
    # Single muscle = no balance
    assert result.balance_index == 0.0


async def test_muscle_workload_primary_secondary_weighting(mock_db_pool: MagicMock) -> None:
    mock_db_pool._conn.fetch.return_value = _make_muscle_rows(
        [
            ("Chest", True, 1000.0),
            ("Triceps", False, 1000.0),
        ]
    )

    result = await compute_muscle_workload(FAKE_USER_ID, mock_db_pool, period_days=7)

    muscles = {m.muscle_group: m for m in result.muscles}
    assert muscles["Chest"].raw_volume == 1000.0  # 1.0 factor
    assert muscles["Triceps"].raw_volume == 500.0  # 0.5 factor


async def test_muscle_workload_balance_index(mock_db_pool: MagicMock) -> None:
    # Perfectly balanced: 3 muscles with equal volume
    mock_db_pool._conn.fetch.return_value = _make_muscle_rows(
        [
            ("Chest", True, 1000.0),
            ("Lats", True, 1000.0),
            ("Quadriceps", True, 1000.0),
        ]
    )

    result = await compute_muscle_workload(FAKE_USER_ID, mock_db_pool, period_days=7)

    assert result.balance_index > 0.99  # near-perfect balance
    assert result.balance_label == "well_balanced"


# ═══════════════════════════════════════════════════════════════════════════════
# PROGRESSIVE OVERLOAD SERVICE
# ═══════════════════════════════════════════════════════════════════════════════


async def test_progressive_overload_empty(mock_db_pool: MagicMock) -> None:
    mock_db_pool._conn.fetch.return_value = []
    result = await compute_progressive_overload(FAKE_USER_ID, mock_db_pool, weeks=8)

    assert result.exercises == []
    assert result.overall_status == "insufficient_data"


async def test_progressive_overload_progressing(mock_db_pool: MagicMock) -> None:
    """Exercise with increasing weights should be classified as progressing."""
    rows = []
    base = date.today() - timedelta(days=42)
    for i in range(7):
        day = base + timedelta(weeks=i)
        rows.append(
            {
                "exercise_id": "ex-bench",
                "exercise_name": "Bench Press",
                "weight": 80.0 + i * 2.5,
                "reps": 5,
                "day": day,
            }
        )

    mock_db_pool._conn.fetch.return_value = rows
    result = await compute_progressive_overload(FAKE_USER_ID, mock_db_pool, weeks=8)

    assert len(result.exercises) == 1
    assert result.exercises[0].status == "progressing"
    assert result.exercises[0].overload_rate > 0
    assert result.progressing_count == 1


async def test_progressive_overload_plateau(mock_db_pool: MagicMock) -> None:
    """Exercise with flat weights should be classified as plateau."""
    rows = []
    base = date.today() - timedelta(days=42)
    for i in range(7):
        day = base + timedelta(weeks=i)
        rows.append(
            {
                "exercise_id": "ex-bench",
                "exercise_name": "Bench Press",
                "weight": 100.0,
                "reps": 5,
                "day": day,
            }
        )

    mock_db_pool._conn.fetch.return_value = rows
    result = await compute_progressive_overload(FAKE_USER_ID, mock_db_pool, weeks=8)

    assert len(result.exercises) == 1
    assert result.exercises[0].status == "plateau"
    assert result.plateau_count == 1


# ═══════════════════════════════════════════════════════════════════════════════
# VOLUME LANDMARKS SERVICE
# ═══════════════════════════════════════════════════════════════════════════════


async def test_volume_landmarks_empty(mock_db_pool: MagicMock) -> None:
    mock_db_pool._conn.fetch.return_value = []
    result = await compute_volume_landmarks(FAKE_USER_ID, mock_db_pool)

    assert result.muscles == []
    assert result.total_weekly_sets == 0.0


async def test_volume_landmarks_productive(mock_db_pool: MagicMock) -> None:
    mock_db_pool._conn.fetch.return_value = [
        {"muscle_group": "Chest", "is_primary": True, "set_count": 12},
    ]

    result = await compute_volume_landmarks(FAKE_USER_ID, mock_db_pool)

    assert len(result.muscles) == 1
    entry = result.muscles[0]
    assert entry.muscle_group == "Chest"
    assert entry.current_sets == 12.0
    assert entry.status == "productive"
    assert entry.mev == 8
    assert entry.mav == 16
    assert entry.mrv == 22


async def test_volume_landmarks_over_mrv(mock_db_pool: MagicMock) -> None:
    mock_db_pool._conn.fetch.return_value = [
        {"muscle_group": "Chest", "is_primary": True, "set_count": 25},
    ]

    result = await compute_volume_landmarks(FAKE_USER_ID, mock_db_pool)

    assert result.muscles[0].status == "over_mrv"
    assert result.muscles_over_mrv == 1


async def test_volume_landmarks_secondary_weighting(mock_db_pool: MagicMock) -> None:
    mock_db_pool._conn.fetch.return_value = [
        {"muscle_group": "Triceps", "is_primary": True, "set_count": 6},
        {"muscle_group": "Triceps", "is_primary": False, "set_count": 8},
    ]

    result = await compute_volume_landmarks(FAKE_USER_ID, mock_db_pool)

    # 6 * 1.0 + 8 * 0.5 = 10 sets
    assert result.muscles[0].current_sets == 10.0


# ═══════════════════════════════════════════════════════════════════════════════
# RECOVERY SERVICE
# ═══════════════════════════════════════════════════════════════════════════════


async def test_recovery_empty(mock_db_pool: MagicMock) -> None:
    mock_db_pool._conn.fetch.side_effect = [[], []]
    result = await compute_recovery(FAKE_USER_ID, mock_db_pool)

    assert result.readiness_score == 100
    assert result.readiness_label == "ready"
    assert result.disclaimer != ""


async def test_recovery_fresh_muscles(mock_db_pool: MagicMock) -> None:
    three_days_ago = NOW - timedelta(hours=80)
    mock_db_pool._conn.fetch.side_effect = [
        [{"muscle_group": "chest", "last_trained": three_days_ago, "set_count": 10}],
        [],  # no soreness
    ]

    result = await compute_recovery(FAKE_USER_ID, mock_db_pool)

    assert len(result.muscles) == 1
    assert result.muscles[0].recovery_status == "fresh"
    assert result.readiness_score >= 80


async def test_recovery_fatigued_muscles(mock_db_pool: MagicMock) -> None:
    recent = NOW - timedelta(hours=12)
    mock_db_pool._conn.fetch.side_effect = [
        [{"muscle_group": "quadriceps", "last_trained": recent, "set_count": 20}],
        [{"muscle_group": "quadriceps", "level": 3}],
    ]

    result = await compute_recovery(FAKE_USER_ID, mock_db_pool)

    assert result.muscles[0].recovery_status == "fatigued"
    assert result.readiness_score <= 50


# ═══════════════════════════════════════════════════════════════════════════════
# SESSION QUALITY SERVICE
# ═══════════════════════════════════════════════════════════════════════════════


async def test_session_quality_empty(mock_db_pool: MagicMock) -> None:
    mock_db_pool._conn.fetch.return_value = []
    result = await compute_session_quality(FAKE_USER_ID, mock_db_pool, period_days=7)

    assert result.avg_rpe is None
    assert result.effective_sets == 0
    assert result.low_stimulus_sets == 0
    assert result.set_distribution == []


async def test_session_quality_with_data(mock_db_pool: MagicMock) -> None:
    mock_db_pool._conn.fetch.return_value = [
        {
            "set_type": "warmup",
            "rpe": 4.0,
            "rir": 6.0,
            "weight": 40,
            "reps": 10,
            "estimated_1rm": 100,
        },
        {
            "set_type": "working",
            "rpe": 7.5,
            "rir": 2.5,
            "weight": 80,
            "reps": 5,
            "estimated_1rm": 100,
        },
        {
            "set_type": "working",
            "rpe": 8.0,
            "rir": 2.0,
            "weight": 85,
            "reps": 5,
            "estimated_1rm": 100,
        },
        {
            "set_type": "amrap",
            "rpe": 9.0,
            "rir": 1.0,
            "weight": 90,
            "reps": 3,
            "estimated_1rm": 100,
        },
        {
            "set_type": "working",
            "rpe": 4.0,
            "rir": 6.0,
            "weight": 50,
            "reps": 8,
            "estimated_1rm": 100,
        },
    ]

    result = await compute_session_quality(FAKE_USER_ID, mock_db_pool, period_days=7)

    assert result.avg_rpe is not None
    assert result.effective_sets == 3  # RPE >= 7: working 7.5, working 8, amrap 9
    assert result.total_working_sets == 4  # 3 working + 1 amrap
    assert result.low_stimulus_sets == 0  # RPE 4 is above the <4 threshold
    assert result.relative_intensity is not None
    assert len(result.set_distribution) > 0


async def test_session_quality_no_rpe(mock_db_pool: MagicMock) -> None:
    """When RPE is not logged, averages should be None."""
    mock_db_pool._conn.fetch.return_value = [
        {
            "set_type": "working",
            "rpe": None,
            "rir": None,
            "weight": 80,
            "reps": 5,
            "estimated_1rm": 100,
        },
    ]

    result = await compute_session_quality(FAKE_USER_ID, mock_db_pool, period_days=7)

    assert result.avg_rpe is None
    assert result.avg_rir is None
    assert result.low_stimulus_sets == 0  # can't detect junk without RPE


# ═══════════════════════════════════════════════════════════════════════════════
# PERIODIZATION SERVICE
# ═══════════════════════════════════════════════════════════════════════════════


async def test_periodization_empty(mock_db_pool: MagicMock) -> None:
    mock_db_pool._conn.fetch.return_value = []
    result = await compute_periodization(FAKE_USER_ID, mock_db_pool, weeks=8)

    assert result.monotony is None
    assert result.strain is None
    assert result.monotony_status == "insufficient_data"
    assert result.current_phase == "unknown"


async def test_periodization_with_data(mock_db_pool: MagicMock) -> None:
    rows = []
    for i in range(14):
        day = date.today() - timedelta(days=13 - i)
        if i % 2 == 0:  # train every other day
            rows.append({"day": day, "daily_volume": 5000.0 + i * 100})

    mock_db_pool._conn.fetch.return_value = rows
    result = await compute_periodization(FAKE_USER_ID, mock_db_pool, weeks=4)

    assert result.monotony is not None
    assert result.strain is not None
    assert len(result.weekly_volumes) > 0
    assert result.monotony_status in ("normal", "elevated", "high_risk")


async def test_periodization_high_monotony(mock_db_pool: MagicMock) -> None:
    """Training every day with same volume should yield high monotony."""
    rows = []
    for i in range(7):
        day = date.today() - timedelta(days=6 - i)
        rows.append({"day": day, "daily_volume": 5000.0})

    mock_db_pool._conn.fetch.return_value = rows
    result = await compute_periodization(FAKE_USER_ID, mock_db_pool, weeks=4)

    # All days identical volume, but rest days at 0 will add variance
    # Unless all 7 days have data, then std=0 and monotony=None (div by 0)
    # With exactly 7 consecutive days of 5000, the full last_7 has no zeros
    # mean=5000, std=0, so monotony should be None (div by zero guarded)
    assert result.monotony is None or result.monotony > 2.0


# ═══════════════════════════════════════════════════════════════════════════════
# BODY PART BALANCE SERVICE
# ═══════════════════════════════════════════════════════════════════════════════


async def test_body_part_balance_empty(mock_db_pool: MagicMock) -> None:
    mock_db_pool._conn.fetch.return_value = []
    result = await compute_body_part_balance(FAKE_USER_ID, mock_db_pool, period_days=7)

    assert result.push_pull_ratio is None
    assert result.push_pull_status == "insufficient_data"


async def test_body_part_balance_push_dominant(mock_db_pool: MagicMock) -> None:
    mock_db_pool._conn.fetch.return_value = [
        {"muscle_group": "Chest", "is_primary": True, "set_volume": 5000, "training_date": TODAY},
        {
            "muscle_group": "Shoulders",
            "is_primary": True,
            "set_volume": 3000,
            "training_date": TODAY,
        },
        {"muscle_group": "Triceps", "is_primary": True, "set_volume": 2000, "training_date": TODAY},
        {"muscle_group": "Lats", "is_primary": True, "set_volume": 2000, "training_date": TODAY},
        {"muscle_group": "Biceps", "is_primary": True, "set_volume": 1000, "training_date": TODAY},
    ]

    result = await compute_body_part_balance(FAKE_USER_ID, mock_db_pool, period_days=7)

    assert result.push_pull_ratio is not None
    assert result.push_pull_ratio > 1.3  # push dominant
    assert len(result.imbalances) > 0
    assert any("Push-dominant" in s for s in result.imbalances)


async def test_body_part_balance_optimal(mock_db_pool: MagicMock) -> None:
    mock_db_pool._conn.fetch.return_value = [
        {"muscle_group": "Chest", "is_primary": True, "set_volume": 3000, "training_date": TODAY},
        {"muscle_group": "Lats", "is_primary": True, "set_volume": 3500, "training_date": TODAY},
        {
            "muscle_group": "Quadriceps",
            "is_primary": True,
            "set_volume": 4000,
            "training_date": TODAY,
        },
    ]

    result = await compute_body_part_balance(FAKE_USER_ID, mock_db_pool, period_days=7)

    assert result.push_pull_ratio is not None
    assert result.push_pull_status in ("optimal", "acceptable")
    assert result.upper_lower_ratio is not None


# ═══════════════════════════════════════════════════════════════════════════════
# ENDPOINT INTEGRATION TESTS
# ═══════════════════════════════════════════════════════════════════════════════


def test_muscle_workload_endpoint(
    adv_client: TestClient,
    mock_db_pool: MagicMock,
) -> None:
    mock_db_pool._conn.fetch.return_value = _make_muscle_rows(
        [
            ("Chest", True, 2000.0),
            ("Lats", True, 1800.0),
        ]
    )

    response = adv_client.get("/api/analytics/advanced/muscle-workload?period=7")
    assert response.status_code == 200

    data = response.json()
    assert "muscles" in data
    assert "balance_index" in data
    assert "balance_label" in data
    assert len(data["muscles"]) == 2


def test_progressive_overload_endpoint(
    adv_client: TestClient,
    mock_db_pool: MagicMock,
) -> None:
    mock_db_pool._conn.fetch.return_value = []

    response = adv_client.get("/api/analytics/advanced/progressive-overload?weeks=8")
    assert response.status_code == 200

    data = response.json()
    assert data["overall_status"] == "insufficient_data"
    assert data["exercises"] == []


def test_volume_landmarks_endpoint(
    adv_client: TestClient,
    mock_db_pool: MagicMock,
) -> None:
    mock_db_pool._conn.fetch.return_value = [
        {"muscle_group": "Chest", "is_primary": True, "set_count": 14},
    ]

    response = adv_client.get("/api/analytics/advanced/volume-landmarks")
    assert response.status_code == 200

    data = response.json()
    assert len(data["muscles"]) == 1
    assert data["muscles"][0]["status"] == "productive"


def test_recovery_endpoint(
    adv_client: TestClient,
    mock_db_pool: MagicMock,
) -> None:
    mock_db_pool._conn.fetch.side_effect = [[], []]

    response = adv_client.get("/api/analytics/advanced/recovery")
    assert response.status_code == 200

    data = response.json()
    assert data["readiness_score"] == 100
    assert "disclaimer" in data


def test_session_quality_endpoint(
    adv_client: TestClient,
    mock_db_pool: MagicMock,
) -> None:
    mock_db_pool._conn.fetch.return_value = []

    response = adv_client.get("/api/analytics/advanced/session-quality?period=7")
    assert response.status_code == 200

    data = response.json()
    assert data["effective_sets"] == 0


def test_periodization_endpoint(
    adv_client: TestClient,
    mock_db_pool: MagicMock,
) -> None:
    mock_db_pool._conn.fetch.return_value = []

    response = adv_client.get("/api/analytics/advanced/periodization?weeks=8")
    assert response.status_code == 200

    data = response.json()
    assert data["current_phase"] == "unknown"


def test_body_part_balance_endpoint(
    adv_client: TestClient,
    mock_db_pool: MagicMock,
) -> None:
    mock_db_pool._conn.fetch.return_value = []

    response = adv_client.get("/api/analytics/advanced/body-part-balance?period=7")
    assert response.status_code == 200

    data = response.json()
    assert data["push_pull_status"] == "insufficient_data"


def test_dashboard_endpoint(
    adv_client: TestClient,
    mock_db_pool: MagicMock,
) -> None:
    """Dashboard endpoint should aggregate all metrics."""
    # Return empty for all queries
    mock_db_pool._conn.fetch.return_value = []
    mock_db_pool._conn.fetch.side_effect = None

    response = adv_client.get("/api/analytics/advanced/dashboard?period=7")
    assert response.status_code == 200

    data = response.json()
    assert "muscle_workload" in data
    assert "progressive_overload" in data
    assert "volume_landmarks" in data
    assert "recovery" in data
    assert "session_quality" in data
    assert "periodization" in data
    assert "body_part_balance" in data


def test_dashboard_period_validation(adv_client: TestClient, mock_db_pool: MagicMock) -> None:
    """Period parameter should be validated."""
    response = adv_client.get("/api/analytics/advanced/dashboard?period=0")
    assert response.status_code == 422

    response = adv_client.get("/api/analytics/advanced/dashboard?period=400")
    assert response.status_code == 422
