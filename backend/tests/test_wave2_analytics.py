"""Tests for wave-2 analytics services.

Services tested:
  - Plan Adherence (linear regression, trend classification)
  - Antagonist Balance (pair classification)
  - Tempo Analysis (parse, TUT computation, TUT classification)
  - Soreness Patterns (Spearman correlation, trend detection, red flags)
  - Equipment Efficiency (linear regression)
  - Milestone Velocity (trend computation)
  - Training Readiness (sleep score, soreness score, ACWR score, composite)
"""

from datetime import UTC, date, datetime, timedelta
from unittest.mock import AsyncMock, MagicMock, patch

from app.models.schemas import ReadinessDimension
from app.services.antagonist_balance_service import (
    _classify_pair,
    _recommendation_for_pair,
    compute_antagonist_balance,
)
from app.services.equipment_efficiency_service import (
    _linear_regression as ee_linear_regression,
)
from app.services.equipment_efficiency_service import (
    compute_equipment_efficiency,
)
from app.services.milestone_velocity_service import (
    _compute_trend as milestone_compute_trend,
)
from app.services.milestone_velocity_service import (
    compute_milestone_velocity,
)
from app.services.plan_adherence_service import (
    _classify_trend,
    compute_plan_adherence,
)
from app.services.plan_adherence_service import (
    _linear_regression as pa_linear_regression,
)
from app.services.soreness_patterns_service import (
    _compute_trend as soreness_compute_trend,
)
from app.services.soreness_patterns_service import (
    _detect_red_flags,
    _rank,
    compute_soreness_patterns,
)
from app.services.soreness_patterns_service import (
    _spearman as soreness_spearman,
)
from app.services.tempo_analysis_service import (
    _classify_tut,
    _compute_tut,
    _parse_tempo,
    compute_tempo_analysis,
)
from app.services.training_readiness_service import (
    _acwr_score,
    _build_composite,
    _preparedness_score,
    _readiness_label,
    _sleep_score,
    _soreness_score,
    compute_training_readiness,
)
from tests.conftest import FAKE_USER_ID

# -- Fixtures -----------------------------------------------------------------

NOW = datetime.now(UTC)
TODAY = date.today()


# =============================================================================
# PLAN ADHERENCE SERVICE
# =============================================================================


def test_pa_linear_regression_perfect_line() -> None:
    """xs=[0,1,2,3], ys=[1,3,5,7] should give slope=2.0."""
    slope, intercept = pa_linear_regression(
        [0.0, 1.0, 2.0, 3.0],
        [1.0, 3.0, 5.0, 7.0],
    )
    assert slope is not None
    assert intercept is not None
    assert abs(slope - 2.0) < 0.001
    assert abs(intercept - 1.0) < 0.001


def test_pa_linear_regression_insufficient_points() -> None:
    """Fewer than 4 points should return (None, None)."""
    slope, intercept = pa_linear_regression([1.0, 2.0, 3.0], [1.0, 2.0, 3.0])
    assert slope is None
    assert intercept is None


def test_pa_linear_regression_flat_line() -> None:
    slope, intercept = pa_linear_regression(
        [0.0, 1.0, 2.0, 3.0],
        [5.0, 5.0, 5.0, 5.0],
    )
    assert slope is not None
    assert abs(slope) < 0.001


def test_pa_linear_regression_zero_variance_x() -> None:
    """All x values identical should return slope=0.0."""
    slope, intercept = pa_linear_regression(
        [1.0, 1.0, 1.0, 1.0],
        [2.0, 4.0, 6.0, 8.0],
    )
    assert slope == 0.0
    assert intercept is not None


def test_classify_trend_improving() -> None:
    assert _classify_trend(0.05) == "improving"


def test_classify_trend_declining() -> None:
    assert _classify_trend(-0.05) == "declining"


def test_classify_trend_stable() -> None:
    assert _classify_trend(0.0) == "stable"
    assert _classify_trend(0.01) == "stable"
    assert _classify_trend(-0.01) == "stable"


def test_classify_trend_none() -> None:
    assert _classify_trend(None) == "insufficient_data"


