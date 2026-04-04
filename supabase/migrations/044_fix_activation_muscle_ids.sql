-- Migration 044: Fix Hardcoded muscle_group_id Errors from Migration 020
--
-- CRITICAL DATA INTEGRITY FIX
--
-- Migration 020_seed_enrichment.sql used hardcoded muscle_group_id values that
-- do NOT match the actual IDs from supabase/seed/001_muscle_groups.sql.
-- The author assumed a sequential numbering scheme; the actual IDs come from
-- the wger fitness database and have gaps/different ordering.
--
-- Actual mapping (seed/001_muscle_groups.sql):
--   1=biceps, 2=shoulders, 3=triceps, 4=chest, 5=forearms,
--   (no 6), 7=calves, 8=glutes, 9=traps, 10=abs, 11=hamstrings,
--   12=lats, 13=lower_back, 14=neck, 15=quadriceps, 16=adductors
--
-- What migration 020 assumed (WRONG):
--   1="anterior deltoid", 2="biceps", 3="brachialis", 4="chest",
--   5="lats", 6="middle deltoid", 7="obliques", 8="posterior deltoid",
--   9="quadriceps", 10="serratus", 11="soleus", 12="trapezius",
--   13="triceps", 14="gastrocnemius", 15="glutes", 16="hamstrings"
--
-- This migration:
--   1. Deletes ALL activation_percent data inserted by migration 020
--      (identified by the specific exercise names + seed-only filter)
--   2. Re-inserts with CORRECT muscle_group_id values using name-based lookups
--   3. Is idempotent (safe to run multiple times)
--
-- NOTE: Later migrations (037, 040, 041) used name-based muscle lookups and
-- are NOT affected by this bug. Their data is preserved. This migration only
-- touches the specific exercises from migration 020's section 4 (4a-4ar).

BEGIN;

-- =============================================================================
-- STEP 1: Reset activation_percent for all exercises touched by migration 020
-- =============================================================================
-- Migration 020 section 4 set activation_percent on these specific seed exercises.
-- We null out activation_percent and reset is_primary to let step 2 re-set them.
-- We scope to created_by IS NULL (seed exercises only).

UPDATE exercise_muscles em
SET activation_percent = NULL, is_primary = false
FROM exercises e
WHERE e.id = em.exercise_id
  AND e.created_by IS NULL
  AND e.name IN (
    'Barbell Bench Press - Medium Grip',
    'Barbell Deadlift',
    'Barbell Full Squat',
    'Barbell Shoulder Press',
    'Incline Dumbbell Press',
    'Dumbbell Bench Press',
    'Close-Grip Barbell Bench Press',
    'Bent Over Barbell Row',
    'Wide-Grip Lat Pulldown',
    'Chin-Up',
    'Dips - Chest Version',
    'Dips - Triceps Version',
    'Barbell Hip Thrust',
    'Romanian Deadlift',
    'Sumo Deadlift',
    'Leg Press',
    'Barbell Lunge',
    'Dumbbell Shoulder Press',
    'Seated Cable Rows',
    'T-Bar Row with Handle',
    'One-Arm Dumbbell Row',
    'Face Pull',
    'Barbell Curl',
    'EZ-Bar Skullcrusher',
    'Triceps Pushdown - Rope Attachment',
    'Cable Rope Overhead Triceps Extension',
    'Glute Ham Raise',
    'Leg Extensions',
    'Lying Leg Curls',
    'Standing Calf Raises',
    'Seated Calf Raise',
    'Upright Barbell Row',
    'Barbell Shrug',
    'Side Lateral Raise',
    'Goblet Squat',
    'Decline Barbell Bench Press',
    'Barbell Incline Bench Press - Medium Grip',
    'Stiff-Legged Barbell Deadlift',
    'Front Squat (Clean Grip)',
    'Dumbbell Flyes',
    'Cable Crossover',
    'Hanging Leg Raise',
    'Rack Pulls',
    'Good Morning'
  );


-- =============================================================================
-- STEP 2: Re-insert CORRECT activation data using name-based muscle lookups
-- =============================================================================
-- All lookups use muscle_groups.name (text match) instead of hardcoded IDs.
-- This is immune to ID ordering issues.


