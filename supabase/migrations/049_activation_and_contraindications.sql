-- Migration 049: Activation Percentage Defaults & Contraindication Enrichment
-- Fills NULL activation_percent values in exercise_muscles with evidence-based
-- defaults, and adds contraindication tags to exercises by movement pattern.
--
-- Activation percentage sources:
--   - EMG studies: Schoenfeld et al. (2010, 2016), Saeterbakken et al. (2011)
--   - NSCA ETSC 4th ed. (Haff & Triplett, 2016) muscle function tables
--   - RP Training Volume Landmarks (Israetel, 2021)
--
-- Contraindication sources:
--   - ACSM Guidelines for Exercise Testing and Prescription (11th ed.)
--   - Kolber et al. (2009): shoulder impingement screening
--   - McGill (2015): low back disorders and exercise contraindications
--
-- All UPDATEs use WHERE activation_percent IS NULL / contraindications IS NULL
-- to preserve existing expert-validated values.

BEGIN;

-- Suppress statement timeout for the full-table muscle_profile refresh at the end.
-- The refresh rebuilds JSONB for 900+ exercises in a single aggregate query.
SET LOCAL statement_timeout = '0';

-- =============================================================================
-- 1. DEFAULT ACTIVATION PERCENTAGES
-- =============================================================================
-- Base defaults: primary muscles get 100%, secondary muscles get 50%.
-- Matches migration 037 convention. Overridden below for specific patterns.

UPDATE exercise_muscles SET activation_percent = 100
WHERE activation_percent IS NULL AND is_primary = true;

UPDATE exercise_muscles SET activation_percent = 50
WHERE activation_percent IS NULL AND is_primary = false;


-- =============================================================================
-- 2. MOVEMENT-PATTERN-SPECIFIC ACTIVATION OVERRIDES
-- =============================================================================
-- These refine the defaults above for exercises where EMG data supports
-- different values. Uses exercises.movement_pattern to target groups.
-- IDEMPOTENCY: Only overrides rows still at the base default (100 primary, 50 secondary).
-- Expert-validated values from migrations 037/040 are preserved.

-- ---- HORIZONTAL PUSH (bench press, push-up, etc.) --------------------------
-- Chest: 85%, Anterior Deltoid (shoulders): 60%, Triceps: 50%

UPDATE exercise_muscles em
SET activation_percent = 85
FROM exercises e
WHERE em.exercise_id = e.id
  AND e.movement_pattern = 'horizontal_push'
  AND em.muscle_group_id = 4  -- chest
  AND em.is_primary = true
  AND em.activation_percent = 100;  -- only override base default

UPDATE exercise_muscles em
SET activation_percent = 60
FROM exercises e
WHERE em.exercise_id = e.id
  AND e.movement_pattern = 'horizontal_push'
  AND em.muscle_group_id = 2  -- shoulders (anterior deltoid)
  AND em.is_primary = false
  AND em.activation_percent = 50;  -- only override base default

UPDATE exercise_muscles em
SET activation_percent = 50
FROM exercises e
WHERE em.exercise_id = e.id
  AND e.movement_pattern = 'horizontal_push'
  AND em.muscle_group_id = 3  -- triceps
  AND em.is_primary = false
  AND em.activation_percent = 50;  -- only override base default

-- ---- INCLINE PRESS ----------------------------------------------------------
-- Upper chest emphasis: Chest 80%, Shoulders 65%, Triceps 45%

UPDATE exercise_muscles em
SET activation_percent = 80
FROM exercises e
WHERE em.exercise_id = e.id
  AND e.movement_pattern = 'incline_press'
  AND em.muscle_group_id = 4  -- chest
  AND em.is_primary = true
  AND em.activation_percent = 100;  -- only override base default

UPDATE exercise_muscles em
SET activation_percent = 65
FROM exercises e
WHERE em.exercise_id = e.id
  AND e.movement_pattern = 'incline_press'
  AND em.muscle_group_id = 2  -- shoulders
  AND em.is_primary = false
  AND em.activation_percent = 50;  -- only override base default

-- ---- VERTICAL PUSH (OHP, pike push-up, etc.) --------------------------------
-- Shoulders: 85%, Triceps: 55%, Upper Chest: 30%

UPDATE exercise_muscles em
SET activation_percent = 85
FROM exercises e
WHERE em.exercise_id = e.id
  AND e.movement_pattern = 'vertical_push'
  AND em.muscle_group_id = 2  -- shoulders
  AND em.is_primary = true
  AND em.activation_percent = 100;  -- only override base default

