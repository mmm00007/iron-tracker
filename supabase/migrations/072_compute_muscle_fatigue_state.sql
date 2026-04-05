-- Migration 072: compute_muscle_fatigue_state() function
-- Backend cron function that populates muscle_fatigue_state for a user
-- across a date range. Computes per-muscle composite fatigue score from
-- 4 components (volume 40%, RPE 20%, soreness 20%, recency 20%).
--
-- Algorithm (per user × muscle × as_of_date):
--   effective_sets_72h = SUM(activation_percent/100) over working sets
--                        targeting this muscle in last 72h
--   peak_rpe_72h       = MAX(rpe) over those sets
--   avg_soreness_72h   = AVG(severity) from soreness_reports last 72h
--   days_since         = MIN days since last set targeting this muscle
--
--   volume_component   = min(100, effective_sets_72h / MEV * 100)
--   rpe_component      = (peak_rpe_72h / 10) * 100
--   soreness_component = (avg_soreness_72h / 4) * 100
--   recency_component  = max(0, 100 - days_since * 25)
--
--   fatigue_score = 0.40*vol + 0.20*rpe + 0.20*sore + 0.20*recency
--
-- Intended caller: backend cron at 02:30 UTC daily.
-- Validated by: data-science-expert, sports-medicine-expert
--
-- Citations:
--   - Pelland J.C. et al. (2024). Volume-load quantification. Sports Medicine.
--   - Zaffagnini S. et al. (2015). DOMS timeline (24-72h peak). J Sports Med.
--   - Damas F. et al. (2018). Protein synthesis vs soreness dissociation.

BEGIN;

-- =============================================================================
-- compute_muscle_fatigue_state(user_id, as_of_date)
-- =============================================================================
-- Computes one fatigue snapshot per muscle for a user on a specific date.
-- Uses 72-hour lookback window. Falls back to sensible defaults when
-- volume_landmarks not seeded for the user.

CREATE OR REPLACE FUNCTION compute_muscle_fatigue_state(
  p_user_id uuid,
  p_as_of_date date DEFAULT CURRENT_DATE
)
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_catalog
AS $$
DECLARE
  v_rows_written integer := 0;
  v_user_goal text;
  v_window_start timestamptz;
  v_window_end timestamptz;
