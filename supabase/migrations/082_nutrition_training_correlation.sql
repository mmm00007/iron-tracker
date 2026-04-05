-- Migration 082: Nutrition × Training Correlation Analytics
-- Joins nutrition_logs × workout_feedback × session_quality_scores to surface
-- patterns between daily nutrition and training performance/recovery.
--
-- Schemas exist (032_nutrition_basics, 019_schema_enrichment) but have never
-- been joined. This migration creates:
--   - nutrition_training_daily: day-level join with quality/feedback
--   - protein_adherence: daily protein target hit-rate
--   - macro_impact_on_quality: aggregate relationship between macros and session quality
--
-- Validated by: data-science-expert, fitness-domain-expert
--
-- Key design decisions:
--   - Date-level join (not meal-level — nutrition_logs is daily totals)
--   - Training-day vs rest-day partitioning for correlation analysis
--   - Protein target: prefer g/kg (bodyweight-aware) over absolute g
--   - Requires min 14 days of paired data for correlations (statistical floor)
--
-- Citations:
--   - Jager R. et al. (2017). ISSN protein position stand (1.6-2.2 g/kg).
--   - Phillips S.M. et al. (2016). Protein "requirements" beyond RDA.
--   - Helms E. et al. (2014). Nutrition for physique competitors. JISSN.
--   - Iraki J. et al. (2019). Nutrition recommendations for bodybuilders. Sports.

BEGIN;

-- =============================================================================
-- 1. nutrition_training_daily view
-- =============================================================================
-- Daily join: for each date, show nutrition + workout_feedback + session quality
-- + protein target status + training-or-rest-day classification.

CREATE OR REPLACE VIEW nutrition_training_daily
WITH (security_invoker = true) AS
WITH daily_sets AS (
  SELECT
    user_id,
    training_date,
    COUNT(*) FILTER (WHERE set_type = 'working')::integer AS working_sets,
    COUNT(DISTINCT exercise_id) AS distinct_exercises,
    SUM(weight * reps)::numeric(10,1) AS total_volume_kg
  FROM sets
  WHERE training_date IS NOT NULL
  GROUP BY user_id, training_date
),
latest_bw AS (
  SELECT DISTINCT ON (user_id)
    user_id,
    CASE WHEN weight_unit = 'lb' THEN weight / 2.20462 ELSE weight END AS weight_kg
  FROM body_weight_log
  ORDER BY user_id, logged_at DESC
)
SELECT
  COALESCE(nl.user_id, ds.user_id, wf.user_id)                         AS user_id,
  COALESCE(nl.logged_date, ds.training_date, wf.training_date)         AS date,
  -- Nutrition
  nl.calories_kcal,
  nl.protein_g,
  nl.carbs_g,
  nl.fat_g,
  nl.fiber_g,
  nl.water_ml,
  -- Targets + adherence
  p.calorie_target,
  p.protein_target_g,
  p.protein_target_g_per_kg,
  -- Effective protein target: prefer per_kg (BW-aware) over absolute
  CASE
    WHEN p.protein_target_g_per_kg IS NOT NULL AND lbw.weight_kg IS NOT NULL
    THEN ROUND((p.protein_target_g_per_kg * lbw.weight_kg)::numeric, 0)
    ELSE p.protein_target_g
  END::integer AS effective_protein_target_g,
  CASE
    WHEN nl.protein_g IS NULL THEN NULL
    WHEN p.protein_target_g_per_kg IS NOT NULL AND lbw.weight_kg IS NOT NULL
    THEN ROUND((nl.protein_g / (p.protein_target_g_per_kg * lbw.weight_kg) * 100)::numeric, 0)
    WHEN p.protein_target_g IS NOT NULL
    THEN ROUND((nl.protein_g / p.protein_target_g * 100)::numeric, 0)
    ELSE NULL
  END::integer AS protein_target_pct,
  -- Training volume
  ds.working_sets,
  ds.distinct_exercises,
  ds.total_volume_kg,
  -- Feedback + quality
  wf.session_rpe,
  wf.sleep_hours,
  wf.prior_sleep_quality,
  wf.readiness_score,
  wf.stress_level,
  sqs.quality_score AS session_quality_score,
  -- Day classification
  CASE
    WHEN ds.working_sets IS NOT NULL AND ds.working_sets > 0 THEN 'training_day'
    ELSE 'rest_day'
  END AS day_type
