-- Migration 037: Activation Percentage Seed Data for Top Exercises
-- Populates activation_percent on exercise_muscles for the most commonly performed
-- exercises. EMG-derived values from published literature where available,
-- pattern-based defaults for the remainder.
--
-- Sources:
--   Lauver et al. (2016, JSCR): EMG comparison of bench press variations
--   Schoenfeld et al. (2022, IJSS): Muscle activation during multi-joint exercises
--   Escamilla et al. (2001, MSSE): Squat EMG analysis
--   Schoenfeld et al. (2010, JSCR): Hamstring EMG during hip extension exercises
--   Youdas et al. (2010, JSCR): Pull-up and lat pulldown EMG comparison
--   Andersen et al. (2014, JSCR): Shoulder press EMG analysis
--   Botton et al. (2013, JSCR): Cable crossover and dumbbell fly EMG
--
-- Pattern:
--   UPDATE exercise_muscles em
--   SET activation_percent = X
--   FROM exercises e, muscle_groups mg
--   WHERE em.exercise_id = e.id
--     AND em.muscle_group_id = mg.id
--     AND lower(e.name) LIKE '%pattern%'
--     AND lower(mg.name) = 'muscle'
--     AND em.activation_percent IS NULL;

BEGIN;

-- =============================================================================
-- 1. COMPOUND EXERCISES — EMG-derived values
-- =============================================================================

-- Barbell Bench Press (Lauver 2016, Schoenfeld 2022)
-- Pectoralis major (sternal) = agonist = 100%
-- Anterior deltoid = strong synergist = 65%
-- Triceps brachii = synergist = 45%
UPDATE exercise_muscles em SET activation_percent = 100
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%bench press%' AND lower(e.name) NOT LIKE '%incline%'
  AND lower(e.name) NOT LIKE '%decline%' AND lower(e.name) NOT LIKE '%close%'
  AND lower(mg.name) IN ('chest', 'pectoralis major') AND em.is_primary = true
  AND em.activation_percent IS NULL;

UPDATE exercise_muscles em SET activation_percent = 65
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%bench press%' AND lower(e.name) NOT LIKE '%incline%'
  AND lower(e.name) NOT LIKE '%decline%' AND lower(e.name) NOT LIKE '%close%'
  AND lower(mg.name) IN ('shoulders', 'anterior deltoid', 'deltoid')
  AND em.is_primary = false AND em.activation_percent IS NULL;

UPDATE exercise_muscles em SET activation_percent = 45
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%bench press%' AND lower(e.name) NOT LIKE '%incline%'
  AND lower(e.name) NOT LIKE '%decline%' AND lower(e.name) NOT LIKE '%close%'
  AND lower(mg.name) IN ('triceps', 'triceps brachii')
  AND em.is_primary = false AND em.activation_percent IS NULL;


-- Incline Bench Press (Lauver 2016: clavicular head > sternal)
UPDATE exercise_muscles em SET activation_percent = 100
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%incline%press%'
  AND lower(mg.name) IN ('chest', 'pectoralis major', 'upper chest') AND em.is_primary = true
  AND em.activation_percent IS NULL;

UPDATE exercise_muscles em SET activation_percent = 70
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%incline%press%'
  AND lower(mg.name) IN ('shoulders', 'anterior deltoid', 'deltoid')
  AND em.is_primary = false AND em.activation_percent IS NULL;

UPDATE exercise_muscles em SET activation_percent = 40
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%incline%press%'
  AND lower(mg.name) IN ('triceps', 'triceps brachii')
  AND em.is_primary = false AND em.activation_percent IS NULL;


-- Barbell Squat (Escamilla 2001, Schoenfeld 2022)
-- Quadriceps = agonist = 100%
-- Glutes = strong synergist = 75% (varies by depth; deeper = more glute)
-- Hamstrings = moderate synergist = 35% (primarily knee stabilization)
-- Core (rectus abdominis + obliques) = stabilizer = 25%
-- Calves = stabilizer = 15%
UPDATE exercise_muscles em SET activation_percent = 100
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%squat%' AND lower(e.name) LIKE '%barbell%'
       OR lower(e.name) = 'barbell back squat' OR lower(e.name) = 'barbell front squat')
  AND lower(mg.name) IN ('quadriceps', 'quads') AND em.is_primary = true
  AND em.activation_percent IS NULL;

