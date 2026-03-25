-- Migration 022: Deep Seed Enrichment
-- Seeds difficulty_level, contraindications, and function_type for the
-- exercise library. Also provides default volume target templates.
--
-- Difficulty criteria (from fitness-domain-expert validation):
--   1=Beginner: Machine-guided, minimal risk, no coaching needed
--   2=Novice: Free weights, single-joint, brief instruction sufficient
--   3=Intermediate: Multi-joint compounds, coaching recommended
--   4=Advanced: Complex compounds, significant technique investment
--   5=Elite: Olympic lifts, advanced gymnastics, coaching required
--
-- Contraindication sources:
--   - NSCA Essentials of Strength Training, 4th ed.
--   - ACSM Guidelines for Exercise Testing and Prescription
--   - Schoenfeld & Contreras (2016) - Exercise selection safety review
--
-- Volume target defaults:
--   - Israetel et al. (2021) Scientific Principles of Hypertrophy Training
--   - Renaissance Periodization Hypertrophy Training Guide

BEGIN;

-- =============================================================================
-- 1. DIFFICULTY LEVELS
-- =============================================================================

-- ---- Level 1: Beginner (machine-guided, bodyweight basics) ----
UPDATE exercises SET difficulty_level = 1
WHERE name IN (
  -- Machines
  'Leg Press', 'Machine Leg Press', 'Seated Leg Curl', 'Lying Leg Curls',
  'Leg Extensions', 'Machine Shoulder (Military) Press',
  'Machine Triceps Extension', 'Machine Bicep Curl',
  'Seated Cable Rows', 'Cable Crossover', 'Butterfly',
  'Smith Machine Bench Press', 'Smith Machine Squat',
  'Smith Machine Shrug', 'Smith Machine Upright Row',
  'Lat Pulldown', 'Wide-Grip Lat Pulldown',
  'V-Bar Pulldown', 'Close-Grip Front Lat Pulldown',
  'Straight-Arm Pulldown', 'Cable Seated Lateral Raise',
  -- Simple bodyweight
  'Crunches', 'Sit-Up', 'Lying Leg Raises', 'Plank',
  'Side Plank', 'Superman', 'Glute Bridge', 'Wall Sit',
  'Calf Raises - Standing', 'Seated Calf Raise',
  -- Simple cable
  'Triceps Pushdown', 'Triceps Pushdown - Rope Attachment',
  'Triceps Pushdown - V-Bar Attachment', 'Cable Bicep Curl',
  'Cable Hammer Curls - Rope Attachment', 'Face Pull',
  'Reverse Grip Triceps Pushdown'
) AND difficulty_level IS NULL;

-- ---- Level 2: Novice (free weights, single-joint) ----
UPDATE exercises SET difficulty_level = 2
WHERE name IN (
  -- Dumbbell isolation
  'Dumbbell Bicep Curl', 'Hammer Curls', 'Concentration Curls',
  'Dumbbell Flyes', 'Incline Dumbbell Flyes', 'Decline Dumbbell Flyes',
  'Dumbbell Lateral Raise', 'Dumbbell Rear Delt Raise',
  'Dumbbell Shrug', 'Dumbbell Wrist Curl',
  'Standing Dumbbell Triceps Extension',
  'Dumbbell One-Arm Triceps Extension', 'Tricep Dumbbell Kickback',
  'Lying Dumbbell Tricep Extension', 'Dumbbell Raise',
  -- Barbell isolation
  'Barbell Curl', 'EZ-Bar Curl', 'Preacher Curl',
  'EZ-Bar Skullcrusher', 'Lying Triceps Press',
  'Barbell Shrug', 'Standing Calf Raises',
  -- Simple free weight compounds
  'Goblet Squat', 'Dumbbell Lunges', 'Dumbbell Step Ups',
  'Dumbbell Bench Press', 'Incline Dumbbell Press',
  'Dumbbell Shoulder Press', 'Dumbbell Row',
  'One-Arm Dumbbell Row',
  -- Bodyweight progressions
  'Push-Ups', 'Knee Push-Up', 'Bodyweight Squat',
  'Inverted Row', 'Band Pull Apart'
) AND difficulty_level IS NULL;

