-- Migration 071: compute_workload_metrics() function
-- Backend cron function that populates workload_metrics for a user across a
-- date range. Derives daily_load using Foster 2001 session-RPE methodology:
--   daily_load = session_rpe * session_duration_minutes
--
-- If workout_feedback.session_rpe is missing, falls back to avg(rpe) over
-- working sets for that training_date. Session duration derived from sets
-- (max logged_at - min logged_at on that training_date). Returns the number
-- of rows upserted.
--
-- Intended caller: backend cron at 02:00 UTC daily, one call per user with
-- new sets since last run. Also called on-demand after session completion.
--
-- Validated by: data-science-expert, database-specialist
--
-- Citations:
--   - Foster C. (2001). Monitoring training in athletes. MSSE.
--   - Gabbett T.J. (2016). Training-injury prevention paradox. BJSM.
--   - Hulin B.T. et al. (2016). ACWR thresholds. BJSM.

BEGIN;

-- =============================================================================
-- compute_workload_metrics(user_id, start_date, end_date)
-- =============================================================================
-- Populates workload_metrics for every date in [start_date, end_date] for
-- the user. Idempotent via UPSERT on (user_id, training_date).

CREATE OR REPLACE FUNCTION compute_workload_metrics(
  p_user_id uuid,
  p_start_date date,
  p_end_date date
)
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_catalog
AS $$
DECLARE
  v_rows_written integer := 0;
BEGIN
  IF p_start_date > p_end_date THEN
    RAISE EXCEPTION 'start_date % must be <= end_date %', p_start_date, p_end_date;
  END IF;

  -- Generate a date series covering the requested range, compute load per day,
  -- then apply rolling 7d acute + 28d chronic windows via window functions.
  WITH date_series AS (
    SELECT d::date AS training_date
    FROM generate_series(p_start_date, p_end_date, interval '1 day') d
  ),
  per_day_stats AS (
    SELECT
      s.training_date,
      COUNT(*) FILTER (WHERE s.set_type = 'working') AS working_set_count,
      AVG(s.rpe) FILTER (WHERE s.rpe IS NOT NULL AND s.set_type = 'working') AS avg_working_rpe,
      -- Session duration in minutes: from first to last logged set on that date
      EXTRACT(epoch FROM (MAX(s.logged_at) - MIN(s.logged_at))) / 60.0 AS session_duration_min
    FROM sets s
    WHERE s.user_id = p_user_id
      AND s.training_date BETWEEN p_start_date - interval '28 days' AND p_end_date
    GROUP BY s.training_date
  ),
  daily_loads AS (
    SELECT
      ds.training_date,
      COALESCE(wf.session_rpe, pds.avg_working_rpe) AS effective_rpe,
      COALESCE(pds.session_duration_min, 0)::integer AS duration_min,
      COALESCE(pds.working_set_count, 0) AS sets_count,
      -- Foster sRPE: load = RPE × duration (0 on rest days)
      COALESCE(
        ROUND(
          (COALESCE(wf.session_rpe, pds.avg_working_rpe)
           * COALESCE(pds.session_duration_min, 0))::numeric, 2
        ),
        0
      ) AS daily_load,
      wf.session_rpe AS feedback_session_rpe
    FROM date_series ds
    LEFT JOIN per_day_stats pds ON pds.training_date = ds.training_date
    LEFT JOIN workout_feedback wf
      ON wf.user_id = p_user_id AND wf.training_date = ds.training_date
  ),
  -- Include lookback data for rolling-window computation (outside the upsert range)
  lookback_loads AS (
    SELECT
      d::date AS training_date,
      COALESCE(
        ROUND(
          (COALESCE(wf.session_rpe,
                    (SELECT AVG(s.rpe) FROM sets s
                     WHERE s.user_id = p_user_id AND s.training_date = d::date
                       AND s.set_type = 'working' AND s.rpe IS NOT NULL))
           * COALESCE(
               EXTRACT(epoch FROM (
                 (SELECT MAX(s.logged_at) - MIN(s.logged_at) FROM sets s
                  WHERE s.user_id = p_user_id AND s.training_date = d::date)
               )) / 60.0,
               0
             )
          )::numeric, 2
        ),
        0
      ) AS daily_load
    FROM generate_series(p_start_date - interval '28 days', p_start_date - interval '1 day', interval '1 day') d
    LEFT JOIN workout_feedback wf
      ON wf.user_id = p_user_id AND wf.training_date = d::date
  ),
  all_loads AS (
    SELECT training_date, daily_load, NULL::smallint AS feedback_session_rpe, NULL::integer AS duration_min, NULL::integer AS sets_count FROM lookback_loads
    UNION ALL
    SELECT training_date, daily_load, feedback_session_rpe, duration_min, sets_count FROM daily_loads
  ),
  windowed AS (
    SELECT
      training_date,
      daily_load,
      feedback_session_rpe,
      duration_min,
      sets_count,
      -- 7-day acute load sum (inclusive of current day, prior 6 days)
      SUM(daily_load) OVER (
        ORDER BY training_date
        RANGE BETWEEN INTERVAL '6 days' PRECEDING AND CURRENT ROW
      ) AS acute_7d_load,
      -- 28-day chronic load sum (inclusive of current day, prior 27 days)
      SUM(daily_load) OVER (
        ORDER BY training_date
        RANGE BETWEEN INTERVAL '27 days' PRECEDING AND CURRENT ROW
      ) AS chronic_28d_load,
      -- Sets count for acute window
      SUM(COALESCE(sets_count, 0)) OVER (
        ORDER BY training_date
        RANGE BETWEEN INTERVAL '6 days' PRECEDING AND CURRENT ROW
      ) AS acute_sets,
      -- Chronic weekly average sets
      SUM(COALESCE(sets_count, 0)) OVER (
        ORDER BY training_date
        RANGE BETWEEN INTERVAL '27 days' PRECEDING AND CURRENT ROW
      ) / 4.0 AS chronic_weekly_sets_avg
    FROM all_loads
  )
  INSERT INTO workload_metrics (
    user_id, training_date, daily_load,
    acute_7d_load, chronic_28d_load,
    acute_sets_count, chronic_avg_weekly_sets,
    session_rpe, session_duration_minutes,
    computed_at
  )
  SELECT
    p_user_id, w.training_date, w.daily_load,
    w.acute_7d_load, w.chronic_28d_load,
    COALESCE(w.acute_sets, 0)::smallint,
    ROUND(w.chronic_weekly_sets_avg::numeric, 2),
    w.feedback_session_rpe,
    w.duration_min,
    now()
  FROM windowed w
  WHERE w.training_date >= p_start_date  -- only upsert the requested range
  ON CONFLICT (user_id, training_date) DO UPDATE SET
    daily_load = EXCLUDED.daily_load,
    acute_7d_load = EXCLUDED.acute_7d_load,
    chronic_28d_load = EXCLUDED.chronic_28d_load,
    acute_sets_count = EXCLUDED.acute_sets_count,
    chronic_avg_weekly_sets = EXCLUDED.chronic_avg_weekly_sets,
    session_rpe = EXCLUDED.session_rpe,
    session_duration_minutes = EXCLUDED.session_duration_minutes,
    computed_at = now();

  GET DIAGNOSTICS v_rows_written = ROW_COUNT;
  RETURN v_rows_written;