UPDATE exercise_muscles em SET activation_percent = 75
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%squat%' AND lower(e.name) LIKE '%barbell%'
       OR lower(e.name) = 'barbell back squat' OR lower(e.name) = 'barbell front squat')
  AND lower(mg.name) IN ('glutes', 'gluteus maximus')
  AND em.activation_percent IS NULL;

UPDATE exercise_muscles em SET activation_percent = 35
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%squat%' AND lower(e.name) LIKE '%barbell%'
       OR lower(e.name) = 'barbell back squat' OR lower(e.name) = 'barbell front squat')
  AND lower(mg.name) IN ('hamstrings') AND em.is_primary = false
  AND em.activation_percent IS NULL;

UPDATE exercise_muscles em SET activation_percent = 25
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%squat%' AND lower(e.name) LIKE '%barbell%'
       OR lower(e.name) = 'barbell back squat' OR lower(e.name) = 'barbell front squat')
  AND lower(mg.name) IN ('core', 'abdominals', 'rectus abdominis', 'obliques')
  AND em.activation_percent IS NULL;


-- Deadlift (Escamilla 2001, Schoenfeld 2010)
-- Glutes = primary = 100%
-- Hamstrings = strong synergist = 80% (hip extension)
-- Back (erector spinae) = strong synergist = 75%
-- Quadriceps = synergist = 45% (knee extension phase)
-- Lats = stabilizer = 30% (bar path control)
-- Core = stabilizer = 25%
UPDATE exercise_muscles em SET activation_percent = 100
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%deadlift%' AND lower(e.name) NOT LIKE '%romanian%'
       AND lower(e.name) NOT LIKE '%stiff%')
  AND lower(mg.name) IN ('glutes', 'gluteus maximus') AND em.is_primary = true
  AND em.activation_percent IS NULL;

UPDATE exercise_muscles em SET activation_percent = 80
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%deadlift%' AND lower(e.name) NOT LIKE '%romanian%'
       AND lower(e.name) NOT LIKE '%stiff%')
  AND lower(mg.name) IN ('hamstrings')
  AND em.activation_percent IS NULL;

UPDATE exercise_muscles em SET activation_percent = 75
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%deadlift%' AND lower(e.name) NOT LIKE '%romanian%'
       AND lower(e.name) NOT LIKE '%stiff%')
  AND lower(mg.name) IN ('back', 'erector spinae', 'lower back')
  AND em.activation_percent IS NULL;

UPDATE exercise_muscles em SET activation_percent = 45
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%deadlift%' AND lower(e.name) NOT LIKE '%romanian%'
       AND lower(e.name) NOT LIKE '%stiff%')
  AND lower(mg.name) IN ('quadriceps', 'quads')
  AND em.activation_percent IS NULL;

UPDATE exercise_muscles em SET activation_percent = 30
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%deadlift%' AND lower(e.name) NOT LIKE '%romanian%'
       AND lower(e.name) NOT LIKE '%stiff%')
  AND lower(mg.name) IN ('lats', 'latissimus dorsi')
  AND em.activation_percent IS NULL;


-- Romanian Deadlift (Schoenfeld 2010: hip-dominant, higher hamstring activation)
UPDATE exercise_muscles em SET activation_percent = 100
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%romanian%deadlift%' OR lower(e.name) LIKE '%stiff%leg%')
  AND lower(mg.name) IN ('hamstrings') AND em.is_primary = true
  AND em.activation_percent IS NULL;

UPDATE exercise_muscles em SET activation_percent = 85
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%romanian%deadlift%' OR lower(e.name) LIKE '%stiff%leg%')
  AND lower(mg.name) IN ('glutes', 'gluteus maximus')
  AND em.activation_percent IS NULL;

