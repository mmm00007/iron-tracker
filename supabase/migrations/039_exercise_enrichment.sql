-- Migration 039: Exercise Enrichment
-- Adds equipment categorization, user exercise overrides, exercise filtering views,
-- fuzzy search indexes, and multi-equipment bridge table.
--
-- Validated by: database-specialist agent
--
-- Key design decisions:
--   - equipment_category uses CHECK constraint (not enum type) for easier future extension
--   - Backfill from existing free-text `equipment` field using deterministic CASE mapping
--   - user_exercise_overrides complements user_exercise_notes (form cues, injury flags)
--     and user_exercise_preferences (rating, favorites) with personalization overrides
--   - exercise_equipment junction table allows many-to-many exercise-equipment mapping
--   - pg_trgm extension for fuzzy name search (GIN trigram index)
--   - All views use security_invoker = true for RLS enforcement
--   - Smith Machine exercises detected from exercise name when equipment = 'machine'

BEGIN;

-- =============================================================================
-- 1. EQUIPMENT CATEGORY COLUMN ON EXERCISES
-- =============================================================================

-- Structured equipment categorization. The existing `equipment` column contains
-- free-text values from free-exercise-db ('barbell', 'dumbbell', 'machine',
-- 'cable', 'body_only', 'bands', 'kettlebell', 'other', NULL).
-- This new column provides a controlled vocabulary for filtering and analytics.

ALTER TABLE exercises
  ADD COLUMN IF NOT EXISTS equipment_category text;

-- Add CHECK constraint separately (idempotent via DO block)
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'exercises_equipment_category_check'
  ) THEN
    ALTER TABLE exercises ADD CONSTRAINT exercises_equipment_category_check CHECK (
      equipment_category IN (
        'barbell', 'dumbbell', 'machine', 'cable', 'bodyweight',
        'kettlebell', 'band', 'smith_machine', 'plate_loaded', 'other'
      )
    );
  END IF;
END $$;

COMMENT ON COLUMN exercises.equipment_category IS
  'Structured equipment category. Mapped from free-text equipment field. Used for filtering and gym-machine matching.';

-- Index for equipment_category filtering (e.g., "show me all dumbbell exercises")
CREATE INDEX IF NOT EXISTS exercises_equipment_category_idx
  ON exercises (equipment_category)
  WHERE equipment_category IS NOT NULL;


-- =============================================================================
-- 2. BACKFILL equipment_category FROM EXISTING equipment FIELD
-- =============================================================================

-- Mapping from free-exercise-db equipment values to structured categories:
--   'barbell'   → 'barbell'
--   'dumbbell'  → 'dumbbell'
--   'machine'   → 'machine' (with Smith Machine override from name)
--   'cable'     → 'cable'
--   'body_only' → 'bodyweight'
--   'bands'     → 'band'
--   'kettlebell' → 'kettlebell'
--   'other'     → 'other'
--   NULL        → NULL (preserve; custom exercises may not have equipment)

-- First pass: Smith Machine exercises (must run before generic 'machine' mapping)
-- Detected by name pattern since free-exercise-db stores 'machine' for Smith exercises.
UPDATE exercises
SET equipment_category = 'smith_machine'
WHERE equipment_category IS NULL
  AND lower(equipment) = 'machine'
  AND lower(name) LIKE '%smith%';

-- Second pass: all remaining exercises from the equipment field
UPDATE exercises
SET equipment_category = CASE lower(equipment)
  WHEN 'barbell'    THEN 'barbell'
  WHEN 'dumbbell'   THEN 'dumbbell'
  WHEN 'machine'    THEN 'machine'
  WHEN 'cable'      THEN 'cable'
  WHEN 'body_only'  THEN 'bodyweight'
  WHEN 'bands'      THEN 'band'
  WHEN 'kettlebell' THEN 'kettlebell'
  WHEN 'other'      THEN 'other'
  ELSE NULL
END
WHERE equipment_category IS NULL
  AND equipment IS NOT NULL;

-- Additional heuristic: exercises with 'plate' in name and machine equipment → plate_loaded
UPDATE exercises
SET equipment_category = 'plate_loaded'
WHERE equipment_category = 'machine'
  AND (lower(name) LIKE '%plate loaded%' OR lower(name) LIKE '%plate-loaded%');


-- =============================================================================
-- 3. EQUIPMENT CATEGORY ON GYM_MACHINES
-- =============================================================================

