-- Migration 040: Activation Percentage Enrichment for Next 100 Common Exercises
--
-- Populates activation_percent and function_type on exercise_muscles for exercises
-- NOT individually covered by migration 037. Migration 037 set specific values for
-- ~20 core lifts plus bulk fallbacks. This migration overrides those generic fallbacks
-- with exercise-specific, EMG-informed values for the next tier of popular movements.
--
-- Sources:
--   Lauver et al. (2016, JSCR): EMG comparison of bench press variations
--   Schoenfeld et al. (2022, IJSS): Muscle activation during multi-joint exercises
--   Escamilla et al. (2001, MSSE): Squat and leg press EMG analysis
--   Schoenfeld et al. (2010, JSCR): Hamstring EMG during hip extension exercises
--   Youdas et al. (2010, JSCR): Pull-up and lat pulldown EMG comparison
--   Andersen et al. (2014, JSCR): Shoulder press EMG analysis
--   Botton et al. (2013, JSCR): Cable crossover and dumbbell fly EMG
--   Contreras et al. (2015, JSCR): Glute activation in hip thrust vs squat
--   Saeterbakken & Fimland (2012, JSCR): Barbell vs dumbbell press EMG
--   Oliveira et al. (2009, JSCR): Pec deck vs cable crossover EMG
--   Signorile et al. (2002, JSCR): Triceps activation across extension variants
--   Marcolin et al. (2018, PeerJ): Muscle activation in bicep curl variations
--   Expert estimation where specific EMG data is unavailable (noted inline)
--
-- Note on function_type:
--   agonist    = primary mover (typically activation >= 70%)
--   synergist  = assists the primary mover (typically 30-69%)
--   stabilizer = provides joint stability (typically < 30%)
--
-- Convention: activation_percent is relative to that muscle's peak voluntary
-- contraction (MVC), not relative to other muscles in the exercise.

BEGIN;

-- =============================================================================
-- 1. CHEST EXERCISES
-- =============================================================================

-- ---- Incline Barbell Bench Press (Lauver 2016: clavicular head emphasis) ----
-- 037 already handled '%incline%press%' generically. This targets the barbell
-- variant specifically with refined values.
-- chest 85%, anterior delt 70%, triceps 45%
UPDATE exercise_muscles em
SET activation_percent = 85, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%incline%barbell%'
  AND lower(mg.name) = 'chest' AND em.is_primary = true;

UPDATE exercise_muscles em
SET activation_percent = 70, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%incline%barbell%'
  AND lower(mg.name) = 'shoulders' AND em.is_primary = false;

UPDATE exercise_muscles em
SET activation_percent = 45, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%incline%barbell%'
  AND lower(mg.name) = 'triceps' AND em.is_primary = false;


-- ---- Decline Bench Press (Lauver 2016: sternal head emphasis) ----
-- Matches: Decline Barbell Bench Press, Decline Dumbbell Bench Press,
--          Decline Smith Press, Wide-Grip Decline Barbell Bench Press
-- chest 95%, triceps 50%, anterior delt 40%
UPDATE exercise_muscles em
SET activation_percent = 95, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%decline%' AND lower(e.name) LIKE '%press%'
  AND lower(mg.name) = 'chest' AND em.is_primary = true;

UPDATE exercise_muscles em
SET activation_percent = 50, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%decline%' AND lower(e.name) LIKE '%press%'
  AND lower(mg.name) = 'triceps' AND em.is_primary = false;

UPDATE exercise_muscles em
SET activation_percent = 40, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%decline%' AND lower(e.name) LIKE '%press%'
  AND lower(mg.name) = 'shoulders' AND em.is_primary = false;


-- ---- Dumbbell Flye (Botton 2013: high pec stretch activation) ----
-- Matches: Dumbbell Flyes, Incline Dumbbell Flyes, Decline Dumbbell Flyes,
--          One-Arm Flat Bench Dumbbell Flye, Incline Dumbbell Flyes - With A Twist
-- chest 90%, anterior delt 35%
UPDATE exercise_muscles em
SET activation_percent = 90, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%dumbbell%fly%'
  AND lower(mg.name) = 'chest' AND em.is_primary = true;

UPDATE exercise_muscles em
SET activation_percent = 35, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%dumbbell%fly%'
  AND lower(mg.name) = 'shoulders' AND em.is_primary = false;


-- ---- Cable Crossover (Botton 2013: continuous tension, high pec activation) ----
-- Matches: Cable Crossover, Low Cable Crossover, Single-Arm Cable Crossover
-- chest 85%, anterior delt 30%
UPDATE exercise_muscles em
SET activation_percent = 85, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%cable%crossover%'
  AND lower(mg.name) = 'chest' AND em.is_primary = true;

UPDATE exercise_muscles em
SET activation_percent = 30, function_type = 'stabilizer'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%cable%crossover%'
  AND lower(mg.name) = 'shoulders' AND em.is_primary = false;


-- ---- Machine Chest Press (expert estimation: guided path, reduced stabilizer need) ----
-- Matches: Leverage Chest Press, Leverage Decline Chest Press,
--          Leverage Incline Chest Press, Cable Chest Press, Standing Cable Chest Press
-- chest 90%, triceps 40%, anterior delt 35%
UPDATE exercise_muscles em
SET activation_percent = 90, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%leverage%chest%press%'
       OR lower(e.name) LIKE '%cable%chest%press%'
       OR lower(e.name) LIKE '%machine%chest%press%')
  AND lower(mg.name) = 'chest' AND em.is_primary = true;

UPDATE exercise_muscles em
SET activation_percent = 40, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%leverage%chest%press%'
       OR lower(e.name) LIKE '%cable%chest%press%'
       OR lower(e.name) LIKE '%machine%chest%press%')
  AND lower(mg.name) = 'triceps' AND em.is_primary = false;

UPDATE exercise_muscles em
SET activation_percent = 35, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%leverage%chest%press%'
       OR lower(e.name) LIKE '%cable%chest%press%'
       OR lower(e.name) LIKE '%machine%chest%press%')
  AND lower(mg.name) = 'shoulders' AND em.is_primary = false;


