-- Migration 047: Exercise Library Expansion
-- Adds ~35 high-value exercises missing from the free-exercise-db seed:
--   - Prehab/Rehab (9): Band Pull-Apart, Dead Hang, Bird Dog, Copenhagen Plank,
--     Wall Slide, Prone Y-T-W Raise, Serratus Punch, Banded Clamshell,
--     Side-Lying External Rotation
--   - Modern Bodybuilding (8): Seal Row, Meadows Row, Pendlay Row, Helms Row,
--     Spoto Press, Larsen Press, Z Press, Bayesian Cable Curl
--   - Cable (7): Cable Face Pull, Cable Pull-Through, Cable Woodchop High-to-Low,
--     Cable Woodchop Low-to-High, Cable Lateral Raise, Cable External Rotation,
--     Cable Internal Rotation
--   - Functional (5): Sled Pull, Battle Ropes, Broad Jump, Wall Ball, Farmer's Walk
--   - Popular Compounds (3): Bulgarian Split Squat, Nordic Hamstring Curl,
--     Chest-Supported Dumbbell Row
--
-- Also adds:
--   - Muscle mappings for all new exercises
--   - Enrichment metadata (movement_pattern, exercise_type, laterality, etc.)
--   - Substitutions and progression chains linking new exercises to existing library
--
-- Sources: NSCA ETSC 4th ed., Schoenfeld (2010) EMG comparisons, Contreras (2019)
-- Validated by: fitness-domain-expert agent (pending post-migration review)

BEGIN;

-- =============================================================================
-- 1. INSERT NEW EXERCISES
-- =============================================================================

-- ---- PREHAB / REHAB --------------------------------------------------------

INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, form_tips, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Band Pull-Apart',
  'pull',
  'beginner',
  'isolation',
  'bands',
  'strength',
  ARRAY[
    'Stand tall holding a resistance band at shoulder height with arms extended, hands slightly wider than shoulder-width.',
    'Keep your arms straight and pull the band apart by squeezing your shoulder blades together.',
    'Continue until the band touches your chest, maintaining a slight bend in the elbows.',
    'Slowly return to the starting position under control.',
    'Repeat for the prescribed number of repetitions.'
  ],
  ARRAY[
    'Keep your core braced and avoid arching your lower back.',
    'Focus on initiating the movement from the rear deltoids and rhomboids, not the arms.',
    'Use a lighter band and higher reps (15-25) for prehab; heavier for strength.'
  ],
  ARRAY[]::text[],
  false,
  NULL
) ON CONFLICT DO NOTHING;

INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, form_tips, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Dead Hang',
  'static',
  'beginner',
  NULL,
  'other',
  'strength',
  ARRAY[
    'Grip a pull-up bar with an overhand grip, hands shoulder-width apart.',
    'Let your body hang freely with arms fully extended.',
    'Relax your shoulders away from your ears to decompress the spine.',
    'Hold the position for the prescribed time.',
    'Step down or drop carefully when finished.'
  ],
  ARRAY[
    'Keep your core lightly engaged to prevent excessive swinging.',
    'Breathe deeply and evenly throughout the hang.',
    'Progress by increasing hang time before adding weight.'
  ],
  ARRAY[]::text[],
  false,
  NULL
) ON CONFLICT DO NOTHING;

INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, form_tips, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Bird Dog',
  'static',
  'beginner',
  'compound',
  'body_only',
  'strength',
  ARRAY[
    'Start on all fours with hands under shoulders and knees under hips.',
    'Simultaneously extend your right arm forward and left leg backward until both are parallel to the floor.',
    'Hold briefly, maintaining a flat back and stable hips.',
    'Return to the starting position under control.',
    'Repeat on the opposite side (left arm, right leg).'
  ],
  ARRAY[
    'Avoid rotating your hips or shoulders during the movement.',
    'Keep your spine neutral — do not arch or round your back.',
    'Place a foam roller on your back to check for hip rotation.'
  ],
  ARRAY[]::text[],
  false,
  NULL
) ON CONFLICT DO NOTHING;

INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, form_tips, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Copenhagen Plank',
  'static',
  'intermediate',
  'isolation',
  'body_only',
  'strength',
  ARRAY[
    'Lie on your side with your top leg resting on a bench, foot hooked over the edge.',
    'Support your upper body on your forearm, elbow directly under your shoulder.',
    'Lift your hips off the ground by pressing your top leg into the bench.',
    'Your bottom leg hangs freely below the bench.',
    'Hold the position for the prescribed time, keeping your body in a straight line.'
  ],
  ARRAY[
    'Progress from short holds (10s) to longer durations.',
    'Keep hips stacked — do not let the top hip roll forward or backward.',
    'For regression, bend the top knee and place the knee (not foot) on the bench.',
    'Avoid with acute groin or adductor injuries — this exercise places very high load on the adductor group.'
  ],
  ARRAY[]::text[],
  false,
  NULL
) ON CONFLICT DO NOTHING;

INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, form_tips, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Wall Slide',
  'push',
  'beginner',
  'isolation',
  'body_only',
  'stretching',
  ARRAY[
    'Stand with your back, head, and hips flat against a wall.',
    'Place your arms against the wall in a "goalpost" position — upper arms at 90 degrees, forearms vertical.',
    'Slowly slide your arms upward along the wall, keeping your wrists and elbows in contact.',
    'Extend as high as comfortable, then slowly slide back down.',
    'Repeat for the prescribed number of repetitions.'
  ],
  ARRAY[
    'If your lower back arches off the wall, slightly bend your knees.',
    'Maintain contact between the wall and your wrists, elbows, and upper back throughout.',
    'This exercise assesses and improves shoulder mobility — stop if painful.'
  ],
  ARRAY[]::text[],
  false,
  NULL
) ON CONFLICT DO NOTHING;

INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, form_tips, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Prone Y-T-W Raise',
  'pull',
  'beginner',
  'isolation',
  'body_only',
  'strength',
  ARRAY[
    'Lie face down on a flat bench or the floor with arms hanging straight down.',
    'Y position: Raise both arms overhead at a 45-degree angle (forming a Y shape) with thumbs up. Hold 2 seconds.',
    'T position: Lower arms, then raise them straight out to the sides (forming a T). Hold 2 seconds.',
    'W position: Lower arms, bend elbows to 90 degrees, and squeeze shoulder blades together (forming a W). Hold 2 seconds.',
    'That is one rep. Repeat for the prescribed number of repetitions.'
  ],
  ARRAY[
    'Use very light weight (1-2 kg) or no weight — this is a prehab exercise.',
    'Focus on squeezing the shoulder blades together at the top of each position.',
    'Keep your forehead resting on the bench to maintain a neutral neck.'
  ],
  ARRAY[]::text[],
  false,
  NULL
) ON CONFLICT DO NOTHING;

INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, form_tips, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Serratus Punch',
  'push',
  'beginner',
  'isolation',
  'body_only',
  'strength',
  ARRAY[
    'Lie face up on a bench holding a light dumbbell or kettlebell with one arm extended above your chest.',
    'Without bending the elbow, push the weight toward the ceiling by protracting your shoulder blade.',
    'Your shoulder should lift off the bench as the serratus anterior engages.',
    'Slowly lower back until the shoulder blade retracts to the bench.',
    'Repeat for the prescribed number of repetitions, then switch arms.'
  ],
  ARRAY[
    'Keep the elbow locked — all movement comes from the shoulder blade.',
    'This is a small-range movement; do not bounce or use momentum.',
    'Also known as a "Serratus Press" or "Scapular Protraction".'
  ],
  ARRAY[]::text[],
  false,
  NULL
) ON CONFLICT DO NOTHING;

INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, form_tips, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Banded Clamshell',
  'push',
  'beginner',
  'isolation',
  'bands',
  'strength',
  ARRAY[
    'Lie on your side with hips and knees bent at 45 degrees, a resistance band looped just above your knees.',
    'Keep your feet together and your bottom arm supporting your head.',
    'Open your top knee as far as possible without rotating your pelvis.',
    'Hold the open position briefly, squeezing the glute.',
    'Slowly return to the starting position. Complete all reps, then switch sides.'
  ],
  ARRAY[
    'Do not let your hips roll backward — the movement should come purely from hip rotation.',
    'Place your free hand on your top hip to monitor for pelvic rotation.',
    'Progress by using a heavier band, not by adding speed.'
  ],
  ARRAY[]::text[],
  false,
  NULL
) ON CONFLICT DO NOTHING;

INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, form_tips, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Side-Lying External Rotation',
  'pull',
  'beginner',
  'isolation',
  'dumbbell',
  'strength',
  ARRAY[
    'Lie on your side with a rolled towel between your top elbow and your ribcage.',
    'Hold a light dumbbell with your top hand, elbow bent at 90 degrees and forearm resting across your stomach.',
    'Rotate your forearm upward, keeping the elbow pinned to the towel, until the forearm is roughly vertical.',
    'Hold briefly at the top, then slowly lower back to the starting position.',
    'Complete all reps on one side, then switch.'
  ],
  ARRAY[
    'Use a very light weight (1-3 kg) — the rotator cuff muscles are small.',
    'Keep the elbow at exactly 90 degrees throughout.',
    'If you feel pain in the shoulder joint, stop immediately and consult a professional.'
  ],
  ARRAY[]::text[],
  false,
  NULL
) ON CONFLICT DO NOTHING;

-- ---- MODERN BODYBUILDING ----------------------------------------------------

INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, form_tips, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Seal Row',
  'pull',
  'intermediate',
  'compound',
  'barbell',
  'strength',
  ARRAY[
    'Lie face down on a raised flat bench so that your arms hang freely below.',
    'Grip a barbell on the floor with an overhand grip, hands slightly wider than shoulder-width.',
    'Row the barbell to the underside of the bench by driving your elbows back.',
    'Squeeze your shoulder blades together at the top.',
    'Lower the barbell under control until arms are fully extended.'
  ],
  ARRAY[
    'The bench-supported position eliminates momentum and lower back stress.',
    'Keep your chest flat on the bench — no lifting the torso.',
    'Can also be performed with dumbbells for a greater range of motion.'
  ],
  ARRAY[]::text[],
  false,
  NULL
) ON CONFLICT DO NOTHING;

INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, form_tips, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Meadows Row',
  'pull',
  'intermediate',
  'compound',
  'barbell',
  'strength',
  ARRAY[
    'Place one end of a barbell in a landmine attachment or corner. Load the other end.',
    'Stand perpendicular to the barbell with the loaded end to your side.',
    'Stagger your stance and hinge at the hips, bracing your off-hand on your front knee.',
    'Grip the end of the barbell with an overhand grip and row it toward your hip.',
    'Squeeze at the top, then lower under control.'
  ],
  ARRAY[
    'Created by John Meadows — the angled pulling path emphasizes the lower lat.',
    'Overhand grip is important; supinated grip shifts emphasis away from the target.',
    'Use straps if grip limits the weight before your back does.'
  ],
  ARRAY[]::text[],
  false,
  NULL
) ON CONFLICT DO NOTHING;

INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, form_tips, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Pendlay Row',
  'pull',
  'intermediate',
  'compound',
  'barbell',
  'strength',
  ARRAY[
    'Stand over a barbell with feet hip-width apart. Hinge at the hips until your torso is parallel to the floor.',
    'Grip the bar with an overhand grip, slightly wider than shoulder-width. The bar starts on the floor each rep.',
    'Explosively row the bar to your lower chest, keeping your torso strictly parallel.',
    'Lower the bar back to the floor under control. Let it fully settle between reps.',
    'Reset your position and repeat.'
  ],
  ARRAY[
    'Unlike a bent-over row, the torso stays strictly horizontal — no body English.',
    'Each rep starts from a dead stop on the floor (like a deadlift for rows).',
    'Named after weightlifting coach Glenn Pendlay.'
  ],
  ARRAY[]::text[],
  false,
  NULL
) ON CONFLICT DO NOTHING;

INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, form_tips, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Helms Row',
  'pull',
  'beginner',
  'compound',
  'dumbbell',
  'strength',
  ARRAY[
    'Set an adjustable bench to a 30-45 degree incline.',
    'Lie face down on the bench with a dumbbell in each hand, arms hanging straight down.',
    'Row both dumbbells simultaneously by driving your elbows back and squeezing your shoulder blades.',
    'Hold the contraction briefly at the top.',
    'Lower under control to full arm extension.'
  ],
  ARRAY[
    'The incline bench angle determines emphasis: steeper = more upper back, flatter = more mid-back.',
    'Chest stays on the pad throughout — no torso lift.',
    'Popularized by Dr. Eric Helms; great for lifters with lower back issues.'
  ],
  ARRAY[]::text[],
  false,
  NULL
) ON CONFLICT DO NOTHING;

INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, form_tips, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Chest-Supported Dumbbell Row',
  'pull',
  'beginner',
  'compound',
  'dumbbell',
  'strength',
  ARRAY[
    'Set an adjustable bench to approximately 30-45 degrees.',
    'Lie face down on the bench with a dumbbell in each hand hanging at arm''s length.',
    'Row the dumbbells to your ribcage by pulling your elbows toward the ceiling.',
    'Squeeze your shoulder blades together at the top of the movement.',
    'Lower the dumbbells slowly to the starting position.'
  ],
  ARRAY[
    'Eliminates lower back strain and momentum cheating.',
    'Neutral grip (palms facing each other) reduces bicep involvement.',
    'Allow your shoulder blades to protract fully at the bottom for a full stretch.'
  ],
  ARRAY[]::text[],
  false,
  NULL
) ON CONFLICT DO NOTHING;

INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, form_tips, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Spoto Press',
  'push',
  'advanced',
  'compound',
  'barbell',
  'strength',
  ARRAY[
    'Set up on a flat bench as you would for a standard bench press.',
    'Unrack the barbell and lower it toward your chest under control.',
    'Pause the bar 1-2 inches above your chest (do NOT touch the chest).',
    'Hold the paused position for 1-2 seconds, maintaining tension.',
    'Press the bar back to lockout.'
  ],
  ARRAY[
    'Named after Eric Spoto (former all-time raw bench press record holder).',
    'The pause above the chest eliminates the stretch reflex and builds strength off the chest.',
    'Use 80-90% of your normal bench weight due to the increased difficulty.'
  ],
  ARRAY[]::text[],
  false,
  NULL
) ON CONFLICT DO NOTHING;

INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, form_tips, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Larsen Press',
  'push',
  'intermediate',
  'compound',
  'barbell',
  'strength',
  ARRAY[
    'Set up on a flat bench and unrack the barbell.',
    'Lift both feet off the floor and hold them straight in front of you, hovering.',
    'Lower the barbell to your chest under control.',
    'Pause briefly on the chest, then press back to lockout.',
    'Maintain feet-off-floor position throughout the set.'
  ],
  ARRAY[
    'Removing leg drive isolates the upper body pressing muscles.',
    'Requires more core stability — brace hard throughout.',
    'Use less weight than your standard bench press (typically 70-85%).'
  ],
  ARRAY[]::text[],
  false,
  NULL
) ON CONFLICT DO NOTHING;

INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, form_tips, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Z Press',
  'push',
  'advanced',
  'compound',
  'barbell',
  'strength',
  ARRAY[
    'Sit on the floor inside a power rack with legs extended straight in front of you.',
    'Unrack the barbell from pins set at shoulder height (or clean it to your shoulders).',
    'Press the barbell overhead to full lockout, keeping your torso upright.',
    'Lower the bar back to your shoulders under control.',
    'Repeat for the prescribed number of repetitions.'
  ],
  ARRAY[
    'Without back support or leg drive, any forward lean is immediately apparent.',
    'Requires excellent hip flexor mobility and core stability.',
    'Named after strongman Zydrunas Savickas.'
  ],
  ARRAY[]::text[],
  false,
  NULL
) ON CONFLICT DO NOTHING;

INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, form_tips, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Bayesian Cable Curl',
  'pull',
  'intermediate',
  'isolation',
  'cable',
  'strength',
  ARRAY[
    'Set a cable pulley to the lowest position with a single handle.',
    'Face away from the cable machine, holding the handle with one hand behind you, arm fully extended.',
    'Step forward until you feel tension on the cable with your arm behind your torso.',
    'Curl the handle forward and up by flexing at the elbow, keeping your upper arm behind your body.',
    'Squeeze the bicep at the top, then slowly return to the stretched position.'
  ],
  ARRAY[
    'The key is the shoulder extension — arm behind the body stretches the long head of the bicep.',
    'Keep your elbow stationary; only the forearm should move.',
    'This is one of the few exercises that loads the bicep at full stretch.'
  ],
  ARRAY[]::text[],
  false,
  NULL
) ON CONFLICT DO NOTHING;

-- ---- CABLE VARIATIONS -------------------------------------------------------

INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, form_tips, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Cable Face Pull',
  'pull',
  'beginner',
  'compound',
  'cable',
  'strength',
  ARRAY[
    'Set a cable pulley to upper chest height with a rope attachment.',
    'Grip each end of the rope with an overhand grip and step back until arms are extended.',
    'Pull the rope toward your face, separating the ends as you pull, driving elbows high and wide.',
    'Externally rotate at the top so your hands end beside your ears, knuckles pointing at the ceiling.',
    'Hold briefly, then return to the starting position under control.'
  ],
  ARRAY[
    'The external rotation at the end is crucial — do not skip it.',
    'Keep your chest up and avoid leaning back to pull the weight.',
    'Excellent for rear deltoid and rotator cuff health; do 3-4 sets of 15-20 reps.'
  ],
  ARRAY[]::text[],
  false,
  NULL
) ON CONFLICT DO NOTHING;

INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, form_tips, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Cable Pull-Through',
  'pull',
  'beginner',
  'compound',
  'cable',
  'strength',
  ARRAY[
    'Set a cable pulley to the lowest position with a rope attachment.',
    'Straddle the cable, facing away from the machine. Reach between your legs and grab the rope.',
    'Walk forward a couple of steps. Stand with feet slightly wider than shoulder-width.',
    'Hinge at the hips, pushing your butt back while keeping your arms straight between your legs.',
    'Drive your hips forward to stand tall, squeezing your glutes at the top. Your arms stay straight throughout.'
  ],
  ARRAY[
    'This is a hip hinge, not a squat — the knees bend only slightly.',
    'The cable provides constant tension through the entire range of motion.',
    'Great teaching tool for the hip hinge pattern before progressing to deadlifts.'
  ],
  ARRAY[]::text[],
  false,
  NULL
) ON CONFLICT DO NOTHING;

INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, form_tips, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Cable Woodchop High-to-Low',
  'pull',
  'intermediate',
  'compound',
  'cable',
  'strength',
  ARRAY[
    'Set a cable pulley to the highest position with a single handle or rope.',
    'Stand sideways to the machine, feet shoulder-width apart, and grip the handle with both hands.',
    'With arms nearly straight, rotate your torso and pull the handle diagonally downward across your body.',
    'The movement finishes near the opposite hip, with your hips and knees slightly bent.',
    'Return to the starting position under control and repeat. Complete all reps, then switch sides.'
  ],
  ARRAY[
    'Power comes from the core rotation, not the arms.',
    'Keep your arms relatively straight — they are levers, not the prime movers.',
    'Control the return (eccentric) — do not let the weight snap back.'
  ],
  ARRAY[]::text[],
  false,
  NULL
) ON CONFLICT DO NOTHING;

INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, form_tips, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Cable Woodchop Low-to-High',
  'push',
  'intermediate',
  'compound',
  'cable',
  'strength',
  ARRAY[
    'Set a cable pulley to the lowest position with a single handle or rope.',
    'Stand sideways to the machine, feet shoulder-width apart, and grip the handle with both hands near your hip.',
    'Rotate your torso and push the handle diagonally upward across your body.',
    'The movement finishes above the opposite shoulder with arms extended.',
    'Return to the starting position under control and repeat. Complete all reps, then switch sides.'
  ],
  ARRAY[
    'Drive the rotation from your hips and core, not your arms.',
    'The feet can pivot slightly to allow full rotation.',
    'Also called a "reverse woodchop" — effective for oblique and serratus development.'
  ],
  ARRAY[]::text[],
  false,
  NULL
) ON CONFLICT DO NOTHING;

INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, form_tips, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Cable Lateral Raise',
  'push',
  'beginner',
  'isolation',
  'cable',
  'strength',
  ARRAY[
    'Set a cable pulley to the lowest position with a single handle.',
    'Stand sideways to the machine and grip the handle with the far hand (cable crosses behind you).',
    'With a slight bend in the elbow, raise your arm out to the side until it is parallel with the floor.',
    'Hold briefly at the top, then lower under control.',
    'Complete all reps, then switch sides.'
  ],
  ARRAY[
    'The cable provides constant tension, unlike dumbbells which lose tension at the bottom.',
    'Lead with the elbow, not the hand, to emphasize the lateral deltoid.',
    'Do not shrug your trap — keep the shoulder down and away from your ear.'
  ],
  ARRAY[]::text[],
  false,
  NULL
) ON CONFLICT DO NOTHING;

INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, form_tips, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Cable External Rotation',
  'pull',
  'beginner',
  'isolation',
  'cable',
  'strength',
  ARRAY[
    'Set a cable pulley to elbow height with a single handle.',
    'Stand sideways to the machine. Grip the handle with the far hand, elbow bent at 90 degrees and pinned to your side.',
    'Rotate your forearm away from your body (externally) against the cable resistance.',
    'Hold briefly at end range, then return slowly to the starting position.',
    'Complete all reps, then switch sides.'
  ],
  ARRAY[
    'Keep the elbow glued to your side — a towel roll can help enforce this.',
    'Use light weight and higher reps (15-20) — this is a rotator cuff exercise.',
    'Stop immediately if you feel sharp pain in the shoulder joint.'
  ],
  ARRAY[]::text[],
  false,
  NULL
) ON CONFLICT DO NOTHING;

INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, form_tips, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Cable Internal Rotation',
  'push',
  'beginner',
  'isolation',
  'cable',
  'strength',
  ARRAY[
    'Set a cable pulley to elbow height with a single handle.',
    'Stand sideways to the machine. Grip the handle with the near hand, elbow bent at 90 degrees and pinned to your side.',
    'Rotate your forearm across your body (internally) against the cable resistance.',
    'Hold briefly at end range, then return slowly to the starting position.',
    'Complete all reps, then switch sides.'
  ],
  ARRAY[
    'Pair with cable external rotation for balanced rotator cuff training.',
    'Use a 3:2 external-to-internal ratio (e.g., 3 sets external, 2 sets internal).',
    'Maintain elbow at 90 degrees throughout.'
  ],
  ARRAY[]::text[],
  false,
  NULL
) ON CONFLICT DO NOTHING;

-- ---- FUNCTIONAL / ATHLETIC --------------------------------------------------

INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, form_tips, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Sled Pull',
  'pull',
  'intermediate',
  'compound',
  'other',
  'strength',
  ARRAY[
    'Attach a rope or strap to a weighted sled. Face the sled and grip the handles.',
    'Walk backward, pulling the sled toward you with each step.',
    'Keep your hips low and drive through your heels.',
    'Maintain an upright torso and keep your arms extended or row hand-over-hand.',
    'Continue for the prescribed distance or time.'
  ],
  ARRAY[
    'Can also be done as hand-over-hand rope pulls from a seated or standing position.',
    'Sled pulls are concentric-only — minimal muscle soreness, great for recovery sessions.',
    'Adjust weight for the goal: lighter for conditioning, heavier for strength.'
  ],
  ARRAY[]::text[],
  false,
  NULL
) ON CONFLICT DO NOTHING;

INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, form_tips, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Battle Ropes',
  'push',
  'beginner',
  'compound',
  'other',
  'strength',
  ARRAY[
    'Anchor a heavy rope around a sturdy post. Hold one end in each hand.',
    'Stand with feet shoulder-width apart, knees slightly bent, hips back.',
    'Alternately raise and lower each arm explosively, creating waves in the rope.',
    'Maintain a strong core and avoid excessive forward lean.',
    'Continue for the prescribed time or number of waves.'
  ],
  ARRAY[
    'Variations: double waves (both arms together), slams, circles, snakes.',
    'The further from the anchor you stand, the easier it gets (less rope weight).',
    'Great for metabolic conditioning with low joint stress.'
  ],
  ARRAY[]::text[],
  false,
  NULL
) ON CONFLICT DO NOTHING;

INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, form_tips, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Standing Broad Jump',
  'push',
  'intermediate',
  'compound',
  'body_only',
  'plyometrics',
  ARRAY[
    'Stand with feet shoulder-width apart at the edge of a clear area.',
    'Swing your arms back as you bend your knees and hinge your hips.',
    'Explosively swing your arms forward and jump as far forward as possible.',
    'Land softly on both feet, bending your knees to absorb the impact.',
    'Stand up, walk back to the start, and repeat.'
  ],
  ARRAY[
    'Focus on triple extension: ankles, knees, and hips all extend simultaneously.',
    'Land with knees tracking over toes — do not let knees collapse inward.',
    'Measure distance for tracking horizontal power development.'
  ],
  ARRAY[]::text[],
  false,
  NULL
) ON CONFLICT DO NOTHING;

INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, form_tips, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Wall Ball',
  'push',
  'intermediate',
  'compound',
  'other',
  'strength',
  ARRAY[
    'Stand facing a wall about arm''s length away, holding a medicine ball at chest height.',
    'Squat down to parallel depth, keeping the ball at your chest.',
    'Explosively stand up and throw the ball upward to hit a target on the wall (typically 9-10 feet).',
    'Catch the ball as it rebounds and immediately descend into the next squat.',
    'Repeat for the prescribed number of repetitions.'
  ],
  ARRAY[
    'The squat and throw should be one fluid movement, not two separate actions.',
    'Keep your chest up throughout the squat — do not let the ball pull you forward.',
    'Standard medicine ball weight: 6-9 kg for men, 4-6 kg for women.'
  ],
  ARRAY[]::text[],
  false,
  NULL
) ON CONFLICT DO NOTHING;

INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, form_tips, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Farmer''s Walk',
  'static',
  'beginner',
  'compound',
  'dumbbell',
  'strongman',
  ARRAY[
    'Pick up a heavy dumbbell or farmer''s walk handle in each hand.',
    'Stand tall with shoulders back and down, core braced.',
    'Walk forward with controlled, even steps for the prescribed distance or time.',
    'Maintain an upright posture — do not lean to either side.',
    'Set the weights down under control when finished.'
  ],
  ARRAY[
    'Grip is usually the limiting factor — use chalk or straps for heavier loads if needed.',
    'Keep your shoulders packed (down and back), not shrugged up to your ears.',
    'Aim for 30-60 seconds of walking or 40-60 meters per set.'
  ],
  ARRAY[]::text[],
  false,
  NULL
) ON CONFLICT DO NOTHING;

-- ---- POPULAR COMPOUNDS ------------------------------------------------------

INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, form_tips, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Bulgarian Split Squat',
  'push',
  'intermediate',
  'compound',
  'dumbbell',
  'strength',
  ARRAY[
    'Stand about 2 feet in front of a bench. Place the top of one foot on the bench behind you.',
    'Hold a dumbbell in each hand at your sides.',
    'Lower your body by bending the front knee until the back knee nearly touches the floor.',
    'Keep your front shin roughly vertical and your torso upright.',
    'Drive through the front heel to return to the starting position. Complete all reps, then switch legs.'
  ],
  ARRAY[
    'The farther forward the front foot, the more glute emphasis; closer = more quad emphasis.',
    'Do not let the front knee cave inward — press it outward over your pinky toe.',
    'Hold a single dumbbell in the goblet position for a stability variation.'
  ],
  ARRAY[]::text[],
  false,
  NULL
) ON CONFLICT DO NOTHING;

INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, form_tips, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Nordic Hamstring Curl',
  'pull',
  'advanced',
  'isolation',
  'body_only',
  'strength',
  ARRAY[
    'Kneel on a pad with a partner holding your ankles, or anchor your feet under a heavy barbell or pad.',
    'Cross your arms over your chest or hold them in front of you.',
    'Keeping your body straight from knees to shoulders, slowly lower yourself toward the floor by extending at the knees.',
    'Lower as far as you can control, then use a slight push from your hands to return to upright.',
    'Repeat for the prescribed number of repetitions.'
  ],
  ARRAY[
    'This is an extremely demanding exercise — start with 3-5 slow eccentric-only reps.',
    'Use a resistance band attached overhead for assistance until you build strength.',
    'Al-Attar et al. (2017) meta-analysis: Nordic curls reduce hamstring injuries by 51%.',
    'Contraindicated for acute hamstring injuries. Build eccentric tolerance gradually over 4-6 weeks.'
  ],
  ARRAY[]::text[],
  false,
  NULL
) ON CONFLICT DO NOTHING;

-- =============================================================================
-- 2. MUSCLE MAPPINGS FOR NEW EXERCISES
-- =============================================================================
-- Muscle group IDs: 1=biceps, 2=shoulders, 3=triceps, 4=chest, 5=forearms,
-- 7=calves, 8=glutes, 9=traps, 10=abs, 11=hamstrings,
-- 12=lats, 13=lower back, 14=neck, 15=quadriceps, 16=adductors

