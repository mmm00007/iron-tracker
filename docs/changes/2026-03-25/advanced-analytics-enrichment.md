# Advanced Analytics Enrichment

**Date:** 2026-03-25
**Scope:** Backend analytics overhaul -- 6 new services, 8 new API endpoints, 40 new tests
**Inspiration:** [gym-tracker](https://github.com/mmm00007/gym-tracker) analytics architecture

---

## Summary

The Iron Tracker backend previously offered three analytics capabilities: a weekly snapshot (this week vs last week), per-exercise e1RM trends, and AI-powered text analysis via Claude. This change introduces a comprehensive advanced analytics layer with seven new metric domains, validated by four specialist agents (fitness domain expert, sports medicine doctor, data science expert, backend specialist).

All new endpoints live under `/api/analytics/advanced/` and are gated behind the `advancedAnalyticsEnabled` rollout flag. A single `/dashboard` endpoint aggregates all metrics in parallel for optimal performance.

---

## New Capabilities

### 1. Muscle Workload Analysis

**Endpoint:** `GET /api/analytics/advanced/muscle-workload?period=7`
**Service:** `muscle_workload_service.py`

Computes weighted volume distribution across all trained muscle groups. Each set's volume (weight x reps) is distributed to muscles based on the `exercise_muscles` junction table:

- Primary muscles receive 100% of set volume
- Secondary muscles receive 50% of set volume

The service normalizes raw volume using per-muscle-group baseline coefficients (calibrated against RP/NSCA literature for intermediate lifters) and applies sparse-data shrinkage to prevent volatile scores when training history is limited.

**Workload Balance Index:** Shannon entropy of the volume distribution, normalized to [0, 1]. A score of 1.0 means perfectly even distribution across all active muscle groups; lower scores indicate concentration on fewer groups.

| Balance Index | Label |
|--------------|-------|
| >= 0.85 | Well balanced |
| 0.65 - 0.84 | Moderate |
| 0.45 - 0.64 | Imbalanced |
| < 0.45 | Very imbalanced |

**Baseline Coefficients** (relative expected volume for an intermediate lifter):

| Muscle | Coefficient | Muscle | Coefficient |
|--------|------------|--------|------------|
| Chest | 1.0 | Quadriceps | 1.0 |
| Lats | 1.0 | Hamstrings | 0.8 |
| Glutes | 1.0 | Shoulders | 0.8 |
| Triceps | 0.65 | Biceps | 0.55 |
| Abdominals | 0.6 | Lower Back | 0.5 |
| Trapezius | 0.5 | Calves | 0.5 |
| Obliques | 0.5 | Forearms | 0.45 |

These were reviewed and adjusted by the fitness domain expert (triceps raised from 0.55 to 0.65, quadriceps from 0.95 to 1.0, trapezius and lower back lowered).

---

### 2. Progressive Overload Tracking

**Endpoint:** `GET /api/analytics/advanced/progressive-overload?weeks=8`
**Service:** `progressive_overload_service.py`

For every exercise with >= 3 training sessions in the lookback period:

- **Overload rate:** Linear regression (pure Python OLS) on best daily e1RM values, expressed as kg/week.
- **Plateau detection:** Coefficient of variation (CV) of weekly best e1RM values across a sliding 3-week window. A plateau is detected when CV < 5% for 4+ consecutive weeks AND the overload rate is near zero (< 0.5 kg/week). This dual requirement prevents flagging steady, consistent progressions as plateaus.
- **Classification:** Each exercise is labeled as `progressing`, `plateau`, or `regressing`.

**Expert corrections applied:**
- Plateau CV threshold widened from 2% to 5% (fitness expert: 2% produces false positives from normal training variation and Epley formula noise).
- Minimum plateau duration raised from 3 to 4 weeks.
- Plateau requires near-zero slope, not just low variance (data science expert: a steady 2.5 kg/week progression has low CV within any short window but is clearly not a plateau).

---

### 3. Volume Landmarks

**Endpoint:** `GET /api/analytics/advanced/volume-landmarks`
**Service:** `volume_landmarks_service.py`

Compares the user's current weekly set count (last 7 days) per muscle group against research-based volume thresholds from Renaissance Periodization (Israetel, Hoffmann, & Smith, 2021) and Schoenfeld meta-analyses:

| Landmark | Meaning |
|----------|---------|
| MV (Maintenance Volume) | Minimum to prevent muscle loss |
| MEV (Minimum Effective Volume) | Minimum to drive adaptation |
| MAV (Maximum Adaptive Volume) | Optimal range for most lifters |
| MRV (Maximum Recoverable Volume) | Upper limit before recovery fails |

Sets are weighted: primary muscles count as 1.0 set, secondary as 0.5 set.

Each muscle group receives a status classification: `below_mv`, `maintenance`, `productive`, `approaching_mrv`, or `over_mrv`, with a corresponding plain-English recommendation.

**Per-muscle-group thresholds** (sets/week for intermediate lifters):

| Muscle | MV | MEV | MAV | MRV |
|--------|-----|------|------|------|
| Chest | 6 | 8 | 16 | 22 |
| Lats | 6 | 8 | 18 | 25 |
| Quadriceps | 6 | 8 | 16 | 20 |
| Shoulders | 4 | 8 | 16 | 22 |
| Biceps | 4 | 6 | 14 | 20 |
| Triceps | 4 | 6 | 14 | 18 |
| Hamstrings | 4 | 6 | 14 | 18 |
| Glutes | 0 | 4 | 16 | 20 |
| Calves | 6 | 8 | 14 | 20 |
| Abdominals | 0 | 4 | 16 | 20 |
| Trapezius | 0 | 4 | 12 | 20 |
| Forearms | 0 | 2 | 10 | 16 |
| Lower Back | 0 | 2 | 10 | 14 |

**Sports medicine note:** The MRV thresholds are population-level defaults. Individual variation is 2-3x (Israetel et al.). The app presents these as guidelines, not absolute limits.

---

### 4. Recovery & Readiness Score

**Endpoint:** `GET /api/analytics/advanced/recovery`
**Service:** `recovery_service.py`

Estimates per-muscle-group recovery status by combining:
- Hours since last training session targeting that muscle
- Expected recovery time by muscle size (large 72h, medium 56h, small 48h)
- Most recent soreness report (0-4 scale)
- Number of sets in the lookback period

**Four-tier classification** (expanded from 3 tiers per sports medicine expert):

| Status | Criteria | Meaning |
|--------|----------|---------|
| Fresh | >130% of expected recovery, soreness <= 1 | Fully recovered, ready for high intensity |
| Recovered | 80-130% of expected recovery, soreness <= 2 | Adequate for moderate training |
| Fatigued | <80% of expected recovery or soreness = 3 | Insufficient recovery |
| At Risk | Soreness = 4 (extreme) | Possible injury -- consider rest |

**Overall readiness score (0-100):** Weighted average of per-muscle status scores (fresh=100, recovered=70, fatigued=30, at_risk=10).

**Medical disclaimer** (mandatory, non-negotiable per sports medicine expert):
> "Recovery scores are estimates based on training data and general exercise science guidelines. They do not constitute medical advice. Listen to your body and consult a healthcare professional if you experience pain beyond normal muscle soreness."

---

### 5. Session Quality Metrics

**Endpoint:** `GET /api/analytics/advanced/session-quality?period=7`
**Service:** `session_quality_service.py`

Analyzes training quality over the specified period:

| Metric | Description |
|--------|-------------|
| Set type distribution | % breakdown of warmup / working / top / drop / backoff / failure sets |
| Average RPE | Mean RPE across working sets (excludes warmups) |
| Average RIR | Mean Reps in Reserve across working sets |
| Relative intensity | Average weight used as % of estimated 1RM |
| Effective sets | Count of sets at RPE >= 7 (sufficient stimulus per Schoenfeld/Baz-Valle) |
| Effective ratio | Effective sets / total working sets |
| Low-stimulus sets | Non-warmup, non-backoff sets at RPE < 4 |

**Expert corrections applied:**
- "Junk volume" renamed to "low-stimulus sets" throughout the API (fitness + sports medicine experts: pejorative labeling encourages overexertion).
- RPE threshold lowered from < 5 to < 4 (sports medicine expert: sets at RPE 4-6 can be deliberate technique work or active recovery; data science expert agreed).
- Backoff sets excluded from low-stimulus detection (data science expert: these are intentionally lower RPE).

---

### 6. Periodization Analysis

**Endpoint:** `GET /api/analytics/advanced/periodization?weeks=8`
**Service:** `periodization_service.py`

Tracks training periodization over the lookback period:

- **Weekly volume trend:** Total volume (weight x reps) per ISO week with training days count.
- **Foster's training monotony:** `mean(daily_volume) / std(daily_volume)` over the last 7 days. Rest days are included as zero-volume days (per Foster's original methodology). High monotony correlates with injury risk.
- **Training strain:** `weekly_load x monotony`. Captures the interaction between load uniformity and magnitude.
- **Current phase detection:** Compares last week's volume to prior weeks' average. Labels as `building` (>10% increase), `maintaining` (-10% to +10%), `tapering` (-30% to -10%), or `deloading` (>30% decrease).

