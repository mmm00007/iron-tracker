-- Migration 026: Exercise Insights Seed Data
-- Seeds default_rest_seconds for exercises and strength_standards reference data.
--
-- Sources:
--   - NSCA Essentials of Strength Training, 4th ed. (rest periods)
--   - Ratamess et al. (2009): rest period recommendations
--   - ExRx.net, Rippetoe & Kilgore (2006), Hoffman (2006): strength standards
--
-- Validated by: fitness-domain-expert agent

BEGIN;

-- =============================================================================
-- 1. EXERCISES: Backfill default_rest_seconds
-- =============================================================================

-- Pattern-based rest defaults per NSCA guidelines:
--   Olympic lifts: 180s (high CNS demand, technique-dependent)
--   Heavy compounds: 120s (adequate for strength/hypertrophy balance)
--   Isolation: 60s (lower systemic fatigue)
--   Bodyweight compounds: 90s (moderate demand)

-- Olympic lifts and heavy barbell compounds: 180s
UPDATE exercises SET default_rest_seconds = 180
WHERE default_rest_seconds IS NULL
  AND (
    -- Olympic lifts
    name ~* '(clean|snatch|jerk|clean and press)'
    -- Heavy posterior chain
    OR name ~* '(deadlift|good morning)'
  )
  AND mechanic = 'compound';

-- Squat and press compounds: 120s
UPDATE exercises SET default_rest_seconds = 120
WHERE default_rest_seconds IS NULL
  AND mechanic = 'compound'
  AND name ~* '(squat|bench press|overhead press|military press|barbell row|pull.?up|chin.?up|dip|lunge|leg press|hack squat|t-bar row)';

-- Remaining compounds not yet tagged: 90s (moderate default)
UPDATE exercises SET default_rest_seconds = 90
WHERE default_rest_seconds IS NULL
  AND mechanic = 'compound';

-- Bodyweight exercises (isolation or unclassified): 60s
UPDATE exercises SET default_rest_seconds = 60
WHERE default_rest_seconds IS NULL
  AND equipment = 'body only';

-- All remaining isolation exercises: 60s
UPDATE exercises SET default_rest_seconds = 60
WHERE default_rest_seconds IS NULL
  AND mechanic = 'isolation';

-- Catch-all for anything still NULL: 90s
UPDATE exercises SET default_rest_seconds = 90
WHERE default_rest_seconds IS NULL;


-- =============================================================================
-- 2. STRENGTH STANDARDS: Male (reference BW = 80kg)
-- =============================================================================

-- Canonical exercise names only (no aliases — app layer handles name matching).
-- Values: [beginner, novice, intermediate, advanced, elite] in kg for 1RM.
-- BW ratios used when user bodyweight is known (more accurate across weight classes).

INSERT INTO strength_standards
  (exercise_name, sex, reference_bw_kg,
   beginner_1rm, novice_1rm, intermediate_1rm, advanced_1rm, elite_1rm,
   beginner_bw_ratio, novice_bw_ratio, intermediate_bw_ratio, advanced_bw_ratio, elite_bw_ratio,
   source)
VALUES
  -- Upper body horizontal push
  ('Barbell Bench Press', 'male', 80,
   40, 60, 85, 110, 140,
   0.50, 0.75, 1.0, 1.35, 1.75,
   'nsca_exrx'),

  ('Dumbbell Bench Press', 'male', 80,
   15, 25, 35, 45, 55,
   NULL, NULL, NULL, NULL, NULL,
   'exrx'),

  -- Upper body vertical push
  ('Overhead Press', 'male', 80,
   25, 40, 55, 75, 95,
   0.30, 0.50, 0.70, 0.95, 1.20,
   'nsca_exrx'),

  ('Dumbbell Shoulder Press', 'male', 80,
   12, 20, 30, 40, 50,
   NULL, NULL, NULL, NULL, NULL,
   'exrx'),

  -- Upper body horizontal pull
  ('Barbell Row', 'male', 80,
   30, 50, 75, 100, 130,
   0.40, 0.65, 0.95, 1.25, 1.60,
   'nsca_exrx'),

  ('Lat Pulldown', 'male', 80,
   30, 50, 70, 90, 110,
   NULL, NULL, NULL, NULL, NULL,
   'exrx'),

  ('Cable Row', 'male', 80,
   25, 40, 60, 80, 100,
   NULL, NULL, NULL, NULL, NULL,
   'exrx'),

  -- Upper body vertical pull (bodyweight exercises: added weight in kg)
  ('Pull-Up', 'male', 80,
   0, 5, 15, 30, 50,
   NULL, NULL, NULL, NULL, NULL,
   'nsca_exrx'),

  ('Chin-Up', 'male', 80,
   0, 5, 15, 30, 50,
   NULL, NULL, NULL, NULL, NULL,
   'nsca_exrx'),

  ('Dip', 'male', 80,
   0, 10, 25, 45, 65,
   NULL, NULL, NULL, NULL, NULL,
   'nsca_exrx'),

  -- Lower body knee-dominant
  ('Barbell Squat', 'male', 80,
   50, 80, 115, 150, 190,
   0.65, 1.0, 1.45, 1.85, 2.35,
   'nsca_exrx'),

  ('Front Squat', 'male', 80,
   35, 60, 90, 120, 150,
   NULL, NULL, NULL, NULL, NULL,
   'nsca_exrx'),

  ('Leg Press', 'male', 80,
   80, 140, 220, 320, 420,
   NULL, NULL, NULL, NULL, NULL,
   'exrx'),

  -- Lower body hip-dominant
  ('Deadlift', 'male', 80,
   60, 95, 135, 175, 220,
   0.75, 1.2, 1.7, 2.2, 2.75,
   'nsca_exrx'),

  ('Romanian Deadlift', 'male', 80,
   40, 65, 95, 125, 160,
   NULL, NULL, NULL, NULL, NULL,
   'nsca_exrx'),

  -- Arms
  ('Barbell Curl', 'male', 80,
   15, 25, 40, 55, 70,
   NULL, NULL, NULL, NULL, NULL,
   'exrx')

