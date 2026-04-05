-- Migration 093: Achievement Forecasts
-- Projects days-to-unlock for each achievement based on user's current
-- rate of progress. Enables "you'll hit 1K Club in ~3 weeks at your
-- current pace" motivation cards.
--
-- For each not-yet-unlocked achievement, computes:
--   - current_value (same as achievement_progress)
--   - daily_rate (how fast the criterion is advancing, last 30 days)
--   - days_to_unlock = (threshold - current) / daily_rate
--   - forecast_date = CURRENT_DATE + days_to_unlock
--
-- Only forecasts when rate > 0 (user actively progressing).
--
-- Validated by: data-science-expert

BEGIN;

CREATE OR REPLACE VIEW achievement_forecasts
WITH (security_invoker = true) AS
WITH user_rates AS (
  SELECT
    p.id AS user_id,
    -- Sets per day over last 30d
    (SELECT COUNT(*) FROM sets WHERE user_id = p.id AND set_type = 'working'
       AND training_date >= CURRENT_DATE - 30 AND training_date <= CURRENT_DATE)::numeric / 30 AS working_sets_per_day,
    -- Volume per day over last 30d
    (SELECT COALESCE(SUM(weight * reps), 0) FROM sets WHERE user_id = p.id AND set_type = 'working'
       AND training_date >= CURRENT_DATE - 30 AND training_date <= CURRENT_DATE)::numeric / 30 AS volume_per_day,
    -- New distinct exercises per month (harder to project — use 90d rate)
    (SELECT COUNT(DISTINCT exercise_id) FROM sets WHERE user_id = p.id
       AND training_date >= CURRENT_DATE - 90 AND training_date <= CURRENT_DATE)::numeric / 90 AS exercises_per_day,
    -- Training days per day (always 0-1). Use 30d rate.
    (SELECT COUNT(DISTINCT training_date) FROM sets WHERE user_id = p.id
       AND training_date >= CURRENT_DATE - 30 AND training_date <= CURRENT_DATE)::numeric / 30 AS training_days_per_day,
    -- Current totals
    (SELECT COUNT(*) FROM sets WHERE user_id = p.id AND set_type = 'working')::numeric AS current_working_sets,
    (SELECT COALESCE(SUM(weight * reps), 0) FROM sets WHERE user_id = p.id AND set_type = 'working')::numeric AS current_volume_kg,
    (SELECT COUNT(DISTINCT exercise_id) FROM sets WHERE user_id = p.id)::numeric AS current_distinct_exercises,
    (SELECT COUNT(DISTINCT training_date) FROM sets WHERE user_id = p.id AND training_date IS NOT NULL)::numeric AS current_training_days
  FROM profiles p
)
SELECT
  ur.user_id,
  a.id AS achievement_id,
  a.slug,
  a.display_name,
  a.category,
  a.rarity,
  a.icon_emoji,
  (a.criteria->>'threshold')::numeric AS threshold,
  a.criteria->>'type' AS criterion_type,
  -- Current value per criterion type
  CASE a.criteria->>'type'
    WHEN 'total_working_sets' THEN ur.current_working_sets
    WHEN 'total_volume_kg' THEN ur.current_volume_kg
    WHEN 'distinct_exercises' THEN ur.current_distinct_exercises
    WHEN 'training_days_total' THEN ur.current_training_days
    ELSE NULL
  END AS current_value,
  -- Daily rate
  CASE a.criteria->>'type'
    WHEN 'total_working_sets' THEN ur.working_sets_per_day
    WHEN 'total_volume_kg' THEN ur.volume_per_day
    WHEN 'distinct_exercises' THEN ur.exercises_per_day
    WHEN 'training_days_total' THEN ur.training_days_per_day
    ELSE NULL
  END::numeric(10,3) AS daily_rate,
  -- Days to unlock (NULL if rate is 0)
  CASE a.criteria->>'type'
    WHEN 'total_working_sets' THEN
      CASE WHEN ur.working_sets_per_day > 0
      THEN CEIL(((a.criteria->>'threshold')::numeric - ur.current_working_sets) / ur.working_sets_per_day)::integer
      ELSE NULL END
    WHEN 'total_volume_kg' THEN
      CASE WHEN ur.volume_per_day > 0
      THEN CEIL(((a.criteria->>'threshold')::numeric - ur.current_volume_kg) / ur.volume_per_day)::integer
      ELSE NULL END
    WHEN 'distinct_exercises' THEN
      CASE WHEN ur.exercises_per_day > 0
      THEN CEIL(((a.criteria->>'threshold')::numeric - ur.current_distinct_exercises) / ur.exercises_per_day)::integer
      ELSE NULL END
    WHEN 'training_days_total' THEN
      CASE WHEN ur.training_days_per_day > 0
      THEN CEIL(((a.criteria->>'threshold')::numeric - ur.current_training_days) / ur.training_days_per_day)::integer
      ELSE NULL END
    ELSE NULL
  END AS days_to_unlock,
  -- Forecast date
  CURRENT_DATE + (
    CASE a.criteria->>'type'
      WHEN 'total_working_sets' THEN
        CASE WHEN ur.working_sets_per_day > 0
        THEN CEIL(((a.criteria->>'threshold')::numeric - ur.current_working_sets) / ur.working_sets_per_day)::integer
        ELSE NULL END
      WHEN 'total_volume_kg' THEN
        CASE WHEN ur.volume_per_day > 0
        THEN CEIL(((a.criteria->>'threshold')::numeric - ur.current_volume_kg) / ur.volume_per_day)::integer
        ELSE NULL END
      WHEN 'distinct_exercises' THEN
        CASE WHEN ur.exercises_per_day > 0
        THEN CEIL(((a.criteria->>'threshold')::numeric - ur.current_distinct_exercises) / ur.exercises_per_day)::integer
        ELSE NULL END
      WHEN 'training_days_total' THEN
        CASE WHEN ur.training_days_per_day > 0
        THEN CEIL(((a.criteria->>'threshold')::numeric - ur.current_training_days) / ur.training_days_per_day)::integer
        ELSE NULL END
      ELSE NULL
    END
  ) AS forecast_unlock_date
