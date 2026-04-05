-- Migration 095: Exercise Co-occurrence Analytics
-- Analyzes which exercises users typically train together in the same
-- session. Powers "users who do X also do Y" recommendations, session
-- flow suggestions, and template generation.
--
-- Co-occurrence defined as: two exercises performed on the same
-- (user, training_date). Raw pair count + user-level confidence metrics.
--
-- Validated by: data-science-expert
--
-- Use cases:
--   - When user adds an exercise to a session, suggest common companions.
--   - Extract implicit workout templates from user history.
--   - Cross-sell: "people who squat also front squat" style recommendations.

BEGIN;

-- =============================================================================
-- 1. user_exercise_cooccurrence view (per-user pairs)
-- =============================================================================
-- For each user, count how often exercise_a and exercise_b were trained
-- together. Canonical ordering: lesser_uuid as exercise_a_id.

CREATE OR REPLACE VIEW user_exercise_cooccurrence
WITH (security_invoker = true) AS
WITH same_day_pairs AS (
  SELECT DISTINCT
    s1.user_id,
    LEAST(s1.exercise_id, s2.exercise_id) AS exercise_a_id,
    GREATEST(s1.exercise_id, s2.exercise_id) AS exercise_b_id,
    s1.training_date
  FROM sets s1
  JOIN sets s2
    ON s1.user_id = s2.user_id
    AND s1.training_date = s2.training_date
    AND s1.exercise_id < s2.exercise_id
  WHERE s1.training_date IS NOT NULL
    AND s1.set_type = 'working'
    AND s2.set_type = 'working'
    AND s1.training_date >= CURRENT_DATE - 180
)
SELECT
  user_id,
  exercise_a_id,
  exercise_b_id,
  COUNT(*)::integer AS sessions_together
FROM same_day_pairs
GROUP BY user_id, exercise_a_id, exercise_b_id
HAVING COUNT(*) >= 2;

COMMENT ON VIEW user_exercise_cooccurrence IS
  'Per-user exercise-pair co-occurrence: how often the two exercises were '
  'trained on the same day over last 180 days. Minimum 2 shared sessions. '
  'Canonical ordering (exercise_a_id < exercise_b_id) ensures one row per pair.';

-- =============================================================================
-- 2. exercise_training_companions view (per-user, one-sided)
-- =============================================================================
-- Given an exercise, list its top companion exercises for a user with
-- confidence metrics. Used when user adds an exercise and app suggests
-- "commonly trained with:".

CREATE OR REPLACE VIEW exercise_training_companions
WITH (security_invoker = true) AS
WITH exercise_session_counts AS (
  SELECT
    user_id, exercise_id,
    COUNT(DISTINCT training_date) AS exercise_sessions
  FROM sets
  WHERE training_date IS NOT NULL
    AND set_type = 'working'
    AND training_date >= CURRENT_DATE - 180
  GROUP BY user_id, exercise_id
),
pairs_both_directions AS (
  SELECT
    user_id,
    exercise_a_id AS primary_exercise_id,
    exercise_b_id AS companion_exercise_id,
    sessions_together
  FROM user_exercise_cooccurrence
  UNION ALL
  SELECT
    user_id,
    exercise_b_id AS primary_exercise_id,
    exercise_a_id AS companion_exercise_id,
    sessions_together
  FROM user_exercise_cooccurrence
)
SELECT
  pbd.user_id,
  pbd.primary_exercise_id,
  pbd.companion_exercise_id,
  e_companion.name AS companion_exercise_name,
  pbd.sessions_together,
  esc.exercise_sessions AS primary_total_sessions,
  -- Confidence: P(companion | primary) = sessions_together / primary_sessions
  ROUND((pbd.sessions_together::numeric / NULLIF(esc.exercise_sessions, 0) * 100), 1) AS pct_sessions_paired
FROM pairs_both_directions pbd
JOIN exercises e_companion ON e_companion.id = pbd.companion_exercise_id
JOIN exercise_session_counts esc
  ON esc.user_id = pbd.user_id AND esc.exercise_id = pbd.primary_exercise_id;

COMMENT ON VIEW exercise_training_companions IS
  'For each (user, primary_exercise), lists companion exercises with '
  'sessions_together count + pct_sessions_paired (confidence). '
  'Use: "When you train X, you also train Y 85% of the time". '
  'Powers session-flow suggestions + implicit-template extraction.';

-- =============================================================================
-- 3. get_exercise_companions() function: ranked suggestions for a user
-- =============================================================================

CREATE OR REPLACE FUNCTION get_exercise_companions(
  p_user_id uuid,
  p_exercise_id uuid,
  p_limit integer DEFAULT 5
)
RETURNS TABLE (
  companion_exercise_id uuid,
  companion_exercise_name text,
  sessions_together integer,
  pct_sessions_paired numeric(4,1),
  confidence_band text
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, pg_catalog
AS $$
  SELECT
    companion_exercise_id,
    companion_exercise_name,
    sessions_together,
    pct_sessions_paired,
    CASE
      WHEN pct_sessions_paired >= 75 THEN 'near_always'
      WHEN pct_sessions_paired >= 50 THEN 'usually'
      WHEN pct_sessions_paired >= 25 THEN 'sometimes'
      ELSE                                 'occasionally'
    END AS confidence_band
  FROM exercise_training_companions
  WHERE user_id = p_user_id
    AND primary_exercise_id = p_exercise_id
  ORDER BY sessions_together DESC, pct_sessions_paired DESC
  LIMIT p_limit;
$$;

COMMENT ON FUNCTION get_exercise_companions(uuid, uuid, integer) IS
  'Top N exercise companions for a user+exercise. Confidence bands: '
  'near_always (>=75%%), usually (>=50%%), sometimes (>=25%%), '
  'occasionally (<25%%). Powers "add to session" suggestions.';

-- =============================================================================
-- 4. user_implicit_split view: cluster exercises into sessions
-- =============================================================================
-- Extracts the user's de-facto training split by grouping exercises that
-- commonly co-occur. Simple approach: list distinct same-day exercise groups.

CREATE OR REPLACE VIEW user_implicit_split
WITH (security_invoker = true) AS
WITH session_patterns AS (
  SELECT
    s.user_id,
    s.training_date,
    string_agg(DISTINCT e.name, ', ' ORDER BY e.name) AS exercise_list,
    COUNT(DISTINCT s.exercise_id) AS exercise_count
  FROM sets s
  JOIN exercises e ON e.id = s.exercise_id
  WHERE s.training_date IS NOT NULL
    AND s.set_type = 'working'
    AND s.training_date >= CURRENT_DATE - 90
  GROUP BY s.user_id, s.training_date
)
SELECT
  user_id,
  exercise_list,
  exercise_count,
  COUNT(*)::integer AS times_performed,
  MAX(training_date) AS most_recent_date,
  MIN(training_date) AS first_occurrence_date
FROM session_patterns
GROUP BY user_id, exercise_list, exercise_count
HAVING COUNT(*) >= 2;

COMMENT ON VIEW user_implicit_split IS
  'Extracts user de-facto training split: distinct same-day exercise groups '
  'performed >=2 times in last 90 days. exercise_list is alphabetical '
  'string. times_performed indicates how established this session is. '
  'Used to surface "Your Push Day" / "Your Pull Day" implicit templates.';

COMMIT;
