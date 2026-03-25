-- Migration 024: Training Intelligence Seed Data
-- Seeds muscle antagonist pairs and exercise progression metadata.
--
-- Antagonist pairs from standard kinesiology (Lippert, Floyd).
-- Progression metadata extends exercise_substitutions (migration 019).
--
-- Validated by: fitness-domain-expert agent

BEGIN;

-- =============================================================================
-- 1. MUSCLE ANTAGONIST PAIRS
-- =============================================================================
-- Canonical ordering: muscle_a_id < muscle_b_id (symmetric relationship).
-- Muscle group IDs from wger:
--   1=biceps, 2=shoulders, 3=triceps, 4=chest, 5=forearms,
--   7=calves, 8=glutes, 9=traps, 10=abs, 11=hamstrings,
--   12=lats, 13=lower_back, 14=neck, 15=quadriceps, 16=adductors

INSERT INTO muscle_antagonist_pairs (muscle_a_id, muscle_b_id, pair_name, pair_strength)
VALUES
  -- Elbow flexors vs extensors. Classic superset pairing.
  -- Robbins et al. (2010): antagonist supersets maintain force output.
  (1, 3, 'biceps-triceps', 'strong'),

  -- Horizontal push vs horizontal pull. Primary upper body balance pair.
  -- Kolber et al. (2009): push:pull ratio >1.5:1 → shoulder impingement risk.
  (4, 12, 'chest-lats', 'strong'),

  -- Trunk flexors vs trunk extensors. Core stability balance.
  (10, 13, 'abs-lower_back', 'strong'),

  -- Knee extensors vs knee flexors. Lower body balance pair.
  -- Hamstring:quad ratio <0.6 associated with ACL injury risk (Hewett et al., 2005).
  (11, 15, 'hamstrings-quadriceps', 'strong'),

  -- Shoulder anterior vs posterior deltoid (both within shoulders group ID 2).
  -- Modeled as shoulders-traps for superset purposes (shrug + lateral raise).
  (2, 9, 'shoulders-traps', 'moderate'),

  -- Hip extensors vs knee extensors in squat patterns.
  -- Not a strict anatomical pair but commonly paired in programming.
  (8, 15, 'glutes-quadriceps', 'moderate')

ON CONFLICT (muscle_a_id, muscle_b_id) DO NOTHING;


-- =============================================================================
-- 2. EXERCISE PROGRESSION METADATA
-- =============================================================================
-- Adds progression_order and prerequisite_1rm_ratio to existing
-- exercise_substitutions where substitution_type is 'progression' or 'regression'.
-- This enriches the existing data rather than duplicating it.

-- Push-up progression chain: knee push-up → push-up → diamond push-up
UPDATE exercise_substitutions
SET progression_order = 1
WHERE substitution_type = 'progression'
  AND progression_order IS NULL
  AND source_exercise_id IN (SELECT id FROM exercises WHERE name = 'Knee Push-Up')
  AND target_exercise_id IN (SELECT id FROM exercises WHERE name = 'Push-Ups');

UPDATE exercise_substitutions
SET progression_order = 2
WHERE substitution_type = 'progression'
  AND progression_order IS NULL
  AND source_exercise_id IN (SELECT id FROM exercises WHERE name = 'Push-Ups')
  AND target_exercise_id IN (SELECT id FROM exercises WHERE name = 'Diamond Push-Up');

-- Squat progression: Bodyweight Squat → Goblet Squat → Back Squat → Front Squat
UPDATE exercise_substitutions
SET progression_order = 1
WHERE substitution_type = 'progression'
  AND progression_order IS NULL
  AND source_exercise_id IN (SELECT id FROM exercises WHERE name = 'Bodyweight Squat')
  AND target_exercise_id IN (SELECT id FROM exercises WHERE name = 'Goblet Squat');

