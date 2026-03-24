-- Migration 010: Add updated_at to exercises table
-- Resolves issue #41: custom exercises could not track when they were last modified.

ALTER TABLE exercises
  ADD COLUMN updated_at timestamptz NOT NULL DEFAULT now();

CREATE TRIGGER exercises_updated_at
  BEFORE UPDATE ON exercises
  FOR EACH ROW
  EXECUTE FUNCTION set_updated_at();
