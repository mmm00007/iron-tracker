-- Iron Tracker: Fix Dangerous ON DELETE CASCADE on sets.exercise_id and gym_machines.exercise_id
--
-- Issue #31: Deleting a seed exercise currently cascades and silently wipes ALL user sets
-- and gym machine records referencing that exercise. This migration replaces ON DELETE CASCADE
-- with ON DELETE RESTRICT on both columns so an exercise cannot be deleted while any
-- sets or gym_machines rows still reference it.
--
-- Note: exercise_muscles, equipment_variants, personal_records, and analytics_cache are
-- not changed here — they are addressed separately if needed. This migration is forward-only.

-- =============================================================================
-- 1. sets.exercise_id: CASCADE → RESTRICT
-- =============================================================================

ALTER TABLE sets
  DROP CONSTRAINT sets_exercise_id_fkey,
  ADD CONSTRAINT sets_exercise_id_fkey
    FOREIGN KEY (exercise_id)
    REFERENCES exercises(id)
    ON DELETE RESTRICT;

-- =============================================================================
-- 2. gym_machines.exercise_id: CASCADE → RESTRICT
-- =============================================================================

ALTER TABLE gym_machines
  DROP CONSTRAINT gym_machines_exercise_id_fkey,
  ADD CONSTRAINT gym_machines_exercise_id_fkey
    FOREIGN KEY (exercise_id)
    REFERENCES exercises(id)
    ON DELETE RESTRICT;
