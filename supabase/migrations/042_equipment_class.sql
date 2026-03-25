-- Migration 042: Add broad equipment_class for top-level filtering
--
-- equipment_category (13 values) is the granular subcategory for detailed matching.
-- equipment_class (3 values) is the broad grouping for primary UI filters:
--   'machine'    — machine, cable, smith_machine, plate_loaded
--   'freeweight' — barbell, dumbbell, kettlebell, trap_bar, ez_bar, plate
--   'bodyweight' — bodyweight, band, suspension
--
-- Stored as a generated column so it stays in sync with equipment_category
-- automatically — no triggers, no backfill drift.

BEGIN;

-- =============================================================================
-- 1. EXERCISES TABLE
-- =============================================================================

ALTER TABLE exercises
  ADD COLUMN IF NOT EXISTS equipment_class text
  GENERATED ALWAYS AS (
    CASE
      WHEN equipment_category IN ('machine', 'cable', 'smith_machine', 'plate_loaded')
        THEN 'machine'
      WHEN equipment_category IN ('barbell', 'dumbbell', 'kettlebell', 'trap_bar', 'ez_bar', 'plate')
        THEN 'freeweight'
      WHEN equipment_category IN ('bodyweight', 'band', 'suspension')
        THEN 'bodyweight'
      ELSE NULL
    END
  ) STORED;

COMMENT ON COLUMN exercises.equipment_class IS
  'Broad equipment grouping (machine / freeweight / bodyweight). Generated from equipment_category.';

CREATE INDEX IF NOT EXISTS exercises_equipment_class_idx
  ON exercises (equipment_class)
  WHERE equipment_class IS NOT NULL;


-- =============================================================================
-- 2. GYM_MACHINES TABLE
-- =============================================================================

ALTER TABLE gym_machines
  ADD COLUMN IF NOT EXISTS equipment_class text
  GENERATED ALWAYS AS (
    CASE
      WHEN equipment_category IN ('machine', 'cable', 'smith_machine', 'plate_loaded')
        THEN 'machine'
      WHEN equipment_category IN ('barbell', 'dumbbell', 'kettlebell', 'trap_bar', 'ez_bar', 'plate')
        THEN 'freeweight'
      WHEN equipment_category IN ('bodyweight', 'band', 'suspension')
        THEN 'bodyweight'
      ELSE NULL
    END
  ) STORED;

COMMENT ON COLUMN gym_machines.equipment_class IS
  'Broad equipment grouping. Generated from equipment_category.';

CREATE INDEX IF NOT EXISTS gym_machines_equipment_class_idx
  ON gym_machines (gym_id, equipment_class)
  WHERE equipment_class IS NOT NULL;


-- =============================================================================
-- 3. UPDATE VIEWS TO INCLUDE equipment_class
-- =============================================================================

-- Recreate exercise_muscle_summary with equipment_class
CREATE OR REPLACE VIEW exercise_muscle_summary
WITH (security_invoker = true)
AS
SELECT
  e.id            AS exercise_id,
  e.name          AS exercise_name,
  e.equipment_category,
  e.equipment_class,
  e.is_compound,
  e.difficulty_level,
  e.movement_pattern,
  (
    SELECT string_agg(DISTINCT mg.name, ', ' ORDER BY mg.name)
    FROM exercise_muscles em
    JOIN muscle_groups mg ON mg.id = em.muscle_group_id
    WHERE em.exercise_id = e.id AND em.is_primary = true
  ) AS primary_muscles,
  (
    SELECT string_agg(DISTINCT mg.name, ', ' ORDER BY mg.name)
    FROM exercise_muscles em
    JOIN muscle_groups mg ON mg.id = em.muscle_group_id
    WHERE em.exercise_id = e.id AND em.is_primary = false
  ) AS secondary_muscles,
  (
    SELECT MAX(em.activation_percent)
    FROM exercise_muscles em
    WHERE em.exercise_id = e.id
  ) AS max_activation_pct
FROM exercises e;

COMMENT ON VIEW exercise_muscle_summary IS
  'Denormalized exercise view for filtering by equipment_class, equipment_category, muscle, difficulty, and movement pattern.';


-- Recreate gym_exercise_catalog with equipment_class
CREATE OR REPLACE VIEW gym_exercise_catalog
WITH (security_invoker = true)
AS
SELECT
  g.id            AS gym_id,
  g.name          AS gym_name,
  e.id            AS exercise_id,
  e.name          AS exercise_name,
  e.equipment_category,
  e.equipment_class,
  gm.name         AS machine_name,
  (
    SELECT string_agg(DISTINCT mg.name, ', ' ORDER BY mg.name)
    FROM exercise_muscles em
    JOIN muscle_groups mg ON mg.id = em.muscle_group_id
    WHERE em.exercise_id = e.id AND em.is_primary = true
  ) AS primary_muscles
FROM gyms g
JOIN gym_machines gm ON gm.gym_id = g.id AND gm.is_active = true
JOIN exercises e ON e.id = gm.exercise_id;

COMMENT ON VIEW gym_exercise_catalog IS
  'Gym machine catalog enriched with exercise metadata for browsing and filtering.';

COMMIT;
