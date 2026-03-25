-- Migration 030: Seed Data for Exercise Depth Enrichment
-- Seeds biomechanical metadata (primary_joints, movement_plane, stability_demand,
-- contraction_emphasis) and coaching cues for the most common exercises.
--
-- Validated by: fitness-domain-expert agent
--
-- Methodology:
--   - Top ~50 exercises selected by popularity in commercial gym tracking apps
--     (STRONG, Hevy, GymShark) and evidence-based programming (NSCA, RP, 5/3/1)
--   - primary_joints from Neumann, Kinesiology of the Musculoskeletal System, 3rd ed.
--   - stability_demand scale: 1=machine, 2=Smith, 3=cable, 4=free weight bilateral, 5=unilateral
--   - movement_plane from Floyd, Manual of Structural Kinesiology, 21st ed.
--   - contraction_emphasis: default 'standard' unless exercise has distinct emphasis
--   - Cues from NSCA CSCS manual + practical coaching consensus

BEGIN;

-- =============================================================================
-- 1. BIOMECHANICAL METADATA: Major compound lifts
-- =============================================================================

-- Barbell Squat
UPDATE exercises SET
  primary_joints = '{hip,knee,ankle}',
  movement_plane = 'sagittal',
  stability_demand = 4,
  contraction_emphasis = 'standard'
WHERE name = 'Barbell Squat' AND NOT is_custom;

-- Barbell Deadlift
UPDATE exercises SET
  primary_joints = '{hip,knee,spine}',
  movement_plane = 'sagittal',
  stability_demand = 4,
  contraction_emphasis = 'standard'
WHERE name = 'Barbell Deadlift' AND NOT is_custom;

-- Barbell Bench Press
UPDATE exercises SET
  primary_joints = '{shoulder,elbow}',
  movement_plane = 'sagittal',
  stability_demand = 4,
  contraction_emphasis = 'standard'
WHERE name IN ('Barbell Bench Press', 'Bench Press') AND NOT is_custom;

-- Barbell Overhead Press / Military Press
UPDATE exercises SET
  primary_joints = '{shoulder,elbow}',
  movement_plane = 'sagittal',
  stability_demand = 4,
  contraction_emphasis = 'standard'
WHERE name IN ('Barbell Shoulder Press', 'Standing Military Press',
               'Seated Barbell Military Press') AND NOT is_custom;

-- Barbell Row
UPDATE exercises SET
  primary_joints = '{shoulder,elbow,spine}',
  movement_plane = 'sagittal',
  stability_demand = 4,
  contraction_emphasis = 'standard'
WHERE name IN ('Barbell Row', 'Bent Over Barbell Row', 'Pendlay Row') AND NOT is_custom;

-- Front Squat
UPDATE exercises SET
  primary_joints = '{hip,knee,ankle}',
  movement_plane = 'sagittal',
  stability_demand = 4,
  contraction_emphasis = 'standard'
WHERE name = 'Front Squat' AND NOT is_custom;

-- Romanian Deadlift
UPDATE exercises SET
  primary_joints = '{hip,knee}',
  movement_plane = 'sagittal',
  stability_demand = 4,
  contraction_emphasis = 'standard'
WHERE name IN ('Romanian Deadlift', 'Barbell Romanian Deadlift') AND NOT is_custom;

-- Sumo Deadlift
UPDATE exercises SET
  primary_joints = '{hip,knee,spine}',
  movement_plane = 'sagittal',
  stability_demand = 4,
  contraction_emphasis = 'standard'
WHERE name = 'Sumo Deadlift' AND NOT is_custom;

-- Incline Bench Press
UPDATE exercises SET
  primary_joints = '{shoulder,elbow}',
  movement_plane = 'sagittal',
  stability_demand = 4,
  contraction_emphasis = 'standard'
WHERE name IN ('Incline Barbell Bench Press', 'Incline Bench Press') AND NOT is_custom;

-- Push Press
UPDATE exercises SET
  primary_joints = '{shoulder,elbow,hip,knee}',
  movement_plane = 'sagittal',
  stability_demand = 4,
  contraction_emphasis = 'ballistic'
WHERE name = 'Push Press' AND NOT is_custom;


-- =============================================================================
-- 2. BIOMECHANICAL METADATA: Dumbbell compounds
-- =============================================================================