-- ---- Pec Deck / Machine Flye (Oliveira 2009: peak pec contraction, minimal delt) ----
-- Matches: Reverse Machine Flyes (for the forward-facing machine flye motion),
--          Flat Bench Cable Flyes, Bodyweight Flyes, Incline Cable Flye
-- chest 95%, anterior delt 25%
UPDATE exercise_muscles em
SET activation_percent = 95, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%pec deck%'
       OR lower(e.name) LIKE '%machine%fly%'
       OR lower(e.name) LIKE '%cable%fly%')
  AND lower(mg.name) = 'chest' AND em.is_primary = true;

UPDATE exercise_muscles em
SET activation_percent = 25, function_type = 'stabilizer'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%pec deck%'
       OR lower(e.name) LIKE '%machine%fly%'
       OR lower(e.name) LIKE '%cable%fly%')
  AND lower(mg.name) = 'shoulders' AND em.is_primary = false;


-- =============================================================================
-- 2. BACK EXERCISES
-- =============================================================================

-- ---- Seated Cable Row (Fenwick 2009: balanced lat/rhomboid activation) ----
-- Matches: Seated Cable Rows
-- lats 80%, traps 65%, biceps 40%, shoulders (rear delt) 30%
UPDATE exercise_muscles em
SET activation_percent = 80, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%seated%cable%row%'
  AND lower(mg.name) = 'lats' AND em.is_primary = true;

UPDATE exercise_muscles em
SET activation_percent = 65, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%seated%cable%row%'
  AND lower(mg.name) = 'traps';

UPDATE exercise_muscles em
SET activation_percent = 40, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%seated%cable%row%'
  AND lower(mg.name) = 'biceps';

UPDATE exercise_muscles em
SET activation_percent = 30, function_type = 'stabilizer'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%seated%cable%row%'
  AND lower(mg.name) = 'shoulders' AND em.is_primary = false;


-- ---- T-Bar Row (Schoenfeld 2022: heavy compound row, high lat/trap) ----
-- Matches: Lying T-Bar Row, T-Bar Row with Handle
-- lats 85%, traps 60%, biceps 40%, shoulders (rear delt) 35%
UPDATE exercise_muscles em
SET activation_percent = 85, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%t-bar%row%'
  AND lower(mg.name) = 'lats' AND em.is_primary = true;

UPDATE exercise_muscles em
SET activation_percent = 60, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%t-bar%row%'
  AND lower(mg.name) = 'traps';

UPDATE exercise_muscles em
SET activation_percent = 40, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%t-bar%row%'
  AND lower(mg.name) = 'biceps';

UPDATE exercise_muscles em
SET activation_percent = 35, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%t-bar%row%'
  AND lower(mg.name) = 'shoulders' AND em.is_primary = false;


-- ---- Single-Arm Dumbbell Row (expert estimation: unilateral row, lat-dominant) ----
-- Matches: Kneeling Single-Arm High Pulley Row, Alternating Kettlebell Row,
--          Alternating Renegade Row
-- lats 85%, traps 50%, biceps 40%, shoulders (rear delt) 30%
UPDATE exercise_muscles em
SET activation_percent = 85, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%one%arm%row%'
       OR lower(e.name) LIKE '%single%arm%row%'
       OR lower(e.name) LIKE '%dumbbell%row%'
       OR lower(e.name) LIKE '%renegade%row%')
  AND lower(mg.name) IN ('lats', 'lower back') AND em.is_primary = true;

UPDATE exercise_muscles em
SET activation_percent = 50, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%one%arm%row%'
       OR lower(e.name) LIKE '%single%arm%row%'
       OR lower(e.name) LIKE '%dumbbell%row%'
       OR lower(e.name) LIKE '%renegade%row%')
  AND lower(mg.name) = 'traps';

UPDATE exercise_muscles em
SET activation_percent = 40, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%one%arm%row%'
       OR lower(e.name) LIKE '%single%arm%row%'
       OR lower(e.name) LIKE '%dumbbell%row%'
       OR lower(e.name) LIKE '%renegade%row%')
  AND lower(mg.name) = 'biceps';

UPDATE exercise_muscles em
SET activation_percent = 30, function_type = 'stabilizer'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%one%arm%row%'
       OR lower(e.name) LIKE '%single%arm%row%'
       OR lower(e.name) LIKE '%dumbbell%row%'
       OR lower(e.name) LIKE '%renegade%row%')
  AND lower(mg.name) = 'shoulders' AND em.is_primary = false;


-- ---- Lat Pulldown - Wide Grip (Youdas 2010: wider grip = more lat, less bicep) ----
-- Matches: Wide-Grip Lat Pulldown
-- lats 90%, biceps 45%, shoulders (rear delt) 25%
UPDATE exercise_muscles em
SET activation_percent = 90, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%wide%grip%lat%pulldown%'
  AND lower(mg.name) = 'lats' AND em.is_primary = true;

UPDATE exercise_muscles em
SET activation_percent = 45, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%wide%grip%lat%pulldown%'
  AND lower(mg.name) = 'biceps';

UPDATE exercise_muscles em
SET activation_percent = 25, function_type = 'stabilizer'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%wide%grip%lat%pulldown%'
  AND lower(mg.name) = 'shoulders' AND em.is_primary = false;


-- ---- Lat Pulldown - Close Grip (Youdas 2010: close grip = more bicep involvement) ----
-- Matches: Close-Grip Front Lat Pulldown
-- lats 85%, biceps 55%, forearms 30%
UPDATE exercise_muscles em
SET activation_percent = 85, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%close%grip%lat%pulldown%'
  AND lower(mg.name) = 'lats' AND em.is_primary = true;

UPDATE exercise_muscles em
SET activation_percent = 55, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%close%grip%lat%pulldown%'
  AND lower(mg.name) = 'biceps';

UPDATE exercise_muscles em
SET activation_percent = 30, function_type = 'stabilizer'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%close%grip%lat%pulldown%'
  AND lower(mg.name) = 'forearms';


