-- Migration 088: Sleep-Performance Correlation
-- Joins workout_feedback.sleep_hours + prior_sleep_quality with
-- session_quality_scores to surface per-user sleep-performance relationships.
--
-- The tables have existed since 019 (workout_feedback) but were never joined
-- for correlation analysis. Evidence base is strong: Knowles 2018 found
-- <6h sleep impairs strength performance; Walker 2018 systematic review
-- links sleep debt to compromised motor learning and recovery.
--
-- Validated by: sports-medicine-expert, data-science-expert
--
-- Key design decisions:
--   - Day-level join (sleep preceding training session)
--   - Split into sleep buckets: poor (<6h), moderate (6-7h), good (7-8h),
--     optimal (8-9h), excess (>9h)
--   - Requires >=10 sessions per bucket for correlation validity
--
-- Citations:
--   - Knowles O.E. et al. (2018). Sleep and resistance training performance.
--     Sports Medicine.
--   - Walker M.P. (2018). Why We Sleep — athletic recovery chapter.
--   - Mah C.D. et al. (2011). Sleep extension in collegiate athletes.
--   - Dattilo M. et al. (2011). Sleep and muscle recovery. Med Hypotheses.

BEGIN;

-- =============================================================================
-- 1. sleep_performance_daily view
-- =============================================================================
-- Day-level join: workout_feedback + session_quality_scores + training load.

CREATE OR REPLACE VIEW sleep_performance_daily
WITH (security_invoker = true) AS
SELECT
  wf.user_id,
  wf.training_date,
  wf.sleep_hours,
  wf.prior_sleep_quality,
  wf.readiness_score,
  wf.stress_level,
  wf.session_rpe,
  sqs.quality_score,
  -- Sleep bucket
  CASE
    WHEN wf.sleep_hours IS NULL THEN NULL
    WHEN wf.sleep_hours < 6 THEN 'poor'
    WHEN wf.sleep_hours < 7 THEN 'moderate'
    WHEN wf.sleep_hours < 8 THEN 'good'
    WHEN wf.sleep_hours <= 9 THEN 'optimal'
    ELSE                          'excess'
  END AS sleep_bucket
FROM workout_feedback wf
LEFT JOIN session_quality_scores sqs
  ON sqs.user_id = wf.user_id AND sqs.training_date = wf.training_date;

COMMENT ON VIEW sleep_performance_daily IS
  'Day-level join of workout_feedback with session_quality_scores. Buckets '
  'sleep into poor (<6h), moderate (6-7), good (7-8), optimal (8-9), excess (>9).';

-- =============================================================================
-- 2. sleep_impact_summary view
-- =============================================================================
-- Per-user aggregate: compare session quality across sleep buckets.

CREATE OR REPLACE VIEW sleep_impact_summary
WITH (security_invoker = true) AS
WITH bucket_stats AS (
  SELECT
    user_id,
    sleep_bucket,
    AVG(quality_score)::numeric(4,1) AS avg_quality,
    AVG(session_rpe)::numeric(3,1) AS avg_session_rpe,
    COUNT(*)::integer AS session_count
  FROM sleep_performance_daily
  WHERE quality_score IS NOT NULL
    AND sleep_bucket IS NOT NULL
    AND training_date >= CURRENT_DATE - 180
  GROUP BY user_id, sleep_bucket
),
poor_vs_good AS (
  SELECT
    user_id,
    MAX(avg_quality) FILTER (WHERE sleep_bucket IN ('good','optimal')) AS good_sleep_quality,
    MAX(avg_quality) FILTER (WHERE sleep_bucket = 'poor') AS poor_sleep_quality,
    MAX(session_count) FILTER (WHERE sleep_bucket IN ('good','optimal')) AS good_sleep_sessions,
    MAX(session_count) FILTER (WHERE sleep_bucket = 'poor') AS poor_sleep_sessions
  FROM bucket_stats
  GROUP BY user_id
)
SELECT
  pvg.user_id,
  pvg.good_sleep_quality,
  pvg.poor_sleep_quality,
  pvg.good_sleep_sessions,
  pvg.poor_sleep_sessions,
  (pvg.good_sleep_quality - pvg.poor_sleep_quality)::numeric(4,1) AS quality_delta,
  CASE
    WHEN pvg.good_sleep_sessions IS NULL OR pvg.poor_sleep_sessions IS NULL
      OR pvg.good_sleep_sessions < 10 OR pvg.poor_sleep_sessions < 5                THEN 'insufficient_data'
    WHEN (pvg.good_sleep_quality - pvg.poor_sleep_quality) >= 10                    THEN 'strong_positive'
    WHEN (pvg.good_sleep_quality - pvg.poor_sleep_quality) >= 3                     THEN 'positive'
    WHEN (pvg.good_sleep_quality - pvg.poor_sleep_quality) >= -3                    THEN 'neutral'
    ELSE                                                                                 'negative'
  END AS sleep_impact,
  CASE
    WHEN pvg.good_sleep_sessions IS NULL OR pvg.poor_sleep_sessions IS NULL
      OR pvg.good_sleep_sessions < 10 OR pvg.poor_sleep_sessions < 5 THEN
      'Log more workouts with sleep data to see personal correlation.'
    WHEN (pvg.good_sleep_quality - pvg.poor_sleep_quality) >= 10 THEN
      'Your training quality is SIGNIFICANTLY better after 7+ hours of sleep. Prioritize sleep on training nights.'
    WHEN (pvg.good_sleep_quality - pvg.poor_sleep_quality) >= 3 THEN
      'Your training quality is modestly better after 7+ hours. Sleep helps.'
    WHEN (pvg.good_sleep_quality - pvg.poor_sleep_quality) >= -3 THEN
      'Your training quality is similar regardless of sleep. Monitor more data.'
    ELSE
      'Your data shows better quality on lower-sleep days — likely noise or confound (caffeine, stimulants).'
  END AS recommendation
