# Backend Analytics Enrichment — 2026-03-25

## Summary

Added 6 new backend analytics services to the advanced analytics dashboard, expanding the analytics from 7 to 13 metrics. These provide deeper, richer insights into training performance, injury risk, consistency, and long-term progress.

Inspired by the gym-tracker project (github.com/mmm00007/gym-tracker) and validated by the project's domain expert agents (fitness, sports medicine, data science, backend specialist).

## New Analytics Services

### 1. ACWR — Acute:Chronic Workload Ratio (`acwr_service.py`)
**Endpoint:** `GET /api/analytics/advanced/acwr`

The gold standard in sports medicine for monitoring training load and injury risk (Gabbett 2016, Hulin et al. 2014). Compares recent training stress (acute, 7-day EWMA) against the athlete's baseline (chronic, 28-day EWMA).

- **Algorithm:** Exponentially Weighted Moving Average (EWMA), more responsive than simple rolling average (Williams et al. 2017)
- **Risk zones:** under_prepared (<0.8), optimal (0.8-1.3), caution (1.3-1.5), danger (>1.5)
- **Data:** 56-day lookback, minimum 14 days for reliable computation
- **Output:** Current ACWR ratio, risk zone with description, 8-week trend, acute/chronic loads

### 2. Training Consistency & Streaks (`consistency_service.py`)
**Endpoint:** `GET /api/analytics/advanced/consistency?weeks=12`

Consistency is the strongest predictor of long-term training outcomes (Schoenfeld & Grgic 2020). Tracks training frequency patterns, streaks, and schedule regularity.

- **Consistency score:** Fraction of weeks with >= 2 training days
- **Streaks:** Current and longest consecutive active weeks
- **Regularity index:** Coefficient of variation of inter-session gaps, inverted (0-1 scale). High = predictable schedule.
- **Classifications:** excellent (>=85%), good (>=65%), moderate (>=40%), needs_improvement

### 3. Strength Standards & Benchmarking (`strength_standards_service.py`)
**Endpoint:** `GET /api/analytics/advanced/strength-standards?weeks=12`

Benchmarks the user's best estimated 1RM per exercise against population strength norms. Provides context for progress that raw numbers alone cannot.

- **Sources:** ExRx, strength-level.com, Rippetoe & Kilgore (2006)
- **Tiers:** untrained, beginner, novice, intermediate, advanced, elite
- **Exercises:** 24 common compound movements with absolute standards (kg)
- **Features:** Approximate percentile, next milestone target, kg to next tier
- **Limitations:** Male standards only (noted in disclaimer); fuzzy exercise name matching

### 4. Exercise Variety & Movement Patterns (`exercise_variety_service.py`)
**Endpoint:** `GET /api/analytics/advanced/exercise-variety?period=28`

Measures training diversity using information theory and maps exercises to fundamental movement patterns (Boyle 2016).

- **Variety index:** Shannon entropy on exercise set distribution, normalized 0-1
- **Movement patterns:** horizontal_push, vertical_push, horizontal_pull, vertical_pull, squat, hip_hinge, lunge, carry, core, isolation
- **Classification:** Keyword-based matching of exercise names to patterns
- **Missing pattern detection:** Identifies gaps in the 6 essential movement patterns
- **Labels:** highly_diverse (>=0.8), balanced (>=0.6), moderate (>=0.4), narrow

### 5. Performance Forecasting (`performance_forecast_service.py`)
**Endpoint:** `GET /api/analytics/advanced/performance-forecast?weeks=12`

Projects future 1RM values using linear regression on daily best e1RM, with R-squared confidence scoring and milestone predictions.

- **Algorithm:** OLS linear regression with R-squared goodness-of-fit
- **Projections:** 4, 8, and 12 weeks ahead (clamped to prevent unreasonable values)
- **Confidence:** Based on R-squared and sample size (high/moderate/low)
- **Milestones:** Predicts dates to reach common kg targets for compound lifts
- **Guardrails:** Non-negative projections, max 3x current value, 365-day max milestone horizon
- **Disclaimer:** Notes linear assumption and diminishing returns for advanced lifters

### 6. Fitness-Fatigue Model (`fitness_fatigue_service.py`)
**Endpoint:** `GET /api/analytics/advanced/fitness-fatigue`

