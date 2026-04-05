-- Migration 069: Phase Context on Exercise Effectiveness Scores
-- Extends exercise_effectiveness_scores with phase_context so analytics
-- can compare apples-to-apples: a 12RM hypertrophy set and a 3RM strength
-- set should not share an e1RM slope comparison.
--
-- Validated by: data-science-expert
--
-- Key design decisions (from data-science-expert review):
--   - Partition effectiveness by phase_context, not replace existing rows
--   - When an 8-week window crosses phases, backend emits multiple rows:
--     one per phase fully contained + one row with phase_context='mixed'
--   - phase_id FK is nullable (historical analyses may be phase-agnostic)
--   - ON DELETE SET NULL: deleting a phase doesn't wipe historical analyses
--   - Extends UNIQUE to include phase_context — existing rows backfill to 'general'
--
-- Citations:
--   - Schoenfeld et al. (2017). Rep-range-specific adaptation meta-analysis.
--   - Helms E. et al. (2019). Muscle and Strength Pyramid — phase design.

BEGIN;

-- =============================================================================
-- 1. Add phase_context + phase_id columns
-- =============================================================================

ALTER TABLE exercise_effectiveness_scores
  ADD COLUMN IF NOT EXISTS phase_context text
    NOT NULL DEFAULT 'general'
    CHECK (phase_context IN (
      'general', 'hypertrophy', 'strength', 'power', 'peaking',
      'deload', 'maintenance', 'technique_primer', 'active_recovery', 'mixed'
    )),
  ADD COLUMN IF NOT EXISTS phase_id uuid
    REFERENCES training_phases(id) ON DELETE SET NULL;

COMMENT ON COLUMN exercise_effectiveness_scores.phase_context IS
  'Training phase during this window. Cross-phase comparisons are invalid: a '
  'hypertrophy-block slope vs a strength-block slope measure different things. '
  '"mixed" is emitted when an 8-week window crosses phase boundaries. '
  '"general" is the default when user has not declared any training phases.';

COMMENT ON COLUMN exercise_effectiveness_scores.phase_id IS
  'Link to the specific training_phases row this analysis targeted. NULL for '
  'mixed/general contexts or historical rows. ON DELETE SET NULL preserves analysis.';

-- =============================================================================
-- 2. Expand UNIQUE to include phase_context
-- =============================================================================
-- Old UNIQUE: (user_id, exercise_id, window_weeks, period_start)
-- New UNIQUE: (user_id, exercise_id, window_weeks, period_start, phase_context)
-- This allows storing multiple phase-partitioned analyses for the same window.

-- Drop the original 4-column UNIQUE constraint by finding it dynamically.
-- Postgres truncates generated constraint names, so we search for any UNIQUE
-- constraint on exercise_effectiveness_scores that covers these exact columns.
DO $$
DECLARE
  v_conname text;
BEGIN
  SELECT conname INTO v_conname
  FROM pg_constraint
  WHERE conrelid = 'exercise_effectiveness_scores'::regclass
    AND contype = 'u'
    AND array_length(conkey, 1) = 4
    AND EXISTS (
      SELECT 1
      FROM unnest(conkey) AS col_num
      WHERE col_num IN (
        SELECT attnum FROM pg_attribute
        WHERE attrelid = 'exercise_effectiveness_scores'::regclass
          AND attname = 'user_id'
      )
    )
  LIMIT 1;

  IF v_conname IS NOT NULL THEN
    EXECUTE format('ALTER TABLE exercise_effectiveness_scores DROP CONSTRAINT %I', v_conname);
  END IF;
END $$;

-- Add new UNIQUE index with phase_context dimension
CREATE UNIQUE INDEX IF NOT EXISTS exercise_effectiveness_scores_unique_idx
  ON exercise_effectiveness_scores (user_id, exercise_id, window_weeks, period_start, phase_context);

-- =============================================================================
-- 3. Indexes for phase-filtered queries
-- =============================================================================

CREATE INDEX IF NOT EXISTS effectiveness_user_phase_idx
  ON exercise_effectiveness_scores (user_id, phase_context, period_end DESC)
  WHERE phase_context != 'general';

CREATE INDEX IF NOT EXISTS effectiveness_phase_ref_idx
  ON exercise_effectiveness_scores (phase_id)
  WHERE phase_id IS NOT NULL;

-- =============================================================================
-- 4. Helper view: effectiveness_current_phase
-- =============================================================================
-- For each user, return most recent effectiveness scores filtered to their
-- current active phase (falling back to 'general' if no phase active).

CREATE OR REPLACE VIEW effectiveness_current_phase
WITH (security_invoker = true) AS
WITH active_phase_per_user AS (
  SELECT DISTINCT ON (user_id)
    user_id, phase_type, id AS phase_id
  FROM training_phases
  WHERE end_date IS NULL
  ORDER BY user_id, start_date DESC
)
SELECT
  ees.user_id,
  ees.exercise_id,
  ees.phase_context,
  ees.e1rm_slope,
  ees.e1rm_ci_lower,
  ees.e1rm_ci_upper,
  ees.volume_efficiency,
  ees.consistency_score,
  ees.effectiveness_rank,
  ees.movement_category,
  ees.recommendation,
  ees.data_quality,
  ees.period_start,
  ees.period_end,
  ees.window_weeks
FROM exercise_effectiveness_scores ees
LEFT JOIN active_phase_per_user app ON app.user_id = ees.user_id
WHERE ees.phase_context = COALESCE(app.phase_type, 'general')
  AND ees.period_end = (
    SELECT MAX(period_end) FROM exercise_effectiveness_scores
    WHERE user_id = ees.user_id AND exercise_id = ees.exercise_id
      AND phase_context = ees.phase_context
  );

COMMENT ON VIEW effectiveness_current_phase IS
  'Latest effectiveness score per (user, exercise) filtered to user active phase. '
  'Falls back to phase_context=general if user has no declared phase. Used by '
  'coaching UI to recommend exercises for the current training block.';

COMMIT;