FROM poor_vs_good pvg
WHERE pvg.good_sleep_quality IS NOT NULL OR pvg.poor_sleep_quality IS NOT NULL;

COMMENT ON VIEW sleep_impact_summary IS
  'Per-user sleep-performance correlation summary. Compares avg session quality '
  'on good/optimal sleep days (7-9h) vs poor sleep days (<6h) over last 180 days. '
  'Requires >=10 good-sleep sessions AND >=5 poor-sleep sessions for validity.';

-- =============================================================================
-- 3. sleep_bucket_summary view: full distribution per user
-- =============================================================================

CREATE OR REPLACE VIEW sleep_bucket_summary
WITH (security_invoker = true) AS
SELECT
  user_id,
  sleep_bucket,
  AVG(quality_score)::numeric(4,1) AS avg_quality,
  AVG(session_rpe)::numeric(3,1) AS avg_rpe,
  AVG(prior_sleep_quality)::numeric(3,1) AS avg_subjective_sleep_quality,
  AVG(readiness_score)::numeric(3,1) AS avg_readiness,
  AVG(stress_level)::numeric(3,1) AS avg_stress,
  COUNT(*)::integer AS session_count
FROM sleep_performance_daily
WHERE sleep_bucket IS NOT NULL
  AND training_date >= CURRENT_DATE - 180
GROUP BY user_id, sleep_bucket;

COMMENT ON VIEW sleep_bucket_summary IS
  'Per-user breakdown of session metrics (quality, RPE, readiness, stress) '
  'by sleep bucket. Shows full gradient of performance vs sleep duration.';

-- =============================================================================
-- 4. sleep_debt_14d view: rolling sleep debt vs target
-- =============================================================================

CREATE OR REPLACE VIEW sleep_debt_14d
WITH (security_invoker = true) AS
WITH windowed AS (
  SELECT
    user_id,
    training_date,
    sleep_hours,
    -- 14-day rolling average sleep hours
    AVG(sleep_hours) OVER (
      PARTITION BY user_id ORDER BY training_date
      ROWS BETWEEN 13 PRECEDING AND CURRENT ROW
    )::numeric(3,1) AS avg_sleep_14d,
    -- Count of days with sleep data in window
    COUNT(sleep_hours) OVER (
      PARTITION BY user_id ORDER BY training_date
      ROWS BETWEEN 13 PRECEDING AND CURRENT ROW
    )::integer AS days_with_data_14d
  FROM workout_feedback
  WHERE sleep_hours IS NOT NULL
)
SELECT
  user_id,
  training_date,
  sleep_hours,
  avg_sleep_14d,
  days_with_data_14d,
  -- Sleep debt vs 8-hour target
  (8.0 - avg_sleep_14d)::numeric(3,1) AS sleep_debt_hours,
  (14 * (8.0 - avg_sleep_14d))::numeric(4,1) AS cumulative_debt_hours,
  CASE
    WHEN days_with_data_14d < 7 THEN 'insufficient_data'
    WHEN avg_sleep_14d >= 7.5 THEN 'well_rested'
    WHEN avg_sleep_14d >= 7.0 THEN 'adequate'
    WHEN avg_sleep_14d >= 6.5 THEN 'mild_debt'
    WHEN avg_sleep_14d >= 6.0 THEN 'moderate_debt'
    ELSE                           'severe_debt'
  END AS sleep_status
FROM windowed;

COMMENT ON VIEW sleep_debt_14d IS
  'Per-user 14-day rolling avg sleep hours with debt vs 8h target. '
  'Cumulative debt = 14 × (8 − avg). Bands: well_rested (>=7.5), '
  'adequate (>=7), mild_debt (>=6.5), moderate_debt (>=6), severe_debt (<6).';

COMMIT;
