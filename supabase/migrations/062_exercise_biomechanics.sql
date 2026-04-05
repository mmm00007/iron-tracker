-- Migration 062: Exercise Biomechanics & Joint Stress
-- Extends exercises with biomechanical characterization and adds a new
-- exercise_joint_stress table for granular injury screening and training
-- budget management.
--
-- Existing primary_joints text[] (migration 029) lists JOINTS INVOLVED.
-- This migration adds STRESS QUANTIFICATION per joint (compression/shear/
-- tension/torsion level 0-3) plus exercise-level skill and fatigue metadata.
--
-- Validated by: fitness-domain-expert, sports-medicine-expert, database-specialist
--
-- Key design decisions:
--   - skill_ceiling (1-5): distinct from `level` (beginner/intermediate/advanced)
--     which is the current proficiency gate. Skill_ceiling is the long-term
--     mastery ceiling (how refined can this movement get).
--   - fatigue_cost (1-5): systemic fatigue per working set. Deadlift=5, lat raise=1.
--     Used for session fatigue budgeting and ACWR contribution weighting.
--   - energy_system: standard physiology classification. Used for exercise
--     selection during phase-specific training (peaking favors alactic).
--   - typical_rep_range: goal-agnostic "reasonable" range for this movement.
--     8-12 for bench press; 3-5 for cleans; 15-20 for calf raises.
--   - common_form_errors (text[]): short cue list for UI "watch out for..." hints.
--   - exercise_joint_stress: normalized 1-to-many table with stress_type
--     dimension. Enables "find exercises with high knee compression" queries.
--
-- Citations:
--   - McGill S. (2016). Low Back Disorders, 3rd ed. (joint stress categorization).
--   - Escamilla R.F. (2001). Knee biomechanics of the squat. Med Sci Sports Exerc.
--   - NSCA (2016). Essentials of Strength Training and Conditioning, 4th ed.
--   - Haff G.G., Triplett N.T. eds. (2016). NSCA Essentials.
--   - Ottinger C.R. et al. (2023). Lengthened-position partials for hypertrophy. MASS.
--   - Issurin V.B. (2013). Training transfer: scientific background. Sports Med.

BEGIN;

-- =============================================================================
-- 1. EXERCISE BIOMECHANICS COLUMNS
-- =============================================================================

ALTER TABLE exercises
  ADD COLUMN IF NOT EXISTS skill_ceiling smallint
    CHECK (skill_ceiling >= 1 AND skill_ceiling <= 5),
  ADD COLUMN IF NOT EXISTS fatigue_cost smallint
    CHECK (fatigue_cost >= 1 AND fatigue_cost <= 5),
  ADD COLUMN IF NOT EXISTS energy_system text
    CHECK (energy_system IN ('alactic', 'lactic', 'aerobic', 'mixed')),
  ADD COLUMN IF NOT EXISTS typical_rep_range_min smallint
    CHECK (typical_rep_range_min > 0 AND typical_rep_range_min <= 100),
  ADD COLUMN IF NOT EXISTS typical_rep_range_max smallint
    CHECK (typical_rep_range_max > 0 AND typical_rep_range_max <= 100),
  ADD COLUMN IF NOT EXISTS common_form_errors text[] DEFAULT '{}',
  ADD COLUMN IF NOT EXISTS cns_demand smallint
    CHECK (cns_demand >= 1 AND cns_demand <= 5);

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE table_name = 'exercises'
      AND constraint_name = 'exercises_typical_rep_range_order_check'
  ) THEN
    ALTER TABLE exercises
      ADD CONSTRAINT exercises_typical_rep_range_order_check
      CHECK (typical_rep_range_min IS NULL OR typical_rep_range_max IS NULL
             OR typical_rep_range_min <= typical_rep_range_max);
  END IF;
END $$;

COMMENT ON COLUMN exercises.skill_ceiling IS
  'Long-term mastery ceiling for this movement (1=simple, 5=elite complex). '
  'Deadlift=4, snatch=5, leg press=1, cable lateral=1. Distinct from `level`.';

COMMENT ON COLUMN exercises.fatigue_cost IS
  'Systemic fatigue cost per working set (1=very low, 5=very high). '
  'Heavy deadlift=5, barbell squat=5, leg press=3, bicep curl=1, cable fly=1. '
  'Used for session fatigue budgeting and ACWR contribution weighting.';

COMMENT ON COLUMN exercises.energy_system IS
  'Dominant energy system: alactic (ATP-PC, <10s), lactic (glycolytic, 30s-2min), '
  'aerobic (oxidative, >2min), mixed. Guides phase-appropriate selection.';

COMMENT ON COLUMN exercises.typical_rep_range_min IS
  'Goal-agnostic lower bound of reasonable rep ranges. Explosive lifts low (1-5), '
  'hypertrophy compounds mid (6-12), endurance/isolation high (15-25).';

COMMENT ON COLUMN exercises.common_form_errors IS
  'Short list of frequent technique errors for this movement, used in UI coaching '
  'hints. E.g. squat: {"knees cave", "heels lift", "forward lean", "butt wink"}.';

COMMENT ON COLUMN exercises.cns_demand IS
  'Central nervous system demand (1=low, 5=very high). Distinct from fatigue_cost: '
  '1RM attempts, power cleans, speed work have high CNS_demand but moderate metabolic cost.';

