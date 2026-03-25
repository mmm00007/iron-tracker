# Training Insights, Warm-Up Guidance & Seed Data Enrichment

**Date:** 2026-03-25
**Scope:** Database schema (migrations 036-037), frontend types, build fix
**Agents used:** Fitness Domain Expert (opus), Database Specialist, Schema Auditor

## Summary

This session adds 4 new domain-expert-validated tables and enriches seed data for the 800+ exercise library. Every proposed enrichment was reviewed by the fitness domain expert agent with specific modifications based on NSCA/ACSM evidence.

## Build Fix

**File:** `frontend/src/hooks/useProfile.ts:24`
Added `current_body_weight_kg: null` to `DEFAULT_PROFILE` — the Profile type included this field (from a recent migration) but the default object was missing it, causing TypeScript compilation failure on Netlify.

---

## Migration 036: Training Insights & Warm-Up Guidance

### 1. Warm-Up Guidance on Exercises

**New columns on `exercises`:**
- `warmup_sets_min` (smallint, 0-5): Minimum warm-up sets for light working loads
- `warmup_sets_max` (smallint, 0-8): Maximum for near-maximal loads
- `specific_warmup_notes` (text): Freeform prep guidance

**Domain expert decision:** Warm-up ramp percentages (40%/60%/80%) are NOT stored on exercises — they are computed dynamically by the app layer based on working weight intensity. The expert cited Baechle & Earle (2016, NSCA 4th ed.): "the heavier the working load, the more warm-up sets are needed."

**Bulk seed values:**
- Compounds: 3-5 warm-up sets
- Isolations: 0-2 warm-up sets
- Other: 1-3 warm-up sets

### 2. Exercise Warm-Up Prerequisites Table

**New table: `exercise_warmup_prerequisites`**

Links compound exercises to preparation movements. Example: Barbell Squat -> hip circles -> goblet squat -> empty bar squat.

| Column | Type | Purpose |
|--------|------|---------|
| exercise_id | uuid FK | The main exercise |
| warmup_exercise_id | uuid FK (nullable) | Prep movement (may not be in library) |
| warmup_name | text | Name of the prep movement |
| sort_order | smallint | Execution sequence |
| duration_seconds | integer | Time for mobility/activation drills |
| reps | smallint | Rep count for pattern rehearsal |
| context | text | 'mobility', 'activation', 'pattern_rehearsal', 'corrective' |

**Evidence:**
- Kolber et al. (2009, JSCR): Rotator cuff activation pre-pressing reduces impingement risk
- Opplert & Babault (2018, Sports Medicine): Dynamic stretching improves acute squat performance
- Fradkin et al. (2010, JSCR): Systematic review confirming warm-up effects on performance

### 3. Exercise Effectiveness Scores Table

**New table: `exercise_effectiveness_scores`**

Per-user, rolling-window analysis of which exercises drive their progress. Answers the question: "Which exercises are actually working for me?"

**Key domain expert modifications:**
- **Rolling window** (default 8 weeks, configurable 4-52): Not all-time. Progression is NOT linear long-term (Rippetoe 2011). Linear regression within 8-12 weeks captures current gain rate.
- **Confidence intervals** (`e1rm_ci_lower`, `e1rm_ci_upper`): Only display scores when 95% CI excludes zero. A slope of 0.5 kg/week with CI [-0.3, 1.3] means "we don't know yet."
- **Within-category ranking**: Rank within `movement_pattern` (squat vs squat, not squat vs curl). Different muscle groups have different response curves (Schoenfeld 2017).
- **Performance-based recovery cost** (`performance_recovery_cost`): Percentage of sessions where e1RM dropped >5%. Domain expert rejected soreness as primary recovery metric — DOMS is poorly correlated with actual muscle damage (Nosaka 2011, Damas 2016).
- **Data quality gating**: `insufficient` (<6 weeks), `preliminary` (6-8), `reliable` (>8). Frontend hides scores until reliable.
- **Volume efficiency**: kg e1RM gained per 10 effective working sets (RPE >=7 per Helms 2018)

### 4. User Rest Recommendations Table

**New table: `user_rest_recommendations`**

Personalized inter-set rest optimization per exercise and training goal.

