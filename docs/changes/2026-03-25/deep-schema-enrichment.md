# Deep Schema Enrichment (Migrations 021-022)

**Date:** 2026-03-25
**Migrations:** `021_deep_schema_enrichment.sql`, `022_deep_seed_enrichment.sql`
**Validated by:** fitness-domain-expert (Opus), database-specialist (Sonnet)
**Inspired by:** [gym-tracker](https://github.com/mmm00007/gym-tracker) data model

## Summary

Two migrations adding 4 new tables, 1 new view, 14 new columns, and comprehensive seed data enrichment. Focus areas: rest period tracking, workout session clustering, exercise knowledge depth, plan programming prescriptions, insights evidence structure, volume target personalization, and periodization tracking.

## Changes

### A. Sets: Rest & Session Clustering

| Change | Type | Details |
|--------|------|---------|
| `sets.rest_seconds` | New column | INTEGER, nullable. Seconds rested before this set. Enables training density analysis. |
| `sets.workout_cluster_id` | New column | UUID, nullable. Gap-based session grouping within a training day. |
| `recompute_workout_clusters()` | New function | Application-callable PL/pgSQL function. Groups sets >N minutes apart into separate clusters. |

**Design decisions:**
- Rest is tracked per-set (not per-session) because rest varies within a session (3min between heavy squats vs 60s between lateral raises). Validated by NSCA position stand (Ratamess et al., 2009).
- Workout clustering uses an application-callable function instead of a row-level trigger to avoid recursive trigger loops (database-specialist recommendation).
- Gap threshold is user-configurable via `profiles.cluster_gap_minutes` (default 90 min). Range: 15-480 min.

### B. Exercises: Deeper Knowledge

| Change | Type | Details |
|--------|------|---------|
| `exercises.difficulty_level` | New column | SMALLINT 1-5. Motor complexity + injury risk rating. |
| `exercises.contraindications` | New column | TEXT[]. Structured safety warning tags from controlled vocabulary. |
| `exercise_muscles.function_type` | New column | TEXT: agonist/synergist/stabilizer. Biomechanical muscle role. |

**Difficulty scale criteria:**

| Level | Label | Examples |
|-------|-------|---------|
| 1 | Beginner | Leg press, lat pulldown, crunches, cable curls |
| 2 | Novice | Dumbbell curls, goblet squat, push-ups, DB bench |
| 3 | Intermediate | Barbell squat, bench press, deadlift, pull-ups |
| 4 | Advanced | Front squat, weighted dips, pistol squat, dragon flag |
| 5 | Elite | Snatch, clean & jerk, muscle-up, planche |

**Contraindication vocabulary:** `shoulder_impingement`, `lower_back_herniation`, `knee_anterior`, `wrist_strain`, `elbow_strain`, `neck_compression`, `rotator_cuff`, `hip_impingement`. These are general caution flags, not medical advice.

**Function type design:** Domain expert recommended dropping 'antagonist' from the classification. Antagonists are not meaningfully activated during exercises; they provide eccentric control. The three retained categories (agonist/synergist/stabilizer) align with standard kinesiology textbooks (Lippert, Floyd). Backfill derived from existing `is_primary` boolean and `activation_percent` values.

### C. Exercise Tags (New Table)

| Table | Columns | RLS |
|-------|---------|-----|
| `exercise_tags` | id, user_id, exercise_id, tag (slug format), created_at | user_id = auth.uid() |

User-customizable tags for exercises (e.g., `arm-day`, `rehab`, `competition-lift`). Tags use slug format (`^[a-z0-9_-]+$`, max 50 chars). FK to exercises uses `ON DELETE RESTRICT` (consistent with migration 018 pattern).

### D. Plans: Programming Depth

| Change | Type | Details |
|--------|------|---------|
| `plans.goal` | New column | Training goal: strength/hypertrophy/endurance/power/general/body_recomposition |
| `plan_items.target_rpe` | New column | NUMERIC(3,1). RPE prescription (1.0-10.0, half-points). |
| `plan_items.target_rir` | New column | SMALLINT. RIR prescription (0-5). |
| `plan_items.rest_target_seconds` | New column | INTEGER. Prescribed rest period. |
| `plan_items.tempo_prescription` | New column | TEXT. 4-digit tempo notation (e.g., "3110"). |
| `plan_items.superset_group` | New column | SMALLINT. Groups items into supersets/circuits. |

**Design decisions:**
- **Goal vs phase separation:** Domain expert recommended keeping 'peaking' and 'deload' as mesocycle phases, not plan goals. Goals describe training intent; phases describe where you are in a periodization block.
- **Both RPE and RIR:** Not redundant per domain expert. RPE (Tuchscherer) is powerlifting-oriented; RIR is hypertrophy-oriented. Consistency constraint ensures they agree within 1 when both are set.
- **Tempo on plan_items, not exercises:** Domain expert recommendation. Tempo is goal-dependent (bench press = "3110" in hypertrophy, "10X0" in strength), not exercise-inherent.

### E. Analysis Reports Enhancement

| Change | Type | Details |
|--------|------|---------|
| `analysis_reports.evidence` | New column | JSONB, default '[]'. Structured evidence array. |
| `analysis_reports.report_type` | New column | TEXT enum. Classification of report purpose. |
| `analysis_reports.status` | New column | TEXT, default 'ready'. Processing status. |

**Report types:** recommendation, weekly_trend, deload_alert, pr_analysis, balance_report, volume_check.

### F. Training Volume Targets (New Table)

| Table | Columns | RLS |
|-------|---------|-----|
| `training_volume_targets` | id, user_id, muscle_group_id, target_mv/mev/mav/mrv, notes, updated_at | user_id = auth.uid() |

Personalized weekly set targets per muscle group, replacing hardcoded population defaults. Uses the Renaissance Periodization framework (Israetel et al., 2021):
- **MV** (Minimum Viable Volume): Maintain muscle at minimum
- **MEV** (Minimum Effective Volume): Minimum for adaptation
- **MAV** (Maximum Adaptive Volume): Optimal range upper bound
- **MRV** (Maximum Recoverable Volume): Exceed = overreaching

CHECK constraints enforce logical ordering: MV <= MEV <= MAV <= MRV.

### G. Mesocycles (New Table)

| Table | Columns | RLS |
|-------|---------|-----|
| `mesocycles` | id, user_id, name, phase, start_date, end_date, target_weeks, plan_id, notes | user_id = auth.uid() |

**Phase nomenclature** (user-friendly names per domain expert, not Issurin academic terminology):
- `hypertrophy` — High volume, moderate intensity (accumulation)
- `strength` — Moderate volume, high intensity (intensification)
- `peaking` — Low volume, very high intensity (realization)
- `deload` — Reduced volume/intensity for recovery
- `transition` — Off-season / between programs
- `general` — Undulating or concurrent programming

### H. Training Day Summary View

New `training_day_summary` view with `security_invoker = true`. Aggregates per training day:
- `total_sets`, `working_sets`, `total_reps`
- `total_volume_kg` (normalized to kg, handles mixed weight units)
- `distinct_exercises`, `avg_rpe`, `avg_rest_seconds`
- `duration_minutes` (first-to-last set span, not total gym time)
- `cluster_count`, `best_estimated_1rm`

**Weight normalization:** View converts lb to kg (`weight * 0.453592`) before summing, solving the mixed-unit volume calculation bug identified by database-specialist.

## Seed Data (Migration 022)

- **Difficulty levels:** ~150+ exercises classified by name, remainder by equipment/category patterns
- **Contraindications:** 8 categories applied to ~30 exercises with known risk profiles
- **Function types:** Backfill from existing is_primary + activation_percent data

## New Indexes

| Index | Table | Columns | Type |
|-------|-------|---------|------|
| `sets_user_exercise_rest_idx` | sets | (user_id, exercise_id, logged_at DESC) | Partial (rest_seconds IS NOT NULL) |
| `sets_user_date_cluster_idx` | sets | (user_id, training_date, workout_cluster_id) | Partial (cluster_id IS NOT NULL) |
| `exercises_difficulty_idx` | exercises | (difficulty_level) | Partial (NOT NULL) |
| `exercises_contraindications_idx` | exercises | (contraindications) | GIN, partial (non-empty) |
| `exercise_muscles_function_idx` | exercise_muscles | (exercise_id, function_type) | Partial (NOT NULL) |
| `exercise_tags_user_tag_idx` | exercise_tags | (user_id, tag) | B-tree |
| `plan_items_superset_idx` | plan_items | (plan_day_id, superset_group) | Partial (NOT NULL) |
| `analysis_reports_type_idx` | analysis_reports | (user_id, report_type) | Partial (NOT NULL) |
| `analysis_reports_status_idx` | analysis_reports | (user_id, status) | Partial (status != 'ready') |
| `mesocycles_user_date_idx` | mesocycles | (user_id, start_date DESC) | B-tree |

## Schema Summary (Post-Migration)

| Metric | Before | After |
|--------|--------|-------|
| Tables | 23 | 27 (+exercise_tags, training_volume_targets, mesocycles, exercise_tags) |
| Views | 2 | 3 (+training_day_summary) |
| Columns on sets | 17 | 19 (+rest_seconds, workout_cluster_id) |
| Columns on exercises | 20 | 22 (+difficulty_level, contraindications) |
| Columns on plan_items | 8 | 13 (+target_rpe, target_rir, rest_target_seconds, tempo_prescription, superset_group) |
| Functions | 3 | 4 (+recompute_workout_clusters) |

## Backwards Compatibility

All changes are backwards-compatible:
- New columns are nullable or have defaults
- New tables have no required application-side changes
- View is additive (existing views unchanged)
- Function is opt-in (called explicitly from backend)

## Next Steps

- Backend: Call `recompute_workout_clusters()` after set mutations
- Frontend: Add rest timer with auto-capture of rest_seconds
- Frontend: Expose exercise tags UI (create, filter, manage)
- Frontend: Mesocycle timeline visualization
- Frontend: Volume targets editor (per-muscle sliders for MV/MEV/MAV/MRV)
- Backend: Feed evidence data to AI analysis service
- Backend: Seed default volume targets from existing `volume_landmarks_service.py` hardcoded values
