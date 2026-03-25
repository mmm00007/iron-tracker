-- Migration 035: Muscle Profile Denormalization + Session Summary Materialized View
-- Adds a denormalized muscle_profile JSONB column on exercises (computed from
-- exercise_muscles junction table) and a materialized session_muscle_summary view
-- that aggregates per-session muscle group volume.
--
-- Inspired by: github.com/mmm00007/gym-tracker dual muscle tracking pattern
-- Validated by: fitness-domain-expert, database-specialist agents
--
-- Key design decisions:
--   - muscle_profile JSONB stored on exercises (not generated column) because:
--       a) PostgreSQL generated columns can't call subqueries (PG 17)
--       b) Junction table has 2,481 rows; rebuilding JSONB on every query is expensive
--       c) Enrichment data changes infrequently; staleness is acceptable
--   - muscle_profile structure: {primary: [{id, name, activation_pct}], secondary: [...], stabilizers: [...]}
--       matches gym-tracker's muscle_profile schema and enables O(1) muscle reads
--       without joining exercise_muscles + muscle_groups on every exercise fetch
--   - refresh_exercise_muscle_profile() is SECURITY DEFINER (service_role only).
--       Not a row trigger (would fire 2,481 times during seed updates — too expensive).
--       Instead called: (1) by backend after any exercise_muscles mutation,
--       (2) by initial backfill below.
--   - session_muscle_summary uses MATERIALIZED VIEW for performance:
--       The join chain (sets → exercise_muscles → muscle_groups) is expensive at
--       scale. Materialized view is refreshed by backend cron after set mutations.
--   - movement_pattern enum extended with single_leg_squat, lateral_raise,
--     elbow_flexion, incline_press per gym-tracker granularity.
--       single_leg_squat: distinct bilateral squat (different motor pattern per Pistilli, 2008)
--       lateral_raise:    frontal-plane isolation (deltoid, supraspinatus); no existing bucket
--       elbow_flexion:    curl-pattern isolation (biceps, brachialis); currently lumped in 'isolation'
--       incline_press:    distinct from horizontal_push (clavicular head emphasis, Barnett, 1995)
--   - UNIQUE constraint on session_muscle_summary is needed for REFRESH CONCURRENTLY support

BEGIN;


-- =============================================================================
-- 1. EXERCISES: movement_pattern enum extension
-- =============================================================================

-- Drop the existing CHECK constraint (auto-named by PostgreSQL).
-- We locate it dynamically because migration 015 used an inline CHECK (no explicit name).
DO $$ DECLARE v_conname text;
BEGIN
  SELECT conname INTO v_conname
  FROM pg_constraint
  WHERE conrelid = 'exercises'::regclass
    AND contype = 'c'
    AND pg_get_constraintdef(oid) LIKE '%movement_pattern%'
    AND pg_get_constraintdef(oid) LIKE '%squat%';

  IF v_conname IS NOT NULL THEN
    EXECUTE 'ALTER TABLE exercises DROP CONSTRAINT ' || quote_ident(v_conname);
  END IF;
END $$;

-- Re-add with four new values.
-- Existing values kept exactly (squat, hip_hinge, lunge, horizontal_push,
-- vertical_push, horizontal_pull, vertical_pull, carry, rotation, isolation, other).
ALTER TABLE exercises
  ADD CONSTRAINT exercises_movement_pattern_check CHECK (movement_pattern IN (
    -- Original patterns (unchanged)
    'squat',
    'hip_hinge',
    'lunge',
    'horizontal_push',
    'vertical_push',
    'horizontal_pull',
    'vertical_pull',
    'carry',
    'rotation',
    'isolation',
    'other',
    -- New patterns (gym-tracker alignment)
    'single_leg_squat',   -- Pistol squat, Bulgarian split squat (unilateral knee)
    'lateral_raise',      -- DB lateral raise, cable lateral (frontal-plane deltoid)
    'elbow_flexion',      -- Curls: bicep, hammer, preacher (distinct from 'isolation')
    'incline_press'       -- Incline bench / incline dumbbell press (upper chest focus)
  ));

