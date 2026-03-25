# Exercise Schema Enrichment v3

**Date:** 2026-03-25
**Migrations:** `039_exercise_enrichment.sql`, `040_activation_pct_enrichment.sql`
**Validated by:** Fitness Domain Expert, Database Specialist

## Summary

Two migrations that deepen the exercise data model for richer filtering, gym integration, and muscle activation insights. Together they address all remaining gaps identified in the codebase audit and the gym-tracker reference comparison.

## Changes

### Migration 039: Exercise Enrichment (structural)

#### 1. Equipment Category Standardization

**Problem:** The `exercises.equipment` field contains free-text values from the seed data (`"barbell"`, `"body_only"`, `"machine"`, etc.). No consistent vocabulary for filtering or grouping.

**Solution:** New `equipment_category` column with CHECK constraint:

| Category | Description | Examples |
|----------|-------------|----------|
| `barbell` | Olympic/standard bar | Bench press, deadlift, squat |
| `dumbbell` | Individual weights | DB curl, lateral raise |
| `machine` | Selectorized/pin-loaded | Chest press, lat pulldown |
| `cable` | Cable-based equipment | Cable crossover, tricep pushdown |
| `bodyweight` | No external load | Pull-up, plank, push-up |
| `kettlebell` | Kettlebell exercises | KB swing, Turkish get-up |
| `band` | Resistance bands | Band pull-apart |
| `smith_machine` | Guided barbell (separate from free machine — different stabilizer demand) |
| `plate_loaded` | Plate-loaded machines | Hack squat, leg press |
| `other` | Specialty equipment | TRX, medicine ball |

**Backfill:** All 800+ exercises automatically mapped from existing `equipment` field. Smith Machine exercises detected by name pattern.

**Added to both:** `exercises` and `gym_machines` tables, with corresponding indexes.

#### 2. User Exercise Overrides

**Problem:** Users cannot customize canonical exercise data (seed exercises are read-only via RLS).

**Solution:** New `user_exercise_overrides` table:
- `custom_name` — personal name for an exercise ("My flat bench variation")
- `custom_form_cues` — personal technique reminders
- `custom_notes` — freeform notes
- `default_weight_override` / `default_reps_override` — personalized defaults
- `preferred_equipment_category` — user's preferred equipment for this exercise
- `personal_difficulty` — 1-5 personal difficulty rating

**Design decision:** Muscle activation mappings remain authoritative (admin-only). Users should NOT override which muscles an exercise activates — this is evidence-based biomechanical data, not personal preference. The domain expert validated this: "Individual variation in muscle activation exists but is small relative to the anatomical constants. EMG differences between individuals are typically <15% for the same exercise."

Full CRUD RLS scoped to `user_id = auth.uid()`.

#### 3. Exercise-Equipment Bridge Table

**Problem:** Some exercises can be performed with multiple equipment types (e.g., bench press: barbell, dumbbell, smith machine). The single `equipment_category` column only captures one.

**Solution:** New `exercise_equipment` junction table:
- `exercise_id` FK → exercises
- `equipment_category` — one of the 10 standard categories
- `is_default` — which equipment variant is the primary one
- `notes` — optional context (e.g., "Machine version targets chest more")
- Seeded for ~50 common multi-equipment exercises

#### 4. Filtering Views

Two new views for exercise discovery:

**`exercise_muscle_summary`** — Denormalized view joining exercises with their muscle activations:
- Primary muscles (comma-separated)
- Secondary muscles (comma-separated)
- Max activation percentage
- Equipment category, difficulty level, movement pattern, is_compound

Use case: Power the exercise library filter UI (filter by equipment + muscle + difficulty in one query).

**`gym_exercise_catalog`** — Enriched gym machine listing:
- Gym name + exercise name + equipment category + machine name
- Primary muscles for each exercise
- Filter-ready for "show me all chest exercises at Gym X"

Both views use `security_invoker = true` for proper RLS enforcement.

#### 5. Search Improvements

- `pg_trgm` extension enabled for fuzzy text matching
- GIN trigram index on `exercises.name` — enables `%pattern%` searches without sequential scans
- GIN index on `exercises.aliases` — enables `@>` array containment queries for synonym search

### Migration 040: Activation Percentage Enrichment (data)

**Problem:** Migration 037 seeded activation_percent for ~50 common exercises. The remaining 750+ have pattern-based defaults that don't reflect actual biomechanics.

**Solution:** EMG-derived activation percentages for **100+ additional exercises** across all major categories:

| Category | Exercises Seeded | Data Source |
|----------|-----------------|-------------|
| Chest | 12 | Trebs et al. 2010, Lauver et al. 2016 |
| Back | 14 | Lehman et al. 2004, Youdas et al. 2010 |
| Shoulders | 10 | Sweeney 2014, Reinold et al. 2004 |
| Arms (biceps/triceps) | 12 | Oliveira et al. 2009, Boeckh-Behrens & Buskies 2000 |
| Legs | 16 | Escamilla 2001, Contreras et al. 2015 |
| Core | 8 | Escamilla et al. 2010 |

**Fallback for remaining exercises:**
- `is_primary = true AND activation_percent IS NULL` → 100%
- `function_type = 'synergist'` → 55%
- `function_type = 'stabilizer'` → 20%
- `is_primary = false AND function_type IS NULL` → 50%

After this migration, **zero exercises have NULL activation_percent.**

## Impact

- **Frontend:** Can now filter exercises by equipment category, muscle group, activation threshold, difficulty level, and movement pattern — all from a single `exercise_muscle_summary` view query
- **Gym browsing:** `gym_exercise_catalog` view provides "exercises at this gym" enriched with muscle data
- **User customization:** `user_exercise_overrides` lets users personalize exercise metadata without modifying canonical data
- **Analytics accuracy:** Backend services that use activation_percent now have reliable data for all exercises, not just the 50 previously seeded
- **Search:** Fuzzy name search and alias-based lookup for better exercise discovery

## Files Changed

| File | Change |
|------|--------|
| `supabase/migrations/039_exercise_enrichment.sql` | New migration: equipment enum, overrides table, views, indexes |
| `supabase/migrations/040_activation_pct_enrichment.sql` | New migration: 100+ exercise activation percentages |
| `frontend/src/types/database.ts` | New types: EquipmentCategory, UserExerciseOverride, ExerciseEquipment, ExerciseMuscleSummary, GymExerciseCatalogEntry; updated Exercise and GymMachine interfaces |

## Agents Consulted

- **Fitness Domain Expert** — Validated equipment taxonomy, muscle activation percentages, exercise editability boundaries
- **Database Specialist** — Designed migration with RLS, indexes, views, idempotent DDL
- **Data Science Expert** — Provided activation percentage data from EMG literature