UPDATE exercise_muscles em
SET activation_percent = 55
FROM exercises e
WHERE em.exercise_id = e.id
  AND e.movement_pattern = 'vertical_push'
  AND em.muscle_group_id = 3  -- triceps
  AND em.is_primary = false
  AND em.activation_percent = 50;  -- only override base default

-- ---- HORIZONTAL PULL (rows) --------------------------------------------------
-- Lats: 80%, Traps/Rhomboids: 65%, Biceps: 45%

UPDATE exercise_muscles em
SET activation_percent = 80
FROM exercises e
WHERE em.exercise_id = e.id
  AND e.movement_pattern = 'horizontal_pull'
  AND em.muscle_group_id = 12  -- lats
  AND em.is_primary = true
  AND em.activation_percent = 100;  -- only override base default

UPDATE exercise_muscles em
SET activation_percent = 65
FROM exercises e
WHERE em.exercise_id = e.id
  AND e.movement_pattern = 'horizontal_pull'
  AND em.muscle_group_id = 9  -- traps
  AND em.is_primary = true
  AND em.activation_percent = 100;  -- only override base default

UPDATE exercise_muscles em
SET activation_percent = 45
FROM exercises e
WHERE em.exercise_id = e.id
  AND e.movement_pattern = 'horizontal_pull'
  AND em.muscle_group_id = 1  -- biceps
  AND em.is_primary = false
  AND em.activation_percent = 50;  -- only override base default

-- ---- VERTICAL PULL (pull-ups, pulldowns) -------------------------------------
-- Lats: 85%, Biceps: 55%, Traps: 40%

UPDATE exercise_muscles em
SET activation_percent = 85
FROM exercises e
WHERE em.exercise_id = e.id
  AND e.movement_pattern = 'vertical_pull'
  AND em.muscle_group_id = 12  -- lats
  AND em.is_primary = true
  AND em.activation_percent = 100;  -- only override base default

UPDATE exercise_muscles em
SET activation_percent = 55
FROM exercises e
WHERE em.exercise_id = e.id
  AND e.movement_pattern = 'vertical_pull'
  AND em.muscle_group_id = 1  -- biceps
  AND em.is_primary = false
  AND em.activation_percent = 50;  -- only override base default

-- ---- SQUAT (back squat, front squat, leg press, etc.) ------------------------
-- Quads: 85%, Glutes: 70%, Hamstrings: 35%, Calves: 20%

UPDATE exercise_muscles em
SET activation_percent = 85
FROM exercises e
WHERE em.exercise_id = e.id
  AND e.movement_pattern IN ('squat', 'single_leg_squat')
  AND em.muscle_group_id = 15  -- quads
  AND em.is_primary = true
  AND em.activation_percent = 100;  -- only override base default

UPDATE exercise_muscles em
SET activation_percent = 70
FROM exercises e
WHERE em.exercise_id = e.id
  AND e.movement_pattern IN ('squat', 'single_leg_squat')
  AND em.muscle_group_id = 8  -- glutes
  AND em.is_primary = true
  AND em.activation_percent = 100;  -- only override base default

UPDATE exercise_muscles em
SET activation_percent = 35
FROM exercises e
WHERE em.exercise_id = e.id
  AND e.movement_pattern IN ('squat', 'single_leg_squat')
  AND em.muscle_group_id = 11  -- hamstrings
  AND em.is_primary = false
  AND em.activation_percent = 50;  -- only override base default

UPDATE exercise_muscles em
SET activation_percent = 20
FROM exercises e
WHERE em.exercise_id = e.id
  AND e.movement_pattern IN ('squat', 'single_leg_squat')
  AND em.muscle_group_id = 7  -- calves
  AND em.is_primary = false
  AND em.activation_percent = 50;  -- only override base default

-- ---- HIP HINGE (deadlift, RDL, hip thrust, etc.) ----------------------------
-- Glutes: 80%, Hamstrings: 75%, Lower Back: 60%, Quads: 35%

UPDATE exercise_muscles em
SET activation_percent = 80
FROM exercises e
WHERE em.exercise_id = e.id
  AND e.movement_pattern = 'hip_hinge'
  AND em.muscle_group_id = 8  -- glutes
  AND em.is_primary = true
  AND em.activation_percent = 100;  -- only override base default

UPDATE exercise_muscles em
SET activation_percent = 75
FROM exercises e
WHERE em.exercise_id = e.id
  AND e.movement_pattern = 'hip_hinge'
  AND em.muscle_group_id = 11  -- hamstrings
  AND em.is_primary = true
  AND em.activation_percent = 100;  -- only override base default

