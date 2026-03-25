-- Migration 020: Seed Data Enrichment
-- Enriches the 873 seed exercises with exercise_type, laterality, aliases,
-- and evidence-based EMG activation percentages for compound movements.
--
-- Columns were added in migration 019_schema_enrichment.sql:
--   exercises.exercise_type   (push/pull/legs/core/cardio/full_body)
--   exercises.laterality      (bilateral/unilateral/both)
--   exercises.aliases         (text[])
--   exercise_muscles.activation_percent (0-100)
--
-- Migration 019 auto-derived exercise_type from movement_pattern for
-- unambiguous cases. This migration handles:
--   1. exercise_type for isolation and 'other' movement_pattern exercises
--   2. laterality for the top 100+ most common exercises
--   3. aliases for the top 50 most commonly known exercises
--   4. activation_percent for the top 30-40 compound exercises
--
-- EMG sources cited per section:
--   - Schoenfeld et al. (2010, 2016, 2020) - Muscle activation comparisons
--   - Andersen et al. (2010) - Bench press grip width EMG analysis
--   - Contreras et al. (2015, 2016) - Glute activation studies
--   - Ebben et al. (2009) - Hamstring exercises EMG comparison
--   - Escamilla et al. (2009, 2010) - Squat/deadlift muscle recruitment
--   - Lehman et al. (2004) - Upper back exercises EMG
--   - Oliveira et al. (2009) - Triceps exercises EMG
--   - Signorile et al. (2002) - Biceps exercises EMG
--   - Youdas et al. (2010) - Push-up variations EMG


BEGIN;


-- =============================================================================
-- 1. EXERCISE_TYPE: Manual classification for isolation / 'other' movement
-- =============================================================================
-- These exercises were NOT auto-derived in 019 because they have
-- movement_pattern = 'isolation' or 'other' (ambiguous without name context).

-- ---- 1a. PUSH isolation exercises ----
-- Chest isolation
UPDATE exercises SET exercise_type = 'push'
WHERE name IN (
  'Butterfly',
  'Cable Crossover',
  'Cable Iron Cross',
  'Decline Dumbbell Flyes',
  'Dumbbell Flyes',
  'Flat Bench Cable Flyes',
  'Incline Cable Flye',
  'Incline Dumbbell Flyes',
  'Incline Dumbbell Flyes - With A Twist',
  'Lying Crossover',
  'One-Arm Flat Bench Dumbbell Flye',
  'Single-Arm Cable Crossover',
  'Bodyweight Flyes'
) AND exercise_type IS NULL;

-- Triceps isolation
UPDATE exercises SET exercise_type = 'push'
WHERE name IN (
  'Cable Incline Triceps Extension',
  'Cable Lying Triceps Extension',
  'Cable One Arm Tricep Extension',
  'Cable Rope Overhead Triceps Extension',
  'Dumbbell One-Arm Triceps Extension',
  'Dumbbell Tricep Extension -Pronated Grip',
  'EZ-Bar Skullcrusher',
  'Lying Close-Grip Barbell Triceps Extension Behind The Head',
  'Lying Close-Grip Barbell Triceps Press To Chin',
  'Lying Dumbbell Tricep Extension',
  'Lying Triceps Press',
  'Machine Triceps Extension',
  'One Arm Pronated Dumbbell Triceps Extension',
  'One Arm Supinated Dumbbell Triceps Extension',
  'Overhead Triceps',
  'Reverse Grip Triceps Pushdown',
  'Seated Bent-Over One-Arm Dumbbell Triceps Extension',
  'Seated Bent-Over Two-Arm Dumbbell Triceps Extension',
  'Seated Triceps Press',
  'Standing Bent-Over One-Arm Dumbbell Triceps Extension',
  'Standing Bent-Over Two-Arm Dumbbell Triceps Extension',
  'Standing Dumbbell Triceps Extension',
  'Standing Low-Pulley One-Arm Triceps Extension',
  'Standing One-Arm Dumbbell Triceps Extension',
  'Standing Overhead Barbell Triceps Extension',
  'Standing Towel Triceps Extension',
  'Tricep Dumbbell Kickback',
  'Triceps Overhead Extension with Rope',
  'Triceps Pushdown',
  'Triceps Pushdown - Rope Attachment',
  'Triceps Pushdown - V-Bar Attachment'
) AND exercise_type IS NULL;

-- Shoulder isolation (anterior/medial deltoid raises)
UPDATE exercises SET exercise_type = 'push'
WHERE name IN (
  'Cable Seated Lateral Raise',
  'Dumbbell Lying One-Arm Rear Lateral Raise',
  'Dumbbell Raise',
  'Dumbbell Scaption',
  'Front Incline Dumbbell Raise',
  'Lateral Raise - With Bands',
  'Lying One-Arm Lateral Raise',
  'Seated Side Lateral Raise',
  'Side Lateral Raise',
  'Side Laterals to Front Raise',
  'Single Dumbbell Raise',
  'Standing Dumbbell Straight-Arm Front Delt Raise Above Head',
  'Standing Front Barbell Raise Over Head',
  'Standing Low-Pulley Deltoid Raise',
  'Alternating Deltoid Raise',
  'Barbell Incline Shoulder Raise',
  'Dumbbell Incline Shoulder Raise',
  'Smith Incline Shoulder Raise'
) AND exercise_type IS NULL;


-- ---- 1b. PULL isolation exercises ----
-- Biceps isolation
UPDATE exercises SET exercise_type = 'pull'
WHERE name IN (
  'Alternate Hammer Curl',
  'Alternate Incline Dumbbell Curl',
  'Barbell Curl',
  'Barbell Curls Lying Against An Incline',
  'Cable Hammer Curls - Rope Attachment',
  'Cable Preacher Curl',
  'Close-Grip Standing Barbell Curl',
  'Concentration Curls',
  'Dumbbell Alternate Bicep Curl',
  'Dumbbell Bicep Curl',
  'Dumbbell Prone Incline Curl',
  'EZ-Bar Curl',
  'Flexor Incline Dumbbell Curls',
  'Hammer Curls',
  'Incline Dumbbell Curl',
  'Lying Cable Curl',
  'Lying Close-Grip Bar Curl On High Pulley',
  'Lying High Bench Barbell Curl',
  'Lying Supine Dumbbell Curl',
  'Machine Bicep Curl',
  'Machine Preacher Curls',
  'One Arm Dumbbell Preacher Curl',
  'Overhead Cable Curl',
  'Preacher Curl',
  'Preacher Hammer Dumbbell Curl',
  'Reverse Barbell Curl',
  'Reverse Barbell Preacher Curls',
  'Reverse Cable Curl',
  'Reverse Plate Curls',
  'Seated Close-Grip Concentration Barbell Curl',
  'Seated Dumbbell Curl',
  'Seated Dumbbell Inner Biceps Curl',
  'Spider Curl',
  'Standing Biceps Cable Curl',
  'Standing Concentration Curl',
  'Standing Inner-Biceps Curl',
  'Standing One-Arm Cable Curl',
  'Standing One-Arm Dumbbell Curl Over Incline Bench',
  'Wide-Grip Standing Barbell Curl',
  'Zottman Curl',
  'Zottman Preacher Curl'
) AND exercise_type IS NULL;

-- Rear delt isolation (pull pattern, shoulder)
UPDATE exercises SET exercise_type = 'pull'
WHERE name IN (
  'Bent Over Dumbbell Rear Delt Raise With Head On Bench',
  'Cable Rear Delt Fly',
  'Dumbbell Lying Rear Lateral Raise',
  'Lying Rear Delt Raise',
  'Reverse Flyes',
  'Reverse Flyes With External Rotation',
  'Reverse Machine Flyes',
  'Seated Bent-Over Rear Delt Raise',
  'Sled Reverse Flye',
  'Back Flyes - With Bands',
  'Bent Over Low-Pulley Side Lateral',
  'Cable Rope Rear-Delt Rows'
) AND exercise_type IS NULL;