-- Dumbbell Bench Press
UPDATE exercises SET
  primary_joints = '{shoulder,elbow}',
  movement_plane = 'sagittal',
  stability_demand = 4,
  contraction_emphasis = 'standard'
WHERE name IN ('Dumbbell Bench Press', 'Flat Dumbbell Press') AND NOT is_custom;

-- Dumbbell Shoulder Press
UPDATE exercises SET
  primary_joints = '{shoulder,elbow}',
  movement_plane = 'sagittal',
  stability_demand = 4,
  contraction_emphasis = 'standard'
WHERE name IN ('Dumbbell Shoulder Press', 'Seated Dumbbell Press') AND NOT is_custom;

-- Dumbbell Row
UPDATE exercises SET
  primary_joints = '{shoulder,elbow}',
  movement_plane = 'sagittal',
  stability_demand = 5,
  contraction_emphasis = 'standard'
WHERE name IN ('Dumbbell Row', 'One Arm Dumbbell Row', 'Single Arm Dumbbell Row') AND NOT is_custom;

-- Dumbbell Lunge
UPDATE exercises SET
  primary_joints = '{hip,knee,ankle}',
  movement_plane = 'sagittal',
  stability_demand = 5,
  contraction_emphasis = 'standard'
WHERE name IN ('Dumbbell Lunge', 'Walking Lunge', 'Dumbbell Walking Lunge') AND NOT is_custom;

-- Bulgarian Split Squat
UPDATE exercises SET
  primary_joints = '{hip,knee,ankle}',
  movement_plane = 'sagittal',
  stability_demand = 5,
  contraction_emphasis = 'standard'
WHERE name IN ('Bulgarian Split Squat', 'Dumbbell Bulgarian Split Squat') AND NOT is_custom;


-- =============================================================================
-- 3. BIOMECHANICAL METADATA: Machine exercises
-- =============================================================================

-- Leg Press
UPDATE exercises SET
  primary_joints = '{hip,knee}',
  movement_plane = 'sagittal',
  stability_demand = 1,
  contraction_emphasis = 'standard'
WHERE name IN ('Leg Press', '45 Degree Leg Press', 'Machine Leg Press') AND NOT is_custom;

-- Leg Extension
UPDATE exercises SET
  primary_joints = '{knee}',
  movement_plane = 'sagittal',
  stability_demand = 1,
  contraction_emphasis = 'standard'
WHERE name IN ('Leg Extension', 'Machine Leg Extension') AND NOT is_custom;

-- Leg Curl
UPDATE exercises SET
  primary_joints = '{knee}',
  movement_plane = 'sagittal',
  stability_demand = 1,
  contraction_emphasis = 'standard'
WHERE name IN ('Leg Curl', 'Lying Leg Curl', 'Seated Leg Curl', 'Machine Leg Curl') AND NOT is_custom;

-- Chest Press Machine
UPDATE exercises SET
  primary_joints = '{shoulder,elbow}',
  movement_plane = 'sagittal',
  stability_demand = 1,
  contraction_emphasis = 'standard'
WHERE name IN ('Machine Chest Press', 'Chest Press Machine', 'Seated Machine Press') AND NOT is_custom;

-- Lat Pulldown
UPDATE exercises SET
  primary_joints = '{shoulder,elbow}',
  movement_plane = 'sagittal',
  stability_demand = 1,
  contraction_emphasis = 'standard'
WHERE name IN ('Lat Pulldown', 'Wide Grip Lat Pulldown', 'Close Grip Lat Pulldown') AND NOT is_custom;

-- Seated Cable Row
UPDATE exercises SET
  primary_joints = '{shoulder,elbow}',
  movement_plane = 'sagittal',
  stability_demand = 3,
  contraction_emphasis = 'standard'
WHERE name IN ('Seated Cable Row', 'Cable Row', 'Seated Row') AND NOT is_custom;

-- Smith Machine Squat
UPDATE exercises SET
  primary_joints = '{hip,knee,ankle}',
  movement_plane = 'sagittal',
  stability_demand = 2,
  contraction_emphasis = 'standard'
WHERE name IN ('Smith Machine Squat', 'Smith Squat') AND NOT is_custom;

-- Hack Squat
UPDATE exercises SET
  primary_joints = '{hip,knee}',
  movement_plane = 'sagittal',
  stability_demand = 1,
  contraction_emphasis = 'standard'