**Key domain expert modifications:**
- **Spearman rank correlation** (not Pearson): Rest-performance relationship is not necessarily linear; performance plateaus after a threshold. Spearman is robust to non-linearity and outliers.
- **Set position controlled**: Controls for fatigue accumulation confounder. Without this, later sets show spurious negative correlation (more fatigue + similar rest = seems like rest doesn't help).
- **Partitioned by training goal**: NSCA rest guidelines differ — strength 3-5min (Harris 1976: phosphocreatine resynthesis), hypertrophy 1.5-3min (Schoenfeld 2016), endurance 30-90s.
- **Minimum 84 set-pairs**: Based on Cohen (1988) — medium effect (rho=0.3) at 80% power requires ~84 data points.
- **Evidence:** de Salles (2009), Schoenfeld (2016), Grgic (2017)

### 5. Session Quality Scores Table

**New table: `session_quality_scores`**

Persistent pre-computed session quality composite with evidence-based sub-score weighting.

**Composite formula (v1):**
```
quality = 0.30 * completion + 0.25 * volume + 0.20 * progression
        + 0.15 * intensity + 0.05 * rest + 0.05 * density
```

**Weighting rationale (domain expert, ordered by outcome prediction strength):**
1. **Completion (30%)**: Steele et al. (2017, PeerJ) — adherence explains more variance in outcomes than any programming variable
2. **Volume (25%)**: Schoenfeld et al. (2017, JSCR) — dose-response for hypertrophy
3. **Progression (20%)**: Kraemer & Ratamess (2004, MSSE) — progressive overload principle
4. **Intensity (15%)**: Helms et al. (2018) — RPE management
5. **Rest (5%)**: Grgic et al. (2017) — less impactful when volume is equated
6. **Density (5%)**: Time-efficiency indicator, not outcome predictor

**Additional features:**
- `exercises_progressed` / `exercises_regressed` / `exercises_maintained`: Tracks both directions (domain expert: regression matters separately from stagnation)
- `session_rpe`: Optional user input; the most-validated session-level metric (Foster et al., 2001)
- `scoring_version`: Enables formula evolution without invalidating historical scores
- `compute_session_quality()` function: Service-role-only, implements the full composite algorithm

---

## Migration 037: Activation Percentage & Metadata Seed Data

### Problem

The schema audit revealed that ~95% of 873 exercises had NULL `activation_percent` on `exercise_muscles`. The views (`weekly_muscle_volume`, `muscle_activation_weights`, `workload_balance_scores`) all fall back to binary defaults (primary=100, secondary=50) when NULL — making the weighted volume calculations no more accurate than the simple `is_primary` boolean.

Similarly, `movement_pattern` and `laterality` had significant NULL coverage, silently degrading the movement pattern balance analytics and bilateral asymmetry detection.

### Solution

**EMG-derived activation percentages for compound exercises:**

| Exercise | Primary (100%) | Key Synergists |
|----------|---------------|----------------|
| Bench Press | Chest | Anterior delt 65%, Triceps 45% |
| Incline Press | Chest | Anterior delt 70%, Triceps 40% |
| Barbell Squat | Quadriceps | Glutes 75%, Hamstrings 35%, Core 25% |
| Deadlift | Glutes | Hamstrings 80%, Back 75%, Quads 45% |
| Romanian Deadlift | Hamstrings | Glutes 85%, Back 60% |
| Overhead Press | Shoulders | Triceps 55% |
| Pull-Up | Lats | Biceps 60% |
| Chin-Up | Lats | Biceps 75% (higher than pull-up) |
| Barbell Row | Back/Lats | Biceps 55% |
| Lunge/Split Squat | Quadriceps | Glutes 80%, Hamstrings 40% |
| Hip Thrust | Glutes | Hamstrings 40% |
| Push-Up | Chest | Front delt 55%, Triceps 50% |
| Dip | Chest/Triceps | Shoulders 65% |

**Isolation exercise defaults:**
- Bicep curl: Biceps 100%, Forearms 35%
- Tricep extensions: Triceps 100%
- Lateral raise: Shoulders 100%, Upper traps 30%
- Leg curl: Hamstrings 100%
- Leg extension: Quadriceps 100%
- Cable fly: Chest 100%, Front delt 35%
- Calf raise: Calves 100%

**Bulk fallback (remaining NULLs):**
- Primary muscles → 100%
- Non-primary agonists → 55%
- Synergists → 45%
- Stabilizers → 20%
- Other non-primary → 50%

**Movement pattern fill:** Pattern-matching on exercise names for curls → isolation, rows → horizontal_pull, pulldowns → vertical_pull, presses → horizontal/vertical_push, squats → squat, deadlifts → hip_hinge, lunges → lunge.

**Laterality fill:** Dumbbell → 'both', barbell → 'bilateral', cable → 'both', machine → 'bilateral', single-arm/leg → 'unilateral', bodyweight → 'bilateral'.

### Sources
- Lauver et al. (2016, JSCR): Bench press EMG comparison
- Escamilla et al. (2001, MSSE): Squat EMG analysis
- Schoenfeld et al. (2010, JSCR): Hamstring EMG during hip extension
- Schoenfeld et al. (2022, IJSS): Multi-joint exercise muscle activation
- Youdas et al. (2010, JSCR): Pull-up and lat pulldown EMG
- Andersen et al. (2014, JSCR): Shoulder press EMG
- Botton et al. (2013, JSCR): Cable crossover and fly EMG
- Contreras et al. (2015): Hip thrust EMG

---

## Frontend Types

**File:** `frontend/src/types/database.ts`

Added TypeScript interfaces for all new tables:
- `ExerciseWarmupPrerequisite` with `WarmupContext` type
- `ExerciseEffectivenessScore` with `EffectivenessRecommendation` and `DataQuality` types
- `UserRestRecommendation` with `TrainingGoal` type
- `SessionQualityScore`

---

## Next Steps

1. **Backend cron jobs**: Implement `compute_session_quality()` calls after set mutations; add exercise effectiveness and rest optimization computation services
2. **Frontend components**: Build session quality trend chart, exercise effectiveness dashboard, personalized rest timer, warm-up protocol generator
3. **Warm-up prerequisite seed data**: Populate the `exercise_warmup_prerequisites` table for the top 20 compounds
4. **API endpoints**: Expose effectiveness scores and rest recommendations via FastAPI for the frontend analytics pages