UPDATE exercise_muscles em SET activation_percent = 60
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%romanian%deadlift%' OR lower(e.name) LIKE '%stiff%leg%')
  AND lower(mg.name) IN ('back', 'erector spinae', 'lower back')
  AND em.activation_percent IS NULL;


-- Overhead Press / Shoulder Press (Andersen 2014)
-- Anterior deltoid = primary = 100%
-- Lateral deltoid = synergist = 60%
-- Triceps = synergist = 55%
-- Upper chest (clavicular) = synergist = 35%
UPDATE exercise_muscles em SET activation_percent = 100
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%shoulder press%' OR lower(e.name) LIKE '%overhead press%'
       OR lower(e.name) LIKE '%military press%')
  AND lower(mg.name) IN ('shoulders', 'deltoid', 'anterior deltoid') AND em.is_primary = true
  AND em.activation_percent IS NULL;

UPDATE exercise_muscles em SET activation_percent = 55
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%shoulder press%' OR lower(e.name) LIKE '%overhead press%'
       OR lower(e.name) LIKE '%military press%')
  AND lower(mg.name) IN ('triceps', 'triceps brachii')
  AND em.is_primary = false AND em.activation_percent IS NULL;


-- Pull-Up / Chin-Up (Youdas 2010)
-- Lats = primary = 100%
-- Biceps = synergist = 60% (higher for chin-ups ~75%)
-- Rear delt / upper back = synergist = 50%
-- Core = stabilizer = 20%
UPDATE exercise_muscles em SET activation_percent = 100
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%pull%up%' OR lower(e.name) LIKE '%pullup%')
  AND lower(mg.name) IN ('lats', 'latissimus dorsi', 'back') AND em.is_primary = true
  AND em.activation_percent IS NULL;

UPDATE exercise_muscles em SET activation_percent = 60
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%pull%up%' OR lower(e.name) LIKE '%pullup%')
  AND lower(mg.name) IN ('biceps', 'biceps brachii')
  AND em.is_primary = false AND em.activation_percent IS NULL;

UPDATE exercise_muscles em SET activation_percent = 75
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%chin%up%' OR lower(e.name) LIKE '%chinup%')
  AND lower(mg.name) IN ('biceps', 'biceps brachii')
  AND em.is_primary = false AND em.activation_percent IS NULL;


-- Barbell Row (Fenwick 2009)
-- Back / lats = primary = 100%
-- Biceps = synergist = 55%
-- Rear deltoid = synergist = 50%
-- Lower back = stabilizer = 30%
UPDATE exercise_muscles em SET activation_percent = 100
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%barbell%row%'
  AND lower(mg.name) IN ('back', 'lats', 'latissimus dorsi') AND em.is_primary = true
  AND em.activation_percent IS NULL;

UPDATE exercise_muscles em SET activation_percent = 55
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%barbell%row%'
  AND lower(mg.name) IN ('biceps', 'biceps brachii')
  AND em.is_primary = false AND em.activation_percent IS NULL;


-- Lat Pulldown (Youdas 2010)
UPDATE exercise_muscles em SET activation_percent = 100
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%lat%pulldown%'
  AND lower(mg.name) IN ('lats', 'latissimus dorsi', 'back') AND em.is_primary = true
  AND em.activation_percent IS NULL;

UPDATE exercise_muscles em SET activation_percent = 55
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%lat%pulldown%'
  AND lower(mg.name) IN ('biceps', 'biceps brachii')
  AND em.is_primary = false AND em.activation_percent IS NULL;


-- Dip (Schoenfeld 2022: chest and tricep heavy compound)
UPDATE exercise_muscles em SET activation_percent = 100
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%dip%'
  AND lower(mg.name) IN ('chest', 'pectoralis major', 'triceps', 'triceps brachii')
  AND em.is_primary = true AND em.activation_percent IS NULL;

UPDATE exercise_muscles em SET activation_percent = 65
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%dip%'
  AND lower(mg.name) IN ('shoulders', 'anterior deltoid', 'deltoid')
  AND em.is_primary = false AND em.activation_percent IS NULL;


