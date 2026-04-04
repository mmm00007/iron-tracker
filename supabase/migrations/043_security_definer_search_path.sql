-- Migration 043: Fix SECURITY DEFINER functions missing SET search_path
--
-- All SECURITY DEFINER functions must set search_path explicitly to prevent
-- search_path hijacking attacks. Without it, a malicious schema placed earlier
-- in the search_path could shadow public tables and intercept or manipulate
-- data when the function executes with elevated privileges (SECURITY DEFINER
-- runs as the function owner, typically the superuser who created the migration).
--
-- PostgreSQL advisory: https://www.postgresql.org/docs/current/sql-createfunction.html
--   "...it is good practice for SECURITY DEFINER functions to include
--    SET search_path = '' or SET search_path = 'public' in their definition"
--
-- Affected functions (all from prior migrations, none had SET search_path):
--   1. recompute_workout_clusters(uuid, date)         — migration 021
--   2. sync_profile_body_weight()                     — migration 025 (trigger)
--   3. compute_workload_balance(uuid, text, date, date) — migration 027
--   4. compute_exercise_progress_snapshot(uuid, text, date) — migration 033
--   5. compute_streak_milestones(uuid)                — migration 034
--   6. refresh_exercise_muscle_profile(uuid)          — migration 035
--   7. refresh_session_muscle_summary()               — migration 035
--   8. compute_session_quality(uuid, date, uuid)      — migration 036

BEGIN;

-- 1. recompute_workout_clusters(uuid, date)
-- Tables used: profiles (SELECT), sets (SELECT, UPDATE)
ALTER FUNCTION recompute_workout_clusters(uuid, date)
  SET search_path = 'public';

-- 2. sync_profile_body_weight()  [trigger function]
-- Tables used: body_weight_log (SELECT), profiles (UPDATE)
ALTER FUNCTION sync_profile_body_weight()
  SET search_path = 'public';

-- 3. compute_workload_balance(uuid, text, date, date)
-- Tables used: sets, exercise_muscles, muscle_groups, exercises, workload_balance_scores
ALTER FUNCTION compute_workload_balance(uuid, text, date, date)
  SET search_path = 'public';

-- 4. compute_exercise_progress_snapshot(uuid, text, date)
-- Tables used: sets, exercise_progress_snapshots
ALTER FUNCTION compute_exercise_progress_snapshot(uuid, text, date)
  SET search_path = 'public';

-- 5. compute_streak_milestones(uuid)
-- Tables/views used: training_consistency_metrics (view), training_milestones
ALTER FUNCTION compute_streak_milestones(uuid)
  SET search_path = 'public';

-- 6. refresh_exercise_muscle_profile(uuid)
-- Tables used: exercises, exercise_muscles, muscle_groups
ALTER FUNCTION refresh_exercise_muscle_profile(uuid)
  SET search_path = 'public';

-- 7. refresh_session_muscle_summary()
-- Objects used: session_muscle_summary (materialized view)
ALTER FUNCTION refresh_session_muscle_summary()
  SET search_path = 'public';

-- 8. compute_session_quality(uuid, date, uuid)
-- Tables used: sets, plan_adherence_log, workout_feedback, session_quality_scores
ALTER FUNCTION compute_session_quality(uuid, date, uuid)
  SET search_path = 'public';

COMMIT;
