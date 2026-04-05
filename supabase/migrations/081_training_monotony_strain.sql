-- Migration 081: Training Monotony + Strain (Foster 2001)
-- Adds monotony/strain metrics alongside ACWR for a fuller picture of
-- overtraining risk. Uses existing workload_metrics.daily_load.
--
-- Monotony = mean(daily_load) / stddev(daily_load) over 7-day window.
--   Low monotony (<1.5) = varied load = good for adaptation
--   High monotony (>2.0) = same load every day = overtraining risk
-- Strain = weekly_load × monotony
--   Foster 2001: strain >3000 AU on sRPE-based load is warning threshold
--
-- ACWR and monotony are COMPLEMENTARY:
--   ACWR compares load vs baseline (temporal)
--   Monotony measures load VARIANCE (day-to-day distribution)
--   A user can have ACWR 1.0 (safe) but high monotony (risky) if they
--   train identically every day.
--
-- Validated by: data-science-expert, sports-medicine-expert
--
-- Citations:
--   - Foster C. (1998). Monitoring training in athletes w/ reference to
--     overtraining syndrome. Med Sci Sports Exerc.
--   - Foster C. et al. (2001). A new approach to monitoring exercise training.
--     JSCR.
--   - Haddad M. et al. (2017). Session-RPE method for training load monitoring.
--     Frontiers Neurosci.

BEGIN;

-- =============================================================================
-- 1. training_monotony_strain view
-- =============================================================================
-- Per-user per-date rolling 7-day monotony + strain. Computes via window
-- functions so backend cron doesn't need to recompute.

CREATE OR REPLACE VIEW training_monotony_strain
WITH (security_invoker = true) AS
WITH daily_loads AS (
  SELECT
    user_id,
    training_date,
    daily_load,
    acute_7d_load AS weekly_load
  FROM workload_metrics
),
with_stats AS (
  SELECT
    user_id,
    training_date,
    daily_load,
    weekly_load,
    -- Mean daily load over trailing 7 days
    AVG(daily_load) OVER (
      PARTITION BY user_id
      ORDER BY training_date
      RANGE BETWEEN INTERVAL '6 days' PRECEDING AND CURRENT ROW
    )::numeric(8,2) AS mean_daily_load_7d,
    -- Stddev daily load over trailing 7 days
    STDDEV(daily_load) OVER (
      PARTITION BY user_id
      ORDER BY training_date
      RANGE BETWEEN INTERVAL '6 days' PRECEDING AND CURRENT ROW
    )::numeric(8,2) AS stddev_daily_load_7d,
    -- Count of non-zero load days in window (for data-quality gate)
    COUNT(daily_load) FILTER (WHERE daily_load > 0) OVER (
      PARTITION BY user_id
      ORDER BY training_date
      RANGE BETWEEN INTERVAL '6 days' PRECEDING AND CURRENT ROW
    )::integer AS training_days_7d
  FROM daily_loads
)
SELECT
  user_id,
  training_date,
  daily_load,
  weekly_load,
  mean_daily_load_7d,
  stddev_daily_load_7d,
  training_days_7d,
  -- Monotony: mean / stddev, capped at 3.0 (degenerate cases produce Inf).
  -- Foster 2001: realistic values span 0.5-2.5; cap prevents overflow when
  -- loads are nearly identical (stddev → 0).
  CASE
    WHEN stddev_daily_load_7d IS NULL OR stddev_daily_load_7d = 0 THEN NULL
    WHEN training_days_7d < 3 THEN NULL
    ELSE LEAST(3.0, ROUND((mean_daily_load_7d / stddev_daily_load_7d)::numeric, 2))
  END AS monotony,
  -- Strain: weekly_load × capped_monotony
  CASE
    WHEN stddev_daily_load_7d IS NULL OR stddev_daily_load_7d = 0 THEN NULL
    WHEN training_days_7d < 3 THEN NULL
    ELSE ROUND((weekly_load * LEAST(3.0, mean_daily_load_7d / stddev_daily_load_7d))::numeric, 0)
  END::integer AS strain,
  -- Risk zones per Foster 2001 (using capped monotony)
  CASE
    WHEN stddev_daily_load_7d IS NULL OR stddev_daily_load_7d = 0 OR training_days_7d < 3 THEN 'insufficient_data'
    WHEN LEAST(3.0, mean_daily_load_7d / stddev_daily_load_7d) < 1.5                      THEN 'low_monotony'
    WHEN LEAST(3.0, mean_daily_load_7d / stddev_daily_load_7d) < 2.0                      THEN 'moderate_monotony'
    ELSE                                                                                        'high_monotony'
  END AS monotony_zone,
  CASE
    WHEN weekly_load IS NULL OR stddev_daily_load_7d IS NULL OR stddev_daily_load_7d = 0 OR training_days_7d < 3 THEN 'insufficient_data'
    WHEN (weekly_load * LEAST(3.0, mean_daily_load_7d / stddev_daily_load_7d)) < 2000                       THEN 'low_strain'
    WHEN (weekly_load * LEAST(3.0, mean_daily_load_7d / stddev_daily_load_7d)) < 3000                       THEN 'moderate_strain'
    WHEN (weekly_load * LEAST(3.0, mean_daily_load_7d / stddev_daily_load_7d)) < 5000                       THEN 'elevated_strain'
    ELSE                                                                                                         'high_strain'
  END AS strain_zone
