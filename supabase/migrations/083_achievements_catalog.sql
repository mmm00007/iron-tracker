-- Migration 083: Achievements Catalog + Unlock System
-- Gamification layer beyond training_milestones (streaks + BW multiples).
-- Catalogs 30+ named achievements across volume, discipline, strength,
-- and variety categories. Users unlock achievements by meeting criteria.
--
-- Validated by: ux-ui-specialist (motivation), fitness-domain-expert (thresholds)
--
-- Key design decisions:
--   - Achievements reference table (seeded) separate from user_achievements
--     (instance records) for clean many-to-many.
--   - Achievement criteria stored as metadata JSONB so detection functions
--     can introspect thresholds without hardcoded values.
--   - Unlock timestamp preserves order; no unlocking twice.
--   - Categories: volume, discipline, strength, variety, recovery, special.
--   - Rarity tiers: bronze/silver/gold/platinum/diamond.

BEGIN;

-- =============================================================================
-- 1. achievements reference table
-- =============================================================================

CREATE TABLE IF NOT EXISTS achievements (
  id             serial      PRIMARY KEY,
  slug           text        NOT NULL UNIQUE,
  display_name   text        NOT NULL,
  description    text        NOT NULL,
  category       text        NOT NULL
    CHECK (category IN ('volume', 'discipline', 'strength', 'variety', 'recovery', 'special')),
  rarity         text        NOT NULL
    CHECK (rarity IN ('bronze', 'silver', 'gold', 'platinum', 'diamond')),
  icon_emoji     text,
  criteria       jsonb       NOT NULL,
  display_order  smallint    NOT NULL DEFAULT 0,
  is_active      boolean     NOT NULL DEFAULT true
);

COMMENT ON TABLE achievements IS
  'Reference catalog of available achievements. Public read. criteria JSONB '
  'describes thresholds (used by detection functions); rarity drives UI badge.';

COMMENT ON COLUMN achievements.criteria IS
  'JSONB with detection parameters. Examples: '
  '{"type":"total_sets","threshold":1000} '
  '{"type":"streak_days","threshold":30} '
  '{"type":"bw_multiple","exercise":"bench press","threshold":1.5} '
  '{"type":"distinct_exercises","threshold":25}';

CREATE INDEX IF NOT EXISTS achievements_active_idx
  ON achievements (category, display_order) WHERE is_active = true;

ALTER TABLE achievements ENABLE ROW LEVEL SECURITY;
CREATE POLICY achievements_select ON achievements
  FOR SELECT TO authenticated USING (true);

-- =============================================================================
-- 2. user_achievements (unlocks)
-- =============================================================================

CREATE TABLE IF NOT EXISTS user_achievements (
  id               uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id          uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  achievement_id   integer     NOT NULL REFERENCES achievements(id) ON DELETE CASCADE,
  unlocked_at      timestamptz NOT NULL DEFAULT now(),
  context          jsonb,
  UNIQUE (user_id, achievement_id)
);

COMMENT ON TABLE user_achievements IS
  'Records which achievements a user has unlocked. context JSONB captures '
  'the specific data that triggered the unlock (e.g., bench PR value, streak '
  'day count). Unlocks are permanent — no revocations.';

CREATE INDEX IF NOT EXISTS user_achievements_user_unlocked_idx
  ON user_achievements (user_id, unlocked_at DESC);

ALTER TABLE user_achievements ENABLE ROW LEVEL SECURITY;
CREATE POLICY user_achievements_select ON user_achievements
  FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY user_achievements_insert ON user_achievements
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY user_achievements_delete ON user_achievements
  FOR DELETE TO authenticated USING (user_id = auth.uid());

-- =============================================================================
-- 3. detect_new_achievements(user_id) function
-- =============================================================================
-- Evaluates all active achievements vs user's current state. Inserts any newly
-- earned achievements into user_achievements. Returns count of new unlocks.

CREATE OR REPLACE FUNCTION detect_new_achievements(p_user_id uuid)
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_catalog
AS $$
DECLARE
  v_count integer := 0;
  v_last_count integer;