ON CONFLICT (exercise_name, sex) DO NOTHING;


-- =============================================================================
-- 3. STRENGTH STANDARDS: Female (reference BW = 60kg)
-- =============================================================================

-- Female standards are NOT a blanket 60% of male.
-- Ratios vary by lift (NSCA Table 18.7, Hoffman 2006):
--   Upper body: ~55-60% of male absolute values
--   Lower body: ~65-75% of male absolute values

INSERT INTO strength_standards
  (exercise_name, sex, reference_bw_kg,
   beginner_1rm, novice_1rm, intermediate_1rm, advanced_1rm, elite_1rm,
   beginner_bw_ratio, novice_bw_ratio, intermediate_bw_ratio, advanced_bw_ratio, elite_bw_ratio,
   source)
VALUES
  ('Barbell Bench Press', 'female', 60,
   20, 30, 45, 60, 80,
   0.30, 0.45, 0.65, 0.90, 1.20,
   'nsca_hoffman'),

  ('Dumbbell Bench Press', 'female', 60,
   8, 14, 20, 28, 36,
   NULL, NULL, NULL, NULL, NULL,
   'exrx'),

  ('Overhead Press', 'female', 60,
   12, 20, 30, 42, 55,
   0.20, 0.35, 0.50, 0.70, 0.90,
   'nsca_hoffman'),

  ('Dumbbell Shoulder Press', 'female', 60,
   6, 10, 16, 24, 32,
   NULL, NULL, NULL, NULL, NULL,
   'exrx'),

  ('Barbell Row', 'female', 60,
   18, 30, 45, 65, 85,
   0.30, 0.45, 0.65, 0.90, 1.20,
   'nsca_hoffman'),

  ('Lat Pulldown', 'female', 60,
   18, 30, 45, 62, 78,
   NULL, NULL, NULL, NULL, NULL,
   'exrx'),

  ('Cable Row', 'female', 60,
   15, 25, 38, 52, 68,
   NULL, NULL, NULL, NULL, NULL,
   'exrx'),

  ('Pull-Up', 'female', 60,
   0, 0, 5, 15, 30,
   NULL, NULL, NULL, NULL, NULL,
   'nsca_hoffman'),

  ('Chin-Up', 'female', 60,
   0, 0, 5, 15, 30,
   NULL, NULL, NULL, NULL, NULL,
   'nsca_hoffman'),

  ('Dip', 'female', 60,
   0, 0, 10, 25, 40,
   NULL, NULL, NULL, NULL, NULL,
   'nsca_hoffman'),

  ('Barbell Squat', 'female', 60,
   30, 50, 75, 100, 130,
   0.50, 0.80, 1.20, 1.55, 2.00,
   'nsca_hoffman'),

  ('Front Squat', 'female', 60,
   22, 38, 60, 82, 105,
   NULL, NULL, NULL, NULL, NULL,
   'exrx'),

  ('Leg Press', 'female', 60,
   55, 100, 160, 230, 310,
   NULL, NULL, NULL, NULL, NULL,
   'exrx'),

  ('Deadlift', 'female', 60,
   40, 65, 95, 125, 160,
   0.60, 1.0, 1.45, 1.90, 2.40,
   'nsca_hoffman'),

  ('Romanian Deadlift', 'female', 60,
   25, 42, 65, 90, 115,
   NULL, NULL, NULL, NULL, NULL,
   'nsca_hoffman'),

  ('Barbell Curl', 'female', 60,
   8, 14, 22, 32, 42,
   NULL, NULL, NULL, NULL, NULL,
   'exrx')

ON CONFLICT (exercise_name, sex) DO NOTHING;


COMMIT;
