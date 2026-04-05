-- Migration 080: Weekly Metrics vs Personal Baseline
-- Comparison views that contrast user's CURRENT week against their personal
-- 12-week average across volume, intensity, consistency, and session quality.
-- Motivation-focused: "you're 20% above your chest-volume average."
--
-- Validated by: data-science-expert
--
-- Key design decisions:
--   - 12-week rolling baseline (excludes current week from baseline)
--   - Pct delta interpretation: +10% = meaningfully better, -15% = concerning
--   - Uses existing weekly_volume_snapshots (078) as the volume source
--   - Gracefully degrades when user has <4 weeks of history (insufficient_baseline)
--
-- Citations:
--   - Hopkins W.G. (2002). Probabilities of clinical/practical significance.
--   - Buchheit M. (2014). Monitoring monotony and training strain. Sports Med.

BEGIN;

-- =============================================================================
-- 1. volume_vs_baseline view
-- =============================================================================
-- Current-week effective_sets per muscle vs personal 12-week average.

CREATE OR REPLACE VIEW volume_vs_baseline
WITH (security_invoker = true) AS
WITH current_week AS (
  SELECT
    user_id,
    muscle_group_id,
    effective_sets AS current_sets,
    total_volume_kg AS current_volume_kg,
    training_days AS current_training_days
  FROM weekly_volume_snapshots
  WHERE week_start = date_trunc('week', CURRENT_DATE)::date
),
baseline AS (
  SELECT
    user_id,
    muscle_group_id,
    AVG(effective_sets)::numeric(5,1) AS baseline_sets,
    AVG(total_volume_kg)::numeric(8,1) AS baseline_volume_kg,
    AVG(training_days)::numeric(3,1) AS baseline_training_days,
    COUNT(*)::integer AS baseline_weeks
  FROM weekly_volume_snapshots
  WHERE week_start >= date_trunc('week', CURRENT_DATE)::date - interval '84 days'
    AND week_start < date_trunc('week', CURRENT_DATE)::date
  GROUP BY user_id, muscle_group_id
)
SELECT
  COALESCE(cw.user_id, b.user_id)           AS user_id,
  COALESCE(cw.muscle_group_id, b.muscle_group_id) AS muscle_group_id,
  mg.name                                    AS muscle_name,
  COALESCE(cw.current_sets, 0)               AS current_week_sets,
  b.baseline_sets,
  b.baseline_weeks,
  CASE
    WHEN b.baseline_weeks IS NULL OR b.baseline_weeks < 4 THEN NULL
    WHEN b.baseline_sets = 0 OR b.baseline_sets IS NULL THEN NULL
    ELSE ROUND(
      ((COALESCE(cw.current_sets, 0) - b.baseline_sets) / b.baseline_sets * 100)::numeric, 1
    )
  END AS pct_delta_vs_baseline,
  CASE
    WHEN b.baseline_weeks IS NULL OR b.baseline_weeks < 4                          THEN 'insufficient_baseline'
    WHEN b.baseline_sets = 0 OR b.baseline_sets IS NULL                            THEN 'no_baseline'
    WHEN COALESCE(cw.current_sets, 0) >= b.baseline_sets * 1.25                    THEN 'well_above_baseline'
    WHEN COALESCE(cw.current_sets, 0) >= b.baseline_sets * 1.05                    THEN 'above_baseline'
    WHEN COALESCE(cw.current_sets, 0) >= b.baseline_sets * 0.95                    THEN 'on_baseline'
    WHEN COALESCE(cw.current_sets, 0) >= b.baseline_sets * 0.75                    THEN 'below_baseline'
    ELSE                                                                                'well_below_baseline'
  END AS comparison_band
FROM baseline b
FULL OUTER JOIN current_week cw
  ON cw.user_id = b.user_id AND cw.muscle_group_id = b.muscle_group_id
JOIN muscle_groups mg
  ON mg.id = COALESCE(cw.muscle_group_id, b.muscle_group_id);

COMMENT ON VIEW volume_vs_baseline IS
  'Current-week effective sets per muscle vs personal 12-week baseline. '
  'Comparison bands: well_above (>=125%%), above (>=105%%), on (±5%%), '
  'below (>=75%%), well_below (<75%%). Requires >= 4 weeks of baseline.';

-- =============================================================================
-- 2. session_quality_vs_baseline view
-- =============================================================================
-- Current-week session quality score vs personal 12-week average.