-- Lunge / Bulgarian Split Squat
UPDATE exercise_muscles em SET activation_percent = 100
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%lunge%' OR lower(e.name) LIKE '%split squat%')
  AND lower(mg.name) IN ('quadriceps', 'quads') AND em.is_primary = true
  AND em.activation_percent IS NULL;

UPDATE exercise_muscles em SET activation_percent = 80
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%lunge%' OR lower(e.name) LIKE '%split squat%')
  AND lower(mg.name) IN ('glutes', 'gluteus maximus')
  AND em.activation_percent IS NULL;

UPDATE exercise_muscles em SET activation_percent = 40
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%lunge%' OR lower(e.name) LIKE '%split squat%')
  AND lower(mg.name) IN ('hamstrings')
  AND em.is_primary = false AND em.activation_percent IS NULL;


-- =============================================================================
-- 2. ISOLATION EXERCISES — pattern-based defaults
-- =============================================================================

-- Bicep curl variations: biceps = 100%, forearms = 35%
UPDATE exercise_muscles em SET activation_percent = 100
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%curl%' AND lower(e.name) NOT LIKE '%leg curl%'
       AND lower(e.name) NOT LIKE '%hamstring curl%')
  AND lower(mg.name) IN ('biceps', 'biceps brachii') AND em.is_primary = true
  AND em.activation_percent IS NULL;

UPDATE exercise_muscles em SET activation_percent = 35
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%curl%' AND lower(e.name) NOT LIKE '%leg curl%'
       AND lower(e.name) NOT LIKE '%hamstring curl%')
  AND lower(mg.name) IN ('forearms', 'brachioradialis')
  AND em.is_primary = false AND em.activation_percent IS NULL;


-- Tricep extensions / pushdowns: triceps = 100%
UPDATE exercise_muscles em SET activation_percent = 100
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%tricep%' OR lower(e.name) LIKE '%pushdown%'
       OR lower(e.name) LIKE '%skull%crush%')
  AND lower(mg.name) IN ('triceps', 'triceps brachii') AND em.is_primary = true
  AND em.activation_percent IS NULL;


-- Lateral raise: lateral deltoid = 100%, upper traps = 30%
UPDATE exercise_muscles em SET activation_percent = 100
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%lateral%raise%'
  AND lower(mg.name) IN ('shoulders', 'deltoid', 'lateral deltoid') AND em.is_primary = true
  AND em.activation_percent IS NULL;

UPDATE exercise_muscles em SET activation_percent = 30
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%lateral%raise%'
  AND lower(mg.name) IN ('traps', 'trapezius', 'upper traps')
  AND em.is_primary = false AND em.activation_percent IS NULL;


-- Leg curl: hamstrings = 100%
UPDATE exercise_muscles em SET activation_percent = 100
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%leg curl%' OR lower(e.name) LIKE '%hamstring curl%')
  AND lower(mg.name) IN ('hamstrings') AND em.is_primary = true
  AND em.activation_percent IS NULL;


-- Leg extension: quadriceps = 100%
UPDATE exercise_muscles em SET activation_percent = 100
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%leg extension%'
  AND lower(mg.name) IN ('quadriceps', 'quads') AND em.is_primary = true
  AND em.activation_percent IS NULL;


-- Cable / dumbbell fly (Botton 2013): chest = 100%, front delt = 35%
UPDATE exercise_muscles em SET activation_percent = 100
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%fly%' OR lower(e.name) LIKE '%flye%'
       OR lower(e.name) LIKE '%crossover%')
  AND lower(mg.name) IN ('chest', 'pectoralis major') AND em.is_primary = true
  AND em.activation_percent IS NULL;

UPDATE exercise_muscles em SET activation_percent = 35
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%fly%' OR lower(e.name) LIKE '%flye%'
       OR lower(e.name) LIKE '%crossover%')
  AND lower(mg.name) IN ('shoulders', 'anterior deltoid', 'deltoid')
  AND em.is_primary = false AND em.activation_percent IS NULL;


-- Face pull / rear delt fly: rear deltoid = 100%, upper back = 50%
UPDATE exercise_muscles em SET activation_percent = 100
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%face pull%' OR lower(e.name) LIKE '%rear delt%')
  AND lower(mg.name) IN ('shoulders', 'rear deltoid', 'deltoid') AND em.is_primary = true
  AND em.activation_percent IS NULL;

