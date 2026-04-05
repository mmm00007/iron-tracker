-- Migration 091: Session Duration Prediction
-- Predicts workout duration based on user's historical pacing per exercise.
-- Answers "how long will this planned workout take?" using consecutive-set
-- logged_at intervals to infer real session density.
--
-- Validated by: data-science-expert
--
-- Algorithm:
--   1. Per user × exercise: compute median time between consecutive working
--      sets (from logged_at deltas within a training_date).
--   2. Cap individual intervals at 8 min (outliers: phone, conversation).
--   3. Exclude intervals <15 sec (double-logs / rapid entries).
--   4. Overall per-user median used as fallback for new exercises.
--   5. Predicted duration = sum(interval_per_exercise × sets_per_exercise)
--      + user's typical session startup overhead.

BEGIN;

-- =============================================================================
-- 1. user_exercise_pacing view
-- =============================================================================
-- Per-user per-exercise median time between consecutive working sets.

CREATE OR REPLACE VIEW user_exercise_pacing
WITH (security_invoker = true) AS
WITH set_deltas AS (
  SELECT
    s.user_id,
    s.exercise_id,
    s.training_date,
    EXTRACT(epoch FROM (
      s.logged_at - LAG(s.logged_at) OVER (
        PARTITION BY s.user_id, s.exercise_id, s.training_date
        ORDER BY s.logged_at
      )
    )) AS seconds_since_prev
  FROM sets s
  WHERE s.set_type = 'working'
    AND s.training_date IS NOT NULL
    AND s.training_date >= CURRENT_DATE - 180
),
filtered AS (
  SELECT user_id, exercise_id, seconds_since_prev
  FROM set_deltas
  WHERE seconds_since_prev IS NOT NULL
    AND seconds_since_prev >= 15
    AND seconds_since_prev <= 480
)
SELECT
  user_id,
  exercise_id,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY seconds_since_prev)::integer AS median_seconds_between_sets,
  PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY seconds_since_prev)::integer AS p25_seconds_between_sets,
  PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY seconds_since_prev)::integer AS p75_seconds_between_sets,
  COUNT(*)::integer AS sample_size
FROM filtered
GROUP BY user_id, exercise_id
HAVING COUNT(*) >= 3;

COMMENT ON VIEW user_exercise_pacing IS
  'Per-user per-exercise median time between working sets (25/50/75 '
  'percentiles). Computed from consecutive logged_at deltas on same training '
  'date, filtered to 15s-8min window. Min 3 samples.';

-- =============================================================================
-- 2. user_overall_pacing view: median across all exercises
-- =============================================================================
-- Fallback for new exercises where per-exercise pacing isn't available.

CREATE OR REPLACE VIEW user_overall_pacing
WITH (security_invoker = true) AS
WITH set_deltas AS (
  SELECT
    s.user_id,
    EXTRACT(epoch FROM (
      s.logged_at - LAG(s.logged_at) OVER (
        PARTITION BY s.user_id, s.training_date, s.exercise_id
        ORDER BY s.logged_at
      )
    )) AS seconds_since_prev
  FROM sets s
  WHERE s.set_type = 'working'
    AND s.training_date IS NOT NULL
    AND s.training_date >= CURRENT_DATE - 180
)
SELECT
  user_id,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY seconds_since_prev)::integer AS overall_median_seconds,
  COUNT(*)::integer AS sample_size
FROM set_deltas
WHERE seconds_since_prev IS NOT NULL
  AND seconds_since_prev >= 15
  AND seconds_since_prev <= 480
GROUP BY user_id
HAVING COUNT(*) >= 20;

COMMENT ON VIEW user_overall_pacing IS
  'Per-user overall median time between working sets across ALL exercises. '
  'Fallback for exercises without enough per-exercise pacing samples.';