async def test_plan_adherence_cold_start(mock_db_pool: MagicMock) -> None:
    mock_db_pool._conn.fetch.return_value = []
    result = await compute_plan_adherence(FAKE_USER_ID, mock_db_pool)

    assert result.weeks == []
    assert result.current_adherence is None
    assert result.trend_direction == "insufficient_data"
    assert result.trend_slope is None
    assert result.burnout_risk is False
    assert result.exceedance_weeks == 0
    assert result.disclaimer != ""


# =============================================================================
# ANTAGONIST BALANCE SERVICE
# =============================================================================


def test_classify_pair_balanced() -> None:
    assert _classify_pair("Chest : Lats", 1.0) == "balanced"
    assert _classify_pair("Chest : Lats", 1.3) == "balanced"
    assert _classify_pair("Biceps : Triceps", 1.5) == "balanced"


def test_classify_pair_moderate_imbalance() -> None:
    assert _classify_pair("Chest : Lats", 1.6) == "moderate_imbalance"
    assert _classify_pair("Chest : Lats", 2.0) == "moderate_imbalance"


def test_classify_pair_significant_imbalance() -> None:
    assert _classify_pair("Chest : Lats", 2.1) == "significant_imbalance"
    assert _classify_pair("Chest : Lats", 3.0) == "significant_imbalance"


def test_classify_pair_insufficient_data() -> None:
    assert _classify_pair("Chest : Lats", None) == "insufficient_data"


def test_classify_pair_hamstring_quad_balanced() -> None:
    assert _classify_pair("Hamstring : Quad", 0.85) == "balanced"
    assert _classify_pair("Hamstring : Quad", 1.0) == "balanced"


def test_classify_pair_hamstring_quad_moderate() -> None:
    assert _classify_pair("Hamstring : Quad", 0.7) == "moderate_imbalance"
    assert _classify_pair("Hamstring : Quad", 0.79) == "moderate_imbalance"


def test_classify_pair_hamstring_quad_significant() -> None:
    assert _classify_pair("Hamstring : Quad", 0.5) == "significant_imbalance"
    assert _classify_pair("Hamstring : Quad", 0.3) == "significant_imbalance"


def test_recommendation_for_pair_balanced() -> None:
    rec = _recommendation_for_pair("Chest : Lats", "Chest", "Lats", 100, 100, "balanced")
    assert "well-balanced" in rec.lower() or "keep it up" in rec.lower()


def test_recommendation_for_pair_imbalance() -> None:
    rec = _recommendation_for_pair("Chest : Lats", "Chest", "Lats", 200, 100, "moderate_imbalance")
    assert "Lats" in rec


async def test_antagonist_balance_cold_start(mock_db_pool: MagicMock) -> None:
    """No antagonist pairs defined should return empty response."""
    mock_db_pool._conn.fetch.return_value = []
    result = await compute_antagonist_balance(FAKE_USER_ID, mock_db_pool)

    assert result.pairs == []
    assert result.imbalanced_count == 0
    assert result.balanced_count == 0
    assert result.disclaimer != ""


# =============================================================================
# TEMPO ANALYSIS SERVICE
# =============================================================================


def test_parse_tempo_standard() -> None:
    assert _parse_tempo("3010") == (3, 0, 1, 0)


def test_parse_tempo_explosive_x() -> None:
    """X should be interpreted as 1 second."""
    assert _parse_tempo("30X0") == (3, 0, 1, 0)


def test_parse_tempo_all_digits() -> None:
    assert _parse_tempo("4211") == (4, 2, 1, 1)


def test_parse_tempo_empty() -> None:
    assert _parse_tempo("") is None


def test_parse_tempo_whitespace_only() -> None:
    assert _parse_tempo("   ") is None


def test_parse_tempo_invalid_letters() -> None:
    assert _parse_tempo("abc") is None


def test_parse_tempo_too_short() -> None:
    assert _parse_tempo("30") is None


def test_parse_tempo_too_long() -> None:
    assert _parse_tempo("30102") is None


def test_compute_tut_standard() -> None:
    """3+0+1+0 = 4 seconds per rep, 10 reps = 40s."""
    assert _compute_tut((3, 0, 1, 0), 10) == 40.0