| Monotony | Status | Meaning |
|----------|--------|---------|
| > 1.5 | High risk | Training too uniform -- vary daily load |
| 1.2 - 1.5 | Elevated | Monitor recovery |
| < 1.2 | Normal | Good training variety |

**Expert corrections applied:**
- Monotony threshold lowered from 2.0 to 1.5 (sports medicine expert: Foster's original 2.0 was calibrated for endurance sports; resistance training has inherently less session-to-session variation).

---

### 7. Body Part Balance

**Endpoint:** `GET /api/analytics/advanced/body-part-balance?period=7`
**Service:** `periodization_service.py` (same file, separate function)

Evaluates structural balance across movement patterns:

| Metric | Target | Rationale |
|--------|--------|-----------|
| Push/pull ratio | 0.77 - 1.0 (optimal) | Slight pull dominance protects shoulder health (Cressey & Robertson, NSCA) |
| Upper/lower ratio | 0.8 - 1.5 (balanced) | No single target -- depends on goals |
| Per-muscle frequency | Tracked, flagged at >= 5x/week | Excessive frequency may exceed recovery capacity |

**Imbalance detection:** Flags ratios outside acceptable ranges with specific, actionable recommendations (e.g., "Push-dominant (1.45:1) -- add more pulling exercises to reduce shoulder injury risk").

**Muscle group classification:**

| Push | Pull | Upper | Lower |
|------|------|-------|-------|
| Chest | Lats | Chest | Quadriceps |
| Shoulders | Biceps | Shoulders | Hamstrings |
| Triceps | Forearms | Triceps | Glutes |
| | Trapezius | Lats | Calves |
| | Lower Back | Biceps | |
| | | Forearms | |
| | | Trapezius | |

---

### 8. Aggregated Dashboard

**Endpoint:** `GET /api/analytics/advanced/dashboard?period=7`

Returns all seven metric domains in a single response. All queries run in parallel via `asyncio.gather(return_exceptions=True)` -- if one metric fails, the others still return successfully with the failed metric replaced by an empty default (backend specialist recommendation for fault isolation).

---

## Enhanced Existing Features

### Enriched Weekly Summary Cron Job

`weekly_summary_service.py` now generates richer automated weekly reports by incorporating the new analytics:

**Previous insights (1 per report):**
- Weekly overview (sets, volume, training days)

**New insights (up to 6 per report):**
- Weekly overview with consistency recommendation
- Training intensity (average RPE, effective sets ratio)
- Workload balance (Shannon entropy score and label)
- Volume warnings (muscles exceeding MRV)
- Volume gaps (muscles below MEV)
- Push/pull balance (when imbalanced)

### Enriched AI Analysis Context

`analysis_service.py` now sends computed analytics metrics to Claude alongside raw training data, enabling deeper, evidence-backed AI insights. The Claude prompt now includes:

- Average RPE and effective set count
- Muscle workload balance index and per-muscle normalized scores
- Volume landmark warnings (muscles over MRV or below MEV)
- Push/pull and upper/lower ratios with imbalance flags

---

## Files Changed

### New Files

| File | Lines | Purpose |
|------|-------|---------|
| `app/services/muscle_workload_service.py` | 135 | Weighted muscle workload + balance index |
| `app/services/progressive_overload_service.py` | 145 | Per-exercise overload rate + plateau detection |
| `app/services/volume_landmarks_service.py` | 120 | Weekly sets vs MV/MEV/MAV/MRV thresholds |
| `app/services/recovery_service.py` | 130 | Per-muscle recovery + readiness score |
| `app/services/session_quality_service.py` | 125 | RPE, intensity, effective volume |
| `app/services/periodization_service.py` | 230 | Monotony, strain, phase detection, push/pull balance |
| `app/routers/advanced_analytics.py` | 230 | 8 new API endpoints |
| `tests/test_advanced_analytics.py` | 530 | 40 tests (unit + integration) |

### Modified Files

| File | Change |
|------|--------|
| `app/models/schemas.py` | 12 new Pydantic response models added |
| `app/main.py` | New router registered + `advancedAnalyticsEnabled` rollout flag |
| `app/services/weekly_summary_service.py` | Enriched cron reports with intensity, balance, volume, push/pull insights |
| `app/services/analysis_service.py` | AI context enriched with computed metrics; `datetime.utcnow()` deprecation fixed |
| `tests/test_weekly_summary_service.py` | Mock data updated for new `rpe`/`set_type` fields |

---

## Domain Expert Validation

Four specialist agents reviewed the plan before and during implementation:

### Fitness Domain Expert (Opus)

**Verdict: Approved with corrections**

- Adjusted muscle baseline coefficients (triceps, quadriceps, trapezius, lower back)
- Widened plateau detection from 2% CV / 3 weeks to 5% CV / 4 weeks
- Confirmed volume landmark values per RP literature
- Confirmed push/pull ratio targets per NSCA guidelines
- Confirmed RPE >= 7 threshold for effective volume per Schoenfeld/Baz-Valle

### Sports Medicine Expert (Opus)

**Verdict: Approved with 3 high-priority conditions**

- Added "at_risk" recovery tier for soreness level 4 (severe pain)
- Lowered Foster's monotony threshold from 2.0 to 1.5 for resistance training
- Mandatory medical disclaimer on all recovery/readiness displays
- Lowered low-stimulus RPE threshold from < 5 to < 4
- Recommended against "junk volume" labeling (renamed to "low-stimulus sets")
- Flagged MRV thresholds as population-level defaults with high individual variation

### Data Science Expert (Opus)

**Verdict: Approved with algorithm modifications**

- Confirmed Shannon entropy over Gini coefficient for balance scoring
- Confirmed rest days must be included as zero in monotony calculation
- Recommended excluding backoff sets from low-stimulus detection
- Recommended Theil-Sen over OLS for future robustness (current OLS is acceptable for MVP)
- Provided cold-start thresholds for each metric
- Recommended MAD-based outlier detection for future iteration

### Backend Specialist (Opus)

**Verdict: Approved -- provided implementation blueprint**

- Confirmed separate router (`advanced_analytics.py`) over extending existing
- Recommended `asyncio.gather(return_exceptions=True)` for fault-isolated dashboard
- Pure Python linear regression (no numpy dependency needed)
- No materialized views needed at current scale
- Suggested partial index on `sets(user_id, logged_at) WHERE weight > 0 AND reps > 0` for future optimization

---

## API Reference

All endpoints require Bearer token authentication.

```
GET /api/analytics/advanced/muscle-workload?period=7
GET /api/analytics/advanced/progressive-overload?weeks=8
GET /api/analytics/advanced/volume-landmarks
GET /api/analytics/advanced/recovery
GET /api/analytics/advanced/session-quality?period=7
GET /api/analytics/advanced/periodization?weeks=8
GET /api/analytics/advanced/body-part-balance?period=7
GET /api/analytics/advanced/dashboard?period=7
```

**Query parameters:**

| Parameter | Type | Range | Default | Used by |
|-----------|------|-------|---------|---------|
| `period` | int | 1-365 | 7 | muscle-workload, session-quality, body-part-balance, dashboard |
| `weeks` | int | 3-52 | 8 | progressive-overload, periodization |

---

## Test Coverage

40 new tests covering:

- **Unit tests:** Linear regression (4), plateau detection (4)
- **Service tests:** Muscle workload (4), progressive overload (3), volume landmarks (4), recovery (3), session quality (3), periodization (3), body part balance (3)
- **Endpoint integration tests:** All 8 endpoints including parameter validation (9)

All 70 tests pass (40 new + 30 existing). Zero lint errors (ruff check + format).