-- ---------------------------------------------------------------------------
-- 4a. BARBELL BENCH PRESS - Medium Grip
-- Primary: chest (90), Synergist: shoulders/ant delt (60), triceps (60)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Barbell Bench Press - Medium Grip' AND e.created_by IS NULL
  AND mg.name = 'chest';

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Barbell Bench Press - Medium Grip' AND e.created_by IS NULL
  AND mg.name = 'shoulders';

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Barbell Bench Press - Medium Grip' AND e.created_by IS NULL
  AND mg.name = 'triceps';

-- biceps stabilizer (minor contribution in bench press)
UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Barbell Bench Press - Medium Grip' AND e.created_by IS NULL
  AND mg.name = 'biceps';


-- ---------------------------------------------------------------------------
-- 4b. BARBELL DEADLIFT
-- Primary: glutes (90), hamstrings (90), lower back (90)
-- Synergist: quadriceps (60), lats (60), traps (60)
-- Stabilizer: forearms/grip (30)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Barbell Deadlift' AND e.created_by IS NULL
  AND mg.name = 'glutes';

UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Barbell Deadlift' AND e.created_by IS NULL
  AND mg.name = 'hamstrings';

UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Barbell Deadlift' AND e.created_by IS NULL
  AND mg.name = 'lower back';

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Barbell Deadlift' AND e.created_by IS NULL
  AND mg.name = 'quadriceps';

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Barbell Deadlift' AND e.created_by IS NULL
  AND mg.name = 'lats';

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Barbell Deadlift' AND e.created_by IS NULL
  AND mg.name = 'traps';

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Barbell Deadlift' AND e.created_by IS NULL
  AND mg.name = 'forearms';


-- ---------------------------------------------------------------------------
-- 4c. BARBELL FULL SQUAT
-- Primary: quadriceps (90), glutes (90)
-- Synergist: hamstrings (60), adductors (60)
-- Stabilizer: calves (30), lower back (30)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Barbell Full Squat' AND e.created_by IS NULL
  AND mg.name = 'quadriceps';

UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Barbell Full Squat' AND e.created_by IS NULL
  AND mg.name = 'glutes';

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Barbell Full Squat' AND e.created_by IS NULL
  AND mg.name = 'hamstrings';

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Barbell Full Squat' AND e.created_by IS NULL
  AND mg.name = 'adductors';

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Barbell Full Squat' AND e.created_by IS NULL
  AND mg.name = 'calves';

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Barbell Full Squat' AND e.created_by IS NULL
  AND mg.name = 'lower back';


-- ---------------------------------------------------------------------------
-- 4d. BARBELL SHOULDER PRESS
-- Primary: shoulders (90)
-- Synergist: triceps (60)
-- Stabilizer: chest (30), traps (30)
-- Note: wger muscle_groups has one "shoulders" entry (id=2, deltoideus).
--       There is no separate "middle deltoid" row (id=6 does not exist).
--       We use "shoulders" for all deltoid contributions.
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Barbell Shoulder Press' AND e.created_by IS NULL
  AND mg.name = 'shoulders';

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Barbell Shoulder Press' AND e.created_by IS NULL
  AND mg.name = 'triceps';

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Barbell Shoulder Press' AND e.created_by IS NULL
  AND mg.name = 'chest';

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Barbell Shoulder Press' AND e.created_by IS NULL
  AND mg.name = 'traps';


-- ---------------------------------------------------------------------------
-- 4e. INCLINE DUMBBELL PRESS
-- Primary: chest (90), Synergist: shoulders (60), triceps (60)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Incline Dumbbell Press' AND e.created_by IS NULL
  AND mg.name = 'chest';

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Incline Dumbbell Press' AND e.created_by IS NULL
  AND mg.name = 'shoulders';

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Incline Dumbbell Press' AND e.created_by IS NULL
  AND mg.name = 'triceps';


-- ---------------------------------------------------------------------------
-- 4f. DUMBBELL BENCH PRESS
-- Primary: chest (90), Synergist: shoulders (60), triceps (60)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Dumbbell Bench Press' AND e.created_by IS NULL
  AND mg.name = 'chest';

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Dumbbell Bench Press' AND e.created_by IS NULL
  AND mg.name = 'shoulders';

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Dumbbell Bench Press' AND e.created_by IS NULL
  AND mg.name = 'triceps';