BEGIN
  -- Total working sets milestones
  INSERT INTO user_achievements (user_id, achievement_id, context)
  SELECT p_user_id, a.id, jsonb_build_object(
    'sets_total', (SELECT COUNT(*) FROM sets WHERE user_id = p_user_id AND set_type = 'working')
  )
  FROM achievements a
  WHERE a.criteria->>'type' = 'total_working_sets'
    AND a.is_active = true
    AND (SELECT COUNT(*) FROM sets WHERE user_id = p_user_id AND set_type = 'working')
        >= (a.criteria->>'threshold')::integer
    AND NOT EXISTS (SELECT 1 FROM user_achievements ua
                    WHERE ua.user_id = p_user_id AND ua.achievement_id = a.id)
  ON CONFLICT DO NOTHING;
  GET DIAGNOSTICS v_last_count = ROW_COUNT;
  v_count := v_count + v_last_count;

  -- Total lifetime volume (kg) milestones
  INSERT INTO user_achievements (user_id, achievement_id, context)
  SELECT p_user_id, a.id, jsonb_build_object(
    'total_volume_kg', (SELECT COALESCE(SUM(weight * reps), 0) FROM sets WHERE user_id = p_user_id AND set_type = 'working')
  )
  FROM achievements a
  WHERE a.criteria->>'type' = 'total_volume_kg'
    AND a.is_active = true
    AND (SELECT COALESCE(SUM(weight * reps), 0) FROM sets WHERE user_id = p_user_id AND set_type = 'working')
        >= (a.criteria->>'threshold')::numeric
    AND NOT EXISTS (SELECT 1 FROM user_achievements ua
                    WHERE ua.user_id = p_user_id AND ua.achievement_id = a.id)
  ON CONFLICT DO NOTHING;
  GET DIAGNOSTICS v_last_count = ROW_COUNT;
  v_count := v_count + v_last_count;

  -- Distinct exercises trained
  INSERT INTO user_achievements (user_id, achievement_id, context)
  SELECT p_user_id, a.id, jsonb_build_object(
    'distinct_exercises', (SELECT COUNT(DISTINCT exercise_id) FROM sets WHERE user_id = p_user_id)
  )
  FROM achievements a
  WHERE a.criteria->>'type' = 'distinct_exercises'
    AND a.is_active = true
    AND (SELECT COUNT(DISTINCT exercise_id) FROM sets WHERE user_id = p_user_id)
        >= (a.criteria->>'threshold')::integer
    AND NOT EXISTS (SELECT 1 FROM user_achievements ua
                    WHERE ua.user_id = p_user_id AND ua.achievement_id = a.id)
  ON CONFLICT DO NOTHING;
  GET DIAGNOSTICS v_last_count = ROW_COUNT;
  v_count := v_count + v_last_count;

  -- Distinct training days
  INSERT INTO user_achievements (user_id, achievement_id, context)
  SELECT p_user_id, a.id, jsonb_build_object(
    'training_days', (SELECT COUNT(DISTINCT training_date) FROM sets WHERE user_id = p_user_id AND training_date IS NOT NULL)
  )
  FROM achievements a
  WHERE a.criteria->>'type' = 'training_days_total'
    AND a.is_active = true
    AND (SELECT COUNT(DISTINCT training_date) FROM sets WHERE user_id = p_user_id AND training_date IS NOT NULL)
        >= (a.criteria->>'threshold')::integer
    AND NOT EXISTS (SELECT 1 FROM user_achievements ua
                    WHERE ua.user_id = p_user_id AND ua.achievement_id = a.id)
  ON CONFLICT DO NOTHING;
  GET DIAGNOSTICS v_last_count = ROW_COUNT;
  v_count := v_count + v_last_count;

  -- PR count milestones
  INSERT INTO user_achievements (user_id, achievement_id, context)
  SELECT p_user_id, a.id, jsonb_build_object(
    'total_prs', (SELECT COUNT(*) FROM pr_events WHERE user_id = p_user_id)
  )
  FROM achievements a
  WHERE a.criteria->>'type' = 'lifetime_prs'
    AND a.is_active = true
    AND (SELECT COUNT(*) FROM pr_events WHERE user_id = p_user_id)
        >= (a.criteria->>'threshold')::integer
    AND NOT EXISTS (SELECT 1 FROM user_achievements ua
                    WHERE ua.user_id = p_user_id AND ua.achievement_id = a.id)
  ON CONFLICT DO NOTHING;
  GET DIAGNOSTICS v_last_count = ROW_COUNT;
  v_count := v_count + v_last_count;

  RETURN v_count;
