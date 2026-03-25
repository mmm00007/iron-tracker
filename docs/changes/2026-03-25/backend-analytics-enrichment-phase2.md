# Backend Analytics Enrichment Phase 2 — 2026-03-25

## Summary

Expanded the advanced analytics dashboard from 13 to 17 metrics, fixed critical strength standards issues (added female norms + bodyweight-relative classification), and added 4 new analytics services. Total analytics backend now provides 17 real-time metrics computed in parallel.

## Changes

### 1. Strength Standards Service — Major Revision

**Problem:** Fitness domain expert flagged as NEEDS REVISION. All users were evaluated against male-only, absolute-value standards (calibrated for ~80kg male). Female users were systematically misclassified. No bodyweight adjustment.

**Fix:**
- Added `_FEMALE_STANDARDS` table with 24 exercise entries based on NSCA Table 18.7 and Hoffman (2006). Sex-specific ratios vary by lift: upper body ~55-60% of male, lower body ~65-75%.
- Added `_MALE_BW_RATIOS` and `_FEMALE_BW_RATIOS` tables for bodyweight-relative standards (10 key compound lifts).
- Service now queries `profiles.sex` and `profiles.bodyweight` to auto-select appropriate standards.
- Falls back to absolute standards when no profile data exists.
- Fixed tie-breaking in overall tier calculation (was lexicographic, now uses tier ordering).
- Context-aware disclaimer shows which standards basis was used.

### 2. Composite Training Score (NEW)

**Endpoint:** `GET /api/analytics/advanced/composite-score?period=28`

A single 0-100 score grading overall training quality across 6 weighted dimensions:
- Consistency (20%) — Training frequency relative to 3-5 day/week ideal
- Progressive Overload (20%) — % of exercises showing strength gains
- Volume Adequacy (15%) — % of muscles above MEV (8+ sets/week)
- Recovery (15%) — % of muscles adequately recovered
- Balance (15%) — Shannon entropy of volume distribution
- Session Quality (15%) — Average working RPE proximity to 7-8.5 ideal

Cold-start: Dimensions with insufficient data are excluded; weight redistributed proportionally.

### 3. Muscle Frequency Optimization (NEW)

**Endpoint:** `GET /api/analytics/advanced/muscle-frequency?weeks=4`

Compares actual per-muscle training frequency against evidence-based targets from Schoenfeld (2016) meta-analysis and NSCA guidelines.

- 14 muscle groups with specific frequency ranges (e.g., Chest: 1.5-3x/week, Biceps: 2-4x/week)
- Classifications: severely_undertrained, undertrained, optimal, high_frequency, overfrequency
- Per-muscle recommendations
- Overall program status: well_optimized, undertrained, overfrequency, mixed

### 4. Workout Staleness Detection (NEW)

**Endpoint:** `GET /api/analytics/advanced/staleness?weeks=4`

Detects when workouts become too repetitive using Jaccard similarity between consecutive sessions.

- Staleness index weighted toward recent workouts (last 3 comparisons)
- Classifications: very_stale (>0.8), moderately_stale, balanced, highly_varied
- Shows shared exercises between consecutive workouts
- Based on principle of progressive variation (Kraemer & Ratamess 2004)
- Flags both excessive repetition AND excessive variation

### 5. Training Load Distribution (NEW)

**Endpoint:** `GET /api/analytics/advanced/load-distribution?weeks=4`

Analyzes how training volume is distributed across the week.

- Per-day-of-week average volume and session counts
- Weekly CV (coefficient of variation) of training-day volumes
- Classifications: very_even (<0.25 CV), well_distributed, moderately_uneven, highly_concentrated
- Flags: concentrated patterns, low-frequency warnings
- Identifies busiest and lightest training days

## Files Changed

### New Files
| File | Purpose |
|------|---------|
| `backend/app/services/composite_score_service.py` | Composite training quality score |
| `backend/app/services/muscle_frequency_service.py` | Per-muscle frequency vs targets |
| `backend/app/services/staleness_service.py` | Workout repetition detection |
| `backend/app/services/load_distribution_service.py` | Weekly load distribution analysis |
| `backend/tests/test_phase2_analytics.py` | 24 tests for all phase 2 services |

### Modified Files
| File | Change |
|------|--------|
| `backend/app/services/strength_standards_service.py` | Added female norms, BW-relative, profile query |
| `backend/app/models/schemas.py` | 8 new Pydantic models + updated dashboard |
| `backend/app/routers/advanced_analytics.py` | 4 new endpoints + dashboard updated to 17 metrics |
| `backend/tests/test_advanced_analytics.py` | Updated mock fixture for profile queries |
| `backend/tests/test_new_analytics.py` | Updated mock fixture for profile queries |

## Testing

- 24 new tests (phase 2)
- 107 total tests across all analytics test files
- All passing, zero regressions

## Scientific References

- Schoenfeld BJ et al. (2016). Effects of resistance training frequency on measures of muscle hypertrophy: a systematic review and meta-analysis. Sports Medicine.
- Kraemer WJ, Ratamess NA (2004). Fundamentals of resistance training: progression and exercise prescription. Medicine & Science in Sports & Exercise.
- Helms ER et al. (2015). Recommendations for natural bodybuilding contest preparation. Journal of the International Society of Sports Nutrition.
- Dankel SJ et al. (2017). Frequency: The overlooked resistance training variable. Sports Medicine.
- Hoffman J (2006). Norms for Fitness, Performance, and Health. Human Kinetics.
- NSCA Essentials of Strength Training and Conditioning (4th ed.) Table 18.7.