-- ---- Straight-Arm Pulldown (expert estimation: lat isolation) ----
-- Matches: Cable Incline Pushdown (similar movement), Straight-Arm Pulldown variants
-- lats 80%, triceps (long head) 25%
UPDATE exercise_muscles em
SET activation_percent = 80, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%straight%arm%pulldown%'
       OR lower(e.name) LIKE '%cable%incline%pushdown%')
  AND lower(mg.name) = 'lats' AND em.is_primary = true;

UPDATE exercise_muscles em
SET activation_percent = 25, function_type = 'stabilizer'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%straight%arm%pulldown%'
       OR lower(e.name) LIKE '%cable%incline%pushdown%')
  AND lower(mg.name) = 'triceps' AND em.is_primary = false;


-- ---- Pendlay Row (expert estimation: explosive barbell row from floor) ----
-- lats 85%, traps 60%, biceps 40%, lower back 50%
UPDATE exercise_muscles em
SET activation_percent = 85, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%pendlay%row%'
  AND lower(mg.name) = 'lats' AND em.is_primary = true;

UPDATE exercise_muscles em
SET activation_percent = 60, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%pendlay%row%'
  AND lower(mg.name) = 'traps';

UPDATE exercise_muscles em
SET activation_percent = 40, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%pendlay%row%'
  AND lower(mg.name) = 'biceps';

UPDATE exercise_muscles em
SET activation_percent = 50, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%pendlay%row%'
  AND lower(mg.name) = 'lower back';


-- ---- Meadows Row (expert estimation: unilateral landmine row, lat-dominant) ----
-- lats 85%, traps 55%, biceps 40%, rear delt 35%
UPDATE exercise_muscles em
SET activation_percent = 85, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%meadows%row%'
  AND lower(mg.name) = 'lats' AND em.is_primary = true;

UPDATE exercise_muscles em
SET activation_percent = 55, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%meadows%row%'
  AND lower(mg.name) = 'traps';

UPDATE exercise_muscles em
SET activation_percent = 40, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%meadows%row%'
  AND lower(mg.name) = 'biceps';

UPDATE exercise_muscles em
SET activation_percent = 35, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%meadows%row%'
  AND lower(mg.name) = 'shoulders' AND em.is_primary = false;


-- ---- Chest-Supported Row (expert estimation: no lower back load) ----
-- lats 85%, traps 55%, biceps 40%, rear delt 30%
UPDATE exercise_muscles em
SET activation_percent = 85, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%chest%supported%row%'
       OR lower(e.name) LIKE '%incline%dumbbell%row%'
       OR lower(e.name) LIKE '%seal%row%')
  AND lower(mg.name) = 'lats' AND em.is_primary = true;

UPDATE exercise_muscles em
SET activation_percent = 55, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%chest%supported%row%'
       OR lower(e.name) LIKE '%incline%dumbbell%row%'
       OR lower(e.name) LIKE '%seal%row%')
  AND lower(mg.name) = 'traps';

UPDATE exercise_muscles em
SET activation_percent = 40, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%chest%supported%row%'
       OR lower(e.name) LIKE '%incline%dumbbell%row%'
       OR lower(e.name) LIKE '%seal%row%')
  AND lower(mg.name) = 'biceps';

UPDATE exercise_muscles em
SET activation_percent = 30, function_type = 'stabilizer'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%chest%supported%row%'
       OR lower(e.name) LIKE '%incline%dumbbell%row%'
       OR lower(e.name) LIKE '%seal%row%')
  AND lower(mg.name) = 'shoulders' AND em.is_primary = false;


-- ---- One-Arm Lat Pulldown (Youdas 2010: unilateral variant) ----
-- lats 88%, biceps 50%, shoulders (rear delt) 25%
UPDATE exercise_muscles em
SET activation_percent = 88, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%one%arm%lat%pulldown%'
  AND lower(mg.name) = 'lats' AND em.is_primary = true;

UPDATE exercise_muscles em
SET activation_percent = 50, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%one%arm%lat%pulldown%'
  AND lower(mg.name) = 'biceps';

UPDATE exercise_muscles em
SET activation_percent = 25, function_type = 'stabilizer'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%one%arm%lat%pulldown%'
  AND lower(mg.name) = 'shoulders' AND em.is_primary = false;


-- ---- Full Range-Of-Motion Lat Pulldown ----
-- lats 90%, biceps 50%, shoulders 30%
UPDATE exercise_muscles em
SET activation_percent = 90, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%full range%lat%pulldown%'
  AND lower(mg.name) = 'lats' AND em.is_primary = true;

UPDATE exercise_muscles em
SET activation_percent = 50, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%full range%lat%pulldown%'
  AND lower(mg.name) = 'biceps';


-- ---- Barbell Rear Delt Row ----
-- shoulders (rear delt) 85%, traps 55%, biceps 35%
UPDATE exercise_muscles em
SET activation_percent = 85, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%rear%delt%row%'
  AND lower(mg.name) = 'shoulders' AND em.is_primary = true;

UPDATE exercise_muscles em
SET activation_percent = 55, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%rear%delt%row%'
  AND lower(mg.name) = 'traps';

UPDATE exercise_muscles em
SET activation_percent = 35, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%rear%delt%row%'
  AND lower(mg.name) = 'biceps';


-- =============================================================================
-- 3. SHOULDER EXERCISES
-- =============================================================================

-- ---- Lateral Raise (Andersen 2014: peak lateral deltoid activation) ----
-- 037 set lateral raise primary = 100. Refine to 95% and add function_type.
-- Matches: Side Lateral Raise, Seated Side Lateral Raise, Cable Seated Lateral Raise,
--          Lateral Raise - With Bands, One-Arm Incline Lateral Raise, Lying One-Arm Lateral Raise
-- lateral delt 95%, traps 35%
UPDATE exercise_muscles em
SET activation_percent = 95, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%lateral%raise%'
  AND lower(mg.name) = 'shoulders' AND em.is_primary = true;

UPDATE exercise_muscles em
SET activation_percent = 35, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%lateral%raise%'
  AND lower(mg.name) = 'traps';