-- =============================================================================
-- 2. EXERCISE_JOINT_STRESS: quantified per-joint stress profile
-- =============================================================================
-- Public reference data. One row per (exercise, joint) combination with
-- stress_level (0-3) and stress_type (compression/shear/tension/torsion/impact).
-- Used for:
--   - Injury screening ("which exercises stress the lumbar spine?")
--   - Session budgeting ("don't stack 3 high-knee-compression exercises")
--   - Alternatives engine ("find lower-shoulder-stress alternatives")

CREATE TABLE IF NOT EXISTS exercise_joint_stress (
  id             bigserial   PRIMARY KEY,
  exercise_id    uuid        NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
  joint          text        NOT NULL
    CHECK (joint IN (
      'cervical_spine', 'thoracic_spine', 'lumbar_spine',
      'shoulder', 'elbow', 'wrist',
      'hip', 'knee', 'ankle',
      'sacroiliac'
    )),
  stress_level   smallint    NOT NULL
    CHECK (stress_level >= 0 AND stress_level <= 3),
  stress_type    text
    CHECK (stress_type IN ('compression', 'shear', 'tension', 'torsion', 'impact')),
  notes          text,
  created_at     timestamptz NOT NULL DEFAULT now(),
  UNIQUE (exercise_id, joint, stress_type)
);

COMMENT ON TABLE exercise_joint_stress IS
  'Per-exercise joint stress quantification. 0=none, 1=low, 2=moderate, 3=high. '
  'stress_type distinguishes shear (ACL risk) from compression (disc risk). '
  'Reference data — public read, service-role write.';

COMMENT ON COLUMN exercise_joint_stress.stress_level IS
  '0=no stress, 1=minor (incidental), 2=moderate (primary load path), 3=high (major loading with injury risk without technique).';

COMMENT ON COLUMN exercise_joint_stress.stress_type IS
  'compression: axial load; shear: parallel displacement; tension: pulling apart; '
  'torsion: rotation; impact: collision. A single exercise+joint pair may have '
  'multiple rows (e.g., squat/lumbar_spine has both compression and shear).';

CREATE INDEX IF NOT EXISTS exercise_joint_stress_exercise_idx
  ON exercise_joint_stress (exercise_id);

CREATE INDEX IF NOT EXISTS exercise_joint_stress_joint_level_idx
  ON exercise_joint_stress (joint, stress_level DESC);

ALTER TABLE exercise_joint_stress ENABLE ROW LEVEL SECURITY;

CREATE POLICY exercise_joint_stress_select ON exercise_joint_stress
  FOR SELECT TO authenticated USING (true);

-- =============================================================================
-- 3. HELPER VIEW: exercise_joint_stress_summary
-- =============================================================================
-- Denormalized view aggregating max stress per joint per exercise. Used by
-- injury screening UI: "show me exercises safe for my shoulder impingement".

CREATE OR REPLACE VIEW exercise_joint_stress_summary
WITH (security_invoker = true) AS
SELECT
  ejs.exercise_id,
  ejs.joint,
  MAX(ejs.stress_level) AS max_stress_level,
  ARRAY_AGG(DISTINCT ejs.stress_type ORDER BY ejs.stress_type)
    FILTER (WHERE ejs.stress_type IS NOT NULL) AS stress_types
FROM exercise_joint_stress ejs
GROUP BY ejs.exercise_id, ejs.joint;

COMMENT ON VIEW exercise_joint_stress_summary IS
  'Aggregated joint stress per (exercise, joint): max stress level and stress types. '
  'Powers injury screening queries and substitution recommendations.';

-- =============================================================================
-- 4. HELPER FUNCTION: find_lower_joint_stress_alternatives
-- =============================================================================
-- Given an exercise and a "sensitive" joint, find alternatives with lower stress
-- on that joint while preserving the movement pattern.

CREATE OR REPLACE FUNCTION find_lower_joint_stress_alternatives(
  p_exercise_id uuid,
  p_joint text,
  p_max_stress_level smallint DEFAULT 1
)
RETURNS TABLE (
  alternative_exercise_id uuid,
  alternative_name text,
  current_stress_level smallint,
  movement_pattern text
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, pg_catalog
AS $$
  WITH source AS (
    SELECT e.movement_pattern
    FROM exercises e
    WHERE e.id = p_exercise_id
  )
  SELECT DISTINCT
    e.id                                  AS alternative_exercise_id,
    e.name                                AS alternative_name,
    COALESCE(ejss.max_stress_level, 0)    AS current_stress_level,
    e.movement_pattern
  FROM exercises e
  CROSS JOIN source s
  LEFT JOIN exercise_joint_stress_summary ejss
    ON ejss.exercise_id = e.id AND ejss.joint = p_joint
  WHERE e.id != p_exercise_id
    AND e.movement_pattern = s.movement_pattern
    AND COALESCE(ejss.max_stress_level, 0) <= p_max_stress_level
    AND e.created_by IS NULL  -- seed exercises only
  ORDER BY current_stress_level ASC, e.name ASC
  LIMIT 10;
$$;

COMMENT ON FUNCTION find_lower_joint_stress_alternatives(uuid, text, smallint) IS
  'Find movement-pattern-matched alternatives with lower stress on target joint. '
  'Used by injury-aware recommendation engine.';

COMMIT;
