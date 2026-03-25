# Exercise Depth & Insights Enrichment

**Date:** 2026-03-25
**Migrations:** 029_exercise_depth_enrichment.sql, 030_exercise_depth_seed.sql
**Validated by:** fitness-domain-expert (opus), database-specialist (sonnet), qa-reviewer (opus)

## Summary

Deepens the exercise data model with biomechanical classification, structured coaching cues, enhanced workout feedback, and four new analytical views. Also fixes a deduplication bug in migration 028.

## Process

1. Analyzed reference implementation (github.com/mmm00007/gym-tracker) for schema inspiration
2. Proposed 17 enrichments to the fitness domain expert — 4 approved, 7 approved with caveats, 6 rejected
3. Consulted database specialist for schema design, indexes, RLS, and migration strategy
4. Incorporated domain expert recommendations (array primary_joints, 5-point stability scale, contraction_emphasis terminology, technique_modifier scope)
5. Code reviewed by qa-reviewer for bugs, conventions, and security

## Bug Fix: Progression Rules Deduplication (Migration 029, Section 1)

**Problem:** Migration 028's `ON CONFLICT DO NOTHING` for population-default progression rules (where both `user_id` and `exercise_id` are NULL) did not prevent duplicate inserts. PostgreSQL B-tree indexes treat `NULL != NULL`, so the partial unique index `progression_rules_default_unique_idx` on `(exercise_id, goal) WHERE user_id IS NULL` could not detect conflicts when `exercise_id` is NULL.

**Fix:**
- Deduplicate existing rows (keep earliest per goal)
- Replace the single partial index with two:
  - `progression_rules_population_default_unique_idx` on `(goal) WHERE user_id IS NULL AND exercise_id IS NULL` — for goal-level defaults
  - `progression_rules_exercise_default_unique_idx` on `(exercise_id, goal) WHERE user_id IS NULL AND exercise_id IS NOT NULL` — for exercise-specific defaults

## View Fix: e1rm_progress_bucketed (Migration 029, Section 2)

Renamed `working_sets` to `training_sets` and changed the count to include all filtered set types (working, backoff, failure). Previously, the view filtered sets by `set_type IN ('working', 'backoff', 'failure')` but only counted `working` sets, creating misleading data when the best e1RM came from a backoff or failure set.

## Schema Changes

### A. Exercises Table: Biomechanical Classification

| Column | Type | Purpose |
|--------|------|---------|
| `primary_joints` | text[] | Joints loaded by exercise. Array (not single enum) because compounds involve multiple joints. Cross-references with `injury_reports.body_area` for contraindication flagging. |
| `movement_plane` | text | Anatomical plane: sagittal/frontal/transverse/multiplanar. Identifies movement pattern gaps (most lifters overtrain sagittal plane). |
| `stability_demand` | smallint 1-5 | Stabilization requirement: 1=machine, 2=Smith, 3=cable, 4=free weight bilateral, 5=unilateral/bodyweight. Powers exercise substitution and beginner recommendations. |
| `contraction_emphasis` | text | Dominant contraction: standard/isometric/eccentric_emphasis/plyometric/ballistic. Determines which set fields are relevant (e.g., isometric uses duration_seconds). |

**Rejected proposals:**
- `force_vector` — Duplicate of existing `movement_pattern` column (015). Domain expert confirmed redundancy.
- `grip_type` — Variant-level attribute, not exercise-level. A "pull-up" can be pronated, supinated, or neutral — these are separate exercises in the database. User preferences go in `user_exercise_notes`.
- `stance_type` — Redundant with exercise name. "Incline bench press" and "bench press" are already separate exercises; tagging stance adds no analytical value.

### B. Sets Table: Technique Modifier

| Column | Type | Purpose |
|--------|------|---------|
| `technique_modifier` | text DEFAULT 'standard' | Intensity technique applied: drop_set, rest_pause, cluster_set, myo_rep, amrap, emom, mechanical_drop_set, forced_rep, tempo_set. Orthogonal to `set_type` (which describes structural role). |

Also added `sets_tempo_format` CHECK constraint on existing `tempo` column to enforce E-P-C-T format (e.g., '3-1-2-0').

**Rejected proposals:**
- `perceived_difficulty` — Conflates RPE (already validated 1-10 scale) with form quality. No validated psychometric scale exists for this construct. Domain expert recommended against adding a third subjective effort column.
- `super_set` / `giant_set` as technique_modifier values — These are session-level exercise pairings, not per-set techniques. Model via `plan_items.superset_group` instead.

### C. Profiles Table

| Column | Type | Purpose |
|--------|------|---------|
| `sex` | text (male/female) | Biological sex for strength standard comparisons. Required by `relative_strength_benchmarks` view; ExRx/Kilgore norms are sex-stratified. |

### D. Workout Feedback Enhancement

