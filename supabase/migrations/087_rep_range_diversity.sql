-- Migration 087: Rep Range Diversity Analysis
-- Analyzes distribution of working-set rep counts per exercise over last
-- 12 weeks. Flags users stuck in narrow rep ranges — a common plateau
-- driver per Schoenfeld's mechanical-tension-diversity principle.
--
-- Rep-range categories (Schoenfeld 2017 meta-analysis):
--   1-3   max_strength
--   4-6   strength
--   7-10  strength_hypertrophy
--   11-15 hypertrophy
--   16+   endurance_metabolic
--
-- Validated by: fitness-domain-expert, data-science-expert
--
-- Citations:
--   - Schoenfeld B.J. et al. (2017). Effects of different load combinations on
--     hypertrophy vs strength meta-analysis. J Strength Cond Res.
--   - Helms E. (2018). Muscle and Strength Pyramid — rep range variation.
--   - Morton R.W. et al. (2016). Neither load nor systemic hormones
--     determine resistance training-mediated hypertrophy.

BEGIN;

-- =============================================================================
-- 1. rep_range_distribution_per_exercise view
-- =============================================================================
-- Per-user per-exercise histogram of rep counts used in working sets (last 12 weeks).

CREATE OR REPLACE VIEW rep_range_distribution_per_exercise
WITH (security_invoker = true) AS
WITH rep_bucketed AS (
  SELECT
    s.user_id,
    s.exercise_id,
    CASE
      WHEN s.reps <= 3  THEN 'max_strength'
      WHEN s.reps <= 6  THEN 'strength'
      WHEN s.reps <= 10 THEN 'strength_hypertrophy'
      WHEN s.reps <= 15 THEN 'hypertrophy'
      ELSE                   'endurance_metabolic'
    END AS rep_range_category,
    s.reps
  FROM sets s
  WHERE s.training_date IS NOT NULL
    AND s.training_date >= CURRENT_DATE - 84
    AND s.training_date <= CURRENT_DATE
    AND s.set_type = 'working'
    AND s.reps > 0
),
totals AS (
  SELECT user_id, exercise_id, COUNT(*) AS total_sets
  FROM rep_bucketed
  GROUP BY user_id, exercise_id
)
SELECT
  rb.user_id,
  rb.exercise_id,
  e.name AS exercise_name,
  rb.rep_range_category,
  COUNT(*)::integer AS sets,
  MIN(rb.reps)::integer AS min_reps,
  MAX(rb.reps)::integer AS max_reps,
  ROUND(AVG(rb.reps), 1)::numeric(3,1) AS avg_reps,
  ROUND((COUNT(*)::numeric / t.total_sets * 100), 1) AS pct_of_exercise_sets,
  t.total_sets
FROM rep_bucketed rb
JOIN exercises e ON e.id = rb.exercise_id
JOIN totals t ON t.user_id = rb.user_id AND t.exercise_id = rb.exercise_id
GROUP BY rb.user_id, rb.exercise_id, e.name, rb.rep_range_category, t.total_sets;

COMMENT ON VIEW rep_range_distribution_per_exercise IS
  'Per-user per-exercise rep-range histogram (last 12 weeks). '
  'Buckets: max_strength (1-3), strength (4-6), strength_hypertrophy (7-10), '
  'hypertrophy (11-15), endurance_metabolic (16+). Schoenfeld 2017.';

-- =============================================================================
-- 2. rep_range_rut_detection view
-- =============================================================================
-- Per-user per-exercise: are they stuck in one rep range?
-- A "rut" = >80% of working sets in a single category AND >=12 sets logged.