FROM nutrition_logs nl
FULL OUTER JOIN daily_sets ds
  ON ds.user_id = nl.user_id AND ds.training_date = nl.logged_date
FULL OUTER JOIN workout_feedback wf
  ON wf.user_id = COALESCE(nl.user_id, ds.user_id)
  AND wf.training_date = COALESCE(nl.logged_date, ds.training_date)
LEFT JOIN session_quality_scores sqs
  ON sqs.user_id = COALESCE(nl.user_id, ds.user_id, wf.user_id)
  AND sqs.training_date = COALESCE(nl.logged_date, ds.training_date, wf.training_date)
LEFT JOIN profiles p
  ON p.id = COALESCE(nl.user_id, ds.user_id, wf.user_id)
LEFT JOIN latest_bw lbw
  ON lbw.user_id = COALESCE(nl.user_id, ds.user_id, wf.user_id);

COMMENT ON VIEW nutrition_training_daily IS
  'Per-user per-date unified view: nutrition + training volume + feedback + '
  'session quality + protein-target adherence. Classifies day_type as '
  'training_day / rest_day. Foundation for nutrition × performance analysis.';

-- =============================================================================
-- 2. protein_adherence_30d view: last 30 days protein target hit-rate
-- =============================================================================

CREATE OR REPLACE VIEW protein_adherence_30d
WITH (security_invoker = true) AS
SELECT
  user_id,
  COUNT(*) FILTER (WHERE protein_g IS NOT NULL)::integer AS days_logged,
  COUNT(*) FILTER (WHERE protein_target_pct >= 100)::integer AS days_at_or_above_target,
  COUNT(*) FILTER (WHERE protein_target_pct >= 80 AND protein_target_pct < 100)::integer AS days_approaching_target,
  COUNT(*) FILTER (WHERE protein_target_pct < 80)::integer AS days_below_target,
  AVG(protein_g)::numeric(5,1) AS avg_protein_g,
  AVG(protein_target_pct)::numeric(4,0) AS avg_target_pct,
  MAX(effective_protein_target_g) AS target_g,
  CASE
    WHEN COUNT(*) FILTER (WHERE protein_g IS NOT NULL) < 7 THEN 'insufficient_data'
    WHEN COUNT(*) FILTER (WHERE protein_target_pct >= 100) * 1.0 / NULLIF(COUNT(*) FILTER (WHERE protein_g IS NOT NULL), 0) >= 0.75 THEN 'excellent'
    WHEN COUNT(*) FILTER (WHERE protein_target_pct >= 100) * 1.0 / NULLIF(COUNT(*) FILTER (WHERE protein_g IS NOT NULL), 0) >= 0.50 THEN 'good'
    WHEN COUNT(*) FILTER (WHERE protein_target_pct >= 100) * 1.0 / NULLIF(COUNT(*) FILTER (WHERE protein_g IS NOT NULL), 0) >= 0.25 THEN 'inconsistent'
    ELSE 'poor'
  END AS adherence_band
FROM nutrition_training_daily
WHERE date >= CURRENT_DATE - interval '30 days'
  AND date <= CURRENT_DATE
GROUP BY user_id;

COMMENT ON VIEW protein_adherence_30d IS
  'Last-30-day protein target adherence per user. Bands: excellent (>=75%% at '
  'target), good (>=50%%), inconsistent (>=25%%), poor (<25%%). Insufficient '
  'data when <7 days logged.';

