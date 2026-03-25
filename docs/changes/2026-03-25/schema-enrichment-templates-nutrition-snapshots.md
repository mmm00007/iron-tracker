# Schema Enrichment: Templates, Nutrition, Snapshots, Streaks

**Date:** 2026-03-25
**Migrations:** 031-034
**Build Fix:** netlify.toml

## Summary

Four new migrations enrich the Iron Tracker data model with workout templates, nutrition tracking, exercise progress snapshots, and gamification streak milestones. The Netlify build was also fixed.

## Reference

Compared against [mmm00007/gym-tracker](https://github.com/mmm00007/gym-tracker) for inspiration on data model patterns including dual muscle representation, gap-based workout clustering, and structured AI evidence. After filtering out features that already existed in Iron Tracker's 30-migration schema, four genuine gaps were identified and validated by the fitness domain expert agent.

## Validation

All proposals were evaluated by the **fitness-domain-expert agent** against NSCA, ACSM, and ISSN standards. Two proposals were **rejected** (Plan Items `target_set_type` — conflates prescription with classification; Equipment Volume Ranking View — already exists as `equipment_usage_stats`).

## Changes

### Build Fix

**File**: `netlify.toml`

Changed build command from `npm ci && npm run build` to `npm ci --ignore-scripts && npm run build`. The `@swc/core` postinstall script was segfaulting on some build environments, causing `npm ci` to fail with exit code 2. Since SWC's WASM fallback (`@swc/wasm`) is already a devDependency, skipping native postinstall scripts is safe.

### Migration 031: Workout Templates

**Tables**:
- `workout_templates` — Saved workout structures for quick-start logging
- `workout_template_items` — Exercises within a template

**Domain Expert Modifications Applied**:
- Uses `target_reps_min` / `target_reps_max` (range) instead of single `target_reps`
- Added `variant_id` FK to equipment_variants
- Added `target_rir` alongside `target_rpe`

**Why**: Reduces logging friction for repeat workouts. 70-90% of sessions within a mesocycle follow the same structure.

### Migration 032: Nutrition Basics

**Table**: `nutrition_logs` — Daily nutrition summaries (not per-meal)

**Profile Extensions**: `calorie_target`, `protein_target_g`, `protein_target_g_per_kg`

**View**: `nutrition_training_correlation` — Joins nutrition with training day summaries

**Domain Expert Modifications Applied**:
- Added `fiber_g` per ISSN/ACSM guidelines
- Added `protein_target_g_per_kg` (Jager et al., 2017: 1.6-2.2 g/kg)
- Enforced `UNIQUE (user_id, logged_date)`

### Migration 033: Exercise Progress Snapshots + Equipment Stats 7d

**Table**: `exercise_progress_snapshots` — Pre-computed weekly/monthly progress summaries

**Function**: `compute_exercise_progress_snapshot(user_id, period_type, period_start)`

**View Update**: `equipment_usage_stats` extended with `sets_7d` and `rank_7d` columns

**Domain Expert Modifications Applied**:
- Added `best_e1rm_reps` — Epley degrades above 10-12 reps
- Uses `period_start` / `period_end` instead of single `snapshot_date`

### Migration 034: Streak Milestones

**Function**: `compute_streak_milestones(user_id)` — Writes to existing `training_milestones` table

**Thresholds** (evidence-based):
| Weeks | Significance |
|-------|-------------|
| 2 | First commitment signal (Lally et al., 2010) |
| 4 | Neural adaptations complete (Sale, 1988) |
| 8 | Hypertrophy first detectable (Schoenfeld et al., 2017) |
| 12 | ACSM "regular exerciser" threshold |
| 24 | Beginner-to-intermediate transition (Kubo et al., 2010) |
| 36 | Linear progression exhausted (Baker et al., 1994) |
| 52 | Full year consistent (Sperandei et al., 2016) |

## Rejected Proposals

| Proposal | Reason |
|----------|--------|
| Plan Items `target_set_type` | Conflates prescription with classification; existing multi-row plan_items handles this |
| Equipment Volume Ranking View | Already exists as `equipment_usage_stats`; extended with 7d window instead |
| Training Bucket ID on sets | Redundant with `(user_id, training_date)` index |
| Muscle Baseline Coefficients | Previously rejected by domain expert (migration 025) |

## TypeScript Types Added

- `WorkoutTemplate`, `WorkoutTemplateItem`, `TemplateSourceType`
- `NutritionLog`, `NutritionSource`, `NutritionTrainingCorrelation`
- `ExerciseProgressSnapshot`, `SnapshotPeriodType`
- Updated `Profile` with nutrition target fields
- Updated `EquipmentUsageStats` with `sets_7d` and `rank_7d`

## Files Modified

| File | Change |
|------|--------|
| `netlify.toml` | Fixed build command (`--ignore-scripts`) |
| `supabase/migrations/031_workout_templates.sql` | New |
| `supabase/migrations/032_nutrition_basics.sql` | New |
| `supabase/migrations/033_exercise_progress_snapshots.sql` | New |
| `supabase/migrations/034_streak_milestones.sql` | New |
| `frontend/src/types/database.ts` | New types + Profile extension + EquipmentUsageStats update |
| `frontend/src/hooks/useProfile.ts` | Default profile updated with nutrition target nulls |