WHERE name IN ('Hack Squat', 'Machine Hack Squat') AND NOT is_custom;


-- =============================================================================
-- 4. BIOMECHANICAL METADATA: Isolation exercises
-- =============================================================================

-- Barbell Curl
UPDATE exercises SET
  primary_joints = '{elbow}',
  movement_plane = 'sagittal',
  stability_demand = 4,
  contraction_emphasis = 'standard'
WHERE name IN ('Barbell Curl', 'Standing Barbell Curl') AND NOT is_custom;

-- Dumbbell Bicep Curl
UPDATE exercises SET
  primary_joints = '{elbow}',
  movement_plane = 'sagittal',
  stability_demand = 4,
  contraction_emphasis = 'standard'
WHERE name IN ('Dumbbell Bicep Curl', 'Dumbbell Curl', 'Standing Dumbbell Curl') AND NOT is_custom;

-- Hammer Curls
UPDATE exercises SET
  primary_joints = '{elbow}',
  movement_plane = 'sagittal',
  stability_demand = 4,
  contraction_emphasis = 'standard'
WHERE name IN ('Hammer Curls', 'Dumbbell Hammer Curl') AND NOT is_custom;

-- Triceps Pushdown
UPDATE exercises SET
  primary_joints = '{elbow}',
  movement_plane = 'sagittal',
  stability_demand = 3,
  contraction_emphasis = 'standard'
WHERE name IN ('Triceps Pushdown', 'Cable Triceps Pushdown', 'Tricep Pushdown') AND NOT is_custom;

-- Overhead Triceps Extension
UPDATE exercises SET
  primary_joints = '{elbow,shoulder}',
  movement_plane = 'sagittal',
  stability_demand = 4,
  contraction_emphasis = 'standard'
WHERE name IN ('Overhead Triceps Extension', 'Dumbbell Overhead Triceps Extension') AND NOT is_custom;

-- Lateral Raise
UPDATE exercises SET
  primary_joints = '{shoulder}',
  movement_plane = 'frontal',
  stability_demand = 4,
  contraction_emphasis = 'standard'
WHERE name IN ('Lateral Raise', 'Dumbbell Lateral Raise', 'Side Lateral Raise') AND NOT is_custom;

-- Front Raise
UPDATE exercises SET
  primary_joints = '{shoulder}',
  movement_plane = 'sagittal',
  stability_demand = 4,
  contraction_emphasis = 'standard'
WHERE name = 'Front Raise' AND NOT is_custom;

-- Face Pull
UPDATE exercises SET
  primary_joints = '{shoulder,elbow}',
  movement_plane = 'transverse',
  stability_demand = 3,
  contraction_emphasis = 'standard'
WHERE name = 'Face Pull' AND NOT is_custom;

-- Reverse Fly / Rear Delt Fly
UPDATE exercises SET
  primary_joints = '{shoulder}',
  movement_plane = 'transverse',
  stability_demand = 4,
  contraction_emphasis = 'standard'
WHERE name IN ('Reverse Fly', 'Rear Delt Fly', 'Dumbbell Reverse Fly') AND NOT is_custom;

-- Cable Fly / Chest Fly
UPDATE exercises SET
  primary_joints = '{shoulder}',
  movement_plane = 'transverse',
  stability_demand = 3,
  contraction_emphasis = 'standard'
WHERE name IN ('Cable Fly', 'Cable Crossover', 'Pec Fly', 'Machine Fly') AND NOT is_custom;

-- Calf Raise
UPDATE exercises SET
  primary_joints = '{ankle}',
  movement_plane = 'sagittal',
  stability_demand = 1,
  contraction_emphasis = 'standard'
WHERE name IN ('Calf Raise', 'Standing Calf Raise', 'Seated Calf Raise',
               'Machine Calf Raise', 'Smith Machine Calf Raise') AND NOT is_custom;


-- =============================================================================
-- 5. BIOMECHANICAL METADATA: Bodyweight & special exercises
-- =============================================================================

-- Pull-Up
UPDATE exercises SET
  primary_joints = '{shoulder,elbow}',
  movement_plane = 'sagittal',
  stability_demand = 5,
  contraction_emphasis = 'standard'