Extended existing `workout_feedback` table (migration 019) instead of creating separate `session_ratings` / `training_readiness` tables per domain expert recommendation (users won't fill out two separate forms).

| Column | Type | Purpose |
|--------|------|---------|
| `pump_quality` | smallint 1-5 | Subjective hypertrophy cue |
| `focus` | smallint 1-5 | Mind-muscle connection quality |
| `nutrition_quality` | smallint 1-5 | Pre-training nutrition assessment |
| `motivation` | smallint 1-5 | Subjective drive/willingness |
| `is_pre_session` | boolean DEFAULT false | Distinguishes pre-workout readiness check-ins from post-workout reflections |

Unique constraint changed from `(user_id, training_date)` to `(user_id, training_date, is_pre_session)` to allow both pre and post entries on the same day.

### E. Exercise Cues Table (New)

Structured coaching cues per exercise, replacing the unstructured `instructions[]` and `form_tips[]` arrays. Categories align with NSCA CSCS coaching structure.

**Cue types:** setup, bracing, execution, breathing, mind_muscle, safety, common_fault

**RLS:** Public read for all authenticated users (reference data, same pattern as `exercise_substitutions`).

## New Analytical Views

### 1. training_load_trend (ACWR)

Weekly volume load with Acute:Chronic Workload Ratio.
- **Acute load:** 4-week rolling average
- **Chronic load:** 8-week rolling average
- **ACWR:** acute/chronic ratio
- **Sweet spot:** 0.8-1.3 (Gabbett, 2016, British Journal of Sports Medicine)
- **Overreaching risk:** >1.3
- **Detraining risk:** <0.8
- Also computes week-over-week change percentage

Uses rolling averages per original Gabbett methodology (simpler and more transparent than EWMA).

### 2. muscle_recovery_status

Per-user, per-muscle-group recovery estimate based on:
- Time since last trained
- Last session volume
- Recent soreness reports (last 3 days)
- Active injuries that limit training

**Recovery states:**
- `fresh` — >72h since trained, no soreness, no injuries
- `recovered` — 48-72h, low soreness (DOMS <= 1)
- `recovering` — <48h or moderate soreness
- `overreached` — injury limiting training, or high soreness + recently trained

Maps injury body areas to muscle groups for cross-referencing (e.g., knee injury flags quadriceps and hamstrings).

### 3. relative_strength_benchmarks

Compares user's best e1RM per exercise against population norms from `strength_standards` table.
- Uses BW-relative ratios (preferred) or absolute values (fallback)
- **Tiers:** untrained / beginner / novice / intermediate / advanced / elite (ExRx/Kilgore)
- Includes `progress_to_next_pct` for progress bar UI
- Falls back gracefully when bodyweight not logged

### 4. exercise_proficiency_index

Composite per-exercise proficiency score (0-100) over 8 weeks. Components (25 points each):
1. **Frequency** — sessions per week for this exercise
2. **Progression** — e1RM trend (positive slope = progressing)
3. **Consistency** — coefficient of variation of working weight
4. **Volume** — average weekly working sets

Component scores exposed alongside the composite for UI transparency. Weights are documented as arbitrary heuristic (no peer-reviewed formula).

## Seed Data (Migration 030)

### Biomechanical Metadata

Tagged ~50 exercises across categories:
- **Major compounds:** Squat, Deadlift, Bench Press, OHP, Barbell Row, Front Squat, RDL, Sumo DL, Incline Bench, Push Press
- **Dumbbell compounds:** DB Bench, DB Shoulder Press, DB Row, Lunges, Bulgarian Split Squat
- **Machine exercises:** Leg Press, Leg Extension, Leg Curl, Chest Press, Lat Pulldown, Cable Row, Smith Squat, Hack Squat
- **Isolation:** Barbell Curl, DB Curl, Hammer Curl, Triceps Pushdown, Overhead Extension, Lateral Raise, Front Raise, Face Pull, Reverse Fly, Cable Fly, Calf Raise
- **Bodyweight/special:** Pull-Up, Dip, Push-Up, Plank, Side Plank, Wall Sit, Box Jump, Nordic Curl, KB Swing, Olympic lifts, Woodchop, Russian Twist, Hip Thrust, Ab Crunch

All remaining exercises defaulted to `contraction_emphasis = 'standard'`.

### Exercise Cues

Structured coaching cues for the 10 most common exercises:
Barbell Squat, Bench Press, Deadlift, OHP, Barbell Row, Pull-Up, Romanian Deadlift, Lat Pulldown, DB Bench Press, Lateral Raise

7-10 cues per exercise covering setup, bracing, execution, breathing, safety, mind-muscle connection, and common faults.

## Index Summary

| Index | Table | Purpose |
|-------|-------|---------|
| `exercises_primary_joints_idx` (GIN) | exercises | Array containment queries for injury cross-referencing |
| `sets_user_technique_modifier_idx` | sets | Filter non-standard technique sets |
| `exercise_cues_exercise_type_order_idx` | exercise_cues | Primary cue lookup |
| `exercise_cues_unique_idx` | exercise_cues | Prevent duplicate cues at same position |
| `progression_rules_population_default_unique_idx` | progression_rules | Fix: unique on (goal) for NULL user_id + NULL exercise_id |
| `progression_rules_exercise_default_unique_idx` | progression_rules | Fix: unique on (exercise_id, goal) for NULL user_id + non-NULL exercise_id |

## Migration Safety

- All schema changes use `IF NOT EXISTS` / `IF NOT` guards
- Bug fix deduplication keeps earliest row per goal (deterministic)
- Workout feedback unique constraint migration handles potential name variations
- Seed updates use `WHERE name = ... AND NOT is_custom` to avoid touching user-created exercises
- All cue inserts use `ON CONFLICT DO NOTHING` for idempotency
