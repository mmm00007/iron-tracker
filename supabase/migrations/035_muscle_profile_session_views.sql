-- Migration 035: Muscle Profile Cache & Session Views
-- Inspired by github.com/mmm00007/gym-tracker dual muscle tracking pattern.
-- Validated by: fitness-domain-expert (APPROVE as computed cache, NOT source of truth),
--              database-specialist (designed refresh function and views)
--
-- Adds:
--   1. muscle_profile JSONB on exercises (computed from exercise_muscles junction table)
--   2. core_stability movement_pattern value (domain expert recommendation)
--   3. session_exercise_summary view (per-session exercise aggregates)
--   4. refresh function for muscle_profile
--
-- Key design decisions (from expert validation):
--   - muscle_profile is a COMPUTED CACHE, not a source of truth. The normalized
--     exercise_muscles junction table remains authoritative. The JSONB enables
--     single-query muscle context in the frontend without expensive JOINs.
--   - core_stability is the only movement_pattern addition approved by domain expert.
--     Proposed additions (incline_press, elbow_flexion, single_leg_squat) were rejected
--     as they confuse equipment variants/anatomical actions with movement patterns.
--   - session_exercise_summary includes muscle_profile directly so the client gets
--     full exercise + muscle context in one query per session.

BEGIN;

-- =============================================================================
-- 1. EXERCISES: Denormalized muscle_profile JSONB (computed cache)
-- =============================================================================

ALTER TABLE exercises ADD COLUMN IF NOT EXISTS muscle_profile jsonb DEFAULT '{}';

COMMENT ON COLUMN exercises.muscle_profile IS
  'COMPUTED CACHE from exercise_muscles junction table. Contains {primary: [{id, name, pct}], secondary: [...], stabilizers: [...]}. '
  'Refresh via refresh_exercise_muscle_profile(). NOT the source of truth — exercise_muscles table is authoritative.';


-- =============================================================================
-- 2. MOVEMENT PATTERN: Add core_stability
-- =============================================================================

-- Drop old constraint, add new one with core_stability included.
-- Core stability exercises (planks, Pallof presses, dead bugs) don't fit
-- rotation or isolation. McGill's core stability paradigm classifies these
-- as anti-movement patterns (McGill, 2010, Ultimate Back Fitness).
DO $$ DECLARE v_conname text;
BEGIN
  SELECT conname INTO v_conname FROM pg_constraint
  WHERE conrelid = 'exercises'::regclass AND contype = 'c'
    AND pg_get_constraintdef(oid) LIKE '%movement_pattern%'
    AND pg_get_constraintdef(oid) LIKE '%squat%';
  IF v_conname IS NOT NULL THEN
    EXECUTE 'ALTER TABLE exercises DROP CONSTRAINT ' || quote_ident(v_conname);
  END IF;
END $$;

ALTER TABLE exercises ADD CONSTRAINT exercises_movement_pattern_check CHECK (
  movement_pattern IS NULL OR movement_pattern IN (
    'squat', 'hip_hinge', 'lunge', 'horizontal_push', 'vertical_push',
    'horizontal_pull', 'vertical_pull', 'carry', 'rotation', 'isolation', 'other',
    'core_stability'
  )
);


-- =============================================================================
-- 3. FUNCTION: refresh_exercise_muscle_profile (service_role only)
-- =============================================================================

