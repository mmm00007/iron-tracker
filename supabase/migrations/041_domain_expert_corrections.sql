-- Migration 041: Domain Expert Corrections
-- Incorporates feedback from the fitness domain expert agent:
--   1. Expand equipment_category enum with trap_bar, ez_bar, suspension
--   2. Correct specific muscle activation percentages from EMG literature
--   3. Backfill newly-added equipment categories
--
-- Sources:
--   Equipment: Swinton et al. 2011 (trap bar), Marcolin et al. 2018 (EZ bar)
--   Activation: Lehman 2005 (close-grip bench), Escamilla 2009 (face pull),
--     Escamilla 2001 (sumo deadlift), Marcolin 2018 (hammer curl),
--     Trebs 2010 (incline bench), Fenwick 2009 (rows)

BEGIN;

-- =============================================================================
-- 1. EXPAND EQUIPMENT CATEGORY CHECK CONSTRAINT
-- =============================================================================
-- Add trap_bar (hex bar — distinct biomechanics, Swinton 2011),
-- ez_bar (changes wrist angle + brachioradialis ratio, Marcolin 2018),
-- suspension (TRX/rings — distinct stabilization profile).

-- Drop and recreate the constraint on exercises
ALTER TABLE exercises DROP CONSTRAINT IF EXISTS exercises_equipment_category_check;
ALTER TABLE exercises ADD CONSTRAINT exercises_equipment_category_check CHECK (
  equipment_category IN (
    'barbell', 'dumbbell', 'machine', 'cable', 'bodyweight',
    'kettlebell', 'band', 'smith_machine', 'plate_loaded',
    'trap_bar', 'ez_bar', 'suspension', 'other'
  )
);

-- Same on gym_machines
ALTER TABLE gym_machines DROP CONSTRAINT IF EXISTS gym_machines_equipment_category_check;
ALTER TABLE gym_machines ADD CONSTRAINT gym_machines_equipment_category_check CHECK (
  equipment_category IN (
    'barbell', 'dumbbell', 'machine', 'cable', 'bodyweight',
    'kettlebell', 'band', 'smith_machine', 'plate_loaded',
    'trap_bar', 'ez_bar', 'suspension', 'other'
  )
);

-- Same on exercise_equipment bridge table
ALTER TABLE exercise_equipment DROP CONSTRAINT IF EXISTS exercise_equipment_equipment_category_check;
ALTER TABLE exercise_equipment ADD CONSTRAINT exercise_equipment_equipment_category_check CHECK (
  equipment_category IN (
    'barbell', 'dumbbell', 'machine', 'cable', 'bodyweight',
    'kettlebell', 'band', 'smith_machine', 'plate_loaded',
    'trap_bar', 'ez_bar', 'suspension', 'other'
  )
);

-- Same on user_exercise_overrides
ALTER TABLE user_exercise_overrides DROP CONSTRAINT IF EXISTS user_exercise_overrides_preferred_equipment_check;
ALTER TABLE user_exercise_overrides ADD CONSTRAINT user_exercise_overrides_preferred_equipment_check CHECK (
  preferred_equipment_category IS NULL OR preferred_equipment_category IN (
    'barbell', 'dumbbell', 'machine', 'cable', 'bodyweight',
    'kettlebell', 'band', 'smith_machine', 'plate_loaded',
    'trap_bar', 'ez_bar', 'suspension', 'other'
  )
);


-- =============================================================================
-- 2. BACKFILL NEW EQUIPMENT CATEGORIES
-- =============================================================================

-- Trap bar / hex bar exercises
UPDATE exercises
SET equipment_category = 'trap_bar'
WHERE equipment_category IN ('barbell', 'other')
  AND (LOWER(name) LIKE '%trap bar%' OR LOWER(name) LIKE '%hex bar%' OR LOWER(name) LIKE '%hex-bar%');

-- EZ bar exercises
UPDATE exercises
SET equipment_category = 'ez_bar'
WHERE equipment_category IN ('barbell', 'other')
  AND (LOWER(name) LIKE '%ez bar%' OR LOWER(name) LIKE '%ez-bar%' OR LOWER(name) LIKE '%e-z bar%');

-- Suspension / TRX exercises
UPDATE exercises
SET equipment_category = 'suspension'
WHERE equipment_category IN ('bodyweight', 'other')
  AND (LOWER(name) LIKE '%trx%' OR LOWER(name) LIKE '%suspension%' OR LOWER(name) LIKE '%ring%');


-- =============================================================================
-- 3. MUSCLE ACTIVATION CORRECTIONS (EMG-based)
-- =============================================================================
-- These override migration 040 values where the domain expert identified errors.