-- ---- Front Raise (Andersen 2014: anterior delt isolation) ----
-- Matches: Front Raise And Pullover, Side Laterals to Front Raise,
--          Alternating Deltoid Raise (partial match)
-- anterior delt 90%, lateral delt 20%
UPDATE exercise_muscles em
SET activation_percent = 90, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%front%raise%'
  AND lower(mg.name) = 'shoulders' AND em.is_primary = true;

UPDATE exercise_muscles em
SET activation_percent = 20, function_type = 'stabilizer'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%front%raise%'
  AND lower(mg.name) = 'chest';


-- ---- Face Pull (expert estimation: rear delt + external rotator focus) ----
-- Matches: Face Pull
-- rear delt 80%, traps 55%, shoulders (ext. rotators mapped to shoulders) 40%
UPDATE exercise_muscles em
SET activation_percent = 80, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%face%pull%'
  AND lower(mg.name) = 'shoulders' AND em.is_primary = true;

UPDATE exercise_muscles em
SET activation_percent = 55, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%face%pull%'
  AND lower(mg.name) = 'traps';

UPDATE exercise_muscles em
SET activation_percent = 40, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%face%pull%'
  AND lower(mg.name) = 'biceps';


-- ---- Rear Delt Flye / Reverse Flye ----
-- Matches: Bent Over Dumbbell Rear Delt Raise With Head On Bench,
--          Seated Bent-Over Rear Delt Raise, Lying Rear Delt Raise,
--          Cable Rear Delt Fly, Reverse Flyes, Reverse Flyes With External Rotation,
--          Reverse Machine Flyes, Sled Reverse Flye
-- rear delt 90%, traps 40%
UPDATE exercise_muscles em
SET activation_percent = 90, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%rear%delt%raise%'
       OR lower(e.name) LIKE '%rear%delt%fly%'
       OR lower(e.name) LIKE '%reverse%fly%'
       OR lower(e.name) LIKE '%reverse%machine%fly%')
  AND lower(mg.name) = 'shoulders' AND em.is_primary = true;

UPDATE exercise_muscles em
SET activation_percent = 40, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%rear%delt%raise%'
       OR lower(e.name) LIKE '%rear%delt%fly%'
       OR lower(e.name) LIKE '%reverse%fly%'
       OR lower(e.name) LIKE '%reverse%machine%fly%')
  AND lower(mg.name) = 'traps';


-- ---- Arnold Press (Andersen 2014: full ROM shoulder press, high lateral delt) ----
-- Matches: Arnold Dumbbell Press, Kettlebell Arnold Press
-- anterior delt 80%, lateral delt (mapped to shoulders) 65%, triceps 40%
UPDATE exercise_muscles em
SET activation_percent = 80, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%arnold%press%'
  AND lower(mg.name) = 'shoulders' AND em.is_primary = true;

UPDATE exercise_muscles em
SET activation_percent = 40, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%arnold%press%'
  AND lower(mg.name) = 'triceps';


-- ---- Upright Row (expert estimation: lateral delt + traps, debated exercise) ----
-- Matches: Dumbbell One-Arm Upright Row, Smith Machine One-Arm Upright Row,
--          Smith Machine Upright Row, Standing Dumbbell Upright Row, Upright Row - With Bands
-- lateral delt 75%, traps 70%, biceps 30%
UPDATE exercise_muscles em
SET activation_percent = 75, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%upright%row%'
  AND lower(mg.name) = 'shoulders' AND em.is_primary = true;

UPDATE exercise_muscles em
SET activation_percent = 70, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%upright%row%'
  AND lower(mg.name) = 'traps';

UPDATE exercise_muscles em
SET activation_percent = 30, function_type = 'stabilizer'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%upright%row%'
  AND lower(mg.name) = 'biceps';


-- ---- Band Pull Apart (expert estimation: rear delt and rhomboid focus) ----
-- Matches: Band Pull Apart
-- shoulders (rear delt) 80%, traps 50%
UPDATE exercise_muscles em
SET activation_percent = 80, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%band%pull%apart%'
  AND lower(mg.name) = 'shoulders' AND em.is_primary = true;

UPDATE exercise_muscles em
SET activation_percent = 50, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%band%pull%apart%'
  AND lower(mg.name) = 'traps';


-- =============================================================================
-- 4. ARM EXERCISES
-- =============================================================================

-- ---- Barbell Curl (Marcolin 2018: standard bicep curl EMG) ----
-- Matches: Barbell Curl, Close-Grip Standing Barbell Curl, Wide-Grip Standing Barbell Curl,
--          Reverse Barbell Curl, Barbell Curls Lying Against An Incline
-- biceps 95%, forearms 35%
UPDATE exercise_muscles em
SET activation_percent = 95, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%barbell%curl%'
  AND lower(e.name) NOT LIKE '%leg curl%'
  AND lower(mg.name) = 'biceps' AND em.is_primary = true;

UPDATE exercise_muscles em
SET activation_percent = 35, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%barbell%curl%'
  AND lower(e.name) NOT LIKE '%leg curl%'
  AND lower(mg.name) = 'forearms';


-- ---- Hammer Curl (Marcolin 2018: brachioradialis emphasis) ----
-- Matches: Hammer Curls, Alternate Hammer Curl, Cross Body Hammer Curl,
--          Cable Hammer Curls - Rope Attachment, Incline Hammer Curls,
--          Preacher Hammer Dumbbell Curl
-- brachioradialis/forearms 85% (primary), biceps 75%, forearms 40%
UPDATE exercise_muscles em
SET activation_percent = 75, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%hammer%curl%'
  AND lower(mg.name) = 'biceps' AND em.is_primary = true;

UPDATE exercise_muscles em
SET activation_percent = 40, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%hammer%curl%'
  AND lower(mg.name) = 'forearms';


-- ---- Preacher Curl (Marcolin 2018: locked position, peak bicep isolation) ----
-- Matches: Preacher Curl, Cable Preacher Curl, One Arm Dumbbell Preacher Curl,
--          Two-Arm Dumbbell Preacher Curl, Reverse Barbell Preacher Curls,
--          Machine Preacher Curls, Zottman Preacher Curl
-- biceps 100%, forearms 25%
UPDATE exercise_muscles em
SET activation_percent = 100, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%preacher%curl%'
  AND lower(mg.name) = 'biceps' AND em.is_primary = true;