ALTER TABLE gym_machines
  ADD COLUMN IF NOT EXISTS equipment_category text;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'gym_machines_equipment_category_check'
  ) THEN
    ALTER TABLE gym_machines ADD CONSTRAINT gym_machines_equipment_category_check CHECK (
      equipment_category IN (
        'barbell', 'dumbbell', 'machine', 'cable', 'bodyweight',
        'kettlebell', 'band', 'smith_machine', 'plate_loaded', 'other'
      )
    );
  END IF;
END $$;

COMMENT ON COLUMN gym_machines.equipment_category IS
  'Structured equipment category for this gym machine. Matches exercises.equipment_category vocabulary.';

-- Index for filtering machines by category within a gym
CREATE INDEX IF NOT EXISTS gym_machines_equipment_category_idx
  ON gym_machines (gym_id, equipment_category)
  WHERE equipment_category IS NOT NULL;

-- Backfill gym_machines equipment_category from equipment_type field
UPDATE gym_machines
SET equipment_category = CASE lower(equipment_type)
  WHEN 'barbell'    THEN 'barbell'
  WHEN 'dumbbell'   THEN 'dumbbell'
  WHEN 'machine'    THEN 'machine'
  WHEN 'cable'      THEN 'cable'
  WHEN 'bodyweight' THEN 'bodyweight'
  WHEN 'body_only'  THEN 'bodyweight'
  WHEN 'bands'      THEN 'band'
  WHEN 'band'       THEN 'band'
  WHEN 'kettlebell' THEN 'kettlebell'
  WHEN 'smith_machine' THEN 'smith_machine'
  WHEN 'smith'      THEN 'smith_machine'
  WHEN 'plate_loaded' THEN 'plate_loaded'
  ELSE 'other'
END
WHERE equipment_category IS NULL
  AND equipment_type IS NOT NULL;

-- Override for Smith machines detected by name
UPDATE gym_machines
SET equipment_category = 'smith_machine'
WHERE equipment_category IN ('machine', 'other')
  AND lower(name) LIKE '%smith%';


-- =============================================================================
-- 4. USER EXERCISE OVERRIDES TABLE
-- =============================================================================

-- Per-user exercise customization layer. Complements:
--   user_exercise_notes (migration 023): form cues, injury flags, grip/stance preferences
--   user_exercise_preferences (migration 027): rating, favorites, default weight/reps/rest
-- This table adds: custom naming, equipment preference, personal difficulty assessment,
-- and weight/reps overrides that differ from exercise-level and preference-level defaults.
--
-- Use case: user calls "Bench Press" → "Flat Bench" in their vocabulary, prefers
-- dumbbells over barbell, rates it difficulty 3/5, and always starts at 60kg x 8.

CREATE TABLE IF NOT EXISTS user_exercise_overrides (
  id                          uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id                     uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  exercise_id                 uuid        NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
  custom_name                 text        CHECK (length(custom_name) <= 200),
  custom_form_cues            text[],
  custom_notes                text,
  default_weight_override     numeric     CHECK (default_weight_override >= 0),
  default_reps_override       integer     CHECK (default_reps_override > 0 AND default_reps_override <= 200),
  preferred_equipment_category text       CHECK (preferred_equipment_category IN (
    'barbell', 'dumbbell', 'machine', 'cable', 'bodyweight',
    'kettlebell', 'band', 'smith_machine', 'plate_loaded', 'other'
  )),
  personal_difficulty         smallint    CHECK (personal_difficulty >= 1 AND personal_difficulty <= 5),
  created_at                  timestamptz NOT NULL DEFAULT now(),
  updated_at                  timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, exercise_id)
);

COMMENT ON TABLE user_exercise_overrides IS
  'Per-user exercise customization: custom names, form cues, weight/reps overrides, equipment preference, personal difficulty.';
COMMENT ON COLUMN user_exercise_overrides.custom_name IS
  'User''s personal name for this exercise (e.g., "Flat Bench" instead of "Barbell Bench Press").';
COMMENT ON COLUMN user_exercise_overrides.preferred_equipment_category IS
  'User''s preferred equipment for this exercise. Influences default variant selection.';
COMMENT ON COLUMN user_exercise_overrides.personal_difficulty IS
  'Subjective difficulty 1-5. Independent from exercises.difficulty_level (objective). Reflects user''s current ability.';

-- Index on user_id for RLS policy enforcement
CREATE INDEX IF NOT EXISTS user_exercise_overrides_user_idx
  ON user_exercise_overrides (user_id);

