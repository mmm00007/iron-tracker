-- Migration 084: Deload Readiness Composite Score
-- Unified "should I deload?" analysis combining 5 signals into a single score.
-- Helps users time deloads correctly — a common source of plateau and injury
-- when done late, or lost progress when done too early.
--
-- Validated by: data-science-expert, fitness-domain-expert, sports-medicine-expert
--
-- Composite signals (each contributes 0-20 points to a 0-100 total):
--   1. ACWR risk zone (from workload_metrics)
--      optimal=0, elevated=10, high_risk=20
--   2. Monotony zone (from training_monotony_strain)
--      low=0, moderate=8, high=15
--   3. Muscle fatigue breadth (from muscle_fatigue_state)
--      count of muscles with fatigue >=60 → capped contribution
--   4. PR stagnation (from pr_events)
--      weeks since most recent PR: 0-5→0, 6-8→8, 9+→15
--   5. Consecutive weeks without deload (from training_phases)
--      0-4→0, 5-6→8, 7+→20
--
-- Verdict bands:
--   <25  = keep_training (not ready)
--   25-50 = consider_deload (watching)
--   50-75 = recommended (clear signals)
--   >=75  = strongly_recommended (multiple red flags)
--
-- Citations:
--   - Israetel M. et al. (2021). Scientific Principles — deload triggers.
--   - Helms E. et al. (2019). Muscle and Strength Pyramid — deload timing.
--   - Coakley S.L., Passfield L. (2018). Training tapers. Int J Sports Physiol Perf.

BEGIN;

-- =============================================================================
-- get_deload_readiness(user_id, as_of_date)
-- =============================================================================

