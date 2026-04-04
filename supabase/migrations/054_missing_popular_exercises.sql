-- Migration 054: Missing Popular Exercises
-- Adds commonly-searched exercises that are still absent from the library.
-- Each with full metadata: instructions, form_tips, movement_pattern,
-- exercise_type, laterality, difficulty_level, equipment_category, default_rest_seconds.

BEGIN;

-- =============================================================================
-- 1. INSERT EXERCISES
-- =============================================================================

INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, form_tips, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(), 'Landmine Press', 'push', 'intermediate', 'compound', 'barbell', 'strength',
  ARRAY['Place one end of a barbell in a landmine attachment or wedge it into a corner.', 'Stand facing the barbell, holding the loaded end at shoulder height with one or both hands.', 'Press the barbell up and forward in an arc until your arm is fully extended.', 'Lower under control back to shoulder height.', 'Complete all reps, then switch sides if doing single-arm.'],
  ARRAY['The arc path is easier on shoulders than strict overhead pressing.', 'Great alternative for lifters with shoulder mobility limitations.', 'Can be done standing, half-kneeling, or tall-kneeling for different stability demands.'],
  ARRAY[]::text[], false, NULL
) ON CONFLICT DO NOTHING;

INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, form_tips, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(), 'Belt Squat', 'push', 'intermediate', 'compound', 'machine', 'strength',
  ARRAY['Attach the belt around your hips and stand on the platforms.', 'Squat down by bending at the hips and knees, keeping your torso upright.', 'Descend until your thighs are at least parallel to the floor.', 'Drive through your feet to stand back up.', 'Repeat for prescribed reps.'],
  ARRAY['Zero spinal loading — ideal for those with back issues or after heavy deadlifts.', 'Allows very upright torso, maximizing quad emphasis.', 'Can be loaded much heavier than goblet squats with no upper body limitation.'],
  ARRAY[]::text[], false, NULL
) ON CONFLICT DO NOTHING;

INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, form_tips, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(), 'GHD Back Extension', 'pull', 'intermediate', 'compound', 'other', 'strength',
  ARRAY['Position yourself face down in the GHD with your hips on the pad and feet secured.', 'Cross your arms over your chest or hold a weight plate.', 'Lower your torso toward the floor by hinging at the hips.', 'Extend your hips and lower back to raise your torso back to parallel.', 'Avoid hyperextending — stop when your body forms a straight line.'],
  ARRAY['GHD = Glute-Ham Developer. Focus on the hip hinge, not lower back arching.', 'Start with bodyweight; add a plate across your chest to progress.', 'Also called a "hip extension" or "back raise" on the GHD.'],
  ARRAY[]::text[], false, NULL
) ON CONFLICT DO NOTHING;

INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, form_tips, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(), 'Hip Abduction Machine', 'push', 'beginner', 'isolation', 'machine', 'strength',
  ARRAY['Sit in the machine with your back against the pad and legs inside the thigh pads.', 'Select an appropriate weight.', 'Press your legs outward against the pads by squeezing your glutes.', 'Hold briefly at maximum abduction.', 'Return slowly to the starting position under control.'],
  ARRAY['Focus on squeezing the glutes, not just pushing with your legs.', 'Do not use momentum — slow and controlled reps are more effective.', 'Lean slightly forward to increase glute medius activation.'],
  ARRAY[]::text[], false, NULL
) ON CONFLICT DO NOTHING;

INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, form_tips, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(), 'Machine Chest Press', 'push', 'beginner', 'compound', 'machine', 'strength',
  ARRAY['Adjust the seat so the handles are at mid-chest height.', 'Sit with your back flat against the pad and grip the handles.', 'Press the handles forward until your arms are fully extended.', 'Slowly return to the starting position, allowing a full stretch in the chest.', 'Repeat for prescribed reps.'],
  ARRAY['Machines provide a fixed path — useful for beginners or training to failure safely.', 'Adjust the seat height to change emphasis: lower = more chest, higher = more shoulder.', 'Use as a finisher after free-weight pressing to safely push to failure.'],
  ARRAY[]::text[], false, NULL
) ON CONFLICT DO NOTHING;

INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, form_tips, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(), 'Machine Row', 'pull', 'beginner', 'compound', 'machine', 'strength',
  ARRAY['Adjust the chest pad so you can reach the handles with arms fully extended.', 'Sit with your chest against the pad and grip the handles.', 'Pull the handles toward your body by squeezing your shoulder blades together.', 'Hold the contraction briefly.', 'Return to the starting position under control.'],
  ARRAY['Keep your chest pressed against the pad throughout — do not lean back.', 'Drive elbows back, not just pulling with your biceps.', 'Great for beginners learning the rowing pattern before free weights.'],
  ARRAY[]::text[], false, NULL
) ON CONFLICT DO NOTHING;

INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, form_tips, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(), 'Pause Squat', 'push', 'advanced', 'compound', 'barbell', 'strength',
  ARRAY['Set up as you would for a standard back squat.', 'Unrack the bar and descend to the bottom position.', 'Pause for 2-3 seconds at the bottom with full tension — do not relax.', 'Drive up explosively from the paused position.', 'Repeat for prescribed reps.'],
  ARRAY['The pause eliminates the stretch reflex, building strength out of the hole.', 'Use 70-85% of your normal squat weight due to increased difficulty.', 'Maintain full-body tension during the pause — do not relax or shift.'],
  ARRAY[]::text[], false, NULL
) ON CONFLICT DO NOTHING;

INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, form_tips, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(), 'Pin Squat', 'push', 'advanced', 'compound', 'barbell', 'strength',
  ARRAY['Set safety pins in a power rack at your desired bottom position (usually parallel or slightly below).', 'Unrack the bar and squat down until the bar rests on the pins.', 'Pause briefly, then drive the bar up from a dead stop on the pins.', 'Re-rack and reset between reps if doing dead-stop reps.', 'Can also be done as continuous reps, touching the pins briefly.'],
  ARRAY['Builds concentric strength from a dead stop — no stretch reflex assistance.', 'Pin height determines the sticking point you are targeting.', 'Start light — dead-stop squats are significantly harder than touch-and-go.'],
  ARRAY[]::text[], false, NULL
) ON CONFLICT DO NOTHING;

INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, form_tips, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(), 'Safety Bar Squat', 'push', 'intermediate', 'compound', 'barbell', 'strength',
  ARRAY['Position the safety squat bar on your upper back with the handles in front of you.', 'Grip the handles and unrack the bar.', 'Squat down as you would for a back squat, pushing your knees out.', 'Drive through your feet to stand back up.', 'The cambered bar shifts the center of gravity forward, increasing upper back demand.'],
  ARRAY['Easier on the shoulders than a straight bar — no external rotation required.', 'The forward-shifted load makes this more quad and upper back dominant.', 'Also called SSB Squat. Great for lifters with shoulder or elbow issues.'],
  ARRAY[]::text[], false, NULL
) ON CONFLICT DO NOTHING;

INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, form_tips, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(), 'TRX Row', 'pull', 'beginner', 'compound', 'other', 'strength',
  ARRAY['Attach TRX straps to a secure overhead anchor.', 'Grip the handles and lean back with arms extended, body in a straight line.', 'Pull your chest toward the handles by squeezing your shoulder blades together.', 'Hold briefly at the top.', 'Lower under control back to the starting position.'],
  ARRAY['The more horizontal your body, the harder the exercise.', 'Keep your body rigid like a plank — do not let your hips sag.', 'Great entry point for the pulling pattern before progressing to pull-ups.'],
  ARRAY[]::text[], false, NULL
) ON CONFLICT DO NOTHING;

INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, form_tips, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(), 'TRX Chest Press', 'push', 'beginner', 'compound', 'other', 'strength',
  ARRAY['Attach TRX straps to a secure overhead anchor.', 'Face away from the anchor, gripping the handles at chest height.', 'Lean forward with arms extended, body in a straight line.', 'Lower your chest toward the handles by bending your elbows.', 'Press back to the starting position.'],
  ARRAY['The steeper your lean angle, the harder the exercise.', 'Like a push-up with an unstable base — great for stabilizer activation.', 'Keep your core braced and body straight throughout.'],
  ARRAY[]::text[], false, NULL
) ON CONFLICT DO NOTHING;


-- =============================================================================
-- 2. MUSCLE MAPPINGS
-- =============================================================================

-- Landmine Press: primary=shoulders, chest; secondary=triceps
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Landmine Press' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Landmine Press' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Landmine Press' AND e.created_by IS NULL ON CONFLICT DO NOTHING;

-- Belt Squat: primary=quads, glutes; secondary=hamstrings, adductors
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Belt Squat' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 8, true FROM exercises e WHERE e.name = 'Belt Squat' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Belt Squat' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 16, false FROM exercises e WHERE e.name = 'Belt Squat' AND e.created_by IS NULL ON CONFLICT DO NOTHING;

-- GHD Back Extension: primary=glutes, hamstrings, lower back
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 8, true FROM exercises e WHERE e.name = 'GHD Back Extension' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 11, true FROM exercises e WHERE e.name = 'GHD Back Extension' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 13, true FROM exercises e WHERE e.name = 'GHD Back Extension' AND e.created_by IS NULL ON CONFLICT DO NOTHING;

-- Hip Abduction Machine: primary=glutes; secondary=adductors (antagonist stabilizer)
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 8, true FROM exercises e WHERE e.name = 'Hip Abduction Machine' AND e.created_by IS NULL ON CONFLICT DO NOTHING;

