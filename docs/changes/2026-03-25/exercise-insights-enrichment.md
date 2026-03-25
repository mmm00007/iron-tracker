# Exercise Insights & Body Tracking Enrichment

**Migrations:** 025_exercise_insights_enrichment.sql, 026_exercise_insights_seed.sql
**Date:** 2026-03-25
**Validated by:** fitness-domain-expert (opus), database-specialist (sonnet)
**Inspired by:** [gym-tracker](https://github.com/mmm00007/gym-tracker) data model comparison

## Summary

Added default rest periods per exercise, a generated compound classification column, body circumference/skinfold tracking, population-level strength benchmarks as a reference table, and three insight-oriented views for exercise performance, weekly muscle volume, and movement pattern balance.

## What Changed

### Migration 025: Schema

| Change | Table | Description |
|--------|-------|-------------|
| New column | `exercises.default_rest_seconds` | Recommended rest between sets (NSCA-based: compounds ~120s, isolation ~60s, Olympic ~180s) |
| New generated column | `exercises.is_compound` | Boolean generated from `mechanic = 'compound'`. Fast query filter without data duplication |
| New column | `profiles.current_body_weight_kg` | Denormalized from latest `body_weight_log` entry. Auto-synced via trigger on INSERT |
| New table | `body_measurements` | Circumference and skinfold measurements per NSCA/ACSM protocols (10 circumference sites + 7 Jackson-Pollock skinfold sites) |
| New table | `strength_standards` | Population strength benchmarks with absolute 1RM values and bodyweight-relative ratios. Sources: NSCA, ExRx, Rippetoe/Kilgore, Hoffman |
| Enum extension | `recommendation_scopes.grouping` | Added `'mesocycle'` and `'custom'` values |
| New view | `exercise_performance_summary` | Per-exercise stats: best weight, best e1RM, last weight/reps, avg RPE, training frequency |
| New view | `weekly_muscle_volume` | Weekly sets per muscle group weighted by biomechanical role (agonist=1.0, synergist=0.5, stabilizer=0.0 per RP convention) |
| New view | `movement_pattern_balance` | Weekly push/pull ratios and knee/hip balance. Flags shoulder impingement risk when h_push:pull > 1.5:1 (Kolber et al., 2009) |

### Migration 026: Seed Data

| Change | Description |
|--------|-------------|
| Backfill `default_rest_seconds` | Pattern-based: Olympic lifts 180s, heavy compounds 120s, bodyweight exercises 60s, isolation 60s |
| Seed `strength_standards` | 16 exercises x 2 sexes = 32 entries. Male (80kg ref) and female (60kg ref) with NSCA/ExRx benchmarks |

## Design Decisions

### What was added

**default_rest_seconds:** Rest is a primary programming variable (Ratamess et al., 2009, NSCA). Placed on exercises because exercises have inherent rest demands based on muscle mass involvement. Plan-level override already exists via `plan_items.rest_target_seconds`.

**body_measurements:** Kept separate from `body_weight_log` because weight is logged daily while circumferences are weekly/monthly. Type/unit co-constraint ensures skinfolds use mm and circumferences use cm/in. Side tracking (left/right) supports bilateral comparison.

**strength_standards:** Moved from hardcoded Python dicts in `strength_standards_service.py` to a database table. Enables: client-side access via Supabase RLS, easier updates, and auditable data. BW ratio columns allow more accurate classification when user bodyweight is known.

**Views:** All use `security_invoker = true` for RLS. None are materialized — the queries hit indexed data and are fast enough as regular views. Heavy pre-computation belongs in `analytics_cache`.

### What was rejected

**muscle_workload_coefficients:** The fitness domain expert rejected this. The proposed cross-muscle normalization coefficients (Chest 1.0, Biceps 0.55, etc.) have no peer-reviewed source. The RP framework explicitly states volume recommendations are muscle-specific and should not be compared across muscles. The correct approach is showing each muscle's volume as a percentage of its own MAV range — which `training_volume_targets` already enables.

### What already existed (skipped)

The following were proposed but found to already exist from prior migrations:

| Proposed | Existing (Migration) |
|----------|---------------------|
| `exercises.movement_pattern` | Migration 015 (identical enum) |
| `exercises.is_unilateral` | Migration 019 as `laterality` (3-value: bilateral/unilateral/both) |
| `exercises.default_weight` | Migration 015 |
| `exercises.default_reps` | Migration 015 |
| `sets.duration_seconds` | Migration 019 |
| `profiles.day_start_hour` | Migration 019 |
| `profiles.timezone` | Migration 019 |
| `recommendation_scopes` table | Migration 019 |

## Evidence Base

| Citation | Used for |
|----------|----------|
| Ratamess et al. (2009), NSCA Position Stand | Rest period recommendations per exercise type |
| Israetel et al. (2021), RP Scientific Principles | Weekly muscle volume counting: agonist=1.0, synergist=0.5, stabilizer=0 |
| Kolber et al. (2009) | Push:pull ratio >1.5:1 shoulder impingement risk threshold |
| NSCA Essentials, 4th ed., Table 18.7 | Male and female absolute 1RM standards |
| Rippetoe & Kilgore (2006) | BW-relative strength ratios |
| Hoffman (2006), Norms for Fitness | Female strength norms |
| ExRx.net strength standards | Additional exercise benchmarks |
| Jackson & Pollock (1978) | 3-site and 7-site skinfold measurement protocols |

## Files Modified

- `supabase/migrations/025_exercise_insights_enrichment.sql` (new)
- `supabase/migrations/026_exercise_insights_seed.sql` (new)

## Schema Impact

**New tables:** `body_measurements`, `strength_standards`
**New views:** `exercise_performance_summary`, `weekly_muscle_volume`, `movement_pattern_balance`
**Modified tables:** `exercises` (+2 columns), `profiles` (+1 column), `recommendation_scopes` (enum extended)
**New functions:** `sync_profile_body_weight()` (trigger)
**RLS:** All new tables have row-level security enabled. `strength_standards` is public read (reference data).