BEGIN
  -- Convert date range to tz-aware timestamps (full 72h lookback)
  v_window_end := (p_as_of_date + interval '1 day')::timestamptz;
  v_window_start := v_window_end - interval '72 hours';

  -- Look up user's primary goal for landmark lookup
  SELECT primary_goal INTO v_user_goal FROM profiles WHERE id = p_user_id;
  v_user_goal := COALESCE(v_user_goal, 'general');

  WITH muscle_volume_72h AS (
    -- Activation-weighted effective sets per muscle in last 72h
    SELECT
      em.muscle_group_id,
      SUM(
        COALESCE(em.activation_percent, CASE WHEN em.is_primary THEN 100 ELSE 50 END)::numeric / 100
      ) AS effective_sets,
      MAX(s.rpe) AS peak_rpe,
      MAX(s.training_date) AS last_trained_date
    FROM sets s
    JOIN exercise_muscles em ON em.exercise_id = s.exercise_id
    WHERE s.user_id = p_user_id
      AND s.logged_at >= v_window_start
      AND s.logged_at < v_window_end
      AND s.set_type = 'working'
      AND s.reps > 0
    GROUP BY em.muscle_group_id
  ),
  muscle_soreness_72h AS (
    SELECT
      muscle_group_id,
      AVG(severity)::numeric(3,1) AS avg_severity
    FROM soreness_reports
    WHERE user_id = p_user_id
      AND reported_at >= v_window_start
      AND reported_at < v_window_end
    GROUP BY muscle_group_id
  ),
  landmarks AS (
    SELECT muscle_group_id, mev_sets_per_week, mav_sets_per_week
    FROM volume_landmarks
    WHERE user_id = p_user_id AND training_goal = v_user_goal
  ),
  last_trained_any AS (
    -- For muscles NOT in 72h window: find most recent training date
    SELECT
      em.muscle_group_id,
      MAX(s.training_date) AS last_trained_date
    FROM sets s
    JOIN exercise_muscles em ON em.exercise_id = s.exercise_id
    WHERE s.user_id = p_user_id
      AND s.set_type = 'working'
      AND s.training_date <= p_as_of_date
    GROUP BY em.muscle_group_id
  ),
  combined AS (
    SELECT
      mg.id                                        AS muscle_group_id,
      COALESCE(mv.effective_sets, 0)               AS effective_sets,
      mv.peak_rpe,
      ms.avg_severity                              AS avg_soreness,
      COALESCE(
        (p_as_of_date - COALESCE(mv.last_trained_date, lta.last_trained_date))::integer,
        999  -- never trained
      )                                            AS days_since_trained,
      -- MEV for volume normalization (fallback: 8 sets/week = ~3.4/72h)
      COALESCE(l.mev_sets_per_week, 8)             AS mev_weekly,
      COALESCE(mv.last_trained_date, lta.last_trained_date) AS resolved_last_trained
    FROM muscle_groups mg
    LEFT JOIN muscle_volume_72h mv  ON mv.muscle_group_id = mg.id
    LEFT JOIN muscle_soreness_72h ms ON ms.muscle_group_id = mg.id
    LEFT JOIN landmarks l            ON l.muscle_group_id = mg.id
    LEFT JOIN last_trained_any lta   ON lta.muscle_group_id = mg.id
  ),
  components AS (
    SELECT
      muscle_group_id,
      effective_sets,
      peak_rpe,
      avg_soreness,
      days_since_trained,
      -- Volume component: MEV is weekly; 72h is ~3/7 of a week.
      -- Scale MEV to 72h window: MEV_72h = MEV * 3/7
      -- Volume at or above MEV_72h = 100; linear scale below.
      LEAST(100, GREATEST(0,
        (effective_sets / NULLIF(mev_weekly * 3.0/7.0, 0)) * 100
      ))::numeric(4,1) AS volume_component,
      -- RPE component: peak_rpe / 10 * 100 (6=60, 8=80, 10=100)
      COALESCE((peak_rpe / 10.0 * 100)::numeric(4,1), 0::numeric(4,1)) AS rpe_component,
      -- Soreness component: 0-4 scale mapped to 0-100
      COALESCE((avg_soreness / 4.0 * 100)::numeric(4,1), 0::numeric(4,1)) AS soreness_component,
      -- Recency: 100 today, -25/day, floor 0. Never trained = 0.
      GREATEST(0, 100 - (days_since_trained * 25))::numeric(4,1) AS recency_component
    FROM combined
  ),
  scored AS (
    SELECT
      muscle_group_id, effective_sets, peak_rpe, avg_soreness, days_since_trained,
      volume_component, rpe_component, soreness_component, recency_component,
      ROUND(
        (0.40 * volume_component
         + 0.20 * rpe_component
         + 0.20 * soreness_component
         + 0.20 * recency_component)::numeric,
        1
      ) AS fatigue_score,
      CASE
        WHEN days_since_trained = 999 AND avg_soreness IS NULL THEN 'no_data'
        ELSE NULL
      END AS no_data_flag
    FROM components
  )
  INSERT INTO muscle_fatigue_state (
    user_id, muscle_group_id, as_of_date,
    fatigue_score, volume_component, rpe_component, soreness_component, recency_component,
    effective_sets_last_72h, peak_rpe_last_72h, avg_soreness_last_72h, days_since_last_trained,
    recovery_status,
    computation_version, computed_at
  )
  SELECT
    p_user_id, s.muscle_group_id, p_as_of_date,
    s.fatigue_score, s.volume_component, s.rpe_component, s.soreness_component, s.recency_component,
    s.effective_sets, s.peak_rpe, s.avg_soreness,
    NULLIF(s.days_since_trained, 999),
    CASE
      WHEN s.no_data_flag = 'no_data'   THEN 'no_data'
      WHEN s.fatigue_score < 20          THEN 'fresh'
      WHEN s.fatigue_score < 40          THEN 'ready'
      WHEN s.fatigue_score < 60          THEN 'recovering'
      WHEN s.fatigue_score < 80          THEN 'fatigued'
      ELSE                                    'overreaching'
    END,
    1, now()
  FROM scored s
  ON CONFLICT (user_id, muscle_group_id, as_of_date) DO UPDATE SET
    fatigue_score = EXCLUDED.fatigue_score,
    volume_component = EXCLUDED.volume_component,
    rpe_component = EXCLUDED.rpe_component,
    soreness_component = EXCLUDED.soreness_component,
    recency_component = EXCLUDED.recency_component,
    effective_sets_last_72h = EXCLUDED.effective_sets_last_72h,
    peak_rpe_last_72h = EXCLUDED.peak_rpe_last_72h,
    avg_soreness_last_72h = EXCLUDED.avg_soreness_last_72h,
    days_since_last_trained = EXCLUDED.days_since_last_trained,
    recovery_status = EXCLUDED.recovery_status,
    computation_version = EXCLUDED.computation_version,
    computed_at = now();

  GET DIAGNOSTICS v_rows_written = ROW_COUNT;
  RETURN v_rows_written;
END;
$$;

COMMENT ON FUNCTION compute_muscle_fatigue_state(uuid, date) IS
  'Populates muscle_fatigue_state for a user on a specific date. Computes '
  '72-hour lookback composite fatigue score (volume 40%% + RPE 20%% + '
  'soreness 20%% + recency 20%%) per muscle group. Idempotent via UPSERT.';

-- =============================================================================
-- compute_muscle_fatigue_state_all_users(as_of_date)
-- =============================================================================
-- Batch wrapper for daily cron.

CREATE OR REPLACE FUNCTION compute_muscle_fatigue_state_all_users(
  p_as_of_date date DEFAULT CURRENT_DATE
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
  -- Only users with sets in last 14 days (anyone else is inactive)
  FOR v_user IN
    SELECT DISTINCT user_id
    FROM sets
    WHERE training_date >= p_as_of_date - interval '14 days'
      AND training_date <= p_as_of_date
  LOOP
    v_user_rows := compute_muscle_fatigue_state(v_user.user_id, p_as_of_date);
    v_total_rows := v_total_rows + v_user_rows;
  END LOOP;

  RETURN v_total_rows;
END;
$$;

COMMENT ON FUNCTION compute_muscle_fatigue_state_all_users(date) IS
  'Batch wrapper: compute fatigue snapshots for all active users. '
  'Intended for daily cron at 02:30 UTC.';

COMMIT;