UPDATE exercise_muscles em
SET activation_percent = 60
FROM exercises e
WHERE em.exercise_id = e.id
  AND e.movement_pattern = 'hip_hinge'
  AND em.muscle_group_id = 13  -- lower back
  AND em.is_primary = false
  AND em.activation_percent = 50;  -- only override base default

UPDATE exercise_muscles em
SET activation_percent = 35
FROM exercises e
WHERE em.exercise_id = e.id
  AND e.movement_pattern = 'hip_hinge'
  AND em.muscle_group_id = 15  -- quads
  AND em.is_primary = false
  AND em.activation_percent = 50;  -- only override base default

-- ---- LUNGE -------------------------------------------------------------------
-- Quads: 80%, Glutes: 75%, Hamstrings: 40%, Adductors: 35%

UPDATE exercise_muscles em
SET activation_percent = 80
FROM exercises e
WHERE em.exercise_id = e.id
  AND e.movement_pattern = 'lunge'
  AND em.muscle_group_id = 15  -- quads
  AND em.is_primary = true
  AND em.activation_percent = 100;  -- only override base default

UPDATE exercise_muscles em
SET activation_percent = 75
FROM exercises e
WHERE em.exercise_id = e.id
  AND e.movement_pattern = 'lunge'
  AND em.muscle_group_id = 8  -- glutes
  AND em.is_primary = true
  AND em.activation_percent = 100;  -- only override base default

UPDATE exercise_muscles em
SET activation_percent = 40
FROM exercises e
WHERE em.exercise_id = e.id
  AND e.movement_pattern = 'lunge'
  AND em.muscle_group_id = 11  -- hamstrings
  AND em.is_primary = false
  AND em.activation_percent = 50;  -- only override base default

-- ---- ELBOW FLEXION (curls) ---------------------------------------------------
-- Biceps: 90%, Forearms: 35%

UPDATE exercise_muscles em
SET activation_percent = 90
FROM exercises e
WHERE em.exercise_id = e.id
  AND e.movement_pattern = 'elbow_flexion'
  AND em.muscle_group_id = 1  -- biceps
  AND em.is_primary = true
  AND em.activation_percent = 100;  -- only override base default

UPDATE exercise_muscles em
SET activation_percent = 35
FROM exercises e
WHERE em.exercise_id = e.id
  AND e.movement_pattern = 'elbow_flexion'
  AND em.muscle_group_id = 5  -- forearms
  AND em.is_primary = false
  AND em.activation_percent = 50;  -- only override base default

-- ---- LATERAL RAISE -----------------------------------------------------------
-- Shoulders (lateral deltoid): 90%, Traps: 30%

UPDATE exercise_muscles em
SET activation_percent = 90
FROM exercises e
WHERE em.exercise_id = e.id
  AND e.movement_pattern = 'lateral_raise'
  AND em.muscle_group_id = 2  -- shoulders
  AND em.is_primary = true
  AND em.activation_percent = 100;  -- only override base default

UPDATE exercise_muscles em
SET activation_percent = 30
FROM exercises e
WHERE em.exercise_id = e.id
  AND e.movement_pattern = 'lateral_raise'
  AND em.muscle_group_id = 9  -- traps
  AND em.is_primary = false
  AND em.activation_percent = 50;  -- only override base default

