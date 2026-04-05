-- Migration 077: Body Composition Trends
-- Derives BMI, FFMI, lean mass, fat mass from body_weight_log + profiles.height_cm.
-- Adds weekly/monthly rolling views for trend visualization.
--
-- Validated by: data-science-expert (formulas), fitness-domain-expert (FFMI interpretation)
--
-- Key design decisions:
--   - body_composition_snapshot view: row-level derivations (always unit-normalized to kg)
--   - body_composition_weekly view: 4-week rolling averages + deltas (trend detection)
--   - Unit-agnostic: normalizes lb → kg for all computations
--   - NULL-tolerant: FFMI NULL when body_fat_pct unknown
--
-- FFMI reference (Kouri et al. 1995):
--   18-20 = average untrained
--   20-22 = athletic
--   22-24 = advanced
--   24-25 = near drug-free natural ceiling
--   >25 = suggests enhancement (not clinical diagnosis)
--
-- BMI limitations: doesn't distinguish muscle from fat. Useful only alongside FFMI
-- or body-fat-aware metrics for strength athletes.
--
-- Citations:
--   - Kouri E.M. et al. (1995). FFMI as a screen for androgen use. Clin J Sport Med.
--   - Schutz Y. et al. (2002). Fat-free mass index reference ranges.
--   - Tetzlaff et al. (2019). DXA vs calculated lean mass agreement.

BEGIN;

-- =============================================================================
-- 1. body_composition_snapshot view
-- =============================================================================
-- Per-entry derivations: each body_weight_log row with computed BMI/FFMI/lean/fat.

CREATE OR REPLACE VIEW body_composition_snapshot
WITH (security_invoker = true) AS
WITH normalized AS (
  SELECT
    bwl.id,
    bwl.user_id,
    bwl.logged_at,
    bwl.logged_at::date AS logged_date,
    bwl.weight,
    bwl.weight_unit,
    bwl.body_fat_pct,
    bwl.source,
    -- Convert to kg for all computations
    CASE WHEN bwl.weight_unit = 'lb' THEN bwl.weight / 2.20462 ELSE bwl.weight END AS weight_kg,
    p.height_cm
  FROM body_weight_log bwl
  LEFT JOIN profiles p ON p.id = bwl.user_id
)
SELECT
  n.id,
  n.user_id,
  n.logged_at,
  n.logged_date,
  n.weight,
  n.weight_unit,
  ROUND(n.weight_kg::numeric, 2) AS weight_kg,
  n.body_fat_pct,
  n.height_cm,
  n.source,
  -- BMI = kg / m^2
  CASE
    WHEN n.height_cm IS NOT NULL AND n.height_cm > 0
    THEN ROUND((n.weight_kg / POWER(n.height_cm / 100.0, 2))::numeric, 2)
    ELSE NULL
  END AS bmi,
  -- Lean mass (kg) = weight × (1 - bf/100)
  CASE
    WHEN n.body_fat_pct IS NOT NULL
    THEN ROUND((n.weight_kg * (1 - n.body_fat_pct / 100.0))::numeric, 2)
    ELSE NULL
  END AS lean_mass_kg,
  -- Fat mass (kg)
  CASE
    WHEN n.body_fat_pct IS NOT NULL
    THEN ROUND((n.weight_kg * n.body_fat_pct / 100.0)::numeric, 2)
    ELSE NULL
  END AS fat_mass_kg,
  -- FFMI = lean_mass / (height_m)^2 (height-normalized lean mass)
  CASE
    WHEN n.height_cm IS NOT NULL AND n.height_cm > 0 AND n.body_fat_pct IS NOT NULL
    THEN ROUND((
      (n.weight_kg * (1 - n.body_fat_pct / 100.0))
      / POWER(n.height_cm / 100.0, 2)
    )::numeric, 2)
    ELSE NULL
  END AS ffmi,
  -- Normalized FFMI (adjusted to 1.80m standard; Kouri 1995 formula)
  CASE
    WHEN n.height_cm IS NOT NULL AND n.height_cm > 0 AND n.body_fat_pct IS NOT NULL
    THEN ROUND((
      (n.weight_kg * (1 - n.body_fat_pct / 100.0)) / POWER(n.height_cm / 100.0, 2)
      + 6.1 * (1.80 - n.height_cm / 100.0)
    )::numeric, 2)
    ELSE NULL
  END AS normalized_ffmi,
  -- BMI classification
  CASE
    WHEN n.height_cm IS NULL THEN NULL
    WHEN (n.weight_kg / POWER(n.height_cm / 100.0, 2)) < 18.5 THEN 'underweight'
    WHEN (n.weight_kg / POWER(n.height_cm / 100.0, 2)) < 25.0 THEN 'normal'
    WHEN (n.weight_kg / POWER(n.height_cm / 100.0, 2)) < 30.0 THEN 'overweight'
    ELSE 'obese'
  END AS bmi_classification,
  -- FFMI classification (Kouri 1995 reference)
  CASE
    WHEN n.body_fat_pct IS NULL OR n.height_cm IS NULL THEN NULL
    WHEN ((n.weight_kg * (1 - n.body_fat_pct / 100.0)) / POWER(n.height_cm / 100.0, 2)) < 18 THEN 'untrained'
    WHEN ((n.weight_kg * (1 - n.body_fat_pct / 100.0)) / POWER(n.height_cm / 100.0, 2)) < 20 THEN 'average'
    WHEN ((n.weight_kg * (1 - n.body_fat_pct / 100.0)) / POWER(n.height_cm / 100.0, 2)) < 22 THEN 'athletic'
    WHEN ((n.weight_kg * (1 - n.body_fat_pct / 100.0)) / POWER(n.height_cm / 100.0, 2)) < 24 THEN 'advanced'
    WHEN ((n.weight_kg * (1 - n.body_fat_pct / 100.0)) / POWER(n.height_cm / 100.0, 2)) < 25 THEN 'near_natural_ceiling'
    ELSE 'above_natural_ceiling'
  END AS ffmi_classification
