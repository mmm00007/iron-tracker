# Deep Insight Analytics — 2026-03-25

## Summary

Added 7 new deep insight analytics endpoints to the Iron Tracker backend, expanding the analytics suite from 17 to 24 endpoints. All new analytics were validated by 4 domain expert agents (fitness domain expert, sports medicine expert, data science expert, backend specialist) before implementation.

Inspired by analysis of [gym-tracker](https://github.com/mmm00007/gym-tracker) analytics patterns and identification of gaps in the existing Iron Tracker analytics coverage.

## New Endpoints

All endpoints are under `/api/analytics/advanced/` and require authentication.

### 1. Bilateral Asymmetry Detection (`GET /bilateral-asymmetry`)

**Purpose:** Detects left-right strength and volume imbalances for unilateral exercises.

**Algorithm:** Uses the Limb Symmetry Index (LSI) formula -- `(weaker_e1rm / stronger_e1rm) * 100` -- which is the rehabilitation literature standard (Schmitt et al. 2012, JOSPT). Thresholds: <8% normal, 8-15% monitor, >15% significant (Knapik et al. 1991, Bishop et al. 2018).

**Data sources:** `sets.side` column (left/right), `exercises.laterality`, `sets.estimated_1rm`

**Key decisions:**
- Minimum 3 sets per side before computing (reduce noise from single-session variance)
- Separate upper/lower body context in disclaimer (upper body asymmetry up to 10% is often normal due to handedness)
- Labels are "asymmetry detected" not "injury risk" -- consumer app, not clinical tool

**File:** `backend/app/services/bilateral_asymmetry_service.py`

### 2. Body Composition Analytics (`GET /body-composition`)

**Purpose:** BMI, FFMI, weight trend tracking, body fat analytics.

**Algorithm:**
- **BMI:** `weight_kg / height_m^2` with WHO classification labels
- **FFMI:** Kouri et al. (1995) normalized formula: `(lean_mass / height_m^2) + 6.1 * (1.8 - height_m)`
- **Weight trend:** 7-day EMA (alpha = 0.25) to smooth daily fluctuations from hydration/glycogen
- **Weight change:** Latest EMA - earliest EMA over the period

**Data sources:** `body_weight_log` (weight, body_fat_pct, weight_unit), `profiles` (height_cm, sex)

**Key decisions:**
- EMA over LOESS: EMA is O(n), incrementally updatable, and causal (no future data needed)
- FFMI labels are sex-specific (male natural limit ~25, female ~22)
- BMI carries prominent disclaimer for trained individuals
- Body fat floor warnings included in disclaimer for safety

**File:** `backend/app/services/body_composition_service.py`

### 3. Training Density / Efficiency (`GET /training-density`)

**Purpose:** Measures workout pace -- effective sets per hour and volume per minute per session.

**Algorithm:**
- **Primary metric:** `sets_per_hour = working_sets / (duration_minutes / 60)`
- **Secondary:** `volume_per_minute = total_volume_kg / duration_minutes`
- **Trend:** Linear regression on chronological sets_per_hour values
- Filter: sessions between 5-180 minutes only

**Data sources:** `sets` (logged_at, workout_cluster_id, weight, reps, set_type)

**Key decisions:**
- Sets/hour primary over volume/time (volume/time is dominated by heavy compounds, misleading)
- Never framed as "higher is better" -- longer rest is better for strength (Schoenfeld 2016)

**File:** `backend/app/services/training_density_service.py`

### 4. Sleep-Performance Correlation (`GET /sleep-performance`)

**Purpose:** Correlates self-reported sleep metrics with training performance.

**Algorithm:**
- **Spearman rank correlation** between sleep_hours and session metrics (volume, e1RM, RPE)
- **Bucket analysis:** poor (<5h), fair (5-6h), good (6-7.5h), excellent (>7.5h)
- **Confidence tiers:** <5 = insufficient, 5-9 = preliminary, 10-19 = moderate, 20+ = reliable

**Data sources:** `workout_feedback` (sleep_hours, prior_sleep_quality) joined with `sets`

**Key decisions:**
- Spearman over Pearson (relationship is monotonic but not necessarily linear)
- Pure Python implementation (no scipy dependency)
- Minimum 5 paired observations; exclude sleep_hours < 3
- No p-values (meaningless for single-user data)

**File:** `backend/app/services/sleep_performance_service.py`

### 5. Time-of-Day Performance (`GET /time-performance`)

**Purpose:** Analyzes when the user performs best across the day.

**Algorithm:**
- 4 time windows: morning (5-11), afternoon (12-16), evening (17-20), night (21-4)
- Per window: avg e1RM%, avg volume, avg RPE, session count
- All timestamps in user's timezone from `profiles.timezone`
- Minimum 5 sessions per window to report

**Data sources:** `sets` (logged_at, estimated_1rm, weight, reps, rpe), `profiles` (timezone)

**Key decisions:**
- 4 bins not 6 (most users train in 1-2 windows, 6 is too granular)
- Descriptive stats only, no ANOVA (meaningless for single user)
- Circadian rhythm context: 5-10% evening advantage (Chtourou & Souissi 2012) but attenuates with habitual training

**File:** `backend/app/services/time_performance_service.py`

### 6. Rest Period Analysis (`GET /rest-analysis`)

**Purpose:** Analyzes rest period distributions by exercise type with NSCA-based optimal ranges.

**Algorithm:**
- Distribution: avg, median, p25, p75 (SQL PERCENTILE_CONT)
- Segmented by exercise mechanic: compound vs isolation
- NSCA-based optimal ranges: compound 90-180s, isolation 60-120s (hypertrophy default)
- Compliance: % of sets within optimal range
- Outlier filter: exclude <15s (supersets) and >600s (phone breaks)

**Data sources:** `sets` (rest_seconds, set_type), `exercises` (mechanic)

**Key decisions:**
- Updated rest ranges from traditional NSCA to 2019+ consensus
- Flag short rest on heavy compounds for cardiovascular safety
- Rest coverage percentage reported for data completeness awareness

**File:** `backend/app/services/rest_analysis_service.py`

### 7. Relative Strength Index (`GET /relative-strength`)

**Purpose:** Tracks strength relative to bodyweight using IPF DOTS scores.

**Algorithm:**
- **DOTS score** (IPF 2019): `e1rm * (500 / polynomial(bodyweight))` with sex-specific coefficients
- **BW ratio:** simple `e1rm / bodyweight` per lift
- **Total DOTS:** sum across benchmarkable compound lifts
- Bodyweight clamped to [40, 200] kg for coefficient stability

**Data sources:** `body_weight_log`, `profiles` (sex), `sets` + `exercises` (benchmarkable lifts)

**Key decisions:**
- DOTS over Wilks (current IPF standard since 2019, better statistical fit across weight classes)
- 14 benchmarkable exercise name variants matched case-insensitively
- No leaderboards (directly incentivizes weight cutting -- sports medicine concern)
- Stale bodyweight (>30 days) flagged but not blocked

**File:** `backend/app/services/relative_strength_service.py`

## Files Changed

### New Files (9)

| File | Purpose |
|------|---------|
| `backend/app/services/bilateral_asymmetry_service.py` | Bilateral asymmetry detection |
| `backend/app/services/body_composition_service.py` | Body composition analytics |
| `backend/app/services/training_density_service.py` | Training density/efficiency |
| `backend/app/services/sleep_performance_service.py` | Sleep-performance correlation |
| `backend/app/services/time_performance_service.py` | Time-of-day performance |
| `backend/app/services/rest_analysis_service.py` | Rest period analysis |
| `backend/app/services/relative_strength_service.py` | Relative strength (DOTS) |
| `backend/tests/test_deep_analytics.py` | 31 tests for all 7 services |
| `docs/changes/2026-03-25/deep-insight-analytics.md` | This document |

### Modified Files (2)

| File | Change |
|------|--------|
| `backend/app/models/schemas.py` | 14 new Pydantic models (7 response + 7 entry types), 7 new fields on AdvancedAnalyticsDashboard |
| `backend/app/routers/advanced_analytics.py` | 7 new endpoints, dashboard updated to 24 parallel metrics |

## Domain Expert Validation

| Expert | Model | Verdict | Key Guidance |
|--------|-------|---------|--------------|
| Fitness Domain Expert | opus | 7/7 APPROVED | LSI > percent-difference; DOTS > Wilks; 7-9h sleep range correct; rest evidence shifted since 2016 |
| Sports Medicine Expert | opus | 7/7 SAFE WITH GUARDRAILS | Body composition highest-risk (eating disorder sensitivity); short rest + heavy load = CV flag; no DOTS leaderboards |
| Data Science Expert | opus | 7/7 APPROVED (3 modified) | Spearman > Pearson; 4 bins > 6 for time; sets/hour > volume/time; filter rest outliers <15s and >600s |
| Backend Specialist | sonnet | 7/7 queries validated | Single connection acquire per service; no new indexes needed; partial indexes cover all queries |

## No Database Migrations Required

All columns were added in existing migrations 019 and 021.

## Test Results

168 passed, 0 failed (31 new + 137 existing).
