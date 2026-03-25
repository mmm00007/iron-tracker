-- Migration 028: Training Context Seed Data
-- Seeds muscle group categories and population-default progression rules.
--
-- Muscle group IDs from wger (migration 001):
--   1=biceps, 2=shoulders, 3=triceps, 4=chest, 5=forearms,
--   7=calves, 8=glutes, 9=traps, 10=abs, 11=hamstrings,
--   12=lats, 13=lower_back, 14=neck, 15=quadriceps, 16=adductors
--
-- Validated by: fitness-domain-expert agent
--
-- Key decisions:
--   - Shoulders in upper_push (anterior delt dominates bench/OHP)
--   - Adductors in lower_pull (functionally closer to glutes/hamstrings)
--   - Calves and neck standalone (unique training characteristics)
--   - Progression defaults per NSCA/RP/Starting Strength guidelines

BEGIN;

-- =============================================================================
-- 1. MUSCLE GROUP CATEGORIES
-- =============================================================================

INSERT INTO muscle_group_categories (category_name, display_name, display_order)
VALUES
  ('upper_push', 'Upper Push',  1),
  ('upper_pull', 'Upper Pull',  2),
  ('lower_push', 'Lower Push',  3),
  ('lower_pull', 'Lower Pull',  4),
  ('core',       'Core',        5),
  ('calves',     'Calves',      6),
  ('neck',       'Neck',        7)
ON CONFLICT (category_name) DO NOTHING;

-- Map muscles to categories
-- upper_push: chest(4), shoulders(2), triceps(3)
INSERT INTO muscle_group_category_members (muscle_group_id, category_id)
SELECT mg.id, cat.id
FROM muscle_groups mg
CROSS JOIN muscle_group_categories cat
WHERE
  (cat.category_name = 'upper_push' AND mg.id IN (4, 2, 3))
  OR (cat.category_name = 'upper_pull' AND mg.id IN (12, 1, 5, 9))
  OR (cat.category_name = 'lower_push' AND mg.id IN (15))
  OR (cat.category_name = 'lower_pull' AND mg.id IN (8, 11, 16))
  OR (cat.category_name = 'core' AND mg.id IN (10, 13))
  OR (cat.category_name = 'calves' AND mg.id IN (7))
  OR (cat.category_name = 'neck' AND mg.id IN (14))
ON CONFLICT (muscle_group_id, category_id) DO NOTHING;


-- =============================================================================
-- 2. PROGRESSION RULES: Population defaults (user_id = NULL)
-- =============================================================================

-- These are goal-level defaults (exercise_id = NULL).
-- Users can override per exercise.
--
-- Sources:
--   Strength: Rippetoe, Starting Strength (3rd ed.) — linear progression
--   Hypertrophy: Helms, Muscle & Strength Pyramids — double progression
--   Endurance: ACSM Guidelines, 11th ed. — high rep, low increment
--   Power: NSCA Essentials, 4th ed. — wave loading
--   General/body_recomposition: moderate defaults

-- Strength: heavy, low rep, linear progression
INSERT INTO progression_rules (
  user_id, exercise_id, goal,
  target_rep_range_min, target_rep_range_max,
  load_increment_kg, progression_model,
  min_reps_to_progress, min_sets_at_target,
  max_progression_weeks, stall_strategy
) VALUES (
  NULL, NULL, 'strength',
  1, 5,
  2.5, 'linear',
  5, 2,
  4, 'deload_and_retry'
) ON CONFLICT DO NOTHING;

-- Hypertrophy: moderate weight, 6-12 reps, double progression
INSERT INTO progression_rules (
  user_id, exercise_id, goal,
  target_rep_range_min, target_rep_range_max,
  load_increment_kg, progression_model,
  min_reps_to_progress, min_sets_at_target,
  max_progression_weeks, stall_strategy
) VALUES (
  NULL, NULL, 'hypertrophy',
  6, 12,
  2.5, 'double_progression',
  12, 2,
  5, 'increase_reps'
) ON CONFLICT DO NOTHING;