-- Index for exercise_id lookups (e.g., "get all overrides for bench press")
CREATE INDEX IF NOT EXISTS user_exercise_overrides_exercise_idx
  ON user_exercise_overrides (exercise_id);

-- Updated_at trigger
CREATE TRIGGER user_exercise_overrides_updated_at
  BEFORE UPDATE ON user_exercise_overrides
  FOR EACH ROW
  EXECUTE FUNCTION set_updated_at();

-- RLS: Full CRUD scoped to user_id
ALTER TABLE user_exercise_overrides ENABLE ROW LEVEL SECURITY;

CREATE POLICY user_exercise_overrides_select ON user_exercise_overrides
  FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY user_exercise_overrides_insert ON user_exercise_overrides
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY user_exercise_overrides_update ON user_exercise_overrides
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY user_exercise_overrides_delete ON user_exercise_overrides
  FOR DELETE TO authenticated USING (user_id = auth.uid());


-- =============================================================================
-- 5. EXERCISE EQUIPMENT BRIDGE TABLE
-- =============================================================================

-- Many-to-many relationship: exercises can use multiple equipment types.
-- E.g., Bench Press → barbell (default), dumbbell, smith_machine.
-- The is_default flag indicates the canonical/most common equipment for that exercise.
-- This enables "what can I do with dumbbells?" and "what equipment can I use for bench press?"

CREATE TABLE IF NOT EXISTS exercise_equipment (
  id                 uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  exercise_id        uuid        NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
  equipment_category text        NOT NULL CHECK (equipment_category IN (
    'barbell', 'dumbbell', 'machine', 'cable', 'bodyweight',
    'kettlebell', 'band', 'smith_machine', 'plate_loaded', 'other'
  )),
  is_default         boolean     NOT NULL DEFAULT false,
  notes              text,
  UNIQUE (exercise_id, equipment_category)
);

COMMENT ON TABLE exercise_equipment IS
  'Junction table: exercises that can be performed with multiple equipment types. is_default marks the canonical equipment.';
COMMENT ON COLUMN exercise_equipment.is_default IS
  'True if this is the canonical/primary equipment for the exercise. Only one default per exercise.';

-- Only one default equipment per exercise
CREATE UNIQUE INDEX IF NOT EXISTS exercise_equipment_default_idx
  ON exercise_equipment (exercise_id)
  WHERE is_default = true;

-- Index for "what exercises can I do with this equipment?" queries
CREATE INDEX IF NOT EXISTS exercise_equipment_category_idx
  ON exercise_equipment (equipment_category);

-- Index for exercise_id lookups
CREATE INDEX IF NOT EXISTS exercise_equipment_exercise_idx
  ON exercise_equipment (exercise_id);

-- RLS: Public read for all authenticated (reference data like exercise_muscles)
ALTER TABLE exercise_equipment ENABLE ROW LEVEL SECURITY;

CREATE POLICY exercise_equipment_select ON exercise_equipment
  FOR SELECT TO authenticated USING (true);


-- =============================================================================
-- 6. SEED exercise_equipment FROM exercises.equipment_category
-- =============================================================================

-- Populate default equipment from the exercises table's equipment_category.
-- This establishes the "primary" equipment for each exercise.
INSERT INTO exercise_equipment (exercise_id, equipment_category, is_default, notes)
SELECT id, equipment_category, true, 'Auto-populated from exercises.equipment_category'
FROM exercises
WHERE equipment_category IS NOT NULL
ON CONFLICT (exercise_id, equipment_category) DO NOTHING;

-- Seed common multi-equipment exercises.
-- These exercises are commonly performed with alternative equipment types.
-- Pattern: find exercises by name, add secondary equipment options.

-- Bench Press variations: barbell (default), dumbbell, smith_machine
INSERT INTO exercise_equipment (exercise_id, equipment_category, is_default, notes)
SELECT id, 'dumbbell', false, 'Dumbbell bench press variation'
FROM exercises
WHERE lower(name) LIKE '%bench press%'
  AND equipment_category = 'barbell'
ON CONFLICT (exercise_id, equipment_category) DO NOTHING;

INSERT INTO exercise_equipment (exercise_id, equipment_category, is_default, notes)
SELECT id, 'smith_machine', false, 'Smith machine bench press variation'
FROM exercises
WHERE lower(name) LIKE '%bench press%'
  AND equipment_category = 'barbell'
ON CONFLICT (exercise_id, equipment_category) DO NOTHING;

