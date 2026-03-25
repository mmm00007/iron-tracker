"""Tests for wave-3 analytics services.

Services tested:
  - Body Measurements (circumference/skinfold tracking, bilateral asymmetry)
  - Nutrition Performance (Spearman correlation, protein buckets)
  - Mesocycle Effectiveness (phase alignment, e1RM progression)
  - Injury Awareness (red flags, recovery trajectory)
  - Substitution Patterns (pair performance ratio, readiness)
  - Exercise Profile (completeness scoring, tag aggregation)
"""

from datetime import UTC, date, datetime, timedelta
from unittest.mock import AsyncMock, MagicMock

import pytest

from app.services.body_measurements_service import (
    _linear_slope,
    _to_cm,
    compute_body_measurements,
)
from app.services.nutrition_performance_service import (
    _spearman,
    compute_nutrition_performance,
)
from app.services.mesocycle_effectiveness_service import (
    _alignment_score,
    _e1rm_change_pct,
    compute_mesocycle_effectiveness,
)
from app.services.injury_awareness_service import (
    _detect_red_flags,
    compute_injury_awareness,
)
from app.services.substitution_patterns_service import (
    compute_substitution_patterns,
)
from app.services.exercise_profile_service import (
    compute_exercise_profile,
)
from app.models.schemas import InjuryEntry
from tests.conftest import FAKE_USER_ID

# ── Fixtures ─────────────────────────────────────────────────────────────────

NOW = datetime.now(UTC)
TODAY = date.today()


@pytest.fixture
def mock_db_pool() -> MagicMock:
    pool = MagicMock()
    conn = AsyncMock()
    conn.fetchrow.return_value = None
    conn.fetch.return_value = []
    conn.fetchval.return_value = None
    ctx = AsyncMock()
    ctx.__aenter__ = AsyncMock(return_value=conn)
    ctx.__aexit__ = AsyncMock(return_value=False)
    pool.acquire.return_value = ctx
    pool._conn = conn
    return pool


# =============================================================================
# BODY MEASUREMENTS SERVICE
# =============================================================================


def test_to_cm_inches() -> None:
    """Inches should be converted to cm (* 2.54)."""
    assert abs(_to_cm(10.0, "in") - 25.4) < 0.01


def test_to_cm_cm_passthrough() -> None:
    """Centimetre values should pass through unchanged."""
    assert _to_cm(30.0, "cm") == 30.0


def test_linear_slope_perfect_line() -> None:
    """Linear data should yield correct slope in units/week."""
    # 1 unit per second = 604800 per week
    slope = _linear_slope([0.0, 1.0, 2.0, 3.0], [0.0, 1.0, 2.0, 3.0])
    assert slope is not None
    assert abs(slope - 604800.0) < 0.1


def test_linear_slope_flat() -> None:
    """Constant values should yield zero slope."""
    slope = _linear_slope([0.0, 1.0, 2.0], [5.0, 5.0, 5.0])
    assert slope is not None
    assert abs(slope) < 0.001


def test_linear_slope_insufficient_points() -> None:
    """Fewer than 2 points should return None."""
    assert _linear_slope([1.0], [1.0]) is None
    assert _linear_slope([], []) is None


def test_linear_slope_zero_variance_timestamps() -> None:
    """All identical timestamps should return None."""
    assert _linear_slope([5.0, 5.0, 5.0], [1.0, 2.0, 3.0]) is None


async def test_body_measurements_cold_start(mock_db_pool: MagicMock) -> None:
    """Empty DB should return valid response with zeroed fields."""
    mock_db_pool._conn.fetch.return_value = []
    result = await compute_body_measurements(FAKE_USER_ID, mock_db_pool)

    assert result.sites == []
    assert result.bilateral == []
    assert result.total_measurements == 0
    assert result.sites_tracked == 0
    assert result.period_days == 180
    assert result.disclaimer != ""