-- Close-grip bench press: triceps is the PRIMARY mover, not chest
-- Source: Lehman 2005, JSCR — ~20% elevated tricep activation vs standard grip
UPDATE exercise_muscles em
SET activation_percent = 100, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id
  AND em.muscle_group_id = mg.id
  AND LOWER(e.name) LIKE '%close%grip%bench%'
  AND LOWER(mg.name) = 'triceps';

UPDATE exercise_muscles em
SET activation_percent = 70, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id
  AND em.muscle_group_id = mg.id
  AND LOWER(e.name) LIKE '%close%grip%bench%'
  AND LOWER(mg.name) = 'chest';

UPDATE exercise_muscles em
SET activation_percent = 60, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id
  AND em.muscle_group_id = mg.id
  AND LOWER(e.name) LIKE '%close%grip%bench%'
  AND LOWER(mg.name) = 'shoulders';

-- Incline bench press: front delt is higher than migration 040 set
-- Source: Trebs 2010 — anterior deltoid at 44° incline ≈ pec major activation
UPDATE exercise_muscles em
SET activation_percent = 80
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id
  AND em.muscle_group_id = mg.id
  AND LOWER(e.name) LIKE '%incline%bench%'
  AND LOWER(mg.name) = 'shoulders'
  AND em.activation_percent < 80;

-- Face pull: traps are a significant synergist (not just rear delt isolation)
-- Source: Escamilla 2009, AJSM — mid trap 70-80% activation
UPDATE exercise_muscles em
SET activation_percent = 70, function_type = 'synergist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id
  AND em.muscle_group_id = mg.id
  AND LOWER(e.name) LIKE '%face pull%'
  AND LOWER(mg.name) IN ('traps', 'trapezius');

-- Hammer curl: brachioradialis is the PRIMARY target, not a minor synergist
-- Source: Marcolin 2018, PeerJ — neutral grip shifts load to brachioradialis
UPDATE exercise_muscles em
SET activation_percent = 80
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id
  AND em.muscle_group_id = mg.id
  AND LOWER(e.name) LIKE '%hammer curl%'
  AND LOWER(mg.name) = 'biceps';

UPDATE exercise_muscles em
SET activation_percent = 75, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id
  AND em.muscle_group_id = mg.id
  AND LOWER(e.name) LIKE '%hammer curl%'
  AND LOWER(mg.name) = 'forearms';

-- Sumo deadlift: quads and adductors higher, hamstrings lower than conventional
-- Source: Escamilla 2001 — wider stance increases hip abduction demand
UPDATE exercise_muscles em
SET activation_percent = 60
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id
  AND em.muscle_group_id = mg.id
  AND LOWER(e.name) LIKE '%sumo%deadlift%'
  AND LOWER(mg.name) = 'quadriceps';

UPDATE exercise_muscles em
SET activation_percent = 65
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id
  AND em.muscle_group_id = mg.id
  AND LOWER(e.name) LIKE '%sumo%deadlift%'
  AND LOWER(mg.name) = 'hamstrings';

-- Hack squat: glutes are overestimated (machine removes hip extension demand)
UPDATE exercise_muscles em
SET activation_percent = 35
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id
  AND em.muscle_group_id = mg.id
  AND LOWER(e.name) LIKE '%hack squat%'
  AND LOWER(mg.name) = 'glutes';

-- Seated cable row: rhomboids/mid traps higher than generic synergist default
-- Source: Fenwick 2009
UPDATE exercise_muscles em
SET activation_percent = 70
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id
  AND em.muscle_group_id = mg.id
  AND LOWER(e.name) LIKE '%seated%cable%row%'
  AND LOWER(mg.name) IN ('traps', 'trapezius');

-- Upright row: lateral delt is co-primary with traps
-- Source: McAllister 2014, JSCR
UPDATE exercise_muscles em
SET activation_percent = 85, function_type = 'agonist'
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id
  AND em.muscle_group_id = mg.id
  AND LOWER(e.name) LIKE '%upright row%'
  AND LOWER(mg.name) = 'shoulders';

UPDATE exercise_muscles em
SET activation_percent = 90
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id
  AND em.muscle_group_id = mg.id
  AND LOWER(e.name) LIKE '%upright row%'
  AND LOWER(mg.name) IN ('traps', 'trapezius');

-- Romanian deadlift: erector spinae slightly higher than migration 040
-- Source: McAllister 2014
UPDATE exercise_muscles em
SET activation_percent = 65
FROM exercises e, muscle_groups mg
WHERE em.exercise_id = e.id
  AND em.muscle_group_id = mg.id
  AND LOWER(e.name) LIKE '%romanian deadlift%'
  AND LOWER(mg.name) = 'lower back';

COMMIT;