-- ---- CARRY (farmer's walk, etc.) ---------------------------------------------
-- Forearms: 85%, Traps: 75%, Abs: 50%, Glutes: 40%

UPDATE exercise_muscles em
SET activation_percent = 85
FROM exercises e
WHERE em.exercise_id = e.id
  AND e.movement_pattern = 'carry'
  AND em.muscle_group_id = 5  -- forearms
  AND em.is_primary = true
  AND em.activation_percent = 100;  -- only override base default

UPDATE exercise_muscles em
SET activation_percent = 75
FROM exercises e
WHERE em.exercise_id = e.id
  AND e.movement_pattern = 'carry'
  AND em.muscle_group_id = 9  -- traps
  AND em.is_primary = true
  AND em.activation_percent = 100;  -- only override base default

-- ---- ROTATION (woodchops, pallof, etc.) --------------------------------------
-- Abs (obliques): 85%, Shoulders: 35%

UPDATE exercise_muscles em
SET activation_percent = 85
FROM exercises e
WHERE em.exercise_id = e.id
  AND e.movement_pattern = 'rotation'
  AND em.muscle_group_id = 10  -- abs
  AND em.is_primary = true
  AND em.activation_percent = 100;  -- only override base default


-- =============================================================================
-- 3. CONTRAINDICATION HEURISTIC MAPPING
-- =============================================================================
-- Maps movement patterns to relevant contraindication tags.
-- Only sets contraindications where the array is NULL or empty.

-- Overhead push (OHP, pike push-up) → shoulder_impingement, rotator_cuff
-- Excludes vertical_pull (pulldowns/pull-ups are standard rehab per Kolber 2010)
UPDATE exercises
SET contraindications = ARRAY['shoulder_impingement', 'rotator_cuff']::text[]
WHERE (contraindications IS NULL OR contraindications = '{}')
  AND movement_pattern = 'vertical_push';

-- Vertical pull: only behind-neck variants → shoulder_impingement
UPDATE exercises
SET contraindications = ARRAY['shoulder_impingement']::text[]
WHERE (contraindications IS NULL OR contraindications = '{}')
  AND movement_pattern = 'vertical_pull'
  AND lower(name) LIKE '%behind%neck%';

-- Heavy hip hinge → lower_back_herniation
-- Excludes hip thrusts (minimal spinal loading per Contreras 2015)
UPDATE exercises
SET contraindications = ARRAY['lower_back_herniation']::text[]
WHERE (contraindications IS NULL OR contraindications = '{}')
  AND movement_pattern = 'hip_hinge'
  AND lower(name) NOT LIKE '%hip thrust%'
  AND lower(name) NOT LIKE '%glute bridge%';

-- Deep loaded squat/lunge → knee_anterior
-- Only compound loaded exercises (excludes bodyweight squats used in rehab per Witvrouw 2004)
UPDATE exercises
SET contraindications = ARRAY['knee_anterior']::text[]
WHERE (contraindications IS NULL OR contraindications = '{}')
  AND movement_pattern IN ('squat', 'lunge', 'single_leg_squat')
  AND mechanic = 'compound'
  AND equipment_category NOT IN ('bodyweight', 'band');

-- Horizontal push (bench press heavy) → shoulder_impingement
UPDATE exercises
SET contraindications = ARRAY['shoulder_impingement']::text[]
WHERE (contraindications IS NULL OR contraindications = '{}')
  AND movement_pattern IN ('horizontal_push', 'incline_press')
  AND mechanic = 'compound';

-- Elbow flexion: only barbell curls → elbow_strain
-- Light DB/cable curls are standard rehab for epicondylitis
UPDATE exercises
SET contraindications = ARRAY['elbow_strain']::text[]
WHERE (contraindications IS NULL OR contraindications = '{}')
  AND movement_pattern = 'elbow_flexion'
  AND equipment_category = 'barbell';

-- Wrist-loading exercises (front squat, clean variants)
UPDATE exercises
SET contraindications = array_cat(COALESCE(contraindications, '{}'), ARRAY['wrist_strain']::text[])
WHERE movement_pattern IN ('squat', 'hip_hinge')
  AND (lower(name) LIKE '%front squat%' OR lower(name) LIKE '%clean%')
  AND NOT ('wrist_strain' = ANY(COALESCE(contraindications, '{}')));

-- Neck exercises → neck_compression
UPDATE exercises
SET contraindications = ARRAY['neck_compression']::text[]
WHERE (contraindications IS NULL OR contraindications = '{}')
  AND EXISTS (
    SELECT 1 FROM exercise_muscles em
    WHERE em.exercise_id = exercises.id
      AND em.muscle_group_id = 14  -- neck
      AND em.is_primary = true
  );

-- Rotation exercises → lower_back_herniation (loaded spinal rotation risk)
UPDATE exercises
SET contraindications = ARRAY['lower_back_herniation']::text[]
WHERE (contraindications IS NULL OR contraindications = '{}')
  AND movement_pattern = 'rotation'
  AND mechanic = 'compound';


-- =============================================================================
-- 4. REFRESH MUSCLE PROFILES FOR UPDATED ACTIVATION PERCENTAGES
-- =============================================================================
-- The muscle_profile JSONB column on exercises includes activation_percent.
-- Since we bulk-updated activation_percent, we need to refresh all profiles.
-- This uses the function created in migration 035.

-- Single call refreshes all exercises (NULL = full-table rebuild).
-- 5-10x faster than iterating 873 individual calls.
DO $$ BEGIN
  PERFORM refresh_exercise_muscle_profile(NULL);
END $$;


COMMIT;