-- Overhead/Shoulder Press: barbell (default), dumbbell, smith_machine
INSERT INTO exercise_equipment (exercise_id, equipment_category, is_default, notes)
SELECT id, 'dumbbell', false, 'Dumbbell overhead press variation'
FROM exercises
WHERE (lower(name) LIKE '%shoulder press%' OR lower(name) LIKE '%overhead press%'
       OR lower(name) LIKE '%military press%')
  AND equipment_category = 'barbell'
ON CONFLICT (exercise_id, equipment_category) DO NOTHING;

INSERT INTO exercise_equipment (exercise_id, equipment_category, is_default, notes)
SELECT id, 'smith_machine', false, 'Smith machine press variation'
FROM exercises
WHERE (lower(name) LIKE '%shoulder press%' OR lower(name) LIKE '%overhead press%'
       OR lower(name) LIKE '%military press%')
  AND equipment_category = 'barbell'
ON CONFLICT (exercise_id, equipment_category) DO NOTHING;

-- Row variations: barbell (default), dumbbell, cable, machine
INSERT INTO exercise_equipment (exercise_id, equipment_category, is_default, notes)
SELECT id, 'dumbbell', false, 'Dumbbell row variation'
FROM exercises
WHERE lower(name) LIKE '%barbell%row%'
  AND equipment_category = 'barbell'
ON CONFLICT (exercise_id, equipment_category) DO NOTHING;

INSERT INTO exercise_equipment (exercise_id, equipment_category, is_default, notes)
SELECT id, 'cable', false, 'Cable row variation'
FROM exercises
WHERE lower(name) LIKE '%barbell%row%'
  AND equipment_category = 'barbell'
ON CONFLICT (exercise_id, equipment_category) DO NOTHING;

-- Squat: barbell (default), dumbbell, smith_machine, bodyweight
INSERT INTO exercise_equipment (exercise_id, equipment_category, is_default, notes)
SELECT id, 'smith_machine', false, 'Smith machine squat variation'
FROM exercises
WHERE lower(name) LIKE '%barbell%squat%'
  AND equipment_category = 'barbell'
ON CONFLICT (exercise_id, equipment_category) DO NOTHING;

INSERT INTO exercise_equipment (exercise_id, equipment_category, is_default, notes)
SELECT id, 'dumbbell', false, 'Dumbbell/goblet squat variation'
FROM exercises
WHERE lower(name) LIKE '%barbell%squat%'
  AND equipment_category = 'barbell'
ON CONFLICT (exercise_id, equipment_category) DO NOTHING;

-- Deadlift: barbell (default), dumbbell, kettlebell
INSERT INTO exercise_equipment (exercise_id, equipment_category, is_default, notes)
SELECT id, 'dumbbell', false, 'Dumbbell deadlift variation'
FROM exercises
WHERE lower(name) LIKE '%deadlift%'
  AND equipment_category = 'barbell'
ON CONFLICT (exercise_id, equipment_category) DO NOTHING;

INSERT INTO exercise_equipment (exercise_id, equipment_category, is_default, notes)
SELECT id, 'kettlebell', false, 'Kettlebell deadlift variation'
FROM exercises
WHERE lower(name) LIKE '%deadlift%'
  AND equipment_category = 'barbell'
ON CONFLICT (exercise_id, equipment_category) DO NOTHING;

-- Curl variations: dumbbell (default where applicable), barbell, cable
INSERT INTO exercise_equipment (exercise_id, equipment_category, is_default, notes)
SELECT id, 'barbell', false, 'Barbell curl variation'
FROM exercises
WHERE lower(name) LIKE '%curl%' AND lower(name) NOT LIKE '%leg curl%'
  AND lower(name) NOT LIKE '%hamstring curl%'
  AND equipment_category = 'dumbbell'
ON CONFLICT (exercise_id, equipment_category) DO NOTHING;

INSERT INTO exercise_equipment (exercise_id, equipment_category, is_default, notes)
SELECT id, 'cable', false, 'Cable curl variation'
FROM exercises
WHERE lower(name) LIKE '%curl%' AND lower(name) NOT LIKE '%leg curl%'
  AND lower(name) NOT LIKE '%hamstring curl%'
  AND equipment_category = 'dumbbell'
ON CONFLICT (exercise_id, equipment_category) DO NOTHING;

-- Lateral raises: dumbbell (default), cable, band
INSERT INTO exercise_equipment (exercise_id, equipment_category, is_default, notes)
SELECT id, 'cable', false, 'Cable lateral raise variation'
FROM exercises
WHERE lower(name) LIKE '%lateral%raise%'
  AND equipment_category = 'dumbbell'
