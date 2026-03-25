-- Migration 033: Exercise Progress Snapshots + Equipment Stats 7d
-- Pre-computed periodic exercise progress summaries for fast trend queries,
-- and extends equipment_usage_stats with a 7-day window.
--
-- Validated by: fitness-domain-expert agent, database-specialist agent
--
-- Key design decisions:
--   - Follows workload_balance_scores pattern (backend cron writes, frontend reads)
--   - Uses period_start/period_end instead of single snapshot_date for clarity
--   - best_e1rm_reps tracks the rep count at which best e1RM was achieved —
--     critical because Epley degrades above 10-12 reps (NSCA guidelines)
--   - equipment_usage_stats extended with 7-day window for recent activity

BEGIN;

-- =============================================================================
-- 1. TABLE: exercise_progress_snapshots
-- =============================================================================

CREATE TABLE IF NOT EXISTS exercise_progress_snapshots (
  id                uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id           uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  exercise_id       uuid        NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
  period_type       text        NOT NULL CHECK (period_type IN ('week', 'month')),
  period_start      date        NOT NULL,
  period_end        date        NOT NULL,
  best_e1rm         numeric,
  best_e1rm_reps    smallint,
  best_weight       numeric,
  best_reps         integer,
  total_sets        integer     NOT NULL DEFAULT 0,
  working_sets      integer     NOT NULL DEFAULT 0,
  total_volume_kg   numeric,
  avg_rpe           numeric(3,1),
  avg_rest_seconds  numeric,
  training_days     integer     NOT NULL DEFAULT 0,
  computed_at       timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, exercise_id, period_type, period_start),
  CONSTRAINT progress_snapshot_period_check
    CHECK (period_end >= period_start)
);

COMMENT ON TABLE exercise_progress_snapshots IS
  'Pre-computed periodic exercise progress summaries. Backend cron writes '
  'weekly/monthly. Enables fast trend queries without full table scans on sets.';
COMMENT ON COLUMN exercise_progress_snapshots.best_e1rm_reps IS
  'Rep count at which best_e1rm was achieved. An e1RM from a 1-rep max is '
  'more reliable than one from 15 reps (Epley degrades above 10-12 reps).';
COMMENT ON COLUMN exercise_progress_snapshots.period_start IS
  'Inclusive start date of the snapshot period. For weeks, this is Monday.';
COMMENT ON COLUMN exercise_progress_snapshots.period_end IS
  'Inclusive end date of the snapshot period. For weeks, this is Sunday.';

-- Indexes
CREATE INDEX IF NOT EXISTS exercise_progress_user_exercise_idx
  ON exercise_progress_snapshots (user_id, exercise_id, period_start DESC);

CREATE INDEX IF NOT EXISTS exercise_progress_user_period_idx
  ON exercise_progress_snapshots (user_id, period_type, period_start DESC);

-- RLS
ALTER TABLE exercise_progress_snapshots ENABLE ROW LEVEL SECURITY;

CREATE POLICY exercise_progress_select ON exercise_progress_snapshots
  FOR SELECT TO authenticated USING (user_id = auth.uid());
-- Service role writes via cron — no authenticated INSERT/UPDATE needed
CREATE POLICY exercise_progress_service_insert ON exercise_progress_snapshots
  FOR INSERT TO service_role WITH CHECK (true);
CREATE POLICY exercise_progress_service_update ON exercise_progress_snapshots
  FOR UPDATE TO service_role USING (true) WITH CHECK (true);
CREATE POLICY exercise_progress_service_delete ON exercise_progress_snapshots
  FOR DELETE TO service_role USING (true);


-- =============================================================================
-- 2. FUNCTION: compute_exercise_progress_snapshot
-- =============================================================================

-- Computes and upserts weekly progress snapshots for a given user and week.
-- Called by backend cron after each training day.
CREATE OR REPLACE FUNCTION compute_exercise_progress_snapshot(
  p_user_id uuid,
  p_period_type text DEFAULT 'week',
  p_period_start date DEFAULT date_trunc('week', CURRENT_DATE)::date
)
RETURNS void AS $$
DECLARE
  v_period_end date;