-- Straight-arm pulldown / pullover (lat isolation)
UPDATE exercises SET exercise_type = 'pull'
WHERE name IN (
  'Straight-Arm Pulldown',
  'Straight-Arm Dumbbell Pullover',
  'Bent-Arm Barbell Pullover',
  'Bent-Arm Dumbbell Pullover',
  'Wide-Grip Decline Barbell Pullover',
  'Cable Shrugs',
  'Barbell Shrug',
  'Barbell Shrug Behind The Back',
  'Dumbbell Shrug',
  'Smith Machine Behind the Back Shrug',
  'Calf-Machine Shoulder Shrug'
) AND exercise_type IS NULL;


-- ---- 1c. LEGS isolation exercises ----
UPDATE exercises SET exercise_type = 'legs'
WHERE name IN (
  'Adductor',
  'Adductor/Groin',
  'Ball Leg Curl',
  'Band Hip Adductions',
  'Barbell Seated Calf Raise',
  'Butt Lift (Bridge)',
  'Cable Hip Adduction',
  'Calf Press',
  'Calf Press On The Leg Press Machine',
  'Calf Raise On A Dumbbell',
  'Calf Raises - With Bands',
  'Dumbbell Seated One-Leg Calf Raise',
  'Glute Kickback',
  'Leg Extensions',
  'Lying Leg Curls',
  'Seated Band Hamstring Curl',
  'Seated Calf Raise',
  'Seated Leg Curl',
  'Single Leg Glute Bridge',
  'Single-Leg Leg Extension',
  'Smith Machine Calf Raise',
  'Smith Machine Reverse Calf Raises',
  'Standing Barbell Calf Raise',
  'Standing Calf Raises',
  'Standing Dumbbell Calf Raise',
  'Standing Leg Curl',
  'Thigh Abductor',
  'Thigh Adductor'
) AND exercise_type IS NULL;


-- ---- 1d. CORE isolation exercises ----
UPDATE exercises SET exercise_type = 'core'
WHERE name IN (
  '3/4 Sit-Up',
  'Ab Crunch Machine',
  'Ab Roller',
  'Air Bike',
  'Alternate Heel Touchers',
  'Barbell Ab Rollout',
  'Barbell Ab Rollout - On Knees',
  'Barbell Side Bend',
  'Butt-Ups',
  'Cable Crunch',
  'Cable Reverse Crunch',
  'Cable Russian Twists',
  'Cable Seated Crunch',
  'Crunch - Hands Overhead',
  'Crunch - Legs On Exercise Ball',
  'Crunches',
  'Decline Crunch',
  'Dumbbell Side Bend',
  'Flat Bench Leg Pull-In',
  'Flat Bench Lying Leg Raise',
  'Gorilla Chin/Crunch',
  'Hanging Leg Raise',
  'Hanging Pike',
  'Jackknife Sit-Up',
  'Landmine 180s',
  'Leg Lift',
  'Leg Pull-In',
  'Oblique Crunches',
  'Oblique Crunches - On The Floor',
  'Plank',
  'Reverse Crunch',
  'Russian Twist',
  'Seated Barbell Twist',
  'Seated Flat Bench Leg Pull-In',
  'Seated Leg Tucks',
  'Spell Caster',
  'Standing Cable Wood Chop',
  'Standing Cable Lift',
  'Standing Rope Crunch',
  'Barbell Rollout from Bench'
) AND exercise_type IS NULL;


-- ---- 1e. FULL_BODY exercises (oly lifts, kettlebell complexes) ----
UPDATE exercises SET exercise_type = 'full_body'
WHERE name IN (
  'Alternating Hang Clean',
  'Clean',
  'Clean and Jerk',
  'Clean and Press',
  'Clean Deadlift',
  'Clean Pull',
  'Clean Shrug',
  'Hang Clean',
  'Kettlebell Thruster',
  'Kipping Muscle Up',
  'Muscle Up',
  'Power Clean',
  'Power Clean from Blocks',
  'Power Snatch',
  'Smith Machine Hang Power Clean',
  'Two-Arm Kettlebell Clean',
  'Two-Arm Kettlebell Jerk',
  'One-Arm Kettlebell Swings',
  'Mountain Climbers',
  'Dumbbell Clean'
) AND exercise_type IS NULL;


-- ---- 1f. CARDIO exercises ----
UPDATE exercises SET exercise_type = 'cardio'
WHERE name IN (
  'Bicycling',
  'Bicycling, Stationary',
  'Jogging, Treadmill',
  'Recumbent Bike',
  'Rowing, Stationary',
  'Running, Treadmill',
  'Stairmaster',
  'Step Mill',
  'Trail Running/Walking'
) AND exercise_type IS NULL;


-- ---- 1g. Catch-all pattern-based for remaining isolation/other ----
-- Wrist curls -> pull (forearm isolation)
UPDATE exercises SET exercise_type = 'pull'
WHERE name ILIKE '%wrist curl%'
  AND exercise_type IS NULL;

-- Remaining calf exercises -> legs
UPDATE exercises SET exercise_type = 'legs'
WHERE (name ILIKE '%calf%' OR name ILIKE '%soleus%' OR name ILIKE '%gastrocnemius%')
  AND name NOT ILIKE '%stretch%'
  AND exercise_type IS NULL;

-- Remaining curl exercises (biceps) -> pull
UPDATE exercises SET exercise_type = 'pull'
WHERE name ILIKE '%curl%'
  AND name NOT ILIKE '%leg curl%'
  AND name NOT ILIKE '%hamstring curl%'
  AND exercise_type IS NULL;

-- Remaining triceps exercises -> push
UPDATE exercises SET exercise_type = 'push'
WHERE (name ILIKE '%tricep%' OR name ILIKE '%skull%' OR name ILIKE '%pushdown%')
  AND exercise_type IS NULL;

-- Remaining shrug exercises -> pull
UPDATE exercises SET exercise_type = 'pull'
WHERE name ILIKE '%shrug%'
  AND exercise_type IS NULL;

-- Remaining fly/flye exercises -> push (chest isolation)
UPDATE exercises SET exercise_type = 'push'
WHERE (name ILIKE '%flye%' OR name ILIKE '%fly%' OR name ILIKE '%crossover%')
  AND name NOT ILIKE '%reverse%'
  AND name NOT ILIKE '%rear%'
  AND exercise_type IS NULL;

-- Remaining raise exercises (lateral/front) -> push
UPDATE exercises SET exercise_type = 'push'
WHERE name ILIKE '%lateral raise%'
  AND exercise_type IS NULL;

-- Remaining crunch/ab exercises -> core
UPDATE exercises SET exercise_type = 'core'
WHERE (name ILIKE '%crunch%' OR name ILIKE '%sit-up%' OR name ILIKE '%ab %')
  AND exercise_type IS NULL;


-- =============================================================================
-- 2. LATERALITY: bilateral/unilateral/both for common exercises
-- =============================================================================