FROM with_stats;

COMMENT ON VIEW training_monotony_strain IS
  'Per-user per-date 7-day rolling monotony + strain metrics (Foster 2001). '
  'monotony = mean_daily_load / stddev_daily_load. strain = weekly_load × monotony. '
  'High monotony (>2.0) indicates under-varied training — overtraining risk. '
  'Strain >3000 AU warrants attention; >5000 suggests unload.';

-- =============================================================================
-- 2. current_overtraining_risk view: combine ACWR + monotony + strain
-- =============================================================================
-- Unified overtraining risk indicator: if ANY of ACWR / monotony / strain is
-- elevated, surface to the user. Current (most recent) values per user.

CREATE OR REPLACE VIEW current_overtraining_risk
WITH (security_invoker = true) AS
WITH latest_per_user AS (
  SELECT DISTINCT ON (wm.user_id)
    wm.user_id,
    wm.training_date,
    wm.acwr_ratio,
    wm.risk_zone AS acwr_zone,
    tms.monotony,
    tms.monotony_zone,
    tms.strain,
    tms.strain_zone
  FROM workload_metrics wm
  LEFT JOIN training_monotony_strain tms
    ON tms.user_id = wm.user_id AND tms.training_date = wm.training_date
  ORDER BY wm.user_id, wm.training_date DESC
)
SELECT
  user_id,
  training_date AS as_of_date,
  acwr_ratio,
  acwr_zone,
  monotony,
  monotony_zone,
  strain,
  strain_zone,
  -- Composite risk: HIGH if any dimension is worst-tier, MODERATE if two are elevated
  CASE
    WHEN acwr_zone = 'insufficient_data' AND monotony_zone = 'insufficient_data' THEN 'insufficient_data'
    WHEN acwr_zone = 'high_risk' OR strain_zone = 'high_strain'                       THEN 'high'
    WHEN monotony_zone = 'high_monotony' AND strain_zone IN ('elevated_strain','high_strain') THEN 'high'
    WHEN acwr_zone IN ('elevated','high_risk') OR monotony_zone = 'high_monotony' OR strain_zone = 'elevated_strain' THEN 'moderate'
    WHEN acwr_zone = 'optimal' AND monotony_zone IN ('low_monotony','moderate_monotony') AND strain_zone IN ('low_strain','moderate_strain') THEN 'low'
    ELSE 'moderate'
  END AS composite_risk,
  -- Recommendation text
  CASE
    WHEN acwr_zone = 'high_risk' AND monotony_zone = 'high_monotony' THEN
      'Load spiking + too monotonous. Deload this week + vary session intensity.'
    WHEN acwr_zone = 'high_risk' THEN
      'Acute load spike. Reduce weekly volume 30-40%% this week.'
    WHEN monotony_zone = 'high_monotony' THEN
      'Training too monotonous. Add easy + hard days, avoid same load daily.'
    WHEN strain_zone = 'high_strain' THEN
      'Strain very high. Schedule a deload week.'
    WHEN strain_zone = 'elevated_strain' THEN
      'Strain elevated. Monitor recovery metrics closely this week.'
    WHEN acwr_zone = 'detraining' THEN
      'Load too low vs baseline. Add volume gradually to rebuild.'
    ELSE NULL
  END AS recommendation
FROM latest_per_user;

COMMENT ON VIEW current_overtraining_risk IS
  'Unified overtraining risk snapshot per user: ACWR + monotony + strain. '
  'composite_risk bands: low / moderate / high / insufficient_data. '
  'Includes actionable recommendation text.';

COMMIT;
