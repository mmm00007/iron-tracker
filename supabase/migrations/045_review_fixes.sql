-- Migration 045: Review cycle fixes
-- Addresses findings from QA, fitness domain, architecture, and security reviews.

-- ═══════════════════════════════════════════════════════════════════════════════
-- 1. Add partial index on sets.workout_cluster_id
--    Used by session_muscle_summary materialized view and training_density_service.
--    Most rows have NULL workout_cluster_id, so partial index is efficient.
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE INDEX IF NOT EXISTS sets_workout_cluster_idx
  ON sets (workout_cluster_id)
  WHERE workout_cluster_id IS NOT NULL;


-- ═══════════════════════════════════════════════════════════════════════════════
-- 2. Fix Axle Deadlift primary muscle mapping
--    Same correction as migration 003 for Barbell Deadlift: demote lower back
--    to secondary, promote glutes + hamstrings to primary.
--    Evidence: Escamilla et al. 2001; NSCA Essentials 4th ed.
-- ═══════════════════════════════════════════════════════════════════════════════

-- Find the Axle Deadlift exercise and fix its muscle mappings
DO $$
DECLARE
  v_exercise_id UUID;
  v_glutes_id INT;
  v_hamstrings_id INT;
  v_lower_back_id INT;
BEGIN
  -- Look up the exercise (case-insensitive match)
  SELECT id INTO v_exercise_id
    FROM exercises
    WHERE LOWER(name) LIKE '%axle deadlift%'
    LIMIT 1;

  IF v_exercise_id IS NULL THEN
    RAISE NOTICE 'Axle Deadlift not found — skipping muscle fix';
    RETURN;
  END IF;

  -- Look up muscle group IDs
  SELECT id INTO v_glutes_id FROM muscle_groups WHERE LOWER(name) IN ('glutes', 'gluteus maximus') LIMIT 1;
  SELECT id INTO v_hamstrings_id FROM muscle_groups WHERE LOWER(name) IN ('hamstrings', 'biceps femoris') LIMIT 1;
  SELECT id INTO v_lower_back_id FROM muscle_groups WHERE LOWER(name) IN ('lower back', 'erector spinae') LIMIT 1;

  -- Demote lower back from primary to secondary
  IF v_lower_back_id IS NOT NULL THEN
    UPDATE exercise_muscles
      SET is_primary = false
      WHERE exercise_id = v_exercise_id AND muscle_group_id = v_lower_back_id;
  END IF;

  -- Promote glutes to primary (insert if missing)
  IF v_glutes_id IS NOT NULL THEN
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
      VALUES (v_exercise_id, v_glutes_id, true)
      ON CONFLICT (exercise_id, muscle_group_id) DO UPDATE SET is_primary = true;
  END IF;

  -- Promote hamstrings to primary (insert if missing)
  IF v_hamstrings_id IS NOT NULL THEN
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
      VALUES (v_exercise_id, v_hamstrings_id, true)
      ON CONFLICT (exercise_id, muscle_group_id) DO UPDATE SET is_primary = true;
  END IF;

  RAISE NOTICE 'Axle Deadlift muscle mapping corrected: glutes+hamstrings primary, lower back secondary';
END $$;


-- ═══════════════════════════════════════════════════════════════════════════════
-- 3. Add trapezius (mid-trap) to Bent Over Barbell Row
--    Rowing movements produce significant mid-trap activation (Fenwick 2009).
--    This omission causes push:pull balance analytics to undercount trap volume.
-- ═══════════════════════════════════════════════════════════════════════════════

DO $$
DECLARE
  v_exercise_id UUID;
  v_trap_id INT;
BEGIN
  -- Find the exercise
  SELECT id INTO v_exercise_id
    FROM exercises
    WHERE LOWER(name) LIKE '%bent over barbell row%'
    LIMIT 1;

  IF v_exercise_id IS NULL THEN
    RAISE NOTICE 'Bent Over Barbell Row not found — skipping trap addition';
    RETURN;
  END IF;

  -- Find trapezius muscle group
  SELECT id INTO v_trap_id
    FROM muscle_groups
    WHERE LOWER(name) IN ('trapezius', 'traps', 'middle back')
    LIMIT 1;

  IF v_trap_id IS NULL THEN
    RAISE NOTICE 'Trapezius muscle group not found — skipping';
    RETURN;
  END IF;

  -- Add as secondary muscle
  INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
    VALUES (v_exercise_id, v_trap_id, false)
    ON CONFLICT (exercise_id, muscle_group_id) DO NOTHING;

  RAISE NOTICE 'Added trapezius as secondary muscle for Bent Over Barbell Row';
END $$;


-- ═══════════════════════════════════════════════════════════════════════════════
-- 4. Update rest timer defaults per Schoenfeld 2016 evidence
--    3-minute rest produces significantly greater hypertrophy than 1-minute.
--    Raise compound defaults from 120s→150s, isolation from 60s→90s.
-- ═══════════════════════════════════════════════════════════════════════════════

-- Update exercise_insights rest_seconds defaults for compound movements
-- Only update where the value matches the old default (don't overwrite customizations)
UPDATE exercise_insights
  SET rest_seconds = 150
  WHERE rest_seconds = 120
    AND exercise_id IN (
      SELECT id FROM exercises
      WHERE LOWER(exercise_type) IN ('strength', 'compound')
         OR LOWER(mechanic) = 'compound'
    );

-- Update isolation defaults from 60s to 90s
UPDATE exercise_insights
  SET rest_seconds = 90
  WHERE rest_seconds = 60
    AND exercise_id IN (
      SELECT id FROM exercises
      WHERE LOWER(mechanic) = 'isolation'
         OR LOWER(exercise_type) = 'isolation'
    );


-- ═══════════════════════════════════════════════════════════════════════════════
-- 5. Harden search_path for trigger functions missed by migration 043
--    set_updated_at() and compute_estimated_1rm() were omitted.
-- ═══════════════════════════════════════════════════════════════════════════════

DO $$
BEGIN
  -- set_updated_at
  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'set_updated_at') THEN
    EXECUTE 'ALTER FUNCTION set_updated_at() SET search_path = public';
  END IF;

  -- compute_estimated_1rm
  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'compute_estimated_1rm') THEN
    EXECUTE 'ALTER FUNCTION compute_estimated_1rm() SET search_path = public';
  END IF;
END $$;