-- Band Pull-Apart: primary=shoulders(rear delt), traps; secondary=lats
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Band Pull-Apart' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 9, true FROM exercises e WHERE e.name = 'Band Pull-Apart' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Band Pull-Apart' AND e.created_by IS NULL ON CONFLICT DO NOTHING;

-- Dead Hang: primary=forearms; secondary=lats, shoulders (passive stretch, not active contraction)
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 5, true FROM exercises e WHERE e.name = 'Dead Hang' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Dead Hang' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Dead Hang' AND e.created_by IS NULL ON CONFLICT DO NOTHING;

-- Bird Dog: primary=abs, lower back; secondary=glutes, shoulders
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Bird Dog' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 13, true FROM exercises e WHERE e.name = 'Bird Dog' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Bird Dog' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Bird Dog' AND e.created_by IS NULL ON CONFLICT DO NOTHING;

-- Copenhagen Plank: primary=adductors; secondary=abs
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 16, true FROM exercises e WHERE e.name = 'Copenhagen Plank' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 10, false FROM exercises e WHERE e.name = 'Copenhagen Plank' AND e.created_by IS NULL ON CONFLICT DO NOTHING;

-- Wall Slide: primary=shoulders; secondary=traps
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Wall Slide' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Wall Slide' AND e.created_by IS NULL ON CONFLICT DO NOTHING;

-- Prone Y-T-W Raise: primary=shoulders, traps; secondary=lats, lower back (isometric stabilizer)
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Prone Y-T-W Raise' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 9, true FROM exercises e WHERE e.name = 'Prone Y-T-W Raise' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Prone Y-T-W Raise' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Prone Y-T-W Raise' AND e.created_by IS NULL ON CONFLICT DO NOTHING;

-- Serratus Punch: primary=chest(serratus is on chest side); secondary=shoulders
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Serratus Punch' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Serratus Punch' AND e.created_by IS NULL ON CONFLICT DO NOTHING;

-- Banded Clamshell: primary=glutes; secondary=adductors
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 8, true FROM exercises e WHERE e.name = 'Banded Clamshell' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 16, false FROM exercises e WHERE e.name = 'Banded Clamshell' AND e.created_by IS NULL ON CONFLICT DO NOTHING;

-- Side-Lying External Rotation: primary=shoulders (infraspinatus); secondary=none
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Side-Lying External Rotation' AND e.created_by IS NULL ON CONFLICT DO NOTHING;

-- Seal Row: primary=lats, traps; secondary=biceps, shoulders
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Seal Row' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 9, true FROM exercises e WHERE e.name = 'Seal Row' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Seal Row' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Seal Row' AND e.created_by IS NULL ON CONFLICT DO NOTHING;

-- Meadows Row: primary=lats; secondary=biceps, traps, shoulders
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Meadows Row' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Meadows Row' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Meadows Row' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Meadows Row' AND e.created_by IS NULL ON CONFLICT DO NOTHING;

-- Pendlay Row: primary=lats, traps; secondary=biceps, lower back
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Pendlay Row' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 9, true FROM exercises e WHERE e.name = 'Pendlay Row' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Pendlay Row' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Pendlay Row' AND e.created_by IS NULL ON CONFLICT DO NOTHING;

-- Helms Row: primary=lats, traps; secondary=biceps, shoulders
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Helms Row' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 9, true FROM exercises e WHERE e.name = 'Helms Row' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Helms Row' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Helms Row' AND e.created_by IS NULL ON CONFLICT DO NOTHING;

-- Chest-Supported Dumbbell Row: primary=lats, traps; secondary=biceps, shoulders
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Chest-Supported Dumbbell Row' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 9, true FROM exercises e WHERE e.name = 'Chest-Supported Dumbbell Row' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Chest-Supported Dumbbell Row' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Chest-Supported Dumbbell Row' AND e.created_by IS NULL ON CONFLICT DO NOTHING;

-- Spoto Press: primary=chest, triceps; secondary=shoulders
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Spoto Press' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Spoto Press' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Spoto Press' AND e.created_by IS NULL ON CONFLICT DO NOTHING;

-- Larsen Press: primary=chest, triceps; secondary=shoulders, abs
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Larsen Press' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Larsen Press' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Larsen Press' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 10, false FROM exercises e WHERE e.name = 'Larsen Press' AND e.created_by IS NULL ON CONFLICT DO NOTHING;

-- Z Press: primary=shoulders, triceps; secondary=abs
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Z Press' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Z Press' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 10, false FROM exercises e WHERE e.name = 'Z Press' AND e.created_by IS NULL ON CONFLICT DO NOTHING;

-- Bayesian Cable Curl: primary=biceps; secondary=forearms
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 1, true FROM exercises e WHERE e.name = 'Bayesian Cable Curl' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Bayesian Cable Curl' AND e.created_by IS NULL ON CONFLICT DO NOTHING;

-- Cable Face Pull: primary=shoulders, traps; secondary=biceps
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Cable Face Pull' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 9, true FROM exercises e WHERE e.name = 'Cable Face Pull' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Cable Face Pull' AND e.created_by IS NULL ON CONFLICT DO NOTHING;

-- Cable Pull-Through: primary=glutes, hamstrings; secondary=lower back
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 8, true FROM exercises e WHERE e.name = 'Cable Pull-Through' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Cable Pull-Through' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Cable Pull-Through' AND e.created_by IS NULL ON CONFLICT DO NOTHING;

-- Cable Woodchop High-to-Low: primary=abs (obliques); secondary=shoulders
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Cable Woodchop High-to-Low' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Cable Woodchop High-to-Low' AND e.created_by IS NULL ON CONFLICT DO NOTHING;

-- Cable Woodchop Low-to-High: primary=abs (obliques); secondary=shoulders
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Cable Woodchop Low-to-High' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Cable Woodchop Low-to-High' AND e.created_by IS NULL ON CONFLICT DO NOTHING;

-- Cable Lateral Raise: primary=shoulders; secondary=traps
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Cable Lateral Raise' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Cable Lateral Raise' AND e.created_by IS NULL ON CONFLICT DO NOTHING;

-- Cable External Rotation: primary=shoulders (infraspinatus)
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Cable External Rotation' AND e.created_by IS NULL ON CONFLICT DO NOTHING;

-- Cable Internal Rotation: primary=shoulders (subscapularis)
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Cable Internal Rotation' AND e.created_by IS NULL ON CONFLICT DO NOTHING;

-- Sled Pull: primary=quads, glutes, hamstrings; secondary=calves, forearms
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Sled Pull' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 8, true FROM exercises e WHERE e.name = 'Sled Pull' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Sled Pull' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Sled Pull' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Sled Pull' AND e.created_by IS NULL ON CONFLICT DO NOTHING;

-- Battle Ropes: primary=shoulders, abs; secondary=forearms, lats
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Battle Ropes' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Battle Ropes' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Battle Ropes' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Battle Ropes' AND e.created_by IS NULL ON CONFLICT DO NOTHING;

-- Standing Broad Jump: primary=quads, glutes; secondary=hamstrings, calves
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Standing Broad Jump' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 8, true FROM exercises e WHERE e.name = 'Standing Broad Jump' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Standing Broad Jump' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Standing Broad Jump' AND e.created_by IS NULL ON CONFLICT DO NOTHING;

