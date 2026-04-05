-- Migration 073: Injury-Aware Exercise Recommendations
-- Connects the existing injury_reports table (migration 027) with
-- exercise_joint_stress (migration 062) to surface safer alternatives.
--
-- Adds:
--   - body_area_to_joint() mapping function (strips lateralization)
--   - get_user_active_injury_joints() — joints the user should protect
--   - find_injury_safe_alternatives() — substitutes filtered by joint stress
--   - user_safe_exercise_filter — RLS-safe view for per-user screening
--
-- Validated by: sports-medicine-expert (injury-stress mapping), database-specialist
--
-- Key design decisions:
--   - Don't modify injury_reports (already well-designed)
--   - body_area → joint mapping: left_shoulder/right_shoulder both → 'shoulder'
--     (exercise_joint_stress tracks bilateral joints only)
--   - Only considers injuries where limits_training = true AND status IN
--     ('active', 'recovering', 'chronic')
--   - Threshold parameter lets caller balance safety vs selection variety
--
-- Citations:
--   - McGill S. (2016). Low Back Disorders — lumbar injury decision trees.
--   - Kibler W.B. (1998). Scapular dyskinesis and shoulder pain. AJSM.
--   - van Dyk N. et al. (2017). Return to play after muscle strain. BJSM.

BEGIN;

-- =============================================================================
-- 1. body_area_to_joint() — strip lateralization
-- =============================================================================

CREATE OR REPLACE FUNCTION body_area_to_joint(p_body_area text)
RETURNS text
LANGUAGE sql
IMMUTABLE
AS $$
  SELECT CASE
    WHEN p_body_area IN ('left_shoulder','right_shoulder')           THEN 'shoulder'
    WHEN p_body_area IN ('left_elbow','right_elbow')                 THEN 'elbow'
    WHEN p_body_area IN ('left_wrist','right_wrist',
                         'left_hand','right_hand')                   THEN 'wrist'
    WHEN p_body_area IN ('left_hip','right_hip')                     THEN 'hip'
    WHEN p_body_area IN ('left_knee','right_knee')                   THEN 'knee'
    WHEN p_body_area IN ('left_ankle','right_ankle',
                         'left_foot','right_foot')                   THEN 'ankle'
    WHEN p_body_area = 'lower_back'                                  THEN 'lumbar_spine'
    WHEN p_body_area = 'upper_back'                                  THEN 'thoracic_spine'
    WHEN p_body_area = 'neck'                                        THEN 'cervical_spine'
    ELSE NULL  -- muscle-body areas (calf, forearm, shin, chest, abdomen) have no joint mapping
  END;
$$;

COMMENT ON FUNCTION body_area_to_joint(text) IS
  'Maps injury_reports.body_area to exercise_joint_stress.joint, stripping '
  'lateralization. Muscle-specific body areas (calf, chest) return NULL.';

-- =============================================================================
-- 2. get_user_active_injury_joints()
-- =============================================================================
-- Returns the set of joints the user should currently protect.

