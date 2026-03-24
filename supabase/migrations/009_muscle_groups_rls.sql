-- Migration 009: Enable RLS on muscle_groups
--
-- Issue #45: muscle_groups had no RLS enabled, allowing the anon role to
-- read and write the table without restriction.
--
-- muscle_groups is reference data (seed catalog). Authenticated users need
-- SELECT access; writes are restricted to the service role (no INSERT/UPDATE/
-- DELETE policies are created here).

ALTER TABLE muscle_groups ENABLE ROW LEVEL SECURITY;

-- Allow all authenticated users to read muscle groups (reference data)
CREATE POLICY muscle_groups_select ON muscle_groups
  FOR SELECT TO authenticated
  USING (true);
