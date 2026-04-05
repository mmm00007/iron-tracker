-- Migration 098: Cron Job Registry + Analytics Index Audit
-- Documents all backend cron functions created across migrations 058-097
-- in a single reference table. The backend cron runner reads this table
-- to know what to call and when.
--
-- Also adds missing indexes identified during the analytics audit.

BEGIN;

-- =============================================================================
-- 1. cron_job_registry: what the backend should call
-- =============================================================================

CREATE TABLE IF NOT EXISTS cron_job_registry (
  id               serial      PRIMARY KEY,
  function_name    text        NOT NULL UNIQUE,
  cron_expression  text        NOT NULL,
  description      text        NOT NULL,
  function_args    text,
  depends_on       text[],
  introduced_in    text,
  is_enabled       boolean     NOT NULL DEFAULT true,
  last_run_at      timestamptz,
  last_run_rows    integer,
  last_error       text,
  display_order    smallint    NOT NULL DEFAULT 0
);

COMMENT ON TABLE cron_job_registry IS
  'Registry of backend cron functions with schedule, dependencies, and '
  'last-run tracking. Backend cron runner reads this at startup. Admins '
  'can disable jobs by setting is_enabled=false.';

ALTER TABLE cron_job_registry ENABLE ROW LEVEL SECURITY;

-- Service-role only (backend reads/writes this; no frontend access)
CREATE POLICY cron_job_registry_service ON cron_job_registry
  FOR ALL TO authenticated USING (false) WITH CHECK (false);

-- =============================================================================
-- 2. SEED: All compute functions from migrations 058-097
-- =============================================================================

INSERT INTO cron_job_registry
  (function_name, cron_expression, description, function_args, depends_on, introduced_in, display_order)
VALUES
  ('compute_workload_metrics_all_users',
   '0 2 * * *',
   'ACWR workload metrics: daily_load, 7d acute, 28d chronic, ACWR ratio + risk zone',
   '7',
   NULL,
   'migration 071',
   10),

  ('compute_muscle_fatigue_state_all_users',
   '15 2 * * *',
   'Per-muscle fatigue composite (volume 40%% + RPE 20%% + soreness 20%% + recency 20%%)',
   'CURRENT_DATE',
   ARRAY['compute_workload_metrics_all_users'],
   'migration 072',
   20),

  ('refresh_weekly_volume_snapshots_all_users',
   '30 2 * * *',
   'Materialize weekly activation-weighted volume per muscle into snapshot table',
   '4',
   NULL,
   'migration 078',
   30),

  ('detect_new_achievements',
   '45 2 * * *',
   'Check all active achievements vs user state, insert any new unlocks',
   'per-user loop',
   ARRAY['compute_workload_metrics_all_users', 'refresh_weekly_volume_snapshots_all_users'],
   'migration 083',
   40)
ON CONFLICT (function_name) DO NOTHING;

-- =============================================================================
-- 3. INDEX AUDIT: ensure analytics views have supporting indexes
-- =============================================================================

-- pr_events: support pr_momentum_summary view (achieved_at filtering)
CREATE INDEX IF NOT EXISTS pr_events_user_type_achieved_idx
  ON pr_events (user_id, record_type, achieved_at DESC)
  WHERE record_type = 'estimated_1rm';

-- workout_feedback: support sleep_performance views (sleep_hours not null)
CREATE INDEX IF NOT EXISTS workout_feedback_user_sleep_idx
  ON workout_feedback (user_id, training_date DESC)
  WHERE sleep_hours IS NOT NULL;

-- sets: support exercise_cooccurrence view (same-day self-join)
CREATE INDEX IF NOT EXISTS sets_user_date_exercise_idx
  ON sets (user_id, training_date, exercise_id)
  WHERE training_date IS NOT NULL AND set_type = 'working';

-- weekly_volume_snapshots: additional composite for trend queries
-- (note: partial index with CURRENT_DATE not possible — IMMUTABLE required.
-- The existing (user_id, muscle_group_id, week_start DESC) from 078 covers this.)
-- Skipped: partial index with CURRENT_DATE is not IMMUTABLE.

-- exercise_coaching_cues: support priority-sorted cue queries
CREATE INDEX IF NOT EXISTS exercise_coaching_cues_exercise_priority_idx
  ON exercise_coaching_cues (exercise_id, priority);

-- achievements: support achievement_forecasts cross-join
CREATE INDEX IF NOT EXISTS achievements_active_type_idx
  ON achievements (is_active, (criteria->>'type'))
  WHERE is_active = true;

COMMIT;