CREATE OR REPLACE FUNCTION get_user_active_injury_joints(p_user_id uuid)
RETURNS TABLE (
  joint text,
  highest_pain_level smallint,
  body_areas text[],
  injury_count integer
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, pg_catalog
AS $$
  SELECT
    body_area_to_joint(ir.body_area) AS joint,
    MAX(ir.pain_level)::smallint     AS highest_pain_level,
    ARRAY_AGG(DISTINCT ir.body_area ORDER BY ir.body_area) AS body_areas,
    COUNT(*)::integer                AS injury_count
  FROM injury_reports ir
  WHERE ir.user_id = p_user_id
    AND ir.limits_training = true
    AND ir.status IN ('active', 'recovering', 'chronic')
    AND body_area_to_joint(ir.body_area) IS NOT NULL
  GROUP BY body_area_to_joint(ir.body_area);
$$;

COMMENT ON FUNCTION get_user_active_injury_joints(uuid) IS
  'Returns joints currently needing protection: active/recovering/chronic injuries '
  'with limits_training=true. Aggregates lateralized injuries. One row per joint.';

-- =============================================================================
-- 3. find_injury_safe_alternatives()
-- =============================================================================
-- Given an exercise, return alternatives with lower stress on the user's
-- injured joints. Preserves movement_pattern where possible.

CREATE OR REPLACE FUNCTION find_injury_safe_alternatives(
  p_user_id uuid,
  p_exercise_id uuid,
  p_max_stress_per_injured_joint smallint DEFAULT 1,
  p_limit integer DEFAULT 10
)
RETURNS TABLE (
  alternative_exercise_id uuid,
  alternative_name text,
  movement_pattern text,
  matches_source_movement boolean,
  max_stress_on_injured_joints smallint,
  total_joint_stress integer
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, pg_catalog
AS $$
  WITH source_movement AS (
    SELECT e.movement_pattern FROM exercises e WHERE e.id = p_exercise_id
  ),
  user_injured_joints AS (
    SELECT joint FROM get_user_active_injury_joints(p_user_id)
  ),
  candidate_stress AS (
    SELECT
      e.id,
      e.name,
      e.movement_pattern,
      COALESCE(MAX(ejs.stress_level) FILTER (
        WHERE ejs.joint IN (SELECT joint FROM user_injured_joints)
      ), 0)::smallint AS max_injured_joint_stress,
      COALESCE(SUM(ejs.stress_level), 0)::integer AS total_stress
    FROM exercises e
    LEFT JOIN exercise_joint_stress ejs ON ejs.exercise_id = e.id
    WHERE e.id != p_exercise_id
      AND e.created_by IS NULL  -- seed exercises only
    GROUP BY e.id, e.name, e.movement_pattern
  )
  SELECT
    cs.id,
    cs.name,
    cs.movement_pattern,
    (cs.movement_pattern IS NOT NULL
     AND cs.movement_pattern = (SELECT movement_pattern FROM source_movement))
      AS matches_source_movement,
    cs.max_injured_joint_stress,
    cs.total_stress
  FROM candidate_stress cs
  WHERE cs.max_injured_joint_stress <= p_max_stress_per_injured_joint
  ORDER BY
    matches_source_movement DESC,
    cs.max_injured_joint_stress ASC,
    cs.total_stress ASC,
    cs.name ASC
  LIMIT p_limit;
$$;

COMMENT ON FUNCTION find_injury_safe_alternatives(uuid, uuid, smallint, integer) IS
  'Returns exercises safe for the user considering active injuries. Prioritizes '
  'movement-pattern matches, then low stress on injured joints, then low total stress. '
  'p_max_stress_per_injured_joint: 0=no stress, 1=low OK, 2=moderate OK, 3=any.';

-- =============================================================================
-- 4. exercise_injury_risk_score()
-- =============================================================================
-- Returns a 0-10 risk score for a specific exercise given a user's injuries.
-- Useful for pre-session screening and coaching warnings.

CREATE OR REPLACE FUNCTION exercise_injury_risk_score(
  p_user_id uuid,
  p_exercise_id uuid
)
RETURNS TABLE (
  risk_score smallint,
  risk_level text,
  high_stress_joints text[],
  recommendation text
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public, pg_catalog
AS $$
DECLARE
  v_max_stress integer;
  v_injured_joint_count integer;
  v_high_joints text[];
  v_score smallint;
  v_level text;
  v_recommendation text;
BEGIN
  -- Max stress on any currently-injured joint for this exercise
  SELECT
    COALESCE(MAX(ejs.stress_level), 0),
    COUNT(DISTINCT ejs.joint) FILTER (WHERE ejs.stress_level >= 2),
    ARRAY_AGG(DISTINCT ejs.joint ORDER BY ejs.joint)
      FILTER (WHERE ejs.stress_level >= 2)
  INTO v_max_stress, v_injured_joint_count, v_high_joints
  FROM exercise_joint_stress ejs
  WHERE ejs.exercise_id = p_exercise_id
    AND ejs.joint IN (SELECT joint FROM get_user_active_injury_joints(p_user_id));

  -- Score: 0 = safe, 10 = extreme risk
  -- max_stress (0-3) weighted ×3, plus ×1 per additional injured joint, capped at 10
  v_score := LEAST(10, v_max_stress * 3 + GREATEST(0, COALESCE(v_injured_joint_count, 0) - 1))::smallint;

  v_level := CASE
    WHEN v_score = 0 THEN 'safe'
    WHEN v_score <= 3 THEN 'low'
    WHEN v_score <= 6 THEN 'moderate'
    ELSE 'high'
  END;

  v_recommendation := CASE
    WHEN v_score = 0    THEN 'No joint stress on any currently-injured area. Safe to perform.'
    WHEN v_score <= 3   THEN 'Low joint stress. Perform with normal warmup + attention to form.'
    WHEN v_score <= 6   THEN 'Moderate stress on injured joints. Consider lower load, slower tempo, or alternative.'
    ELSE                    'High stress on injured joints. Strongly consider a safer alternative until resolved.'
  END;

  RETURN QUERY SELECT v_score, v_level, COALESCE(v_high_joints, ARRAY[]::text[]), v_recommendation;
END;
$$;

COMMENT ON FUNCTION exercise_injury_risk_score(uuid, uuid) IS
  'Returns 0-10 injury risk score for an exercise given user active injuries. '
  'Score combines max joint stress level (weighted 3x) and count of ≥moderate-stress '
  'injured joints (weighted 2x, capped at 4).';

-- =============================================================================
-- 5. user_daily_safe_exercises view
-- =============================================================================
-- Materialized-style view: for each user, list top exercises ranked by safety
-- considering current injuries. RLS-scoped via security_invoker.

CREATE OR REPLACE VIEW user_daily_safe_exercises
WITH (security_invoker = true) AS
WITH user_injuries AS (
  SELECT user_id, ARRAY_AGG(joint) AS injured_joints
  FROM (
    SELECT DISTINCT ir.user_id,
           body_area_to_joint(ir.body_area) AS joint
    FROM injury_reports ir
    WHERE ir.limits_training = true
      AND ir.status IN ('active','recovering','chronic')
      AND body_area_to_joint(ir.body_area) IS NOT NULL
  ) x
  GROUP BY user_id
),
exercise_risk AS (
  SELECT
    ui.user_id,
    e.id AS exercise_id,
    e.name,
    e.movement_pattern,
    COALESCE(MAX(ejs.stress_level) FILTER (
      WHERE ejs.joint = ANY(ui.injured_joints)
    ), 0)::smallint AS max_stress_on_injured
  FROM user_injuries ui
  CROSS JOIN exercises e
  LEFT JOIN exercise_joint_stress ejs ON ejs.exercise_id = e.id
  WHERE e.created_by IS NULL
  GROUP BY ui.user_id, e.id, e.name, e.movement_pattern
)
SELECT
  user_id,
  exercise_id,
  name                     AS exercise_name,
  movement_pattern,
  max_stress_on_injured    AS max_stress_on_injured_joint,
  CASE
    WHEN max_stress_on_injured = 0 THEN 'safe'
    WHEN max_stress_on_injured = 1 THEN 'low_risk'
    WHEN max_stress_on_injured = 2 THEN 'moderate_risk'
    ELSE                                 'high_risk'
  END AS risk_category
FROM exercise_risk;

COMMENT ON VIEW user_daily_safe_exercises IS
  'Per-user exercise safety screening considering all active injuries. '
  'One row per (user, exercise). Users with no active injuries do not appear. '
  'Frontend filters to risk_category=safe/low_risk by default.';

COMMIT;