-- Calf raise: calves = 100%
UPDATE exercise_muscles em SET activation_percent = 100
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%calf%raise%'
  AND lower(mg.name) IN ('calves', 'gastrocnemius', 'soleus') AND em.is_primary = true
  AND em.activation_percent IS NULL;


-- Hip thrust (Contreras 2015): glutes = 100%, hamstrings = 40%
UPDATE exercise_muscles em SET activation_percent = 100
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%hip thrust%'
  AND lower(mg.name) IN ('glutes', 'gluteus maximus') AND em.is_primary = true
  AND em.activation_percent IS NULL;

UPDATE exercise_muscles em SET activation_percent = 40
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%hip thrust%'
  AND lower(mg.name) IN ('hamstrings')
  AND em.is_primary = false AND em.activation_percent IS NULL;


-- Plank / core exercises: core = 100%
UPDATE exercise_muscles em SET activation_percent = 100
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND (lower(e.name) LIKE '%plank%' OR lower(e.name) LIKE '%crunch%'
       OR lower(e.name) LIKE '%sit%up%' OR lower(e.name) LIKE '%leg raise%')
  AND lower(mg.name) IN ('core', 'abdominals', 'rectus abdominis', 'obliques')
  AND em.is_primary = true AND em.activation_percent IS NULL;


-- Push-up: chest = 100%, triceps = 50%, front delt = 55%
UPDATE exercise_muscles em SET activation_percent = 100
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%push%up%'
  AND lower(mg.name) IN ('chest', 'pectoralis major') AND em.is_primary = true
  AND em.activation_percent IS NULL;

UPDATE exercise_muscles em SET activation_percent = 55
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%push%up%'
  AND lower(mg.name) IN ('shoulders', 'anterior deltoid', 'deltoid')
  AND em.is_primary = false AND em.activation_percent IS NULL;

UPDATE exercise_muscles em SET activation_percent = 50
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id AND em.muscle_group_id = mg.id
  AND lower(e.name) LIKE '%push%up%'
  AND lower(mg.name) IN ('triceps', 'triceps brachii')
  AND em.is_primary = false AND em.activation_percent IS NULL;


-- =============================================================================
-- 3. BULK FALLBACK: remaining NULL activation_percent
-- =============================================================================

-- Any remaining primary muscles without activation_percent → 100
UPDATE exercise_muscles SET activation_percent = 100
WHERE is_primary = true AND activation_percent IS NULL;

-- Any remaining synergists (non-primary, agonist) → 55
UPDATE exercise_muscles SET activation_percent = 55
WHERE is_primary = false AND function_type = 'agonist' AND activation_percent IS NULL;

-- Any remaining synergists → 45
UPDATE exercise_muscles SET activation_percent = 45
WHERE is_primary = false AND function_type = 'synergist' AND activation_percent IS NULL;

-- Any remaining stabilizers → 20
UPDATE exercise_muscles SET activation_percent = 20
WHERE is_primary = false AND function_type = 'stabilizer' AND activation_percent IS NULL;

-- Any remaining non-primary without function_type → 50 (conservative default)
UPDATE exercise_muscles SET activation_percent = 50
WHERE is_primary = false AND activation_percent IS NULL;


-- =============================================================================
-- 4. BULK: movement_pattern for exercises still missing it
-- =============================================================================

-- Curl exercises → isolation (currently some may be NULL)
UPDATE exercises SET movement_pattern = 'isolation'
WHERE movement_pattern IS NULL
  AND (lower(name) LIKE '%curl%' AND lower(name) NOT LIKE '%leg curl%');

-- Tricep exercises → isolation
UPDATE exercises SET movement_pattern = 'isolation'
WHERE movement_pattern IS NULL
  AND (lower(name) LIKE '%tricep%' OR lower(name) LIKE '%pushdown%'
       OR lower(name) LIKE '%skull%crush%');

