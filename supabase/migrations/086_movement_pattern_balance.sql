-- Migration 086: Movement Pattern Balance Analytics
-- Injury-prevention analytics that expose volume imbalances between
-- antagonist pairs (push/pull, quad/ham, etc.) and movement patterns
-- over a trailing 4-week window.
--
-- Kolber 2009: push:pull volume ratios >1.5:1 predict shoulder impingement.
-- McGill 2015: quad:ham imbalances >2:1 elevate ACL injury risk.
-- NSCA 2016: balanced movement-pattern programming reduces overuse injury.
--
-- Composes existing: muscle_antagonist_pairs (023), exercise_muscles +
-- activation_percent, exercises.movement_pattern/exercise_type, sets.
--
-- Validated by: sports-medicine-expert, fitness-domain-expert

BEGIN;

-- =============================================================================
-- 1. antagonist_balance_4w view
-- =============================================================================
-- Volume ratio per antagonist pair over last 4 weeks. Flags >1.5:1 or <0.5:1.

CREATE OR REPLACE VIEW antagonist_balance_4w
WITH (security_invoker = true) AS
WITH muscle_volume_4w AS (
  SELECT
    s.user_id,
    em.muscle_group_id,
    SUM(
      COALESCE(em.activation_percent, CASE WHEN em.is_primary THEN 100 ELSE 50 END)::numeric / 100
    ) AS effective_sets_4w
  FROM sets s
  JOIN exercise_muscles em ON em.exercise_id = s.exercise_id
  WHERE s.training_date IS NOT NULL
    AND s.training_date >= CURRENT_DATE - 28
    AND s.training_date <= CURRENT_DATE
    AND s.set_type = 'working'
    AND s.reps > 0
  GROUP BY s.user_id, em.muscle_group_id
)
SELECT
  mva.user_id,
  map.pair_name,
  map.pair_strength,
  mg_a.name AS muscle_a_name,
  mg_b.name AS muscle_b_name,
  COALESCE(mva.effective_sets_4w, 0)::numeric(5,1) AS muscle_a_sets_4w,
  COALESCE(mvb.effective_sets_4w, 0)::numeric(5,1) AS muscle_b_sets_4w,
  -- Ratio always >= 1 (larger / smaller)
  CASE
    WHEN COALESCE(mva.effective_sets_4w, 0) = 0 AND COALESCE(mvb.effective_sets_4w, 0) = 0 THEN NULL
    WHEN COALESCE(mvb.effective_sets_4w, 0) = 0 THEN 99::numeric(4,2)
    WHEN COALESCE(mva.effective_sets_4w, 0) = 0 THEN 99::numeric(4,2)
    ELSE
      ROUND(
        (GREATEST(mva.effective_sets_4w, mvb.effective_sets_4w)
         / NULLIF(LEAST(mva.effective_sets_4w, mvb.effective_sets_4w), 0))::numeric,
        2
      )
  END AS imbalance_ratio,
  -- Dominant muscle
  CASE
    WHEN COALESCE(mva.effective_sets_4w, 0) > COALESCE(mvb.effective_sets_4w, 0) THEN mg_a.name
    WHEN COALESCE(mvb.effective_sets_4w, 0) > COALESCE(mva.effective_sets_4w, 0) THEN mg_b.name
    ELSE NULL
  END AS dominant_muscle,
  -- Balance band
  CASE
    WHEN COALESCE(mva.effective_sets_4w, 0) = 0 AND COALESCE(mvb.effective_sets_4w, 0) = 0 THEN 'no_data'
    WHEN COALESCE(mva.effective_sets_4w, 0) = 0 OR COALESCE(mvb.effective_sets_4w, 0) = 0 THEN 'severe_imbalance'
    WHEN GREATEST(mva.effective_sets_4w, mvb.effective_sets_4w)
         / NULLIF(LEAST(mva.effective_sets_4w, mvb.effective_sets_4w), 0) < 1.2 THEN 'balanced'
    WHEN GREATEST(mva.effective_sets_4w, mvb.effective_sets_4w)
         / NULLIF(LEAST(mva.effective_sets_4w, mvb.effective_sets_4w), 0) < 1.5 THEN 'minor_imbalance'
    WHEN GREATEST(mva.effective_sets_4w, mvb.effective_sets_4w)
         / NULLIF(LEAST(mva.effective_sets_4w, mvb.effective_sets_4w), 0) < 2.0 THEN 'moderate_imbalance'
    ELSE                                                                             'severe_imbalance'
  END AS balance_status
FROM muscle_antagonist_pairs map
JOIN muscle_groups mg_a ON mg_a.id = map.muscle_a_id
JOIN muscle_groups mg_b ON mg_b.id = map.muscle_b_id
LEFT JOIN muscle_volume_4w mva ON mva.muscle_group_id = map.muscle_a_id
FULL OUTER JOIN muscle_volume_4w mvb ON mvb.muscle_group_id = map.muscle_b_id AND mvb.user_id = mva.user_id
WHERE map.pair_strength = 'strong'
  AND (mva.user_id IS NOT NULL OR mvb.user_id IS NOT NULL);

COMMENT ON VIEW antagonist_balance_4w IS
  'Per-user antagonist-pair volume balance over last 4 weeks. Bands: '
  'balanced (<1.2x), minor (<1.5x), moderate (<2.0x), severe (>=2.0x). '
  'Kolber 2009: push:pull >1.5:1 predicts shoulder impingement.';

-- =============================================================================
-- 2. movement_pattern_distribution_4w view
-- =============================================================================
-- Volume distribution across exercises.movement_pattern over 4 weeks.

