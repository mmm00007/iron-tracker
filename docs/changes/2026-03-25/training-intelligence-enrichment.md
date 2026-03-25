# Training Intelligence Enrichment (Migrations 023-024)

**Date:** 2026-03-25
**Migrations:** `023_training_intelligence.sql`, `024_training_intelligence_seed.sql`
**Validated by:** fitness-domain-expert (Opus), database-specialist (Sonnet)
**Inspired by:** [gym-tracker](https://github.com/mmm00007/gym-tracker) user_preferences, adherence.js, equipment_set_counts

## Summary

Two migrations adding 5 new tables, 1 new view, 12 new columns, and reference/progression seed data. Focus areas: lifestyle context (sleep/workout windows), equipment preferences, plan adherence tracking, percentage-based weight prescriptions, muscle antagonist pairs, per-exercise user notes, training milestones, and exercise progression chains.

## Changes

### A. Profiles: Sleep & Workout Windows

| Change | Type | Details |
|--------|------|---------|
| `profiles.sleep_window_start` | New column | TIME, nullable. Typical bedtime. |
| `profiles.sleep_window_end` | New column | TIME, nullable. Typical wake time. |
| `profiles.workout_window_start` | New column | TIME, nullable. Preferred workout start. |
| `profiles.workout_window_end` | New column | TIME, nullable. Preferred workout end. |

**Design decisions:**
- Sleep windows support overnight semantics (22:30 -> 06:30). No ordering constraint needed for sleep (start can be > end when crossing midnight).
- Workout windows enforce ordering (start < end) via CHECK constraint since workouts don't cross midnight.
- These capture *habitual* patterns for deviation detection, complementing per-session actual data in `workout_feedback`.
- Source: Knowles et al. (2018) on sleep-strength interaction; Chtourou & Souissi (2012) on time-of-day effects.

### B. Equipment Variants: Rating

| Change | Type | Details |
|--------|------|---------|
| `equipment_variants.rating` | New column | SMALLINT 1-5. User preference rating. |

Defined as "overall preference" (1=avoid, 5=favorite). Used for sorting and recommendations, NOT for effectiveness or progressive overload inference. Index covers `(user_id, exercise_id, rating DESC)` for "best-rated variant for this exercise" queries.

### C. Plan Adherence Log (New Table)

| Table | Key Columns | RLS |
|-------|-------------|-----|
| `plan_adherence_log` | user_id, plan_id, plan_day_id, training_date, planned_sets, completed_sets, adherence_ratio (GENERATED), items_complete/partial/skipped, surplus_sets | user_id = auth.uid() |

**Design decisions:**
- `adherence_ratio` is a **generated column** (`GENERATED ALWAYS AS ... STORED`) computed from `completed_sets / planned_sets`. Eliminates data inconsistency between ratio and raw counts.
- Ratio caps at 1.0 (surplus sets tracked separately, not inflating the ratio).
- Auto-computed by backend (diff sets vs plan_items), not manually entered by users.
- Plan adherence is one of the strongest predictors of training outcomes (Steele et al., 2017; Hackett et al., 2018).

### D. Plan Items: Weight Range & Percentage

| Change | Type | Details |
|--------|------|---------|
| `plan_items.target_weight_min` | New column | NUMERIC. Minimum target weight (kg or lb). |
| `plan_items.target_weight_max` | New column | NUMERIC. Maximum target weight. |
| `plan_items.target_weight_pct` | New column | NUMERIC(4,1). Percentage of estimated 1RM (e.g., 75.0 = 75%). |

**Design decisions:**
- Three weight prescription methods coexist: absolute single value (existing `target_weight`), absolute range (min/max), and percentage-based (pct). Programs like 5/3/1 use percentages while user-written plans use absolutes.
- Co-constraint ensures `target_weight_min <= target_weight_max`.
- `target_weight_pct` requires a known e1RM for the exercise; frontend must handle the case where no e1RM exists.

### E. Muscle Antagonist Pairs (New Table)

| Table | Key Columns | RLS |
|-------|-------------|-----|
| `muscle_antagonist_pairs` | muscle_a_id, muscle_b_id (canonical ordering: a < b), pair_name, pair_strength | Public read (authenticated) |

**Seeded pairs (migration 024):**

| Pair | Strength | Clinical Relevance |
|------|----------|--------------------|
| biceps-triceps | Strong | Classic superset pairing (Robbins et al., 2010) |
| chest-lats | Strong | Push:pull ratio >1.5:1 = shoulder impingement risk (Kolber et al., 2009) |
| abs-lower_back | Strong | Core stability balance |
| hamstrings-quadriceps | Strong | H:Q ratio <0.6 associated with ACL injury risk (Hewett et al., 2005) |
| shoulders-traps | Moderate | Superset pairing for upper back/delts |
| glutes-quadriceps | Moderate | Lower body programming balance |

**Design decisions:**
- Canonical ordering (`muscle_a_id < muscle_b_id`) prevents duplicate inverse rows. One row per symmetric pair.
- `pair_strength` distinguishes anatomically strict antagonist pairs (strong) from programming-convenience pairings (moderate).

### F. User Exercise Notes (New Table)

| Table | Key Columns | RLS |
|-------|-------------|-----|
| `user_exercise_notes` | user_id, exercise_id (UNIQUE), form_cues, injury_notes, personal_best_context, preferred_grip, preferred_stance, preferred_rep_range | user_id = auth.uid() |

**Design decisions:**
- `form_cues` and `injury_notes` kept as separate fields (not merged into single notes) because injury warnings need to surface before exercise begins (distinct UX action from showing form cues during exercise).
- `preferred_rep_range` added per domain expert recommendation: experienced lifters know which rep ranges work best for each exercise on their body.
- `ON DELETE CASCADE` on exercise_id (consistent with schema convention for user data).

### G. Training Milestones (New Table)

| Table | Key Columns | RLS |
|-------|-------------|-----|
| `training_milestones` | user_id, milestone_type (text), exercise_id (nullable), value, unit, achieved_at, body_weight_at | user_id = auth.uid() |

**Design decisions:**
- `milestone_type` is unconstrained text (not enum CHECK) for extensibility. New milestone types can be added without DDL changes.
- **Partial unique indexes** handle nullable `exercise_id` correctly (PostgreSQL quirk: `NULL != NULL` in UNIQUE constraints). Two indexes: one for global milestones (`WHERE exercise_id IS NULL`), one for exercise-specific (`WHERE exercise_id IS NOT NULL`).
- `body_weight_at` records body weight at time of achievement. BW milestones are locked to this value and never re-evaluated when body weight changes.
- BW multiples are the standard metric for strength milestones in the lifting community (ExRx, Kilgore, Symmetric Strength).

### H. Exercise Progressions (Extended exercise_substitutions)

| Change | Type | Details |
|--------|------|---------|
| `exercise_substitutions.progression_order` | New column | SMALLINT. Sequence within a progression chain. |
| `exercise_substitutions.prerequisite_1rm_ratio` | New column | NUMERIC(3,2). BW multiple e1RM required before progressing. |

**Design decisions:**
- Merged into existing `exercise_substitutions` table per domain expert recommendation. Avoids table duplication — all exercise relationships in one place.
- `progression_order` only set for `substitution_type IN ('progression', 'regression')`.
- Progressions form a DAG (directed acyclic graph), not strict linear chains. Multiple exercises can share the same `progression_order` from a single source.

**Seeded progressions (migration 024):** Push-up chain, squat progression, pull-up chain, deadlift progression, bench progression, dip progression.

### I. Equipment Usage Stats View

New `equipment_usage_stats` view with `security_invoker = true`. Per equipment variant:
- `sets_30d`, `sets_90d`, `sets_all_time`
- `last_used_at`
- `rank_30d`, `rank_90d` (RANK window functions via subquery)

**Design decisions:**
- RANK() wrapped in subquery per database-specialist recommendation (window functions over aggregates require outer query in PostgreSQL).
- Only includes sets with `variant_id IS NOT NULL` (excludes variant-less logging).

## Schema Summary (Post-Migration 024)

| Metric | Before (022) | After (024) | Delta |
|--------|--------------|-------------|-------|
| Tables | 27 | 32 | +5 |
| Views | 3 | 4 | +1 |
| Columns on profiles | 13 | 17 | +4 |
| Columns on plan_items | 13 | 16 | +3 |
| Columns on equipment_variants | 15 | 16 | +1 |
| Columns on exercise_substitutions | 6 | 8 | +2 |

## New Tables Created

1. **plan_adherence_log** — Auto-computed daily plan adherence with generated ratio column
2. **muscle_antagonist_pairs** — Reference data for superset recommendations and balance analytics
3. **user_exercise_notes** — Per-exercise personal form cues, injury notes, and preferences
4. **training_milestones** — Permanent achievements with body weight context
5. (exercise_substitutions extended, not a new table)

## New Indexes

| Index | Table | Columns | Type |
|-------|-------|---------|------|
| `equipment_variants_rating_idx` | equipment_variants | (user_id, exercise_id, rating DESC) | Partial |
| `plan_adherence_user_date_idx` | plan_adherence_log | (user_id, training_date DESC) | B-tree |
| `plan_adherence_plan_date_idx` | plan_adherence_log | (user_id, plan_id, training_date DESC) | B-tree |
| `muscle_antagonist_b_idx` | muscle_antagonist_pairs | (muscle_b_id) | B-tree |
| `training_milestones_global_idx` | training_milestones | (user_id, milestone_type) | Partial unique (exercise_id IS NULL) |
| `training_milestones_exercise_idx` | training_milestones | (user_id, milestone_type, exercise_id) | Partial unique (exercise_id IS NOT NULL) |
| `training_milestones_user_date_idx` | training_milestones | (user_id, achieved_at DESC) | B-tree |
| `exercise_subs_progression_idx` | exercise_substitutions | (source_exercise_id, progression_order) | Partial |

## Backwards Compatibility

All changes are backwards-compatible:
- New columns are nullable or have defaults
- New tables have no required application-side changes
- View is additive
- Generated column on plan_adherence_log is transparent to INSERT/UPDATE callers

## Next Steps

- Backend: Implement plan adherence computation service (diff sets vs plan_items nightly)
- Backend: Milestone detection service (check BW multiples after each set insert)
- Frontend: Sleep/workout window settings in profile editor
- Frontend: Equipment rating stars on variant detail screen
- Frontend: User exercise notes editor (form cues, injury flags, grip/stance)
- Frontend: Milestone timeline/achievement screen
- Frontend: Antagonist pair superset suggestions in plan builder
- Frontend: Percentage-based weight prescription in plan item editor
