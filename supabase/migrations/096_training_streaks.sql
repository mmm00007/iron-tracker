-- Migration 096: Training Consistency Streaks
-- Week-level streaks (consecutive weeks with >=N training days). The most
-- prominent motivation metric across all gym apps. Directly surfaces:
--   "You've trained 12 weeks in a row!"
--   "Personal best: 18-week streak"
--
-- training_milestones (migration 023) tracks milestone EVENTS (streak_4w,
-- streak_12w etc.) but doesn't give a LIVE current-streak count.
--
-- Validated by: ux-ui-specialist (motivation), data-science-expert
--
-- Key design decisions:
--   - Streak = consecutive ISO weeks with >= min_days_per_week (default 2)
--   - A user who trains Mon+Wed+Fri is "3 days that week" = streak continues
--   - A week with 0-1 training days BREAKS the streak
--   - current_streak looks backward from current week
--   - best_streak scans all history

BEGIN;

-- =============================================================================
-- 1. get_training_streaks(user_id, min_days_per_week)
-- =============================================================================

CREATE OR REPLACE FUNCTION get_training_streaks(
  p_user_id uuid,
  p_min_days_per_week integer DEFAULT 2
)
RETURNS TABLE (
  current_week_streak integer,
  best_week_streak integer,
  current_streak_start_date date,
  best_streak_start_date date,
  best_streak_end_date date,
  total_training_weeks integer,
  total_qualifying_weeks integer,
  avg_days_per_week numeric(3,1)
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public, pg_catalog
AS $$
BEGIN
  RETURN QUERY
  WITH weekly_training AS (
    SELECT
      date_trunc('week', s.training_date)::date AS week_start,
      COUNT(DISTINCT s.training_date)::integer AS training_days
    FROM sets s
    WHERE s.user_id = p_user_id
      AND s.training_date IS NOT NULL
    GROUP BY date_trunc('week', s.training_date)
  ),
  all_weeks AS (
    SELECT
      d::date AS week_start
    FROM generate_series(
      (SELECT MIN(week_start) FROM weekly_training),
      date_trunc('week', CURRENT_DATE)::date,
      interval '1 week'
    ) d
  ),
  merged AS (
    SELECT
      aw.week_start,
      COALESCE(wt.training_days, 0) AS training_days,
      (COALESCE(wt.training_days, 0) >= p_min_days_per_week) AS qualifies
    FROM all_weeks aw
    LEFT JOIN weekly_training wt ON wt.week_start = aw.week_start
  ),
  streak_groups AS (
    SELECT
      week_start,
      training_days,
      qualifies,
      -- Group consecutive qualifying weeks using the gaps-and-islands technique
      ROW_NUMBER() OVER (ORDER BY week_start) -
      ROW_NUMBER() OVER (PARTITION BY qualifies ORDER BY week_start) AS island_id
    FROM merged
  ),
  streaks AS (
    SELECT
      island_id,
      COUNT(*)::integer AS streak_length,
      MIN(week_start) AS streak_start,
      MAX(week_start) + 6 AS streak_end
    FROM streak_groups
    WHERE qualifies = true
    GROUP BY island_id
  ),
  current_streak AS (
    SELECT streak_length, streak_start
    FROM streaks
    WHERE streak_end >= date_trunc('week', CURRENT_DATE)::date
    ORDER BY streak_end DESC
    LIMIT 1
  ),
  best_streak AS (
    SELECT streak_length, streak_start, streak_end
    FROM streaks
    ORDER BY streak_length DESC
    LIMIT 1
  ),
  totals AS (
    SELECT
      COUNT(*) FILTER (WHERE training_days > 0)::integer AS total_training_weeks,
      COUNT(*) FILTER (WHERE qualifies)::integer AS total_qualifying_weeks,
      AVG(training_days) FILTER (WHERE training_days > 0)::numeric(3,1) AS avg_days_per_week
    FROM merged
  )
  SELECT
    COALESCE(cs.streak_length, 0)::integer,
    COALESCE(bs.streak_length, 0)::integer,
    cs.streak_start,
    bs.streak_start,
    bs.streak_end,
    t.total_training_weeks,
    t.total_qualifying_weeks,
    t.avg_days_per_week
  FROM totals t
  LEFT JOIN current_streak cs ON true
  LEFT JOIN best_streak bs ON true;
END;
$$;

COMMENT ON FUNCTION get_training_streaks(uuid, integer) IS
  'Computes current and best-ever week-streaks for a user. A week qualifies '
  'if user trained >= min_days_per_week (default 2). Uses gaps-and-islands '
  'technique on ISO weeks. Also returns total training/qualifying weeks + '
  'avg days per training week. Powers "12 weeks in a row!" motivation widget.';

-- =============================================================================
-- 2. user_streak_summary view: current state per user
-- =============================================================================

CREATE OR REPLACE VIEW user_streak_summary
WITH (security_invoker = true) AS
SELECT
  p.id AS user_id,
  (s).current_week_streak,
  (s).best_week_streak,
  (s).current_streak_start_date,
  (s).best_streak_start_date,
  (s).best_streak_end_date,
  (s).total_training_weeks,
  (s).total_qualifying_weeks,
  (s).avg_days_per_week,
  CASE
    WHEN (s).current_week_streak >= 52 THEN 'legendary'
    WHEN (s).current_week_streak >= 24 THEN 'elite'
    WHEN (s).current_week_streak >= 12 THEN 'consistent'
    WHEN (s).current_week_streak >= 4  THEN 'building'
    WHEN (s).current_week_streak >= 1  THEN 'started'
    ELSE                                    'inactive'
  END AS streak_tier,
  CASE
    WHEN (s).current_week_streak >= (s).best_week_streak AND (s).current_week_streak > 0
    THEN true ELSE false
  END AS is_personal_best_streak
FROM profiles p
CROSS JOIN LATERAL get_training_streaks(p.id, 2) s;

COMMENT ON VIEW user_streak_summary IS
  'Per-user current and best week-streak summary with streak_tier '
  '(legendary >=52w, elite >=24w, consistent >=12w, building >=4w, '
  'started >=1w, inactive). Flags is_personal_best_streak when current '
  'streak matches or exceeds all-time best. Powers home screen widget.';

COMMIT;