CREATE OR REPLACE VIEW session_quality_vs_baseline
WITH (security_invoker = true) AS
WITH current_week AS (
  SELECT
    user_id,
    AVG(quality_score)::numeric(4,1) AS current_avg_quality,
    COUNT(*)::integer AS current_session_count
  FROM session_quality_scores
  WHERE training_date >= date_trunc('week', CURRENT_DATE)::date
    AND training_date < date_trunc('week', CURRENT_DATE)::date + interval '7 days'
  GROUP BY user_id
),
baseline AS (
  SELECT
    user_id,
    AVG(quality_score)::numeric(4,1) AS baseline_avg_quality,
    COUNT(*)::integer AS baseline_session_count,
    COUNT(DISTINCT date_trunc('week', training_date))::integer AS baseline_weeks
  FROM session_quality_scores
  WHERE training_date >= date_trunc('week', CURRENT_DATE)::date - interval '84 days'
    AND training_date < date_trunc('week', CURRENT_DATE)::date
  GROUP BY user_id
)
SELECT
  COALESCE(cw.user_id, b.user_id) AS user_id,
  cw.current_avg_quality,
  cw.current_session_count,
  b.baseline_avg_quality,
  b.baseline_session_count,
  b.baseline_weeks,
  CASE
    WHEN b.baseline_weeks IS NULL OR b.baseline_weeks < 4 THEN NULL
    WHEN b.baseline_avg_quality IS NULL THEN NULL
    ELSE ROUND(
      ((cw.current_avg_quality - b.baseline_avg_quality))::numeric, 1
    )
  END AS points_delta_vs_baseline,
  CASE
    WHEN b.baseline_weeks IS NULL OR b.baseline_weeks < 4                          THEN 'insufficient_baseline'
    WHEN cw.current_avg_quality IS NULL                                             THEN 'no_current_data'
    WHEN cw.current_avg_quality >= b.baseline_avg_quality + 10                     THEN 'well_above_baseline'
    WHEN cw.current_avg_quality >= b.baseline_avg_quality + 3                      THEN 'above_baseline'
    WHEN cw.current_avg_quality >= b.baseline_avg_quality - 3                      THEN 'on_baseline'
    WHEN cw.current_avg_quality >= b.baseline_avg_quality - 10                     THEN 'below_baseline'
    ELSE                                                                                'well_below_baseline'
  END AS comparison_band
FROM baseline b
FULL OUTER JOIN current_week cw ON cw.user_id = b.user_id;

COMMENT ON VIEW session_quality_vs_baseline IS
  'Current-week average session quality vs personal 12-week baseline. '
  'Bands by points delta: well_above (>=+10), above (>=+3), on (±3), '
  'below (>=-10), well_below (<-10). Quality is 0-100.';

-- =============================================================================
-- 3. consistency_vs_baseline view
-- =============================================================================
-- Current-week training days + set count vs personal averages.

CREATE OR REPLACE VIEW consistency_vs_baseline
WITH (security_invoker = true) AS
WITH current_week AS (
  SELECT
    user_id,
    COUNT(DISTINCT training_date)::integer AS current_training_days,
    COUNT(*) FILTER (WHERE set_type = 'working')::integer AS current_working_sets
  FROM sets
  WHERE training_date >= date_trunc('week', CURRENT_DATE)::date
    AND training_date < date_trunc('week', CURRENT_DATE)::date + interval '7 days'
  GROUP BY user_id
),
baseline_weekly AS (
  SELECT
    user_id,
    date_trunc('week', training_date)::date AS week_start,
    COUNT(DISTINCT training_date) AS week_training_days,
    COUNT(*) FILTER (WHERE set_type = 'working') AS week_working_sets
  FROM sets
  WHERE training_date >= date_trunc('week', CURRENT_DATE)::date - interval '84 days'
    AND training_date < date_trunc('week', CURRENT_DATE)::date
  GROUP BY user_id, date_trunc('week', training_date)
),
baseline AS (
  SELECT
    user_id,
    AVG(week_training_days)::numeric(3,1) AS baseline_training_days,
    AVG(week_working_sets)::numeric(5,1) AS baseline_working_sets,
    COUNT(*)::integer AS baseline_weeks
  FROM baseline_weekly
  GROUP BY user_id
)
SELECT
  COALESCE(cw.user_id, b.user_id) AS user_id,
  COALESCE(cw.current_training_days, 0) AS current_training_days,
  COALESCE(cw.current_working_sets, 0) AS current_working_sets,
  b.baseline_training_days,
  b.baseline_working_sets,
  b.baseline_weeks,
  -- Training-days delta
  CASE
    WHEN b.baseline_weeks IS NULL OR b.baseline_weeks < 4 THEN NULL
    WHEN b.baseline_training_days = 0 THEN NULL
    ELSE ROUND(
      ((COALESCE(cw.current_training_days, 0) - b.baseline_training_days)
       / b.baseline_training_days * 100)::numeric, 0
    )::integer
  END AS training_days_pct_delta,
  CASE
    WHEN b.baseline_weeks IS NULL OR b.baseline_weeks < 4 THEN NULL
    WHEN b.baseline_working_sets = 0 THEN NULL
    ELSE ROUND(
      ((COALESCE(cw.current_working_sets, 0) - b.baseline_working_sets)
       / b.baseline_working_sets * 100)::numeric, 0
    )::integer
  END AS working_sets_pct_delta,
  CASE
    WHEN b.baseline_weeks IS NULL OR b.baseline_weeks < 4                                THEN 'insufficient_baseline'
    WHEN COALESCE(cw.current_training_days, 0) = 0                                        THEN 'no_training_this_week'
    WHEN COALESCE(cw.current_training_days, 0) >= b.baseline_training_days * 1.15         THEN 'above_baseline'
    WHEN COALESCE(cw.current_training_days, 0) >= b.baseline_training_days * 0.85         THEN 'on_baseline'
    ELSE                                                                                      'below_baseline'
  END AS consistency_band