async def test_body_measurements_happy_path(mock_db_pool: MagicMock) -> None:
    """Realistic data should produce populated site entries and bilateral comparison."""
    now_ts = NOW.timestamp()
    one_week_ago_ts = now_ts - 7 * 24 * 3600

    # trend_rows: two measurements for 'chest' (no side), two bilateral for 'arm'
    trend_rows = [
        {
            "site": "arm",
            "side": "left",
            "measurement_type": "circumference",
            "value": 35.0,
            "unit": "cm",
            "measured_at": "2026-03-18T10:00:00",
            "ts": one_week_ago_ts,
        },
        {
            "site": "arm",
            "side": "left",
            "measurement_type": "circumference",
            "value": 35.5,
            "unit": "cm",
            "measured_at": "2026-03-25T10:00:00",
            "ts": now_ts,
        },
        {
            "site": "arm",
            "side": "right",
            "measurement_type": "circumference",
            "value": 36.0,
            "unit": "cm",
            "measured_at": "2026-03-18T10:00:00",
            "ts": one_week_ago_ts,
        },
        {
            "site": "arm",
            "side": "right",
            "measurement_type": "circumference",
            "value": 36.2,
            "unit": "cm",
            "measured_at": "2026-03-25T10:00:00",
            "ts": now_ts,
        },
        {
            "site": "chest",
            "side": None,
            "measurement_type": "circumference",
            "value": 100.0,
            "unit": "cm",
            "measured_at": "2026-03-18T10:00:00",
            "ts": one_week_ago_ts,
        },
        {
            "site": "chest",
            "side": None,
            "measurement_type": "circumference",
            "value": 101.0,
            "unit": "cm",
            "measured_at": "2026-03-25T10:00:00",
            "ts": now_ts,
        },
    ]

    bilateral_rows = [
        {"site": "arm", "side": "left", "value": 35.5, "unit": "cm"},
        {"site": "arm", "side": "right", "value": 36.2, "unit": "cm"},
    ]

    call_count = 0

    async def fetch_side_effect(*args, **kwargs):
        nonlocal call_count
        call_count += 1
        if call_count == 1:
            return trend_rows
        return bilateral_rows

    mock_db_pool._conn.fetch.side_effect = fetch_side_effect

    result = await compute_body_measurements(FAKE_USER_ID, mock_db_pool)

    assert result.total_measurements == 6
    assert result.sites_tracked == 2
    assert len(result.sites) == 2

    # Arm and chest should both have entries
    site_names = {s.site for s in result.sites}
    assert "arm" in site_names
    assert "chest" in site_names

    # Bilateral: arm should show asymmetry
    assert len(result.bilateral) == 1
    arm_bi = result.bilateral[0]
    assert arm_bi.site == "arm"
    assert arm_bi.left_value == 35.5
    assert arm_bi.right_value == 36.2
    assert arm_bi.asymmetry_pct > 0


# =============================================================================
# NUTRITION PERFORMANCE SERVICE
# =============================================================================


def test_spearman_perfect_positive() -> None:
    """Identical rankings should yield rho close to 1.0."""
    rho = _spearman(
        [1.0, 2.0, 3.0, 4.0, 5.0],
        [1.0, 2.0, 3.0, 4.0, 5.0],
    )
    assert rho is not None
    assert abs(rho - 1.0) < 0.001


def test_spearman_insufficient_data() -> None:
    """Fewer than 5 data points should return None."""
    assert _spearman([1.0, 2.0, 3.0], [3.0, 2.0, 1.0]) is None


async def test_nutrition_performance_cold_start(mock_db_pool: MagicMock) -> None:
    """Fewer than 14 paired days should return cold-start response."""
    mock_db_pool._conn.fetch.return_value = []
    mock_db_pool._conn.fetchrow.return_value = None
    result = await compute_nutrition_performance(FAKE_USER_ID, mock_db_pool)

    assert result.correlation_protein_volume is None
    assert result.correlation_calories_volume is None
    assert result.correlation_carbs_rpe is None
    assert result.protein_buckets == []
    assert result.avg_protein_per_kg is None
    assert result.avg_calories is None
    assert result.paired_days == 0
    assert result.period_days == 90
    assert result.disclaimer != ""


async def test_nutrition_performance_happy_path(mock_db_pool: MagicMock) -> None:
    """With enough paired days and body weight, correlations should be computed."""
    # Generate 20 paired rows with realistic data
    rows = []
    base_date = TODAY - timedelta(days=30)
    for i in range(20):
        d = base_date + timedelta(days=i)
        rows.append(
            {
                "logged_date": str(d),
                "protein_g": 120.0 + i * 2,
                "calories_kcal": 2200.0 + i * 20,
                "carbs_g": 250.0 + i * 5,
                "total_volume_kg": 5000.0 + i * 100,
                "avg_rpe": 7.0 + (i % 3) * 0.5,
                "best_e1rm": 100.0 + i * 1.5,
            }
        )

    weight_row = {"weight": 80.0, "weight_unit": "kg"}

    call_count = 0

    async def fetch_side_effect(*args, **kwargs):
        nonlocal call_count
        call_count += 1
        return rows

    mock_db_pool._conn.fetch.side_effect = fetch_side_effect
    mock_db_pool._conn.fetchrow.return_value = weight_row

    result = await compute_nutrition_performance(FAKE_USER_ID, mock_db_pool)

    assert result.paired_days == 20
    assert result.avg_protein_per_kg is not None
    assert result.avg_protein_per_kg > 0
    assert result.avg_calories is not None
    assert result.avg_calories > 0
    # With 20 data points, correlations should be computed (not None)
    assert result.correlation_protein_volume is not None
    assert result.protein_buckets != []
    assert result.disclaimer != ""