-- ---------------------------------------------------------------------------
-- 4g. CLOSE-GRIP BARBELL BENCH PRESS
-- Primary: triceps (90), Synergist: chest (60), Stabilizer: shoulders (30)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Close-Grip Barbell Bench Press' AND e.created_by IS NULL
  AND mg.name = 'triceps';

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Close-Grip Barbell Bench Press' AND e.created_by IS NULL
  AND mg.name = 'chest';

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Close-Grip Barbell Bench Press' AND e.created_by IS NULL
  AND mg.name IN ('shoulders', 'biceps');


-- ---------------------------------------------------------------------------
-- 4h. BENT OVER BARBELL ROW
-- Primary: lats (90), traps (90)
-- Synergist: shoulders/post delt (60), biceps (60)
-- Stabilizer: forearms (30), lower back (30)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Bent Over Barbell Row' AND e.created_by IS NULL
  AND mg.name = 'lats';

UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Bent Over Barbell Row' AND e.created_by IS NULL
  AND mg.name = 'traps';

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Bent Over Barbell Row' AND e.created_by IS NULL
  AND mg.name = 'shoulders';

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Bent Over Barbell Row' AND e.created_by IS NULL
  AND mg.name = 'biceps';

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Bent Over Barbell Row' AND e.created_by IS NULL
  AND mg.name IN ('forearms', 'lower back');


-- ---------------------------------------------------------------------------
-- 4i. WIDE-GRIP LAT PULLDOWN
-- Primary: lats (90)
-- Synergist: biceps (60), shoulders/post delt (60)
-- Stabilizer: traps (30)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Wide-Grip Lat Pulldown' AND e.created_by IS NULL
  AND mg.name = 'lats';

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Wide-Grip Lat Pulldown' AND e.created_by IS NULL
  AND mg.name = 'biceps';

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Wide-Grip Lat Pulldown' AND e.created_by IS NULL
  AND mg.name = 'shoulders';

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Wide-Grip Lat Pulldown' AND e.created_by IS NULL
  AND mg.name = 'traps';


-- ---------------------------------------------------------------------------
-- 4j. CHIN-UP
-- Primary: lats (90), biceps (90)
-- Synergist: shoulders (60), traps (60)
-- Stabilizer: forearms (30)
-- Note: Original had "brachialis" as synergist. wger has no brachialis row;
--       forearms (brachioradialis) is the closest proxy.
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Chin-Up' AND e.created_by IS NULL
  AND mg.name = 'lats';

UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Chin-Up' AND e.created_by IS NULL
  AND mg.name = 'biceps';

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Chin-Up' AND e.created_by IS NULL
  AND mg.name = 'shoulders';

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Chin-Up' AND e.created_by IS NULL
  AND mg.name = 'traps';

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Chin-Up' AND e.created_by IS NULL
  AND mg.name = 'forearms';


-- ---------------------------------------------------------------------------
-- 4k. DIPS - CHEST VERSION
-- Primary: chest (90), triceps (90), Synergist: shoulders (60)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Dips - Chest Version' AND e.created_by IS NULL
  AND mg.name = 'chest';

UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Dips - Chest Version' AND e.created_by IS NULL
  AND mg.name = 'triceps';

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Dips - Chest Version' AND e.created_by IS NULL
  AND mg.name = 'shoulders';


-- ---------------------------------------------------------------------------
-- 4l. DIPS - TRICEPS VERSION
-- Primary: triceps (90), Synergist: chest (60), Stabilizer: shoulders (30)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Dips - Triceps Version' AND e.created_by IS NULL
  AND mg.name = 'triceps';

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Dips - Triceps Version' AND e.created_by IS NULL
  AND mg.name = 'chest';

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Dips - Triceps Version' AND e.created_by IS NULL
  AND mg.name = 'shoulders';


-- ---------------------------------------------------------------------------
-- 4m. BARBELL HIP THRUST
-- Primary: glutes (90)
-- Synergist: hamstrings (60)
-- Stabilizer: quadriceps (30)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Barbell Hip Thrust' AND e.created_by IS NULL
  AND mg.name = 'glutes';

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Barbell Hip Thrust' AND e.created_by IS NULL
  AND mg.name = 'hamstrings';

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Barbell Hip Thrust' AND e.created_by IS NULL
  AND mg.name = 'quadriceps';