FROM baseline b
FULL OUTER JOIN current_week cw ON cw.user_id = b.user_id;

COMMENT ON VIEW consistency_vs_baseline IS
  'Current-week training frequency (days + working sets) vs personal 12-week '
  'baseline. Enables "you trained 4 days vs typical 3" coaching cards.';

-- =============================================================================
-- 4. exercise_this_week_vs_pr view
-- =============================================================================
-- For each exercise user trained this week, show their best weight/reps vs
-- their all-time best. Motivating "almost at your PR!" surfacing.

CREATE OR REPLACE VIEW exercise_this_week_vs_pr
WITH (security_invoker = true) AS
WITH current_week_best AS (
  SELECT
    s.user_id,
    s.exercise_id,
    MAX(s.estimated_1rm) AS best_e1rm_this_week,
    MAX(s.weight) AS max_weight_this_week,
    MAX(s.weight * s.reps) AS max_volume_this_week
  FROM sets s
  WHERE s.user_id IS NOT NULL
    AND s.training_date >= date_trunc('week', CURRENT_DATE)::date
    AND s.training_date < date_trunc('week', CURRENT_DATE)::date + interval '7 days'
    AND s.set_type = 'working'
    AND s.estimated_1rm IS NOT NULL
  GROUP BY s.user_id, s.exercise_id
),
all_time_prs AS (
  SELECT
    pr.user_id,
    pr.exercise_id,
    MAX(pr.value) FILTER (WHERE pr.record_type = 'estimated_1rm') AS all_time_best_e1rm,
    MAX(pr.value) FILTER (WHERE pr.record_type = 'max_weight') AS all_time_max_weight
  FROM personal_records pr
  WHERE pr.pr_context = 'straight'
  GROUP BY pr.user_id, pr.exercise_id
)
SELECT
  cwb.user_id,
  cwb.exercise_id,
  e.name AS exercise_name,
  cwb.best_e1rm_this_week,
  atp.all_time_best_e1rm,
  CASE
    WHEN atp.all_time_best_e1rm IS NULL OR atp.all_time_best_e1rm = 0 THEN NULL
    ELSE ROUND(
      (cwb.best_e1rm_this_week / atp.all_time_best_e1rm * 100)::numeric, 1
    )
  END AS pct_of_all_time_pr,
  CASE
    WHEN atp.all_time_best_e1rm IS NULL                                    THEN 'no_pr_history'
    WHEN cwb.best_e1rm_this_week >= atp.all_time_best_e1rm                 THEN 'new_pr'
    WHEN cwb.best_e1rm_this_week >= atp.all_time_best_e1rm * 0.98          THEN 'near_pr'
    WHEN cwb.best_e1rm_this_week >= atp.all_time_best_e1rm * 0.90          THEN 'working_hard'
    ELSE                                                                        'building_up'
  END AS approach_status
FROM current_week_best cwb
JOIN exercises e ON e.id = cwb.exercise_id
LEFT JOIN all_time_prs atp ON atp.user_id = cwb.user_id AND atp.exercise_id = cwb.exercise_id
ORDER BY cwb.user_id, pct_of_all_time_pr DESC NULLS LAST;

COMMENT ON VIEW exercise_this_week_vs_pr IS
  'Current-week best e1RM per exercise vs user all-time PR. Surfaces '
  '"new_pr" (achieved this week), "near_pr" (>=98%%), "working_hard" (>=90%%) '
  'for motivation and coaching recommendations.';

COMMIT;