UPDATE exercise_muscles em
SET activation_percent = 25, function_type = 'stabilizer'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%preacher%curl%'
  AND lower(mg.name) = 'forearms';


-- ---- Concentration Curl (Marcolin 2018: highest bicep activation of all curl variants) ----
-- Matches: Concentration Curls, Standing Concentration Curl,
--          Seated Close-Grip Concentration Barbell Curl
-- biceps 100%
UPDATE exercise_muscles em
SET activation_percent = 100, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%concentration%curl%'
  AND lower(mg.name) = 'biceps' AND em.is_primary = true;


-- ---- Tricep Pushdown (Signorile 2002: tricep isolation, all heads) ----
-- Matches: Triceps Pushdown, Triceps Pushdown - Rope Attachment,
--          Triceps Pushdown - V-Bar Attachment, Reverse Grip Triceps Pushdown
-- triceps 95%
UPDATE exercise_muscles em
SET activation_percent = 95, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%triceps%pushdown%'
  AND lower(mg.name) = 'triceps' AND em.is_primary = true;


-- ---- Overhead Tricep Extension (Signorile 2002: long head emphasis) ----
-- Matches: Cable Rope Overhead Triceps Extension, Standing Overhead Barbell Triceps Extension,
--          Overhead Triceps, Sled Overhead Triceps Extension, Speed Band Overhead Triceps
-- triceps 95%
UPDATE exercise_muscles em
SET activation_percent = 95, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%overhead%tricep%'
  AND lower(mg.name) = 'triceps' AND em.is_primary = true;


-- ---- Skull Crusher / Lying Tricep Extension (Signorile 2002) ----
-- Matches: Band Skull Crusher, Decline Close-Grip Bench To Skull Crusher,
--          Decline EZ Bar Triceps Extension, Decline Dumbbell Triceps Extension
-- triceps 95%, forearms 20%
UPDATE exercise_muscles em
SET activation_percent = 95, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%skull%crush%'
       OR (lower(e.name) LIKE '%tricep%extension%' AND lower(e.name) NOT LIKE '%overhead%'))
  AND lower(mg.name) = 'triceps' AND em.is_primary = true;

UPDATE exercise_muscles em
SET activation_percent = 20, function_type = 'stabilizer'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%skull%crush%'
       OR (lower(e.name) LIKE '%tricep%extension%' AND lower(e.name) NOT LIKE '%overhead%'))
  AND lower(mg.name) = 'forearms';


-- ---- Dips - Tricep Focus (expert estimation: narrow grip, upright torso) ----
-- Matches: Dips - Triceps Version, Bench Dips, Weighted Bench Dip, Dip Machine
-- triceps 80%, chest 50%, anterior delt 40%
UPDATE exercise_muscles em
SET activation_percent = 80, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%dips%-%triceps%'
       OR lower(e.name) LIKE '%bench dip%'
       OR lower(e.name) LIKE '%dip machine%')
  AND lower(mg.name) = 'triceps' AND em.is_primary = true;

UPDATE exercise_muscles em
SET activation_percent = 50, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%dips%-%triceps%'
       OR lower(e.name) LIKE '%bench dip%'
       OR lower(e.name) LIKE '%dip machine%')
  AND lower(mg.name) = 'chest';

UPDATE exercise_muscles em
SET activation_percent = 40, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%dips%-%triceps%'
       OR lower(e.name) LIKE '%bench dip%'
       OR lower(e.name) LIKE '%dip machine%')
  AND lower(mg.name) = 'shoulders' AND em.is_primary = false;


-- ---- Incline Curl variants (Marcolin 2018: stretched position, higher long head) ----
-- Matches: Alternate Incline Dumbbell Curl, Incline Hammer Curls
-- biceps 90%, forearms 30%
UPDATE exercise_muscles em
SET activation_percent = 90, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%incline%curl%'
  AND lower(mg.name) = 'biceps' AND em.is_primary = true;

UPDATE exercise_muscles em
SET activation_percent = 30, function_type = 'stabilizer'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%incline%curl%'
  AND lower(mg.name) = 'forearms';


-- =============================================================================
-- 5. LEG EXERCISES
-- =============================================================================

-- ---- Leg Press (Escamilla 2001: high quad, moderate glute) ----
-- Matches: Leg Press, Narrow Stance Leg Press, Smith Machine Leg Press,
--          Calf Press On The Leg Press Machine
-- quads 90%, glutes 50%, hamstrings 25%
UPDATE exercise_muscles em
SET activation_percent = 90, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%leg%press%'
  AND lower(e.name) NOT LIKE '%calf%press%'
  AND lower(mg.name) = 'quadriceps' AND em.is_primary = true;

UPDATE exercise_muscles em
SET activation_percent = 50, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%leg%press%'
  AND lower(e.name) NOT LIKE '%calf%press%'
  AND lower(mg.name) = 'glutes';

UPDATE exercise_muscles em
SET activation_percent = 25, function_type = 'stabilizer'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%leg%press%'
  AND lower(e.name) NOT LIKE '%calf%press%'
  AND lower(mg.name) = 'hamstrings';


-- ---- Hack Squat (Escamilla 2001: very quad-dominant, less glute than squat) ----
-- Matches: Hack Squat, Barbell Hack Squat, Narrow Stance Hack Squats
-- quads 95%, glutes 40%
UPDATE exercise_muscles em
SET activation_percent = 95, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%hack%squat%'
  AND lower(mg.name) = 'quadriceps' AND em.is_primary = true;

UPDATE exercise_muscles em
SET activation_percent = 40, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%hack%squat%'
  AND lower(mg.name) = 'glutes';


-- ---- Bulgarian Split Squat (Contreras 2015: high glute + quad) ----
-- 037 already handled '%split squat%' generically. Refine to specific values.
-- quads 85%, glutes 70%, hamstrings 30%
UPDATE exercise_muscles em
SET activation_percent = 85, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%bulgarian%split%squat%'
  AND lower(mg.name) = 'quadriceps' AND em.is_primary = true;

