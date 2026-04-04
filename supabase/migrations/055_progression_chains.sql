-- Migration 055: Comprehensive Exercise Progression Chains
-- Builds out progression/regression chains for all major movement patterns.
-- Each chain represents a difficulty ladder from easiest → hardest.
--
-- Progression chains power:
-- - "Ready to progress?" notifications (when user plateaus)
-- - "Try this regression" suggestions (when user is injured or deloading)
-- - AI coaching recommendations
-- - New user onboarding paths
--
-- Sources: NSCA ETSC 4th ed. (exercise progression guidelines),
-- Boyle "New Functional Training" (regression/progression ladders),
-- Starting Strength / 5/3/1 (programming progressions)
--
-- Uses ON CONFLICT DO NOTHING for idempotency.

BEGIN;

-- =============================================================================
-- HORIZONTAL PUSH CHAIN
-- Machine Chest Press → Push-Ups → DB Bench Press → BB Bench Press → Close-Grip → Spoto Press → Larsen Press
-- =============================================================================

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, progression_order, notes)
SELECT s.id, t.id, 'progression', 70, 1, 'Machine provides guided path; push-up introduces free stabilization.'
FROM exercises s, exercises t WHERE s.name = 'Machine Chest Press' AND s.created_by IS NULL AND t.name = 'Push-Ups' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, progression_order, notes)
SELECT s.id, t.id, 'progression', 75, 2, 'Push-up to dumbbell adds external load and unilateral demand.'
FROM exercises s, exercises t WHERE s.name = 'Push-Ups' AND s.created_by IS NULL AND t.name = 'Dumbbell Bench Press' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, progression_order, notes)
SELECT s.id, t.id, 'progression', 80, 3, 'Barbell allows heavier loading than dumbbells; bilateral pressing.'
FROM exercises s, exercises t WHERE s.name = 'Dumbbell Bench Press' AND s.created_by IS NULL AND t.name = 'Barbell Bench Press - Medium Grip' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, progression_order, notes)
SELECT s.id, t.id, 'progression', 85, 4, 'Close grip shifts emphasis to triceps; builds lockout strength.'
FROM exercises s, exercises t WHERE s.name = 'Barbell Bench Press - Medium Grip' AND s.created_by IS NULL AND t.name = 'Close-Grip Barbell Bench Press' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

-- =============================================================================
-- VERTICAL PUSH CHAIN
-- Machine Shoulder Press → DB Shoulder Press → BB Shoulder Press → Push Press → Z Press
-- =============================================================================

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, progression_order, notes)
SELECT s.id, t.id, 'progression', 70, 1, 'Machine to dumbbell adds stabilization demand.'
FROM exercises s, exercises t WHERE s.name = 'Shoulder Press Machine' AND s.created_by IS NULL AND t.name = 'Dumbbell Shoulder Press' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, progression_order, notes)
SELECT s.id, t.id, 'progression', 80, 2, 'Barbell allows heavier loading; standing adds core demand.'
FROM exercises s, exercises t WHERE s.name = 'Dumbbell Shoulder Press' AND s.created_by IS NULL AND t.name = 'Barbell Shoulder Press' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, progression_order, notes)
SELECT s.id, t.id, 'progression', 75, 3, 'Push press uses leg drive to overload the overhead position.'
FROM exercises s, exercises t WHERE s.name = 'Barbell Shoulder Press' AND s.created_by IS NULL AND t.name = 'Push Press' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, progression_order, notes)
SELECT s.id, t.id, 'progression', 70, 4, 'Z Press removes all leg drive and back support; strictest overhead variation.'
FROM exercises s, exercises t WHERE s.name = 'Push Press' AND s.created_by IS NULL AND t.name = 'Z Press' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

-- =============================================================================
-- VERTICAL PULL CHAIN
-- Lat Pulldown → Band Assisted Pull-Up → Chin-Up → Pull-Up → Weighted Pull-Up
-- =============================================================================

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, progression_order, notes)
SELECT s.id, t.id, 'progression', 72, 1, 'Pulldown to band-assisted pull-up transitions from machine to bodyweight.'
FROM exercises s, exercises t WHERE s.name = 'Wide-Grip Lat Pulldown' AND s.created_by IS NULL AND t.name = 'Band Assisted Pull-Up' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, progression_order, notes)
SELECT s.id, t.id, 'progression', 80, 2, 'Chin-up (supinated grip) is easier than pull-up due to bicep assistance.'
FROM exercises s, exercises t WHERE s.name = 'Band Assisted Pull-Up' AND s.created_by IS NULL AND t.name = 'Chin-Up' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, progression_order, prerequisite_1rm_ratio, notes)
SELECT s.id, t.id, 'progression', 85, 3, 1.0, 'Pull-up (pronated grip) requires more lat strength than chin-up.'
FROM exercises s, exercises t WHERE s.name = 'Chin-Up' AND s.created_by IS NULL AND t.name = 'Pull-Ups' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