WHERE name IN ('Pull-Up', 'Pull Up', 'Pullup', 'Chin-Up', 'Chin Up') AND NOT is_custom;

-- Dip
UPDATE exercises SET
  primary_joints = '{shoulder,elbow}',
  movement_plane = 'sagittal',
  stability_demand = 5,
  contraction_emphasis = 'standard'
WHERE name IN ('Dip', 'Dips', 'Parallel Bar Dip', 'Tricep Dip') AND NOT is_custom;

-- Push-Up
UPDATE exercises SET
  primary_joints = '{shoulder,elbow}',
  movement_plane = 'sagittal',
  stability_demand = 5,
  contraction_emphasis = 'standard'
WHERE name IN ('Push-Up', 'Push Up', 'Pushup') AND NOT is_custom;

-- Plank
UPDATE exercises SET
  primary_joints = '{spine}',
  movement_plane = 'sagittal',
  stability_demand = 5,
  contraction_emphasis = 'isometric'
WHERE name IN ('Plank', 'Front Plank', 'Forearm Plank') AND NOT is_custom;

-- Side Plank
UPDATE exercises SET
  primary_joints = '{spine}',
  movement_plane = 'frontal',
  stability_demand = 5,
  contraction_emphasis = 'isometric'
WHERE name IN ('Side Plank') AND NOT is_custom;

-- Wall Sit
UPDATE exercises SET
  primary_joints = '{hip,knee}',
  movement_plane = 'sagittal',
  stability_demand = 5,
  contraction_emphasis = 'isometric'
WHERE name IN ('Wall Sit', 'Wall Squat') AND NOT is_custom;

-- Box Jump
UPDATE exercises SET
  primary_joints = '{hip,knee,ankle}',
  movement_plane = 'sagittal',
  stability_demand = 5,
  contraction_emphasis = 'plyometric'
WHERE name IN ('Box Jump', 'Box Jumps') AND NOT is_custom;

-- Nordic Hamstring Curl
UPDATE exercises SET
  primary_joints = '{knee}',
  movement_plane = 'sagittal',
  stability_demand = 5,
  contraction_emphasis = 'eccentric_emphasis'
WHERE name IN ('Nordic Hamstring Curl', 'Nordic Curl') AND NOT is_custom;

-- Kettlebell Swing
UPDATE exercises SET
  primary_joints = '{hip,knee}',
  movement_plane = 'sagittal',
  stability_demand = 4,
  contraction_emphasis = 'ballistic'
WHERE name IN ('Kettlebell Swing', 'Kettlebell Swings') AND NOT is_custom;

-- Clean and Jerk / Power Clean
UPDATE exercises SET
  primary_joints = '{hip,knee,ankle,shoulder,elbow}',
  movement_plane = 'sagittal',
  stability_demand = 5,
  contraction_emphasis = 'ballistic'
WHERE name IN ('Clean and Jerk', 'Power Clean', 'Hang Clean') AND NOT is_custom;

-- Snatch
UPDATE exercises SET
  primary_joints = '{hip,knee,ankle,shoulder,elbow}',
  movement_plane = 'sagittal',
  stability_demand = 5,
  contraction_emphasis = 'ballistic'
WHERE name IN ('Snatch', 'Power Snatch', 'Hang Snatch') AND NOT is_custom;

-- Cable Woodchop
UPDATE exercises SET
  primary_joints = '{spine,hip,shoulder}',
  movement_plane = 'transverse',
  stability_demand = 3,
  contraction_emphasis = 'standard'
WHERE name IN ('Cable Woodchop', 'Cable Wood Chop', 'Woodchop') AND NOT is_custom;

-- Russian Twist
UPDATE exercises SET
  primary_joints = '{spine}',
  movement_plane = 'transverse',
  stability_demand = 5,
  contraction_emphasis = 'standard'
WHERE name IN ('Russian Twist', 'Russian Twists') AND NOT is_custom;

-- Hip Thrust
UPDATE exercises SET
  primary_joints = '{hip}',
  movement_plane = 'sagittal',
  stability_demand = 4,
  contraction_emphasis = 'standard'
WHERE name IN ('Hip Thrust', 'Barbell Hip Thrust') AND NOT is_custom;

-- Ab Crunch / Sit-Up
UPDATE exercises SET
  primary_joints = '{spine}',
  movement_plane = 'sagittal',
  stability_demand = 5,
  contraction_emphasis = 'standard'
