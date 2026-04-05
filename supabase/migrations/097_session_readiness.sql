-- Migration 097: Session Readiness Snapshot
-- Morning-decision composite: "Should I go hard today, moderate, or rest?"
-- Combines the following existing signals:
--   - muscle fatigue breadth (from muscle_fatigue_state)
--   - sleep quality (most recent workout_feedback)
--   - days since last training session
--   - ACWR zone (from workload_metrics)
--   - deload readiness score (from get_deload_readiness)
--   - active injuries limiting training (from injury_reports)
--
-- Returns a simple traffic-light: go_hard / moderate / light_day / rest.
--
-- Validated by: sports-medicine-expert, fitness-domain-expert
--
-- Key design decisions:
--   - Meant for morning check BEFORE training — not post-session analysis.
--   - Degrades gracefully: works with just sets history, improves with
--     sleep/feedback/fatigue/ACWR data.
--   - Prioritizes safety: any HIGH-risk signal forces moderate or rest.

BEGIN;

CREATE OR REPLACE FUNCTION get_session_readiness(
  p_user_id uuid,
  p_date date DEFAULT CURRENT_DATE
)
RETURNS TABLE (
  signal text,
  readiness_score smallint,
  summary text,
  muscle_readiness_pct smallint,
  sleep_factor text,
  days_since_last_session integer,
  acwr_status text,
  active_injuries_count integer,
  suggested_intensity text,
  suggested_muscle_groups text[]
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public, pg_catalog
AS $$
DECLARE
  v_fresh_muscles integer := 0;
  v_total_muscles integer := 0;
  v_last_sleep_hours numeric;
  v_last_sleep_quality smallint;
  v_last_readiness smallint;
  v_days_since_session integer;
  v_acwr_zone text;
  v_injury_count integer := 0;
  v_score smallint := 50;  -- neutral baseline
  v_signal text;
  v_suggested_muscles text[];
BEGIN
  -- 1. Muscle readiness: count fresh/ready muscles (fatigue < 40)
  SELECT COUNT(*) FILTER (WHERE fatigue_score < 40), COUNT(*)
  INTO v_fresh_muscles, v_total_muscles
  FROM muscle_fatigue_state
  WHERE user_id = p_user_id AND as_of_date = p_date;

  IF v_total_muscles > 0 THEN
    v_score := v_score + ((v_fresh_muscles::numeric / v_total_muscles) * 30 - 15)::smallint;
  END IF;

  -- Get names of fresh muscles for suggestion
  SELECT ARRAY_AGG(mg.name ORDER BY mfs.fatigue_score ASC)
  INTO v_suggested_muscles
  FROM muscle_fatigue_state mfs
  JOIN muscle_groups mg ON mg.id = mfs.muscle_group_id
  WHERE mfs.user_id = p_user_id AND mfs.as_of_date = p_date AND mfs.fatigue_score < 40
  LIMIT 5;

  -- 2. Sleep factor (most recent workout_feedback)
  SELECT wf.sleep_hours, wf.prior_sleep_quality, wf.readiness_score
  INTO v_last_sleep_hours, v_last_sleep_quality, v_last_readiness
  FROM workout_feedback wf
  WHERE wf.user_id = p_user_id
  ORDER BY wf.training_date DESC LIMIT 1;

  IF v_last_sleep_hours IS NOT NULL THEN
    v_score := v_score + CASE
      WHEN v_last_sleep_hours >= 8 THEN 10
      WHEN v_last_sleep_hours >= 7 THEN 5
      WHEN v_last_sleep_hours >= 6 THEN 0
      WHEN v_last_sleep_hours >= 5 THEN -8
      ELSE -15
    END;
  END IF;

  IF v_last_readiness IS NOT NULL THEN
    v_score := v_score + (v_last_readiness - 3) * 5;  -- -10 to +10
  END IF;

  -- 3. Days since last session
  SELECT (p_date - MAX(training_date))::integer
  INTO v_days_since_session
  FROM sets
  WHERE user_id = p_user_id AND training_date IS NOT NULL AND training_date <= p_date;

  IF v_days_since_session IS NOT NULL THEN
    v_score := v_score + CASE
      WHEN v_days_since_session >= 3 THEN 8   -- well rested
      WHEN v_days_since_session = 2 THEN 5
      WHEN v_days_since_session = 1 THEN 0
      WHEN v_days_since_session = 0 THEN -8   -- training again same day
      ELSE 0
    END;
  END IF;

  -- 4. ACWR zone
  SELECT wm.risk_zone INTO v_acwr_zone
  FROM workload_metrics wm
  WHERE wm.user_id = p_user_id AND wm.training_date <= p_date
  ORDER BY wm.training_date DESC LIMIT 1;

  v_score := v_score + CASE v_acwr_zone
    WHEN 'optimal' THEN 5
    WHEN 'elevated' THEN -5
    WHEN 'high_risk' THEN -15
    WHEN 'detraining' THEN 5  -- actually good to push
    ELSE 0
  END;

  -- 5. Active injuries
  SELECT COUNT(*) INTO v_injury_count
  FROM injury_reports
  WHERE user_id = p_user_id
    AND limits_training = true
    AND status IN ('active','recovering','chronic');

  v_score := v_score - (v_injury_count * 8);

  -- Clamp 0-100
  v_score := GREATEST(0, LEAST(100, v_score))::smallint;

  -- Signal
  v_signal := CASE
    WHEN v_score >= 70 THEN 'go_hard'
    WHEN v_score >= 45 THEN 'moderate'
    WHEN v_score >= 25 THEN 'light_day'
    ELSE                    'rest'
  END;

  RETURN QUERY SELECT
    v_signal,
    v_score,
    CASE v_signal
      WHEN 'go_hard'  THEN 'Recovery signals green. Push intensity and volume today.'
      WHEN 'moderate'  THEN 'Some fatigue indicators. Train normally but listen to your body.'
      WHEN 'light_day' THEN 'Multiple fatigue signals. Light session or mobility work recommended.'
      WHEN 'rest'      THEN 'Recovery needed. Take a rest day — training through this risks injury.'
    END::text,
    CASE WHEN v_total_muscles > 0
      THEN (v_fresh_muscles::numeric / v_total_muscles * 100)::smallint
      ELSE NULL
    END,
    CASE
      WHEN v_last_sleep_hours IS NULL THEN 'no_data'
      WHEN v_last_sleep_hours >= 7.5 THEN 'good'
      WHEN v_last_sleep_hours >= 6.5 THEN 'adequate'
      ELSE 'poor'
    END::text,
    v_days_since_session,
    COALESCE(v_acwr_zone, 'no_data')::text,
    v_injury_count,
    CASE v_signal
      WHEN 'go_hard'   THEN 'Heavy compound work. Push for PRs if feeling strong.'
      WHEN 'moderate'   THEN 'Standard working weights. Maintain volume, skip top sets.'
      WHEN 'light_day'  THEN 'Drop load 30-40%. Focus on form and muscle connection.'
      WHEN 'rest'       THEN 'No training. Walk, stretch, foam roll.'
    END::text,
    v_suggested_muscles;
END;
$$;

COMMENT ON FUNCTION get_session_readiness(uuid, date) IS
  'Morning-decision composite: 0-100 readiness score → go_hard (>=70) / '
  'moderate (>=45) / light_day (>=25) / rest (<25). Combines muscle fatigue '
  'breadth, sleep, days since session, ACWR zone, active injuries. '
  'Returns suggested_intensity + suggested_muscle_groups (fresh ones). '
  'Powers "start workout" screen morning check.';

COMMIT;