def test_compute_tut_heavy_eccentric() -> None:
    """5+1+2+1 = 9 seconds per rep, 5 reps = 45s."""
    assert _compute_tut((5, 1, 2, 1), 5) == 45.0


def test_compute_tut_zero_reps() -> None:
    assert _compute_tut((3, 0, 1, 0), 0) == 0.0


def test_classify_tut_strength() -> None:
    assert _classify_tut(15) == "strength"
    assert _classify_tut(0) == "strength"
    assert _classify_tut(19) == "strength"


def test_classify_tut_moderate() -> None:
    assert _classify_tut(20) == "moderate"
    assert _classify_tut(30) == "moderate"
    assert _classify_tut(39) == "moderate"


def test_classify_tut_hypertrophy() -> None:
    assert _classify_tut(40) == "hypertrophy"
    assert _classify_tut(45) == "hypertrophy"
    assert _classify_tut(59) == "hypertrophy"


def test_classify_tut_endurance() -> None:
    assert _classify_tut(60) == "endurance"
    assert _classify_tut(90) == "endurance"
    assert _classify_tut(120) == "endurance"


async def test_tempo_analysis_cold_start(mock_db_pool: MagicMock) -> None:
    """No sets should return cold-start response."""
    mock_db_pool._conn.fetch.return_value = []
    result = await compute_tempo_analysis(FAKE_USER_ID, mock_db_pool)

    assert result.avg_tut_seconds is None
    assert result.sets_with_tempo == 0
    assert result.total_sets == 0
    assert len(result.distribution) == 4
    for entry in result.distribution:
        assert entry.set_count == 0
        assert entry.percentage == 0.0
    assert result.disclaimer != ""


# =============================================================================
# SORENESS PATTERNS SERVICE
# =============================================================================


def test_rank_ascending() -> None:
    assert _rank([1.0, 2.0, 3.0]) == [1.0, 2.0, 3.0]


def test_rank_descending() -> None:
    assert _rank([3.0, 2.0, 1.0]) == [3.0, 2.0, 1.0]


def test_spearman_perfect_positive() -> None:
    """Identical rankings should yield rho close to 1.0."""
    rho = soreness_spearman(
        [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0],
        [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0],
    )
    assert rho is not None
    assert abs(rho - 1.0) < 0.001


def test_spearman_perfect_negative() -> None:
    rho = soreness_spearman(
        [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0],
        [8.0, 7.0, 6.0, 5.0, 4.0, 3.0, 2.0, 1.0],
    )
    assert rho is not None
    assert abs(rho - (-1.0)) < 0.001


def test_spearman_insufficient_data() -> None:
    """Fewer than 8 data points should return None."""
    assert soreness_spearman([1.0, 2.0, 3.0], [3.0, 2.0, 1.0]) is None


def test_soreness_compute_trend_stable() -> None:
    midpoint = TODAY - timedelta(days=15)
    levels = [2.0, 2.0, 2.0, 2.0]
    dates = [
        TODAY - timedelta(days=25),
        TODAY - timedelta(days=20),
        TODAY - timedelta(days=10),
        TODAY - timedelta(days=5),
    ]
    assert soreness_compute_trend(levels, dates, midpoint) == "stable"


def test_soreness_compute_trend_worsening() -> None:
    midpoint = TODAY - timedelta(days=15)
    levels = [1.0, 1.0, 3.0, 3.0]
    dates = [
        TODAY - timedelta(days=25),
        TODAY - timedelta(days=20),
        TODAY - timedelta(days=10),
        TODAY - timedelta(days=5),
    ]
    assert soreness_compute_trend(levels, dates, midpoint) == "worsening"


def test_soreness_compute_trend_improving() -> None:
    midpoint = TODAY - timedelta(days=15)
    levels = [3.0, 3.0, 1.0, 1.0]
    dates = [
        TODAY - timedelta(days=25),
        TODAY - timedelta(days=20),
        TODAY - timedelta(days=10),
        TODAY - timedelta(days=5),
    ]
    assert soreness_compute_trend(levels, dates, midpoint) == "improving"