WHERE name IN ('Crunch', 'Crunches', 'Sit-Up', 'Sit Up', 'Ab Crunch') AND NOT is_custom;


-- =============================================================================
-- 6. EXERCISE CUES: Top 10 most common exercises
-- =============================================================================

-- Barbell Squat cues
INSERT INTO exercise_cues (exercise_id, cue_type, cue_text, display_order)
SELECT e.id, cue.cue_type, cue.cue_text, cue.display_order
FROM exercises e
CROSS JOIN (VALUES
  ('setup',        'Feet shoulder-width apart, toes turned out 15-30 degrees', 1),
  ('setup',        'Bar on upper traps (high bar) or rear delts (low bar), grip just outside shoulders', 2),
  ('bracing',      'Big belly breath, brace core 360 degrees against your belt', 1),
  ('execution',    'Break at hips and knees simultaneously, sit between your legs', 1),
  ('execution',    'Drive through midfoot, push knees out over toes', 2),
  ('breathing',    'Inhale and brace at top, hold through the rep, exhale at lockout', 1),
  ('safety',       'Keep neutral spine — do not round lower back at the bottom', 1),
  ('common_fault', 'Hips rising faster than shoulders (good-morning squat) — cue chest up', 1),
  ('common_fault', 'Knees caving inward — cue spread the floor with your feet', 2)
) AS cue(cue_type, cue_text, display_order)
WHERE e.name = 'Barbell Squat' AND NOT e.is_custom
ON CONFLICT (exercise_id, cue_type, display_order) DO NOTHING;

-- Barbell Bench Press cues
INSERT INTO exercise_cues (exercise_id, cue_type, cue_text, display_order)
SELECT e.id, cue.cue_type, cue.cue_text, cue.display_order
FROM exercises e
CROSS JOIN (VALUES
  ('setup',        'Eyes under the bar, feet flat on floor, 5-point contact (head, shoulders, glutes, feet)', 1),
  ('setup',        'Retract and depress scapulae — squeeze shoulder blades together and down', 2),
  ('bracing',      'Arch upper back, drive shoulders into bench, fill chest with air', 1),
  ('execution',    'Unrack with locked arms, lower bar to nipple line under control', 1),
  ('execution',    'Drive bar up and slightly back toward the rack, lock elbows at top', 2),
  ('breathing',    'Inhale on the descent, exhale through the sticking point', 1),
  ('safety',       'Always use a spotter or safety pins for heavy sets', 1),
  ('common_fault', 'Elbows flaring to 90 degrees — keep elbows at 45-75 degree angle', 1),
  ('common_fault', 'Bouncing bar off chest — brief touch, no bounce', 2)
) AS cue(cue_type, cue_text, display_order)
WHERE e.name IN ('Barbell Bench Press', 'Bench Press') AND NOT e.is_custom
ON CONFLICT (exercise_id, cue_type, display_order) DO NOTHING;

-- Barbell Deadlift cues
INSERT INTO exercise_cues (exercise_id, cue_type, cue_text, display_order)
SELECT e.id, cue.cue_type, cue.cue_text, cue.display_order
FROM exercises e
CROSS JOIN (VALUES
  ('setup',        'Feet hip-width apart, bar over midfoot, shins 1 inch from bar', 1),
  ('setup',        'Grip just outside knees (double overhand, hook, or mixed)', 2),
  ('bracing',      'Push belly into belt, pull slack out of bar before lifting', 1),
  ('execution',    'Push floor away with legs, keep bar against body the entire pull', 1),
  ('execution',    'Lock out by squeezing glutes forward, do not hyperextend lower back', 2),
  ('breathing',    'Inhale and brace before each rep, exhale at lockout', 1),
  ('safety',       'Keep lower back neutral — if it rounds, the weight is too heavy', 1),
  ('safety',       'Do not jerk the bar off the floor — smooth acceleration', 2),
  ('common_fault', 'Hips shooting up first (stiff-leg deadlift) — cue push the floor away', 1),
  ('common_fault', 'Bar drifting away from body — keep lats engaged, pull bar into shins', 2)
) AS cue(cue_type, cue_text, display_order)
WHERE e.name = 'Barbell Deadlift' AND NOT e.is_custom
ON CONFLICT (exercise_id, cue_type, display_order) DO NOTHING;

