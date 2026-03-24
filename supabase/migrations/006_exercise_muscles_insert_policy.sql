-- Migration 006: Add INSERT and DELETE policies for exercise_muscles
--
-- Issue #34: exercise_muscles only had a SELECT policy, preventing users
-- from adding or removing muscle mappings for their own custom exercises.
-- These policies restrict writes to exercises owned by the authenticated user.

CREATE POLICY exercise_muscles_insert ON exercise_muscles
  FOR INSERT TO authenticated
  WITH CHECK (
    exercise_id IN (
      SELECT id FROM exercises WHERE created_by = auth.uid()
    )
  );

CREATE POLICY exercise_muscles_delete ON exercise_muscles
  FOR DELETE TO authenticated
  USING (
    exercise_id IN (
      SELECT id FROM exercises WHERE created_by = auth.uid()
    )
  );
