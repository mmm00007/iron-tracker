-- Migration 050: exercise_muscles write RLS policies
-- Allows authenticated users to INSERT/DELETE exercise_muscles rows
-- for exercises they own (created_by = auth.uid()).
-- Required for the exercise edit form to save muscle group assignments.
-- Replaces policies from migration 006 with equivalent EXISTS-based versions.

BEGIN;

-- Drop existing policies from migration 006 (if present) to avoid name collision
DROP POLICY IF EXISTS exercise_muscles_insert ON exercise_muscles;
DROP POLICY IF EXISTS exercise_muscles_delete ON exercise_muscles;

CREATE POLICY exercise_muscles_insert ON exercise_muscles
  FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM exercises
      WHERE exercises.id = exercise_id
        AND exercises.created_by = auth.uid()
    )
  );

CREATE POLICY exercise_muscles_delete ON exercise_muscles
  FOR DELETE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM exercises
      WHERE exercises.id = exercise_id
        AND exercises.created_by = auth.uid()
    )
  );

COMMIT;
