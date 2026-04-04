"""Tests for the 7 deep analytics services (2026-03-25).

Services tested:
  - Bilateral Asymmetry (LSI)
  - Body Composition (BMI, FFMI, EMA weight trend)
  - Training Density (sets/hour, volume/minute)
  - Sleep-Performance Correlation (Spearman)
  - Time-of-Day Performance
  - Rest Period Analysis
  - Relative Strength (DOTS)
"""

from datetime import UTC, date, datetime
from unittest.mock import MagicMock

from app.services.bilateral_asymmetry_service import (
    _classify_severity,
    compute_bilateral_asymmetry,
)
from app.services.body_composition_service import (
    _classify_bmi,
    _classify_ffmi,
    compute_body_composition,
)
from app.services.relative_strength_service import (
    _dots_coefficient,
    compute_relative_strength,
)
from app.services.rest_analysis_service import (
    _classify_mechanic,
    compute_rest_analysis,
)
from app.services.sleep_performance_service import (
    _confidence_tier,
    _correlation_label,
    _spearman,
    compute_sleep_performance,
)
from app.services.time_performance_service import (
    _get_window,
    compute_time_performance,
)
from app.services.training_density_service import (
    _linear_regression,
    compute_training_density,
)
from tests.conftest import FAKE_USER_ID

# ── Fixtures ─────────────────────────────────────────────────────────────────

NOW = datetime.now(UTC)
TODAY = date.today()


# ═════════════════════════════════════════════════════════════════════════════
# BILATERAL ASYMMETRY SERVICE
# ═════════════════════════════════════════════════════════════════════════════


def test_classify_severity_normal() -> None:
    assert _classify_severity(5.0) == "normal"
    assert _classify_severity(0.0) == "normal"
    assert _classify_severity(7.9) == "normal"


def test_classify_severity_monitor() -> None:
    assert _classify_severity(8.0) == "monitor"
    assert _classify_severity(12.0) == "monitor"
    assert _classify_severity(15.0) == "monitor"


def test_classify_severity_significant() -> None:
    assert _classify_severity(15.1) == "significant"
    assert _classify_severity(25.0) == "significant"


async def test_bilateral_asymmetry_cold_start(mock_db_pool: MagicMock) -> None:
    mock_db_pool._conn.fetch.return_value = []
    result = await compute_bilateral_asymmetry(FAKE_USER_ID, mock_db_pool)

    assert result.exercises == []
    assert result.flagged_count == 0
    assert result.normal_count == 0
    assert result.avg_asymmetry is None
    assert result.disclaimer != ""


# ═════════════════════════════════════════════════════════════════════════════
# BODY COMPOSITION SERVICE
# ═════════════════════════════════════════════════════════════════════════════


def test_classify_bmi_categories() -> None:
    assert _classify_bmi(17.0) == "underweight"
    assert _classify_bmi(22.0) == "normal"
    assert _classify_bmi(27.0) == "overweight"
    assert _classify_bmi(32.0) == "obese"


def test_classify_ffmi_male() -> None:
    assert _classify_ffmi(17.0, "male") == "below_average"
    assert _classify_ffmi(19.0, "male") == "average"
    assert _classify_ffmi(21.0, "male") == "above_average"
    assert _classify_ffmi(23.0, "male") == "excellent"
    assert _classify_ffmi(26.0, "male") == "exceptional"


def test_classify_ffmi_female() -> None:
    assert _classify_ffmi(14.0, "female") == "below_average"
    assert _classify_ffmi(16.0, "female") == "average"
    assert _classify_ffmi(18.0, "female") == "above_average"
    assert _classify_ffmi(20.0, "female") == "excellent"
    assert _classify_ffmi(23.0, "female") == "exceptional"


async def test_body_composition_cold_start(mock_db_pool: MagicMock) -> None:
    """No weight entries should return None fields."""
    mock_db_pool._conn.fetch.return_value = []
    mock_db_pool._conn.fetchrow.return_value = {"height_cm": 180, "sex": "male"}

    result = await compute_body_composition(FAKE_USER_ID, mock_db_pool)

    assert result.current_weight_kg is None
    assert result.bmi is None
    assert result.ffmi is None
    assert result.weight_trend == []
    assert result.data_points == 0
    assert result.disclaimer != ""


