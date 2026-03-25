# Training Context & Progression Enrichment

**Migrations:** 027_training_context_enrichment.sql, 028_training_context_seed.sql
**Date:** 2026-03-25
**Validated by:** fitness-domain-expert (opus), database-specialist (sonnet)
**Inspired by:** [gym-tracker](https://github.com/mmm00007/gym-tracker) progression logic and adherence patterns

## Summary

Added muscle group hierarchy for rollup volume analysis, configurable progression rules that move hardcoded logic into the database, a structured injury/pain diary for safety-aware recommendations, and two insight views for training consistency and e1RM progress charting.

## What Changed

### Migration 027: Schema

| Change | Table/View | Description |
|--------|------------|-------------|
| New table | `muscle_group_categories` | 7 functional categories (upper_push, upper_pull, lower_push, lower_pull, core, calves, neck) |
| New table | `muscle_group_category_members` | Many-to-many mapping of 16 muscle groups into categories |
| New table | `progression_rules` | Configurable load progression per exercise/goal. Population defaults + user overrides. Includes stall_strategy |
| New table | `injury_reports` | Structured pain tracking with NRS 0-10 scale, body area, onset type, mechanism, and training limitation flag |
| New index | `sets(user_id, exercise_id, training_date)` | Supports e1RM bucketing and exercise performance queries |
| New view | `training_consistency_metrics` | Per-user: current streak (weeks), rolling frequency, regularity CV (coefficient of variation) |
| New view | `e1rm_progress_bucketed` | Per-exercise weekly best estimated 1RM with context (reps, RPE, working set count) |

### Migration 028: Seed Data

| Change | Description |
|--------|-------------|
| Seed muscle group categories | 7 categories, 16 muscle-to-category mappings |
| Seed progression rules (population) | 6 goal-level defaults (strength/hypertrophy/endurance/power/general/body_recomposition) |
| Seed progression rules (exercise) | OHP-specific slower increment (1.25kg), isolation exercise overrides (1.25kg, higher rep range) |

## Design Decisions

### Muscle Group Hierarchy

**Push/pull taxonomy for legs:** Lower body uses `lower_push` (knee extension = quadriceps) and `lower_pull` (hip extension = glutes, hamstrings, adductors). This mirrors the upper body push/pull dichotomy and is a common convention in periodization literature (Boyle, 2016).

**Adductors in lower_pull:** The domain expert corrected the initial placement of adductors in `lower_push`. Hip adductors are functionally closer to glutes/hamstrings than quadriceps (Escamilla et al., 2009). They participate in hip extension and adduction, not knee extension.

**Shoulders compromise:** The deltoid has three functionally distinct heads (anterior=pusher, lateral=abductor, posterior=puller). Since the database has a single "shoulders" muscle group (wger convention), and the most common shoulder-loading exercises are push movements (bench press, overhead press), shoulders are placed in `upper_push`. This is documented as a known compromise.

### Progression Rules

**Population defaults + user overrides:** Same pattern as strength_standards — NULL user_id rows serve as evidence-based defaults. Users can override per exercise. This avoids hardcoding progression logic in Python/TypeScript while keeping sensible defaults.

**Stall strategy:** The domain expert emphasized this as critical for user retention. When a user fails to progress, the system needs a defined response. Options: `deload_and_retry` (Starting Strength reset), `reduce_weight` (drop 10%), `increase_reps` (switch to rep progression), `switch_variation` (suggest substitution via exercise_substitutions). Default varies by goal.

**Exercise-specific overrides:** OHP gets 1.25kg increments (slower progression per Rippetoe). Isolation exercises get 1.25kg with higher rep ranges. These match real-world gym constraints (smallest plates available are usually 1.25kg/2.5lb).

### Injury Reports

**Separate from soreness:** DOMS (delayed onset muscle soreness, 0-4 scale) is a normal training response tracked in `soreness_reports`. Pain/injury is pathological, uses the clinical NRS 0-10 scale (Hawker et al., 2011), and requires structured metadata (location type, onset mechanism, training limitation).

**`limits_training` flag:** The key field for the recommendation engine. When true, cross-reference `exercises.contraindications` and `exercise_substitutions` to suggest safe alternatives.

**`resolved_at` co-constraint:** `resolved_at` must be set when status='resolved' and NULL otherwise. Prevents inconsistent state.

### Training Consistency View

**Streak = consecutive weeks meeting frequency target:** NOT consecutive calendar days. Training every day without rest promotes overtraining (Fry & Kraemer, 1997). A user with 4x/week target who trains M/Tu/Th/F has a perfect streak despite rest days. Tolerance of -1 day applied (3/4 still counts) per adherence research (Steele et al., 2017).

**Regularity CV:** Coefficient of variation of inter-session gaps. CV < 0.3 = regular training. Better than simple frequency because it captures consistency of spacing (training MWF every week = low CV; 3x one week + 6x next = high CV despite same average).

### What Was Rejected

**Workload balance index (Shannon entropy):** The domain expert rejected this. Shannon entropy assumes all muscle groups are equally important, which is incorrect (quadriceps ≠ forearms). The existing `movement_pattern_balance` view with push:pull and knee:hip ratios is clinically validated (Kolber et al., 2009) and more actionable.

**Exercise variation catalog:** Redundant with existing `exercise_substitutions` table (which carries similarity_score and substitution_type) and the 873 exercises that already encode variations as separate entries.

## Evidence Base

| Citation | Used for |
|----------|----------|
| Boyle (2016), New Functional Training for Sports | Push/pull taxonomy for lower body |
| Escamilla et al. (2009) | Adductor activation during squats (lower_pull placement) |
| Rippetoe, Starting Strength (3rd ed.) | Linear progression model, OHP slower increment |
| Helms et al., Muscle & Strength Pyramids | Double progression for hypertrophy |
| Tuchscherer/RTS | RPE-based autoregulation model |
| Wendler 5/3/1 | Wave loading progression model |
| Hawker et al. (2011), Arthritis Care & Research | NRS 0-10 pain scale validation |
| Cook & Purdam (2009), BJSM | Tendinopathy model (tissue-specific implications) |
| Fry & Kraemer (1997), Sports Medicine | Overtraining from daily training without rest |
| Steele et al. (2017), PeerJ | Near-perfect adherence ≈ perfect adherence |
| Foster et al. (2001), JSCR | 4-week chronic window for training load monitoring |

## Files Modified

- `supabase/migrations/027_training_context_enrichment.sql` (new)
- `supabase/migrations/028_training_context_seed.sql` (new)

## Schema Impact

**New tables:** `muscle_group_categories`, `muscle_group_category_members`, `progression_rules`, `injury_reports`
**New views:** `training_consistency_metrics`, `e1rm_progress_bucketed`
**New indexes:** `sets(user_id, exercise_id, training_date DESC)`
**RLS:** All new tables have row-level security. Reference tables (categories) are public read. `progression_rules` SELECT allows user rows + population defaults (user_id IS NULL).