def test_soreness_compute_trend_single_report() -> None:
    """Single report should be stable."""
    assert soreness_compute_trend([2.0], [TODAY], TODAY) == "stable"


def test_detect_red_flags_severe_persistent() -> None:
    """Level 4 soreness persisting >72h should be flagged."""
    muscle_reports = {
        "1": [{"level": 4, "training_date": TODAY - timedelta(days=5), "lag_hours": 96.0}],
    }
    muscle_names = {1: "Chest"}
    flags = _detect_red_flags(muscle_reports, muscle_names)
    assert len(flags) == 1
    assert "Chest" in flags[0]
    assert "72 hours" in flags[0]


def test_detect_red_flags_escalating() -> None:
    """3 consecutive increasing reports should flag escalation."""
    muscle_reports = {
        "1": [
            {"level": 1, "training_date": TODAY - timedelta(days=6), "lag_hours": 24.0},
            {"level": 2, "training_date": TODAY - timedelta(days=4), "lag_hours": 24.0},
            {"level": 3, "training_date": TODAY - timedelta(days=2), "lag_hours": 24.0},
        ],
    }
    muscle_names = {1: "Quads"}
    flags = _detect_red_flags(muscle_reports, muscle_names)
    assert len(flags) == 1
    assert "Escalating" in flags[0]
    assert "Quads" in flags[0]


def test_detect_red_flags_none() -> None:
    """Normal soreness should not flag anything."""
    muscle_reports = {
        "1": [{"level": 2, "training_date": TODAY - timedelta(days=2), "lag_hours": 24.0}],
    }
    muscle_names = {1: "Chest"}
    flags = _detect_red_flags(muscle_reports, muscle_names)
    assert flags == []


async def test_soreness_patterns_cold_start(mock_db_pool: MagicMock) -> None:
    """Fewer than MIN_REPORTS should return cold-start response."""
    mock_db_pool._conn.fetch.return_value = []
    result = await compute_soreness_patterns(FAKE_USER_ID, mock_db_pool)

    assert result.muscles == []
    assert result.overall_avg_level is None
    assert result.most_sore_muscle is None
    assert result.red_flags == []
    assert result.correlation_volume_soreness is None
    assert result.data_points == 0
    assert result.disclaimer != ""


# =============================================================================
# EQUIPMENT EFFICIENCY SERVICE
# =============================================================================


def test_ee_linear_regression_positive_slope() -> None:
    slope = ee_linear_regression(
        [0.0, 1.0, 2.0, 3.0],
        [100.0, 105.0, 110.0, 115.0],
    )
    assert slope is not None
    assert abs(slope - 5.0) < 0.001


def test_ee_linear_regression_insufficient_points() -> None:
    """Fewer than 4 points should return None."""
    slope = ee_linear_regression([0.0, 1.0, 2.0], [100.0, 105.0, 110.0])
    assert slope is None


def test_ee_linear_regression_flat() -> None:
    slope = ee_linear_regression(
        [0.0, 1.0, 2.0, 3.0],
        [100.0, 100.0, 100.0, 100.0],
    )
    assert slope is not None
    assert abs(slope) < 0.001


def test_ee_linear_regression_zero_variance_x() -> None:
    """All x values identical should return 0.0."""
    slope = ee_linear_regression(
        [5.0, 5.0, 5.0, 5.0],
        [100.0, 110.0, 120.0, 130.0],
    )
    assert slope == 0.0


async def test_equipment_efficiency_cold_start(mock_db_pool: MagicMock) -> None:
    mock_db_pool._conn.fetch.return_value = []
    result = await compute_equipment_efficiency(FAKE_USER_ID, mock_db_pool)

    assert result.equipment == []
    assert result.total_variants_used == 0
    assert result.top_performer is None
    assert result.disclaimer != ""


# =============================================================================
# MILESTONE VELOCITY SERVICE
# =============================================================================


def test_milestone_trend_insufficient_data() -> None:
    """Fewer than 3 intervals should return insufficient_data."""
    assert milestone_compute_trend([], None) == "insufficient_data"
    assert milestone_compute_trend([10], 10.0) == "insufficient_data"
    assert milestone_compute_trend([10, 12], 11.0) == "insufficient_data"