-- Wall Ball: primary=quads, glutes, shoulders; secondary=triceps, abs
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Wall Ball' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 8, true FROM exercises e WHERE e.name = 'Wall Ball' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Wall Ball' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Wall Ball' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 10, false FROM exercises e WHERE e.name = 'Wall Ball' AND e.created_by IS NULL ON CONFLICT DO NOTHING;

-- Farmer's Walk: primary=forearms, traps; secondary=abs, glutes, quads
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 5, true FROM exercises e WHERE e.name = 'Farmer''s Walk' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 9, true FROM exercises e WHERE e.name = 'Farmer''s Walk' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 10, false FROM exercises e WHERE e.name = 'Farmer''s Walk' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Farmer''s Walk' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Farmer''s Walk' AND e.created_by IS NULL ON CONFLICT DO NOTHING;

-- Bulgarian Split Squat: primary=quads, glutes; secondary=hamstrings, adductors
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Bulgarian Split Squat' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 8, true FROM exercises e WHERE e.name = 'Bulgarian Split Squat' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Bulgarian Split Squat' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 16, false FROM exercises e WHERE e.name = 'Bulgarian Split Squat' AND e.created_by IS NULL ON CONFLICT DO NOTHING;

-- Nordic Hamstring Curl: primary=hamstrings; secondary=glutes, calves
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Nordic Hamstring Curl' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Nordic Hamstring Curl' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Nordic Hamstring Curl' AND e.created_by IS NULL ON CONFLICT DO NOTHING;


-- =============================================================================
-- 3. ENRICHMENT METADATA FOR NEW EXERCISES
-- =============================================================================

-- Movement pattern classification
UPDATE exercises SET movement_pattern = 'horizontal_pull' WHERE name = 'Band Pull-Apart' AND movement_pattern IS NULL;
UPDATE exercises SET movement_pattern = 'isolation'       WHERE name IN ('Prone Y-T-W Raise', 'Side-Lying External Rotation') AND movement_pattern IS NULL;
UPDATE exercises SET movement_pattern = 'other'           WHERE name IN ('Dead Hang', 'Wall Slide', 'Bird Dog') AND movement_pattern IS NULL;
UPDATE exercises SET movement_pattern = 'rotation'        WHERE name IN ('Cable Woodchop High-to-Low', 'Cable Woodchop Low-to-High') AND movement_pattern IS NULL;
UPDATE exercises SET movement_pattern = 'other'           WHERE name IN ('Copenhagen Plank', 'Serratus Punch', 'Banded Clamshell') AND movement_pattern IS NULL;
UPDATE exercises SET movement_pattern = 'horizontal_pull' WHERE name IN ('Seal Row', 'Meadows Row', 'Pendlay Row', 'Helms Row', 'Chest-Supported Dumbbell Row', 'Cable Face Pull') AND movement_pattern IS NULL;
UPDATE exercises SET movement_pattern = 'horizontal_push' WHERE name IN ('Spoto Press', 'Larsen Press') AND movement_pattern IS NULL;
UPDATE exercises SET movement_pattern = 'vertical_push'   WHERE name = 'Z Press' AND movement_pattern IS NULL;
UPDATE exercises SET movement_pattern = 'elbow_flexion'   WHERE name = 'Bayesian Cable Curl' AND movement_pattern IS NULL;
UPDATE exercises SET movement_pattern = 'hip_hinge'       WHERE name = 'Cable Pull-Through' AND movement_pattern IS NULL;
UPDATE exercises SET movement_pattern = 'lateral_raise'   WHERE name = 'Cable Lateral Raise' AND movement_pattern IS NULL;
UPDATE exercises SET movement_pattern = 'isolation'       WHERE name IN ('Cable External Rotation', 'Cable Internal Rotation') AND movement_pattern IS NULL;
UPDATE exercises SET movement_pattern = 'other'           WHERE name IN ('Sled Pull', 'Battle Ropes') AND movement_pattern IS NULL;
UPDATE exercises SET movement_pattern = 'squat'           WHERE name IN ('Standing Broad Jump', 'Wall Ball') AND movement_pattern IS NULL;
UPDATE exercises SET movement_pattern = 'carry'           WHERE name = 'Farmer''s Walk' AND movement_pattern IS NULL;
UPDATE exercises SET movement_pattern = 'single_leg_squat' WHERE name = 'Bulgarian Split Squat' AND movement_pattern IS NULL;
UPDATE exercises SET movement_pattern = 'isolation'       WHERE name = 'Nordic Hamstring Curl' AND movement_pattern IS NULL;

-- Exercise type (push/pull/legs/core)
UPDATE exercises SET exercise_type = 'pull'  WHERE name IN ('Band Pull-Apart', 'Seal Row', 'Meadows Row', 'Pendlay Row', 'Helms Row', 'Chest-Supported Dumbbell Row', 'Cable Face Pull', 'Bayesian Cable Curl', 'Side-Lying External Rotation', 'Cable External Rotation', 'Sled Pull', 'Cable Pull-Through', 'Dead Hang', 'Prone Y-T-W Raise') AND exercise_type IS NULL;
UPDATE exercises SET exercise_type = 'push'  WHERE name IN ('Spoto Press', 'Larsen Press', 'Z Press', 'Serratus Punch', 'Cable Internal Rotation', 'Cable Lateral Raise', 'Wall Ball', 'Wall Slide') AND exercise_type IS NULL;
UPDATE exercises SET exercise_type = 'core'  WHERE name IN ('Bird Dog', 'Copenhagen Plank', 'Cable Woodchop High-to-Low', 'Cable Woodchop Low-to-High') AND exercise_type IS NULL;
UPDATE exercises SET exercise_type = 'legs'  WHERE name IN ('Bulgarian Split Squat', 'Nordic Hamstring Curl', 'Standing Broad Jump', 'Banded Clamshell') AND exercise_type IS NULL;
UPDATE exercises SET exercise_type = 'full_body' WHERE name IN ('Farmer''s Walk', 'Battle Ropes') AND exercise_type IS NULL;

-- Laterality
UPDATE exercises SET laterality = 'bilateral' WHERE name IN ('Band Pull-Apart', 'Dead Hang', 'Seal Row', 'Pendlay Row', 'Spoto Press', 'Larsen Press', 'Z Press', 'Standing Broad Jump', 'Wall Ball', 'Battle Ropes', 'Nordic Hamstring Curl') AND laterality IS NULL;
UPDATE exercises SET laterality = 'unilateral' WHERE name IN ('Meadows Row', 'Bayesian Cable Curl', 'Side-Lying External Rotation', 'Cable External Rotation', 'Cable Internal Rotation', 'Cable Lateral Raise', 'Cable Woodchop High-to-Low', 'Cable Woodchop Low-to-High', 'Serratus Punch') AND laterality IS NULL;
UPDATE exercises SET laterality = 'both' WHERE name IN ('Bird Dog', 'Copenhagen Plank', 'Wall Slide', 'Prone Y-T-W Raise', 'Banded Clamshell', 'Helms Row', 'Chest-Supported Dumbbell Row', 'Cable Face Pull', 'Cable Pull-Through', 'Sled Pull', 'Farmer''s Walk', 'Bulgarian Split Squat') AND laterality IS NULL;

