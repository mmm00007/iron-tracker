# Schema Enrichment: Deeper Exercise Data & Insights Infrastructure

**Date:** 2026-03-25
**Migrations:** 019_schema_enrichment.sql, 020_seed_enrichment.sql
**Seed data:** 004_exercise_substitutions.sql
**Inspiration:** [mmm00007/gym-tracker](https://github.com/mmm00007/gym-tracker)

## Motivation

Iron Tracker had a solid set-centric data model but lacked depth in two areas:

1. **Exercise metadata** -- the 873 seed exercises had basic fields (name, force, level, equipment) but no training-split classification (push/pull/legs), no laterality tracking, no alternate names for search, and no exercise alternatives.
2. **Insights infrastructure** -- analytics were computed client-side from raw sets with no timezone awareness, no body weight normalization, no subjective session feedback, and no reproducible analysis scopes.

The gym-tracker project demonstrated several patterns worth adopting: timezone-aware training date bucketing, dual muscle representation, recommendation scopes for reproducible AI analysis, and structured workout feedback.

## Validation Process

Three specialist agents reviewed every proposed change before implementation:

- **Fitness domain expert** (Opus) -- validated exercise science decisions against NSCA/ACSM guidelines and peer-reviewed literature
- **Data science expert** (Opus) -- validated analytics value, statistical methods, cold-start behavior, and data quality concerns
- **Database specialist** (Sonnet) -- reviewed migration for correctness, RLS security, idempotency, FK cascades, and naming conventions

This process **rejected 3 proposals** that would have added complexity without value:
- Difficulty score (1-5) -- redundant with existing `level` column
- Muscle profile JSONB -- redundant with normalized `exercise_muscles` junction table
- `rest_seconds` column on sets -- derivable from consecutive `logged_at` timestamps

## What Changed

### Migration 019: Schema Enrichment

#### Exercises table (+3 columns)

| Column | Type | Purpose |
|--------|------|---------|
| `laterality` | `bilateral / unilateral / both` | Enables side-to-side imbalance detection. "both" means the exercise can be done either way (e.g., dumbbell curl). Named `both` instead of `either` per fitness expert recommendation for clarity. |
| `aliases` | `text[]` | Alternate names for search and deduplication. GIN-indexed for containment queries. Example: "Barbell Bench Press - Medium Grip" has aliases `['Flat Bench Press', 'Bench Press', 'BB Bench']`. |
| `exercise_type` | `push / pull / legs / core / cardio / full_body` | Training-split classification for push/pull volume balance analytics. Complements the biomechanical `movement_pattern` column (added in migration 015). The fitness expert initially rejected this as redundant with `movement_pattern`, but the data science expert demonstrated that push/pull balance ratios -- a key metric for shoulder health -- cannot be derived from `movement_pattern` alone for ~30% of exercises (isolations, carries, compound movements like deadlifts). |

**Why both `movement_pattern` and `exercise_type`?** They serve different analytical purposes. `movement_pattern` is biomechanical (squat, hip_hinge, horizontal_push) and drives exercise substitution logic. `exercise_type` is a training-split classification (push, pull, legs) and drives volume balance analytics. A deadlift is `hip_hinge` (movement_pattern) but `pull` (exercise_type). A bicep curl is `isolation` (movement_pattern) but `pull` (exercise_type). Neither column can replace the other.

#### Sets table (+5 columns)

| Column | Type | Purpose |
|--------|------|---------|
| `duration_seconds` | `integer, nullable` | Time-under-tension for hypertrophy tracking and isometric holds (planks, wall sits) where reps are meaningless. Only populated when the user explicitly tracks it. |
| `distance_meters` | `numeric, nullable` | Progress tracking for cardio exercises (rower, ski erg, sled push, loaded carries). Without this, these exercises have no meaningful progression metric. |
| `distance_unit` | `m / km / mi / yd` | User preference for distance display. Co-constrained with `distance_meters` (both null or both set). |
| `training_date` | `date` | Timezone-aware date bucketing. Computed via trigger from `logged_at` + user's timezone + `day_start_hour`. A set logged at 2 AM local time counts as "yesterday" when `day_start_hour` is 4 AM. This fixes systematic errors in 7+ analytics functions (weekly volume, training streak, calendar heatmap, deload detection). |
| `side` | `left / right, nullable` | Unilateral exercise tracking. When combined with `laterality` on the exercise, enables left/right strength imbalance detection. |

**Why `training_date` matters:** Without timezone-aware bucketing, a Friday 9 PM workout in New York (UTC-5) gets recorded as Saturday UTC, potentially shifting into the next ISO week. This cascades into wrong weekly volume comparisons, broken training streaks, and false deload recommendations. The 4 AM boundary convention is used by Whoop, STRONG, and gym-tracker.

#### Profiles table (+3 columns)

| Column | Type | Purpose |
|--------|------|---------|
| `timezone` | `text, default 'UTC'` | IANA timezone identifier (e.g., `America/New_York`). Used by the `compute_training_date()` trigger. |
| `day_start_hour` | `smallint, default 4` | Hour boundary for training date bucketing. Sets logged before this hour count as the previous day. |
| `height_cm` | `numeric, nullable` | Required for BMI and Fat-Free Mass Index (FFMI) calculations when combined with body weight data. |

### New Tables

#### body_weight_log

Tracks user body weight over time. Enables:
- **Bodyweight multiples** (e.g., "you squat 1.5x bodyweight") -- the most intuitive strength metric for experienced lifters
- **DOTS score** -- the IPF-adopted normalization for cross-bodyweight comparison (preferred over Wilks since 2019)
- **Weight trend** -- useful for bulk/cut cycle tracking
- **FFMI** -- with `height_cm` from profiles and `body_fat_pct`, calculates Fat-Free Mass Index (natural ceiling ~25, per Kouri et al. 1995)

Columns: `id`, `user_id`, `weight`, `weight_unit`, `body_fat_pct` (optional), `source` (manual/smart_scale/import), `notes`, `logged_at`, `updated_at`.

For analytics, the most recent measurement at or before the training date is used (step function, no interpolation). Linear interpolation may be added later for visualization only.

#### workout_feedback

Post-session subjective data that correlates with performance. Field names follow sports science conventions:

| Field | Scale | What it measures |
|-------|-------|------------------|
| `session_rpe` | 1-10 | Session RPE (Foster et al., 2001). Distinct from set-level RPE on the `sets` table. sRPE x session duration = session load. |
| `readiness_score` | 1-5 | Pre-session readiness (proxy for HRV-based readiness). "How ready did you feel going into the session?" |
| `prior_sleep_quality` | 1-5 | Sleep quality the night before. Named `prior_sleep_quality` to make the temporal relationship clear. |
| `sleep_hours` | 0-24 | Objective companion to sleep quality. Stronger predictor of performance than quality alone (Knowles et al. 2018). |
| `stress_level` | 1-5 | Meaningful recovery confounder (Stults-Kolehmainen & Sims 2013). Replaces the initially proposed `satisfaction` which had no established correlation with physiological outcomes. |

**Analytics unlock:** Spearman rank correlation (not Pearson) between subjective metrics and performance (E1RM, volume). Valid at n >= 10. Divergence between session RPE and actual volume is a fatigue signal for deload detection. With 10+ data points, the AI can say "your E1RM drops ~X% after poor sleep nights."

Keyed by `(user_id, training_date)` -- one feedback record per training day.

#### exercise_substitutions

Directional exercise alternatives with typed relationships:

| Type | Meaning | Example |
|------|---------|---------|
| `same_pattern` | Same movement, different equipment | Barbell Bench Press <-> Dumbbell Bench Press |
| `same_muscles` | Same primary muscles, different pattern | Lat Pulldown <-> Seated Row |
| `regression` | Easier variant | Pull-Up -> Band-Assisted Pull-Up |
| `progression` | Harder variant | Goblet Squat -> Front Squat -> Barbell Back Squat |

Each pair has a `similarity_score` (1-100): 90+ = nearly identical stimulus, 70-89 = very similar, 50-69 = moderately similar, 30-49 = loosely related.

Relationships are **directional** because substitutability is not always symmetric. A barbell bench press can be substituted with dumbbells (same pattern, less load), but someone who specifically chose dumbbells for stability work may not want to switch to barbell.

FK cascade is `ON DELETE RESTRICT` (matching the pattern from migration 018 for plan_items and exercise_favorites) to prevent silent data loss if a seed exercise is accidentally deleted.

Seeded with 212 substitution pairs across 125 exercises.

#### recommendation_scopes

Stores analysis parameters so AI insights are reproducible and comparable:

- `grouping`: how to aggregate sets (`training_day`, `session`, `week`, `cluster`)
- `date_start` / `date_end`: analysis window
- `included_set_types`: which set types to analyze (default: `{working}`)
- `comparison_scope_id`: self-referencing FK for "compare this scope against that scope"
- `metadata`: JSONB escape hatch for additional filters

Linked to `analysis_reports` via `recommendation_scope_id` FK. Enables "re-run this analysis" and "compare two time periods" workflows.

### New View: exercise_usage_stats

Regular view (not materialized) computing set counts per exercise over 7d/30d/90d/all-time windows. Uses `SECURITY INVOKER` (PostgreSQL 15+) to enforce RLS policies from the underlying `sets` table -- prevents cross-user data leakage.

### New Trigger: compute_training_date()

Fires on `INSERT` and `UPDATE OF logged_at` on the `sets` table. Reads the user's `timezone` and `day_start_hour` from `profiles` and computes:

```
training_date = (logged_at AT TIME ZONE timezone - day_start_hour hours)::date
```

Falls back to UTC/4AM if no profile exists. Existing sets are backfilled during migration.

### Migration 020: Seed Data Enrichment

Populates the new columns for the 873 seed exercises:

1. **exercise_type** (18 UPDATE groups) -- Manual classification for isolation and `other` movement_pattern exercises that couldn't be auto-derived. Covers chest isolation (flyes), triceps isolation (pushdowns, skullcrushers), shoulder isolation (lateral raises), biceps isolation (curls), core isolation (crunches, planks), full_body (Olympic lifts), and cardio.

2. **laterality** (8 UPDATE groups) -- 120+ bilateral, 50+ unilateral, 25+ both. Pattern-based rules for remaining (e.g., "One-Arm" in name -> unilateral, "Barbell" -> bilateral).

3. **aliases** (49 UPDATE statements) -- Common alternate names for the most-used exercises.

4. **activation_percent** (143 UPDATE statements across 45 exercises) -- Evidence-based EMG activation tiers for compound exercises: 90 = primary mover, 60 = strong synergist, 30 = stabilizer. Each exercise section cites the source study (Schoenfeld, Contreras, Escamilla, Ebben, Lehman, etc.).

### Analytics Improvement: Weighted Volume by Muscle

The `volumeByMuscle()` function in `frontend/src/utils/analytics.ts` was updated to use activation percentages instead of even-splitting:

**Before:** A bench press set with 3 target muscles (chest, front delts, triceps) allocated 33%/33%/33% of volume to each -- directionally wrong.

**After:** With activation data (chest: 90%, front delts: 60%, triceps: 30%), volume is distributed proportionally: 50%/33%/17%. Falls back to even-split when activation data is unavailable (backward compatible).

This is the single largest accuracy improvement for the muscle volume heatmap and distribution charts.

## Database Specialist Review Findings

The migration was reviewed and these issues were fixed:

| Severity | Issue | Fix |
|----------|-------|-----|
| HIGH | `exercise_usage_stats` view lacked `SECURITY INVOKER`, leaking all users' data | Added `WITH (security_invoker = true)` |
| HIGH | 6 `CREATE INDEX` statements without `IF NOT EXISTS` | Added `IF NOT EXISTS` to all |
| HIGH | `CREATE TRIGGER` without idempotency guard | Added `DROP TRIGGER IF EXISTS` before create |
| MEDIUM | `distance_meters` and `distance_unit` not co-constrained | Added CHECK constraint requiring both or neither |
| MEDIUM | `exercise_substitutions` FK CASCADE could silently delete data | Changed to `ON DELETE RESTRICT` |
| MEDIUM | `body_weight_log` missing `updated_at` + trigger | Added column and trigger |
| MEDIUM | `workout_feedback` missing `updated_at` + trigger | Added column and trigger |

## Files

| File | Status | Lines |
|------|--------|-------|
| `supabase/migrations/019_schema_enrichment.sql` | New | ~360 |
| `supabase/migrations/020_seed_enrichment.sql` | New | 1,974 |
| `supabase/seed/004_exercise_substitutions.sql` | New | 1,913 |
| `frontend/src/types/database.ts` | Modified | +85 |
| `frontend/src/utils/analytics.ts` | Modified | +30 |
| `frontend/src/utils/analytics.test.ts` | Modified | +20 |
| `frontend/src/hooks/useAnalytics.ts` | Modified | +5 |