# =============================================================================
# MESOCYCLE EFFECTIVENESS SERVICE
# =============================================================================


def test_alignment_score_hypertrophy_ideal() -> None:
    """Perfect hypertrophy alignment: RPE 7, volume 0.85 => should score high."""
    score = _alignment_score("hypertrophy", 7.0, 0.85)
    assert score is not None
    assert score >= 80.0


def test_alignment_score_general_phase() -> None:
    """General phase has no ideal profile, should return None."""
    assert _alignment_score("general", 7.0, 0.5) is None


def test_alignment_score_deload_ideal() -> None:
    """Perfect deload: RPE 5.5, volume 0.1 => should score high."""
    score = _alignment_score("deload", 5.5, 0.1)
    assert score is not None
    assert score >= 80.0


def test_e1rm_change_pct_positive() -> None:
    """Increasing e1RM across weeks should yield positive change."""
    weekly = {0: 100.0, 1: 102.0, 2: 105.0, 3: 108.0}
    change = _e1rm_change_pct(weekly)
    assert change is not None
    assert change > 0


def test_e1rm_change_pct_insufficient() -> None:
    """Single week should return None."""
    assert _e1rm_change_pct({0: 100.0}) is None
    assert _e1rm_change_pct({}) is None


async def test_mesocycle_effectiveness_cold_start(mock_db_pool: MagicMock) -> None:
    """No mesocycle data should return empty response."""
    mock_db_pool._conn.fetch.return_value = []
    result = await compute_mesocycle_effectiveness(FAKE_USER_ID, mock_db_pool)

    assert result.mesocycles == []
    assert result.total_mesocycles == 0
    assert result.current_phase is None
    assert result.best_phase_for_strength is None
    assert result.period_days == 365
    assert result.disclaimer != ""


async def test_mesocycle_effectiveness_happy_path(mock_db_pool: MagicMock) -> None:
    """Mesocycle with multi-week training data should produce entries."""
    start = TODAY - timedelta(days=42)

    # Build rows: 3 weeks of training in one hypertrophy mesocycle
    rows = []
    for week in range(3):
        for day_in_week in range(3):  # 3 sessions per week
            td = start + timedelta(weeks=week, days=day_in_week * 2)
            rows.append(
                {
                    "mesocycle_id": "meso-001",
                    "name": "Hypertrophy Block",
                    "phase": "hypertrophy",
                    "start_date": str(start),
                    "end_date": str(start + timedelta(days=42)),
                    "target_weeks": 6,
                    "training_date": td,
                    "total_sets": 20,
                    "working_sets": 16,
                    "total_volume_kg": 8000.0 + week * 500,
                    "avg_rpe": 7.0 + week * 0.3,
                    "best_e1rm": 100.0 + week * 5.0,
                }
            )

    mock_db_pool._conn.fetch.return_value = rows
    result = await compute_mesocycle_effectiveness(FAKE_USER_ID, mock_db_pool)

    assert result.total_mesocycles >= 1
    assert len(result.mesocycles) >= 1
    meso = result.mesocycles[0]
    assert meso.name == "Hypertrophy Block"
    assert meso.phase == "hypertrophy"
    assert meso.weeks_completed >= 2
    assert meso.total_volume_kg > 0
    assert meso.avg_rpe is not None
    assert result.current_phase == "hypertrophy"
    assert result.disclaimer != ""


# =============================================================================
# INJURY AWARENESS SERVICE
# =============================================================================


def test_detect_red_flags_high_pain_chronic() -> None:
    """High pain (>=7) persisting >14 days should trigger a red flag."""
    injury = InjuryEntry(
        injury_id="inj-1",
        body_area="lower_back",
        location_type="muscle",
        pain_level=8,
        status="active",
        reported_at="2026-03-01T10:00:00",
        resolved_at=None,
        days_active=20,
        sets_while_injured=0,
        onset_type="gradual",
    )
    flags = _detect_red_flags([injury])
    assert len(flags) >= 1
    assert "lower_back" in flags[0]