-- Equipment category
UPDATE exercises SET equipment_category = 'band'      WHERE name IN ('Band Pull-Apart', 'Banded Clamshell') AND equipment_category IS NULL;
UPDATE exercises SET equipment_category = 'bodyweight' WHERE name IN ('Dead Hang', 'Bird Dog', 'Copenhagen Plank', 'Wall Slide', 'Prone Y-T-W Raise', 'Standing Broad Jump', 'Nordic Hamstring Curl') AND equipment_category IS NULL;
UPDATE exercises SET equipment_category = 'barbell'    WHERE name IN ('Seal Row', 'Pendlay Row', 'Spoto Press', 'Larsen Press', 'Z Press') AND equipment_category IS NULL;
UPDATE exercises SET equipment_category = 'dumbbell'   WHERE name IN ('Helms Row', 'Chest-Supported Dumbbell Row', 'Side-Lying External Rotation', 'Bulgarian Split Squat', 'Farmer''s Walk', 'Serratus Punch') AND equipment_category IS NULL;
UPDATE exercises SET equipment_category = 'cable'      WHERE name IN ('Bayesian Cable Curl', 'Cable Face Pull', 'Cable Pull-Through', 'Cable Woodchop High-to-Low', 'Cable Woodchop Low-to-High', 'Cable Lateral Raise', 'Cable External Rotation', 'Cable Internal Rotation') AND equipment_category IS NULL;
UPDATE exercises SET equipment_category = 'other'      WHERE name IN ('Sled Pull', 'Battle Ropes', 'Wall Ball', 'Meadows Row') AND equipment_category IS NULL;

-- Difficulty level (1-5)
UPDATE exercises SET difficulty_level = 1 WHERE name IN ('Band Pull-Apart', 'Dead Hang', 'Wall Slide', 'Banded Clamshell', 'Cable Lateral Raise', 'Cable External Rotation', 'Cable Internal Rotation', 'Battle Ropes') AND difficulty_level IS NULL;
UPDATE exercises SET difficulty_level = 2 WHERE name IN ('Bird Dog', 'Prone Y-T-W Raise', 'Serratus Punch', 'Side-Lying External Rotation', 'Helms Row', 'Chest-Supported Dumbbell Row', 'Cable Face Pull', 'Cable Pull-Through', 'Sled Pull', 'Farmer''s Walk', 'Standing Broad Jump', 'Wall Ball') AND difficulty_level IS NULL;
UPDATE exercises SET difficulty_level = 3 WHERE name IN ('Copenhagen Plank', 'Seal Row', 'Meadows Row', 'Pendlay Row', 'Cable Woodchop High-to-Low', 'Cable Woodchop Low-to-High', 'Bayesian Cable Curl', 'Larsen Press', 'Spoto Press') AND difficulty_level IS NULL;
UPDATE exercises SET difficulty_level = 4 WHERE name IN ('Z Press', 'Nordic Hamstring Curl', 'Bulgarian Split Squat') AND difficulty_level IS NULL;

-- Default rest seconds
UPDATE exercises SET default_rest_seconds = 30  WHERE name IN ('Band Pull-Apart', 'Wall Slide', 'Banded Clamshell') AND default_rest_seconds IS NULL;
UPDATE exercises SET default_rest_seconds = 45  WHERE name IN ('Cable External Rotation', 'Cable Internal Rotation', 'Side-Lying External Rotation', 'Prone Y-T-W Raise', 'Serratus Punch', 'Cable Lateral Raise') AND default_rest_seconds IS NULL;
UPDATE exercises SET default_rest_seconds = 60  WHERE name IN ('Bird Dog', 'Cable Face Pull', 'Cable Woodchop High-to-Low', 'Cable Woodchop Low-to-High', 'Bayesian Cable Curl', 'Battle Ropes', 'Dead Hang') AND default_rest_seconds IS NULL;
UPDATE exercises SET default_rest_seconds = 90  WHERE name IN ('Copenhagen Plank', 'Cable Pull-Through', 'Wall Ball', 'Standing Broad Jump', 'Sled Pull') AND default_rest_seconds IS NULL;
UPDATE exercises SET default_rest_seconds = 120 WHERE name IN ('Seal Row', 'Meadows Row', 'Pendlay Row', 'Helms Row', 'Chest-Supported Dumbbell Row', 'Larsen Press', 'Farmer''s Walk', 'Bulgarian Split Squat') AND default_rest_seconds IS NULL;
UPDATE exercises SET default_rest_seconds = 180 WHERE name IN ('Spoto Press', 'Z Press', 'Nordic Hamstring Curl') AND default_rest_seconds IS NULL;


-- =============================================================================
-- 4. EXERCISE SUBSTITUTIONS AND PROGRESSIONS
-- =============================================================================

-- Seal Row <-> Pendlay Row (same_pattern — both strict horizontal pulls)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 82, 'Both eliminate cheating: Seal Row via chest support, Pendlay Row via dead-stop. Seal Row is more strict.'
FROM exercises s, exercises t WHERE s.name = 'Seal Row' AND s.created_by IS NULL AND t.name = 'Pendlay Row' AND t.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 82, 'Pendlay Row allows heavier loading and trains hip hinge isometric strength.'
FROM exercises s, exercises t WHERE s.name = 'Pendlay Row' AND s.created_by IS NULL AND t.name = 'Seal Row' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