def test_milestone_trend_accelerating() -> None:
    """Recent intervals much shorter than average = accelerating."""
    # Overall avg = 20, last 3 avg = 10 (< 20*0.8=16) => accelerating
    intervals = [10, 10, 10, 30, 30, 30]
    avg = sum(intervals) / len(intervals)
    assert milestone_compute_trend(intervals, avg) == "accelerating"


def test_milestone_trend_decelerating() -> None:
    """Recent intervals much longer than average = decelerating."""
    # Overall avg = 20, last 3 avg = 30 (> 20*1.2=24) => decelerating
    intervals = [30, 30, 30, 10, 10, 10]
    avg = sum(intervals) / len(intervals)
    assert milestone_compute_trend(intervals, avg) == "decelerating"


def test_milestone_trend_stable() -> None:
    """Similar intervals should be stable."""
    intervals = [20, 20, 20, 20, 20, 20]
    avg = sum(intervals) / len(intervals)
    assert milestone_compute_trend(intervals, avg) == "stable"


async def test_milestone_velocity_cold_start(mock_db_pool: MagicMock) -> None:
    mock_db_pool._conn.fetch.return_value = []
    result = await compute_milestone_velocity(FAKE_USER_ID, mock_db_pool)

    assert result.milestones == []
    assert result.total_count == 0
    assert result.milestones_30d == 0
    assert result.milestones_90d == 0
    assert result.avg_interval_days is None
    assert result.velocity_trend == "insufficient_data"
    assert result.disclaimer != ""


# =============================================================================
# TRAINING READINESS SERVICE
# =============================================================================


def test_sleep_score_none_feedback() -> None:
    score, detail = _sleep_score(None)
    assert score is None
    assert "No recent sleep" in detail


def test_sleep_score_quality_only() -> None:
    """Quality 4/5 with no hours should give 80."""
    feedback = {"prior_sleep_quality": 4, "sleep_hours": None}
    score, detail = _sleep_score(feedback)
    assert score == 80
    assert "4/5" in detail


def test_sleep_score_quality_and_hours() -> None:
    """Quality 5/5, 9h sleep => (5/5*0.5 + 9/9*0.5)*100 = 100."""
    feedback = {"prior_sleep_quality": 5, "sleep_hours": 9.0}
    score, detail = _sleep_score(feedback)
    assert score == 100


def test_sleep_score_low_quality_short_hours() -> None:
    """Quality 2/5, 5h sleep => (2/5*0.5 + 5/9*0.5)*100 = (0.2+0.278)*100 = ~48."""
    feedback = {"prior_sleep_quality": 2, "sleep_hours": 5.0}
    score, detail = _sleep_score(feedback)
    assert score is not None
    assert 45 <= score <= 50


def test_sleep_score_no_quality() -> None:
    feedback = {"prior_sleep_quality": None, "sleep_hours": 7.0}
    score, detail = _sleep_score(feedback)
    assert score is None


def test_soreness_score_none() -> None:
    score, detail = _soreness_score(None)
    assert score is None
    assert "No soreness" in detail


def test_soreness_score_zero() -> None:
    """No soreness (0) should give 100."""
    score, detail = _soreness_score(0)
    assert score == 100


def test_soreness_score_max() -> None:
    """Max soreness (4) should give 0."""
    score, detail = _soreness_score(4)
    assert score == 0


def test_soreness_score_mid() -> None:
    """Soreness 2 => (4-2)/4*100 = 50."""
    score, detail = _soreness_score(2)
    assert score == 50


def test_acwr_score_none() -> None:
    score, detail = _acwr_score(None)
    assert score is None
    assert "Insufficient" in detail


def test_acwr_score_sweet_spot() -> None:
    """ACWR in 0.8-1.3 should give 100."""
    score, detail = _acwr_score(1.0)
    assert score == 100
    assert "optimal" in detail.lower()


def test_acwr_score_low() -> None:
    """ACWR below 0.8 should scale down."""
    score, detail = _acwr_score(0.4)
    assert score is not None
    assert score == 50
    assert "under-prepared" in detail.lower() or "low" in detail.lower()