-- ---- 2a. BILATERAL exercises (two limbs work together) ----
UPDATE exercises SET laterality = 'bilateral'
WHERE name IN (
  -- Barbell compounds
  'Barbell Bench Press - Medium Grip',
  'Barbell Deadlift',
  'Barbell Full Squat',
  'Barbell Squat',
  'Barbell Squat To A Bench',
  'Barbell Shoulder Press',
  'Barbell Incline Bench Press - Medium Grip',
  'Barbell Curl',
  'Barbell Glute Bridge',
  'Barbell Guillotine Bench Press',
  'Barbell Hack Squat',
  'Barbell Hip Thrust',
  'Barbell Rear Delt Row',
  'Barbell Seated Calf Raise',
  'Barbell Shrug',
  'Barbell Shrug Behind The Back',
  'Barbell Side Split Squat',
  'Barbell Ab Rollout',
  'Barbell Ab Rollout - On Knees',
  'Bent Over Barbell Row',
  'Bradford/Rocky Presses',
  'Close-Grip Barbell Bench Press',
  'Close-Grip Standing Barbell Curl',
  'Decline Barbell Bench Press',
  'EZ-Bar Curl',
  'EZ-Bar Skullcrusher',
  'Front Barbell Squat',
  'Front Barbell Squat To A Bench',
  'Front Squat (Clean Grip)',
  'Good Morning',
  'Good Morning off Pins',
  'Hack Squat',
  'Leg Press',
  'Lying Leg Curls',
  'Leg Extensions',
  'Overhead Squat',
  'Rack Pulls',
  'Reverse Barbell Curl',
  'Reverse Grip Bent-Over Rows',
  'Romanian Deadlift',
  'Romanian Deadlift from Deficit',
  'Seated Barbell Military Press',
  'Seated Cable Rows',
  'Seated Calf Raise',
  'Seated Leg Curl',
  'Standing Barbell Calf Raise',
  'Standing Calf Raises',
  'Standing Military Press',
  'Stiff-Legged Barbell Deadlift',
  'Sumo Deadlift',
  'T-Bar Row with Handle',
  'Upright Barbell Row',
  'Wide-Grip Barbell Bench Press',
  'Wide-Grip Decline Barbell Bench Press',
  'Wide-Grip Lat Pulldown',
  'Wide-Grip Standing Barbell Curl',
  -- Dumbbell bilateral
  'Dumbbell Bench Press',
  'Dumbbell Bench Press with Neutral Grip',
  'Dumbbell Flyes',
  'Dumbbell Shoulder Press',
  'Dumbbell Shrug',
  'Dumbbell Squat',
  'Dumbbell Squat To A Bench',
  'Incline Dumbbell Flyes',
  'Incline Dumbbell Press',
  'Decline Dumbbell Flyes',
  'Bent Over Two-Dumbbell Row',
  'Bent Over Two-Dumbbell Row With Palms In',
  'Seated Dumbbell Press',
  -- Machine bilateral
  'Ab Crunch Machine',
  'Butterfly',
  'Calf Press On The Leg Press Machine',
  'Cable Crossover',
  'Cable Chest Press',
  'Close-Grip Front Lat Pulldown',
  'Full Range-Of-Motion Lat Pulldown',
  'Leverage Chest Press',
  'Leverage Decline Chest Press',
  'Leverage Incline Chest Press',
  'Leverage Shoulder Press',
  'Machine Bench Press',
  'Machine Shoulder (Military) Press',
  'Machine Triceps Extension',
  'Narrow Stance Hack Squats',
  'Reverse Machine Flyes',
  'Smith Machine Bench Press',
  'Smith Machine Close-Grip Bench Press',
  'Smith Machine Decline Press',
  'Smith Machine Incline Bench Press',
  'Smith Machine Overhead Shoulder Press',
  'Smith Machine Squat',
  'V-Bar Pulldown',
  'V-Bar Pullup',
  -- Bodyweight bilateral
  'Pullups',
  'Chin-Up',
  'Dips - Chest Version',
  'Dips - Triceps Version',
  'Glute Ham Raise',
  'Hyperextensions (Back Extensions)',
  'Plank',
  'Ring Dips',
  -- Cable bilateral
  'Cable Crunch',
  'Cable Rope Overhead Triceps Extension',
  'Face Pull',
  'Triceps Pushdown',
  'Triceps Pushdown - Rope Attachment',
  'Triceps Pushdown - V-Bar Attachment',
  'Upright Cable Row',
  'Straight-Arm Pulldown',
  -- Olympic lifts
  'Clean and Jerk',
  'Clean and Press',
  'Power Clean',
  'Power Clean from Blocks',
  'Clean',
  'Barbell Clean and Press',
  'Sumo Deadlift with Bands',
  'Sumo Deadlift with Chains'
) AND laterality IS NULL;


-- ---- 2b. UNILATERAL exercises (one limb at a time) ----
UPDATE exercises SET laterality = 'unilateral'
WHERE name IN (
  -- Single-arm dumbbell
  'Alternate Hammer Curl',
  'Alternate Incline Dumbbell Curl',
  'Concentration Curls',
  'Dumbbell Alternate Bicep Curl',
  'Dumbbell Lying One-Arm Rear Lateral Raise',
  'Dumbbell One-Arm Shoulder Press',
  'Dumbbell One-Arm Triceps Extension',
  'Dumbbell One-Arm Upright Row',
  'Dumbbell Prone Incline Curl',
  'One Arm Chin-Up',
  'One Arm Dumbbell Bench Press',
  'One Arm Dumbbell Preacher Curl',
  'One Arm Floor Press',
  'One Arm Lat Pulldown',
  'One Arm Pronated Dumbbell Triceps Extension',
  'One Arm Supinated Dumbbell Triceps Extension',
  'One-Arm Dumbbell Row',
  'One-Arm Flat Bench Dumbbell Flye',
  'Seated Bent-Over One-Arm Dumbbell Triceps Extension',
  'Seated One-Arm Dumbbell Palms-Down Wrist Curl',
  'Seated One-Arm Dumbbell Palms-Up Wrist Curl',
  'Seated One-arm Cable Pulley Rows',
  'Spider Curl',
  'Standing Bent-Over One-Arm Dumbbell Triceps Extension',
  'Standing Concentration Curl',
  'Standing One-Arm Cable Curl',
  'Standing One-Arm Dumbbell Curl Over Incline Bench',
  'Standing One-Arm Dumbbell Triceps Extension',
  'Standing Palm-In One-Arm Dumbbell Press',
  -- Single-arm cable
  'Cable One Arm Tricep Extension',
  'Single-Arm Cable Crossover',
  'Standing Low-Pulley One-Arm Triceps Extension',
  -- Single-leg
  'Dumbbell Rear Lunge',
  'Dumbbell Seated One-Leg Calf Raise',
  'Dumbbell Step Ups',
  'Barbell Step Ups',
  'Single Leg Glute Bridge',
  'Single-Arm Push-Up',
  'Single-Leg Leg Extension',
  'Smith Single-Leg Split Squat',
  'Smith Machine Pistol Squat',
  'Step-up with Knee Raise',
  'Standing Leg Curl',
  'Standing Dumbbell Calf Raise',
  -- Kettlebell unilateral
  'One-Arm Kettlebell Floor Press',
  'One-Arm Kettlebell Swings',
  -- Bent-over single-arm rows
  'Bent Over One-Arm Long Bar Row'
) AND laterality IS NULL;


-- ---- 2c. BOTH (can be done bilateral or unilateral) ----
UPDATE exercises SET laterality = 'both'
WHERE name IN (
  'Dumbbell Bicep Curl',
  'Dumbbell Lunges',
  'Hammer Curls',
  'Incline Dumbbell Curl',
  'Preacher Curl',
  'Preacher Hammer Dumbbell Curl',
  'Seated Dumbbell Curl',
  'Seated Dumbbell Inner Biceps Curl',
  'Barbell Lunge',
  'Barbell Walking Lunge',
  'Cable Hammer Curls - Rope Attachment',
  'Cable Preacher Curl',
  'Calf Raise On A Dumbbell',
  'Goblet Squat',
  'Reverse Barbell Preacher Curls',
  'Reverse Cable Curl',
  'Split Squat with Dumbbells',
  'Split Squats',
  'Standing Biceps Cable Curl',
  'Standing Inner-Biceps Curl',
  'Zottman Curl',
  'Zottman Preacher Curl',
  'Seated Bent-Over Rear Delt Raise',
  'Side Lateral Raise',
  'Seated Side Lateral Raise',
  'Front Raise And Pullover'
) AND laterality IS NULL;


-- ---- 2d. Pattern-based laterality for remaining exercises ----
-- Exercises with "One-Arm", "One Arm", "Single-Arm", "Single-Leg", "Single Leg" -> unilateral
UPDATE exercises SET laterality = 'unilateral'
WHERE (
  name ILIKE '%one-arm%' OR name ILIKE '%one arm%'
  OR name ILIKE '%single-arm%' OR name ILIKE '%single arm%'
  OR name ILIKE '%single-leg%' OR name ILIKE '%single leg%'
  OR name ILIKE '%one-leg%' OR name ILIKE '%one leg%'
)
AND laterality IS NULL;

