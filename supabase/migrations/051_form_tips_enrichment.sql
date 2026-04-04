-- Migration 051: Form Tips Enrichment for Top Exercises
-- The original 873 exercises from free-exercise-db have instructions but no form_tips.
-- This migration adds evidence-based form tips to the most commonly-used exercises.
--
-- Sources: NSCA ETSC 4th ed., Starting Strength (Rippetoe), RP Training (Israetel),
--          Schoenfeld EMG studies, McGill spine biomechanics
--
-- Only updates exercises where form_tips IS NULL or empty array.

BEGIN;

-- ---- BENCH PRESS VARIANTS --------------------------------------------------

UPDATE exercises SET form_tips = ARRAY[
  'Plant feet flat on the floor and drive through them for leg drive.',
  'Retract and depress your shoulder blades — squeeze them together and down before unracking.',
  'Touch the bar to your lower chest (nipple line), not your neck or upper chest.',
  'Keep wrists stacked over elbows throughout the press.',
  'Do not bounce the bar off your chest — brief touch or slight pause is ideal.'
]
WHERE lower(name) LIKE '%bench press%' AND (form_tips IS NULL OR form_tips = '{}') AND created_by IS NULL;

-- ---- SQUAT VARIANTS ---------------------------------------------------------

UPDATE exercises SET form_tips = ARRAY[
  'Brace your core hard before descending — take a deep breath and push your abs out.',
  'Break at the hips and knees simultaneously, sitting back and down.',
  'Push your knees out over your toes — do not let them cave inward.',
  'Keep your chest up and maintain a neutral spine throughout.',
  'Drive up through your whole foot, not just your toes.'
]
WHERE lower(name) LIKE '%squat%' AND mechanic = 'compound' AND (form_tips IS NULL OR form_tips = '{}') AND created_by IS NULL
  AND lower(name) NOT LIKE '%pistol%';

-- ---- DEADLIFT VARIANTS ------------------------------------------------------

UPDATE exercises SET form_tips = ARRAY[
  'Set up with the bar over mid-foot, about 1 inch from your shins.',
  'Take the slack out of the bar before pulling — engage your lats and straighten your arms.',
  'Push the floor away with your legs rather than pulling with your back.',
  'Keep the bar in contact with your body throughout the lift (drag it up your legs).',
  'Lock out by squeezing your glutes at the top — do not hyperextend your lower back.'
]
WHERE (lower(name) LIKE '%deadlift%' OR lower(name) = 'barbell deadlift') AND (form_tips IS NULL OR form_tips = '{}') AND created_by IS NULL;

-- ---- OVERHEAD PRESS ----------------------------------------------------------

UPDATE exercises SET form_tips = ARRAY[
  'Start with the bar at collarbone height, elbows slightly in front of the bar.',
  'Press the bar in a slight arc around your face, then straight up once it clears your head.',
  'Squeeze your glutes and brace your abs to prevent lower back arch.',
  'Lock out fully overhead with the bar directly over your mid-foot.',
  'Do not lean back excessively — a slight lean is fine, but it should not become a standing incline press.'
]
WHERE (lower(name) LIKE '%overhead press%' OR lower(name) LIKE '%military press%' OR lower(name) LIKE '%shoulder press%')
  AND mechanic = 'compound' AND (form_tips IS NULL OR form_tips = '{}') AND created_by IS NULL;

-- ---- BARBELL ROW VARIANTS ---------------------------------------------------

UPDATE exercises SET form_tips = ARRAY[
  'Hinge at the hips until your torso is 45-70 degrees from horizontal.',
  'Initiate the pull by squeezing your shoulder blades together, then bend your elbows.',
  'Pull the bar to your lower ribcage or upper abdomen, not your chest.',
  'Do not jerk the weight — use a controlled tempo with a brief squeeze at the top.',
  'Keep your lower back neutral — if it rounds, the weight is too heavy.'
]
WHERE lower(name) LIKE '%barbell%row%' AND (form_tips IS NULL OR form_tips = '{}') AND created_by IS NULL;

-- ---- PULL-UP / CHIN-UP ------------------------------------------------------

UPDATE exercises SET form_tips = ARRAY[
  'Start from a dead hang with arms fully extended — no half reps.',
  'Pull your elbows toward your hips (not behind you) to engage your lats.',
  'Get your chin clearly over the bar at the top.',
  'Lower under control — do not just drop down.',
  'If you cannot do a full rep, use band assistance or slow negatives (3-5 second lowering).'
]
WHERE (lower(name) LIKE '%pull-up%' OR lower(name) LIKE '%pull up%' OR lower(name) LIKE '%chin-up%' OR lower(name) LIKE '%chin up%')
  AND (form_tips IS NULL OR form_tips = '{}') AND created_by IS NULL;