END;
$$;

COMMENT ON FUNCTION detect_new_achievements(uuid) IS
  'Evaluates all active achievements vs user''s current training state and '
  'inserts any newly-earned achievements. Idempotent via UNIQUE constraint. '
  'Returns count of new unlocks. Backend cron calls daily per active user.';

-- =============================================================================
-- 4. achievement_progress view
-- =============================================================================
-- Shows user's progress toward not-yet-unlocked achievements. Powers the
-- "almost there!" motivation card.

CREATE OR REPLACE VIEW achievement_progress
WITH (security_invoker = true) AS
WITH user_stats AS (
  SELECT
    (SELECT COUNT(*) FROM sets WHERE user_id = p.id AND set_type = 'working')::bigint AS working_sets,
    (SELECT COALESCE(SUM(weight * reps), 0) FROM sets WHERE user_id = p.id AND set_type = 'working')::numeric AS total_volume_kg,
    (SELECT COUNT(DISTINCT exercise_id) FROM sets WHERE user_id = p.id)::integer AS distinct_exercises,
    (SELECT COUNT(DISTINCT training_date) FROM sets WHERE user_id = p.id AND training_date IS NOT NULL)::integer AS training_days,
    p.id AS user_id
  FROM profiles p
)
SELECT
  us.user_id,
  a.id AS achievement_id,
  a.slug,
  a.display_name,
  a.description,
  a.category,
  a.rarity,
  a.icon_emoji,
  (a.criteria->>'threshold')::numeric AS threshold,
  a.criteria->>'type' AS criterion_type,
  CASE a.criteria->>'type'
    WHEN 'total_working_sets' THEN us.working_sets::numeric
    WHEN 'total_volume_kg' THEN us.total_volume_kg
    WHEN 'distinct_exercises' THEN us.distinct_exercises::numeric
    WHEN 'training_days_total' THEN us.training_days::numeric
  END AS current_value,
  ROUND(
    LEAST(100, CASE a.criteria->>'type'
      WHEN 'total_working_sets' THEN us.working_sets::numeric / NULLIF((a.criteria->>'threshold')::numeric, 0) * 100
      WHEN 'total_volume_kg' THEN us.total_volume_kg / NULLIF((a.criteria->>'threshold')::numeric, 0) * 100
      WHEN 'distinct_exercises' THEN us.distinct_exercises::numeric / NULLIF((a.criteria->>'threshold')::numeric, 0) * 100
      WHEN 'training_days_total' THEN us.training_days::numeric / NULLIF((a.criteria->>'threshold')::numeric, 0) * 100
      ELSE 0
    END)::numeric, 1
  ) AS progress_pct,
  EXISTS (SELECT 1 FROM user_achievements ua WHERE ua.user_id = us.user_id AND ua.achievement_id = a.id) AS is_unlocked
FROM user_stats us
CROSS JOIN achievements a
WHERE a.is_active = true
  AND a.criteria->>'type' IN ('total_working_sets','total_volume_kg','distinct_exercises','training_days_total');

COMMENT ON VIEW achievement_progress IS
  'Per-user progress toward each achievement. progress_pct caps at 100. '
  'Powers "almost there!" coaching cards. Currently supports 4 criterion types; '
  'more can be added as detection function grows.';

-- =============================================================================
-- 5. SEED DATA: 30 achievements across 6 categories
-- =============================================================================