# ═════════════════════════════════════════════════════════════════════════════
# TRAINING DENSITY SERVICE
# ═════════════════════════════════════════════════════════════════════════════


def test_linear_regression_perfect_line() -> None:
    """xs=[1,2,3,4,5], ys=[2,4,6,8,10] should give slope=2.0."""
    slope, intercept = _linear_regression(
        [1.0, 2.0, 3.0, 4.0, 5.0],
        [2.0, 4.0, 6.0, 8.0, 10.0],
    )
    assert slope is not None
    assert intercept is not None
    assert abs(slope - 2.0) < 0.001
    assert abs(intercept - 0.0) < 0.001


def test_linear_regression_insufficient_points() -> None:
    """Fewer than 3 points should return (None, None)."""
    slope, intercept = _linear_regression([1.0, 2.0], [3.0, 5.0])
    assert slope is None
    assert intercept is None


def test_linear_regression_flat_line() -> None:
    slope, intercept = _linear_regression(
        [1.0, 2.0, 3.0, 4.0],
        [5.0, 5.0, 5.0, 5.0],
    )
    assert slope is not None
    assert abs(slope) < 0.001


async def test_training_density_cold_start(mock_db_pool: MagicMock) -> None:
    mock_db_pool._conn.fetch.return_value = []
    result = await compute_training_density(FAKE_USER_ID, mock_db_pool)

    assert result.sessions == []
    assert result.avg_sets_per_hour is None
    assert result.avg_volume_per_minute is None
    assert result.trend_direction == "stable"
    assert result.trend_slope is None
    assert result.disclaimer != ""


# ═════════════════════════════════════════════════════════════════════════════
# SLEEP-PERFORMANCE SERVICE
# ═════════════════════════════════════════════════════════════════════════════


def test_spearman_perfect_positive() -> None:
    """Identical rankings should yield rho = 1.0."""
    rho = _spearman([1.0, 2.0, 3.0, 4.0, 5.0], [1.0, 2.0, 3.0, 4.0, 5.0])
    assert rho is not None
    assert abs(rho - 1.0) < 0.001


def test_spearman_perfect_negative() -> None:
    """Reversed rankings should yield rho = -1.0."""
    rho = _spearman([1.0, 2.0, 3.0, 4.0, 5.0], [5.0, 4.0, 3.0, 2.0, 1.0])
    assert rho is not None
    assert abs(rho - (-1.0)) < 0.001


def test_spearman_insufficient_data() -> None:
    """Fewer than 5 data points should return None."""
    assert _spearman([1.0, 2.0, 3.0], [3.0, 2.0, 1.0]) is None


def test_confidence_tier_levels() -> None:
    assert _confidence_tier(3) == "insufficient"
    assert _confidence_tier(7) == "preliminary"
    assert _confidence_tier(15) == "moderate"
    assert _confidence_tier(25) == "reliable"


def test_correlation_label_categories() -> None:
    assert _correlation_label(None) == "insufficient_data"
    assert _correlation_label(0.1) == "weak"
    assert _correlation_label(0.4) == "moderate"
    assert _correlation_label(0.8) == "strong"
    assert _correlation_label(-0.7) == "strong"


async def test_sleep_performance_cold_start(mock_db_pool: MagicMock) -> None:
    mock_db_pool._conn.fetch.return_value = []
    result = await compute_sleep_performance(FAKE_USER_ID, mock_db_pool)

    assert result.correlation_sleep_volume is None
    assert result.correlation_sleep_e1rm is None
    assert result.correlation_sleep_rpe is None
    assert result.correlation_label == "insufficient_data"
    assert result.confidence == "insufficient"
    assert result.sleep_buckets == []
    assert result.avg_sleep_hours is None
    assert result.data_points == 0
    assert result.disclaimer != ""


# ═════════════════════════════════════════════════════════════════════════════
# TIME-PERFORMANCE SERVICE
# ═════════════════════════════════════════════════════════════════════════════


def test_get_window_morning() -> None:
    assert _get_window(6) == "morning"
    assert _get_window(5) == "morning"
    assert _get_window(11) == "morning"


def test_get_window_afternoon() -> None:
    assert _get_window(12) == "afternoon"
    assert _get_window(15) == "afternoon"
    assert _get_window(16) == "afternoon"