UPDATE exercise_muscles em
SET activation_percent = 70, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%bulgarian%split%squat%'
  AND lower(mg.name) = 'glutes';

UPDATE exercise_muscles em
SET activation_percent = 30, function_type = 'stabilizer'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%bulgarian%split%squat%'
  AND lower(mg.name) = 'hamstrings';


-- ---- Leg Extension (expert estimation: pure quad isolation) ----
-- Matches: Leg Extensions, Single-Leg Leg Extension
-- quads 100%
UPDATE exercise_muscles em
SET activation_percent = 100, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%leg%extension%'
  AND lower(mg.name) = 'quadriceps' AND em.is_primary = true;


-- ---- Leg Curl - Lying / Seated (expert estimation: hamstring isolation) ----
-- Matches: Lying Leg Curls, Seated Leg Curl, Standing Leg Curl, Ball Leg Curl
-- hamstrings 95%, calves 15%
UPDATE exercise_muscles em
SET activation_percent = 95, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%leg%curl%'
  AND lower(mg.name) = 'hamstrings' AND em.is_primary = true;

UPDATE exercise_muscles em
SET activation_percent = 15, function_type = 'stabilizer'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%leg%curl%'
  AND lower(mg.name) = 'calves';


-- ---- Hip Thrust (Contreras 2015: highest glute activation of any exercise) ----
-- 037 already handled this. Refine with function_type.
-- Matches: Barbell Hip Thrust, Barbell Glute Bridge (similar pattern)
-- glutes 95%, hamstrings 40%
UPDATE exercise_muscles em
SET activation_percent = 95, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%hip%thrust%' OR lower(e.name) LIKE '%glute%bridge%')
  AND lower(mg.name) = 'glutes' AND em.is_primary = true;

UPDATE exercise_muscles em
SET activation_percent = 40, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%hip%thrust%' OR lower(e.name) LIKE '%glute%bridge%')
  AND lower(mg.name) = 'hamstrings';


-- ---- Calf Raise - Standing (expert estimation: gastrocnemius emphasis) ----
-- Matches: Standing Calf Raises, Standing Barbell Calf Raise,
--          Standing Dumbbell Calf Raise, Smith Machine Calf Raise,
--          Rocking Standing Calf Raise, Donkey Calf Raises, Calf Raises - With Bands
-- calves 95%
UPDATE exercise_muscles em
SET activation_percent = 95, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%calf%raise%'
  AND lower(e.name) NOT LIKE '%seated%'
  AND lower(mg.name) = 'calves' AND em.is_primary = true;


-- ---- Calf Raise - Seated (expert estimation: soleus emphasis) ----
-- Matches: Seated Calf Raise, Barbell Seated Calf Raise,
--          Dumbbell Seated One-Leg Calf Raise
-- calves 90% (primarily soleus; gastrocnemius is slack at bent knee)
UPDATE exercise_muscles em
SET activation_percent = 90, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%seated%calf%raise%'
  AND lower(mg.name) = 'calves' AND em.is_primary = true;


-- ---- Good Morning (Schoenfeld 2010: hip-hinge, hamstring/glute/erector) ----
-- Matches: Good Morning, Band Good Morning, Good Morning off Pins,
--          Hanging Bar Good Morning, Seated Good Mornings, Stiff Leg Barbell Good Morning
-- hamstrings 75%, glutes 70%, lower back 65%
UPDATE exercise_muscles em
SET activation_percent = 75, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%good%morning%'
  AND lower(mg.name) = 'hamstrings' AND em.is_primary = true;

UPDATE exercise_muscles em
SET activation_percent = 70, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%good%morning%'
  AND lower(mg.name) = 'glutes';

UPDATE exercise_muscles em
SET activation_percent = 65, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%good%morning%'
  AND lower(mg.name) = 'lower back';


-- ---- Sumo Deadlift (Escamilla 2001: wider stance = more adductor/glute) ----
-- Matches: Sumo Deadlift, Sumo Deadlift with Bands, Sumo Deadlift with Chains,
--          Reverse Band Sumo Deadlift
-- glutes 90%, hamstrings 65%, quads 55%, adductors 50%
UPDATE exercise_muscles em
SET activation_percent = 90, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%sumo%deadlift%'
  AND lower(mg.name) = 'glutes' AND em.is_primary = true;

UPDATE exercise_muscles em
SET activation_percent = 65, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%sumo%deadlift%'
  AND lower(mg.name) = 'hamstrings';

UPDATE exercise_muscles em
SET activation_percent = 55, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%sumo%deadlift%'
  AND lower(mg.name) = 'quadriceps';

UPDATE exercise_muscles em
SET activation_percent = 50, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%sumo%deadlift%'
  AND lower(mg.name) = 'adductors';


-- ---- Glute Kickback (expert estimation: isolation, glute focused) ----
-- Matches: Glute Kickback
-- glutes 90%, hamstrings 25%
UPDATE exercise_muscles em
SET activation_percent = 90, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%glute%kickback%'
  AND lower(mg.name) = 'glutes' AND em.is_primary = true;

UPDATE exercise_muscles em
SET activation_percent = 25, function_type = 'stabilizer'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%glute%kickback%'
  AND lower(mg.name) = 'hamstrings';


-- ---- Calf Press on Leg Press Machine ----
-- calves 90%
UPDATE exercise_muscles em
SET activation_percent = 90, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%calf%press%'
  AND lower(mg.name) = 'calves' AND em.is_primary = true;


-- ---- Donkey Calf Raise (expert estimation: similar to standing, deeper stretch) ----
-- calves 95%
UPDATE exercise_muscles em
SET activation_percent = 95, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%donkey%calf%'
  AND lower(mg.name) = 'calves' AND em.is_primary = true;


-- ---- Kettlebell Sumo High Pull ----
-- traps 70%, shoulders 65%, glutes 50%, quads 40%
UPDATE exercise_muscles em
SET activation_percent = 65, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%sumo%high%pull%'
  AND lower(mg.name) = 'shoulders' AND em.is_primary = true;

UPDATE exercise_muscles em
SET activation_percent = 70, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%sumo%high%pull%'
  AND lower(mg.name) = 'traps';