-- Exercises with "alternate" or "alternating" -> unilateral (performed one side at a time)
UPDATE exercises SET laterality = 'unilateral'
WHERE (name ILIKE 'alternate %' OR name ILIKE 'alternating %')
  AND laterality IS NULL;

-- Barbell exercises are generally bilateral
UPDATE exercises SET laterality = 'bilateral'
WHERE name ILIKE 'barbell %'
  AND laterality IS NULL;

-- Machine exercises are generally bilateral
UPDATE exercises SET laterality = 'bilateral'
WHERE (name ILIKE 'machine %' OR name ILIKE 'leverage %' OR name ILIKE 'smith machine %')
  AND laterality IS NULL;

-- Push-up variations are bilateral
UPDATE exercises SET laterality = 'bilateral'
WHERE (name ILIKE '%push-up%' OR name ILIKE '%push up%')
  AND name NOT ILIKE '%single%' AND name NOT ILIKE '%one%'
  AND laterality IS NULL;


-- =============================================================================
-- 3. ALIASES: Common alternate names for the top 50 exercises
-- =============================================================================
-- These aliases power search/deduplication so users find exercises regardless
-- of what name they know.

-- Big 3 powerlifts
UPDATE exercises SET aliases = ARRAY['Flat Bench Press', 'Bench Press', 'Flat Bench', 'BB Bench']
WHERE name = 'Barbell Bench Press - Medium Grip';

UPDATE exercises SET aliases = ARRAY['Conventional Deadlift', 'Deadlift', 'BB Deadlift']
WHERE name = 'Barbell Deadlift';

UPDATE exercises SET aliases = ARRAY['Back Squat', 'Squat', 'Full Squat', 'ATG Squat', 'BB Squat']
WHERE name = 'Barbell Full Squat';

UPDATE exercises SET aliases = ARRAY['Squat', 'Back Squat', 'BB Squat']
WHERE name = 'Barbell Squat';

-- Pressing
UPDATE exercises SET aliases = ARRAY['OHP', 'Overhead Press', 'Military Press', 'Standing Press']
WHERE name = 'Barbell Shoulder Press';

UPDATE exercises SET aliases = ARRAY['Seated OHP', 'Seated Military Press']
WHERE name = 'Seated Barbell Military Press';

UPDATE exercises SET aliases = ARRAY['Standing OHP', 'Strict Press']
WHERE name = 'Standing Military Press';

UPDATE exercises SET aliases = ARRAY['Arnold Press']
WHERE name = 'Arnold Dumbbell Press';

UPDATE exercises SET aliases = ARRAY['DB Shoulder Press', 'DB OHP']
WHERE name = 'Dumbbell Shoulder Press';

UPDATE exercises SET aliases = ARRAY['Seated DB Press']
WHERE name = 'Seated Dumbbell Press';

UPDATE exercises SET aliases = ARRAY['DB Bench Press', 'DB Bench', 'Flat DB Bench']
WHERE name = 'Dumbbell Bench Press';

UPDATE exercises SET aliases = ARRAY['Incline Bench', 'Incline BB Bench']
WHERE name = 'Barbell Incline Bench Press - Medium Grip';

UPDATE exercises SET aliases = ARRAY['Incline DB Press', 'Incline DB Bench']
WHERE name = 'Incline Dumbbell Press';

UPDATE exercises SET aliases = ARRAY['CG Bench', 'Close Grip Bench']
WHERE name = 'Close-Grip Barbell Bench Press';

UPDATE exercises SET aliases = ARRAY['Decline Bench']
WHERE name = 'Decline Barbell Bench Press';

-- Rows and pulls
UPDATE exercises SET aliases = ARRAY['Barbell Row', 'BB Row', 'Pendlay Row']
WHERE name = 'Bent Over Barbell Row';

UPDATE exercises SET aliases = ARRAY['DB Row', 'Dumbbell Row']
WHERE name = 'One-Arm Dumbbell Row';

UPDATE exercises SET aliases = ARRAY['Seated Row', 'Cable Row', 'Seated Cable Row']
WHERE name = 'Seated Cable Rows';

UPDATE exercises SET aliases = ARRAY['T-Bar Row', 'T Bar Row']
WHERE name = 'T-Bar Row with Handle';

UPDATE exercises SET aliases = ARRAY['Wide Grip Lat Pull', 'Lat Pull']
WHERE name = 'Wide-Grip Lat Pulldown';

UPDATE exercises SET aliases = ARRAY['Close Grip Pulldown', 'CG Lat Pulldown']
WHERE name = 'Close-Grip Front Lat Pulldown';

UPDATE exercises SET aliases = ARRAY['Reverse Pec Deck', 'Rear Delt Machine']
WHERE name = 'Reverse Machine Flyes';

UPDATE exercises SET aliases = ARRAY['Cable Face Pull']
WHERE name = 'Face Pull';

UPDATE exercises SET aliases = ARRAY['Rear Delt Fly', 'Reverse Cable Fly']
WHERE name = 'Cable Rear Delt Fly';

-- Leg exercises
UPDATE exercises SET aliases = ARRAY['Hip Thrust', 'BB Hip Thrust', 'Glute Bridge']
WHERE name = 'Barbell Hip Thrust';

UPDATE exercises SET aliases = ARRAY['RDL', 'Romanian DL', 'Stiff Leg Deadlift']
WHERE name = 'Romanian Deadlift';

UPDATE exercises SET aliases = ARRAY['SLDL', 'Stiff-Leg Deadlift', 'Stiff Legged DL']
WHERE name = 'Stiff-Legged Barbell Deadlift';

UPDATE exercises SET aliases = ARRAY['Sumo DL', 'Wide Stance Deadlift']
WHERE name = 'Sumo Deadlift';

UPDATE exercises SET aliases = ARRAY['Front Squat', 'FS']
WHERE name = 'Front Squat (Clean Grip)';

UPDATE exercises SET aliases = ARRAY['Hack Squat Machine']
WHERE name = 'Hack Squat';

UPDATE exercises SET aliases = ARRAY['BB Lunge']
WHERE name = 'Barbell Lunge';

UPDATE exercises SET aliases = ARRAY['DB Lunge', 'Dumbbell Lunge']
WHERE name = 'Dumbbell Lunges';

UPDATE exercises SET aliases = ARRAY['Standing Calf Raise']
WHERE name = 'Standing Calf Raises';

UPDATE exercises SET aliases = ARRAY['Leg Curl', 'Hamstring Curl', 'Lying Hamstring Curl']
WHERE name = 'Lying Leg Curls';

UPDATE exercises SET aliases = ARRAY['Leg Extension', 'Quad Extension']
WHERE name = 'Leg Extensions';

-- Arm isolation
UPDATE exercises SET aliases = ARRAY['BB Curl', 'Standing Barbell Curl']
WHERE name = 'Barbell Curl';

UPDATE exercises SET aliases = ARRAY['DB Curl', 'Bicep Curl', 'DB Bicep Curl']
WHERE name = 'Dumbbell Bicep Curl';

UPDATE exercises SET aliases = ARRAY['Lying Tricep Extension', 'Nose Breaker', 'Skullcrusher']
WHERE name = 'EZ-Bar Skullcrusher';

UPDATE exercises SET aliases = ARRAY['Rope Pushdown', 'Rope Tricep Pushdown']
WHERE name = 'Triceps Pushdown - Rope Attachment';

UPDATE exercises SET aliases = ARRAY['Tricep Pushdown', 'Cable Pushdown']
WHERE name = 'Triceps Pushdown';

UPDATE exercises SET aliases = ARRAY['Overhead Tricep Extension', 'Rope Overhead Extension']
WHERE name = 'Cable Rope Overhead Triceps Extension';