BEGIN
  -- Compute period end
  IF p_period_type = 'week' THEN
    v_period_end := p_period_start + interval '6 days';
  ELSIF p_period_type = 'month' THEN
    v_period_end := (p_period_start + interval '1 month' - interval '1 day')::date;
  ELSE
    RAISE EXCEPTION 'Invalid period_type: %', p_period_type;
  END IF;

  -- Upsert snapshots for each exercise with data in the period
  INSERT INTO exercise_progress_snapshots (
    user_id, exercise_id, period_type, period_start, period_end,
    best_e1rm, best_e1rm_reps, best_weight, best_reps,
    total_sets, working_sets, total_volume_kg,
    avg_rpe, avg_rest_seconds, training_days, computed_at
  )
  SELECT
    p_user_id,
    s.exercise_id,
    p_period_type,
    p_period_start,
    v_period_end,
    -- Best e1RM: pick the maximum, then get the reps for that set
    MAX(s.estimated_1rm),
    -- Reps at best e1rm (subquery for the set with highest e1rm)
    (SELECT sub.reps FROM sets sub
     WHERE sub.user_id = p_user_id
       AND sub.exercise_id = s.exercise_id
       AND sub.training_date BETWEEN p_period_start AND v_period_end
       AND sub.estimated_1rm = MAX(s.estimated_1rm)
     ORDER BY sub.logged_at DESC LIMIT 1),
    MAX(CASE WHEN s.weight_unit = 'lb' THEN s.weight * 0.453592 ELSE s.weight END),
    MAX(s.reps),
    COUNT(*),
    COUNT(*) FILTER (WHERE s.set_type = 'working'),
    SUM(
      CASE WHEN s.weight_unit = 'lb' THEN s.weight * 0.453592 ELSE s.weight END
      * s.reps
    ),
    ROUND(AVG(s.rpe) FILTER (WHERE s.rpe IS NOT NULL), 1),
    ROUND(AVG(s.rest_seconds) FILTER (WHERE s.rest_seconds IS NOT NULL)),
    COUNT(DISTINCT s.training_date),
    now()
  FROM sets s
  WHERE s.user_id = p_user_id
    AND s.training_date BETWEEN p_period_start AND v_period_end
  GROUP BY s.exercise_id
  ON CONFLICT (user_id, exercise_id, period_type, period_start)
  DO UPDATE SET
    period_end      = EXCLUDED.period_end,
    best_e1rm       = EXCLUDED.best_e1rm,
    best_e1rm_reps  = EXCLUDED.best_e1rm_reps,
    best_weight     = EXCLUDED.best_weight,
    best_reps       = EXCLUDED.best_reps,
    total_sets      = EXCLUDED.total_sets,
    working_sets    = EXCLUDED.working_sets,
    total_volume_kg = EXCLUDED.total_volume_kg,
    avg_rpe         = EXCLUDED.avg_rpe,
    avg_rest_seconds = EXCLUDED.avg_rest_seconds,
    training_days   = EXCLUDED.training_days,
    computed_at     = now();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

REVOKE EXECUTE ON FUNCTION compute_exercise_progress_snapshot(uuid, text, date) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION compute_exercise_progress_snapshot(uuid, text, date) FROM authenticated;
GRANT EXECUTE ON FUNCTION compute_exercise_progress_snapshot(uuid, text, date) TO service_role;

COMMENT ON FUNCTION compute_exercise_progress_snapshot IS
  'Computes and upserts exercise progress snapshots for a given user and period. '
  'Called by backend cron. Service role only.';


-- =============================================================================
-- 3. VIEW: equipment_usage_stats (replace with 7d window)
-- =============================================================================

-- Extend existing view with 7-day window per domain expert recommendation.
CREATE OR REPLACE VIEW equipment_usage_stats
WITH (security_invoker = true) AS
SELECT
  s.user_id,
  s.variant_id                                                     AS equipment_variant_id,
  s.exercise_id,
  COUNT(*) FILTER (WHERE s.logged_at >= NOW() - interval '7 days')  AS sets_7d,
  COUNT(*) FILTER (WHERE s.logged_at >= NOW() - interval '30 days') AS sets_30d,
  COUNT(*) FILTER (WHERE s.logged_at >= NOW() - interval '90 days') AS sets_90d,
  COUNT(*)                                                          AS sets_all_time,
  MAX(s.logged_at)                                                  AS last_used_at,
  RANK() OVER (
    PARTITION BY s.user_id
    ORDER BY COUNT(*) FILTER (WHERE s.logged_at >= NOW() - interval '7 days') DESC
  )                                                                 AS rank_7d,
  RANK() OVER (
    PARTITION BY s.user_id
    ORDER BY COUNT(*) FILTER (WHERE s.logged_at >= NOW() - interval '30 days') DESC
  )                                                                 AS rank_30d,
  RANK() OVER (
    PARTITION BY s.user_id
    ORDER BY COUNT(*) FILTER (WHERE s.logged_at >= NOW() - interval '90 days') DESC
  )                                                                 AS rank_90d
FROM sets s
WHERE s.variant_id IS NOT NULL
GROUP BY s.user_id, s.variant_id, s.exercise_id;

COMMENT ON VIEW equipment_usage_stats IS
  'Per-variant equipment usage stats with 7d/30d/90d/all-time windows and rankings. '
  'RLS via security_invoker.';

COMMIT;