CREATE OR REPLACE VIEW movement_pattern_distribution_4w
WITH (security_invoker = true) AS
WITH pattern_sets AS (
  SELECT
    s.user_id,
    COALESCE(e.movement_pattern, 'unclassified') AS movement_pattern,
    COUNT(*)::integer AS working_sets,
    SUM(s.weight * s.reps)::numeric(10,1) AS total_volume_kg
  FROM sets s
  JOIN exercises e ON e.id = s.exercise_id
  WHERE s.training_date IS NOT NULL
    AND s.training_date >= CURRENT_DATE - 28
    AND s.training_date <= CURRENT_DATE
    AND s.set_type = 'working'
    AND s.reps > 0
  GROUP BY s.user_id, COALESCE(e.movement_pattern, 'unclassified')
),
totals AS (
  SELECT user_id, SUM(working_sets) AS total_sets
  FROM pattern_sets
  GROUP BY user_id
)
SELECT
  ps.user_id,
  ps.movement_pattern,
  ps.working_sets,
  ps.total_volume_kg,
  ROUND((ps.working_sets::numeric / NULLIF(t.total_sets, 0) * 100), 1) AS pct_of_total_sets
FROM pattern_sets ps
JOIN totals t ON t.user_id = ps.user_id
ORDER BY ps.user_id, ps.working_sets DESC;

COMMENT ON VIEW movement_pattern_distribution_4w IS
  'Per-user working-set distribution across movement_patterns over 4 weeks. '
  'Used to flag missing patterns (e.g. no hip_hinge) or overemphasis '
  '(e.g. 60%% horizontal_push).';

-- =============================================================================
-- 3. push_pull_ratio_4w view
-- =============================================================================
-- Specifically surfaces push:pull volume ratio (most common injury-risk pattern).

CREATE OR REPLACE VIEW push_pull_ratio_4w
WITH (security_invoker = true) AS
WITH push_pull_sets AS (
  SELECT
    s.user_id,
    SUM(CASE WHEN e.movement_pattern IN ('horizontal_push','vertical_push') THEN 1 ELSE 0 END)::integer AS push_sets,
    SUM(CASE WHEN e.movement_pattern IN ('horizontal_pull','vertical_pull') THEN 1 ELSE 0 END)::integer AS pull_sets
  FROM sets s
  JOIN exercises e ON e.id = s.exercise_id
  WHERE s.training_date IS NOT NULL
    AND s.training_date >= CURRENT_DATE - 28
    AND s.training_date <= CURRENT_DATE
    AND s.set_type = 'working'
    AND s.reps > 0
  GROUP BY s.user_id
)
SELECT
  user_id,
  push_sets,
  pull_sets,
  CASE
    WHEN pull_sets = 0 AND push_sets = 0 THEN NULL
    WHEN pull_sets = 0 THEN 99::numeric(4,2)
    ELSE ROUND((push_sets::numeric / pull_sets)::numeric, 2)
  END AS push_pull_ratio,
  CASE
    WHEN push_sets = 0 AND pull_sets = 0 THEN 'no_data'
    WHEN push_sets = 0 OR pull_sets = 0 THEN 'missing_one_side'
    WHEN (push_sets::numeric / pull_sets) < 0.67 THEN 'pull_dominant'
    WHEN (push_sets::numeric / pull_sets) <= 1.5 THEN 'balanced'
    WHEN (push_sets::numeric / pull_sets) <= 2.0 THEN 'push_dominant'
    ELSE                                                'severe_push_dominance'
  END AS balance_status,
  CASE
    WHEN push_sets = 0 OR pull_sets = 0 THEN
      'Missing full push or pull work. Add both directions for shoulder health.'
    WHEN (push_sets::numeric / pull_sets) > 1.5 THEN
      'Push:pull ratio ' || ROUND((push_sets::numeric / pull_sets)::numeric, 2)::text
      || ':1 — add pulling volume to restore balance.'
    WHEN (pull_sets::numeric / push_sets) > 1.5 THEN
      'Pull:push ratio ' || ROUND((pull_sets::numeric / push_sets)::numeric, 2)::text
      || ':1 — fine for rehab but add pushing for full development.'
    ELSE NULL
  END AS recommendation
FROM push_pull_sets;

COMMENT ON VIEW push_pull_ratio_4w IS
  'Per-user push:pull working-set ratio (4 weeks). Based on exercises.movement_pattern. '
  'Bands: pull_dominant (<0.67), balanced (0.67-1.5), push_dominant (1.5-2), severe (>2). '
  'Kolber 2009: >1.5:1 push-dominance predicts shoulder pathology.';

-- =============================================================================
-- 4. balance_alerts_current view
-- =============================================================================
-- Surfaces only the imbalances that warrant user action.

CREATE OR REPLACE VIEW balance_alerts_current
WITH (security_invoker = true) AS
SELECT
  user_id,
  'antagonist'::text AS alert_category,
  pair_name AS alert_subject,
  format('%s is %sx your %s volume — rebalance over next 2 weeks',
         dominant_muscle,
         imbalance_ratio::text,
         CASE WHEN dominant_muscle = muscle_a_name THEN muscle_b_name ELSE muscle_a_name END)::text AS message,
  balance_status AS severity
FROM antagonist_balance_4w
WHERE balance_status IN ('moderate_imbalance','severe_imbalance')
UNION ALL
SELECT
  user_id,
  'push_pull'::text,
  'Push:Pull balance',
  COALESCE(recommendation, 'Push:pull distribution needs attention'),
  balance_status
FROM push_pull_ratio_4w
WHERE balance_status IN ('missing_one_side','severe_push_dominance','push_dominant');

COMMENT ON VIEW balance_alerts_current IS
  'Actionable balance alerts only — filters out balanced/minor imbalances. '
  'Surfaces antagonist-pair + push:pull warnings. Used by coaching UI.';

COMMIT;