-- =============================================================================
-- HORIZONTAL PULL CHAIN
-- Machine Row → TRX Row → Cable Row → DB Row → Helms Row → BB Row → Pendlay Row
-- =============================================================================

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, progression_order, notes)
SELECT s.id, t.id, 'progression', 68, 1, 'Machine to TRX transitions from fixed path to bodyweight stabilization.'
FROM exercises s, exercises t WHERE s.name = 'Machine Row' AND s.created_by IS NULL AND t.name = 'TRX Row' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, progression_order, notes)
SELECT s.id, t.id, 'progression', 72, 2, 'Cable row adds external load with constant tension.'
FROM exercises s, exercises t WHERE s.name = 'TRX Row' AND s.created_by IS NULL AND t.name = 'Seated Cable Rows' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, progression_order, notes)
SELECT s.id, t.id, 'progression', 75, 3, 'DB row adds unilateral free-weight demand.'
FROM exercises s, exercises t WHERE s.name = 'Seated Cable Rows' AND s.created_by IS NULL AND t.name = 'One-Arm Dumbbell Row' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, progression_order, notes)
SELECT s.id, t.id, 'progression', 78, 4, 'Bent-over row requires hip hinge hold + bilateral pulling.'
FROM exercises s, exercises t WHERE s.name = 'One-Arm Dumbbell Row' AND s.created_by IS NULL AND t.name = 'Bent Over Barbell Row' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

-- =============================================================================
-- SQUAT CHAIN
-- Leg Press → Goblet Squat → Belt Squat → Back Squat → Front Squat → Pause Squat → Safety Bar Squat
-- =============================================================================

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, progression_order, notes)
SELECT s.id, t.id, 'progression', 68, 1, 'Leg press to goblet squat introduces free-standing balance demand.'
FROM exercises s, exercises t WHERE s.name = 'Leg Press' AND s.created_by IS NULL AND t.name = 'Goblet Squat' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, progression_order, notes)
SELECT s.id, t.id, 'progression', 72, 2, 'Belt squat adds loading without spinal compression.'
FROM exercises s, exercises t WHERE s.name = 'Goblet Squat' AND s.created_by IS NULL AND t.name = 'Belt Squat' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, progression_order, prerequisite_1rm_ratio, notes)
SELECT s.id, t.id, 'progression', 80, 3, 0.5, 'Back squat is the standard loaded squat; requires spinal loading.'
FROM exercises s, exercises t WHERE s.name = 'Belt Squat' AND s.created_by IS NULL AND t.name = 'Barbell Full Squat' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, progression_order, prerequisite_1rm_ratio, notes)
SELECT s.id, t.id, 'progression', 82, 4, 1.0, 'Front squat demands more quad strength and thoracic mobility than back squat.'
FROM exercises s, exercises t WHERE s.name = 'Barbell Full Squat' AND s.created_by IS NULL AND t.name = 'Front Squat' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, progression_order, notes)
SELECT s.id, t.id, 'progression', 88, 5, 'Pause squat eliminates stretch reflex; builds bottom-position strength.'
FROM exercises s, exercises t WHERE s.name = 'Barbell Full Squat' AND s.created_by IS NULL AND t.name = 'Pause Squat' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