UPDATE exercise_substitutions
SET progression_order = 2, prerequisite_1rm_ratio = 0.5
WHERE substitution_type = 'progression'
  AND progression_order IS NULL
  AND source_exercise_id IN (SELECT id FROM exercises WHERE name = 'Goblet Squat')
  AND target_exercise_id IN (SELECT id FROM exercises WHERE name IN ('Barbell Squat', 'Back Squat', 'Barbell Full Squat'));

UPDATE exercise_substitutions
SET progression_order = 3, prerequisite_1rm_ratio = 1.0
WHERE substitution_type = 'progression'
  AND progression_order IS NULL
  AND source_exercise_id IN (SELECT id FROM exercises WHERE name IN ('Barbell Squat', 'Back Squat', 'Barbell Full Squat'))
  AND target_exercise_id IN (SELECT id FROM exercises WHERE name = 'Front Squat');

-- Pull-up progression: Inverted Row → Chin-Up → Pull-Up → Weighted Pull-Up
UPDATE exercise_substitutions
SET progression_order = 1
WHERE substitution_type = 'progression'
  AND progression_order IS NULL
  AND source_exercise_id IN (SELECT id FROM exercises WHERE name = 'Inverted Row')
  AND target_exercise_id IN (SELECT id FROM exercises WHERE name = 'Chin-Up');

UPDATE exercise_substitutions
SET progression_order = 2, prerequisite_1rm_ratio = 1.0
WHERE substitution_type = 'progression'
  AND progression_order IS NULL
  AND source_exercise_id IN (SELECT id FROM exercises WHERE name = 'Chin-Up')
  AND target_exercise_id IN (SELECT id FROM exercises WHERE name IN ('Pull-Ups', 'Wide-Grip Pull-Up'));

UPDATE exercise_substitutions
SET progression_order = 3, prerequisite_1rm_ratio = 1.2
WHERE substitution_type = 'progression'
  AND progression_order IS NULL
  AND source_exercise_id IN (SELECT id FROM exercises WHERE name IN ('Pull-Ups', 'Wide-Grip Pull-Up'))
  AND target_exercise_id IN (SELECT id FROM exercises WHERE name = 'Weighted Pull-Ups');

-- Deadlift progression: Romanian Deadlift → Conventional Deadlift → Sumo Deadlift
UPDATE exercise_substitutions
SET progression_order = 1, prerequisite_1rm_ratio = 0.75
WHERE substitution_type = 'progression'
  AND progression_order IS NULL
  AND source_exercise_id IN (SELECT id FROM exercises WHERE name = 'Romanian Deadlift')
  AND target_exercise_id IN (SELECT id FROM exercises WHERE name IN ('Conventional Deadlift', 'Barbell Deadlift'));

-- Bench progression: DB Bench → Barbell Bench → Close-Grip Bench
UPDATE exercise_substitutions
SET progression_order = 1, prerequisite_1rm_ratio = 0.6
WHERE substitution_type = 'progression'
  AND progression_order IS NULL
  AND source_exercise_id IN (SELECT id FROM exercises WHERE name IN ('Dumbbell Bench Press', 'Incline Dumbbell Press'))
  AND target_exercise_id IN (SELECT id FROM exercises WHERE name = 'Barbell Bench Press - Medium Grip');

-- Dip progression: Bench Dips → Dips → Weighted Dips
UPDATE exercise_substitutions
SET progression_order = 1
WHERE substitution_type = 'progression'
  AND progression_order IS NULL
  AND source_exercise_id IN (SELECT id FROM exercises WHERE name = 'Bench Dips')
  AND target_exercise_id IN (SELECT id FROM exercises WHERE name IN ('Dips - Chest Version', 'Dips - Triceps Version'));

UPDATE exercise_substitutions
SET progression_order = 2, prerequisite_1rm_ratio = 1.1
WHERE substitution_type = 'progression'
  AND progression_order IS NULL
  AND source_exercise_id IN (SELECT id FROM exercises WHERE name IN ('Dips - Chest Version', 'Dips - Triceps Version'))
  AND target_exercise_id IN (SELECT id FROM exercises WHERE name = 'Weighted Dips');


COMMIT;