CREATE OR REPLACE VIEW rep_range_rut_detection
WITH (security_invoker = true) AS
WITH exercise_concentration AS (
  SELECT
    user_id,
    exercise_id,
    exercise_name,
    MAX(total_sets) AS total_sets,
    MAX(pct_of_exercise_sets) AS max_single_range_pct,
    (ARRAY_AGG(rep_range_category ORDER BY pct_of_exercise_sets DESC))[1] AS dominant_range,
    (ARRAY_AGG(avg_reps ORDER BY pct_of_exercise_sets DESC))[1] AS dominant_avg_reps,
    COUNT(*)::integer AS distinct_ranges_used
  FROM rep_range_distribution_per_exercise
  GROUP BY user_id, exercise_id, exercise_name
)
SELECT
  user_id,
  exercise_id,
  exercise_name,
  total_sets,
  distinct_ranges_used,
  max_single_range_pct,
  dominant_range,
  dominant_avg_reps,
  CASE
    WHEN total_sets < 12 THEN 'insufficient_data'
    WHEN max_single_range_pct >= 90 AND distinct_ranges_used = 1 THEN 'severe_rut'
    WHEN max_single_range_pct >= 80 AND distinct_ranges_used <= 2 THEN 'rut'
    WHEN max_single_range_pct >= 65 THEN 'narrow_focus'
    WHEN distinct_ranges_used >= 3 THEN 'diverse'
    ELSE                                 'moderate'
  END AS diversity_status,
  CASE
    WHEN total_sets < 12 THEN NULL
    WHEN max_single_range_pct >= 80 AND dominant_range = 'max_strength' THEN
      'You only do heavy triples on this lift. Try one week of 8-10s for hypertrophy.'
    WHEN max_single_range_pct >= 80 AND dominant_range = 'strength' THEN
      'You only do 4-6s on this lift. Add a week of 10-12s or 2-3s for stimulus variety.'
    WHEN max_single_range_pct >= 80 AND dominant_range = 'strength_hypertrophy' THEN
      'You only do 7-10s on this lift. Try 4-6s for strength or 12-15s for metabolic work.'
    WHEN max_single_range_pct >= 80 AND dominant_range = 'hypertrophy' THEN
      'You only do 11-15s on this lift. Add a heavy week (4-8 reps) to build base strength.'
    WHEN max_single_range_pct >= 80 AND dominant_range = 'endurance_metabolic' THEN
      'You only do high-rep work on this lift. Drop reps to 6-10 for hypertrophy stimulus.'
    ELSE NULL
  END AS recommendation
FROM exercise_concentration;

COMMENT ON VIEW rep_range_rut_detection IS
  'Per-user per-exercise rep-range concentration detection. Flags when >80%% '
  'of working sets fall in one rep-range bucket (rut) or >90%% in only one '
  'category (severe_rut). Includes actionable rep-range diversification '
  'recommendations. Min 12 sets required for detection.';

-- =============================================================================
-- 3. user_rep_range_overview view: aggregate per user
-- =============================================================================
-- Aggregate user's overall rep-range distribution across ALL exercises.

CREATE OR REPLACE VIEW user_rep_range_overview
WITH (security_invoker = true) AS
WITH user_totals AS (
  SELECT
    s.user_id,
    CASE
      WHEN s.reps <= 3  THEN 'max_strength'
      WHEN s.reps <= 6  THEN 'strength'
      WHEN s.reps <= 10 THEN 'strength_hypertrophy'
      WHEN s.reps <= 15 THEN 'hypertrophy'
      ELSE                   'endurance_metabolic'
    END AS rep_range_category,
    COUNT(*) AS sets
  FROM sets s
  WHERE s.training_date IS NOT NULL
    AND s.training_date >= CURRENT_DATE - 84
    AND s.training_date <= CURRENT_DATE
    AND s.set_type = 'working'
    AND s.reps > 0
  GROUP BY s.user_id, rep_range_category
),
grand_totals AS (
  SELECT user_id, SUM(sets) AS total FROM user_totals GROUP BY user_id
)
SELECT
  ut.user_id,
  ut.rep_range_category,
  ut.sets::integer,
  ROUND((ut.sets::numeric / g.total * 100), 1) AS pct_of_all_working_sets
FROM user_totals ut
JOIN grand_totals g ON g.user_id = ut.user_id
ORDER BY ut.user_id, CASE ut.rep_range_category
  WHEN 'max_strength' THEN 1 WHEN 'strength' THEN 2 WHEN 'strength_hypertrophy' THEN 3
  WHEN 'hypertrophy' THEN 4 WHEN 'endurance_metabolic' THEN 5
END;

COMMENT ON VIEW user_rep_range_overview IS
  'Per-user aggregate rep-range distribution across ALL working sets in last '
  '12 weeks. Useful for "you spend 60%% of sets in 7-10 rep range" summary.';

COMMIT;