def test_detect_red_flags_nerve_type() -> None:
    """Nerve-type injury should always trigger a red flag."""
    injury = InjuryEntry(
        injury_id="inj-2",
        body_area="wrist",
        location_type="nerve",
        pain_level=3,
        status="active",
        reported_at="2026-03-20T10:00:00",
        resolved_at=None,
        days_active=5,
        sets_while_injured=0,
        onset_type="sudden",
    )
    flags = _detect_red_flags([injury])
    assert len(flags) >= 1
    assert "nerve" in flags[0].lower()


def test_detect_red_flags_training_through_pain() -> None:
    """Training through significant pain (>=5) should be flagged."""
    injury = InjuryEntry(
        injury_id="inj-3",
        body_area="shoulder",
        location_type="joint",
        pain_level=6,
        status="active",
        reported_at="2026-03-15T10:00:00",
        resolved_at=None,
        days_active=10,
        sets_while_injured=5,
        onset_type="gradual",
    )
    flags = _detect_red_flags([injury])
    assert len(flags) >= 1
    assert "Training through" in flags[0] or "pain" in flags[0].lower()


def test_detect_red_flags_none() -> None:
    """Low-pain, non-nerve, no training-through should produce no flags."""
    injury = InjuryEntry(
        injury_id="inj-4",
        body_area="biceps",
        location_type="muscle",
        pain_level=3,
        status="active",
        reported_at="2026-03-22T10:00:00",
        resolved_at=None,
        days_active=3,
        sets_while_injured=0,
        onset_type="gradual",
    )
    flags = _detect_red_flags([injury])
    assert flags == []


async def test_injury_awareness_cold_start(mock_db_pool: MagicMock) -> None:
    """No injury reports should return empty response."""
    mock_db_pool._conn.fetch.return_value = []
    result = await compute_injury_awareness(FAKE_USER_ID, mock_db_pool)

    assert result.injuries == []
    assert result.active_count == 0
    assert result.resolved_count == 0
    assert result.avg_recovery_days is None
    assert result.red_flags == []
    assert result.training_through_injury is False
    assert result.disclaimer != ""


async def test_injury_awareness_happy_path(mock_db_pool: MagicMock) -> None:
    """Realistic injury data should produce entries with correct partitioning."""
    rows = [
        {
            "injury_id": "inj-1",
            "body_area": "knee",
            "location_type": "joint",
            "pain_level": 5,
            "status": "active",
            "reported_at": "2026-03-10T10:00:00",
            "resolved_at": None,
            "onset_type": "gradual",
            "days_active": 15,
            "sets_while_injured": 3,
        },
        {
            "injury_id": "inj-2",
            "body_area": "shoulder",
            "location_type": "muscle",
            "pain_level": 4,
            "status": "resolved",
            "reported_at": "2026-02-01T10:00:00",
            "resolved_at": "2026-02-15T10:00:00",
            "onset_type": "sudden",
            "days_active": 14,
            "sets_while_injured": 0,
        },
    ]

    mock_db_pool._conn.fetch.return_value = rows
    result = await compute_injury_awareness(FAKE_USER_ID, mock_db_pool)

    assert len(result.injuries) == 2
    assert result.active_count == 1
    assert result.resolved_count == 1
    assert result.avg_recovery_days == 14.0
    assert result.training_through_injury is True
    # Pain >= 5 and training through => red flag
    assert len(result.red_flags) >= 1
    assert result.disclaimer != ""


# =============================================================================
# SUBSTITUTION PATTERNS SERVICE
# =============================================================================


async def test_substitution_patterns_cold_start(mock_db_pool: MagicMock) -> None:
    """No substitution pairs should return empty response."""
    mock_db_pool._conn.fetch.return_value = []
    mock_db_pool._conn.fetchrow.return_value = None
    result = await compute_substitution_patterns(FAKE_USER_ID, mock_db_pool)

    assert result.pairs == []
    assert result.total_pairs_used == 0
    assert result.progressions_ready == 0
    assert result.period_days == 180
    assert result.disclaimer != ""