END;
$$;

COMMENT ON FUNCTION compute_workload_metrics(uuid, date, date) IS
  'Populates workload_metrics for a user across [start_date, end_date]. '
  'Uses Foster sRPE × duration for daily_load, then computes 7d acute + 28d '
  'chronic rolling sums. Includes 28-day lookback for correct chronic values '
  'at range start. Idempotent via UPSERT.';

-- =============================================================================
-- compute_workload_metrics_recent(user_id, days_back)
-- =============================================================================
-- Convenience wrapper: recompute last N days (default 7) for a user.
-- This is the typical backend cron call pattern.

CREATE OR REPLACE FUNCTION compute_workload_metrics_recent(
  p_user_id uuid,
  p_days_back integer DEFAULT 7
)
RETURNS integer
LANGUAGE sql
SECURITY DEFINER
SET search_path = public, pg_catalog
AS $$
  SELECT compute_workload_metrics(
    p_user_id,
    (CURRENT_DATE - (p_days_back - 1))::date,
    CURRENT_DATE
  );
$$;

COMMENT ON FUNCTION compute_workload_metrics_recent(uuid, integer) IS
  'Convenience wrapper: recompute workload_metrics for last N days (default 7). '
  'Call from backend cron after any set insertion to refresh ACWR.';

-- =============================================================================
-- compute_workload_metrics_all_users(days_back)
-- =============================================================================
-- Batch wrapper for daily cron: recompute last N days for all users with
-- activity in that window.

CREATE OR REPLACE FUNCTION compute_workload_metrics_all_users(
  p_days_back integer DEFAULT 7
)
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_catalog
AS $$
DECLARE
  v_total_rows integer := 0;
  v_user_rows integer;
  v_user record;
BEGIN
  FOR v_user IN
    SELECT DISTINCT user_id
    FROM sets
    WHERE training_date >= CURRENT_DATE - (p_days_back - 1)
  LOOP
    v_user_rows := compute_workload_metrics_recent(v_user.user_id, p_days_back);
    v_total_rows := v_total_rows + v_user_rows;
  END LOOP;

  RETURN v_total_rows;
END;
$$;

COMMENT ON FUNCTION compute_workload_metrics_all_users(integer) IS
  'Batch wrapper: recompute workload_metrics for all users with sets in last N days. '
  'Intended for daily cron job at 02:00 UTC.';

COMMIT;
