-- Migration 053: Exercise Substitution Expansion
-- Adds same_pattern and same_muscles substitution links for popular exercises
-- that currently lack alternatives. Focuses on exercises users commonly need
-- substitutes for (e.g., "I don't have a barbell, what can I do instead?").
--
-- Substitution types: same_pattern (same movement, different equipment),
-- same_muscles (same primary muscles, different pattern)
-- Similarity scores: 90+ nearly identical, 70-89 very similar, 50-69 moderate
--
-- All inserts use ON CONFLICT DO NOTHING for idempotency.

BEGIN;

-- =============================================================================
-- 1. DUMBBELL ↔ BARBELL EQUIVALENTS (same_pattern, high similarity)
-- =============================================================================

-- Dumbbell Shoulder Press ↔ Barbell Shoulder Press
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 90, 'Dumbbell version allows independent arm movement and greater ROM.'
FROM exercises s, exercises t WHERE s.name = 'Dumbbell Shoulder Press' AND s.created_by IS NULL AND t.name = 'Barbell Shoulder Press' AND t.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 90, 'Barbell version allows heavier loading.'
FROM exercises s, exercises t WHERE s.name = 'Barbell Shoulder Press' AND s.created_by IS NULL AND t.name = 'Dumbbell Shoulder Press' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

-- Dumbbell Bicep Curl ↔ Barbell Curl
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 92, 'Dumbbell allows supination through ROM; barbell fixes grip.'
FROM exercises s, exercises t WHERE s.name = 'Dumbbell Bicep Curl' AND s.created_by IS NULL AND t.name = 'Barbell Curl' AND t.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 92, 'Barbell allows heavier loading and both arms work simultaneously.'
FROM exercises s, exercises t WHERE s.name = 'Barbell Curl' AND s.created_by IS NULL AND t.name = 'Dumbbell Bicep Curl' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

-- Hammer Curls ↔ Barbell Curl (same_muscles — both bicep dominant)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 75, 'Hammer grip shifts emphasis to brachioradialis and brachialis.'
FROM exercises s, exercises t WHERE s.name = 'Hammer Curls' AND s.created_by IS NULL AND t.name = 'Barbell Curl' AND t.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 75, 'Barbell curl is supinated grip; more bicep peak emphasis.'
FROM exercises s, exercises t WHERE s.name = 'Barbell Curl' AND s.created_by IS NULL AND t.name = 'Hammer Curls' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

-- =============================================================================
-- 2. MACHINE ↔ FREE WEIGHT EQUIVALENTS
-- =============================================================================

-- Leg Extensions ↔ Bulgarian Split Squat (same_muscles — both quad dominant)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 55, 'Leg extension is open chain isolation; BSS is closed chain compound with more glute activation.'
FROM exercises s, exercises t WHERE s.name = 'Leg Extensions' AND s.created_by IS NULL AND t.name = 'Bulgarian Split Squat' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

-- Lying Leg Curls ↔ Nordic Hamstring Curl (same_muscles — both hamstring)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 60, 'Nordic curl is bodyweight eccentric; much more demanding than machine curl.'
FROM exercises s, exercises t WHERE s.name = 'Lying Leg Curls' AND s.created_by IS NULL AND t.name = 'Nordic Hamstring Curl' AND t.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 60, 'Machine curl is more accessible; Nordic curl builds eccentric hamstring strength.'
FROM exercises s, exercises t WHERE s.name = 'Nordic Hamstring Curl' AND s.created_by IS NULL AND t.name = 'Lying Leg Curls' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

-- Leg Press ↔ Barbell Full Squat (same_muscles)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 72, 'Leg press removes spinal loading; squat recruits more stabilizers.'
FROM exercises s, exercises t WHERE s.name = 'Leg Press' AND s.created_by IS NULL AND t.name = 'Barbell Full Squat' AND t.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 72, 'Barbell squat is a full-body compound; leg press isolates the legs.'
FROM exercises s, exercises t WHERE s.name = 'Barbell Full Squat' AND s.created_by IS NULL AND t.name = 'Leg Press' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

-- =============================================================================
-- 3. BODYWEIGHT ↔ LOADED EQUIVALENTS
-- =============================================================================