def test_acwr_score_high() -> None:
    """ACWR above 1.3 should scale down (exponential penalty)."""
    score, detail = _acwr_score(1.65)
    assert score is not None
    assert score == 17
    assert "spike" in detail.lower() or "elevated" in detail.lower()


def test_preparedness_score_positive() -> None:
    """Positive preparedness => score > 50."""
    score, detail = _preparedness_score(1.0)
    assert score == 75
    assert "positive" in detail.lower() or "supercompensating" in detail.lower()


def test_preparedness_score_zero() -> None:
    score, detail = _preparedness_score(0.0)
    assert score == 50
    assert "neutral" in detail.lower()


def test_preparedness_score_negative() -> None:
    """Negative preparedness => score < 50."""
    score, detail = _preparedness_score(-1.0)
    assert score == 25
    assert "fatigue" in detail.lower()


def test_readiness_label_ready() -> None:
    assert _readiness_label(85) == "ready"
    assert _readiness_label(80) == "ready"
    assert _readiness_label(100) == "ready"


def test_readiness_label_moderate() -> None:
    assert _readiness_label(70) == "moderate"
    assert _readiness_label(60) == "moderate"


def test_readiness_label_fatigued() -> None:
    assert _readiness_label(50) == "fatigued"
    assert _readiness_label(40) == "fatigued"


def test_readiness_label_rest_recommended() -> None:
    assert _readiness_label(30) == "rest_recommended"
    assert _readiness_label(0) == "rest_recommended"


def test_build_composite_no_data() -> None:
    """No available dimensions should return 75 (neutral default)."""
    dimensions = [
        ReadinessDimension(name="sleep", score=0, weight=0.3, available=False, detail=""),
        ReadinessDimension(name="soreness", score=0, weight=0.2, available=False, detail=""),
    ]
    assert _build_composite(dimensions) == 75


def test_build_composite_single_dimension() -> None:
    """Single dimension with score 80 should return 80."""
    dimensions = [
        ReadinessDimension(name="sleep", score=80, weight=0.3, available=True, detail=""),
        ReadinessDimension(name="soreness", score=0, weight=0.2, available=False, detail=""),
    ]
    assert _build_composite(dimensions) == 80


def test_build_composite_all_available() -> None:
    """All dimensions available, even weights, score=60 each => composite=60."""
    dimensions = [
        ReadinessDimension(name="a", score=60, weight=0.5, available=True, detail=""),
        ReadinessDimension(name="b", score=60, weight=0.5, available=True, detail=""),
    ]
    assert _build_composite(dimensions) == 60


async def test_training_readiness_cold_start(mock_db_pool: MagicMock) -> None:
    """All sub-services return cold-start data => readiness should still be valid."""
    # Mock the three sub-services to return cold-start responses
    mock_recovery = MagicMock()
    mock_recovery.readiness_score = 75
    mock_recovery.readiness_label = "moderate"

    mock_acwr = MagicMock()
    mock_acwr.acwr = None

    mock_ff = MagicMock()
    mock_ff.preparedness_label = "insufficient_data"
    mock_ff.preparedness = 0.0

    with (
        patch(
            "app.services.training_readiness_service.compute_recovery",
            new_callable=AsyncMock,
            return_value=mock_recovery,
        ),
        patch(
            "app.services.training_readiness_service.compute_acwr",
            new_callable=AsyncMock,
            return_value=mock_acwr,
        ),
        patch(
            "app.services.training_readiness_service.compute_fitness_fatigue",
            new_callable=AsyncMock,
            return_value=mock_ff,
        ),
    ):
        # feedback and max_soreness will be None from the mock DB
        mock_db_pool._conn.fetchrow.return_value = None
        result = await compute_training_readiness(FAKE_USER_ID, mock_db_pool)

    assert 0 <= result.readiness_score <= 100
    assert result.readiness_label in ("ready", "moderate", "fatigued", "rest_recommended")
    assert len(result.dimensions) == 5
    assert result.recommendation != ""
    assert result.disclaimer != ""