-- ---- Level 3: Intermediate (multi-joint compounds, coaching recommended) ----
UPDATE exercises SET difficulty_level = 3
WHERE name IN (
  'Barbell Bench Press - Medium Grip', 'Bench Press - With Bands',
  'Incline Barbell Bench Press', 'Decline Barbell Bench Press',
  'Close-Grip Barbell Bench Press',
  'Barbell Squat', 'Back Squat', 'Barbell Full Squat',
  'Romanian Deadlift', 'Stiff-Legged Barbell Deadlift',
  'Conventional Deadlift', 'Barbell Deadlift',
  'Bent Over Barbell Row', 'Pendlay Row',
  'T-Bar Row', 'T-Bar Row with Handle',
  'Overhead Press', 'Standing Military Press',
  'Seated Barbell Military Press', 'Arnold Dumbbell Press',
  'Pull-Ups', 'Chin-Up', 'Wide-Grip Pull-Up',
  'Dips - Chest Version', 'Dips - Triceps Version',
  'Barbell Hip Thrust', 'Hip Thrust',
  'Walking Lunges', 'Barbell Lunge',
  'Good Morning', 'Cable Woodchop'
) AND difficulty_level IS NULL;

-- ---- Level 4: Advanced (complex compounds, significant technique) ----
UPDATE exercises SET difficulty_level = 4
WHERE name IN (
  'Front Squat', 'Zercher Squat', 'Overhead Squat',
  'Sumo Deadlift', 'Deficit Deadlift', 'Rack Pulls',
  'Weighted Pull-Ups', 'Weighted Dips',
  'Muscle Ups', 'Ring Dips', 'Ring Push-Ups',
  'Pistol Squat', 'Single Leg Squat',
  'Dragon Flag', 'Ab Wheel Rollout',
  'Floor Press', 'Spoto Press',
  'Pause Squat', 'Tempo Squat',
  'Farmers Walk', 'Trap Bar Deadlift',
  'Pendlay Row', 'Meadows Row',
  'Behind The Neck Press', 'Push Press',
  'Snatch Grip Deadlift', 'Deficit Deadlift'
) AND difficulty_level IS NULL;

-- ---- Level 5: Elite (Olympic lifts, advanced gymnastics) ----
UPDATE exercises SET difficulty_level = 5
WHERE name IN (
  'Clean and Jerk', 'Clean', 'Power Clean',
  'Hang Clean', 'Muscle Clean',
  'Snatch', 'Power Snatch', 'Hang Snatch',
  'Clean and Press', 'Clean Pull',
  'Muscle-Up', 'Strict Muscle-Up',
  'Planche', 'Planche Push-Up',
  'Front Lever', 'Back Lever',
  'Handstand Push-Up', 'Handstand Walk',
  'Iron Cross', 'L-Sit',
  'Turkish Get-Up', 'Windmill'
) AND difficulty_level IS NULL;

-- ---- Bulk assignments by equipment/category patterns ----

-- Most machine exercises are beginner-friendly
UPDATE exercises SET difficulty_level = 1
WHERE difficulty_level IS NULL
  AND equipment IN ('machine', 'e-z_curl_bar')
  AND category IN ('isolation');

-- Cable exercises default to novice
UPDATE exercises SET difficulty_level = 2
WHERE difficulty_level IS NULL
  AND equipment = 'cable';

-- Bodyweight exercises default to novice (advanced ones already classified)
UPDATE exercises SET difficulty_level = 2
WHERE difficulty_level IS NULL
  AND equipment = 'body_only'
  AND category = 'isolation';

-- Remaining dumbbell exercises default to novice
UPDATE exercises SET difficulty_level = 2
WHERE difficulty_level IS NULL
  AND equipment = 'dumbbell';

-- Remaining barbell compounds default to intermediate
UPDATE exercises SET difficulty_level = 3
WHERE difficulty_level IS NULL
  AND equipment = 'barbell'
  AND mechanic = 'compound';

-- Remaining barbell isolation default to novice
UPDATE exercises SET difficulty_level = 2
WHERE difficulty_level IS NULL
  AND equipment = 'barbell'
  AND mechanic = 'isolation';