ON CONFLICT (exercise_id, equipment_category) DO NOTHING;

INSERT INTO exercise_equipment (exercise_id, equipment_category, is_default, notes)
SELECT id, 'band', false, 'Resistance band lateral raise variation'
FROM exercises
WHERE lower(name) LIKE '%lateral%raise%'
  AND equipment_category = 'dumbbell'
ON CONFLICT (exercise_id, equipment_category) DO NOTHING;

-- Tricep extensions: cable (default for pushdowns), dumbbell, band
INSERT INTO exercise_equipment (exercise_id, equipment_category, is_default, notes)
SELECT id, 'dumbbell', false, 'Dumbbell tricep extension variation'
FROM exercises
WHERE (lower(name) LIKE '%tricep%extension%' OR lower(name) LIKE '%pushdown%')
  AND equipment_category = 'cable'
ON CONFLICT (exercise_id, equipment_category) DO NOTHING;

-- Lunge: bodyweight (default), dumbbell, barbell, kettlebell
INSERT INTO exercise_equipment (exercise_id, equipment_category, is_default, notes)
SELECT id, 'dumbbell', false, 'Dumbbell lunge variation'
FROM exercises
WHERE (lower(name) LIKE '%lunge%' OR lower(name) LIKE '%split squat%')
  AND equipment_category = 'bodyweight'
ON CONFLICT (exercise_id, equipment_category) DO NOTHING;

INSERT INTO exercise_equipment (exercise_id, equipment_category, is_default, notes)
SELECT id, 'barbell', false, 'Barbell lunge variation'
FROM exercises
WHERE (lower(name) LIKE '%lunge%' OR lower(name) LIKE '%split squat%')
  AND equipment_category = 'bodyweight'
ON CONFLICT (exercise_id, equipment_category) DO NOTHING;

INSERT INTO exercise_equipment (exercise_id, equipment_category, is_default, notes)
SELECT id, 'kettlebell', false, 'Kettlebell lunge variation'
FROM exercises
WHERE (lower(name) LIKE '%lunge%' OR lower(name) LIKE '%split squat%')
  AND equipment_category = 'bodyweight'
ON CONFLICT (exercise_id, equipment_category) DO NOTHING;

-- Hip thrust: barbell (default where applicable), band, bodyweight
INSERT INTO exercise_equipment (exercise_id, equipment_category, is_default, notes)
SELECT id, 'band', false, 'Banded hip thrust variation'
FROM exercises
WHERE lower(name) LIKE '%hip thrust%'
  AND equipment_category = 'barbell'
ON CONFLICT (exercise_id, equipment_category) DO NOTHING;

INSERT INTO exercise_equipment (exercise_id, equipment_category, is_default, notes)
SELECT id, 'bodyweight', false, 'Bodyweight hip thrust / glute bridge'
FROM exercises
WHERE lower(name) LIKE '%hip thrust%'
  AND equipment_category = 'barbell'
ON CONFLICT (exercise_id, equipment_category) DO NOTHING;

-- Calf raise: machine (default), bodyweight, smith_machine, dumbbell
INSERT INTO exercise_equipment (exercise_id, equipment_category, is_default, notes)
SELECT id, 'bodyweight', false, 'Bodyweight calf raise variation'
FROM exercises
WHERE lower(name) LIKE '%calf%raise%'
  AND equipment_category = 'machine'
ON CONFLICT (exercise_id, equipment_category) DO NOTHING;

INSERT INTO exercise_equipment (exercise_id, equipment_category, is_default, notes)
SELECT id, 'smith_machine', false, 'Smith machine calf raise variation'
FROM exercises
WHERE lower(name) LIKE '%calf%raise%'
  AND equipment_category = 'machine'
ON CONFLICT (exercise_id, equipment_category) DO NOTHING;


-- =============================================================================
-- 7. SEARCH IMPROVEMENTS: pg_trgm fuzzy search
-- =============================================================================

-- Enable pg_trgm extension for trigram-based fuzzy matching.
-- Supabase includes pg_trgm by default; CREATE EXTENSION is idempotent.
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- GIN trigram index on exercises.name for fuzzy search (LIKE '%term%', similarity())
-- Enables: SELECT * FROM exercises WHERE name % 'benchpress' ORDER BY similarity(name, 'benchpress') DESC
CREATE INDEX IF NOT EXISTS exercises_name_trgm_idx
  ON exercises USING GIN (name gin_trgm_ops);