FROM user_rates ur
CROSS JOIN achievements a
WHERE a.is_active = true
  AND a.criteria->>'type' IN ('total_working_sets','total_volume_kg','distinct_exercises','training_days_total')
  -- Not yet unlocked
  AND NOT EXISTS (
    SELECT 1 FROM user_achievements ua
    WHERE ua.user_id = ur.user_id AND ua.achievement_id = a.id
  )
  -- Below threshold
  AND (
    CASE a.criteria->>'type'
      WHEN 'total_working_sets' THEN ur.current_working_sets
      WHEN 'total_volume_kg' THEN ur.current_volume_kg
      WHEN 'distinct_exercises' THEN ur.current_distinct_exercises
      WHEN 'training_days_total' THEN ur.current_training_days
    END
  ) < (a.criteria->>'threshold')::numeric;

COMMENT ON VIEW achievement_forecasts IS
  'Per-user forecast of when each unearned achievement will unlock at '
  'current rate of progress. Daily rates computed over last 30 days (or '
  '90 for distinct exercises). Returns NULL when rate is 0 (user not '
  'progressing on that criterion). Powers "you''ll hit X in Y days" cards.';

-- =============================================================================
-- next_likely_unlock view: the soonest-forecast achievement per user
-- =============================================================================

CREATE OR REPLACE VIEW next_likely_unlock
WITH (security_invoker = true) AS
SELECT DISTINCT ON (user_id)
  user_id, achievement_id, slug, display_name, category, rarity, icon_emoji,
  current_value, threshold, daily_rate, days_to_unlock, forecast_unlock_date
FROM achievement_forecasts
WHERE days_to_unlock IS NOT NULL AND days_to_unlock <= 365  -- forecast within 1 year only
ORDER BY user_id, days_to_unlock ASC;

COMMENT ON VIEW next_likely_unlock IS
  'Per-user SINGLE next achievement forecast to unlock (soonest-coming). '
  'Filters to forecasts within 1 year. Powers dashboard "next milestone" card.';

COMMIT;