-- Recomputes muscle_profile JSONB from the normalized exercise_muscles table.
-- Call with NULL to refresh all exercises, or a specific exercise_id.
-- Called by backend after exercise_muscles mutations.
CREATE OR REPLACE FUNCTION refresh_exercise_muscle_profile(p_exercise_id uuid DEFAULT NULL)
RETURNS void AS $$
BEGIN
  UPDATE exercises e SET muscle_profile = COALESCE((
    SELECT jsonb_build_object(
      'primary', COALESCE((
        SELECT jsonb_agg(jsonb_build_object(
          'id', mg.id, 'name', mg.name,
          'pct', COALESCE(em.activation_percent, 100)
        ) ORDER BY COALESCE(em.activation_percent, 100) DESC)
        FROM exercise_muscles em
        JOIN muscle_groups mg ON mg.id = em.muscle_group_id
        WHERE em.exercise_id = e.id AND em.function_type = 'agonist'
      ), '[]'::jsonb),
      'secondary', COALESCE((
        SELECT jsonb_agg(jsonb_build_object(
          'id', mg.id, 'name', mg.name,
          'pct', COALESCE(em.activation_percent, 50)
        ) ORDER BY COALESCE(em.activation_percent, 50) DESC)
        FROM exercise_muscles em
        JOIN muscle_groups mg ON mg.id = em.muscle_group_id
        WHERE em.exercise_id = e.id AND em.function_type = 'synergist'
      ), '[]'::jsonb),
      'stabilizers', COALESCE((
        SELECT jsonb_agg(jsonb_build_object(
          'id', mg.id, 'name', mg.name,
          'pct', COALESCE(em.activation_percent, 20)
        ) ORDER BY COALESCE(em.activation_percent, 20) DESC)
        FROM exercise_muscles em
        JOIN muscle_groups mg ON mg.id = em.muscle_group_id
        WHERE em.exercise_id = e.id AND em.function_type = 'stabilizer'
      ), '[]'::jsonb)
    )
  ), '{}')
  WHERE (p_exercise_id IS NULL OR e.id = p_exercise_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION refresh_exercise_muscle_profile IS
  'Recomputes muscle_profile JSONB from exercise_muscles junction table. '
  'Call with NULL for all exercises, or specific exercise_id. Service role only.';

REVOKE EXECUTE ON FUNCTION refresh_exercise_muscle_profile(uuid) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION refresh_exercise_muscle_profile(uuid) FROM authenticated;
GRANT EXECUTE ON FUNCTION refresh_exercise_muscle_profile(uuid) TO service_role;

-- Backfill muscle_profile for all 873 exercises
SELECT refresh_exercise_muscle_profile(NULL);


-- =============================================================================
-- 4. VIEW: session_exercise_summary
-- =============================================================================

-- Per-session per-exercise aggregates with muscle_profile JSONB for
-- single-query muscle context. Eliminates the need for a separate
-- exercise_muscles JOIN on every session detail query.
CREATE OR REPLACE VIEW session_exercise_summary
WITH (security_invoker = true) AS
SELECT
  s.user_id,
  s.training_date,
  s.workout_cluster_id,
  s.exercise_id,
  e.name                                                    AS exercise_name,
  e.movement_pattern,
  e.exercise_type,
  e.muscle_profile,
  COUNT(*)                                                  AS total_sets,
  COUNT(*) FILTER (WHERE s.set_type = 'working')            AS working_sets,
  MAX(s.estimated_1rm) FILTER (WHERE s.set_type = 'working') AS best_e1rm,
  SUM(
    CASE WHEN s.weight_unit = 'lb' THEN s.weight * 0.453592 ELSE s.weight END
    * s.reps
  )                                                         AS total_volume_kg,
  (ARRAY_AGG(s.weight ORDER BY s.logged_at DESC))[1]        AS last_weight,
  (ARRAY_AGG(s.reps ORDER BY s.logged_at DESC))[1]          AS last_reps,
  AVG(s.rpe) FILTER (WHERE s.rpe IS NOT NULL)               AS avg_rpe,
  AVG(s.rest_seconds) FILTER (WHERE s.rest_seconds IS NOT NULL) AS avg_rest_seconds,
  MIN(s.logged_at)                                          AS first_set_at,
  MAX(s.logged_at)                                          AS last_set_at
FROM sets s
JOIN exercises e ON e.id = s.exercise_id
WHERE s.training_date IS NOT NULL
GROUP BY s.user_id, s.training_date, s.workout_cluster_id, s.exercise_id,
         e.name, e.movement_pattern, e.exercise_type, e.muscle_profile;

COMMENT ON VIEW session_exercise_summary IS
  'Per-session per-exercise aggregates with muscle_profile JSONB. '
  'Enables single-query muscle context for session detail pages. RLS via security_invoker.';

COMMIT;
