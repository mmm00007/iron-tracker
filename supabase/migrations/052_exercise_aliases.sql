-- Migration 052: Exercise Aliases Enrichment
-- Populates the aliases column (text[]) with common alternative names for
-- the most frequently searched exercises. Improves search discoverability.
--
-- The aliases column was added in migration 019 with a GIN index.
-- Only updates exercises where aliases IS NULL or empty.

BEGIN;

-- ---- COMPOUND PRESSING -------------------------------------------------------

UPDATE exercises SET aliases = ARRAY['Bench Press', 'Flat Bench', 'BB Bench']
WHERE name = 'Barbell Bench Press - Medium Grip' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

UPDATE exercises SET aliases = ARRAY['Incline Bench', 'Incline Press', 'Incline BB Bench']
WHERE name = 'Incline Barbell Bench Press' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

UPDATE exercises SET aliases = ARRAY['Decline Bench', 'Decline Press']
WHERE name = 'Decline Barbell Bench Press' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

UPDATE exercises SET aliases = ARRAY['Close Grip Bench', 'CG Bench', 'Tricep Bench']
WHERE name = 'Close-Grip Barbell Bench Press' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

UPDATE exercises SET aliases = ARRAY['DB Bench Press', 'Dumbbell Flat Press']
WHERE name = 'Dumbbell Bench Press' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

UPDATE exercises SET aliases = ARRAY['Overhead Press', 'OHP', 'Strict Press', 'Standing Press']
WHERE name = 'Barbell Shoulder Press' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

UPDATE exercises SET aliases = ARRAY['Seated OHP', 'Seated Military Press']
WHERE name = 'Seated Barbell Military Press' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

UPDATE exercises SET aliases = ARRAY['Arnold Shoulder Press']
WHERE name = 'Arnold Dumbbell Press' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

UPDATE exercises SET aliases = ARRAY['DB Shoulder Press', 'DB OHP']
WHERE name = 'Dumbbell Shoulder Press' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

-- ---- SQUATS ------------------------------------------------------------------

UPDATE exercises SET aliases = ARRAY['Back Squat', 'Barbell Squat', 'High Bar Squat', 'Full Squat']
WHERE name = 'Barbell Full Squat' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

UPDATE exercises SET aliases = ARRAY['Front Barbell Squat', 'Front Rack Squat']
WHERE name = 'Front Squat' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

UPDATE exercises SET aliases = ARRAY['Goblet Squat']
WHERE name = 'Goblet Squat' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

UPDATE exercises SET aliases = ARRAY['Box Squat']
WHERE name = 'Box Squat with Bands' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

UPDATE exercises SET aliases = ARRAY['RFESS', 'Rear Foot Elevated Split Squat', 'BSS']
WHERE name = 'Bulgarian Split Squat' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

-- ---- DEADLIFTS ---------------------------------------------------------------

UPDATE exercises SET aliases = ARRAY['Conventional Deadlift', 'Deadlift', 'DL']
WHERE name = 'Barbell Deadlift' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

UPDATE exercises SET aliases = ARRAY['RDL', 'Stiff-Leg Deadlift', 'SLDL', 'Romanian DL']
WHERE name = 'Romanian Deadlift' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

UPDATE exercises SET aliases = ARRAY['Wide Stance Deadlift', 'Sumo DL']
WHERE name = 'Sumo Deadlift' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

UPDATE exercises SET aliases = ARRAY['Trap Bar Deadlift', 'Hex Bar DL']
WHERE name = 'Trap Bar Deadlift' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

-- ---- PULLING -----------------------------------------------------------------

UPDATE exercises SET aliases = ARRAY['Pullup', 'Pull Up', 'Overhand Pull-Up']
WHERE name = 'Pull-Ups' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

UPDATE exercises SET aliases = ARRAY['Chinup', 'Chin Up', 'Underhand Pull-Up', 'Supinated Pull-Up']
WHERE name = 'Chin-Up' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

UPDATE exercises SET aliases = ARRAY['Wide Grip Pull-Up']
WHERE name = 'Wide-Grip Pull-Up' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

UPDATE exercises SET aliases = ARRAY['Lat Pulldown', 'Pulldown', 'Cable Pulldown']
WHERE name = 'Wide-Grip Lat Pulldown' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

UPDATE exercises SET aliases = ARRAY['V-Bar Pulldown', 'Narrow Grip Pulldown']
WHERE name = 'Close-Grip Front Lat Pulldown' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

UPDATE exercises SET aliases = ARRAY['Bent Over Row', 'BB Row', 'Barbell Row', 'BOR']
WHERE name = 'Bent Over Barbell Row' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

UPDATE exercises SET aliases = ARRAY['One Arm DB Row', 'Single Arm Row', 'Lawn Mower']
WHERE name = 'One-Arm Dumbbell Row' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

UPDATE exercises SET aliases = ARRAY['T Bar Row', 'Landmine Row']
WHERE name = 'T-Bar Row' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

UPDATE exercises SET aliases = ARRAY['Cable Row', 'Low Row', 'Horizontal Row']
WHERE name = 'Seated Cable Rows' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

-- ---- ISOLATION UPPER ---------------------------------------------------------

UPDATE exercises SET aliases = ARRAY['Lateral Raise', 'Side Raise', 'DB Lateral Raise', 'Side Delt Raise']
WHERE name = 'Side Lateral Raise' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

UPDATE exercises SET aliases = ARRAY['Front Delt Raise']
WHERE name = 'Front Dumbbell Raise' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