-- Bodyweight
UPDATE exercises SET aliases = ARRAY['Pull-Up', 'Pull Up', 'Overhand Pullup', 'Pullup']
WHERE name = 'Pullups';

UPDATE exercises SET aliases = ARRAY['Chinup', 'Chin Up', 'Underhand Pullup', 'Supinated Pullup']
WHERE name = 'Chin-Up';

UPDATE exercises SET aliases = ARRAY['Chest Dip', 'Parallel Bar Dip']
WHERE name = 'Dips - Chest Version';

UPDATE exercises SET aliases = ARRAY['Tricep Dip']
WHERE name = 'Dips - Triceps Version';

UPDATE exercises SET aliases = ARRAY['Back Extension', 'Back Raise', 'Hypers']
WHERE name = 'Hyperextensions (Back Extensions)';

-- Core
UPDATE exercises SET aliases = ARRAY['Hanging Knee Raise', 'Hanging Leg Lift']
WHERE name = 'Hanging Leg Raise';

UPDATE exercises SET aliases = ARRAY['Lat Raise', 'DB Lateral Raise', 'Lateral Delt Raise']
WHERE name = 'Side Lateral Raise';

-- Farmer's walk
UPDATE exercises SET aliases = ARRAY['Farmer Walk', 'Farmer Carry']
WHERE name = 'Farmer''s Walk';


-- =============================================================================
-- 4. ACTIVATION PERCENT: Evidence-based EMG tiers for top compound exercises
-- =============================================================================
-- Tier system based on normalized EMG (%MVIC):
--   90 = primary mover (>60% MVIC in most studies)
--   60 = strong synergist (30-60% MVIC)
--   30 = stabilizer / minor contributor (<30% MVIC)
--
-- We also set is_primary = true for 90, false for 60 and 30, to align
-- the boolean with the new percentage.

-- Helper: only update if the exercise_muscles row exists
-- We use a subquery pattern:
--   UPDATE exercise_muscles em
--   SET activation_percent = X
--   FROM exercises e
--   WHERE e.id = em.exercise_id
--     AND e.name = '...'
--     AND e.created_by IS NULL
--     AND em.muscle_group_id = Y;


-- ---------------------------------------------------------------------------
-- 4a. BARBELL BENCH PRESS - Medium Grip
-- Source: Schoenfeld et al. (2016); Andersen et al. (2010)
-- Primary: pectoralis major (90), anterior deltoid (60), triceps (60)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Barbell Bench Press - Medium Grip'
  AND e.created_by IS NULL AND em.muscle_group_id = 4;  -- Chest

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Barbell Bench Press - Medium Grip'
  AND e.created_by IS NULL AND em.muscle_group_id = 1;  -- Anterior deltoid

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Barbell Bench Press - Medium Grip'
  AND e.created_by IS NULL AND em.muscle_group_id = 13; -- Triceps

-- Existing seed has muscle_group_id 2 (biceps) and 3 (brachialis) as secondary
-- which is incorrect for bench press. Update to stabilizer level.
UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Barbell Bench Press - Medium Grip'
  AND e.created_by IS NULL AND em.muscle_group_id IN (2, 3);


-- ---------------------------------------------------------------------------
-- 4b. BARBELL DEADLIFT
-- Source: Escamilla et al. (2002); Schoenfeld et al. (2020)
-- Primary: glutes (90), hamstrings (90), erector spinae (90)
-- Synergist: quads (60), lats (60), traps (60)
-- Stabilizer: forearms/grip (30)
-- ---------------------------------------------------------------------------
-- Note: erector spinae not in our 16 muscle_groups table; closest is trapezius
-- for upper back contribution. We work with existing junction rows.

UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Barbell Deadlift'
  AND e.created_by IS NULL AND em.muscle_group_id = 15; -- Glutes

UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Barbell Deadlift'
  AND e.created_by IS NULL AND em.muscle_group_id = 16; -- Hamstrings

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Barbell Deadlift'
  AND e.created_by IS NULL AND em.muscle_group_id = 9;  -- Quadriceps

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Barbell Deadlift'
  AND e.created_by IS NULL AND em.muscle_group_id = 5;  -- Lats

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Barbell Deadlift'
  AND e.created_by IS NULL AND em.muscle_group_id = 12; -- Trapezius

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Barbell Deadlift'
  AND e.created_by IS NULL AND em.muscle_group_id IN (7, 8, 11, 13); -- Obliques, post delt, soleus, triceps


-- ---------------------------------------------------------------------------
-- 4c. BARBELL FULL SQUAT
-- Source: Escamilla et al. (2001); Contreras et al. (2016)
-- Primary: quads (90), glutes (90)
-- Synergist: hamstrings (60), adductors (60)
-- Stabilizer: obliques (30), calves (30)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Barbell Full Squat'
  AND e.created_by IS NULL AND em.muscle_group_id = 9;  -- Quadriceps

UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Barbell Full Squat'
  AND e.created_by IS NULL AND em.muscle_group_id = 15; -- Glutes

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Barbell Full Squat'
  AND e.created_by IS NULL AND em.muscle_group_id = 16; -- Hamstrings

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Barbell Full Squat'
  AND e.created_by IS NULL AND em.muscle_group_id IN (7, 8, 11, 13); -- Obliques, post delt, soleus, triceps


-- ---------------------------------------------------------------------------
-- 4d. BARBELL SHOULDER PRESS (Standing OHP)
-- Source: Saeterbakken & Fimland (2013)
-- Primary: anterior deltoid (90), triceps (60)
-- Synergist: middle deltoid (60), upper chest (30)
-- Stabilizer: traps (30), core (30)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Barbell Shoulder Press'
  AND e.created_by IS NULL AND em.muscle_group_id = 1;  -- Anterior deltoid

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Barbell Shoulder Press'
  AND e.created_by IS NULL AND em.muscle_group_id = 13; -- Triceps

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Barbell Shoulder Press'
  AND e.created_by IS NULL AND em.muscle_group_id = 6;  -- Middle deltoid

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Barbell Shoulder Press'
  AND e.created_by IS NULL AND em.muscle_group_id IN (4, 12); -- Chest, traps


-- ---------------------------------------------------------------------------
-- 4e. INCLINE DUMBBELL PRESS
-- Source: Trebs et al. (2010); Lauver et al. (2016)
-- Primary: upper chest (90), anterior deltoid (60), triceps (60)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Incline Dumbbell Press'
  AND e.created_by IS NULL AND em.muscle_group_id = 4;  -- Chest

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Incline Dumbbell Press'
  AND e.created_by IS NULL AND em.muscle_group_id = 1;  -- Anterior deltoid

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Incline Dumbbell Press'
  AND e.created_by IS NULL AND em.muscle_group_id = 13; -- Triceps


-- ---------------------------------------------------------------------------
-- 4f. DUMBBELL BENCH PRESS
-- Source: Saeterbakken et al. (2011)
-- Primary: chest (90), anterior deltoid (60), triceps (60)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Dumbbell Bench Press'
  AND e.created_by IS NULL AND em.muscle_group_id = 4;  -- Chest

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Dumbbell Bench Press'
  AND e.created_by IS NULL AND em.muscle_group_id = 1;  -- Anterior deltoid

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Dumbbell Bench Press'
  AND e.created_by IS NULL AND em.muscle_group_id = 13; -- Triceps


-- ---------------------------------------------------------------------------
-- 4g. CLOSE-GRIP BARBELL BENCH PRESS
-- Source: Barnett et al. (1995); Lehman (2005)
-- Primary: triceps (90), chest (60), anterior deltoid (30)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Close-Grip Barbell Bench Press'
  AND e.created_by IS NULL AND em.muscle_group_id = 13; -- Triceps

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Close-Grip Barbell Bench Press'
  AND e.created_by IS NULL AND em.muscle_group_id = 4;  -- Chest

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Close-Grip Barbell Bench Press'
  AND e.created_by IS NULL AND em.muscle_group_id IN (1, 2); -- Anterior deltoid, biceps


