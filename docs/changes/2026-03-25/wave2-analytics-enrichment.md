# Wave 2: Untapped Data Analytics Enrichment -- 2026-03-25

## Summary

Added 7 new analytics endpoints targeting previously unused database tables and columns, expanding the analytics suite from 24 to 31 endpoints. These analytics unlock data from `plan_adherence_log`, `muscle_antagonist_pairs`, `sets.tempo`, `soreness_reports` (deeper analysis), `equipment_usage_stats`, `training_milestones`, and cross-service composites.

All new analytics were validated by 4 domain expert agents (fitness, sports medicine, data science, backend) in a combined consultation before implementation.

## New Endpoints

All endpoints are under `/api/analytics/advanced/` and require authentication.

### 1. Plan Adherence Trend (`GET /plan-adherence`)

**Data source:** `plan_adherence_log` (previously unused)

Tracks weekly adherence ratio (completed_sets / planned_sets) over time. Detects declining adherence via linear regression. Flags burnout risk when adherence slope < -0.03 AND average RPE > 8.0 (Steele et al. 2017, Meeusen et al. 2013). Counts exceedance weeks (doing more than planned).

**File:** `backend/app/services/plan_adherence_service.py`

### 2. Antagonist Pair Balance (`GET /antagonist-balance`)

**Data source:** `muscle_antagonist_pairs` (previously unused)

Computes activation-weighted volume ratios for antagonist muscle pairs. Uses pair-specific thresholds: chest:lats > 1.5 (Kolber 2009, shoulder impingement), hamstrings:quads < 0.6 (Hewett 2005, ACL risk). Primary muscles weighted at 1.0, secondary at 0.5.

**File:** `backend/app/services/antagonist_balance_service.py`

### 3. Tempo & Time-Under-Tension Analysis (`GET /tempo-analysis`)

**Data source:** `sets.tempo` column (previously unused)

Parses tempo strings (e.g., "3010" = 3s eccentric, 0s pause, 1s concentric, 0s top) to compute TUT per set. Handles "X" as 1 second (explosive). Classifies into training zones: strength (<20s), moderate (20-40s), hypertrophy (40-60s), endurance (>60s). Reports tempo logging coverage percentage.

**File:** `backend/app/services/tempo_analysis_service.py`

### 4. Soreness Patterns (`GET /soreness-patterns`)

**Data source:** `soreness_reports` (deeper than recovery service's basic use)

Per-muscle soreness trends, DOMS timing analysis (lag between training and reporting), volume-soreness Spearman correlation. Detects red flags: level 4 persisting >72h, escalating patterns (3+ consecutive increasing reports). Based on Cheung et al. 2003 DOMS physiology.

**File:** `backend/app/services/soreness_patterns_service.py`

### 5. Equipment Efficiency (`GET /equipment-efficiency`)

**Data source:** `equipment_variants` + `equipment_usage_stats` view (previously unused)

Compares e1RM progression rates across equipment variants for the same exercises. Per-variant: best e1RM, trend slope (kg/week), usage frequency, user rating. Identifies top-performing equipment for the individual user.

**File:** `backend/app/services/equipment_efficiency_service.py`

### 6. Milestone Velocity (`GET /milestone-velocity`)

**Data source:** `training_milestones` (previously unused)

Tracks milestone frequency (PRs, achievements), inter-milestone intervals using LAG window function, and velocity trend (accelerating/stable/decelerating). Counts milestones in 30d and 90d windows.

**File:** `backend/app/services/milestone_velocity_service.py`

### 7. Training Readiness Score (`GET /training-readiness`)

**Data source:** Cross-cutting composite (reuses 3 existing services + 2 queries)

Composite 0-100 pre-workout readiness score combining 5 weighted dimensions:
- Sleep quality + hours (weight 0.30) -- from `workout_feedback`
- Soreness (weight 0.20) -- max active soreness from `soreness_reports` (last 72h)
- Recovery (weight 0.20) -- from existing `recovery_service`
- ACWR (weight 0.15) -- from existing `acwr_service`
- Fitness-Fatigue preparedness (weight 0.15) -- from existing `fitness_fatigue_service`

Analogous to the Hooper Index (Hooper & Mackinnon 1995). Missing dimensions redistribute weights proportionally. Default 75 with no data.

**File:** `backend/app/services/training_readiness_service.py`

## Files Changed

### New Files (9)

| File | Purpose |
|------|---------|
| `backend/app/services/plan_adherence_service.py` | Plan adherence trend |
| `backend/app/services/antagonist_balance_service.py` | Antagonist pair balance |
| `backend/app/services/tempo_analysis_service.py` | Tempo/TUT analysis |
| `backend/app/services/soreness_patterns_service.py` | Soreness patterns |
| `backend/app/services/equipment_efficiency_service.py` | Equipment efficiency |
| `backend/app/services/milestone_velocity_service.py` | Milestone velocity |
| `backend/app/services/training_readiness_service.py` | Training readiness |
| `backend/tests/test_wave2_analytics.py` | 82 tests for all 7 services |
| `docs/changes/2026-03-25/wave2-analytics-enrichment.md` | This document |

### Modified Files (2)

| File | Change |
|------|--------|
| `backend/app/models/schemas.py` | 14 new Pydantic models, 7 new dashboard fields |
| `backend/app/routers/advanced_analytics.py` | 7 new endpoints, dashboard updated to 31 parallel metrics |

## Domain Expert Validation

Combined 4-expert consultation with all experts in a single session:

| Analytics | Fitness | Sports Med | Data Sci | Backend |
|-----------|---------|-----------|----------|---------|
| Plan Adherence | Adherence strongest predictor (Steele 2017) | Declining adherence = overtraining sign | OLS regression, 4-week minimum | Simple aggregation on indexed table |
| Antagonist Balance | Per-pair thresholds (Kolber/Hewett) | 1.5:1 only for chest:lats | Activation-weighted volume | UNION ALL unfold + exercise_muscles JOIN |
| Tempo/TUT | <20s = strength, not a safety concern | Slow eccentric + heavy load = tendon note | Parse in Python, handle 'X' as 1s | Raw text column, Python parsing |
| Soreness Patterns | DOMS peaks 24-72h; not stimulus indicator | Level 4 >72h = red flag | Lag analysis + Spearman correlation | JOIN with training_day_summary |
| Equipment Efficiency | Frame as personal comparison only | No safety concerns | Control for training maturity | Uses existing equipment_usage_stats view |
| Milestone Velocity | 1RM PRs most meaningful type | No safety concerns | LAG window for intervals | Simple temporal analysis |
| Training Readiness | Sleep highest weight (Knowles 2018) | NO "safe to train" threshold | Weighted sum, proportional redistribution | Reuse 3 existing services |

## No Database Migrations Required

All targeted tables/columns already exist: `plan_adherence_log` (migration 023), `muscle_antagonist_pairs` (migration 023), `sets.tempo` (migration 001), `soreness_reports` (migration 013), `equipment_variants` + `equipment_usage_stats` (migration 019/023), `training_milestones` (migration 023).

## Test Results

250 passed, 0 failed (82 wave-2 + 31 wave-1 + 137 existing).

## Cumulative Analytics Count

| Wave | Endpoints | Cumulative |
|------|-----------|-----------|
| Original (pre-enrichment) | 17 | 17 |
| Wave 1: Deep Insights | 7 | 24 |
| Wave 2: Untapped Data | 7 | 31 |