-- ---- DIP VARIANTS -----------------------------------------------------------

UPDATE exercises SET form_tips = ARRAY[
  'Lean slightly forward for chest emphasis; stay upright for triceps emphasis.',
  'Lower until your upper arm is parallel to the floor — do not go deeper unless you have healthy shoulders.',
  'Keep elbows tucked at 30-45 degrees, not flared out wide.',
  'Press up through your palms, locking out at the top.',
  'If bodyweight is too difficult, use a band or machine for assistance.'
]
WHERE lower(name) LIKE '%dip%' AND mechanic = 'compound' AND (form_tips IS NULL OR form_tips = '{}') AND created_by IS NULL;

-- ---- ROMANIAN DEADLIFT ------------------------------------------------------

UPDATE exercises SET form_tips = ARRAY[
  'Push your hips back as if closing a car door with your butt.',
  'Keep the bar in contact with your thighs throughout — it should slide down your legs.',
  'Stop lowering when you feel a strong stretch in your hamstrings (usually mid-shin).',
  'Do not round your lower back to reach the floor — depth is limited by hamstring flexibility.',
  'Squeeze your glutes to drive your hips forward at the top.'
]
WHERE lower(name) LIKE '%romanian deadlift%' AND (form_tips IS NULL OR form_tips = '{}') AND created_by IS NULL;

-- ---- HIP THRUST -------------------------------------------------------------

UPDATE exercises SET form_tips = ARRAY[
  'Position your upper back on the bench at the bottom of your shoulder blades.',
  'Place the bar in the crease of your hips — use a pad for comfort.',
  'Drive through your heels and squeeze your glutes at the top until your torso is parallel to the floor.',
  'Do not hyperextend at the top — stop when your hips are level with your knees and shoulders.',
  'Keep your chin slightly tucked throughout to maintain a neutral spine.'
]
WHERE lower(name) LIKE '%hip thrust%' AND (form_tips IS NULL OR form_tips = '{}') AND created_by IS NULL;

-- ---- LATERAL RAISE -----------------------------------------------------------

UPDATE exercises SET form_tips = ARRAY[
  'Lead with your elbows, not your hands — imagine pouring water from a pitcher.',
  'Raise to shoulder height only — going higher shifts emphasis to traps.',
  'Use a slight forward lean to better target the lateral deltoid.',
  'Control the lowering phase — do not just drop the weight.',
  'Keep your ego in check — lateral raises are effective with light weight and strict form.'
]
WHERE lower(name) LIKE '%lateral raise%' AND (form_tips IS NULL OR form_tips = '{}') AND created_by IS NULL;

-- ---- BICEP CURL VARIANTS ---------------------------------------------------

UPDATE exercises SET form_tips = ARRAY[
  'Keep your elbows pinned at your sides — do not swing them forward.',
  'Squeeze the bicep hard at the top of each rep.',
  'Lower the weight under control for at least 2 seconds (the eccentric is where growth happens).',
  'Do not use momentum — if you need to swing, the weight is too heavy.'
]
WHERE lower(name) LIKE '%curl%' AND (lower(name) LIKE '%bicep%' OR lower(name) LIKE '%barbell curl%' OR lower(name) LIKE '%dumbbell curl%' OR lower(name) LIKE '%preacher%' OR lower(name) LIKE '%concentration%')
  AND (form_tips IS NULL OR form_tips = '{}') AND created_by IS NULL;

-- ---- TRICEP EXTENSION VARIANTS ----------------------------------------------

UPDATE exercises SET form_tips = ARRAY[
  'Keep your elbows pointing forward (or up for overhead variants) — do not let them flare.',
  'Lock out fully at the bottom (pushdowns) or top (overhead) to fully contract the triceps.',
  'Use a controlled tempo — do not snap the weight through the movement.',
  'If you feel elbow pain, try a different grip width or angle before adding more weight.'
]
WHERE (lower(name) LIKE '%tricep%extension%' OR lower(name) LIKE '%skull crush%' OR lower(name) LIKE '%pushdown%' OR lower(name) LIKE '%press down%')
  AND (form_tips IS NULL OR form_tips = '{}') AND created_by IS NULL;

-- ---- LEG PRESS ---------------------------------------------------------------

UPDATE exercises SET form_tips = ARRAY[
  'Place feet shoulder-width apart, midway up the platform.',
  'Lower until your knees reach 90 degrees — do not let your lower back lift off the pad.',
  'Push through your whole foot, not just your toes.',
  'Do not lock out your knees aggressively at the top — maintain a slight bend.',
  'Higher foot placement emphasizes glutes/hamstrings; lower emphasizes quads.'
]
WHERE lower(name) LIKE '%leg press%' AND (form_tips IS NULL OR form_tips = '{}') AND created_by IS NULL;