-- Push-Ups ↔ Dumbbell Bench Press (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 70, 'Push-up is bodyweight horizontal push; DB bench allows progressive loading.'
FROM exercises s, exercises t WHERE s.name = 'Push-Ups' AND s.created_by IS NULL AND t.name = 'Dumbbell Bench Press' AND t.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 70, 'DB bench is a loaded horizontal push; push-up is the bodyweight equivalent.'
FROM exercises s, exercises t WHERE s.name = 'Dumbbell Bench Press' AND s.created_by IS NULL AND t.name = 'Push-Ups' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

-- Plank ↔ Ab Roller (same_muscles — both anti-extension core)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 65, 'Both train anti-extension; ab roller has greater lever arm and is more challenging.'
FROM exercises s, exercises t WHERE s.name = 'Plank' AND s.created_by IS NULL AND t.name = 'Ab Roller' AND t.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 65, 'Plank is static; ab roller is dynamic with greater range. Both anti-extension.'
FROM exercises s, exercises t WHERE s.name = 'Ab Roller' AND s.created_by IS NULL AND t.name = 'Plank' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

-- =============================================================================
-- 4. CABLE ↔ FREE WEIGHT EQUIVALENTS
-- =============================================================================

-- Cable Lateral Raise ↔ Side Lateral Raise (already in 047, but adding Dumbbell Flyes ↔ Cable Crossover)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 85, 'Both are chest fly variations; cable provides constant tension, DB has peak tension at bottom.'
FROM exercises s, exercises t WHERE s.name = 'Dumbbell Flyes' AND s.created_by IS NULL AND t.name = 'Cable Crossover' AND t.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 85, 'Cable crossover provides constant tension through full ROM; DB flyes peak at stretch.'
FROM exercises s, exercises t WHERE s.name = 'Cable Crossover' AND s.created_by IS NULL AND t.name = 'Dumbbell Flyes' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

-- Bayesian Cable Curl ↔ Incline Dumbbell Curl (same_muscles — both stretch the long head)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 80, 'Both load the bicep at full stretch; Bayesian uses cable tension, incline uses gravity.'
FROM exercises s, exercises t WHERE s.name = 'Bayesian Cable Curl' AND s.created_by IS NULL AND t.name = 'Incline Dumbbell Curl' AND t.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 80, 'Incline curl stretches the long head via shoulder extension; Bayesian curl does the same with cable.'
FROM exercises s, exercises t WHERE s.name = 'Incline Dumbbell Curl' AND s.created_by IS NULL AND t.name = 'Bayesian Cable Curl' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

-- =============================================================================
-- 5. ROWING VARIANTS (cross-link new exercises)
-- =============================================================================

-- Helms Row ↔ One-Arm Dumbbell Row (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 75, 'Both are chest-supported dumbbell rows; Helms is bilateral on incline, one-arm is unilateral.'
FROM exercises s, exercises t WHERE s.name = 'Helms Row' AND s.created_by IS NULL AND t.name = 'One-Arm Dumbbell Row' AND t.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 75, 'One-arm row allows heavier unilateral loading; Helms row eliminates lower back strain.'
FROM exercises s, exercises t WHERE s.name = 'One-Arm Dumbbell Row' AND s.created_by IS NULL AND t.name = 'Helms Row' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

-- Pendlay Row ↔ Bent Over Barbell Row (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 88, 'Pendlay row is dead-stop strict form; bent-over row allows more body English and continuous tension.'
FROM exercises s, exercises t WHERE s.name = 'Pendlay Row' AND s.created_by IS NULL AND t.name = 'Bent Over Barbell Row' AND t.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 88, 'Bent-over row allows more weight and continuous tension; Pendlay row enforces strict form.'
FROM exercises s, exercises t WHERE s.name = 'Bent Over Barbell Row' AND s.created_by IS NULL AND t.name = 'Pendlay Row' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

-- =============================================================================
-- 6. PRESSING VARIANTS
-- =============================================================================

-- Z Press ↔ Seated Barbell Military Press (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 78, 'Z Press removes back support entirely; seated press provides partial support.'
FROM exercises s, exercises t WHERE s.name = 'Z Press' AND s.created_by IS NULL AND t.name = 'Seated Barbell Military Press' AND t.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 78, 'Seated press has back support; Z Press is the strictest overhead press variant.'
FROM exercises s, exercises t WHERE s.name = 'Seated Barbell Military Press' AND s.created_by IS NULL AND t.name = 'Z Press' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

-- Larsen Press ↔ Spoto Press (same_pattern — both bench variants)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 82, 'Both are bench press variations that remove advantages: Larsen removes leg drive, Spoto removes stretch reflex.'
FROM exercises s, exercises t WHERE s.name = 'Larsen Press' AND s.created_by IS NULL AND t.name = 'Spoto Press' AND t.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 82, 'Both build bench press weak points; Spoto targets off-chest strength, Larsen targets upper body isolation.'
FROM exercises s, exercises t WHERE s.name = 'Spoto Press' AND s.created_by IS NULL AND t.name = 'Larsen Press' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

-- =============================================================================
-- 7. HIP HINGE VARIANTS
-- =============================================================================

-- Romanian Deadlift ↔ Cable Pull-Through (already in 047)
-- Barbell Hip Thrust ↔ Glute Bridge (same_muscles)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 82, 'Both target glutes via hip extension; hip thrust allows heavier loading, bridge is bodyweight.'
FROM exercises s, exercises t WHERE s.name = 'Barbell Hip Thrust' AND s.created_by IS NULL AND t.name = 'Glute Bridge' AND t.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 82, 'Glute bridge is a bodyweight regression; hip thrust adds barbell loading.'
FROM exercises s, exercises t WHERE s.name = 'Glute Bridge' AND s.created_by IS NULL AND t.name = 'Barbell Hip Thrust' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

-- =============================================================================
-- 8. PREHAB EQUIVALENTS
-- =============================================================================

-- Band Pull-Apart ↔ Prone Y-T-W Raise (same_muscles — rear delt / scapular)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 70, 'Both target scapular retractors and rear delts; Y-T-W adds multi-angle variation.'
FROM exercises s, exercises t WHERE s.name = 'Band Pull-Apart' AND s.created_by IS NULL AND t.name = 'Prone Y-T-W Raise' AND t.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 70, 'Band pull-apart is simpler; Y-T-W targets three shoulder positions.'
FROM exercises s, exercises t WHERE s.name = 'Prone Y-T-W Raise' AND s.created_by IS NULL AND t.name = 'Band Pull-Apart' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

-- Cable External Rotation ↔ Side-Lying External Rotation (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 88, 'Both target infraspinatus/teres minor; cable provides constant tension, side-lying uses gravity.'
FROM exercises s, exercises t WHERE s.name = 'Cable External Rotation' AND s.created_by IS NULL AND t.name = 'Side-Lying External Rotation' AND t.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 88, 'Side-lying uses dumbbell + gravity; cable version provides adjustable resistance.'
FROM exercises s, exercises t WHERE s.name = 'Side-Lying External Rotation' AND s.created_by IS NULL AND t.name = 'Cable External Rotation' AND t.created_by IS NULL ON CONFLICT DO NOTHING;


COMMIT;