-- ---------------------------------------------------------------------------
-- 4n. ROMANIAN DEADLIFT
-- Primary: hamstrings (90), glutes (90)
-- Synergist: lower back (60)
-- Stabilizer: lats (30), forearms (30)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Romanian Deadlift' AND e.created_by IS NULL
  AND mg.name = 'hamstrings';

UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Romanian Deadlift' AND e.created_by IS NULL
  AND mg.name = 'glutes';

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Romanian Deadlift' AND e.created_by IS NULL
  AND mg.name = 'lower back';

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Romanian Deadlift' AND e.created_by IS NULL
  AND mg.name IN ('lats', 'forearms');


-- ---------------------------------------------------------------------------
-- 4o. SUMO DEADLIFT
-- Primary: quadriceps (90), glutes (90)
-- Synergist: hamstrings (60), traps (60), adductors (60)
-- Stabilizer: lats (30)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Sumo Deadlift' AND e.created_by IS NULL
  AND mg.name = 'quadriceps';

UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Sumo Deadlift' AND e.created_by IS NULL
  AND mg.name = 'glutes';

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Sumo Deadlift' AND e.created_by IS NULL
  AND mg.name = 'hamstrings';

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Sumo Deadlift' AND e.created_by IS NULL
  AND mg.name = 'traps';

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Sumo Deadlift' AND e.created_by IS NULL
  AND mg.name = 'adductors';

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Sumo Deadlift' AND e.created_by IS NULL
  AND mg.name = 'lats';


-- ---------------------------------------------------------------------------
-- 4p. LEG PRESS
-- Primary: quadriceps (90), Synergist: glutes (60)
-- Stabilizer: hamstrings (30), calves (30)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Leg Press' AND e.created_by IS NULL
  AND mg.name = 'quadriceps';

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Leg Press' AND e.created_by IS NULL
  AND mg.name = 'glutes';

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Leg Press' AND e.created_by IS NULL
  AND mg.name IN ('hamstrings', 'calves');


-- ---------------------------------------------------------------------------
-- 4q. BARBELL LUNGE
-- Primary: quadriceps (90), glutes (90)
-- Synergist: hamstrings (60)
-- Stabilizer: calves (30), lower back (30)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Barbell Lunge' AND e.created_by IS NULL
  AND mg.name = 'quadriceps';

UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Barbell Lunge' AND e.created_by IS NULL
  AND mg.name = 'glutes';

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Barbell Lunge' AND e.created_by IS NULL
  AND mg.name = 'hamstrings';

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Barbell Lunge' AND e.created_by IS NULL
  AND mg.name IN ('calves', 'lower back');


-- ---------------------------------------------------------------------------
-- 4r. DUMBBELL SHOULDER PRESS
-- Primary: shoulders (90)
-- Synergist: triceps (60)
-- Stabilizer: traps (30)
-- Note: No separate "middle deltoid" row exists (id=6 is missing).
--       "shoulders" (id=2) covers all deltoid heads.
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Dumbbell Shoulder Press' AND e.created_by IS NULL
  AND mg.name = 'shoulders';

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Dumbbell Shoulder Press' AND e.created_by IS NULL
  AND mg.name = 'triceps';

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Dumbbell Shoulder Press' AND e.created_by IS NULL
  AND mg.name = 'traps';


-- ---------------------------------------------------------------------------
-- 4s. SEATED CABLE ROWS
-- Primary: lats (90), traps (90)
-- Synergist: biceps (60), shoulders/post delt (60)
-- Stabilizer: forearms (30)
-- Note: Original had "brachialis" at id=3; that is actually triceps. Forearms
--       is the correct proxy for brachialis/brachioradialis in this table.
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Seated Cable Rows' AND e.created_by IS NULL
  AND mg.name = 'lats';

UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Seated Cable Rows' AND e.created_by IS NULL
  AND mg.name = 'traps';

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Seated Cable Rows' AND e.created_by IS NULL
  AND mg.name = 'biceps';

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Seated Cable Rows' AND e.created_by IS NULL
  AND mg.name = 'shoulders';

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Seated Cable Rows' AND e.created_by IS NULL
  AND mg.name = 'forearms';