-- Machine Chest Press: primary=chest, triceps; secondary=shoulders
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Machine Chest Press' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Machine Chest Press' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Machine Chest Press' AND e.created_by IS NULL ON CONFLICT DO NOTHING;

-- Machine Row: primary=lats, traps; secondary=biceps
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Machine Row' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 9, true FROM exercises e WHERE e.name = 'Machine Row' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Machine Row' AND e.created_by IS NULL ON CONFLICT DO NOTHING;

-- Pause Squat / Pin Squat / Safety Bar Squat: same as barbell squat
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 15, true FROM exercises e WHERE e.name IN ('Pause Squat', 'Pin Squat', 'Safety Bar Squat') AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 8, true FROM exercises e WHERE e.name IN ('Pause Squat', 'Pin Squat', 'Safety Bar Squat') AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 11, false FROM exercises e WHERE e.name IN ('Pause Squat', 'Pin Squat', 'Safety Bar Squat') AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 13, false FROM exercises e WHERE e.name IN ('Pause Squat', 'Pin Squat', 'Safety Bar Squat') AND e.created_by IS NULL ON CONFLICT DO NOTHING;

-- TRX Row: primary=lats, traps; secondary=biceps
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 12, true FROM exercises e WHERE e.name = 'TRX Row' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 9, true FROM exercises e WHERE e.name = 'TRX Row' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 1, false FROM exercises e WHERE e.name = 'TRX Row' AND e.created_by IS NULL ON CONFLICT DO NOTHING;

-- TRX Chest Press: primary=chest; secondary=triceps, shoulders
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 4, true FROM exercises e WHERE e.name = 'TRX Chest Press' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 3, false FROM exercises e WHERE e.name = 'TRX Chest Press' AND e.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary) SELECT e.id, 2, false FROM exercises e WHERE e.name = 'TRX Chest Press' AND e.created_by IS NULL ON CONFLICT DO NOTHING;


-- =============================================================================
-- 3. ENRICHMENT METADATA
-- =============================================================================

UPDATE exercises SET movement_pattern = 'vertical_push' WHERE name = 'Landmine Press' AND movement_pattern IS NULL;
UPDATE exercises SET movement_pattern = 'squat' WHERE name IN ('Belt Squat', 'Pause Squat', 'Pin Squat', 'Safety Bar Squat') AND movement_pattern IS NULL;
UPDATE exercises SET movement_pattern = 'hip_hinge' WHERE name = 'GHD Back Extension' AND movement_pattern IS NULL;
UPDATE exercises SET movement_pattern = 'isolation' WHERE name = 'Hip Abduction Machine' AND movement_pattern IS NULL;
UPDATE exercises SET movement_pattern = 'horizontal_push' WHERE name IN ('Machine Chest Press', 'TRX Chest Press') AND movement_pattern IS NULL;
UPDATE exercises SET movement_pattern = 'horizontal_pull' WHERE name IN ('Machine Row', 'TRX Row') AND movement_pattern IS NULL;

UPDATE exercises SET exercise_type = 'push' WHERE name IN ('Landmine Press', 'Machine Chest Press', 'TRX Chest Press', 'Belt Squat', 'Pause Squat', 'Pin Squat', 'Safety Bar Squat') AND exercise_type IS NULL;
UPDATE exercises SET exercise_type = 'pull' WHERE name IN ('GHD Back Extension', 'Machine Row', 'TRX Row') AND exercise_type IS NULL;
UPDATE exercises SET exercise_type = 'legs' WHERE name = 'Hip Abduction Machine' AND exercise_type IS NULL;

UPDATE exercises SET laterality = 'both' WHERE name = 'Landmine Press' AND laterality IS NULL;
UPDATE exercises SET laterality = 'bilateral' WHERE name IN ('Belt Squat', 'Pause Squat', 'Pin Squat', 'Safety Bar Squat', 'Machine Chest Press', 'Machine Row', 'Hip Abduction Machine') AND laterality IS NULL;
UPDATE exercises SET laterality = 'both' WHERE name IN ('GHD Back Extension', 'TRX Row', 'TRX Chest Press') AND laterality IS NULL;

UPDATE exercises SET difficulty_level = 2 WHERE name IN ('Machine Chest Press', 'Machine Row', 'Hip Abduction Machine', 'TRX Row', 'TRX Chest Press') AND difficulty_level IS NULL;
UPDATE exercises SET difficulty_level = 3 WHERE name IN ('Landmine Press', 'Belt Squat', 'GHD Back Extension', 'Safety Bar Squat') AND difficulty_level IS NULL;
UPDATE exercises SET difficulty_level = 4 WHERE name IN ('Pause Squat', 'Pin Squat') AND difficulty_level IS NULL;