-- Barbell Overhead Press cues
INSERT INTO exercise_cues (exercise_id, cue_type, cue_text, display_order)
SELECT e.id, cue.cue_type, cue.cue_text, cue.display_order
FROM exercises e
CROSS JOIN (VALUES
  ('setup',        'Feet hip-width apart, bar resting on front delts, grip just outside shoulders', 1),
  ('bracing',      'Squeeze glutes, brace core hard — no leaning back', 1),
  ('execution',    'Press bar straight up, move head through once bar passes forehead', 1),
  ('execution',    'Lock out with bar directly over midfoot, shrug shoulders at top', 2),
  ('breathing',    'Inhale at bottom, exhale through the press', 1),
  ('safety',       'Do not excessively arch lower back — squeeze glutes to stay upright', 1),
  ('common_fault', 'Pressing bar forward instead of straight up — bar path should be vertical', 1)
) AS cue(cue_type, cue_text, display_order)
WHERE e.name IN ('Barbell Shoulder Press', 'Standing Military Press') AND NOT e.is_custom
ON CONFLICT (exercise_id, cue_type, display_order) DO NOTHING;

-- Barbell Row cues
INSERT INTO exercise_cues (exercise_id, cue_type, cue_text, display_order)
SELECT e.id, cue.cue_type, cue.cue_text, cue.display_order
FROM exercises e
CROSS JOIN (VALUES
  ('setup',        'Hinge forward 45-70 degrees, bar hanging at arms length, knees slightly bent', 1),
  ('bracing',      'Brace core, maintain rigid torso — do not swing the weight', 1),
  ('execution',    'Pull bar to lower chest/upper belly, drive elbows behind you', 1),
  ('execution',    'Squeeze shoulder blades together at top, control the descent', 2),
  ('breathing',    'Exhale on the pull, inhale as you lower', 1),
  ('safety',       'Keep lower back neutral — if torso rises during the row, weight is too heavy', 1),
  ('common_fault', 'Using momentum/body English — reduce weight, strict form', 1)
) AS cue(cue_type, cue_text, display_order)
WHERE e.name IN ('Barbell Row', 'Bent Over Barbell Row') AND NOT e.is_custom
ON CONFLICT (exercise_id, cue_type, display_order) DO NOTHING;

-- Pull-Up cues
INSERT INTO exercise_cues (exercise_id, cue_type, cue_text, display_order)
SELECT e.id, cue.cue_type, cue.cue_text, cue.display_order
FROM exercises e
CROSS JOIN (VALUES
  ('setup',        'Grip bar slightly wider than shoulder width, full dead hang to start', 1),
  ('bracing',      'Engage lats by depressing shoulders — pull shoulder blades down and back', 1),
  ('execution',    'Pull elbows down and back, chin above bar at the top', 1),
  ('execution',    'Control the descent — full range of motion to dead hang', 2),
  ('mind_muscle',  'Think about driving elbows into your back pockets, not pulling with hands', 1),
  ('common_fault', 'Kipping or swinging — strict pull-ups build more strength and muscle', 1),
  ('common_fault', 'Half reps / not reaching full extension at bottom', 2)
) AS cue(cue_type, cue_text, display_order)
WHERE e.name IN ('Pull-Up', 'Pull Up', 'Pullup') AND NOT e.is_custom
ON CONFLICT (exercise_id, cue_type, display_order) DO NOTHING;

-- Romanian Deadlift cues
INSERT INTO exercise_cues (exercise_id, cue_type, cue_text, display_order)
SELECT e.id, cue.cue_type, cue.cue_text, cue.display_order
FROM exercises e
CROSS JOIN (VALUES
  ('setup',        'Stand tall with bar at hip height, feet hip-width, slight knee bend', 1),
  ('bracing',      'Brace core, pull shoulders back — maintain stiff upper back throughout', 1),
  ('execution',    'Hinge at hips, push hips back, slide bar down thighs — feel hamstring stretch', 1),
  ('execution',    'Reverse by driving hips forward, squeeze glutes at top', 2),
  ('breathing',    'Inhale on the way down (eccentric), exhale on the way up', 1),
  ('safety',       'Stop descent when you feel max hamstring stretch — do not round lower back', 1),
  ('common_fault', 'Bending knees too much (turning it into a conventional DL) — keep legs stiff', 1)
) AS cue(cue_type, cue_text, display_order)
WHERE e.name IN ('Romanian Deadlift', 'Barbell Romanian Deadlift') AND NOT e.is_custom
ON CONFLICT (exercise_id, cue_type, display_order) DO NOTHING;