async def test_substitution_patterns_happy_path(mock_db_pool: MagicMock) -> None:
    """Realistic pair data should produce performance ratios and readiness."""
    pair_rows = [
        {
            "source_exercise_id": "ex-1",
            "target_exercise_id": "ex-2",
            "substitution_type": "equivalent",
            "similarity_score": 85,
            "prerequisite_1rm_ratio": None,
            "source_name": "Barbell Bench Press",
            "target_name": "Dumbbell Bench Press",
            "source_e1rm": 100.0,
            "target_e1rm": 80.0,
        },
        {
            "source_exercise_id": "ex-3",
            "target_exercise_id": "ex-4",
            "substitution_type": "progression",
            "similarity_score": 70,
            "prerequisite_1rm_ratio": 1.5,
            "source_name": "Barbell Row",
            "target_name": "Weighted Pull-Up",
            "source_e1rm": 90.0,
            "target_e1rm": 60.0,
        },
    ]
    bw_row = {"weight": 80.0, "weight_unit": "kg"}

    call_count = 0

    async def fetch_side_effect(*args, **kwargs):
        nonlocal call_count
        call_count += 1
        return pair_rows

    mock_db_pool._conn.fetch.side_effect = fetch_side_effect
    mock_db_pool._conn.fetchrow.return_value = bw_row

    result = await compute_substitution_patterns(FAKE_USER_ID, mock_db_pool)

    assert result.total_pairs_used == 2
    assert len(result.pairs) == 2

    # First pair: equivalent, should have performance ratio
    equiv = result.pairs[0]
    assert equiv.source_name == "Barbell Bench Press"
    assert equiv.target_name == "Dumbbell Bench Press"
    assert equiv.performance_ratio is not None
    assert equiv.performance_ratio == 0.8  # 80/100
    assert equiv.readiness_pct is None  # not a progression type

    # Second pair: progression type, should have readiness
    prog = result.pairs[1]
    assert prog.substitution_type == "progression"
    assert prog.readiness_pct is not None
    assert prog.readiness_pct > 0

    assert result.disclaimer != ""


# =============================================================================
# EXERCISE PROFILE SERVICE
# =============================================================================


async def test_exercise_profile_cold_start(mock_db_pool: MagicMock) -> None:
    """No exercises should return empty response with zeroed stats."""
    mock_db_pool._conn.fetch.return_value = []
    result = await compute_exercise_profile(FAKE_USER_ID, mock_db_pool)

    assert result.exercises == []
    assert result.avg_completeness == 0.0
    assert result.exercises_with_notes == 0
    assert result.exercises_with_injury_flags == 0
    assert result.total_tags == 0
    assert result.unique_tags == 0
    assert result.disclaimer != ""


async def test_exercise_profile_happy_path(mock_db_pool: MagicMock) -> None:
    """Realistic exercise data should produce completeness scores and tag aggregation."""
    rows = [
        {
            "exercise_id": "ex-1",
            "exercise_name": "Barbell Squat",
            "form_cues": "Brace core, drive knees out",
            "injury_notes": "Watch left knee",
            "preferred_grip": None,
            "preferred_stance": "shoulder-width",
            "preferred_rep_range": "3-5",
            "tags": ["compound", "legs"],
            "total_sets": 50,
        },
        {
            "exercise_id": "ex-2",
            "exercise_name": "Bicep Curl",
            "form_cues": None,
            "injury_notes": None,
            "preferred_grip": "supinated",
            "preferred_stance": None,
            "preferred_rep_range": None,
            "tags": ["isolation", "arms"],
            "total_sets": 20,
        },
        {
            "exercise_id": "ex-3",
            "exercise_name": "Deadlift",
            "form_cues": "Hinge at hips",
            "injury_notes": None,
            "preferred_grip": "mixed",
            "preferred_stance": "conventional",
            "preferred_rep_range": "1-5",
            "tags": ["compound", "back", "legs"],
            "total_sets": 40,
        },
    ]

    mock_db_pool._conn.fetch.return_value = rows
    result = await compute_exercise_profile(FAKE_USER_ID, mock_db_pool)

    assert len(result.exercises) == 3

    # Squat: form_cues + stance + rep_range + tags = 4/5 = 80%
    squat = next(e for e in result.exercises if e.exercise_name == "Barbell Squat")
    assert squat.completeness_pct == 80.0
    assert squat.has_form_cues is True
    assert squat.has_injury_notes is True
    assert squat.total_sets == 50

    # Curl: grip only = 1/5 = 20%
    curl = next(e for e in result.exercises if e.exercise_name == "Bicep Curl")
    assert curl.completeness_pct == 40.0  # grip + tags = 2/5
    assert curl.has_form_cues is False
    assert curl.has_injury_notes is False

    # Deadlift: form_cues + grip + stance + rep_range + tags = 5/5 = 100%
    deadlift = next(e for e in result.exercises if e.exercise_name == "Deadlift")
    assert deadlift.completeness_pct == 100.0

    # Aggregate stats
    assert result.exercises_with_injury_flags == 1  # only squat
    assert result.exercises_with_notes >= 2  # squat and deadlift have form/prefs
    assert result.avg_completeness > 0
    assert result.total_tags == 7  # 2 + 2 + 3
    assert result.unique_tags == 5  # compound, legs, isolation, arms, back
    assert result.disclaimer != ""
