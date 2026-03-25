-- Migration 018: Security hardening
-- Fixes: soreness_reports schema mismatch, CASCADE delete risks,
-- missing exercise_muscles UPDATE policy, sets.updated_at nullable

-- ─── H7: Fix soreness_reports schema mismatch (001 vs 013) ─────────────────
-- Migration 001 created the table with 'severity'; migration 013 expects 'level'
-- and 'training_date'. Since CREATE TABLE IF NOT EXISTS in 013 was a no-op,
-- the actual schema still has the 001 definition.

-- Add training_date column if missing
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'soreness_reports' AND column_name = 'training_date'
  ) THEN
    ALTER TABLE soreness_reports ADD COLUMN training_date date;
    -- Backfill from reported_at
    UPDATE soreness_reports SET training_date = reported_at::date WHERE training_date IS NULL;
    ALTER TABLE soreness_reports ALTER COLUMN training_date SET NOT NULL;
  END IF;
END $$;

-- Rename severity → level if the old column name still exists
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'soreness_reports' AND column_name = 'severity'
  ) AND NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'soreness_reports' AND column_name = 'level'
  ) THEN
    ALTER TABLE soreness_reports RENAME COLUMN severity TO level;
    -- Update the CHECK constraint
    ALTER TABLE soreness_reports DROP CONSTRAINT IF EXISTS soreness_reports_severity_check;
    ALTER TABLE soreness_reports ADD CONSTRAINT soreness_reports_level_check CHECK (level BETWEEN 0 AND 4);
  END IF;
END $$;

-- Change column type to smallint if it's still integer
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'soreness_reports' AND column_name = 'level'
      AND data_type = 'integer'
  ) THEN
    ALTER TABLE soreness_reports ALTER COLUMN level TYPE smallint;
  END IF;
END $$;

-- Add unique constraint if missing
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'soreness_reports'::regclass
      AND contype = 'u'
  ) THEN
    ALTER TABLE soreness_reports ADD CONSTRAINT soreness_reports_user_muscle_date_unique
      UNIQUE (user_id, muscle_group_id, training_date);
  END IF;
END $$;

-- Drop duplicate FOR ALL policy created by migration 013 (if it exists)
DROP POLICY IF EXISTS "Users can CRUD their own soreness reports" ON soreness_reports;

-- Ensure indexes exist
CREATE INDEX IF NOT EXISTS idx_soreness_reports_user_id ON soreness_reports(user_id);
CREATE INDEX IF NOT EXISTS idx_soreness_reports_training_date ON soreness_reports(training_date);


-- ─── H8: Fix CASCADE deletes on plan_items and exercise_favorites ──────────

-- plan_items.exercise_id: CASCADE → RESTRICT
ALTER TABLE plan_items
  DROP CONSTRAINT IF EXISTS plan_items_exercise_id_fkey;
ALTER TABLE plan_items
  ADD CONSTRAINT plan_items_exercise_id_fkey
    FOREIGN KEY (exercise_id) REFERENCES exercises(id) ON DELETE RESTRICT;

-- exercise_favorites.exercise_id: CASCADE → RESTRICT
ALTER TABLE exercise_favorites
  DROP CONSTRAINT IF EXISTS exercise_favorites_exercise_id_fkey;
ALTER TABLE exercise_favorites
  ADD CONSTRAINT exercise_favorites_exercise_id_fkey
    FOREIGN KEY (exercise_id) REFERENCES exercises(id) ON DELETE RESTRICT;


-- ─── M7: Add UPDATE policy on exercise_muscles ────────────────────────────

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'exercise_muscles' AND policyname = 'exercise_muscles_update'
  ) THEN
    CREATE POLICY exercise_muscles_update ON exercise_muscles
      FOR UPDATE TO authenticated
      USING (exercise_id IN (SELECT id FROM exercises WHERE created_by = auth.uid()))
      WITH CHECK (exercise_id IN (SELECT id FROM exercises WHERE created_by = auth.uid()));
  END IF;
END $$;


-- ─── L5: Make sets.updated_at NOT NULL ────────────────────────────────────

-- Backfill any remaining NULLs first
UPDATE sets SET updated_at = logged_at WHERE updated_at IS NULL;

-- Now enforce NOT NULL
ALTER TABLE sets ALTER COLUMN updated_at SET NOT NULL;