-- ---------------------------------------------------------------------------
-- 4t. T-BAR ROW WITH HANDLE
-- Primary: lats (90), traps (90)
-- Synergist: biceps (60), shoulders/post delt (60)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'T-Bar Row with Handle' AND e.created_by IS NULL
  AND mg.name = 'lats';

UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'T-Bar Row with Handle' AND e.created_by IS NULL
  AND mg.name = 'traps';

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'T-Bar Row with Handle' AND e.created_by IS NULL
  AND mg.name = 'biceps';

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'T-Bar Row with Handle' AND e.created_by IS NULL
  AND mg.name = 'shoulders';


-- ---------------------------------------------------------------------------
-- 4u. ONE-ARM DUMBBELL ROW
-- Primary: lats (90)
-- Synergist: traps (60), biceps (60), shoulders (60)
-- Stabilizer: lower back (30)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'One-Arm Dumbbell Row' AND e.created_by IS NULL
  AND mg.name = 'lats';

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'One-Arm Dumbbell Row' AND e.created_by IS NULL
  AND mg.name = 'traps';

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'One-Arm Dumbbell Row' AND e.created_by IS NULL
  AND mg.name = 'biceps';

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'One-Arm Dumbbell Row' AND e.created_by IS NULL
  AND mg.name = 'shoulders';

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'One-Arm Dumbbell Row' AND e.created_by IS NULL
  AND mg.name = 'lower back';


-- ---------------------------------------------------------------------------
-- 4v. FACE PULL
-- Primary: shoulders/post delt (90), Synergist: traps (60)
-- Stabilizer: biceps (30)
-- Note: Original had "middle deltoid" at id=6 which does not exist.
--       Using "shoulders" (only deltoid row available) + "traps".
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Face Pull' AND e.created_by IS NULL
  AND mg.name = 'shoulders';

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Face Pull' AND e.created_by IS NULL
  AND mg.name = 'traps';

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Face Pull' AND e.created_by IS NULL
  AND mg.name = 'biceps';


-- ---------------------------------------------------------------------------
-- 4w. BARBELL CURL
-- Primary: biceps (90)
-- Synergist: forearms (60)
-- Note: Original had "brachialis" at id=3 (actually triceps). Forearms
--       is the correct proxy for brachialis activation.
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Barbell Curl' AND e.created_by IS NULL
  AND mg.name = 'biceps';

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Barbell Curl' AND e.created_by IS NULL
  AND mg.name = 'forearms';


-- ---------------------------------------------------------------------------
-- 4x. EZ-BAR SKULLCRUSHER
-- Primary: triceps (90)
-- Stabilizer: shoulders (30), chest (30)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'EZ-Bar Skullcrusher' AND e.created_by IS NULL
  AND mg.name = 'triceps';

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'EZ-Bar Skullcrusher' AND e.created_by IS NULL
  AND mg.name IN ('shoulders', 'chest');


-- ---------------------------------------------------------------------------
-- 4y. TRICEPS PUSHDOWN - ROPE ATTACHMENT
-- Primary: triceps (90)
-- Stabilizer: shoulders (30)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Triceps Pushdown - Rope Attachment' AND e.created_by IS NULL
  AND mg.name = 'triceps';

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Triceps Pushdown - Rope Attachment' AND e.created_by IS NULL
  AND mg.name = 'shoulders';


-- ---------------------------------------------------------------------------
-- 4z. CABLE ROPE OVERHEAD TRICEPS EXTENSION
-- Primary: triceps (90)
-- Stabilizer: shoulders (30)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Cable Rope Overhead Triceps Extension' AND e.created_by IS NULL
  AND mg.name = 'triceps';

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Cable Rope Overhead Triceps Extension' AND e.created_by IS NULL
  AND mg.name = 'shoulders';


-- ---------------------------------------------------------------------------
-- 4aa. GLUTE HAM RAISE
-- Primary: hamstrings (90), Synergist: glutes (60)
-- Stabilizer: calves (30)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Glute Ham Raise' AND e.created_by IS NULL
  AND mg.name = 'hamstrings';

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Glute Ham Raise' AND e.created_by IS NULL
  AND mg.name = 'glutes';

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Glute Ham Raise' AND e.created_by IS NULL
  AND mg.name = 'calves';