-- Lateral raises → isolation
UPDATE exercises SET movement_pattern = 'isolation'
WHERE movement_pattern IS NULL
  AND lower(name) LIKE '%lateral%raise%';

-- Calf exercises → isolation
UPDATE exercises SET movement_pattern = 'isolation'
WHERE movement_pattern IS NULL
  AND lower(name) LIKE '%calf%';

-- Fly / crossover → isolation
UPDATE exercises SET movement_pattern = 'isolation'
WHERE movement_pattern IS NULL
  AND (lower(name) LIKE '%fly%' OR lower(name) LIKE '%flye%' OR lower(name) LIKE '%crossover%');

-- Rows → horizontal_pull
UPDATE exercises SET movement_pattern = 'horizontal_pull'
WHERE movement_pattern IS NULL
  AND lower(name) LIKE '%row%';

-- Pulldowns → vertical_pull
UPDATE exercises SET movement_pattern = 'vertical_pull'
WHERE movement_pattern IS NULL
  AND lower(name) LIKE '%pulldown%';

-- Pull-ups / chin-ups → vertical_pull
UPDATE exercises SET movement_pattern = 'vertical_pull'
WHERE movement_pattern IS NULL
  AND (lower(name) LIKE '%pull%up%' OR lower(name) LIKE '%chin%up%');

-- Press (overhead) → vertical_push
UPDATE exercises SET movement_pattern = 'vertical_push'
WHERE movement_pattern IS NULL
  AND (lower(name) LIKE '%shoulder press%' OR lower(name) LIKE '%overhead press%'
       OR lower(name) LIKE '%military press%');

-- Bench press → horizontal_push
UPDATE exercises SET movement_pattern = 'horizontal_push'
WHERE movement_pattern IS NULL
  AND lower(name) LIKE '%bench press%';

-- Push-ups → horizontal_push
UPDATE exercises SET movement_pattern = 'horizontal_push'
WHERE movement_pattern IS NULL
  AND lower(name) LIKE '%push%up%';

-- Squats → squat
UPDATE exercises SET movement_pattern = 'squat'
WHERE movement_pattern IS NULL
  AND lower(name) LIKE '%squat%';

-- Deadlifts → hip_hinge
UPDATE exercises SET movement_pattern = 'hip_hinge'
WHERE movement_pattern IS NULL
  AND lower(name) LIKE '%deadlift%';

-- Lunges → lunge
UPDATE exercises SET movement_pattern = 'lunge'
WHERE movement_pattern IS NULL
  AND (lower(name) LIKE '%lunge%' OR lower(name) LIKE '%step%up%'
       OR lower(name) LIKE '%split squat%');


-- =============================================================================
-- 5. BULK: laterality for exercises still missing it
-- =============================================================================

-- Dumbbell exercises → 'both' (can be done unilateral or bilateral)
UPDATE exercises SET laterality = 'both'
WHERE laterality IS NULL
  AND lower(name) LIKE '%dumbbell%';

-- Barbell exercises → 'bilateral'
UPDATE exercises SET laterality = 'bilateral'
WHERE laterality IS NULL
  AND lower(name) LIKE '%barbell%';

-- Cable exercises → 'both' (most can be done single-arm)
UPDATE exercises SET laterality = 'both'
WHERE laterality IS NULL
  AND lower(name) LIKE '%cable%';

-- Machine exercises → 'bilateral' (most machines are bilateral)
UPDATE exercises SET laterality = 'bilateral'
WHERE laterality IS NULL
  AND (equipment = 'machine' OR lower(name) LIKE '%machine%');

-- Single-arm/single-leg → 'unilateral'
UPDATE exercises SET laterality = 'unilateral'
WHERE laterality IS NULL
  AND (lower(name) LIKE '%single%arm%' OR lower(name) LIKE '%single%leg%'
       OR lower(name) LIKE '%one%arm%' OR lower(name) LIKE '%one%leg%'
       OR lower(name) LIKE '%pistol%');

-- Bodyweight → 'bilateral' (most are bilateral unless already tagged)
UPDATE exercises SET laterality = 'bilateral'
WHERE laterality IS NULL
  AND equipment = 'body only';


COMMIT;