CREATE OR REPLACE FUNCTION get_deload_readiness(
  p_user_id uuid,
  p_as_of_date date DEFAULT CURRENT_DATE
)
RETURNS TABLE (
  score smallint,
  verdict text,
  acwr_contribution smallint,
  monotony_contribution smallint,
  fatigue_contribution smallint,
  stagnation_contribution smallint,
  phase_duration_contribution smallint,
  signals jsonb,
  recommendation text
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public, pg_catalog
AS $$
DECLARE
  v_acwr_zone text;
  v_acwr_ratio numeric;
  v_monotony_zone text;
  v_monotony numeric;
  v_fatigued_muscles integer;
  v_avg_fatigue numeric;
  v_weeks_since_pr integer;
  v_weeks_in_phase integer;
  v_phase_type text;
  v_last_deload_date date;
  v_acwr_contrib smallint := 0;
  v_monotony_contrib smallint := 0;
  v_fatigue_contrib smallint := 0;
  v_stagnation_contrib smallint := 0;
  v_phase_contrib smallint := 0;
  v_score smallint := 0;
BEGIN
  -- 1. ACWR signal (latest workload_metrics)
  SELECT wm.risk_zone, wm.acwr_ratio INTO v_acwr_zone, v_acwr_ratio
  FROM workload_metrics wm
  WHERE wm.user_id = p_user_id AND wm.training_date <= p_as_of_date
  ORDER BY wm.training_date DESC LIMIT 1;

  v_acwr_contrib := CASE v_acwr_zone
    WHEN 'high_risk' THEN 20
    WHEN 'elevated'  THEN 12
    WHEN 'optimal'   THEN 0
    WHEN 'detraining' THEN -5  -- deload wouldn't help; pushes score down
    ELSE 0
  END;

  -- 2. Monotony signal
  SELECT tms.monotony_zone, tms.monotony INTO v_monotony_zone, v_monotony
  FROM training_monotony_strain tms
  WHERE tms.user_id = p_user_id AND tms.training_date <= p_as_of_date
  ORDER BY tms.training_date DESC LIMIT 1;

  v_monotony_contrib := CASE v_monotony_zone
    WHEN 'high_monotony'     THEN 15
    WHEN 'moderate_monotony' THEN 8
    ELSE 0
  END;

  -- 3. Muscle fatigue breadth (how many muscles are fatigued today)
  SELECT
    COUNT(*) FILTER (WHERE mfs.fatigue_score >= 60),
    AVG(mfs.fatigue_score)
  INTO v_fatigued_muscles, v_avg_fatigue
  FROM muscle_fatigue_state mfs
  WHERE mfs.user_id = p_user_id AND mfs.as_of_date = p_as_of_date;

  -- 4 fatigued = 10 points, 8+ = 20 points
  v_fatigue_contrib := CASE
    WHEN v_fatigued_muscles >= 8 THEN 20
    WHEN v_fatigued_muscles >= 5 THEN 15
    WHEN v_fatigued_muscles >= 3 THEN 10
    WHEN v_fatigued_muscles >= 1 THEN 5
    ELSE 0
  END::smallint;

  -- 4. PR stagnation (weeks since most recent PR in last 90 days)
  SELECT
    COALESCE((p_as_of_date - MAX(pe.achieved_at::date)) / 7, 999)
  INTO v_weeks_since_pr
  FROM pr_events pe
  WHERE pe.user_id = p_user_id
    AND pe.achieved_at <= p_as_of_date + interval '1 day';

  v_stagnation_contrib := CASE
    WHEN v_weeks_since_pr >= 12 THEN 20
    WHEN v_weeks_since_pr >= 8  THEN 15
    WHEN v_weeks_since_pr >= 6  THEN 10
    WHEN v_weeks_since_pr >= 4  THEN 5
    ELSE 0
  END::smallint;

  -- 5. Consecutive weeks without deload (from training_phases)
  SELECT
    tp.phase_type,
    GREATEST(0, (p_as_of_date - tp.start_date) / 7)
  INTO v_phase_type, v_weeks_in_phase
  FROM training_phases tp
  WHERE tp.user_id = p_user_id
    AND tp.start_date <= p_as_of_date
    AND (tp.end_date IS NULL OR tp.end_date >= p_as_of_date)
  ORDER BY tp.start_date DESC LIMIT 1;

  -- Find most recent deload phase
  SELECT MAX(tp.start_date) INTO v_last_deload_date
  FROM training_phases tp
  WHERE tp.user_id = p_user_id
    AND tp.phase_type = 'deload'
    AND tp.start_date <= p_as_of_date;

  -- Phase duration contribution: if user hasn't deloaded recently, push toward deload
  v_phase_contrib := CASE
    WHEN v_phase_type = 'deload' THEN 0  -- already deloading
    WHEN v_last_deload_date IS NULL AND v_weeks_in_phase >= 8 THEN 20  -- never deloaded + long phase
    WHEN v_last_deload_date IS NULL THEN 10  -- never deloaded
    WHEN (p_as_of_date - v_last_deload_date) / 7 >= 10 THEN 20  -- 10+ weeks since deload
    WHEN (p_as_of_date - v_last_deload_date) / 7 >= 7 THEN 12
    WHEN (p_as_of_date - v_last_deload_date) / 7 >= 5 THEN 5
    ELSE 0
  END::smallint;

  -- Compute total score (clamped 0-100)
  v_score := GREATEST(0, LEAST(100,
    v_acwr_contrib + v_monotony_contrib + v_fatigue_contrib +
    v_stagnation_contrib + v_phase_contrib
  ))::smallint;

  RETURN QUERY SELECT
    v_score,
    CASE
      WHEN v_phase_type = 'deload'         THEN 'already_deloading'
      WHEN v_score >= 75                    THEN 'strongly_recommended'
      WHEN v_score >= 50                    THEN 'recommended'
      WHEN v_score >= 25                    THEN 'consider_deload'
      ELSE                                       'keep_training'
    END::text,
    v_acwr_contrib,
    v_monotony_contrib,
    v_fatigue_contrib,
    v_stagnation_contrib,
    v_phase_contrib,
    jsonb_build_object(
      'acwr_zone', v_acwr_zone,
      'acwr_ratio', v_acwr_ratio,
      'monotony_zone', v_monotony_zone,
      'monotony', v_monotony,
      'fatigued_muscles_count', v_fatigued_muscles,
      'avg_fatigue_score', ROUND(COALESCE(v_avg_fatigue, 0)::numeric, 1),
      'weeks_since_last_pr', CASE WHEN v_weeks_since_pr = 999 THEN NULL ELSE v_weeks_since_pr END,
      'active_phase_type', v_phase_type,
      'weeks_in_current_phase', v_weeks_in_phase,
      'weeks_since_last_deload',
        CASE WHEN v_last_deload_date IS NULL THEN NULL
             ELSE (p_as_of_date - v_last_deload_date) / 7
        END
    ),
    CASE
      WHEN v_phase_type = 'deload' THEN
        'You''re already deloading. Stick with the plan.'
      WHEN v_score >= 75 THEN
        'Multiple fatigue signals elevated. Deload this week — drop volume 40-50%%, reduce intensity.'
      WHEN v_score >= 50 THEN
        'Cumulative fatigue indicators accumulating. Schedule a deload in the next 1-2 weeks.'
      WHEN v_score >= 25 THEN
        'Some fatigue markers elevated. Monitor recovery; consider deload in 2-4 weeks.'
      ELSE
        'Recovery signals clear. Keep training, push volume if adaptation is flat.'
    END::text;
END;
$$;

COMMENT ON FUNCTION get_deload_readiness(uuid, date) IS
  'Returns composite 0-100 deload readiness score + verdict + signal breakdown. '
  'Combines ACWR zone, monotony zone, muscle fatigue breadth, PR stagnation, '
  'and weeks-since-last-deload into a single unified "should I deload?" answer. '
  'Verdict bands: keep_training (<25), consider (25-50), recommended (50-75), '
  'strongly_recommended (>=75), already_deloading (if phase = deload).';

-- =============================================================================
-- Helper view: deload_history (easy query of user's deload pattern)
-- =============================================================================

CREATE OR REPLACE VIEW deload_history
WITH (security_invoker = true) AS
SELECT
  tp.user_id,
  tp.id AS phase_id,
  tp.name AS phase_name,
  tp.start_date AS deload_start_date,
  tp.end_date AS deload_end_date,
  COALESCE(tp.end_date, CURRENT_DATE) - tp.start_date AS deload_duration_days,
  tp.notes,
  tp.deload_trigger,
  -- Days between this deload and the previous one
  tp.start_date - LAG(COALESCE(tp.end_date, tp.start_date)) OVER (
    PARTITION BY tp.user_id ORDER BY tp.start_date
  ) AS days_since_previous_deload_end
FROM training_phases tp
WHERE tp.phase_type = 'deload';

COMMENT ON VIEW deload_history IS
  'Timeline of deload phases per user with inter-deload gaps. Helps coaching '
  'suggest "you typically deload every 8 weeks" or "overdue vs your pattern".';

COMMIT;