UPDATE exercises SET aliases = ARRAY['Rear Delt Fly', 'Reverse Fly', 'Bent Over Fly']
WHERE name = 'Seated Bent-Over Rear Delt Raise' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

UPDATE exercises SET aliases = ARRAY['Bicep Curl', 'BB Curl', 'Arm Curl', 'Standing Curl']
WHERE name = 'Barbell Curl' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

UPDATE exercises SET aliases = ARRAY['DB Curl', 'Dumbbell Curl', 'Arm Curl']
WHERE name = 'Dumbbell Bicep Curl' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

UPDATE exercises SET aliases = ARRAY['Hammer Curl', 'Neutral Grip Curl']
WHERE name = 'Hammer Curls' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

UPDATE exercises SET aliases = ARRAY['Skull Crusher', 'Skullcrusher', 'French Press', 'Nose Breaker']
WHERE name = 'Lying Triceps Press' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

UPDATE exercises SET aliases = ARRAY['Tricep Pushdown', 'Cable Pushdown', 'Rope Pushdown']
WHERE name = 'Triceps Pushdown - Rope Attachment' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

UPDATE exercises SET aliases = ARRAY['V-Bar Pushdown', 'Tricep Pressdown']
WHERE name = 'Triceps Pushdown - V-Bar Attachment' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

UPDATE exercises SET aliases = ARRAY['Overhead Tricep Extension', 'French Press Cable']
WHERE name = 'Cable Overhead Triceps Extension' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

UPDATE exercises SET aliases = ARRAY['DB Fly', 'Dumbbell Fly', 'Chest Fly']
WHERE name = 'Dumbbell Flyes' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

UPDATE exercises SET aliases = ARRAY['Pec Deck', 'Machine Fly', 'Chest Fly Machine']
WHERE name = 'Butterfly' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

UPDATE exercises SET aliases = ARRAY['Shrug', 'Trap Shrug']
WHERE name = 'Barbell Shrug' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

-- ---- ISOLATION LOWER ---------------------------------------------------------

UPDATE exercises SET aliases = ARRAY['Leg Extension', 'Quad Extension']
WHERE name = 'Leg Extensions' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

UPDATE exercises SET aliases = ARRAY['Ham Curl', 'Hamstring Curl', 'Lying Ham Curl']
WHERE name = 'Lying Leg Curls' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

UPDATE exercises SET aliases = ARRAY['Seated Ham Curl']
WHERE name = 'Seated Leg Curl' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

UPDATE exercises SET aliases = ARRAY['Calf Raise', 'Standing Calf']
WHERE name = 'Standing Calf Raises' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

UPDATE exercises SET aliases = ARRAY['Seated Calf']
WHERE name = 'Seated Calf Raise' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

UPDATE exercises SET aliases = ARRAY['45 Degree Leg Press', 'Sled Press']
WHERE name = 'Leg Press' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

UPDATE exercises SET aliases = ARRAY['Hip Thrust', 'Glute Bridge Barbell']
WHERE name = 'Barbell Hip Thrust' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

-- ---- FUNCTIONAL / NEW EXERCISES (047) ----------------------------------------

UPDATE exercises SET aliases = ARRAY['Nordic Curl', 'Nordic Ham Curl', 'NHC']
WHERE name = 'Nordic Hamstring Curl' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

UPDATE exercises SET aliases = ARRAY['Face Pull', 'Rope Face Pull']
WHERE name = 'Cable Face Pull' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

UPDATE exercises SET aliases = ARRAY['Farmer Walk', 'Farmers Carry', 'Farmer Carry']
WHERE name = 'Farmer''s Walk' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

UPDATE exercises SET aliases = ARRAY['Pull-Through', 'Cable Hip Hinge']
WHERE name = 'Cable Pull-Through' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

UPDATE exercises SET aliases = ARRAY['Woodchop', 'High Woodchop', 'Cable Chop']
WHERE name = 'Cable Woodchop High-to-Low' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

UPDATE exercises SET aliases = ARRAY['Reverse Woodchop', 'Low Woodchop', 'Cable Reverse Chop']
WHERE name = 'Cable Woodchop Low-to-High' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

UPDATE exercises SET aliases = ARRAY['Band Apart', 'Band Pull Apart']
WHERE name = 'Band Pull-Apart' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

-- ---- BODYWEIGHT ---------------------------------------------------------------

UPDATE exercises SET aliases = ARRAY['Push Up', 'Pushup', 'Press Up']
WHERE name = 'Push-Ups' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

UPDATE exercises SET aliases = ARRAY['Diamond Push Up', 'Close Grip Push Up', 'Tricep Push Up']
WHERE name = 'Diamond Push-Up' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

UPDATE exercises SET aliases = ARRAY['Chest Dip', 'Parallel Bar Dip']
WHERE name = 'Dips - Chest Version' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

UPDATE exercises SET aliases = ARRAY['Tricep Dip', 'Parallel Bar Dip']
WHERE name = 'Dips - Triceps Version' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

UPDATE exercises SET aliases = ARRAY['Bench Dip', 'Chair Dip', 'Tricep Bench Dip']
WHERE name = 'Bench Dips' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

UPDATE exercises SET aliases = ARRAY['Front Plank', 'Elbow Plank']
WHERE name = 'Plank' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

UPDATE exercises SET aliases = ARRAY['Bodyweight Lunge', 'Walking Lunge']
WHERE name = 'Lunge' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;


COMMIT;
