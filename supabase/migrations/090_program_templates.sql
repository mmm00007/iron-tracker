-- Migration 090: Program Templates Catalog
-- Pre-built training programs users can follow. Solves the new-user
-- cold-start problem ("what should I do?") by offering established
-- programs with prescriptive session/exercise schedules.
--
-- This migration creates a lightweight 3-table catalog:
--   program_templates   — top-level metadata per program
--   program_template_sessions — each day/session within a program
--   program_template_items — each exercise prescription per session
--
-- Seeds 5 popular evidence-backed programs:
--   StrongLifts 5x5 (3-day full-body strength)
--   Starting Strength (3-day novice linear progression)
--   PPL 6-day (hypertrophy-focused push/pull/legs)
--   Upper/Lower 4-day (intermediate balanced)
--   5/3/1 BBB (intermediate/advanced powerlifting)
--
-- Validated by: fitness-domain-expert (program selection + prescriptions)
--
-- Key design decisions:
--   - Exercises referenced by name hint (case-insensitive match) not FK —
--     allows flexibility across users with different exercise catalogs.
--   - Intensity as pct_of_1rm OR target_rpe OR fixed weight (any one).
--   - Sets/reps stored as flexible target strings ("5x5", "3x5", "5/3/1").
--   - source field tracks provenance for credit/citation.

BEGIN;

-- =============================================================================
-- 1. program_templates (top-level catalog)
-- =============================================================================

CREATE TABLE IF NOT EXISTS program_templates (
  id               serial      PRIMARY KEY,
  slug             text        NOT NULL UNIQUE,
  display_name     text        NOT NULL,
  description      text        NOT NULL,
  goal             text        NOT NULL CHECK (goal IN ('strength','hypertrophy','general','endurance','powerlifting')),
  experience_level text        NOT NULL CHECK (experience_level IN ('beginner','intermediate','advanced','any')),
  duration_weeks   smallint    CHECK (duration_weeks IS NULL OR duration_weeks > 0),
  days_per_week    smallint    NOT NULL CHECK (days_per_week BETWEEN 1 AND 7),
  source           text        NOT NULL,
  source_url       text,
  is_active        boolean     NOT NULL DEFAULT true,
  display_order    smallint    NOT NULL DEFAULT 0
);

COMMENT ON TABLE program_templates IS
  'Catalog of pre-built training programs. Public read. Users can fork/start '
  'a program which creates per-user plan_days + plan_items from the template.';

CREATE INDEX IF NOT EXISTS program_templates_active_idx
  ON program_templates (is_active, display_order, days_per_week)
  WHERE is_active = true;

ALTER TABLE program_templates ENABLE ROW LEVEL SECURITY;
CREATE POLICY program_templates_select ON program_templates
  FOR SELECT TO authenticated USING (true);

-- =============================================================================
-- 2. program_template_sessions (one row per day in program)
-- =============================================================================

CREATE TABLE IF NOT EXISTS program_template_sessions (
  id                   uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  program_template_id  integer     NOT NULL REFERENCES program_templates(id) ON DELETE CASCADE,
  day_number           smallint    NOT NULL CHECK (day_number BETWEEN 1 AND 7),
  session_name         text        NOT NULL,
  focus                text,
  notes                text,
  UNIQUE (program_template_id, day_number)
);

COMMENT ON TABLE program_template_sessions IS
  'Per-day sessions within a program. day_number 1-7 maps to ordinal day '
  'within the weekly cycle (user assigns these to calendar weekdays when forking).';

CREATE INDEX IF NOT EXISTS program_template_sessions_program_idx
  ON program_template_sessions (program_template_id, day_number);

ALTER TABLE program_template_sessions ENABLE ROW LEVEL SECURITY;
CREATE POLICY program_template_sessions_select ON program_template_sessions
  FOR SELECT TO authenticated USING (true);

-- =============================================================================
-- 3. program_template_items (exercise prescriptions per session)
-- =============================================================================

CREATE TABLE IF NOT EXISTS program_template_items (
  id                            uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id                    uuid        NOT NULL REFERENCES program_template_sessions(id) ON DELETE CASCADE,
  sort_order                    smallint    NOT NULL CHECK (sort_order > 0),
  exercise_name_hint            text        NOT NULL,
  target_sets                   smallint    CHECK (target_sets > 0 AND target_sets <= 20),
  target_reps                   text,
  target_intensity_pct_1rm      smallint    CHECK (target_intensity_pct_1rm IS NULL OR (target_intensity_pct_1rm > 0 AND target_intensity_pct_1rm <= 105)),
  target_rpe                    numeric(3,1) CHECK (target_rpe IS NULL OR (target_rpe >= 1 AND target_rpe <= 10)),
  rest_seconds                  smallint    CHECK (rest_seconds IS NULL OR (rest_seconds >= 0 AND rest_seconds <= 900)),
  notes                         text,
  UNIQUE (session_id, sort_order)
);