FROM normalized n;

COMMENT ON VIEW body_composition_snapshot IS
  'Per-log-entry body composition derivations: BMI, FFMI, lean/fat mass. '
  'Unit-agnostic (lb → kg normalized). NULL when required inputs missing. '
  'Kouri 1995 normalized FFMI adjusts for height.';

-- =============================================================================
-- 2. body_composition_weekly view: rolling weekly averages + trend direction
-- =============================================================================

CREATE OR REPLACE VIEW body_composition_weekly
WITH (security_invoker = true) AS
WITH weekly_avg AS (
  SELECT
    user_id,
    date_trunc('week', logged_date)::date AS week_start,
    AVG(weight_kg)::numeric(5,2) AS avg_weight_kg,
    AVG(body_fat_pct)::numeric(4,2) AS avg_body_fat_pct,
    AVG(lean_mass_kg)::numeric(5,2) AS avg_lean_mass_kg,
    AVG(fat_mass_kg)::numeric(5,2) AS avg_fat_mass_kg,
    AVG(bmi)::numeric(4,2) AS avg_bmi,
    AVG(ffmi)::numeric(4,2) AS avg_ffmi,
    AVG(normalized_ffmi)::numeric(4,2) AS avg_normalized_ffmi,
    COUNT(*)::integer AS entries_this_week
  FROM body_composition_snapshot
  GROUP BY user_id, date_trunc('week', logged_date)
),
with_lag AS (
  SELECT
    wa.*,
    LAG(wa.avg_weight_kg) OVER (PARTITION BY wa.user_id ORDER BY wa.week_start) AS prev_week_weight_kg,
    LAG(wa.avg_lean_mass_kg) OVER (PARTITION BY wa.user_id ORDER BY wa.week_start) AS prev_week_lean_kg,
    LAG(wa.avg_fat_mass_kg) OVER (PARTITION BY wa.user_id ORDER BY wa.week_start) AS prev_week_fat_kg,
    -- 4-week rolling average
    AVG(wa.avg_weight_kg) OVER (
      PARTITION BY wa.user_id ORDER BY wa.week_start
      ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
    )::numeric(5,2) AS weight_4w_rolling_avg,
    AVG(wa.avg_lean_mass_kg) OVER (
      PARTITION BY wa.user_id ORDER BY wa.week_start
      ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
    )::numeric(5,2) AS lean_mass_4w_rolling_avg
  FROM weekly_avg wa
)
SELECT
  user_id,
  week_start,
  avg_weight_kg,
  avg_body_fat_pct,
  avg_lean_mass_kg,
  avg_fat_mass_kg,
  avg_bmi,
  avg_ffmi,
  avg_normalized_ffmi,
  entries_this_week,
  weight_4w_rolling_avg,
  lean_mass_4w_rolling_avg,
  -- Week-over-week deltas
  (avg_weight_kg - prev_week_weight_kg)::numeric(5,2) AS weight_delta_kg,
  (avg_lean_mass_kg - prev_week_lean_kg)::numeric(5,2) AS lean_delta_kg,
  (avg_fat_mass_kg - prev_week_fat_kg)::numeric(5,2) AS fat_delta_kg,
  -- Trend direction based on delta vs rolling avg
  CASE
    WHEN prev_week_weight_kg IS NULL OR weight_4w_rolling_avg IS NULL THEN NULL
    WHEN avg_weight_kg > weight_4w_rolling_avg + 0.3 THEN 'gaining'
    WHEN avg_weight_kg < weight_4w_rolling_avg - 0.3 THEN 'losing'
    ELSE 'stable'
  END AS weight_trend,
  -- Recomp indicator: gaining lean while losing fat (or vice versa)
  CASE
    WHEN prev_week_lean_kg IS NULL OR prev_week_fat_kg IS NULL THEN NULL
    WHEN avg_lean_mass_kg > prev_week_lean_kg + 0.1 AND avg_fat_mass_kg < prev_week_fat_kg - 0.1 THEN 'recomposing'
    WHEN avg_lean_mass_kg > prev_week_lean_kg + 0.1 AND avg_fat_mass_kg > prev_week_fat_kg + 0.1 THEN 'bulking'
    WHEN avg_lean_mass_kg < prev_week_lean_kg - 0.1 AND avg_fat_mass_kg < prev_week_fat_kg - 0.1 THEN 'cutting'
    WHEN avg_lean_mass_kg < prev_week_lean_kg - 0.1 AND avg_fat_mass_kg > prev_week_fat_kg + 0.1 THEN 'reverse_recomp'
    ELSE 'maintaining'
  END AS body_comp_phase
FROM with_lag;

COMMENT ON VIEW body_composition_weekly IS
  'Weekly body-composition averages with 4-week rolling averages + W-o-W deltas. '
  'weight_trend: gaining/losing/stable (>0.3kg deviation from 4wk avg). '
  'body_comp_phase: recomposing/bulking/cutting/reverse_recomp/maintaining.';

-- =============================================================================
-- 3. body_composition_current view: most recent snapshot per user
-- =============================================================================

CREATE OR REPLACE VIEW body_composition_current
WITH (security_invoker = true) AS
SELECT DISTINCT ON (user_id)
  user_id, logged_at, logged_date,
  weight_kg, body_fat_pct, lean_mass_kg, fat_mass_kg,
  bmi, ffmi, normalized_ffmi, bmi_classification, ffmi_classification
FROM body_composition_snapshot
ORDER BY user_id, logged_at DESC;

COMMENT ON VIEW body_composition_current IS
  'Latest body composition snapshot per user. Powers home screen summary card.';

COMMIT;