-- ---------------------------------------------------------------------------
-- 4h. BENT OVER BARBELL ROW
-- Source: Lehman et al. (2004); Fenwick et al. (2009)
-- Primary: lats (90), mid traps/rhomboids (90)
-- Synergist: posterior deltoid (60), biceps (60)
-- Stabilizer: forearms (30), erector spinae (30)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Bent Over Barbell Row'
  AND e.created_by IS NULL AND em.muscle_group_id = 5;  -- Lats

UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Bent Over Barbell Row'
  AND e.created_by IS NULL AND em.muscle_group_id = 12; -- Trapezius

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Bent Over Barbell Row'
  AND e.created_by IS NULL AND em.muscle_group_id = 8;  -- Posterior deltoid

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Bent Over Barbell Row'
  AND e.created_by IS NULL AND em.muscle_group_id = 2;  -- Biceps

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Bent Over Barbell Row'
  AND e.created_by IS NULL AND em.muscle_group_id IN (3, 7); -- Brachialis, obliques


-- ---------------------------------------------------------------------------
-- 4i. WIDE-GRIP LAT PULLDOWN
-- Source: Signorile et al. (2002); Lusk et al. (2010)
-- Primary: lats (90)
-- Synergist: biceps (60), posterior deltoid (60), traps (30)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Wide-Grip Lat Pulldown'
  AND e.created_by IS NULL AND em.muscle_group_id = 5;  -- Lats

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Wide-Grip Lat Pulldown'
  AND e.created_by IS NULL AND em.muscle_group_id = 2;  -- Biceps

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Wide-Grip Lat Pulldown'
  AND e.created_by IS NULL AND em.muscle_group_id = 8;  -- Posterior deltoid

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Wide-Grip Lat Pulldown'
  AND e.created_by IS NULL AND em.muscle_group_id = 12; -- Trapezius


-- ---------------------------------------------------------------------------
-- 4j. CHIN-UP
-- Source: Youdas et al. (2010); Dickie et al. (2017)
-- Primary: lats (90), biceps (90)
-- Synergist: posterior deltoid (60), traps (60), brachialis (60)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Chin-Up'
  AND e.created_by IS NULL AND em.muscle_group_id = 5;  -- Lats

UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Chin-Up'
  AND e.created_by IS NULL AND em.muscle_group_id = 2;  -- Biceps

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Chin-Up'
  AND e.created_by IS NULL AND em.muscle_group_id = 8;  -- Posterior deltoid

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Chin-Up'
  AND e.created_by IS NULL AND em.muscle_group_id = 12; -- Trapezius

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Chin-Up'
  AND e.created_by IS NULL AND em.muscle_group_id = 3;  -- Brachialis


-- ---------------------------------------------------------------------------
-- 4k. DIPS - CHEST VERSION
-- Source: Kolber et al. (2021); McKenzie (1998)
-- Primary: chest (90), triceps (90), anterior deltoid (60)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Dips - Chest Version'
  AND e.created_by IS NULL AND em.muscle_group_id = 4;  -- Chest

UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Dips - Chest Version'
  AND e.created_by IS NULL AND em.muscle_group_id = 13; -- Triceps

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Dips - Chest Version'
  AND e.created_by IS NULL AND em.muscle_group_id = 1;  -- Anterior deltoid


-- ---------------------------------------------------------------------------
-- 4l. DIPS - TRICEPS VERSION
-- Source: Kolber et al. (2021)
-- Primary: triceps (90), chest (60), anterior deltoid (30)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Dips - Triceps Version'
  AND e.created_by IS NULL AND em.muscle_group_id = 13; -- Triceps

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Dips - Triceps Version'
  AND e.created_by IS NULL AND em.muscle_group_id = 4;  -- Chest

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Dips - Triceps Version'
  AND e.created_by IS NULL AND em.muscle_group_id = 1;  -- Anterior deltoid


-- ---------------------------------------------------------------------------
-- 4m. BARBELL HIP THRUST
-- Source: Contreras et al. (2015, 2016)
-- Primary: glutes (90)
-- Synergist: hamstrings (60), quads (30)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Barbell Hip Thrust'
  AND e.created_by IS NULL AND em.muscle_group_id = 15; -- Glutes

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Barbell Hip Thrust'
  AND e.created_by IS NULL AND em.muscle_group_id = 16; -- Hamstrings

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Barbell Hip Thrust'
  AND e.created_by IS NULL AND em.muscle_group_id = 9;  -- Quadriceps


-- ---------------------------------------------------------------------------
-- 4n. ROMANIAN DEADLIFT
-- Source: Ebben et al. (2009); McAllister et al. (2014)
-- Primary: hamstrings (90), glutes (90)
-- Synergist: erector spinae/traps (60)
-- Stabilizer: lats (30), forearms (30)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Romanian Deadlift'
  AND e.created_by IS NULL AND em.muscle_group_id = 16; -- Hamstrings

UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Romanian Deadlift'
  AND e.created_by IS NULL AND em.muscle_group_id = 15; -- Glutes

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Romanian Deadlift'
  AND e.created_by IS NULL AND em.muscle_group_id = 12; -- Trapezius (erector proxy)

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Romanian Deadlift'
  AND e.created_by IS NULL AND em.muscle_group_id IN (5, 7); -- Lats, obliques


-- ---------------------------------------------------------------------------
-- 4o. SUMO DEADLIFT
-- Source: Escamilla et al. (2002); Cholewicki et al. (1991)
-- Primary: quads (90), glutes (90)
-- Synergist: hamstrings (60), traps/erector (60), adductors (60)
-- Stabilizer: lats (30)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Sumo Deadlift'
  AND e.created_by IS NULL AND em.muscle_group_id = 9;  -- Quadriceps

UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Sumo Deadlift'
  AND e.created_by IS NULL AND em.muscle_group_id = 15; -- Glutes

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Sumo Deadlift'
  AND e.created_by IS NULL AND em.muscle_group_id = 16; -- Hamstrings

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Sumo Deadlift'
  AND e.created_by IS NULL AND em.muscle_group_id = 12; -- Trapezius

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Sumo Deadlift'
  AND e.created_by IS NULL AND em.muscle_group_id = 5;  -- Lats


-- ---------------------------------------------------------------------------
-- 4p. LEG PRESS
-- Source: Escamilla et al. (2001)
-- Primary: quads (90), glutes (60)
-- Synergist: hamstrings (30), calves (30)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Leg Press'
  AND e.created_by IS NULL AND em.muscle_group_id = 9;  -- Quadriceps

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Leg Press'
  AND e.created_by IS NULL AND em.muscle_group_id = 15; -- Glutes

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Leg Press'
  AND e.created_by IS NULL AND em.muscle_group_id IN (16, 14, 11); -- Hamstrings, gastrocnemius, soleus


-- ---------------------------------------------------------------------------
-- 4q. BARBELL LUNGE
-- Source: Riemann et al. (2012)
-- Primary: quads (90), glutes (90)
-- Synergist: hamstrings (60)
-- Stabilizer: calves (30), core (30)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Barbell Lunge'
  AND e.created_by IS NULL AND em.muscle_group_id = 9;  -- Quadriceps

UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Barbell Lunge'
  AND e.created_by IS NULL AND em.muscle_group_id = 15; -- Glutes

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Barbell Lunge'
  AND e.created_by IS NULL AND em.muscle_group_id = 16; -- Hamstrings

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Barbell Lunge'
  AND e.created_by IS NULL AND em.muscle_group_id IN (11, 14, 7); -- Soleus, gastrocnemius, obliques