-- Lat Pulldown cues
INSERT INTO exercise_cues (exercise_id, cue_type, cue_text, display_order)
SELECT e.id, cue.cue_type, cue.cue_text, cue.display_order
FROM exercises e
CROSS JOIN (VALUES
  ('setup',        'Grip bar just outside shoulder width, thighs locked under pad', 1),
  ('bracing',      'Lean back slightly (10-15 degrees), puff chest up toward the bar', 1),
  ('execution',    'Pull bar to upper chest, drive elbows down and toward hips', 1),
  ('execution',    'Control the return — full extension at top, feel lat stretch', 2),
  ('mind_muscle',  'Focus on pulling with elbows, not hands — hands are hooks', 1),
  ('common_fault', 'Pulling bar behind neck — increases shoulder impingement risk, pull to chest', 1),
  ('common_fault', 'Excessive body lean/momentum — stay relatively upright', 2)
) AS cue(cue_type, cue_text, display_order)
WHERE e.name IN ('Lat Pulldown', 'Wide Grip Lat Pulldown') AND NOT e.is_custom
ON CONFLICT (exercise_id, cue_type, display_order) DO NOTHING;

-- Dumbbell Bench Press cues
INSERT INTO exercise_cues (exercise_id, cue_type, cue_text, display_order)
SELECT e.id, cue.cue_type, cue.cue_text, cue.display_order
FROM exercises e
CROSS JOIN (VALUES
  ('setup',        'Sit on bench edge with dumbbells on thighs, kick them up as you lie back', 1),
  ('setup',        'Retract scapulae, plant feet flat, maintain natural arch', 2),
  ('execution',    'Press dumbbells up and slightly inward, touch at top without clanking', 1),
  ('execution',    'Lower with control to chest level, elbows at 45-degree angle', 2),
  ('breathing',    'Inhale on descent, exhale through the press', 1),
  ('safety',       'At failure, lower dumbbells to thighs and sit up — do not drop sideways', 1),
  ('common_fault', 'Dumbbells drifting toward belly — keep press line at mid-chest', 1)
) AS cue(cue_type, cue_text, display_order)
WHERE e.name IN ('Dumbbell Bench Press', 'Flat Dumbbell Press') AND NOT e.is_custom
ON CONFLICT (exercise_id, cue_type, display_order) DO NOTHING;

-- Lateral Raise cues
INSERT INTO exercise_cues (exercise_id, cue_type, cue_text, display_order)
SELECT e.id, cue.cue_type, cue.cue_text, cue.display_order
FROM exercises e
CROSS JOIN (VALUES
  ('setup',        'Stand tall, slight forward lean, dumbbells at sides with soft elbows', 1),
  ('execution',    'Raise arms to shoulder height, lead with elbows not hands', 1),
  ('execution',    'Control the descent — 2-3 second negative for maximum delt activation', 2),
  ('mind_muscle',  'Imagine pouring water from a pitcher at the top — slight internal rotation', 1),
  ('safety',       'Do not raise above shoulder height — increases impingement risk', 1),
  ('common_fault', 'Using momentum/swinging — reduce weight, strict slow reps', 1),
  ('common_fault', 'Shrugging traps — keep shoulders depressed throughout', 2)
) AS cue(cue_type, cue_text, display_order)
WHERE e.name IN ('Lateral Raise', 'Dumbbell Lateral Raise', 'Side Lateral Raise') AND NOT e.is_custom
ON CONFLICT (exercise_id, cue_type, display_order) DO NOTHING;


-- =============================================================================
-- 7. BULK DEFAULTS: Set contraction_emphasis = 'standard' for all unset exercises
-- =============================================================================

-- Most exercises are standard isotonic (concentric + eccentric). Set default
-- for any seed exercise that wasn't explicitly tagged above.
-- Custom (user-created) exercises will get the column default via migration 029.
UPDATE exercises
SET contraction_emphasis = 'standard'
WHERE contraction_emphasis IS NULL
  AND NOT is_custom;


COMMIT;