-- ---- LEG CURL / LEG EXTENSION -----------------------------------------------

UPDATE exercises SET form_tips = ARRAY[
  'Adjust the pad so it sits on your lower shin (just above the ankle).',
  'Move through the full range of motion — full extension and full contraction.',
  'Control the eccentric (lowering) phase for at least 2 seconds.',
  'Do not use momentum to swing the weight up.'
]
WHERE (lower(name) LIKE '%leg curl%' OR lower(name) LIKE '%leg extension%')
  AND (form_tips IS NULL OR form_tips = '{}') AND created_by IS NULL;

-- ---- CALF RAISE VARIANTS ---------------------------------------------------

UPDATE exercises SET form_tips = ARRAY[
  'Get a full stretch at the bottom — let your heels drop below the platform.',
  'Pause at the top for 1-2 seconds to eliminate momentum.',
  'Keep your knees straight (or slightly bent for seated) throughout.',
  'Calves respond well to higher reps (12-20) and slow eccentrics.'
]
WHERE lower(name) LIKE '%calf raise%' AND (form_tips IS NULL OR form_tips = '{}') AND created_by IS NULL;

-- ---- PLANK VARIANTS ---------------------------------------------------------

UPDATE exercises SET form_tips = ARRAY[
  'Keep your body in a straight line from head to heels — no sagging hips or piking up.',
  'Squeeze your glutes and brace your abs as if bracing for a punch.',
  'Place your elbows directly under your shoulders.',
  'Breathe normally — do not hold your breath.'
]
WHERE lower(name) LIKE '%plank%' AND (form_tips IS NULL OR form_tips = '{}') AND created_by IS NULL;

-- ---- PUSH-UP VARIANTS -------------------------------------------------------

UPDATE exercises SET form_tips = ARRAY[
  'Keep your body in a straight line — do not let your hips sag or pike.',
  'Hands slightly wider than shoulder-width, fingers pointing forward.',
  'Lower until your chest touches (or nearly touches) the floor.',
  'Keep your elbows at 45 degrees to your body, not flared at 90.',
  'Squeeze your core and glutes throughout for stability.'
]
WHERE (lower(name) LIKE '%push-up%' OR lower(name) LIKE '%push up%' OR lower(name) LIKE '%pushup%')
  AND (form_tips IS NULL OR form_tips = '{}') AND created_by IS NULL;

-- ---- FACE PULL ---------------------------------------------------------------

UPDATE exercises SET form_tips = ARRAY[
  'Set the cable at upper chest to face height.',
  'Pull the rope apart as you pull toward your face — external rotation is the key movement.',
  'Finish with your hands beside your ears, knuckles pointing at the ceiling.',
  'Keep your chest up and avoid leaning back to pull the weight.'
]
WHERE lower(name) LIKE '%face pull%' AND (form_tips IS NULL OR form_tips = '{}') AND created_by IS NULL;

-- ---- LAT PULLDOWN -----------------------------------------------------------

UPDATE exercises SET form_tips = ARRAY[
  'Lean back slightly (10-15 degrees) and pull the bar to your upper chest.',
  'Drive your elbows down and back — imagine putting them in your back pockets.',
  'Squeeze your shoulder blades together at the bottom of each rep.',
  'Do not pull behind your neck — this puts unnecessary stress on the shoulder joint.',
  'Control the return — do not let the weight stack slam.'
]
WHERE (lower(name) LIKE '%pulldown%' OR lower(name) LIKE '%pull down%') AND (form_tips IS NULL OR form_tips = '{}') AND created_by IS NULL;

-- ---- CABLE ROW ---------------------------------------------------------------

UPDATE exercises SET form_tips = ARRAY[
  'Sit upright with a slight lean back — do not round forward.',
  'Pull the handle to your lower ribcage, squeezing your shoulder blades.',
  'Keep your elbows close to your body throughout the pull.',
  'Let your arms extend fully at the start to get a full lat stretch.',
  'Do not rock back and forth to generate momentum.'
]
WHERE (lower(name) LIKE '%cable row%' OR lower(name) LIKE '%seated row%') AND (form_tips IS NULL OR form_tips = '{}') AND created_by IS NULL;

-- ---- LUNGES ------------------------------------------------------------------

UPDATE exercises SET form_tips = ARRAY[
  'Take a stride long enough that both knees reach 90 degrees at the bottom.',
  'Keep your torso upright — do not lean forward excessively.',
  'Drive up through your front heel, not your toes.',
  'Do not let your front knee collapse inward — press it outward.'
]
WHERE lower(name) LIKE '%lunge%' AND (form_tips IS NULL OR form_tips = '{}') AND created_by IS NULL;


COMMIT;
