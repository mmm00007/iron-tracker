-- Migration: Add missing indexes for common query patterns
--
-- Issue #29: Three query patterns lack covering indexes, causing sequential scans
-- on tables that are read on every user session.
--
--   1. personal_records: fetched ordered by achieved_at DESC per user
--   2. soreness_reports: fetched ordered by reported_at DESC per user
--   3. equipment_variants: FK scan triggered by ON DELETE SET NULL on gym_machine_id

-- Index 1: Recent PRs query — (user_id, achieved_at DESC)
CREATE INDEX IF NOT EXISTS personal_records_user_achieved_idx
  ON personal_records (user_id, achieved_at DESC);

-- Index 2: User soreness history — (user_id, reported_at DESC)
CREATE INDEX IF NOT EXISTS soreness_reports_user_reported_idx
  ON soreness_reports (user_id, reported_at DESC);

-- Index 3: ON DELETE SET NULL FK scan — partial index, only rows where FK is set
CREATE INDEX IF NOT EXISTS equipment_variants_gym_machine_idx
  ON equipment_variants (gym_machine_id)
  WHERE gym_machine_id IS NOT NULL;