COMMENT ON TABLE program_template_items IS
  'Exercise prescriptions per template session. Users match exercise_name_hint '
  'to their exercise catalog when forking. target_reps is flexible text '
  '("5", "8-12", "AMRAP") since programs vary.';

CREATE INDEX IF NOT EXISTS program_template_items_session_idx
  ON program_template_items (session_id, sort_order);

ALTER TABLE program_template_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY program_template_items_select ON program_template_items
  FOR SELECT TO authenticated USING (true);

-- =============================================================================
-- 4. SEED: 5 evidence-backed programs
-- =============================================================================

-- StrongLifts 5x5 (simple 3-day beginner strength program)
INSERT INTO program_templates
  (slug, display_name, description, goal, experience_level, duration_weeks, days_per_week, source, source_url, display_order)
VALUES
  ('stronglifts-5x5', 'StrongLifts 5x5',
   'Simple 3-day beginner strength program. Two alternating workouts (A/B) with squat every session. Add 2.5kg each session until stall.',
   'strength', 'beginner', 12, 3, 'StrongLifts.com', 'https://stronglifts.com/5x5/', 10)
ON CONFLICT (slug) DO NOTHING;

-- Starting Strength (novice linear progression by Mark Rippetoe)
INSERT INTO program_templates
  (slug, display_name, description, goal, experience_level, duration_weeks, days_per_week, source, source_url, display_order)
VALUES
  ('starting-strength', 'Starting Strength',
   'Mark Rippetoe novice linear progression. 3-day alternating A/B. Squat every session; deadlift A, power clean B. Add weight each session.',
   'strength', 'beginner', 12, 3, 'Rippetoe M. (2011). Starting Strength 3rd ed.', NULL, 20)
ON CONFLICT (slug) DO NOTHING;

-- Push/Pull/Legs 6-day (hypertrophy)
INSERT INTO program_templates
  (slug, display_name, description, goal, experience_level, duration_weeks, days_per_week, source, source_url, display_order)
VALUES
  ('ppl-6-day', 'Push/Pull/Legs (6-day)',
   'Hypertrophy-focused 6-day split. Each muscle trained 2x/week. Push (chest/shoulders/triceps), Pull (back/biceps), Legs (quads/hamstrings/glutes/calves).',
   'hypertrophy', 'intermediate', NULL, 6, 'Common bodybuilding template', NULL, 30)
ON CONFLICT (slug) DO NOTHING;

-- Upper/Lower 4-day (balanced intermediate)
INSERT INTO program_templates
  (slug, display_name, description, goal, experience_level, duration_weeks, days_per_week, source, source_url, display_order)
VALUES
  ('upper-lower-4day', 'Upper/Lower 4-day',
   'Balanced 4-day split: 2 upper + 2 lower per week. Each muscle trained 2x/week with higher frequency than bro split.',
   'general', 'intermediate', NULL, 4, 'Common intermediate template', NULL, 40)
ON CONFLICT (slug) DO NOTHING;

-- 5/3/1 BBB (5/3/1 with Boring But Big accessory, by Jim Wendler)
INSERT INTO program_templates
  (slug, display_name, description, goal, experience_level, duration_weeks, days_per_week, source, source_url, display_order)
VALUES
  ('531-bbb', '5/3/1 Boring But Big',
   'Jim Wendler''s 5/3/1 with BBB accessory work. 4 main lifts (squat/bench/dead/press) rotated across 4 days. 5/3/1 main work + 5x10 same lift at 50% 1RM.',
   'powerlifting', 'intermediate', 12, 4, 'Wendler J. (2012). 5/3/1: The Simplest and Most Effective Training System', NULL, 50)
ON CONFLICT (slug) DO NOTHING;

-- =============================================================================
-- SEED SESSIONS + ITEMS
-- =============================================================================

-- StrongLifts 5x5
DO $$
DECLARE
  v_program_id integer;
  v_workout_a_id uuid;
  v_workout_b_id uuid;