The Banister impulse-response model (1975, refined by Busso et al. 1997) — a bicomponent model that decomposes training response into fitness and fatigue.

- **Fitness:** Slow-decaying adaptation (tau = 42 days, k = 1.0)
- **Fatigue:** Fast-decaying stress (tau = 7 days, k = 2.0)
- **Preparedness:** Fitness - Fatigue (positive = supercompensation)
- **Labels:** supercompensated, fresh, fatigued, overreached
- **Timeline:** 60-day daily fitness/fatigue/preparedness visualization data
- **Recommendations:** Context-aware training load advice based on fatigue ratio

## Files Changed

### New Files
| File | Lines | Purpose |
|------|-------|---------|
| `backend/app/services/acwr_service.py` | ~130 | ACWR computation via EWMA |
| `backend/app/services/consistency_service.py` | ~135 | Streaks, consistency, regularity |
| `backend/app/services/strength_standards_service.py` | ~150 | Population benchmarking |
| `backend/app/services/exercise_variety_service.py` | ~165 | Movement pattern analysis |
| `backend/app/services/performance_forecast_service.py` | ~185 | 1RM forecasting with milestones |
| `backend/app/services/fitness_fatigue_service.py` | ~145 | Banister model |
| `backend/tests/test_new_analytics.py` | ~370 | 43 tests covering all new services |
| `docs/changes/2026-03-25/backend-analytics-enrichment.md` | This file |

### Modified Files
| File | Change |
|------|--------|
| `backend/app/models/schemas.py` | Added 12 new Pydantic models + updated AdvancedAnalyticsDashboard |
| `backend/app/routers/advanced_analytics.py` | Added 6 new endpoints + updated dashboard to 13 parallel queries |

## API Changes

### New Endpoints
All require authentication (`Authorization: Bearer <token>`).

| Method | Path | Parameters |
|--------|------|------------|
| GET | `/api/analytics/advanced/acwr` | — |
| GET | `/api/analytics/advanced/consistency` | `weeks` (4-52, default 12) |
| GET | `/api/analytics/advanced/strength-standards` | `weeks` (4-52, default 12) |
| GET | `/api/analytics/advanced/exercise-variety` | `period` (7-365, default 28) |
| GET | `/api/analytics/advanced/performance-forecast` | `weeks` (4-52, default 12) |
| GET | `/api/analytics/advanced/fitness-fatigue` | — |

### Dashboard Update
`GET /api/analytics/advanced/dashboard` now returns 6 additional optional fields:
- `acwr`, `consistency`, `strength_standards`, `exercise_variety`, `performance_forecast`, `fitness_fatigue`

These are optional (nullable) for backward compatibility. All 13 metrics run in parallel via `asyncio.gather`.

## Testing

- 43 new tests: unit tests for pure functions + async service tests + endpoint integration tests
- 40 existing tests pass unchanged (zero regressions)
- All tests mock the database via `asyncpg.Pool` mock pattern

## Domain Expert Validation

All services were reviewed by 4 specialist agents:
1. **Fitness Domain Expert** (opus) — exercise science correctness, thresholds
2. **Sports Medicine Expert** (opus) — safety, injury risk, disclaimers
3. **Data Science Expert** (opus) — statistical validity, edge cases, cold-start behavior
4. **Backend Specialist** (sonnet) — code quality, patterns, asyncpg usage

## Scientific References

- Gabbett TJ (2016). The training-injury prevention paradox. BJSM.
- Hulin BT et al. (2014). The acute:chronic workload ratio predicts injury. BJSM.
- Williams S et al. (2017). EWMA charts for monitoring ACWR. BJSM.
- Banister EW (1975). Modeling athletic training and performance. Exercise & Sport Sciences Reviews.
- Busso T et al. (1997). Fatigue and fitness modelled from training. European Journal of Applied Physiology.
- Schoenfeld BJ, Grgic J (2020). Training frequency for strength development. Sports Medicine.
- Boyle M (2016). New Functional Training for Sports. Human Kinetics.
- Rippetoe M, Kilgore L (2006). Practical Programming for Strength Training.
- Foster C (1998). Monitoring training in athletes with reference to overtraining syndrome. Medicine & Science in Sports & Exercise.