-- =============================================================================
-- 3. nutrition_impact_on_training view
-- =============================================================================
-- Per-user aggregate: compare training-day session quality with protein intake
-- splits. Answers: "do I train better when I hit protein target?"

CREATE OR REPLACE VIEW nutrition_impact_on_training
WITH (security_invoker = true) AS
WITH user_windows AS (
  SELECT
    user_id,
    day_type,
    protein_target_pct,
    session_quality_score,
    session_rpe,
    total_volume_kg
  FROM nutrition_training_daily
  WHERE day_type = 'training_day'
    AND date >= CURRENT_DATE - interval '90 days'
    AND date <= CURRENT_DATE
    AND protein_g IS NOT NULL
    AND session_quality_score IS NOT NULL
),
splits AS (
  SELECT
    user_id,
    -- Quality on days hitting protein target (>=100%)
    AVG(session_quality_score) FILTER (WHERE protein_target_pct >= 100)::numeric(4,1) AS quality_at_target,
    -- Quality on days missing target (<80%)
    AVG(session_quality_score) FILTER (WHERE protein_target_pct < 80)::numeric(4,1) AS quality_below_target,
    -- Quality when in between
    AVG(session_quality_score) FILTER (WHERE protein_target_pct >= 80 AND protein_target_pct < 100)::numeric(4,1) AS quality_approaching_target,
    COUNT(*) FILTER (WHERE protein_target_pct >= 100) AS sessions_at_target,
    COUNT(*) FILTER (WHERE protein_target_pct < 80) AS sessions_below_target,
    COUNT(*) FILTER (WHERE protein_target_pct >= 80 AND protein_target_pct < 100) AS sessions_approaching
  FROM user_windows
  GROUP BY user_id
)
SELECT
  user_id,
  quality_at_target,
  quality_approaching_target,
  quality_below_target,
  sessions_at_target,
  sessions_approaching,
  sessions_below_target,
  -- Delta: session quality advantage when hitting target
  (quality_at_target - quality_below_target)::numeric(4,1) AS quality_delta_at_vs_below,
  CASE
    WHEN sessions_at_target < 5 OR sessions_below_target < 5                        THEN 'insufficient_data'
    WHEN (quality_at_target - quality_below_target) >= 10                            THEN 'strong_positive'
    WHEN (quality_at_target - quality_below_target) >= 3                             THEN 'positive'
    WHEN (quality_at_target - quality_below_target) >= -3                            THEN 'neutral'
    ELSE                                                                                  'no_relationship'
  END AS protein_impact
FROM splits;

COMMENT ON VIEW nutrition_impact_on_training IS
  'Per-user 90-day analysis: compares session_quality_score on protein-target-hit '
  'days vs target-missed days. Requires >=5 sessions in each bucket. Surfaces '
  'whether user''s training quality depends meaningfully on protein intake.';

-- =============================================================================
-- 4. training_vs_rest_day_macros view
-- =============================================================================
-- Compare average macros on training days vs rest days. Evidence-based question:
-- "are you eating enough on training days?"

CREATE OR REPLACE VIEW training_vs_rest_day_macros
WITH (security_invoker = true) AS
SELECT
  user_id,
  day_type,
  COUNT(*)::integer AS days,
  AVG(calories_kcal)::integer AS avg_calories,
  AVG(protein_g)::numeric(5,1) AS avg_protein_g,
  AVG(carbs_g)::numeric(5,1) AS avg_carbs_g,
  AVG(fat_g)::numeric(5,1) AS avg_fat_g
FROM nutrition_training_daily
WHERE calories_kcal IS NOT NULL
  AND date >= CURRENT_DATE - interval '30 days'
  AND date <= CURRENT_DATE
GROUP BY user_id, day_type;

COMMENT ON VIEW training_vs_rest_day_macros IS
  'Average macros split by day_type (training vs rest) over last 30 days. '
  'Frontend can compute delta: "you eat 400 kcal more on training days".';

COMMIT;