INSERT INTO achievements (slug, display_name, description, category, rarity, icon_emoji, criteria, display_order) VALUES
  -- VOLUME (working sets)
  ('sets_100',   'Century',            'Log 100 working sets', 'volume', 'bronze', '💯',
   '{"type":"total_working_sets","threshold":100}', 10),
  ('sets_1000',  '1K Club',            'Log 1,000 working sets', 'volume', 'silver', '🎯',
   '{"type":"total_working_sets","threshold":1000}', 11),
  ('sets_5000',  'Iron Addict',        'Log 5,000 working sets', 'volume', 'gold', '🏋️',
   '{"type":"total_working_sets","threshold":5000}', 12),
  ('sets_10000', '10K Champion',       'Log 10,000 working sets', 'volume', 'platinum', '🥇',
   '{"type":"total_working_sets","threshold":10000}', 13),
  ('sets_25000', 'Lifelong Lifter',    'Log 25,000 working sets', 'volume', 'diamond', '💎',
   '{"type":"total_working_sets","threshold":25000}', 14),

  -- VOLUME (total tonnage kg)
  ('tonnage_10k',   '10 Tonnes',      'Lift 10,000 kg total volume', 'volume', 'bronze', '⚖️',
   '{"type":"total_volume_kg","threshold":10000}', 20),
  ('tonnage_100k',  '100 Tonnes',     'Lift 100,000 kg total volume', 'volume', 'silver', '🚛',
   '{"type":"total_volume_kg","threshold":100000}', 21),
  ('tonnage_500k',  'Half Megaton',   'Lift 500,000 kg total volume', 'volume', 'gold', '🏗️',
   '{"type":"total_volume_kg","threshold":500000}', 22),
  ('tonnage_1m',    'Megaton Club',   'Lift 1,000,000 kg total volume', 'volume', 'platinum', '🏛️',
   '{"type":"total_volume_kg","threshold":1000000}', 23),
  ('tonnage_5m',    'Megaton Master', 'Lift 5,000,000 kg total volume', 'volume', 'diamond', '🗿',
   '{"type":"total_volume_kg","threshold":5000000}', 24),

  -- DISCIPLINE (training days)
  ('days_10',   'Getting Started',   'Train for 10 distinct days', 'discipline', 'bronze', '🗓️',
   '{"type":"training_days_total","threshold":10}', 30),
  ('days_50',   'Consistent',        'Train for 50 distinct days', 'discipline', 'bronze', '✅',
   '{"type":"training_days_total","threshold":50}', 31),
  ('days_100',  'Triple Digits',     'Train for 100 distinct days', 'discipline', 'silver', '🔥',
   '{"type":"training_days_total","threshold":100}', 32),
  ('days_250',  'Quarter Grand',     'Train for 250 distinct days', 'discipline', 'silver', '⭐',
   '{"type":"training_days_total","threshold":250}', 33),
  ('days_500',  'Dedicated',         'Train for 500 distinct days', 'discipline', 'gold', '🎖️',
   '{"type":"training_days_total","threshold":500}', 34),
  ('days_1000', 'Gym Rat',           'Train for 1,000 distinct days', 'discipline', 'platinum', '🐀',
   '{"type":"training_days_total","threshold":1000}', 35),
  ('days_2000', 'Iron Monk',         'Train for 2,000 distinct days', 'discipline', 'diamond', '🧘',
   '{"type":"training_days_total","threshold":2000}', 36),

  -- VARIETY (distinct exercises)
  ('variety_10',  'Exploring',        'Train 10 distinct exercises', 'variety', 'bronze', '🔍',
   '{"type":"distinct_exercises","threshold":10}', 40),
  ('variety_25',  'Well-Rounded',     'Train 25 distinct exercises', 'variety', 'silver', '🌀',
   '{"type":"distinct_exercises","threshold":25}', 41),
  ('variety_50',  'Polyathlete',      'Train 50 distinct exercises', 'variety', 'gold', '🎨',
   '{"type":"distinct_exercises","threshold":50}', 42),
  ('variety_100', 'Exercise Maestro', 'Train 100 distinct exercises', 'variety', 'platinum', '🎭',
   '{"type":"distinct_exercises","threshold":100}', 43),

  -- STRENGTH (PR counts)
  ('prs_10',   'PR Hunter',       'Set 10 lifetime personal records', 'strength', 'bronze', '📈',
   '{"type":"lifetime_prs","threshold":10}', 50),
  ('prs_50',   'Record Breaker',  'Set 50 lifetime personal records', 'strength', 'silver', '🏆',
   '{"type":"lifetime_prs","threshold":50}', 51),
  ('prs_100',  'Century PR',      'Set 100 lifetime personal records', 'strength', 'gold', '💪',
   '{"type":"lifetime_prs","threshold":100}', 52),
  ('prs_250',  'Progress Legend', 'Set 250 lifetime personal records', 'strength', 'platinum', '🌟',
   '{"type":"lifetime_prs","threshold":250}', 53),
  ('prs_500',  'PR Machine',      'Set 500 lifetime personal records', 'strength', 'diamond', '⚡',
   '{"type":"lifetime_prs","threshold":500}', 54)
ON CONFLICT (slug) DO NOTHING;

COMMIT;