-- =============================================================================
-- 3. predict_session_duration() function
-- =============================================================================
-- Takes a planned session (arrays of exercise_ids + sets_per_exercise) and
-- returns estimated duration in minutes.

CREATE OR REPLACE FUNCTION predict_session_duration(
  p_user_id uuid,
  p_exercise_ids uuid[],
  p_sets_per_exercise smallint[],
  p_startup_minutes smallint DEFAULT 8
)
RETURNS TABLE (
  estimated_minutes smallint,
  lower_bound_minutes smallint,
  upper_bound_minutes smallint,
  exercises_with_history integer,
  exercises_with_fallback integer
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public, pg_catalog
AS $$
DECLARE
  v_overall_median integer;
  v_total_seconds numeric := 0;
  v_lower_seconds numeric := 0;
  v_upper_seconds numeric := 0;
  v_with_history integer := 0;
  v_with_fallback integer := 0;
  v_idx integer;
  v_exercise_id uuid;
  v_sets smallint;
  v_median integer;
  v_p25 integer;
  v_p75 integer;
BEGIN
  IF array_length(p_exercise_ids, 1) IS NULL
     OR array_length(p_sets_per_exercise, 1) IS NULL
     OR array_length(p_exercise_ids, 1) != array_length(p_sets_per_exercise, 1) THEN
    RAISE EXCEPTION 'exercise_ids and sets_per_exercise must be non-empty and same length';
  END IF;

  SELECT overall_median_seconds INTO v_overall_median
  FROM user_overall_pacing WHERE user_id = p_user_id;

  v_overall_median := COALESCE(v_overall_median, 180);  -- 3min fallback

  FOR v_idx IN 1..array_length(p_exercise_ids, 1) LOOP
    v_exercise_id := p_exercise_ids[v_idx];
    v_sets := p_sets_per_exercise[v_idx];

    SELECT median_seconds_between_sets, p25_seconds_between_sets, p75_seconds_between_sets
    INTO v_median, v_p25, v_p75
    FROM user_exercise_pacing
    WHERE user_id = p_user_id AND exercise_id = v_exercise_id;

    IF v_median IS NOT NULL THEN
      v_with_history := v_with_history + 1;
      -- N sets = N-1 rest intervals
      v_total_seconds := v_total_seconds + (v_sets - 1) * v_median;
      v_lower_seconds := v_lower_seconds + (v_sets - 1) * v_p25;
      v_upper_seconds := v_upper_seconds + (v_sets - 1) * v_p75;
    ELSE
      v_with_fallback := v_with_fallback + 1;
      v_total_seconds := v_total_seconds + (v_sets - 1) * v_overall_median;
      v_lower_seconds := v_lower_seconds + (v_sets - 1) * v_overall_median * 0.75;
      v_upper_seconds := v_upper_seconds + (v_sets - 1) * v_overall_median * 1.33;
    END IF;

    -- Transition between exercises: add ~90s
    v_total_seconds := v_total_seconds + 90;
    v_lower_seconds := v_lower_seconds + 60;
    v_upper_seconds := v_upper_seconds + 120;
  END LOOP;

  RETURN QUERY SELECT
    CEIL((v_total_seconds + p_startup_minutes * 60) / 60.0)::smallint,
    CEIL((v_lower_seconds + p_startup_minutes * 60) / 60.0)::smallint,
    CEIL((v_upper_seconds + p_startup_minutes * 60) / 60.0)::smallint,
    v_with_history,
    v_with_fallback;
END;
$$;

COMMENT ON FUNCTION predict_session_duration(uuid, uuid[], smallint[], smallint) IS
  'Predicts total session duration given planned exercises and sets. Uses '
  'user_exercise_pacing (p25/median/p75 seconds between sets) per exercise. '
  'Falls back to overall median for exercises without history. Adds 90s '
  'exercise-transition overhead + startup_minutes (default 8). Returns '
  'lower/expected/upper bounds + counts of exercises with vs without history.';

COMMIT;