-- Endurance: light weight, high reps
INSERT INTO progression_rules (
  user_id, exercise_id, goal,
  target_rep_range_min, target_rep_range_max,
  load_increment_kg, progression_model,
  min_reps_to_progress, min_sets_at_target,
  max_progression_weeks, stall_strategy
) VALUES (
  NULL, NULL, 'endurance',
  12, 20,
  1.25, 'double_progression',
  20, 1,
  6, 'increase_reps'
) ON CONFLICT DO NOTHING;

-- Power: explosive, wave loading
INSERT INTO progression_rules (
  user_id, exercise_id, goal,
  target_rep_range_min, target_rep_range_max,
  load_increment_kg, progression_model,
  min_reps_to_progress, min_sets_at_target,
  max_progression_weeks, stall_strategy
) VALUES (
  NULL, NULL, 'power',
  1, 5,
  2.5, 'wave',
  5, 2,
  4, 'deload_and_retry'
) ON CONFLICT DO NOTHING;

-- General fitness: moderate everything
INSERT INTO progression_rules (
  user_id, exercise_id, goal,
  target_rep_range_min, target_rep_range_max,
  load_increment_kg, progression_model,
  min_reps_to_progress, min_sets_at_target,
  max_progression_weeks, stall_strategy
) VALUES (
  NULL, NULL, 'general',
  8, 15,
  2.5, 'double_progression',
  15, 2,
  5, 'increase_reps'
) ON CONFLICT DO NOTHING;

-- Body recomposition: hypertrophy-biased (simultaneous fat loss + muscle gain)
INSERT INTO progression_rules (
  user_id, exercise_id, goal,
  target_rep_range_min, target_rep_range_max,
  load_increment_kg, progression_model,
  min_reps_to_progress, min_sets_at_target,
  max_progression_weeks, stall_strategy
) VALUES (
  NULL, NULL, 'body_recomposition',
  8, 12,
  2.5, 'double_progression',
  12, 2,
  5, 'reduce_weight'
) ON CONFLICT DO NOTHING;


-- =============================================================================
-- 3. PROGRESSION RULES: Exercise-specific overrides (population defaults)
-- =============================================================================

-- OHP progresses slower than other compounds (Rippetoe, Starting Strength)
-- Use 1.25kg increments instead of 2.5kg for strength goal
INSERT INTO progression_rules (
  user_id, exercise_id, goal,
  target_rep_range_min, target_rep_range_max,
  load_increment_kg, progression_model,
  min_reps_to_progress, min_sets_at_target,
  max_progression_weeks, stall_strategy
)
SELECT
  NULL, e.id, 'strength',
  1, 5,
  1.25, 'linear',
  5, 2,
  3, 'deload_and_retry'
FROM exercises e
WHERE e.name IN ('Barbell Shoulder Press', 'Seated Barbell Military Press',
                  'Standing Military Press', 'Push Press')
  AND NOT e.is_custom
ON CONFLICT DO NOTHING;

-- Isolation exercises: smaller increments for all goals
INSERT INTO progression_rules (
  user_id, exercise_id, goal,
  target_rep_range_min, target_rep_range_max,
  load_increment_kg, progression_model,
  min_reps_to_progress, min_sets_at_target,
  max_progression_weeks, stall_strategy
)
SELECT
  NULL, e.id, 'hypertrophy',
  8, 15,
  1.25, 'double_progression',
  15, 2,
  6, 'increase_reps'
FROM exercises e
WHERE e.mechanic = 'isolation'
  AND NOT e.is_custom
  AND e.name IN (
    'Barbell Curl', 'Dumbbell Bicep Curl', 'Hammer Curls',
    'Triceps Pushdown', 'Overhead Triceps Extension',
    'Lateral Raise', 'Front Raise',
    'Calf Raise', 'Seated Calf Raise',
    'Leg Extension', 'Leg Curl',
    'Face Pull', 'Reverse Fly'
  )
ON CONFLICT DO NOTHING;


COMMIT;