UPDATE exercises SET equipment_category = 'barbell' WHERE name IN ('Landmine Press', 'Pause Squat', 'Pin Squat', 'Safety Bar Squat') AND equipment_category IS NULL;
UPDATE exercises SET equipment_category = 'machine' WHERE name IN ('Belt Squat', 'Machine Chest Press', 'Machine Row', 'Hip Abduction Machine') AND equipment_category IS NULL;
UPDATE exercises SET equipment_category = 'other' WHERE name IN ('GHD Back Extension', 'TRX Row', 'TRX Chest Press') AND equipment_category IS NULL;

UPDATE exercises SET default_rest_seconds = 120 WHERE name IN ('Belt Squat', 'Pause Squat', 'Pin Squat', 'Safety Bar Squat', 'Landmine Press') AND default_rest_seconds IS NULL;
UPDATE exercises SET default_rest_seconds = 90 WHERE name IN ('Machine Chest Press', 'Machine Row', 'GHD Back Extension', 'TRX Row', 'TRX Chest Press') AND default_rest_seconds IS NULL;
UPDATE exercises SET default_rest_seconds = 60 WHERE name = 'Hip Abduction Machine' AND default_rest_seconds IS NULL;

-- Aliases
UPDATE exercises SET aliases = ARRAY['Landmine Shoulder Press', 'Angled Press', 'Landmine OHP'] WHERE name = 'Landmine Press' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;
UPDATE exercises SET aliases = ARRAY['Hip Belt Squat', 'Rhino Squat'] WHERE name = 'Belt Squat' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;
UPDATE exercises SET aliases = ARRAY['GHD Hip Extension', 'Glute Ham Back Raise', 'Back Raise'] WHERE name = 'GHD Back Extension' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;
UPDATE exercises SET aliases = ARRAY['Hip Abductor', 'Abduction Machine', 'Outer Thigh Machine'] WHERE name = 'Hip Abduction Machine' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;
UPDATE exercises SET aliases = ARRAY['SSB Squat', 'Yoke Bar Squat', 'Hatfield Squat'] WHERE name = 'Safety Bar Squat' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;
UPDATE exercises SET aliases = ARRAY['Suspension Row', 'Ring Row', 'Inverted TRX Row'] WHERE name = 'TRX Row' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;
UPDATE exercises SET aliases = ARRAY['Suspension Push-Up', 'TRX Push-Up', 'Ring Push-Up'] WHERE name = 'TRX Chest Press' AND (aliases IS NULL OR aliases = '{}') AND created_by IS NULL;

-- Substitution links
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 78, 'Belt squat removes spinal loading; back squat is the standard loaded squat.'
FROM exercises s, exercises t WHERE s.name = 'Belt Squat' AND s.created_by IS NULL AND t.name = 'Barbell Full Squat' AND t.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 78, 'Back squat loads the spine; belt squat is the spinal-deloaded alternative.'
FROM exercises s, exercises t WHERE s.name = 'Barbell Full Squat' AND s.created_by IS NULL AND t.name = 'Belt Squat' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 90, 'Both are barbell squats; pause squat eliminates stretch reflex.'
FROM exercises s, exercises t WHERE s.name = 'Barbell Full Squat' AND s.created_by IS NULL AND t.name = 'Pause Squat' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 85, 'Safety bar shifts load forward; easier on shoulders, harder on upper back.'
FROM exercises s, exercises t WHERE s.name = 'Barbell Full Squat' AND s.created_by IS NULL AND t.name = 'Safety Bar Squat' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 72, 'TRX row is bodyweight; machine row is loaded. Both horizontal pulls with chest support.'
FROM exercises s, exercises t WHERE s.name = 'TRX Row' AND s.created_by IS NULL AND t.name = 'Machine Row' AND t.created_by IS NULL ON CONFLICT DO NOTHING;
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 72, 'Machine row provides fixed path; TRX row requires stabilization.'
FROM exercises s, exercises t WHERE s.name = 'Machine Row' AND s.created_by IS NULL AND t.name = 'TRX Row' AND t.created_by IS NULL ON CONFLICT DO NOTHING;

-- Refresh muscle profiles for new exercises
DO $$ DECLARE ex_id uuid;
BEGIN
  FOR ex_id IN
    SELECT e.id FROM exercises e WHERE e.name IN (
      'Landmine Press', 'Belt Squat', 'GHD Back Extension', 'Hip Abduction Machine',
      'Machine Chest Press', 'Machine Row', 'Pause Squat', 'Pin Squat',
      'Safety Bar Squat', 'TRX Row', 'TRX Chest Press'
    ) AND e.created_by IS NULL
  LOOP
    PERFORM refresh_exercise_muscle_profile(ex_id);
  END LOOP;
END $$;


COMMIT;
