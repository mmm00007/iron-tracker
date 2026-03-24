-- Migration: Fix estimated_1rm trigger to fire on both INSERT and UPDATE
--
-- Issue #17: sets_compute_estimated_1rm only fired on INSERT, leaving
-- estimated_1rm stale when a user edits weight or reps on an existing set.

-- Drop the INSERT-only trigger
DROP TRIGGER IF EXISTS sets_compute_estimated_1rm ON sets;

-- Recreate it to fire on both INSERT and UPDATE
CREATE TRIGGER sets_compute_estimated_1rm
  BEFORE INSERT OR UPDATE ON sets
  FOR EACH ROW
  EXECUTE FUNCTION compute_estimated_1rm();