-- ---------------------------------------------------------------------------
-- 4ab. LEG EXTENSIONS
-- Primary: quadriceps (90)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Leg Extensions' AND e.created_by IS NULL
  AND mg.name = 'quadriceps';


-- ---------------------------------------------------------------------------
-- 4ac. LYING LEG CURLS
-- Primary: hamstrings (90)
-- Stabilizer: calves (30)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Lying Leg Curls' AND e.created_by IS NULL
  AND mg.name = 'hamstrings';

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Lying Leg Curls' AND e.created_by IS NULL
  AND mg.name = 'calves';


-- ---------------------------------------------------------------------------
-- 4ad. STANDING CALF RAISES
-- Primary: calves (90)
-- Note: wger has one "calves" entry (gastrocnemius). No separate soleus row.
--       Original migration referenced id=11 ("soleus") which is actually
--       hamstrings. The single calves row covers the whole calf complex.
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Standing Calf Raises' AND e.created_by IS NULL
  AND mg.name = 'calves';


-- ---------------------------------------------------------------------------
-- 4ae. SEATED CALF RAISE
-- Primary: calves (90)
-- Note: Same as above -- only one calves row exists.
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Seated Calf Raise' AND e.created_by IS NULL
  AND mg.name = 'calves';


-- ---------------------------------------------------------------------------
-- 4af. UPRIGHT BARBELL ROW
-- Primary: shoulders (90), Synergist: traps (60)
-- Stabilizer: biceps (30)
-- Note: Original had "middle deltoid" at id=6 (nonexistent). "shoulders"
--       (id=2) is the only deltoid row available.
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Upright Barbell Row' AND e.created_by IS NULL
  AND mg.name = 'shoulders';

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Upright Barbell Row' AND e.created_by IS NULL
  AND mg.name = 'traps';

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Upright Barbell Row' AND e.created_by IS NULL
  AND mg.name = 'biceps';


-- ---------------------------------------------------------------------------
-- 4ag. BARBELL SHRUG
-- Primary: traps (90)
-- Stabilizer: shoulders (30)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Barbell Shrug' AND e.created_by IS NULL
  AND mg.name = 'traps';

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Barbell Shrug' AND e.created_by IS NULL
  AND mg.name = 'shoulders';


-- ---------------------------------------------------------------------------
-- 4ah. SIDE LATERAL RAISE
-- Primary: shoulders (90)
-- Stabilizer: traps (30)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Side Lateral Raise' AND e.created_by IS NULL
  AND mg.name = 'shoulders';

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Side Lateral Raise' AND e.created_by IS NULL
  AND mg.name = 'traps';


-- ---------------------------------------------------------------------------
-- 4ai. GOBLET SQUAT
-- Primary: quadriceps (90), Synergist: glutes (60)
-- Stabilizer: hamstrings (30), lower back (30)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Goblet Squat' AND e.created_by IS NULL
  AND mg.name = 'quadriceps';

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Goblet Squat' AND e.created_by IS NULL
  AND mg.name = 'glutes';

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Goblet Squat' AND e.created_by IS NULL
  AND mg.name IN ('hamstrings', 'lower back');


-- ---------------------------------------------------------------------------
-- 4aj. DECLINE BARBELL BENCH PRESS
-- Primary: chest (90), Synergist: triceps (60)
-- Stabilizer: shoulders (30)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Decline Barbell Bench Press' AND e.created_by IS NULL
  AND mg.name = 'chest';

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Decline Barbell Bench Press' AND e.created_by IS NULL
  AND mg.name = 'triceps';

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Decline Barbell Bench Press' AND e.created_by IS NULL
  AND mg.name IN ('shoulders', 'biceps');


-- ---------------------------------------------------------------------------
-- 4ak. BARBELL INCLINE BENCH PRESS - Medium Grip
-- Primary: chest (90), Synergist: shoulders (60), triceps (60)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Barbell Incline Bench Press - Medium Grip' AND e.created_by IS NULL
  AND mg.name = 'chest';

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Barbell Incline Bench Press - Medium Grip' AND e.created_by IS NULL
  AND mg.name = 'shoulders';

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Barbell Incline Bench Press - Medium Grip' AND e.created_by IS NULL
  AND mg.name = 'triceps';