-- =============================================================================
-- HIP HINGE CHAIN
-- Cable Pull-Through → Kettlebell Swing → Romanian Deadlift → Trap Bar DL → Conventional DL → Sumo DL
-- =============================================================================

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, progression_order, notes)
SELECT s.id, t.id, 'progression', 65, 1, 'Cable pull-through teaches hip hinge; KB swing adds explosive hip extension.'
FROM exercises s, exercises t WHERE s.name = 'Cable Pull-Through' AND s.created_by IS NULL AND t.name = 'One-Arm Kettlebell Swings' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, progression_order, notes)
SELECT s.id, t.id, 'progression', 72, 2, 'RDL adds heavy eccentric loading to the hip hinge pattern.'
FROM exercises s, exercises t WHERE s.name = 'One-Arm Kettlebell Swings' AND s.created_by IS NULL AND t.name = 'Romanian Deadlift' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, progression_order, prerequisite_1rm_ratio, notes)
SELECT s.id, t.id, 'progression', 80, 3, 0.75, 'Trap bar deadlift is mechanically easier than conventional due to handle position.'
FROM exercises s, exercises t WHERE s.name = 'Romanian Deadlift' AND s.created_by IS NULL AND t.name = 'Trap Bar Deadlift' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, progression_order, prerequisite_1rm_ratio, notes)
SELECT s.id, t.id, 'progression', 85, 4, 1.0, 'Conventional deadlift from the floor — the standard barbell hip hinge.'
FROM exercises s, exercises t WHERE s.name = 'Trap Bar Deadlift' AND s.created_by IS NULL AND t.name = 'Barbell Deadlift' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

-- =============================================================================
-- SINGLE-LEG CHAIN
-- Step-Up → Reverse Lunge → Walking Lunge → Bulgarian Split Squat → Pistol Squat
-- =============================================================================

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, progression_order, notes)
SELECT s.id, t.id, 'progression', 72, 1, 'Step-up to reverse lunge adds eccentric lowering demand.'
FROM exercises s, exercises t WHERE s.name = 'Step-Up' AND s.created_by IS NULL AND t.name = 'Reverse Lunge' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, progression_order, notes)
SELECT s.id, t.id, 'progression', 75, 2, 'Walking lunge adds continuous forward movement and balance challenge.'
FROM exercises s, exercises t WHERE s.name = 'Reverse Lunge' AND s.created_by IS NULL AND t.name = 'Walking Lunge' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, progression_order, notes)
SELECT s.id, t.id, 'progression', 78, 3, 'BSS increases ROM and single-leg demand with rear foot elevation.'
FROM exercises s, exercises t WHERE s.name = 'Walking Lunge' AND s.created_by IS NULL AND t.name = 'Bulgarian Split Squat' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, progression_order, prerequisite_1rm_ratio, notes)
SELECT s.id, t.id, 'progression', 65, 4, 1.2, 'Pistol squat requires extreme single-leg strength, mobility, and balance.'
FROM exercises s, exercises t WHERE s.name = 'Bulgarian Split Squat' AND s.created_by IS NULL AND t.name = 'Kettlebell Pistol Squat' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

-- =============================================================================
-- BICEP CHAIN
-- Machine Curl → Cable Curl → DB Curl → BB Curl → Incline DB Curl → Bayesian Cable Curl
-- =============================================================================

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, progression_order, notes)
SELECT s.id, t.id, 'progression', 75, 1, 'Cable provides constant tension vs machine guided path.'
FROM exercises s, exercises t WHERE s.name = 'Machine Bicep Curl' AND s.created_by IS NULL AND t.name = 'Cable Curl' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, progression_order, notes)
SELECT s.id, t.id, 'progression', 80, 2, 'Dumbbell adds unilateral demand and supination through ROM.'
FROM exercises s, exercises t WHERE s.name = 'Cable Curl' AND s.created_by IS NULL AND t.name = 'Dumbbell Bicep Curl' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, progression_order, notes)
SELECT s.id, t.id, 'progression', 85, 3, 'Barbell allows heavier bilateral loading.'
FROM exercises s, exercises t WHERE s.name = 'Dumbbell Bicep Curl' AND s.created_by IS NULL AND t.name = 'Barbell Curl' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, progression_order, notes)
SELECT s.id, t.id, 'progression', 78, 4, 'Incline curl loads the bicep at maximum stretch (shoulder extension).'
FROM exercises s, exercises t WHERE s.name = 'Barbell Curl' AND s.created_by IS NULL AND t.name = 'Incline Dumbbell Curl' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, progression_order, notes)
SELECT s.id, t.id, 'progression', 75, 5, 'Bayesian curl provides constant cable tension at full bicep stretch.'
FROM exercises s, exercises t WHERE s.name = 'Incline Dumbbell Curl' AND s.created_by IS NULL AND t.name = 'Bayesian Cable Curl' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

