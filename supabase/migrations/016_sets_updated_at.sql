-- Migration 016: Add updated_at to sets table for sync conflict resolution
--
-- Enables last-write-wins conflict resolution when the same set is modified
-- on multiple devices or the optimistic update conflicts with the server.

ALTER TABLE sets ADD COLUMN IF NOT EXISTS updated_at timestamptz DEFAULT now();

-- Reuse the existing set_updated_at() trigger function
CREATE TRIGGER sets_updated_at
  BEFORE UPDATE ON sets
  FOR EACH ROW
  EXECUTE FUNCTION set_updated_at();

-- Backfill: set updated_at = created_at for existing rows
UPDATE sets SET updated_at = COALESCE(logged_at, now()) WHERE updated_at IS NULL;