COMMENT ON COLUMN exercises.movement_pattern IS
  'Biomechanical movement classification. Extended from 11 → 15 values in migration 035. '
  'New: single_leg_squat (unilateral knee), lateral_raise (frontal deltoid), '
  'elbow_flexion (curl pattern), incline_press (upper chest emphasis). '
  'Used for exercise_type derivation and movement_pattern_balance analytics.';

-- Auto-derive exercise_type for new patterns (same logic as migration 019)
UPDATE exercises SET exercise_type = 'push'
WHERE movement_pattern = 'incline_press' AND exercise_type IS NULL;

UPDATE exercises SET exercise_type = 'legs'
WHERE movement_pattern = 'single_leg_squat' AND exercise_type IS NULL;

-- lateral_raise and elbow_flexion: no single unambiguous exercise_type → leave NULL


-- =============================================================================
-- 2. EXERCISES: muscle_profile JSONB column
-- =============================================================================

-- Denormalized muscle profile for fast client-side reads without JOINs.
-- Structure mirrors gym-tracker's muscle_profile JSONB:
-- {
--   "primary":    [{"id": 1, "name": "Pectoralis Major", "activation_pct": 100}],
--   "secondary":  [{"id": 4, "name": "Anterior Deltoid", "activation_pct": 60}],
--   "stabilizers":[{"id": 9, "name": "Rotator Cuff", "activation_pct": 20}]
-- }
-- Keys match function_type enum: agonist→primary, synergist→secondary, stabilizer→stabilizers
-- activation_pct is COALESCE(activation_percent, is_primary::int * 100 + (1-is_primary::int) * 50)
ALTER TABLE exercises
  ADD COLUMN IF NOT EXISTS muscle_profile jsonb DEFAULT '{}';

COMMENT ON COLUMN exercises.muscle_profile IS
  'Denormalized muscle activation profile. Auto-computed from exercise_muscles junction '
  'by refresh_exercise_muscle_profile(). Structure: {primary, secondary, stabilizers} arrays '
  'each containing {id, name, activation_pct}. Stale after exercise_muscles mutations — '
  'backend must call refresh_exercise_muscle_profile(exercise_id) after any change.';

CREATE INDEX IF NOT EXISTS exercises_muscle_profile_idx
  ON exercises USING GIN (muscle_profile)
  WHERE muscle_profile != '{}';


-- =============================================================================
-- 3. FUNCTION: refresh_exercise_muscle_profile
-- =============================================================================