UPDATE exercise_muscles em
SET activation_percent = 50, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%sumo%high%pull%'
  AND lower(mg.name) = 'glutes';

UPDATE exercise_muscles em
SET activation_percent = 40, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%sumo%high%pull%'
  AND lower(mg.name) = 'quadriceps';


-- =============================================================================
-- 6. CORE EXERCISES
-- =============================================================================

-- ---- Plank (expert estimation: isometric core) ----
-- Matches: Plank, Push Up to Side Plank
-- abs 80%, obliques (mapped to abs in our model) already covered,
-- lower back 30%
UPDATE exercise_muscles em
SET activation_percent = 80, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%plank%'
  AND lower(mg.name) = 'abs' AND em.is_primary = true;

UPDATE exercise_muscles em
SET activation_percent = 30, function_type = 'stabilizer'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%plank%'
  AND lower(mg.name) = 'lower back';

UPDATE exercise_muscles em
SET activation_percent = 40, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%plank%'
  AND lower(mg.name) = 'shoulders';


-- ---- Hanging Leg Raise (expert estimation: high lower-ab / hip flexor) ----
-- Matches: Hanging Leg Raise
-- abs 90%, hip flexors (mapped to quadriceps in this model) 40%
UPDATE exercise_muscles em
SET activation_percent = 90, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%hanging%leg%raise%'
  AND lower(mg.name) = 'abs' AND em.is_primary = true;

UPDATE exercise_muscles em
SET activation_percent = 40, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%hanging%leg%raise%'
  AND lower(mg.name) = 'quadriceps';

UPDATE exercise_muscles em
SET activation_percent = 25, function_type = 'stabilizer'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%hanging%leg%raise%'
  AND lower(mg.name) = 'lats';


-- ---- Cable Woodchop (expert estimation: rotational core) ----
-- obliques (mapped to abs) 85%, abs 45%
UPDATE exercise_muscles em
SET activation_percent = 85, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%woodchop%'
  AND lower(mg.name) = 'abs' AND em.is_primary = true;

UPDATE exercise_muscles em
SET activation_percent = 35, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%woodchop%'
  AND lower(mg.name) = 'shoulders';


-- ---- Ab Wheel / Ab Roller Rollout (expert estimation: high ab, lat stabilization) ----
-- Matches: Ab Roller, Barbell Ab Rollout, Barbell Ab Rollout - On Knees
-- abs 95%, lats 25%, triceps 20%
UPDATE exercise_muscles em
SET activation_percent = 95, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%ab%roller%' OR lower(e.name) LIKE '%ab%rollout%')
  AND lower(mg.name) = 'abs' AND em.is_primary = true;

UPDATE exercise_muscles em
SET activation_percent = 25, function_type = 'stabilizer'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%ab%roller%' OR lower(e.name) LIKE '%ab%rollout%')
  AND lower(mg.name) = 'lats';

UPDATE exercise_muscles em
SET activation_percent = 20, function_type = 'stabilizer'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%ab%roller%' OR lower(e.name) LIKE '%ab%rollout%')
  AND lower(mg.name) = 'triceps';

UPDATE exercise_muscles em
SET activation_percent = 25, function_type = 'stabilizer'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%ab%roller%' OR lower(e.name) LIKE '%ab%rollout%')
  AND lower(mg.name) = 'shoulders';


-- =============================================================================
-- 7. ADDITIONAL COMPOUND EXERCISES
-- =============================================================================

-- ---- Dips - Chest Version (wider grip, forward lean) ----
-- Matches: Dips - Chest Version, Ring Dips, Parallel Bar Dip
-- chest 90%, triceps 65%, anterior delt 55%
UPDATE exercise_muscles em
SET activation_percent = 90, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%dips%-%chest%'
       OR lower(e.name) LIKE '%ring dip%'
       OR lower(e.name) LIKE '%parallel%bar%dip%')
  AND lower(mg.name) = 'chest' AND em.is_primary = true;

UPDATE exercise_muscles em
SET activation_percent = 65, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%dips%-%chest%'
       OR lower(e.name) LIKE '%ring dip%'
       OR lower(e.name) LIKE '%parallel%bar%dip%')
  AND lower(mg.name) = 'triceps';

UPDATE exercise_muscles em
SET activation_percent = 55, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%dips%-%chest%'
       OR lower(e.name) LIKE '%ring dip%'
       OR lower(e.name) LIKE '%parallel%bar%dip%')
  AND lower(mg.name) = 'shoulders' AND em.is_primary = false;


-- ---- Chin-Up (Youdas 2010: supinated grip, higher bicep than pull-up) ----
-- 037 already set bicep = 75% for chin-ups. Add function_type.
UPDATE exercise_muscles em
SET activation_percent = 100, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%chin%up%' OR lower(e.name) LIKE '%chinup%')
  AND lower(mg.name) = 'lats' AND em.is_primary = true;

UPDATE exercise_muscles em
SET activation_percent = 75, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%chin%up%' OR lower(e.name) LIKE '%chinup%')
  AND lower(mg.name) = 'biceps' AND em.is_primary = false;


-- ---- Barbell Front Squat (Escamilla 2001: more quad, less glute than back squat) ----
-- quads 100%, glutes 60%, core 35%, hamstrings 25%
UPDATE exercise_muscles em
SET activation_percent = 100, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%front%squat%'
  AND lower(mg.name) = 'quadriceps' AND em.is_primary = true;

UPDATE exercise_muscles em
SET activation_percent = 60, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%front%squat%'
  AND lower(mg.name) = 'glutes';

UPDATE exercise_muscles em
SET activation_percent = 35, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%front%squat%'
  AND lower(mg.name) = 'abs';

UPDATE exercise_muscles em
SET activation_percent = 25, function_type = 'stabilizer'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%front%squat%'
  AND lower(mg.name) = 'hamstrings';


-- ---- Alternating Shoulder Press variants ----
-- shoulders 90%, triceps 50%
UPDATE exercise_muscles em
SET activation_percent = 90, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%alternating%shoulder%press%'
  AND lower(mg.name) = 'shoulders' AND em.is_primary = true;

