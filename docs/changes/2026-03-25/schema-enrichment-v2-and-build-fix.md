# Schema Enrichment V2 & Build Fix

**Date:** 2026-03-25
**Scope:** Database schema, frontend types, build fix

## Summary

This session addressed three areas: fixing the Netlify build failure, enriching the database schema with user exercise preferences and workload balance scoring, and adding corresponding frontend TypeScript types.

## Changes

### 1. Netlify Build Fix

**File:** `frontend/src/hooks/useProfile.ts`

The build failed because the `Profile` TypeScript type included `current_body_weight_kg` (added in a recent migration) but the `DEFAULT_PROFILE` constant was missing this property. Added `current_body_weight_kg: null` to the default.

### 2. Migration 027: Schema Enrichment V2

**File:** `supabase/migrations/027_schema_enrichment_v2.sql`

#### Domain Expert Review

Before designing the migration, the fitness domain expert agent reviewed all 7 proposed enrichments against the existing schema and NSCA/ACSM evidence:

| Enrichment | Verdict | Rationale |
|---|---|---|
| Muscle activation percentages | Already exists (mig 015) | `activation_percent` smallint 0-100 on `exercise_muscles` |
| Exercise ratings & favorites | Already exists (mig 014, 023) | `exercise_favorites` + `equipment_variants.rating` |
| Default weight/reps | Already exists (mig 015) | `default_weight`, `default_reps` on `exercises` |
| Rest seconds per set | Already exists (mig 021) | `rest_seconds` integer on `sets` |
| Workout cluster ID | Already exists (mig 021) | `workout_cluster_id` uuid + `recompute_workout_clusters()` |
| Movement variations | Already exists (mig 015, 019) | `variations text[]` + `exercise_substitutions` table |
| Shannon entropy balance | Modify approach | Use alongside existing views, not as replacement |

The expert noted that Shannon entropy is mathematically sound but uniform distribution is NOT the training goal — recommended pairing it with the existing `training_volume_targets` (MEV/MAV/MRV) and push:pull ratios (Kolber et al., 2009) for actionable insights.

#### New Schema Objects

**`user_exercise_preferences` table** — Consolidates per-user exercise preferences into a single table:
- `rating` (1-5): User rating of exercise effectiveness
- `is_favorite`: Quick-access flag
- `default_weight`, `default_reps`, `default_rest_seconds`: Per-user defaults
- `notes`: Personal notes
- Migrates existing `exercise_favorites` data
- Full RLS, partial indexes on favorites and ratings

**`muscle_activation_weights` view** — Single source of truth for activation-weighted volume:
- Provides `effective_activation_pct` with fallback defaults (primary=100, secondary=50)
- `volume_weight_factor` (0.0-1.0) for weighted volume calculations
- Stabilizers and <30% activation get 0.0 per Renaissance Periodization convention

**Updated `weekly_muscle_volume` view** — Now uses actual `activation_percent` values instead of binary 1.0/0.5/0.0 weights. Exercises with EMG-sourced activation data contribute proportionally.

**`workload_balance_scores` table** — Pre-computed balance metrics:
- Shannon entropy + normalized entropy (0.0-1.0) for muscle distribution diversity
- Push/pull ratio (target: 0.67-1.0 per Kolber et al., 2009)
- Horizontal push:pull ratio (shoulder impingement risk indicator)
- Upper/lower ratio
- Dominant muscle group identification
- JSONB distribution breakdown for drill-down
- Full RLS, computed by backend cron via `compute_workload_balance()` function

**`compute_workload_balance()` function** — Service-role-only function that computes and upserts balance scores. Uses same activation-weighted logic as the updated views.

### 3. Frontend TypeScript Types

**File:** `frontend/src/types/database.ts`

Added corresponding TypeScript interfaces:
- `UserExercisePreference` — maps to `user_exercise_preferences`
- `BalancePeriodType` — `'week' | 'month'` union
- `WorkloadBalanceScore` — maps to `workload_balance_scores`
- `MuscleActivationWeight` — maps to `muscle_activation_weights` view

## Agents Used

| Agent | Role |
|---|---|
| Fitness Domain Expert (opus) | Reviewed all 7 enrichment proposals against NSCA/ACSM evidence |
| Database Specialist (sonnet) | Designed migration 027 following existing patterns |
| Frontend Specialist | Updated TypeScript types |

## Key Domain Expert Citations

- **Muscle activation EMG**: Lauver et al. (2016, JSCR); Schoenfeld et al. (2022, IJSS)
- **Rest periods**: Ratamess et al. (2009, NSCA); Schoenfeld et al. (2016) — 3 min superior for both strength and hypertrophy
- **Push:pull balance**: Kolber et al. (2009) — target ratio 0.67-1.0 for shoulder health
- **Shannon entropy**: Stergiou & Decker (2011, Human Movement Science) — movement variability analysis
- **Volume landmarks**: RP framework (MV/MEV/MAV/MRV) for per-muscle target ranges

## Next Steps

- Populate `activation_percent` for top 50 most-used exercises using EMG literature
- Build frontend components to display workload balance scores
- Add backend cron job to call `compute_workload_balance()` periodically
- Consider building a "% muscles within target volume range" metric using existing `training_volume_targets` table
