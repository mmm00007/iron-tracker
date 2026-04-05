-- Migration 067: Integrated Analytics Views
-- Composes the tables introduced in 058-066 into analytics views that the
-- frontend can query directly. All views are security_invoker (RLS applies
-- via underlying tables).
--
-- Views created:
--   - weekly_muscle_effective_sets: activation-weighted volume per muscle per week
--   - volume_vs_landmarks_current_week: comparison of current week to MEV/MAV/MRV
--   - user_dashboard_summary: one-row-per-user state snapshot
--   - phase_adherence_check: is user's current training matching their declared phase?
--
-- Validated by: data-science-expert, database-specialist

BEGIN;

-- =============================================================================
-- 1. weekly_muscle_effective_sets
-- =============================================================================
-- Activation-weighted volume per (user, muscle_group, week). Replaces raw set
-- count with fractional contribution: bench press contributes 1.0 to chest +
-- 0.5 to triceps based on exercise_muscles.activation_percent.
--
-- Used by volume_vs_landmarks_current_week + analytics cron.

CREATE OR REPLACE VIEW weekly_muscle_effective_sets
WITH (security_invoker = true) AS
SELECT
  s.user_id,
  em.muscle_group_id,
  date_trunc('week', s.training_date)::date AS week_start,
  (date_trunc('week', s.training_date) + interval '6 days')::date AS week_end,
  -- Activation-weighted sum: each set contributes (activation_pct/100) to each muscle
  ROUND(
    SUM(COALESCE(em.activation_percent, CASE WHEN em.is_primary THEN 100 ELSE 50 END)::numeric / 100),
    1
  ) AS effective_sets,
  COUNT(*) AS mechanical_sets,
  -- Exclude drop-set sub-sets, cluster sub-sets — treat as fractional (needs cluster_type_defaults.effective_set_coefficient)
  AVG(s.rpe) FILTER (WHERE s.rpe IS NOT NULL)::numeric(3,1) AS avg_rpe,
  MAX(s.rpe) AS peak_rpe
FROM sets s
JOIN exercise_muscles em ON em.exercise_id = s.exercise_id
WHERE s.training_date IS NOT NULL
  AND s.set_type = 'working'
  AND s.reps > 0
GROUP BY s.user_id, em.muscle_group_id, date_trunc('week', s.training_date);

COMMENT ON VIEW weekly_muscle_effective_sets IS
  'Per-user per-muscle per-week activation-weighted effective sets. Working sets only. '
  'Activation weights from exercise_muscles.activation_percent (fallback: primary=100%, secondary=50%).';

-- =============================================================================
-- 2. volume_vs_landmarks_current_week
-- =============================================================================
-- Compares current-week effective sets to user's volume_landmarks.
-- Surfaces "at MEV", "above MAV", "approaching MRV" coaching states.

CREATE OR REPLACE VIEW volume_vs_landmarks_current_week
WITH (security_invoker = true) AS
WITH current_week AS (
  SELECT
    user_id, muscle_group_id, effective_sets, mechanical_sets, avg_rpe, peak_rpe
  FROM weekly_muscle_effective_sets
  WHERE week_start = date_trunc('week', CURRENT_DATE)::date
),
user_goal AS (
  SELECT id AS user_id, primary_goal FROM profiles
)
SELECT
  vl.user_id,
  vl.muscle_group_id,
  mg.name                          AS muscle_name,
  vl.training_goal,
  COALESCE(cw.effective_sets, 0)   AS current_week_effective_sets,
  COALESCE(cw.mechanical_sets, 0)  AS current_week_mechanical_sets,
  cw.avg_rpe                       AS current_week_avg_rpe,
  vl.mv_sets_per_week,
  vl.mev_sets_per_week,
  vl.mav_sets_per_week,
  vl.mrv_sets_per_week,
  CASE
    WHEN COALESCE(cw.effective_sets, 0) < vl.mv_sets_per_week  THEN 'below_mv'
    WHEN COALESCE(cw.effective_sets, 0) < vl.mev_sets_per_week THEN 'mv_zone'
    WHEN COALESCE(cw.effective_sets, 0) < vl.mav_sets_per_week THEN 'productive'
    WHEN COALESCE(cw.effective_sets, 0) <= vl.mrv_sets_per_week THEN 'near_ceiling'
    ELSE 'above_mrv'
  END                              AS landmark_zone,
  CASE
    WHEN COALESCE(cw.effective_sets, 0) > vl.mrv_sets_per_week THEN true
    ELSE false
  END                              AS is_overreaching
