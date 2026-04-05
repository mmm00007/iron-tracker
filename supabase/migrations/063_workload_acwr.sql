-- Migration 063: Workload Monitoring & ACWR (Acute:Chronic Workload Ratio)
-- Per-user daily load snapshots with 7-day acute + 28-day chronic rolling
-- sums and computed ACWR. Used for overtraining risk detection and
-- autoregulation recommendations.
--
-- Framework: Gabbett/Hulin acute:chronic workload ratio (Gabbett 2016 BJSM).
-- ACWR of 0.8-1.3 = "sweet spot"; >1.5 = elevated injury risk.
--
-- Validated by: data-science-expert, sports-medicine-expert, database-specialist
--
-- Key design decisions:
--   - daily_load = session_rpe * session_duration_minutes (Foster 2001, sRPE)
--   - Generated columns for acwr_ratio and risk_zone (always in sync)
--   - No FK to workout_feedback — feedback is optional, cron handles missing days
--   - 4-week (28-day) chronic window aligns with Gabbett's original methodology
--   - risk_zone uses Hulin 2016 thresholds (0.8 / 1.3 / 1.5)
--   - Backend cron recomputes daily at 02:00 UTC for users with new sets
--
-- Citations:
--   - Gabbett T.J. (2016). Training-injury prevention paradox. Br J Sports Med.
--   - Hulin B.T. et al. (2016). ACWR and injury risk in rugby league. BJSM.
--   - Foster C. (2001). Session rating of perceived exertion. Med Sci Sports Exerc.
--   - Impellizzeri F.M. et al. (2020). Training load concepts overview.

BEGIN;

-- =============================================================================
-- 1. workload_metrics
-- =============================================================================

CREATE TABLE IF NOT EXISTS workload_metrics (
  id                        uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id                   uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  training_date             date        NOT NULL,
  daily_load                numeric(10,2) NOT NULL DEFAULT 0
                                        CHECK (daily_load >= 0),
  acute_7d_load             numeric(10,2) NOT NULL DEFAULT 0
                                        CHECK (acute_7d_load >= 0),
  chronic_28d_load          numeric(10,2) NOT NULL DEFAULT 0
                                        CHECK (chronic_28d_load >= 0),
  acute_sets_count          smallint    NOT NULL DEFAULT 0 CHECK (acute_sets_count >= 0),
  chronic_avg_weekly_sets   numeric(6,2) NOT NULL DEFAULT 0 CHECK (chronic_avg_weekly_sets >= 0),
  session_rpe               numeric(3,1) CHECK (session_rpe IS NULL OR (session_rpe >= 1 AND session_rpe <= 10)),
  session_duration_minutes  smallint    CHECK (session_duration_minutes IS NULL OR session_duration_minutes >= 0),
  -- Generated: acute/chronic ratio. NULL when chronic_28d_load is 0 (insufficient data).
  acwr_ratio                numeric(4,2) GENERATED ALWAYS AS (
    CASE
      WHEN chronic_28d_load > 0
      THEN ROUND((acute_7d_load / chronic_28d_load)::numeric, 2)
      ELSE NULL
    END
  ) STORED,
  -- Generated: risk zone classification per Hulin et al. 2016.
  risk_zone                 text        GENERATED ALWAYS AS (
    CASE
      WHEN chronic_28d_load = 0 THEN 'insufficient_data'
      WHEN (acute_7d_load / NULLIF(chronic_28d_load, 0)) < 0.8 THEN 'detraining'
      WHEN (acute_7d_load / NULLIF(chronic_28d_load, 0)) <= 1.3 THEN 'optimal'
      WHEN (acute_7d_load / NULLIF(chronic_28d_load, 0)) <= 1.5 THEN 'elevated'
      ELSE 'high_risk'
    END
  ) STORED,
  computation_version       smallint    NOT NULL DEFAULT 1,
  computed_at               timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, training_date)
);

COMMENT ON TABLE workload_metrics IS
  'Per-user daily workload with 7-day acute + 28-day chronic rolling sums and '
  'computed ACWR. Used for overtraining risk detection. Backend cron recomputes '
  'daily at 02:00 UTC for users with new sets since last run.';

COMMENT ON COLUMN workload_metrics.daily_load IS
  'Session-RPE * session-duration-minutes (Foster 2001). 0 on rest days.';

COMMENT ON COLUMN workload_metrics.acwr_ratio IS
  'Acute:Chronic Workload Ratio. 0.8-1.3 = optimal sweet spot; >1.5 = elevated injury risk.';

COMMENT ON COLUMN workload_metrics.risk_zone IS
  'Classification per Hulin 2016: detraining (<0.8), optimal (0.8-1.3), '
  'elevated (1.3-1.5), high_risk (>1.5). insufficient_data until 28d baseline.';

CREATE INDEX IF NOT EXISTS workload_metrics_user_date_idx
  ON workload_metrics (user_id, training_date DESC);

CREATE INDEX IF NOT EXISTS workload_metrics_user_risk_idx
  ON workload_metrics (user_id, risk_zone)
  WHERE risk_zone IN ('elevated', 'high_risk');

ALTER TABLE workload_metrics ENABLE ROW LEVEL SECURITY;

CREATE POLICY workload_metrics_select ON workload_metrics
  FOR SELECT TO authenticated USING (user_id = auth.uid());

CREATE POLICY workload_metrics_insert ON workload_metrics
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());

CREATE POLICY workload_metrics_update ON workload_metrics
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

CREATE POLICY workload_metrics_delete ON workload_metrics
  FOR DELETE TO authenticated USING (user_id = auth.uid());

-- =============================================================================
-- 2. workload_alerts (one-shot flag history)
-- =============================================================================
-- When a user crosses into high_risk, emit an alert and track whether it's
-- been dismissed. Prevents alert spam.

CREATE TABLE IF NOT EXISTS workload_alerts (
  id                   uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id              uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  triggered_on_date    date        NOT NULL,
  alert_type           text        NOT NULL
    CHECK (alert_type IN ('acwr_elevated','acwr_high_risk','deload_suggested','undertraining_warning','acute_spike')),
  severity             text        NOT NULL DEFAULT 'info'
    CHECK (severity IN ('info','warning','critical')),
  acwr_ratio           numeric(4,2),
  message              text        NOT NULL,
  dismissed_at         timestamptz,
  acknowledged_at      timestamptz,
  created_at           timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, triggered_on_date, alert_type)
);

COMMENT ON TABLE workload_alerts IS
  'Coaching alerts triggered by workload_metrics thresholds. Unique per user/date/type '
  'prevents duplicate alerts. Frontend surfaces via notification feed.';

CREATE INDEX IF NOT EXISTS workload_alerts_user_active_idx
  ON workload_alerts (user_id, triggered_on_date DESC)
  WHERE dismissed_at IS NULL;

ALTER TABLE workload_alerts ENABLE ROW LEVEL SECURITY;

CREATE POLICY workload_alerts_select ON workload_alerts
  FOR SELECT TO authenticated USING (user_id = auth.uid());

CREATE POLICY workload_alerts_insert ON workload_alerts
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());

CREATE POLICY workload_alerts_update ON workload_alerts
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

CREATE POLICY workload_alerts_delete ON workload_alerts
  FOR DELETE TO authenticated USING (user_id = auth.uid());

COMMIT;