-- Chest-Supported Row <-> Helms Row (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 95, 'Essentially the same movement; Helms Row is the named variant.'
FROM exercises s, exercises t WHERE s.name = 'Chest-Supported Dumbbell Row' AND s.created_by IS NULL AND t.name = 'Helms Row' AND t.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 95, 'Same movement pattern; interchangeable.'
FROM exercises s, exercises t WHERE s.name = 'Helms Row' AND s.created_by IS NULL AND t.name = 'Chest-Supported Dumbbell Row' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

-- Spoto Press -> Bench Press (progression: Spoto is harder due to paused off-chest)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 90, 'Spoto Press is a bench press variation with a pause above the chest. Builds off-chest strength.'
FROM exercises s, exercises t WHERE s.name = 'Barbell Bench Press - Medium Grip' AND s.created_by IS NULL AND t.name = 'Spoto Press' AND t.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 90, 'Standard bench press with touch-and-go or slight pause on chest.'
FROM exercises s, exercises t WHERE s.name = 'Spoto Press' AND s.created_by IS NULL AND t.name = 'Barbell Bench Press - Medium Grip' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

-- Larsen Press -> Bench Press (same_pattern, no leg drive variant)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 85, 'Larsen Press removes leg drive; isolates upper body pressing musculature.'
FROM exercises s, exercises t WHERE s.name = 'Barbell Bench Press - Medium Grip' AND s.created_by IS NULL AND t.name = 'Larsen Press' AND t.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 85, 'Standard bench press adds leg drive for higher loading.'
FROM exercises s, exercises t WHERE s.name = 'Larsen Press' AND s.created_by IS NULL AND t.name = 'Barbell Bench Press - Medium Grip' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

-- Z Press <-> OHP (same_pattern: Z Press is harder due to no back support)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 80, 'Z Press removes back support and leg drive; exposes mobility restrictions.'
FROM exercises s, exercises t WHERE s.name = 'Barbell Shoulder Press' AND s.created_by IS NULL AND t.name = 'Z Press' AND t.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 80, 'Barbell shoulder press with back support and leg drive; Z Press is the stricter variation.'
FROM exercises s, exercises t WHERE s.name = 'Z Press' AND s.created_by IS NULL AND t.name = 'Barbell Shoulder Press' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

-- Bulgarian Split Squat <-> Reverse Lunge (same_muscles)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 78, 'Bulgarian split squat provides greater ROM and stability challenge; reverse lunge is more dynamic.'
FROM exercises s, exercises t WHERE s.name = 'Bulgarian Split Squat' AND s.created_by IS NULL AND t.name = 'Reverse Lunge' AND t.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 78, 'Reverse lunge easier to balance; Bulgarian split squat builds more single-leg strength.'
FROM exercises s, exercises t WHERE s.name = 'Reverse Lunge' AND s.created_by IS NULL AND t.name = 'Bulgarian Split Squat' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

-- Nordic Curl <-> Lying Leg Curl (same_muscles — both knee flexion focused)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 65, 'Nordic curl is bodyweight eccentric; leg curl is machine concentric. Nordic is far more demanding.'
FROM exercises s, exercises t WHERE s.name = 'Nordic Hamstring Curl' AND s.created_by IS NULL AND t.name = 'Lying Leg Curls' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

-- Cable Face Pull <-> Band Pull-Apart (same_muscles — both rear delt/external rotation)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 75, 'Both target rear deltoid and external rotation. Face pull adds resistance curve; band pull-apart is more accessible.'
FROM exercises s, exercises t WHERE s.name = 'Cable Face Pull' AND s.created_by IS NULL AND t.name = 'Band Pull-Apart' AND t.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 75, 'Band pull-apart is simpler; cable face pull adds external rotation component.'
FROM exercises s, exercises t WHERE s.name = 'Band Pull-Apart' AND s.created_by IS NULL AND t.name = 'Cable Face Pull' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

-- Cable Pull-Through <-> Romanian Deadlift (same_pattern — both hip hinges)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 72, 'Cable pull-through teaches the hip hinge with constant tension; RDL allows heavier loading.'
FROM exercises s, exercises t WHERE s.name = 'Cable Pull-Through' AND s.created_by IS NULL AND t.name = 'Romanian Deadlift' AND t.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 72, 'RDL is a free-weight hip hinge with higher loading potential.'
FROM exercises s, exercises t WHERE s.name = 'Romanian Deadlift' AND s.created_by IS NULL AND t.name = 'Cable Pull-Through' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

-- Cable Lateral Raise <-> Dumbbell Lateral Raise (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 88, 'Cable provides constant tension throughout ROM; dumbbell tension peaks at top.'
FROM exercises s, exercises t WHERE s.name = 'Cable Lateral Raise' AND s.created_by IS NULL AND t.name = 'Side Lateral Raise' AND t.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 88, 'Dumbbell version is simpler to set up; cable version provides more even tension.'
FROM exercises s, exercises t WHERE s.name = 'Side Lateral Raise' AND s.created_by IS NULL AND t.name = 'Cable Lateral Raise' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

-- Progression chains for new exercises

-- Prehab shoulder chain: Band Pull-Apart → Prone Y-T-W Raise → Cable Face Pull
-- (corrected order: bodyweight band → bodyweight multi-angle → cable loaded)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, progression_order, notes)
SELECT s.id, t.id, 'progression', 70, 1, 'Band Pull-Apart builds basic rear delt activation; Y-T-W adds multi-angle scapular work.'
FROM exercises s, exercises t WHERE s.name = 'Band Pull-Apart' AND s.created_by IS NULL AND t.name = 'Prone Y-T-W Raise' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

-- Row progression: Helms Row → Seal Row → Pendlay Row → Meadows Row
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, progression_order, notes)
SELECT s.id, t.id, 'progression', 80, 1, 'Helms Row (incline support) → Seal Row (flat support). Both chest-supported, Seal Row requires more back strength.'
FROM exercises s, exercises t WHERE s.name = 'Helms Row' AND s.created_by IS NULL AND t.name = 'Seal Row' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, progression_order, notes)
SELECT s.id, t.id, 'progression', 75, 2, 'Seal Row (supported) → Pendlay Row (free-standing). Removes chest support, adds lower back demand.'
FROM exercises s, exercises t WHERE s.name = 'Seal Row' AND s.created_by IS NULL AND t.name = 'Pendlay Row' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, progression_order, notes)
SELECT s.id, t.id, 'progression', 70, 3, 'Pendlay Row (bilateral) → Meadows Row (unilateral landmine). Adds coordination and unilateral strength demand.'
FROM exercises s, exercises t WHERE s.name = 'Pendlay Row' AND s.created_by IS NULL AND t.name = 'Meadows Row' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

-- Prehab shoulder chain: Band Pull-Apart → Prone Y-T-W Raise → Cable Face Pull
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, progression_order, notes)
SELECT s.id, t.id, 'progression', 65, 2, 'Prone Y-T-W adds multi-angle scapular work; Cable Face Pull adds external rotation under load.'
FROM exercises s, exercises t WHERE s.name = 'Prone Y-T-W Raise' AND s.created_by IS NULL AND t.name = 'Cable Face Pull' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

-- Bulgarian Split Squat progression chain
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, progression_order, notes)
SELECT s.id, t.id, 'progression', 75, 1, 'Step-up → Bulgarian split squat. BSS requires more balance and single-leg strength.'
FROM exercises s, exercises t WHERE s.name = 'Step-Up' AND s.created_by IS NULL AND t.name = 'Bulgarian Split Squat' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

-- Hip hinge progression: Cable Pull-Through → Romanian Deadlift → Conventional Deadlift
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, progression_order, prerequisite_1rm_ratio, notes)
SELECT s.id, t.id, 'progression', 72, 1, 0.5, 'Cable pull-through teaches hip hinge; Romanian deadlift adds free-weight loading.'
FROM exercises s, exercises t WHERE s.name = 'Cable Pull-Through' AND s.created_by IS NULL AND t.name = 'Romanian Deadlift' AND t.created_by IS NULL ON CONFLICT DO NOTHING;


-- =============================================================================
-- 5. REFRESH MUSCLE PROFILES (denormalized JSONB on exercises table)
-- =============================================================================
-- Call the refresh function for all newly added exercises to populate muscle_profile JSONB.
-- This function was created in migration 035.

DO $$ DECLARE
  ex_id uuid;
BEGIN
  FOR ex_id IN
    SELECT e.id FROM exercises e
    WHERE e.name IN (
      'Band Pull-Apart', 'Dead Hang', 'Bird Dog', 'Copenhagen Plank', 'Serratus Punch',
      'Wall Slide', 'Prone Y-T-W Raise', 'Banded Clamshell',
      'Side-Lying External Rotation', 'Seal Row', 'Meadows Row', 'Pendlay Row',
      'Helms Row', 'Chest-Supported Dumbbell Row', 'Spoto Press', 'Larsen Press',
      'Z Press', 'Bayesian Cable Curl', 'Cable Face Pull', 'Cable Pull-Through',
      'Cable Woodchop High-to-Low', 'Cable Woodchop Low-to-High', 'Cable Lateral Raise',
      'Cable External Rotation', 'Cable Internal Rotation', 'Sled Pull',
      'Battle Ropes', 'Standing Broad Jump', 'Wall Ball', 'Farmer''s Walk',
      'Bulgarian Split Squat', 'Nordic Hamstring Curl'
    ) AND e.created_by IS NULL
  LOOP
    PERFORM refresh_exercise_muscle_profile(ex_id);
  END LOOP;
END $$;


COMMIT;