COMMENT ON INDEX exercises_name_trgm_idx IS
  'Trigram GIN index for fuzzy name search. Supports LIKE, ILIKE, similarity(), and % operator.';

-- GIN index on exercises.aliases for array containment queries (@>)
-- Migration 019 already created exercises_aliases_idx; verify it exists and add
-- a trigram index on the array elements for broader search capability.
-- Note: GIN on text[] already supports @> (array contains). For fuzzy matching
-- on individual alias elements, the application should unnest and use similarity().


-- =============================================================================
-- 8. VIEW: exercise_muscle_summary
-- =============================================================================

-- Aggregated exercise catalog view for filtering, browsing, and search.
-- Combines exercise metadata with aggregated muscle data from exercise_muscles.
-- Primary and secondary muscles are aggregated into comma-separated strings.
-- Max activation percentage provides a quick "intensity" indicator.

CREATE OR REPLACE VIEW exercise_muscle_summary
WITH (security_invoker = true) AS
SELECT
  e.id                                                     AS exercise_id,
  e.name                                                   AS exercise_name,
  e.equipment_category,
  -- Primary muscles (agonists): aggregated as comma-separated string
  STRING_AGG(DISTINCT mg.name, ', ' ORDER BY mg.name)
    FILTER (WHERE em.is_primary = true)                    AS primary_muscles,
  -- Secondary muscles (synergists + stabilizers): aggregated
  STRING_AGG(DISTINCT mg.name, ', ' ORDER BY mg.name)
    FILTER (WHERE em.is_primary = false)                   AS secondary_muscles,
  -- Highest activation percentage across all mapped muscles
  MAX(em.activation_percent)                               AS max_activation_pct,
  -- Compound flag from generated column
  e.is_compound,
  -- Difficulty from migration 021
  e.difficulty_level,
  -- Movement pattern from migration 015
  e.movement_pattern
FROM exercises e
LEFT JOIN exercise_muscles em ON em.exercise_id = e.id
LEFT JOIN muscle_groups mg    ON mg.id = em.muscle_group_id
GROUP BY e.id, e.name, e.equipment_category, e.is_compound, e.difficulty_level, e.movement_pattern;

COMMENT ON VIEW exercise_muscle_summary IS
  'Aggregated exercise catalog: equipment category, primary/secondary muscles, activation, compound flag, difficulty, movement pattern. RLS via security_invoker.';


-- =============================================================================
-- 9. VIEW: gym_exercise_catalog
-- =============================================================================

-- Shows what exercises are available at each gym based on gym_machines.
-- Joins through gym_machines to exercises, providing a browsable gym catalog.
-- The `available` flag is always true in this view (rows only exist when a
-- gym_machine exists). To get "available + unavailable", the application
-- should LEFT JOIN exercises with this view.

CREATE OR REPLACE VIEW gym_exercise_catalog
WITH (security_invoker = true) AS
SELECT
  g.id                                                     AS gym_id,
  g.name                                                   AS gym_name,
  e.id                                                     AS exercise_id,
  e.name                                                   AS exercise_name,
  COALESCE(gm.equipment_category, e.equipment_category)    AS equipment_category,
  gm.name                                                  AS machine_name,
  gm.id                                                    AS gym_machine_id,
  gm.manufacturer,
  gm.weight_range_min,
  gm.weight_range_max,
  gm.weight_increment,
  -- Aggregated primary muscles for this exercise
  STRING_AGG(DISTINCT mg.name, ', ' ORDER BY mg.name)
    FILTER (WHERE em.is_primary = true)                    AS primary_muscles,
  -- Available flag: always true when gym_machine row exists
  true                                                     AS available
FROM gyms g
JOIN gym_machines gm    ON gm.gym_id = g.id AND gm.is_active = true
JOIN exercises e        ON e.id = gm.exercise_id
LEFT JOIN exercise_muscles em ON em.exercise_id = e.id
LEFT JOIN muscle_groups mg    ON mg.id = em.muscle_group_id AND em.is_primary = true
WHERE g.is_active = true
GROUP BY g.id, g.name, e.id, e.name, gm.equipment_category, e.equipment_category,
         gm.name, gm.id, gm.manufacturer, gm.weight_range_min, gm.weight_range_max,
         gm.weight_increment;

COMMENT ON VIEW gym_exercise_catalog IS
  'Gym equipment catalog: exercises available at each gym via gym_machines. Includes machine details and primary muscles. RLS via security_invoker.';


COMMIT;