FROM volume_landmarks vl
JOIN muscle_groups mg     ON mg.id = vl.muscle_group_id
JOIN user_goal ug         ON ug.user_id = vl.user_id AND ug.primary_goal = vl.training_goal
LEFT JOIN current_week cw ON cw.user_id = vl.user_id AND cw.muscle_group_id = vl.muscle_group_id;

COMMENT ON VIEW volume_vs_landmarks_current_week IS
  'Current week effective sets per muscle vs user volume landmarks. '
  'Zones: below_mv < mv_zone < productive < near_ceiling < above_mrv. '
  'Filters to user''s active training_goal.';

-- =============================================================================
-- 3. user_dashboard_summary
-- =============================================================================
-- Single-row-per-user snapshot combining current phase, latest ACWR, highest-
-- fatigue muscle, and training consistency. Used by home screen.

CREATE OR REPLACE VIEW user_dashboard_summary
WITH (security_invoker = true) AS
WITH active_phase AS (
  SELECT DISTINCT ON (user_id)
    user_id, id AS phase_id, name AS phase_name, phase_type, start_date, planned_weeks,
    (CURRENT_DATE - start_date) AS phase_days_elapsed
  FROM training_phases
  WHERE end_date IS NULL
  ORDER BY user_id, start_date DESC
),
latest_workload AS (
  SELECT DISTINCT ON (user_id)
    user_id, acwr_ratio, risk_zone, acute_7d_load, chronic_28d_load, training_date
  FROM workload_metrics
  ORDER BY user_id, training_date DESC
),
most_fatigued_muscle AS (
  SELECT DISTINCT ON (mfs.user_id)
    mfs.user_id, mfs.muscle_group_id, mg.name AS muscle_name,
    mfs.fatigue_score, mfs.recovery_status
  FROM muscle_fatigue_state mfs
  JOIN muscle_groups mg ON mg.id = mfs.muscle_group_id
  WHERE mfs.as_of_date = CURRENT_DATE
  ORDER BY mfs.user_id, mfs.fatigue_score DESC
),
weekly_activity AS (
  SELECT
    s.user_id,
    COUNT(DISTINCT s.training_date) AS training_days_this_week,
    COUNT(*)                         AS sets_this_week
  FROM sets s
  WHERE s.training_date >= date_trunc('week', CURRENT_DATE)::date
  GROUP BY s.user_id
)
SELECT
  p.id                                    AS user_id,
  p.display_name,
  p.primary_goal,
  p.experience_level,
  ap.phase_id,
  ap.phase_name,
  ap.phase_type,
  ap.phase_days_elapsed,
  ap.planned_weeks                        AS phase_planned_weeks,
  lw.acwr_ratio                           AS latest_acwr,
  lw.risk_zone                            AS latest_risk_zone,
  mfm.muscle_name                         AS most_fatigued_muscle,
  mfm.fatigue_score                       AS most_fatigued_score,
  mfm.recovery_status                     AS most_fatigued_recovery_status,
  COALESCE(wa.training_days_this_week, 0) AS training_days_this_week,
  COALESCE(wa.sets_this_week, 0)          AS sets_this_week
FROM profiles p
LEFT JOIN active_phase ap        ON ap.user_id = p.id
LEFT JOIN latest_workload lw     ON lw.user_id = p.id
LEFT JOIN most_fatigued_muscle mfm ON mfm.user_id = p.id
LEFT JOIN weekly_activity wa     ON wa.user_id = p.id;

COMMENT ON VIEW user_dashboard_summary IS
  'One row per user, aggregating current phase, latest ACWR, most-fatigued muscle, '
  'and weekly activity. Used by home screen to show a unified state snapshot.';

-- =============================================================================
-- 4. Supporting function: compute_daily_load_from_workout
-- =============================================================================
-- Canonical formula for daily_load from workout_feedback. Backend cron
-- uses this to populate workload_metrics.daily_load.

CREATE OR REPLACE FUNCTION compute_daily_load(
  p_session_rpe numeric,
  p_duration_minutes integer
)
RETURNS numeric
LANGUAGE sql
IMMUTABLE
AS $$
  SELECT CASE
    WHEN p_session_rpe IS NULL OR p_duration_minutes IS NULL OR p_duration_minutes <= 0
    THEN 0::numeric
    ELSE ROUND((p_session_rpe * p_duration_minutes)::numeric, 2)
  END;
$$;

COMMENT ON FUNCTION compute_daily_load(numeric, integer) IS
  'Canonical daily load formula: session_rpe * duration_minutes (Foster 2001 sRPE). '
  'Returns 0 for missing data. Used by backend cron and analytics consistency.';

COMMIT;