UPDATE exercise_muscles em
SET activation_percent = 50, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%alternating%shoulder%press%'
  AND lower(mg.name) = 'triceps';


-- ---- Alternating Kettlebell Press ----
-- shoulders 88%, triceps 45%
UPDATE exercise_muscles em
SET activation_percent = 88, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%alternating%kettlebell%press%'
  AND lower(mg.name) = 'shoulders' AND em.is_primary = true;

UPDATE exercise_muscles em
SET activation_percent = 45, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%alternating%kettlebell%press%'
  AND lower(mg.name) = 'triceps';


-- ---- Alternating Floor Press ----
-- chest 85%, triceps 50%, shoulders 40%
UPDATE exercise_muscles em
SET activation_percent = 85, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%floor%press%'
  AND lower(mg.name) = 'chest' AND em.is_primary = true;

UPDATE exercise_muscles em
SET activation_percent = 50, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%floor%press%'
  AND lower(mg.name) = 'triceps';

UPDATE exercise_muscles em
SET activation_percent = 40, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%floor%press%'
  AND lower(mg.name) = 'shoulders' AND em.is_primary = false;


-- =============================================================================
-- 8. MOVEMENT PATTERN ENRICHMENT for newly covered exercises
-- =============================================================================

-- Hack squats → squat
UPDATE exercises SET movement_pattern = 'squat'
WHERE movement_pattern IS NULL
  AND lower(name) LIKE '%hack%squat%';

-- Good mornings → hip_hinge
UPDATE exercises SET movement_pattern = 'hip_hinge'
WHERE movement_pattern IS NULL
  AND lower(name) LIKE '%good%morning%';

-- Sumo deadlift → hip_hinge
UPDATE exercises SET movement_pattern = 'hip_hinge'
WHERE movement_pattern IS NULL
  AND lower(name) LIKE '%sumo%deadlift%';

-- Hip thrust / glute bridge → hip_hinge
UPDATE exercises SET movement_pattern = 'hip_hinge'
WHERE movement_pattern IS NULL
  AND (lower(name) LIKE '%hip%thrust%' OR lower(name) LIKE '%glute%bridge%'
       OR lower(name) LIKE '%glute%kickback%');

-- Upright row → vertical_pull
UPDATE exercises SET movement_pattern = 'vertical_pull'
WHERE movement_pattern IS NULL
  AND lower(name) LIKE '%upright%row%';

-- Face pull → horizontal_pull
UPDATE exercises SET movement_pattern = 'horizontal_pull'
WHERE movement_pattern IS NULL
  AND lower(name) LIKE '%face%pull%';

-- Arnold press → vertical_push
UPDATE exercises SET movement_pattern = 'vertical_push'
WHERE movement_pattern IS NULL
  AND lower(name) LIKE '%arnold%press%';

-- Front raise → isolation
UPDATE exercises SET movement_pattern = 'isolation'
WHERE movement_pattern IS NULL
  AND lower(name) LIKE '%front%raise%';

-- Rear delt exercises → isolation
UPDATE exercises SET movement_pattern = 'isolation'
WHERE movement_pattern IS NULL
  AND (lower(name) LIKE '%rear%delt%' OR lower(name) LIKE '%reverse%fly%');

-- Leg press → squat (machine variant)
UPDATE exercises SET movement_pattern = 'squat'
WHERE movement_pattern IS NULL
  AND lower(name) LIKE '%leg%press%' AND lower(name) NOT LIKE '%calf%';

-- Concentration curls → isolation
UPDATE exercises SET movement_pattern = 'isolation'
WHERE movement_pattern IS NULL
  AND lower(name) LIKE '%concentration%curl%';

-- Preacher curls → isolation
UPDATE exercises SET movement_pattern = 'isolation'
WHERE movement_pattern IS NULL
  AND lower(name) LIKE '%preacher%curl%';

-- Ab roller / ab wheel → isolation (core)
UPDATE exercises SET movement_pattern = 'isolation'
WHERE movement_pattern IS NULL
  AND (lower(name) LIKE '%ab%roller%' OR lower(name) LIKE '%ab%rollout%');

-- Woodchop → isolation (rotational core)
UPDATE exercises SET movement_pattern = 'isolation'
WHERE movement_pattern IS NULL
  AND lower(name) LIKE '%woodchop%';

-- Plank → isolation (isometric core)
UPDATE exercises SET movement_pattern = 'isolation'
WHERE movement_pattern IS NULL
  AND lower(name) LIKE '%plank%';

-- Floor press → horizontal_push
UPDATE exercises SET movement_pattern = 'horizontal_push'
WHERE movement_pattern IS NULL
  AND lower(name) LIKE '%floor%press%';

-- Band pull apart → isolation (rear delt)
UPDATE exercises SET movement_pattern = 'isolation'
WHERE movement_pattern IS NULL
  AND lower(name) LIKE '%band%pull%apart%';


-- =============================================================================
-- 9. BACKFILL: remaining NULL activation_percent with pattern-based defaults
-- =============================================================================
-- These catch any exercises still missing values after both 037 and this migration.
-- Use conservative evidence-based defaults.

-- Primary muscles with null activation → 100 (if primary, it's fully activated by definition)
UPDATE exercise_muscles SET activation_percent = 100, function_type = 'agonist'
WHERE is_primary = true AND activation_percent IS NULL;

-- Synergists with null activation → 55 (moderate assistance)
UPDATE exercise_muscles SET activation_percent = 55
WHERE function_type = 'synergist' AND activation_percent IS NULL;

-- Stabilizers with null activation → 20 (joint stability, low EMG)
UPDATE exercise_muscles SET activation_percent = 20
WHERE function_type = 'stabilizer' AND activation_percent IS NULL;

-- Non-primary without function_type, still null → assign as synergist at 50
UPDATE exercise_muscles SET activation_percent = 50, function_type = 'synergist'
WHERE is_primary = false AND activation_percent IS NULL AND function_type IS NULL;

-- Non-primary with function_type but somehow still null → 45
UPDATE exercise_muscles SET activation_percent = 45
WHERE is_primary = false AND activation_percent IS NULL;


COMMIT;