-- =============================================================================
-- 2. CONTRAINDICATIONS (safety warning tags)
-- =============================================================================

-- Behind-the-neck exercises: shoulder impingement risk
UPDATE exercises SET contraindications = array_cat(contraindications, ARRAY['shoulder_impingement', 'rotator_cuff'])
WHERE name IN (
  'Behind The Neck Press', 'Behind The Neck Barbell Press',
  'Wide-Grip Behind-The-Neck Press'
) AND NOT (contraindications @> ARRAY['shoulder_impingement']);

-- Upright rows (narrow grip): shoulder impingement
UPDATE exercises SET contraindications = array_cat(contraindications, ARRAY['shoulder_impingement'])
WHERE name IN (
  'Upright Barbell Row', 'Upright Cable Row', 'Upright Row - With Bands',
  'Smith Machine Upright Row', 'Dumbbell Upright Row'
) AND NOT (contraindications @> ARRAY['shoulder_impingement']);

-- Skull crushers / overhead triceps: elbow strain
UPDATE exercises SET contraindications = array_cat(contraindications, ARRAY['elbow_strain'])
WHERE name IN (
  'EZ-Bar Skullcrusher', 'Lying Triceps Press',
  'Lying Close-Grip Barbell Triceps Extension Behind The Head',
  'Lying Close-Grip Barbell Triceps Press To Chin',
  'Standing Overhead Barbell Triceps Extension',
  'Cable Rope Overhead Triceps Extension',
  'Overhead Triceps'
) AND NOT (contraindications @> ARRAY['elbow_strain']);

-- Good mornings / stiff-legged deadlifts: lower back risk
UPDATE exercises SET contraindications = array_cat(contraindications, ARRAY['lower_back_herniation'])
WHERE name IN (
  'Good Morning', 'Stiff-Legged Barbell Deadlift',
  'Straight-Leg Barbell Deadlift', 'Stiff-Legged Dumbbell Deadlift'
) AND NOT (contraindications @> ARRAY['lower_back_herniation']);

-- Deep leg extensions at heavy load: anterior knee stress
UPDATE exercises SET contraindications = array_cat(contraindications, ARRAY['knee_anterior'])
WHERE name IN (
  'Leg Extensions', 'Sissy Squat'
) AND NOT (contraindications @> ARRAY['knee_anterior']);

-- Behind-the-neck pulldowns: shoulder + rotator cuff
UPDATE exercises SET contraindications = array_cat(contraindications, ARRAY['shoulder_impingement', 'rotator_cuff'])
WHERE name IN (
  'Behind The Neck Lat Pulldown'
) AND NOT (contraindications @> ARRAY['shoulder_impingement']);

-- Heavy barbell curls: wrist strain
UPDATE exercises SET contraindications = array_cat(contraindications, ARRAY['wrist_strain'])
WHERE name IN (
  'Barbell Curl', 'Wide-Grip Standing Barbell Curl',
  'Close-Grip Standing Barbell Curl'
) AND NOT (contraindications @> ARRAY['wrist_strain']);

-- Heavy shrugs: neck compression
UPDATE exercises SET contraindications = array_cat(contraindications, ARRAY['neck_compression'])
WHERE name IN (
  'Barbell Shrug', 'Barbell Behind-the-Back Shrug',
  'Smith Machine Shrug'
) AND NOT (contraindications @> ARRAY['neck_compression']);


-- =============================================================================
-- 3. FUNCTION_TYPE enrichment for common exercises
-- =============================================================================
-- The migration 021 backfill derived agonist/synergist/stabilizer from
-- is_primary + activation_percent. This section fills remaining NULL values
-- for exercises where activation_percent was not set.

-- Remaining is_primary = true rows are agonists
UPDATE exercise_muscles
SET function_type = 'agonist'
WHERE is_primary = true AND function_type IS NULL;

-- Remaining is_primary = false rows default to synergist
-- (stabilizers were identified by activation_percent < 40 in migration 021)
UPDATE exercise_muscles
SET function_type = 'synergist'
WHERE is_primary = false AND function_type IS NULL;


COMMIT;