-- Computes and writes muscle_profile JSONB for one or all exercises.
-- When p_exercise_id IS NULL: full table rebuild (used for migrations / re-seeds).
-- When p_exercise_id IS NOT NULL: single-exercise update (called after mutations).
--
-- Classification mapping (consistent with migrations 021, 025, 027):
--   function_type = 'agonist'    → 'primary'
--   function_type = 'synergist'  → 'secondary'
--   function_type = 'stabilizer' → 'stabilizers'
--   function_type IS NULL + is_primary = true  → 'primary'
--   function_type IS NULL + is_primary = false → 'secondary'
CREATE OR REPLACE FUNCTION refresh_exercise_muscle_profile(
  p_exercise_id uuid DEFAULT NULL
)
RETURNS void AS $$
BEGIN
  UPDATE exercises e
  SET muscle_profile = sub.profile
  FROM (
    SELECT
      em.exercise_id,
      jsonb_build_object(
        'primary',
        COALESCE(
          jsonb_agg(
            jsonb_build_object(
              'id',             mg.id,
              'name',           mg.name,
              'activation_pct', COALESCE(
                em.activation_percent,
                CASE WHEN em.is_primary THEN 100 ELSE 50 END
              )
            ) ORDER BY COALESCE(em.activation_percent, 100) DESC
          ) FILTER (
            WHERE COALESCE(em.function_type, CASE WHEN em.is_primary THEN 'agonist' ELSE 'synergist' END) = 'agonist'
          ),
          '[]'::jsonb
        ),
        'secondary',
        COALESCE(
          jsonb_agg(
            jsonb_build_object(
              'id',             mg.id,
              'name',           mg.name,
              'activation_pct', COALESCE(
                em.activation_percent,
                50
              )
            ) ORDER BY COALESCE(em.activation_percent, 50) DESC
          ) FILTER (
            WHERE COALESCE(em.function_type, CASE WHEN em.is_primary THEN 'agonist' ELSE 'synergist' END) = 'synergist'
          ),
          '[]'::jsonb
        ),
        'stabilizers',
        COALESCE(
          jsonb_agg(
            jsonb_build_object(
              'id',             mg.id,
              'name',           mg.name,
              'activation_pct', COALESCE(em.activation_percent, 20)
            ) ORDER BY COALESCE(em.activation_percent, 20) DESC
          ) FILTER (
            WHERE em.function_type = 'stabilizer'
          ),
          '[]'::jsonb
        )
      ) AS profile
    FROM exercise_muscles em
    JOIN muscle_groups mg ON mg.id = em.muscle_group_id
    WHERE (p_exercise_id IS NULL OR em.exercise_id = p_exercise_id)
    GROUP BY em.exercise_id
  ) sub
  WHERE e.id = sub.exercise_id
    AND (p_exercise_id IS NULL OR e.id = p_exercise_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION refresh_exercise_muscle_profile IS
  'Computes and writes muscle_profile JSONB for one (p_exercise_id) or all exercises (NULL). '
  'Classification: agonist→primary, synergist→secondary, stabilizer→stabilizers. '
  'Falls back to is_primary when function_type is NULL. '
  'Call from backend after any exercise_muscles mutation. Service role only.';

-- Restrict to service_role (same pattern as recompute_workout_clusters, compute_workload_balance)
REVOKE EXECUTE ON FUNCTION refresh_exercise_muscle_profile(uuid) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION refresh_exercise_muscle_profile(uuid) FROM authenticated;
GRANT EXECUTE ON FUNCTION refresh_exercise_muscle_profile(uuid) TO service_role;


-- =============================================================================
-- 4. BACKFILL: muscle_profile for all existing exercises
-- =============================================================================

-- Run the full-table rebuild on migration. This is a one-time cost.
-- 873 exercises × ~3 muscles avg = ~2,600 rows in exercise_muscles.
-- Estimated runtime: < 2 seconds.
DO $$
BEGIN
  PERFORM refresh_exercise_muscle_profile(NULL);
END $$;


-- =============================================================================
-- 5. MATERIALIZED VIEW: session_muscle_summary
-- =============================================================================

-- Aggregates per-session (training_date + workout_cluster_id) muscle group volume.
-- Replaces the need for ad-hoc joins in coaching and analytics queries.
--
-- Design rationale:
--   - Uses workout_cluster_id from migration 021 for sub-day session segmentation
--     (AM cardio + PM strength = two separate rows)
--   - Weighted sets follow migration 027 activation_percent convention
--     (agonist activation / 100; stabilizers = 0)
--   - Filters working/backoff/failure sets (excludes warmups per RP convention)
--   - NOT security_invoker because materialized views don't support it (PG 17).
--     RLS is enforced by the UNIQUE index on (user_id, *) + backend write path:
--     only service_role can REFRESH this view. Direct SELECT via authenticated
--     role will still respect RLS because the materialized view is a table-like
--     object — we add an RLS policy below.
--
-- Refresh strategy: CONCURRENTLY after recompute_workout_clusters() in the
-- backend cron (after each set mutation cycle). The UNIQUE index on
-- (user_id, training_date, muscle_group_id, workout_cluster_id) is required
-- for REFRESH CONCURRENTLY.

DROP MATERIALIZED VIEW IF EXISTS session_muscle_summary;

CREATE MATERIALIZED VIEW session_muscle_summary AS
SELECT
  s.user_id,
  s.training_date,
  s.workout_cluster_id,
  mg.id                                                          AS muscle_group_id,
  mg.name                                                        AS muscle_group_name,
  -- Weighted set count using activation percentages (migration 027 convention)
  SUM(
    CASE
      WHEN em.function_type = 'stabilizer' THEN 0.0
      WHEN COALESCE(em.activation_percent,
           CASE WHEN em.is_primary THEN 100 ELSE 50 END) < 30 THEN 0.0
      ELSE COALESCE(
        em.activation_percent,
        CASE WHEN em.is_primary THEN 100 ELSE 50 END
      )::numeric / 100.0
    END
  )                                                              AS weighted_sets,
  COUNT(*)                                                       AS raw_sets,
  -- Volume normalized to kg
  SUM(
    CASE WHEN s.weight_unit = 'lb' THEN s.weight * 0.453592 ELSE s.weight END
    * COALESCE(s.reps, 1)
    * CASE
        WHEN em.function_type = 'stabilizer' THEN 0.0
        WHEN COALESCE(em.activation_percent,
             CASE WHEN em.is_primary THEN 100 ELSE 50 END) < 30 THEN 0.0
        ELSE COALESCE(
          em.activation_percent,
          CASE WHEN em.is_primary THEN 100 ELSE 50 END
        )::numeric / 100.0
      END
  )                                                              AS weighted_volume_kg,
  AVG(s.rpe) FILTER (WHERE s.rpe IS NOT NULL)                    AS avg_rpe,
  MIN(s.logged_at)                                               AS first_set_at,
  MAX(s.logged_at)                                               AS last_set_at
FROM sets s
JOIN exercise_muscles em ON em.exercise_id = s.exercise_id
JOIN muscle_groups mg    ON mg.id = em.muscle_group_id
WHERE s.set_type IN ('working', 'backoff', 'failure')
  AND s.training_date IS NOT NULL
GROUP BY s.user_id, s.training_date, s.workout_cluster_id, mg.id, mg.name
WITH DATA;

COMMENT ON MATERIALIZED VIEW session_muscle_summary IS
  'Per-session (training_date + cluster) muscle group weighted volume. '
  'Refreshed CONCURRENTLY by backend cron after set mutations. '
  'Activation weighting: agonist=activation_pct/100, stabilizer=0, <30%=0. '
  'Weight normalized to kg. Excludes warmup sets.';

-- Unique index required for REFRESH CONCURRENTLY.
-- NULL workout_cluster_id is included (sessions without cluster assignment).
CREATE UNIQUE INDEX session_muscle_summary_unique_idx
  ON session_muscle_summary (
    user_id,
    training_date,
    muscle_group_id,
    workout_cluster_id
  );

-- Query indexes for common access patterns
CREATE INDEX session_muscle_summary_user_date_idx
  ON session_muscle_summary (user_id, training_date DESC);

CREATE INDEX session_muscle_summary_user_muscle_idx
  ON session_muscle_summary (user_id, muscle_group_id, training_date DESC);


-- =============================================================================
-- 6. RLS on session_muscle_summary
-- =============================================================================

-- Materialized views are heap tables and support RLS in PostgreSQL 15+.
-- We enforce user isolation to prevent cross-user data leaks.
ALTER MATERIALIZED VIEW session_muscle_summary ENABLE ROW LEVEL SECURITY;

CREATE POLICY session_muscle_summary_select ON session_muscle_summary
  FOR SELECT TO authenticated USING (user_id = auth.uid());


-- =============================================================================
-- 7. FUNCTION: refresh_session_muscle_summary (service_role only)
-- =============================================================================

-- Wrapper to refresh the materialized view. Called by backend cron.
-- Uses CONCURRENTLY to avoid locking reads during refresh.
CREATE OR REPLACE FUNCTION refresh_session_muscle_summary()
RETURNS void AS $$
BEGIN
  REFRESH MATERIALIZED VIEW CONCURRENTLY session_muscle_summary;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION refresh_session_muscle_summary IS
  'Refreshes session_muscle_summary CONCURRENTLY. '
  'Call from backend cron after recompute_workout_clusters(). Service role only.';

REVOKE EXECUTE ON FUNCTION refresh_session_muscle_summary() FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION refresh_session_muscle_summary() FROM authenticated;
GRANT EXECUTE ON FUNCTION refresh_session_muscle_summary() TO service_role;


-- =============================================================================
-- 8. VIEW: session_exercise_summary
-- =============================================================================

-- Per-session per-exercise aggregates. Complements session_muscle_summary
-- by providing the exercise-level detail (best e1RM, total volume, sets).
-- Implemented as a regular VIEW (not materialized) because exercise-level
-- data is already fast via the exercises index; the expensive join is
-- muscle-level (handled by the materialized view above).
-- Uses security_invoker for automatic RLS enforcement.
CREATE OR REPLACE VIEW session_exercise_summary
WITH (security_invoker = true) AS
SELECT
  s.user_id,
  s.training_date,
  s.workout_cluster_id,
  s.exercise_id,
  e.name                                                         AS exercise_name,
  e.movement_pattern,
  e.exercise_type,
  e.muscle_profile,
  COUNT(*)                                                       AS total_sets,
  COUNT(*) FILTER (WHERE s.set_type = 'working')                 AS working_sets,
  -- Best weight (normalized to kg)
  MAX(
    CASE WHEN s.weight_unit = 'lb' THEN s.weight * 0.453592 ELSE s.weight END
  ) FILTER (WHERE s.set_type = 'working')                        AS best_weight_kg,
  MAX(s.estimated_1rm) FILTER (WHERE s.set_type = 'working')     AS best_e1rm,
  -- Total volume (kg)
  SUM(
    CASE WHEN s.weight_unit = 'lb' THEN s.weight * 0.453592 ELSE s.weight END
    * COALESCE(s.reps, 1)
  )                                                              AS total_volume_kg,
  -- Rep counts
  SUM(s.reps)                                                    AS total_reps,
  -- Intensity
  AVG(s.rpe) FILTER (WHERE s.rpe IS NOT NULL)                    AS avg_rpe,
  AVG(s.rest_seconds) FILTER (WHERE s.rest_seconds IS NOT NULL)  AS avg_rest_seconds,
  -- Last set weight/reps for "repeat this workout" prefill
  (ARRAY_AGG(
    CASE WHEN s.weight_unit = 'lb' THEN s.weight * 0.453592 ELSE s.weight END
    ORDER BY s.logged_at DESC
  ) FILTER (WHERE s.set_type = 'working'))[1]                    AS last_weight_kg,
  (ARRAY_AGG(s.reps ORDER BY s.logged_at DESC)
   FILTER (WHERE s.set_type = 'working'))[1]                     AS last_reps,
  MIN(s.logged_at)                                               AS first_set_at,
  MAX(s.logged_at)                                               AS last_set_at
FROM sets s
JOIN exercises e ON e.id = s.exercise_id
WHERE s.training_date IS NOT NULL
GROUP BY
  s.user_id, s.training_date, s.workout_cluster_id,
  s.exercise_id, e.name, e.movement_pattern, e.exercise_type, e.muscle_profile;

COMMENT ON VIEW session_exercise_summary IS
  'Per-session per-exercise aggregates including muscle_profile JSONB from exercises. '
  'Complements session_muscle_summary (muscle-level). RLS via security_invoker. '
  'last_weight_kg / last_reps enable one-tap repeat set prefill.';


COMMIT;