BEGIN
  SELECT id INTO v_program_id FROM program_templates WHERE slug = 'stronglifts-5x5';
  IF v_program_id IS NULL THEN RETURN; END IF;

  INSERT INTO program_template_sessions (program_template_id, day_number, session_name, focus)
  VALUES (v_program_id, 1, 'Workout A', 'Squat + Bench + Row')
  ON CONFLICT (program_template_id, day_number) DO NOTHING RETURNING id INTO v_workout_a_id;

  IF v_workout_a_id IS NULL THEN
    SELECT id INTO v_workout_a_id FROM program_template_sessions
    WHERE program_template_id = v_program_id AND day_number = 1;
  END IF;

  INSERT INTO program_template_sessions (program_template_id, day_number, session_name, focus)
  VALUES (v_program_id, 2, 'Workout B', 'Squat + Overhead Press + Deadlift')
  ON CONFLICT (program_template_id, day_number) DO NOTHING RETURNING id INTO v_workout_b_id;

  IF v_workout_b_id IS NULL THEN
    SELECT id INTO v_workout_b_id FROM program_template_sessions
    WHERE program_template_id = v_program_id AND day_number = 2;
  END IF;

  INSERT INTO program_template_items (session_id, sort_order, exercise_name_hint, target_sets, target_reps, target_rpe, rest_seconds, notes) VALUES
    (v_workout_a_id, 1, 'Barbell Squat', 5, '5', 8, 180, 'Add 2.5kg each session until stall'),
    (v_workout_a_id, 2, 'Bench Press', 5, '5', 8, 180, 'Add 2.5kg each session until stall'),
    (v_workout_a_id, 3, 'Barbell Row', 5, '5', 8, 180, 'Add 2.5kg each session until stall'),
    (v_workout_b_id, 1, 'Barbell Squat', 5, '5', 8, 180, 'Add 2.5kg each session until stall'),
    (v_workout_b_id, 2, 'Overhead Press', 5, '5', 8, 180, 'Add 2.5kg each session until stall'),
    (v_workout_b_id, 3, 'Deadlift', 1, '5', 8, 180, '1x5 only (heavy pull)')
  ON CONFLICT (session_id, sort_order) DO NOTHING;
END $$;

-- Upper/Lower 4-day (simplified seed — 4 sessions)
DO $$
DECLARE
  v_program_id integer;
  v_upper_1 uuid;
  v_lower_1 uuid;
  v_upper_2 uuid;
  v_lower_2 uuid;
BEGIN
  SELECT id INTO v_program_id FROM program_templates WHERE slug = 'upper-lower-4day';
  IF v_program_id IS NULL THEN RETURN; END IF;

  INSERT INTO program_template_sessions (program_template_id, day_number, session_name, focus) VALUES
    (v_program_id, 1, 'Upper 1', 'Bench-focused'),
    (v_program_id, 2, 'Lower 1', 'Squat-focused'),
    (v_program_id, 3, 'Upper 2', 'Overhead press + row'),
    (v_program_id, 4, 'Lower 2', 'Deadlift-focused')
  ON CONFLICT (program_template_id, day_number) DO NOTHING;

  SELECT id INTO v_upper_1 FROM program_template_sessions WHERE program_template_id = v_program_id AND day_number = 1;
  SELECT id INTO v_lower_1 FROM program_template_sessions WHERE program_template_id = v_program_id AND day_number = 2;
  SELECT id INTO v_upper_2 FROM program_template_sessions WHERE program_template_id = v_program_id AND day_number = 3;
  SELECT id INTO v_lower_2 FROM program_template_sessions WHERE program_template_id = v_program_id AND day_number = 4;

  INSERT INTO program_template_items (session_id, sort_order, exercise_name_hint, target_sets, target_reps, target_rpe, rest_seconds) VALUES
    -- Upper 1
    (v_upper_1, 1, 'Bench Press',           4, '6-8',   7.5, 180),
    (v_upper_1, 2, 'Barbell Row',           4, '6-8',   7.5, 180),
    (v_upper_1, 3, 'Incline Dumbbell Press',3, '8-12',  8,   120),
    (v_upper_1, 4, 'Lat Pulldown',          3, '8-12',  8,   120),
    (v_upper_1, 5, 'Lateral Raise',         3, '12-15', 8,   90),
    (v_upper_1, 6, 'Tricep Pushdown',       3, '10-15', 8,   90),
    -- Lower 1
    (v_lower_1, 1, 'Barbell Squat',         4, '6-8',   8,   180),
    (v_lower_1, 2, 'Romanian Deadlift',     3, '8-12',  8,   150),
    (v_lower_1, 3, 'Leg Press',             3, '10-15', 8,   120),
    (v_lower_1, 4, 'Leg Curl',              3, '10-15', 8,   90),
    (v_lower_1, 5, 'Standing Calf Raise',   4, '12-20', 8,   60),
    -- Upper 2
    (v_upper_2, 1, 'Overhead Press',        4, '6-8',   7.5, 180),
    (v_upper_2, 2, 'Pull-Up',               4, '6-10',  8,   180),
    (v_upper_2, 3, 'Dumbbell Bench Press',  3, '8-12',  8,   120),
    (v_upper_2, 4, 'Seated Cable Row',      3, '10-12', 8,   120),
    (v_upper_2, 5, 'Face Pull',             3, '12-20', 8,   60),
    (v_upper_2, 6, 'Barbell Curl',          3, '10-15', 8,   90),
    -- Lower 2
    (v_lower_2, 1, 'Deadlift',              3, '5',     8,   240),
    (v_lower_2, 2, 'Front Squat',           3, '6-8',   8,   180),
    (v_lower_2, 3, 'Hip Thrust',            3, '8-12',  8,   120),
    (v_lower_2, 4, 'Leg Extension',         3, '12-15', 8,   90),
    (v_lower_2, 5, 'Seated Calf Raise',     4, '15-20', 8,   60)
  ON CONFLICT (session_id, sort_order) DO NOTHING;
END $$;

COMMIT;