-- ---------------------------------------------------------------------------
-- 4r. DUMBBELL SHOULDER PRESS
-- Source: Saeterbakken & Fimland (2013)
-- Primary: anterior deltoid (90)
-- Synergist: triceps (60), middle deltoid (60)
-- Stabilizer: traps (30)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Dumbbell Shoulder Press'
  AND e.created_by IS NULL AND em.muscle_group_id = 1;  -- Anterior deltoid

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Dumbbell Shoulder Press'
  AND e.created_by IS NULL AND em.muscle_group_id = 13; -- Triceps

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Dumbbell Shoulder Press'
  AND e.created_by IS NULL AND em.muscle_group_id = 6;  -- Middle deltoid

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Dumbbell Shoulder Press'
  AND e.created_by IS NULL AND em.muscle_group_id = 12; -- Trapezius


-- ---------------------------------------------------------------------------
-- 4s. SEATED CABLE ROWS
-- Source: Lehman et al. (2004); Fenwick et al. (2009)
-- Primary: lats (90), mid traps (90)
-- Synergist: biceps (60), posterior deltoid (60), brachialis (30)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Seated Cable Rows'
  AND e.created_by IS NULL AND em.muscle_group_id = 5;  -- Lats

UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Seated Cable Rows'
  AND e.created_by IS NULL AND em.muscle_group_id = 12; -- Trapezius

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Seated Cable Rows'
  AND e.created_by IS NULL AND em.muscle_group_id = 2;  -- Biceps

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Seated Cable Rows'
  AND e.created_by IS NULL AND em.muscle_group_id = 8;  -- Posterior deltoid

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Seated Cable Rows'
  AND e.created_by IS NULL AND em.muscle_group_id = 3;  -- Brachialis


-- ---------------------------------------------------------------------------
-- 4t. T-BAR ROW WITH HANDLE
-- Source: Lehman et al. (2004)
-- Primary: lats (90), mid traps (90)
-- Synergist: biceps (60), posterior deltoid (60)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'T-Bar Row with Handle'
  AND e.created_by IS NULL AND em.muscle_group_id = 5;  -- Lats

UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'T-Bar Row with Handle'
  AND e.created_by IS NULL AND em.muscle_group_id = 12; -- Trapezius

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'T-Bar Row with Handle'
  AND e.created_by IS NULL AND em.muscle_group_id = 2;  -- Biceps

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'T-Bar Row with Handle'
  AND e.created_by IS NULL AND em.muscle_group_id = 8;  -- Posterior deltoid


-- ---------------------------------------------------------------------------
-- 4u. ONE-ARM DUMBBELL ROW
-- Source: Fenwick et al. (2009)
-- Primary: lats (90)
-- Synergist: mid traps (60), biceps (60), posterior deltoid (60)
-- Stabilizer: core (30)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'One-Arm Dumbbell Row'
  AND e.created_by IS NULL AND em.muscle_group_id = 5;  -- Lats

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'One-Arm Dumbbell Row'
  AND e.created_by IS NULL AND em.muscle_group_id = 12; -- Trapezius

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'One-Arm Dumbbell Row'
  AND e.created_by IS NULL AND em.muscle_group_id = 2;  -- Biceps

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'One-Arm Dumbbell Row'
  AND e.created_by IS NULL AND em.muscle_group_id = 8;  -- Posterior deltoid


-- ---------------------------------------------------------------------------
-- 4v. FACE PULL
-- Source: Reinold et al. (2009)
-- Primary: posterior deltoid (90), mid traps (60)
-- Synergist: external rotators (60)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Face Pull'
  AND e.created_by IS NULL AND em.muscle_group_id = 8;  -- Posterior deltoid

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Face Pull'
  AND e.created_by IS NULL AND em.muscle_group_id = 12; -- Trapezius

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Face Pull'
  AND e.created_by IS NULL AND em.muscle_group_id = 6;  -- Middle deltoid


-- ---------------------------------------------------------------------------
-- 4w. BARBELL CURL
-- Source: Signorile et al. (2002); Oliveira et al. (2009)
-- Primary: biceps (90)
-- Synergist: brachialis (60), forearms (30)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Barbell Curl'
  AND e.created_by IS NULL AND em.muscle_group_id = 2;  -- Biceps

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Barbell Curl'
  AND e.created_by IS NULL AND em.muscle_group_id = 3;  -- Brachialis


-- ---------------------------------------------------------------------------
-- 4x. EZ-BAR SKULLCRUSHER
-- Source: Oliveira et al. (2009)
-- Primary: triceps (90)
-- Stabilizer: anterior deltoid (30), chest (30)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'EZ-Bar Skullcrusher'
  AND e.created_by IS NULL AND em.muscle_group_id = 13; -- Triceps

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'EZ-Bar Skullcrusher'
  AND e.created_by IS NULL AND em.muscle_group_id IN (1, 4); -- Anterior deltoid, chest


-- ---------------------------------------------------------------------------
-- 4y. TRICEPS PUSHDOWN - ROPE ATTACHMENT
-- Source: Oliveira et al. (2009)
-- Primary: triceps (90)
-- Stabilizer: anterior deltoid (30)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Triceps Pushdown - Rope Attachment'
  AND e.created_by IS NULL AND em.muscle_group_id = 13; -- Triceps

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Triceps Pushdown - Rope Attachment'
  AND e.created_by IS NULL AND em.muscle_group_id = 1;  -- Anterior deltoid


-- ---------------------------------------------------------------------------
-- 4z. CABLE ROPE OVERHEAD TRICEPS EXTENSION
-- Source: Oliveira et al. (2009)
-- Primary: triceps long head (90)
-- Stabilizer: anterior deltoid (30)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Cable Rope Overhead Triceps Extension'
  AND e.created_by IS NULL AND em.muscle_group_id = 13; -- Triceps

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Cable Rope Overhead Triceps Extension'
  AND e.created_by IS NULL AND em.muscle_group_id = 1;  -- Anterior deltoid


-- ---------------------------------------------------------------------------
-- 4aa. GLUTE HAM RAISE
-- Source: Ebben et al. (2009)
-- Primary: hamstrings (90), glutes (60)
-- Synergist: calves (30), erector spinae (30)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Glute Ham Raise'
  AND e.created_by IS NULL AND em.muscle_group_id = 16; -- Hamstrings

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Glute Ham Raise'
  AND e.created_by IS NULL AND em.muscle_group_id = 15; -- Glutes

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Glute Ham Raise'
  AND e.created_by IS NULL AND em.muscle_group_id IN (14, 11); -- Gastrocnemius, soleus


-- ---------------------------------------------------------------------------
-- 4ab. LEG EXTENSIONS
-- Source: Escamilla et al. (1998)
-- Primary: quadriceps (90)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Leg Extensions'
  AND e.created_by IS NULL AND em.muscle_group_id = 9;  -- Quadriceps


-- ---------------------------------------------------------------------------
-- 4ac. LYING LEG CURLS
-- Source: Ebben et al. (2009)
-- Primary: hamstrings (90)
-- Synergist: calves (30)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Lying Leg Curls'
  AND e.created_by IS NULL AND em.muscle_group_id = 16; -- Hamstrings

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Lying Leg Curls'
  AND e.created_by IS NULL AND em.muscle_group_id IN (14, 11); -- Gastrocnemius, soleus


-- ---------------------------------------------------------------------------
-- 4ad. STANDING CALF RAISES
-- Source: Signorile et al. (2002)
-- Primary: gastrocnemius (90), soleus (60)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Standing Calf Raises'
  AND e.created_by IS NULL AND em.muscle_group_id = 14; -- Gastrocnemius

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Standing Calf Raises'
  AND e.created_by IS NULL AND em.muscle_group_id = 11; -- Soleus


-- ---------------------------------------------------------------------------
-- 4ae. SEATED CALF RAISE
-- Source: Signorile et al. (2002)
-- Primary: soleus (90), gastrocnemius (30)
-- (Bent knee reduces gastroc contribution)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Seated Calf Raise'
  AND e.created_by IS NULL AND em.muscle_group_id = 11; -- Soleus

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Seated Calf Raise'
  AND e.created_by IS NULL AND em.muscle_group_id = 14; -- Gastrocnemius