-- ---------------------------------------------------------------------------
-- 4al. STIFF-LEGGED BARBELL DEADLIFT
-- Primary: hamstrings (90), Synergist: glutes (60), lower back (60)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Stiff-Legged Barbell Deadlift' AND e.created_by IS NULL
  AND mg.name = 'hamstrings';

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Stiff-Legged Barbell Deadlift' AND e.created_by IS NULL
  AND mg.name = 'glutes';

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Stiff-Legged Barbell Deadlift' AND e.created_by IS NULL
  AND mg.name = 'lower back';


-- ---------------------------------------------------------------------------
-- 4am. FRONT SQUAT (CLEAN GRIP)
-- Primary: quadriceps (90)
-- Synergist: glutes (60), abs (60)
-- Stabilizer: hamstrings (30)
-- Note: Original used id=7 ("obliques") for core -- that is actually calves.
--       Using "abs" (id=10) as the core proxy.
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Front Squat (Clean Grip)' AND e.created_by IS NULL
  AND mg.name = 'quadriceps';

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Front Squat (Clean Grip)' AND e.created_by IS NULL
  AND mg.name = 'glutes';

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Front Squat (Clean Grip)' AND e.created_by IS NULL
  AND mg.name = 'abs';

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Front Squat (Clean Grip)' AND e.created_by IS NULL
  AND mg.name = 'hamstrings';


-- ---------------------------------------------------------------------------
-- 4an. DUMBBELL FLYES
-- Primary: chest (90)
-- Stabilizer: shoulders (30), biceps (30)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Dumbbell Flyes' AND e.created_by IS NULL
  AND mg.name = 'chest';

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Dumbbell Flyes' AND e.created_by IS NULL
  AND mg.name IN ('shoulders', 'biceps');


-- ---------------------------------------------------------------------------
-- 4ao. CABLE CROSSOVER
-- Primary: chest (90)
-- Stabilizer: shoulders (30)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Cable Crossover' AND e.created_by IS NULL
  AND mg.name = 'chest';

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Cable Crossover' AND e.created_by IS NULL
  AND mg.name = 'shoulders';


-- ---------------------------------------------------------------------------
-- 4ap. HANGING LEG RAISE
-- Primary: abs (90)
-- Synergist: hip flexors -- no direct row, but quadriceps (60) is closest
--            proxy for rectus femoris / iliopsoas contribution
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Hanging Leg Raise' AND e.created_by IS NULL
  AND mg.name = 'abs';

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Hanging Leg Raise' AND e.created_by IS NULL
  AND mg.name = 'quadriceps';


-- ---------------------------------------------------------------------------
-- 4aq. RACK PULLS
-- Primary: glutes (90), traps (90)
-- Synergist: hamstrings (60), lats (60)
-- Stabilizer: quadriceps (30)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Rack Pulls' AND e.created_by IS NULL
  AND mg.name = 'glutes';

UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Rack Pulls' AND e.created_by IS NULL
  AND mg.name = 'traps';

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Rack Pulls' AND e.created_by IS NULL
  AND mg.name = 'hamstrings';

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Rack Pulls' AND e.created_by IS NULL
  AND mg.name = 'lats';

UPDATE exercise_muscles em
SET activation_percent = 30, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Rack Pulls' AND e.created_by IS NULL
  AND mg.name = 'quadriceps';


-- ---------------------------------------------------------------------------
-- 4ar. GOOD MORNING
-- Primary: hamstrings (90), Synergist: glutes (60), lower back (60)
-- ---------------------------------------------------------------------------
UPDATE exercise_muscles em
SET activation_percent = 90, is_primary = true
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Good Morning' AND e.created_by IS NULL
  AND mg.name = 'hamstrings';

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Good Morning' AND e.created_by IS NULL
  AND mg.name = 'glutes';

UPDATE exercise_muscles em
SET activation_percent = 60, is_primary = false
FROM exercises e, muscle_groups mg
WHERE e.id = em.exercise_id AND em.muscle_group_id = mg.id
  AND e.name = 'Good Morning' AND e.created_by IS NULL
  AND mg.name = 'lower back';


COMMIT;