def test_get_window_evening() -> None:
    assert _get_window(17) == "evening"
    assert _get_window(19) == "evening"
    assert _get_window(20) == "evening"


def test_get_window_night() -> None:
    assert _get_window(21) == "night"
    assert _get_window(23) == "night"
    assert _get_window(0) == "night"
    assert _get_window(4) == "night"


async def test_time_performance_cold_start(mock_db_pool: MagicMock) -> None:
    """Profile with timezone but no sets should return empty windows."""
    mock_db_pool._conn.fetchrow.return_value = {"timezone": "America/New_York"}
    mock_db_pool._conn.fetch.return_value = []
    result = await compute_time_performance(FAKE_USER_ID, mock_db_pool)

    assert len(result.windows) == 4
    assert result.best_window is None
    assert result.best_window_advantage_pct is None
    assert result.disclaimer != ""


# ═════════════════════════════════════════════════════════════════════════════
# REST ANALYSIS SERVICE
# ═════════════════════════════════════════════════════════════════════════════


def test_classify_mechanic_values() -> None:
    assert _classify_mechanic("compound") == "compound"
    assert _classify_mechanic("Compound") == "compound"
    assert _classify_mechanic("isolation") == "isolation"
    assert _classify_mechanic("isolated") == "isolation"
    assert _classify_mechanic("other") == "unknown"


async def test_rest_analysis_cold_start(mock_db_pool: MagicMock) -> None:
    """No rest data should return empty distributions and no flags."""
    mock_db_pool._conn.fetch.return_value = []
    mock_db_pool._conn.fetchrow.return_value = {"total_working_sets": 0}
    mock_db_pool._conn.fetchval.return_value = 0

    result = await compute_rest_analysis(FAKE_USER_ID, mock_db_pool)

    assert result.by_type == []
    assert result.overall_avg_rest is None
    assert result.overall_median_rest is None
    assert result.disclaimer != ""


# ═════════════════════════════════════════════════════════════════════════════
# RELATIVE STRENGTH SERVICE (DOTS)
# ═════════════════════════════════════════════════════════════════════════════


def test_dots_coefficient_male_80kg() -> None:
    """DOTS coefficient for 80kg male should be a reasonable positive number."""
    coeff = _dots_coefficient(80.0, "male")
    assert 0.5 < coeff < 1.0


def test_dots_coefficient_female() -> None:
    coeff = _dots_coefficient(60.0, "female")
    assert coeff > 0


def test_dots_coefficient_clamp_low_bw() -> None:
    """Very low BW (30 kg) should be clamped to 40 kg internally."""
    coeff_30 = _dots_coefficient(30.0, "male")
    coeff_40 = _dots_coefficient(40.0, "male")
    assert coeff_30 == coeff_40  # Clamped to same value


def test_dots_coefficient_clamp_high_bw() -> None:
    """Very high BW (250 kg) should be clamped to 200 kg internally."""
    coeff_250 = _dots_coefficient(250.0, "male")
    coeff_200 = _dots_coefficient(200.0, "male")
    assert coeff_250 == coeff_200


async def test_relative_strength_cold_start(mock_db_pool: MagicMock) -> None:
    """No body weight logged should return empty exercises."""
    mock_db_pool._conn.fetchrow.return_value = None
    mock_db_pool._conn.fetch.return_value = []

    result = await compute_relative_strength(FAKE_USER_ID, mock_db_pool)

    assert result.exercises == []
    assert result.total_dots is None
    assert result.bodyweight_kg is None
    assert result.trend == []
    assert result.disclaimer != ""


async def test_relative_strength_no_bw_with_profile(mock_db_pool: MagicMock) -> None:
    """Profile exists but no body weight entry should still return empty exercises."""
    call_count = 0

    async def fetchrow_side_effect(*args, **kwargs):
        nonlocal call_count
        call_count += 1
        if call_count == 1:
            return None  # No body weight
        if call_count == 2:
            return {"sex": "male"}  # Profile exists
        return None

    mock_db_pool._conn.fetchrow.side_effect = fetchrow_side_effect
    mock_db_pool._conn.fetch.return_value = []

    result = await compute_relative_strength(FAKE_USER_ID, mock_db_pool)

    assert result.exercises == []
    assert result.bodyweight_kg is None
    assert result.disclaimer != ""