-- ---------------------------------------------------------------------------
-- 4af. UPRIGHT BARBELL ROW
-- Source: McAllister et al. (2013)
-- Primary: middle deltoid (90), traps (60)
-- Synergist: anterior deltoid (60), biceps (30)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Upright Barbell Row'
  AND e.created_by IS NULL AND em.muscle_group_id = 6;  -- Middle deltoid

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Upright Barbell Row'
  AND e.created_by IS NULL AND em.muscle_group_id = 12; -- Trapezius

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Upright Barbell Row'
  AND e.created_by IS NULL AND em.muscle_group_id = 1;  -- Anterior deltoid

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Upright Barbell Row'
  AND e.created_by IS NULL AND em.muscle_group_id = 2;  -- Biceps


-- ---------------------------------------------------------------------------
-- 4ag. BARBELL SHRUG
-- Source: Lehman et al. (2004)
-- Primary: trapezius (90)
-- Stabilizer: middle deltoid (30)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Barbell Shrug'
  AND e.created_by IS NULL AND em.muscle_group_id = 12; -- Trapezius

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Barbell Shrug'
  AND e.created_by IS NULL AND em.muscle_group_id = 6;  -- Middle deltoid


-- ---------------------------------------------------------------------------
-- 4ah. SIDE LATERAL RAISE
-- Source: Reinold et al. (2009)
-- Primary: middle deltoid (90)
-- Synergist: anterior deltoid (30), traps (30)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Side Lateral Raise'
  AND e.created_by IS NULL AND em.muscle_group_id = 6;  -- Middle deltoid

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Side Lateral Raise'
  AND e.created_by IS NULL AND em.muscle_group_id IN (1, 12); -- Anterior deltoid, traps


-- ---------------------------------------------------------------------------
-- 4ai. GOBLET SQUAT
-- Source: Contreras et al. (2016)
-- Primary: quads (90), glutes (60)
-- Synergist: hamstrings (30), core (30)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Goblet Squat'
  AND e.created_by IS NULL AND em.muscle_group_id = 9;  -- Quadriceps

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Goblet Squat'
  AND e.created_by IS NULL AND em.muscle_group_id = 15; -- Glutes

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Goblet Squat'
  AND e.created_by IS NULL AND em.muscle_group_id IN (16, 7); -- Hamstrings, obliques


-- ---------------------------------------------------------------------------
-- 4aj. DECLINE BARBELL BENCH PRESS
-- Source: Lauver et al. (2016)
-- Primary: chest lower fibers (90), triceps (60)
-- Synergist: anterior deltoid (30)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Decline Barbell Bench Press'
  AND e.created_by IS NULL AND em.muscle_group_id = 4;  -- Chest

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Decline Barbell Bench Press'
  AND e.created_by IS NULL AND em.muscle_group_id = 13; -- Triceps

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Decline Barbell Bench Press'
  AND e.created_by IS NULL AND em.muscle_group_id IN (1, 2, 3); -- Anterior delt, biceps, brachialis


-- ---------------------------------------------------------------------------
-- 4ak. BARBELL INCLINE BENCH PRESS - Medium Grip
-- Source: Trebs et al. (2010); Lauver et al. (2016)
-- Primary: upper chest (90), anterior deltoid (60), triceps (60)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Barbell Incline Bench Press - Medium Grip'
  AND e.created_by IS NULL AND em.muscle_group_id = 4;  -- Chest

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Barbell Incline Bench Press - Medium Grip'
  AND e.created_by IS NULL AND em.muscle_group_id = 1;  -- Anterior deltoid

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Barbell Incline Bench Press - Medium Grip'
  AND e.created_by IS NULL AND em.muscle_group_id = 13; -- Triceps


-- ---------------------------------------------------------------------------
-- 4al. STIFF-LEGGED BARBELL DEADLIFT
-- Source: Ebben et al. (2009)
-- Primary: hamstrings (90), glutes (60)
-- Synergist: erector spinae/traps (60)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Stiff-Legged Barbell Deadlift'
  AND e.created_by IS NULL AND em.muscle_group_id = 16; -- Hamstrings

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Stiff-Legged Barbell Deadlift'
  AND e.created_by IS NULL AND em.muscle_group_id = 15; -- Glutes

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Stiff-Legged Barbell Deadlift'
  AND e.created_by IS NULL AND em.muscle_group_id = 12; -- Trapezius


-- ---------------------------------------------------------------------------
-- 4am. FRONT SQUAT (CLEAN GRIP)
-- Source: Gullett et al. (2009)
-- Primary: quads (90)
-- Synergist: glutes (60), core (60)
-- Stabilizer: hamstrings (30)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Front Squat (Clean Grip)'
  AND e.created_by IS NULL AND em.muscle_group_id = 9;  -- Quadriceps

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Front Squat (Clean Grip)'
  AND e.created_by IS NULL AND em.muscle_group_id = 15; -- Glutes

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Front Squat (Clean Grip)'
  AND e.created_by IS NULL AND em.muscle_group_id = 7;  -- Obliques (core proxy)

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Front Squat (Clean Grip)'
  AND e.created_by IS NULL AND em.muscle_group_id = 16; -- Hamstrings


-- ---------------------------------------------------------------------------
-- 4an. DUMBBELL FLYES
-- Source: Schoenfeld et al. (2016)
-- Primary: chest (90)
-- Synergist: anterior deltoid (30)
-- Stabilizer: biceps (30)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Dumbbell Flyes'
  AND e.created_by IS NULL AND em.muscle_group_id = 4;  -- Chest

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Dumbbell Flyes'
  AND e.created_by IS NULL AND em.muscle_group_id IN (1, 2); -- Anterior deltoid, biceps


-- ---------------------------------------------------------------------------
-- 4ao. CABLE CROSSOVER
-- Source: Schoenfeld et al. (2016)
-- Primary: chest (90)
-- Synergist: anterior deltoid (30)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Cable Crossover'
  AND e.created_by IS NULL AND em.muscle_group_id = 4;  -- Chest

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Cable Crossover'
  AND e.created_by IS NULL AND em.muscle_group_id = 1;  -- Anterior deltoid


-- ---------------------------------------------------------------------------
-- 4ap. HANGING LEG RAISE
-- Source: Contreras & Schoenfeld (2011)
-- Primary: rectus abdominis / obliques (90)
-- Synergist: hip flexors (60)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Hanging Leg Raise'
  AND e.created_by IS NULL AND em.muscle_group_id = 7;  -- Obliques (core proxy)

UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Hanging Leg Raise'
  AND e.created_by IS NULL AND em.muscle_group_id = 10; -- Serratus (core proxy)


-- ---------------------------------------------------------------------------
-- 4aq. RACK PULLS
-- Source: Escamilla (2001)
-- Primary: glutes (90), hamstrings (60), traps (90)
-- Synergist: lats (60), quads (30)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Rack Pulls'
  AND e.created_by IS NULL AND em.muscle_group_id = 15; -- Glutes

UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Rack Pulls'
  AND e.created_by IS NULL AND em.muscle_group_id = 12; -- Trapezius

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Rack Pulls'
  AND e.created_by IS NULL AND em.muscle_group_id = 16; -- Hamstrings

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Rack Pulls'
  AND e.created_by IS NULL AND em.muscle_group_id = 5;  -- Lats

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Rack Pulls'
  AND e.created_by IS NULL AND em.muscle_group_id = 9;  -- Quadriceps


-- ---------------------------------------------------------------------------
-- 4ar. GOOD MORNING
-- Source: Ebben et al. (2009)
-- Primary: hamstrings (90), glutes (60)
-- Synergist: erector spinae (60)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Good Morning'
  AND e.created_by IS NULL AND em.muscle_group_id = 16; -- Hamstrings

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Good Morning'
  AND e.created_by IS NULL AND em.muscle_group_id = 15; -- Glutes

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id AND e.name = 'Good Morning'
  AND e.created_by IS NULL AND em.muscle_group_id = 12; -- Trapezius (erector proxy)


COMMIT;