-- =============================================================================
-- CORE ANTI-EXTENSION CHAIN
-- Dead Bug → Plank → Ab Roller (kneeling) → Bird Dog → Cable Pallof Press
-- =============================================================================

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, progression_order, notes)
SELECT s.id, t.id, 'progression', 70, 1, 'Dead bug to plank transitions from supine to prone anti-extension.'
FROM exercises s, exercises t WHERE s.name = 'Dead Bug' AND s.created_by IS NULL AND t.name = 'Plank' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, progression_order, notes)
SELECT s.id, t.id, 'progression', 72, 2, 'Ab roller extends the lever arm dramatically; much harder than plank.'
FROM exercises s, exercises t WHERE s.name = 'Plank' AND s.created_by IS NULL AND t.name = 'Ab Roller' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

-- =============================================================================
-- PREHAB SHOULDER CHAIN
-- Wall Slide → Band Pull-Apart → Prone Y-T-W → Cable Face Pull → Cable External Rotation
-- =============================================================================

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, progression_order, notes)
SELECT s.id, t.id, 'progression', 60, 1, 'Wall slide assesses baseline mobility; band pull-apart adds light resistance.'
FROM exercises s, exercises t WHERE s.name = 'Wall Slide' AND s.created_by IS NULL AND t.name = 'Band Pull-Apart' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, progression_order, notes)
SELECT s.id, t.id, 'progression', 65, 3, 'Cable face pull adds external rotation under cable load.'
FROM exercises s, exercises t WHERE s.name = 'Prone Y-T-W Raise' AND s.created_by IS NULL AND t.name = 'Cable Face Pull' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, progression_order, notes)
SELECT s.id, t.id, 'progression', 60, 4, 'Cable external rotation isolates the rotator cuff under controlled load.'
FROM exercises s, exercises t WHERE s.name = 'Cable Face Pull' AND s.created_by IS NULL AND t.name = 'Cable External Rotation' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

-- =============================================================================
-- HAMSTRING CHAIN
-- Lying Leg Curl → Seated Leg Curl → Romanian Deadlift → Nordic Hamstring Curl
-- =============================================================================

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, progression_order, notes)
SELECT s.id, t.id, 'progression', 80, 1, 'Seated curl hits hamstrings in a more stretched position than lying.'
FROM exercises s, exercises t WHERE s.name = 'Lying Leg Curls' AND s.created_by IS NULL AND t.name = 'Seated Leg Curl' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, progression_order, notes)
SELECT s.id, t.id, 'progression', 70, 2, 'RDL is a compound hip hinge that heavily loads hamstrings eccentrically.'
FROM exercises s, exercises t WHERE s.name = 'Seated Leg Curl' AND s.created_by IS NULL AND t.name = 'Romanian Deadlift' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, progression_order, prerequisite_1rm_ratio, notes)
SELECT s.id, t.id, 'progression', 60, 3, 1.0, 'Nordic curl is the most demanding hamstring exercise — extreme eccentric loading.'
FROM exercises s, exercises t WHERE s.name = 'Romanian Deadlift' AND s.created_by IS NULL AND t.name = 'Nordic Hamstring Curl' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

-- =============================================================================
-- GLUTE CHAIN
-- Banded Clamshell → Glute Bridge → Hip Thrust → Cable Pull-Through → GHD Back Extension
-- =============================================================================

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, progression_order, notes)
SELECT s.id, t.id, 'progression', 60, 1, 'Clamshell activates glute medius; bridge adds hip extension load.'
FROM exercises s, exercises t WHERE s.name = 'Banded Clamshell' AND s.created_by IS NULL AND t.name = 'Glute Bridge' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, progression_order, notes)
SELECT s.id, t.id, 'progression', 75, 2, 'Hip thrust adds barbell loading to the bridge pattern.'
FROM exercises s, exercises t WHERE s.name = 'Glute Bridge' AND s.created_by IS NULL AND t.name = 'Barbell Hip Thrust' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, progression_order, notes)
SELECT s.id, t.id, 'progression', 70, 3, 'GHD extends the posterior chain through a larger ROM.'
FROM exercises s, exercises t WHERE s.name = 'Barbell Hip Thrust' AND s.created_by IS NULL AND t.name = 'GHD Back Extension' AND t.created_by IS NULL ON CONFLICT DO NOTHING;


COMMIT;
