-- Exercise substitutions: evidence-based exercise alternatives
-- Source: NSCA Essentials of Strength Training and Conditioning (4th ed.),
--         ACSM Guidelines for Exercise Testing and Prescription (11th ed.),
--         Schoenfeld 2010 (muscle activation EMG comparisons)
--
-- Substitution types:
--   same_pattern  = same movement, different equipment/implement
--   same_muscles  = same primary muscles, different movement pattern
--   regression    = easier variant (source is harder, target is easier)
--   progression   = harder variant (source is easier, target is harder)
--
-- Similarity scoring (1-100):
--   90+  Nearly identical stimulus (e.g., barbell vs dumbbell same exercise)
--   70-89 Very similar, minor stimulus differences (grip, angle)
--   50-69 Moderately similar, same primary muscles but different feel
--   30-49 Loosely related, overlapping muscles but different movement
--
-- Each substitution is directional; both A->B and B->A are inserted where
-- the relationship is symmetric (same_pattern, same_muscles). Regression/
-- progression pairs are inserted once per direction.

-- =============================================================================
-- 1. HORIZONTAL PRESSING (Chest / Triceps / Anterior Deltoid)
-- =============================================================================

-- Barbell Bench Press <-> Dumbbell Bench Press (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 92,
  'Dumbbell version allows greater ROM and unilateral balance; barbell allows heavier loading. EMG activation of pec major is comparable (Saeterbakken 2011).'
FROM exercises s, exercises t
WHERE s.name = 'Barbell Bench Press - Medium Grip' AND s.created_by IS NULL
  AND t.name = 'Dumbbell Bench Press' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 92,
  'Barbell version allows heavier loading; dumbbell version provides greater ROM and unilateral stability demand.'
FROM exercises s, exercises t
WHERE s.name = 'Dumbbell Bench Press' AND s.created_by IS NULL
  AND t.name = 'Barbell Bench Press - Medium Grip' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Barbell Bench Press <-> Machine Bench Press (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 78,
  'Machine removes stabilizer demand; useful for beginners or training to failure safely.'
FROM exercises s, exercises t
WHERE s.name = 'Barbell Bench Press - Medium Grip' AND s.created_by IS NULL
  AND t.name = 'Machine Bench Press' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 78,
  'Free weight bench press recruits more stabilizers; machine is safer for solo training to failure.'
FROM exercises s, exercises t
WHERE s.name = 'Machine Bench Press' AND s.created_by IS NULL
  AND t.name = 'Barbell Bench Press - Medium Grip' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Barbell Bench Press <-> Close-Grip Barbell Bench Press (same_pattern, shifts emphasis to triceps)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 80,
  'Close grip shifts emphasis to triceps and anterior deltoid; reduces pec stretch. Same horizontal press pattern.'
FROM exercises s, exercises t
WHERE s.name = 'Barbell Bench Press - Medium Grip' AND s.created_by IS NULL
  AND t.name = 'Close-Grip Barbell Bench Press' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 80,
  'Medium grip distributes load more evenly across pec, deltoid, and triceps compared to close grip.'
FROM exercises s, exercises t
WHERE s.name = 'Close-Grip Barbell Bench Press' AND s.created_by IS NULL
  AND t.name = 'Barbell Bench Press - Medium Grip' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Bench Press -> Push-Up (regression)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'regression', 72,
  'Push-up is a bodyweight regression of bench press; same horizontal push pattern with ~65% BW load. Good entry point for beginners.'
FROM exercises s, exercises t
WHERE s.name = 'Barbell Bench Press - Medium Grip' AND s.created_by IS NULL
  AND t.name = 'Pushups' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Push-Up -> Bench Press (progression)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'progression', 72,
  'Barbell bench press allows progressive overload beyond bodyweight; next step after push-ups become easy.'
FROM exercises s, exercises t
WHERE s.name = 'Pushups' AND s.created_by IS NULL
  AND t.name = 'Barbell Bench Press - Medium Grip' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Barbell Bench Press <-> Dumbbell Flyes (same_muscles)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 55,
  'Flyes isolate pec major with horizontal adduction; bench press is compound. Flyes provide greater pec stretch at bottom ROM.'
FROM exercises s, exercises t
WHERE s.name = 'Barbell Bench Press - Medium Grip' AND s.created_by IS NULL
  AND t.name = 'Dumbbell Flyes' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 55,
  'Bench press is compound (pec, delt, tri); flyes isolate pec via horizontal adduction only.'
FROM exercises s, exercises t
WHERE s.name = 'Dumbbell Flyes' AND s.created_by IS NULL
  AND t.name = 'Barbell Bench Press - Medium Grip' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Dumbbell Flyes <-> Cable Crossover (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 85,
  'Both are horizontal adduction isolation movements; cables maintain constant tension throughout ROM vs. gravity-dependent dumbbells.'
FROM exercises s, exercises t
WHERE s.name = 'Dumbbell Flyes' AND s.created_by IS NULL
  AND t.name = 'Cable Crossover' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 85,
  'Both target pec major via horizontal adduction; dumbbells provide greater stretch at bottom, cables provide constant tension.'
FROM exercises s, exercises t
WHERE s.name = 'Cable Crossover' AND s.created_by IS NULL
  AND t.name = 'Dumbbell Flyes' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Dumbbell Flyes <-> Flat Bench Cable Flyes (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 90,
  'Same supine fly movement; cables provide more constant tension curve vs. dumbbell gravity-only resistance.'
FROM exercises s, exercises t
WHERE s.name = 'Dumbbell Flyes' AND s.created_by IS NULL
  AND t.name = 'Flat Bench Cable Flyes' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 90,
  'Same supine fly movement; dumbbells allow easier setup but lose tension at top of ROM.'
FROM exercises s, exercises t
WHERE s.name = 'Flat Bench Cable Flyes' AND s.created_by IS NULL
  AND t.name = 'Dumbbell Flyes' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- =============================================================================
-- 2. INCLINE PRESSING (Upper Chest / Anterior Deltoid)
-- =============================================================================

-- Barbell Incline Bench <-> Incline Dumbbell Press (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 92,
  'Same incline press pattern; dumbbells allow greater adduction at top and independent arm work. EMG of upper pec is comparable.'
FROM exercises s, exercises t
WHERE s.name = 'Barbell Incline Bench Press - Medium Grip' AND s.created_by IS NULL
  AND t.name = 'Incline Dumbbell Press' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 92,
  'Barbell allows heavier loading on incline; dumbbell provides greater ROM and unilateral correction.'
FROM exercises s, exercises t
WHERE s.name = 'Incline Dumbbell Press' AND s.created_by IS NULL
  AND t.name = 'Barbell Incline Bench Press - Medium Grip' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Incline Dumbbell Press <-> Incline Dumbbell Flyes (same_muscles)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 60,
  'Both target upper pec at incline angle; flyes isolate via horizontal adduction while press is compound.'
FROM exercises s, exercises t
WHERE s.name = 'Incline Dumbbell Press' AND s.created_by IS NULL
  AND t.name = 'Incline Dumbbell Flyes' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 60,
  'Press adds tricep and anterior delt compound loading; flyes isolate upper pec stretch and adduction.'
FROM exercises s, exercises t
WHERE s.name = 'Incline Dumbbell Flyes' AND s.created_by IS NULL
  AND t.name = 'Incline Dumbbell Press' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Incline Dumbbell Flyes <-> Incline Cable Flye (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 90,
  'Same incline fly movement; cables maintain tension at top of ROM where dumbbells lose resistance.'
FROM exercises s, exercises t
WHERE s.name = 'Incline Dumbbell Flyes' AND s.created_by IS NULL
  AND t.name = 'Incline Cable Flye' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 90,
  'Dumbbell incline flyes provide greater eccentric stretch; cable version keeps constant tension.'
FROM exercises s, exercises t
WHERE s.name = 'Incline Cable Flye' AND s.created_by IS NULL
  AND t.name = 'Incline Dumbbell Flyes' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Flat Bench <-> Incline Bench (same_muscles, different angle)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 75,
  'Incline shifts emphasis to clavicular (upper) pec and anterior delt; flat emphasizes sternal pec. Both are horizontal press compounds.'
FROM exercises s, exercises t
WHERE s.name = 'Barbell Bench Press - Medium Grip' AND s.created_by IS NULL
  AND t.name = 'Barbell Incline Bench Press - Medium Grip' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 75,
  'Flat bench emphasizes sternal (lower/mid) pec; incline targets clavicular head more. Trebs et al. 2010 EMG data.'
FROM exercises s, exercises t
WHERE s.name = 'Barbell Incline Bench Press - Medium Grip' AND s.created_by IS NULL
  AND t.name = 'Barbell Bench Press - Medium Grip' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- =============================================================================
-- 3. DECLINE PRESSING (Lower Chest)
-- =============================================================================

-- Decline Barbell Bench <-> Decline Dumbbell Bench (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 92,
  'Same decline angle; dumbbell allows greater ROM and addresses bilateral imbalances.'
FROM exercises s, exercises t
WHERE s.name = 'Decline Barbell Bench Press' AND s.created_by IS NULL
  AND t.name = 'Decline Dumbbell Bench Press' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 92,
  'Barbell allows heavier loading on decline; both target sternal pec with reduced anterior delt involvement.'
FROM exercises s, exercises t
WHERE s.name = 'Decline Dumbbell Bench Press' AND s.created_by IS NULL
  AND t.name = 'Decline Barbell Bench Press' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Decline Bench <-> Dips Chest Version (same_muscles)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 70,
  'Chest dips mimic decline press angle; both target lower pec with tricep involvement. Dips add more bodyweight demand.'
FROM exercises s, exercises t
WHERE s.name = 'Decline Barbell Bench Press' AND s.created_by IS NULL
  AND t.name = 'Dips - Chest Version' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 70,
  'Decline press allows precise loading; chest dips use bodyweight at a similar angle targeting lower pec.'
FROM exercises s, exercises t
WHERE s.name = 'Dips - Chest Version' AND s.created_by IS NULL
  AND t.name = 'Decline Barbell Bench Press' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Decline Dumbbell Flyes <-> Decline Barbell Bench (same_muscles)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 55,
  'Decline flyes isolate lower pec via horizontal adduction; decline bench is compound including triceps.'
FROM exercises s, exercises t
WHERE s.name = 'Decline Dumbbell Flyes' AND s.created_by IS NULL
  AND t.name = 'Decline Barbell Bench Press' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 55,
  'Decline bench is compound (pec + tri + delt); decline flyes isolate sternal pec with greater stretch.'
FROM exercises s, exercises t
WHERE s.name = 'Decline Barbell Bench Press' AND s.created_by IS NULL
  AND t.name = 'Decline Dumbbell Flyes' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- =============================================================================
-- 4. DIPS (Chest vs Triceps emphasis)
-- =============================================================================

-- Dips Chest <-> Dips Triceps (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 75,
  'Same movement; forward lean targets pec, upright targets triceps. Adjust torso angle to shift emphasis.'
FROM exercises s, exercises t
WHERE s.name = 'Dips - Chest Version' AND s.created_by IS NULL
  AND t.name = 'Dips - Triceps Version' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 75,
  'Upright dips emphasize triceps; forward lean shifts load to pec major. Same joint actions.'
FROM exercises s, exercises t
WHERE s.name = 'Dips - Triceps Version' AND s.created_by IS NULL
  AND t.name = 'Dips - Chest Version' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Dips -> Bench Dips (regression)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'regression', 70,
  'Bench dips reduce load by supporting feet on floor/bench; good stepping stone before full parallel bar dips.'
FROM exercises s, exercises t
WHERE s.name = 'Dips - Triceps Version' AND s.created_by IS NULL
  AND t.name = 'Bench Dips' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Bench Dips -> Dips (progression)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'progression', 70,
  'Full parallel bar dips require supporting entire bodyweight; progress from bench dips when 3x12 is comfortable.'
FROM exercises s, exercises t
WHERE s.name = 'Bench Dips' AND s.created_by IS NULL
  AND t.name = 'Dips - Triceps Version' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Dips <-> Dip Machine (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 80,
  'Machine dip provides counterweight assistance; same pressing pattern. Good for those who cannot do bodyweight dips.'
FROM exercises s, exercises t
WHERE s.name = 'Dips - Triceps Version' AND s.created_by IS NULL
  AND t.name = 'Dip Machine' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 80,
  'Bodyweight dips recruit more stabilizers; machine version allows adjustable resistance.'
FROM exercises s, exercises t
WHERE s.name = 'Dip Machine' AND s.created_by IS NULL
  AND t.name = 'Dips - Triceps Version' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- =============================================================================
-- 5. SQUAT PATTERNS (Quadriceps / Glutes / Hamstrings)
-- =============================================================================

-- Barbell Full Squat <-> Barbell Squat (same_pattern, depth difference)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 95,
  'Full squat goes below parallel; standard squat to parallel. Full squat recruits more glute and adductor at deeper ROM.'
FROM exercises s, exercises t
WHERE s.name = 'Barbell Full Squat' AND s.created_by IS NULL
  AND t.name = 'Barbell Squat' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 95,
  'Standard squat to parallel; full squat adds deeper ROM. Both are bilateral barbell back squats.'
FROM exercises s, exercises t
WHERE s.name = 'Barbell Squat' AND s.created_by IS NULL
  AND t.name = 'Barbell Full Squat' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Barbell Full Squat <-> Front Barbell Squat (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 82,
  'Front squat shifts load anterior; more quad-dominant, requires more thoracic mobility. Reduces spinal compression vs back squat (Gullett 2009).'
FROM exercises s, exercises t
WHERE s.name = 'Barbell Full Squat' AND s.created_by IS NULL
  AND t.name = 'Front Barbell Squat' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 82,
  'Back squat allows heavier loads; front squat is more quad-dominant with more upright torso.'
FROM exercises s, exercises t
WHERE s.name = 'Front Barbell Squat' AND s.created_by IS NULL
  AND t.name = 'Barbell Full Squat' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Barbell Full Squat <-> Dumbbell Squat (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 75,
  'Dumbbell squat is a lighter, more accessible squat variant; limited by grip strength at higher loads.'
FROM exercises s, exercises t
WHERE s.name = 'Barbell Full Squat' AND s.created_by IS NULL
  AND t.name = 'Dumbbell Squat' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 75,
  'Barbell allows much heavier loading; dumbbell squat is limited by grip and upper body fatigue.'
FROM exercises s, exercises t
WHERE s.name = 'Dumbbell Squat' AND s.created_by IS NULL
  AND t.name = 'Barbell Full Squat' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Goblet Squat -> Front Squat -> Back Squat (regression/progression chain)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'progression', 78,
  'Front squat is the barbell progression of goblet squat; same upright torso, anterior load position, quad emphasis.'
FROM exercises s, exercises t
WHERE s.name = 'Goblet Squat' AND s.created_by IS NULL
  AND t.name = 'Front Barbell Squat' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'regression', 78,
  'Goblet squat teaches upright squat mechanics with lighter load; natural regression from front squat.'
FROM exercises s, exercises t
WHERE s.name = 'Front Barbell Squat' AND s.created_by IS NULL
  AND t.name = 'Goblet Squat' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'progression', 72,
  'Back squat allows heaviest loading in the squat pattern; progress from goblet squat once pattern is solid.'
FROM exercises s, exercises t
WHERE s.name = 'Goblet Squat' AND s.created_by IS NULL
  AND t.name = 'Barbell Full Squat' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'regression', 72,
  'Goblet squat is a beginner-friendly regression; teaches squat depth and upright posture with minimal equipment.'
FROM exercises s, exercises t
WHERE s.name = 'Barbell Full Squat' AND s.created_by IS NULL
  AND t.name = 'Goblet Squat' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Bodyweight Squat -> Goblet Squat (progression)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'progression', 80,
  'Goblet squat adds load while maintaining squat pattern; natural next step from bodyweight squat.'
FROM exercises s, exercises t
WHERE s.name = 'Bodyweight Squat' AND s.created_by IS NULL
  AND t.name = 'Goblet Squat' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'regression', 80,
  'Bodyweight squat removes all external load; use to learn squat pattern before adding weight.'
FROM exercises s, exercises t
WHERE s.name = 'Goblet Squat' AND s.created_by IS NULL
  AND t.name = 'Bodyweight Squat' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Barbell Full Squat <-> Leg Press (same_muscles)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 65,
  'Leg press targets quads, glutes, hamstrings without spinal loading; removes balance/core demand. Useful when back squat is contraindicated.'
FROM exercises s, exercises t
WHERE s.name = 'Barbell Full Squat' AND s.created_by IS NULL
  AND t.name = 'Leg Press' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 65,
  'Barbell squat is superior for total body recruitment; leg press isolates legs without spinal/core demand.'
FROM exercises s, exercises t
WHERE s.name = 'Leg Press' AND s.created_by IS NULL
  AND t.name = 'Barbell Full Squat' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Barbell Full Squat <-> Hack Squat (same_muscles)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 70,
  'Hack squat machine provides guided squat path with back support; emphasizes quad over posterior chain.'
FROM exercises s, exercises t
WHERE s.name = 'Barbell Full Squat' AND s.created_by IS NULL
  AND t.name = 'Hack Squat' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 70,
  'Free weight squat requires more stabilization and core; hack squat provides back support and fixed path.'
FROM exercises s, exercises t
WHERE s.name = 'Hack Squat' AND s.created_by IS NULL
  AND t.name = 'Barbell Full Squat' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Barbell Full Squat <-> Smith Machine Squat (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 72,
  'Smith machine removes stabilizer demand with fixed bar path; allows focus on quad drive but less functional transfer.'
FROM exercises s, exercises t
WHERE s.name = 'Barbell Full Squat' AND s.created_by IS NULL
  AND t.name = 'Smith Machine Squat' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 72,
  'Free weight squat has greater functional transfer and stabilizer recruitment vs. Smith machine fixed path.'
FROM exercises s, exercises t
WHERE s.name = 'Smith Machine Squat' AND s.created_by IS NULL
  AND t.name = 'Barbell Full Squat' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Leg Press <-> Hack Squat (same_muscles)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 78,
  'Both are machine-based quad-dominant movements with back support; hack squat has more upright torso angle.'
FROM exercises s, exercises t
WHERE s.name = 'Leg Press' AND s.created_by IS NULL
  AND t.name = 'Hack Squat' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 78,
  'Both target quads with machine support; leg press allows foot placement variation to shift emphasis.'
FROM exercises s, exercises t
WHERE s.name = 'Hack Squat' AND s.created_by IS NULL
  AND t.name = 'Leg Press' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- =============================================================================
-- 6. LUNGE PATTERNS (Unilateral Legs)
-- =============================================================================

-- Barbell Lunge <-> Dumbbell Lunges (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 90,
  'Same lunge pattern; dumbbells at sides vs barbell on back. Dumbbells are often easier to balance for beginners.'
FROM exercises s, exercises t
WHERE s.name = 'Barbell Lunge' AND s.created_by IS NULL
  AND t.name = 'Dumbbell Lunges' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 90,
  'Barbell lunge allows heavier loading; dumbbell lunge is more accessible with better balance.'
FROM exercises s, exercises t
WHERE s.name = 'Dumbbell Lunges' AND s.created_by IS NULL
  AND t.name = 'Barbell Lunge' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Lunge <-> Split Squat with Dumbbells (same_muscles)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 85,
  'Split squat is a static lunge; removes the dynamic stepping component. Both are unilateral quad/glute dominant.'
FROM exercises s, exercises t
WHERE s.name = 'Dumbbell Lunges' AND s.created_by IS NULL
  AND t.name = 'Split Squat with Dumbbells' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 85,
  'Lunge adds dynamic stepping; split squat is stationary. Same unilateral lower body muscles targeted.'
FROM exercises s, exercises t
WHERE s.name = 'Split Squat with Dumbbells' AND s.created_by IS NULL
  AND t.name = 'Dumbbell Lunges' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Barbell Walking Lunge <-> Barbell Lunge (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 92,
  'Walking version adds continuous forward locomotion; stationary lunge returns to start. Same muscles, slightly more metabolic demand walking.'
FROM exercises s, exercises t
WHERE s.name = 'Barbell Walking Lunge' AND s.created_by IS NULL
  AND t.name = 'Barbell Lunge' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 92,
  'Stationary lunge requires less space; walking lunge adds locomotion and metabolic challenge.'
FROM exercises s, exercises t
WHERE s.name = 'Barbell Lunge' AND s.created_by IS NULL
  AND t.name = 'Barbell Walking Lunge' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Leg Press <-> Leg Extensions (same_muscles, quad focus)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 45,
  'Both target quadriceps; leg extensions are open-chain isolation. Leg press is compound including glutes/hams.'
FROM exercises s, exercises t
WHERE s.name = 'Leg Press' AND s.created_by IS NULL
  AND t.name = 'Leg Extensions' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 45,
  'Leg press is multi-joint; leg extensions isolate quad only. Different training stimulus but both build quad size.'
FROM exercises s, exercises t
WHERE s.name = 'Leg Extensions' AND s.created_by IS NULL
  AND t.name = 'Leg Press' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- =============================================================================
-- 7. DEADLIFT PATTERNS (Posterior Chain)
-- =============================================================================

-- Barbell Deadlift <-> Sumo Deadlift (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 85,
  'Sumo stance widens feet and reduces ROM; shifts emphasis to adductors and quads while still targeting posterior chain. Individual leverages determine preference.'
FROM exercises s, exercises t
WHERE s.name = 'Barbell Deadlift' AND s.created_by IS NULL
  AND t.name = 'Sumo Deadlift' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 85,
  'Conventional stance emphasizes posterior chain (erectors, hams); sumo shifts to quads/adductors. Both are hip hinge pulls from floor.'
FROM exercises s, exercises t
WHERE s.name = 'Sumo Deadlift' AND s.created_by IS NULL
  AND t.name = 'Barbell Deadlift' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Barbell Deadlift <-> Trap Bar Deadlift (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 88,
  'Trap bar centers load and allows more upright torso; reduces spinal shear forces (Swinton 2011). More quad involvement than conventional.'
FROM exercises s, exercises t
WHERE s.name = 'Barbell Deadlift' AND s.created_by IS NULL
  AND t.name = 'Trap Bar Deadlift' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 88,
  'Conventional barbell deadlift has more hip hinge demand; trap bar is often safer for beginners due to neutral grip and centered load.'
FROM exercises s, exercises t
WHERE s.name = 'Trap Bar Deadlift' AND s.created_by IS NULL
  AND t.name = 'Barbell Deadlift' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Barbell Deadlift <-> Romanian Deadlift (same_muscles, different emphasis)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 72,
  'RDL is top-down with eccentric emphasis on hamstrings; conventional is floor-to-lockout. RDL isolates hip hinge with minimal quad contribution.'
FROM exercises s, exercises t
WHERE s.name = 'Barbell Deadlift' AND s.created_by IS NULL
  AND t.name = 'Romanian Deadlift' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 72,
  'Conventional deadlift involves quad drive off floor; RDL emphasizes eccentric hamstring loading from standing start.'
FROM exercises s, exercises t
WHERE s.name = 'Romanian Deadlift' AND s.created_by IS NULL
  AND t.name = 'Barbell Deadlift' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Romanian Deadlift <-> Stiff-Legged Barbell Deadlift (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 88,
  'Both are hip hinge movements emphasizing hamstrings; stiff-legged has straighter knees increasing hamstring stretch. Very similar EMG patterns.'
FROM exercises s, exercises t
WHERE s.name = 'Romanian Deadlift' AND s.created_by IS NULL
  AND t.name = 'Stiff-Legged Barbell Deadlift' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 88,
  'RDL maintains slight knee bend; stiff-leg has near-straight knees for greater hamstring stretch. Both are hip-hinge dominant.'
FROM exercises s, exercises t
WHERE s.name = 'Stiff-Legged Barbell Deadlift' AND s.created_by IS NULL
  AND t.name = 'Romanian Deadlift' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Romanian Deadlift <-> Stiff-Legged Dumbbell Deadlift (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 85,
  'Dumbbell version allows more natural arm path and addresses bilateral imbalances; same hip hinge pattern.'
FROM exercises s, exercises t
WHERE s.name = 'Romanian Deadlift' AND s.created_by IS NULL
  AND t.name = 'Stiff-Legged Dumbbell Deadlift' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 85,
  'Barbell RDL allows heavier loading; dumbbell SLDL provides more freedom of movement path.'
FROM exercises s, exercises t
WHERE s.name = 'Stiff-Legged Dumbbell Deadlift' AND s.created_by IS NULL
  AND t.name = 'Romanian Deadlift' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Romanian Deadlift <-> Good Morning (same_muscles)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 70,
  'Both target hamstrings and erectors via hip hinge; good morning has barbell on back instead of hanging in hands. Similar posterior chain demand.'
FROM exercises s, exercises t
WHERE s.name = 'Romanian Deadlift' AND s.created_by IS NULL
  AND t.name = 'Good Morning' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 70,
  'Good morning places bar on back (longer moment arm on spine); RDL has bar in hands. Both are hip hinge posterior chain exercises.'
FROM exercises s, exercises t
WHERE s.name = 'Good Morning' AND s.created_by IS NULL
  AND t.name = 'Romanian Deadlift' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- =============================================================================
-- 8. HIP THRUST / GLUTE FOCUS
-- =============================================================================

-- Barbell Hip Thrust <-> Glute Kickback (same_muscles)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 55,
  'Both target glute max via hip extension; hip thrust is bilateral with heavy load, kickback is unilateral and lighter.'
FROM exercises s, exercises t
WHERE s.name = 'Barbell Hip Thrust' AND s.created_by IS NULL
  AND t.name = 'Glute Kickback' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 55,
  'Hip thrust allows heavy bilateral loading of glutes; kickback isolates one side with lighter loads.'
FROM exercises s, exercises t
WHERE s.name = 'Glute Kickback' AND s.created_by IS NULL
  AND t.name = 'Barbell Hip Thrust' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Barbell Hip Thrust <-> Glute Ham Raise (same_muscles)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 58,
  'Both target glutes and hamstrings; hip thrust emphasizes glute max at full extension, GHR emphasizes hamstring eccentrically.'
FROM exercises s, exercises t
WHERE s.name = 'Barbell Hip Thrust' AND s.created_by IS NULL
  AND t.name = 'Glute Ham Raise' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 58,
  'GHR has strong eccentric hamstring demand; hip thrust is more glute-dominant at lockout.'
FROM exercises s, exercises t
WHERE s.name = 'Glute Ham Raise' AND s.created_by IS NULL
  AND t.name = 'Barbell Hip Thrust' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- =============================================================================
-- 9. LEG CURL PATTERNS (Hamstring Isolation)
-- =============================================================================

-- Lying Leg Curls <-> Seated Leg Curl (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 88,
  'Both isolate hamstrings via knee flexion; seated position pre-stretches hamstrings at hip. Seated may produce slightly greater activation (Schoenfeld 2021).'
FROM exercises s, exercises t
WHERE s.name = 'Lying Leg Curls' AND s.created_by IS NULL
  AND t.name = 'Seated Leg Curl' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 88,
  'Lying leg curl has hips extended (shorter hamstring); seated pre-stretches at hip. Both isolate knee flexion.'
FROM exercises s, exercises t
WHERE s.name = 'Seated Leg Curl' AND s.created_by IS NULL
  AND t.name = 'Lying Leg Curls' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Lying Leg Curls <-> Ball Leg Curl (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 65,
  'Stability ball leg curl targets hamstrings with bodyweight; adds core stabilization demand. Less precise loading than machine.'
FROM exercises s, exercises t
WHERE s.name = 'Lying Leg Curls' AND s.created_by IS NULL
  AND t.name = 'Ball Leg Curl' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 65,
  'Machine leg curl provides precise loading; ball curl is equipment-free alternative with instability challenge.'
FROM exercises s, exercises t
WHERE s.name = 'Ball Leg Curl' AND s.created_by IS NULL
  AND t.name = 'Lying Leg Curls' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Leg Extensions <-> Single-Leg Leg Extension (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 92,
  'Single-leg version addresses bilateral deficit and imbalances; same open-chain quad isolation movement.'
FROM exercises s, exercises t
WHERE s.name = 'Leg Extensions' AND s.created_by IS NULL
  AND t.name = 'Single-Leg Leg Extension' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 92,
  'Bilateral leg extension is faster to execute; single-leg addresses asymmetries.'
FROM exercises s, exercises t
WHERE s.name = 'Single-Leg Leg Extension' AND s.created_by IS NULL
  AND t.name = 'Leg Extensions' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- =============================================================================
-- 10. CALF RAISES
-- =============================================================================

-- Standing Calf Raises <-> Seated Calf Raise (same_muscles)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 65,
  'Standing targets gastrocnemius (knee extended); seated targets soleus (knee flexed). Both are plantarflexion but hit different calf muscles.'
FROM exercises s, exercises t
WHERE s.name = 'Standing Calf Raises' AND s.created_by IS NULL
  AND t.name = 'Seated Calf Raise' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 65,
  'Seated targets soleus (under gastrocnemius); standing targets gastrocnemius. Use both for complete calf development.'
FROM exercises s, exercises t
WHERE s.name = 'Seated Calf Raise' AND s.created_by IS NULL
  AND t.name = 'Standing Calf Raises' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Standing Calf Raises <-> Calf Press On The Leg Press Machine (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 82,
  'Both target gastrocnemius with extended knees; leg press calf raise allows heavier loading in a seated position.'
FROM exercises s, exercises t
WHERE s.name = 'Standing Calf Raises' AND s.created_by IS NULL
  AND t.name = 'Calf Press On The Leg Press Machine' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 82,
  'Leg press calf press allows heavy loading without spinal compression; standing version loads spine.'
FROM exercises s, exercises t
WHERE s.name = 'Calf Press On The Leg Press Machine' AND s.created_by IS NULL
  AND t.name = 'Standing Calf Raises' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Standing Barbell Calf Raise <-> Standing Dumbbell Calf Raise (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 92,
  'Same standing calf raise; dumbbells at sides vs barbell on back. Dumbbells reduce spinal compression.'
FROM exercises s, exercises t
WHERE s.name = 'Standing Barbell Calf Raise' AND s.created_by IS NULL
  AND t.name = 'Standing Dumbbell Calf Raise' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 92,
  'Barbell calf raise allows heavier loading; dumbbell version is limited by grip strength.'
FROM exercises s, exercises t
WHERE s.name = 'Standing Dumbbell Calf Raise' AND s.created_by IS NULL
  AND t.name = 'Standing Barbell Calf Raise' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- =============================================================================
-- 11. VERTICAL PULLING (Lats / Biceps / Rear Delts)
-- =============================================================================

-- Pullups <-> Chin-Up (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 85,
  'Chin-up (supinated grip) increases bicep involvement; pull-up (pronated) emphasizes lat/teres. Youdas 2010 EMG shows comparable lat activation.'
FROM exercises s, exercises t
WHERE s.name = 'Pullups' AND s.created_by IS NULL
  AND t.name = 'Chin-Up' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 85,
  'Pull-up (pronated) emphasizes lat width; chin-up (supinated) adds bicep contribution. Both are vertical pulling.'
FROM exercises s, exercises t
WHERE s.name = 'Chin-Up' AND s.created_by IS NULL
  AND t.name = 'Pullups' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Pullups <-> Wide-Grip Lat Pulldown (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 82,
  'Lat pulldown is the machine equivalent of pull-ups; allows adjustable load below bodyweight. Same vertical pull pattern.'
FROM exercises s, exercises t
WHERE s.name = 'Pullups' AND s.created_by IS NULL
  AND t.name = 'Wide-Grip Lat Pulldown' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 82,
  'Pull-ups use bodyweight and recruit more core/stabilizers; lat pulldown allows precise load selection.'
FROM exercises s, exercises t
WHERE s.name = 'Wide-Grip Lat Pulldown' AND s.created_by IS NULL
  AND t.name = 'Pullups' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Band Assisted Pull-Up -> Pullups (progression)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'progression', 90,
  'Unassisted pull-up is the progression from band-assisted; remove band assistance as strength increases.'
FROM exercises s, exercises t
WHERE s.name = 'Band Assisted Pull-Up' AND s.created_by IS NULL
  AND t.name = 'Pullups' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Pullups -> Band Assisted Pull-Up (regression)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'regression', 90,
  'Band reduces bodyweight load; use progressively thinner bands until unassisted pull-up is achievable.'
FROM exercises s, exercises t
WHERE s.name = 'Pullups' AND s.created_by IS NULL
  AND t.name = 'Band Assisted Pull-Up' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Wide-Grip Lat Pulldown -> Pullups (progression)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'progression', 82,
  'Pull-ups require supporting full bodyweight; progress from lat pulldown when pulling close to bodyweight.'
FROM exercises s, exercises t
WHERE s.name = 'Wide-Grip Lat Pulldown' AND s.created_by IS NULL
  AND t.name = 'Pullups' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Wide-Grip Lat Pulldown <-> V-Bar Pulldown (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 82,
  'V-bar uses neutral/close grip increasing bicep and mid-back involvement; wide grip emphasizes lat width. Same vertical pull.'
FROM exercises s, exercises t
WHERE s.name = 'Wide-Grip Lat Pulldown' AND s.created_by IS NULL
  AND t.name = 'V-Bar Pulldown' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 82,
  'Wide-grip emphasizes lat stretch and width; V-bar/close-grip adds more bicep and rhomboid involvement.'
FROM exercises s, exercises t
WHERE s.name = 'V-Bar Pulldown' AND s.created_by IS NULL
  AND t.name = 'Wide-Grip Lat Pulldown' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Wide-Grip Lat Pulldown <-> Close-Grip Front Lat Pulldown (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 85,
  'Close grip shifts emphasis to lower lats and biceps; wide grip targets upper lat and teres major more.'
FROM exercises s, exercises t
WHERE s.name = 'Wide-Grip Lat Pulldown' AND s.created_by IS NULL
  AND t.name = 'Close-Grip Front Lat Pulldown' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 85,
  'Both are cable lat pulldowns; grip width shifts lat emphasis. Close grip = lower lats/biceps, wide grip = upper lats.'
FROM exercises s, exercises t
WHERE s.name = 'Close-Grip Front Lat Pulldown' AND s.created_by IS NULL
  AND t.name = 'Wide-Grip Lat Pulldown' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Pullups -> Weighted Pull Ups (progression)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'progression', 95,
  'Weighted pull-ups add external load beyond bodyweight; the primary strength progression after bodyweight pull-ups become easy.'
FROM exercises s, exercises t
WHERE s.name = 'Pullups' AND s.created_by IS NULL
  AND t.name = 'Weighted Pull Ups' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'regression', 95,
  'Bodyweight pull-ups are the regression; remove added weight to return to bodyweight-only version.'
FROM exercises s, exercises t
WHERE s.name = 'Weighted Pull Ups' AND s.created_by IS NULL
  AND t.name = 'Pullups' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- =============================================================================
-- 12. HORIZONTAL PULLING / ROWS (Mid-Back / Lats / Biceps)
-- =============================================================================

-- Bent Over Barbell Row <-> Bent Over Two-Dumbbell Row (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 90,
  'Same bent-over row pattern; dumbbells allow greater ROM and independent arm movement. Barbell allows heavier loading.'
FROM exercises s, exercises t
WHERE s.name = 'Bent Over Barbell Row' AND s.created_by IS NULL
  AND t.name = 'Bent Over Two-Dumbbell Row' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 90,
  'Barbell row allows heavier bilateral loading; dumbbell row provides greater scapular retraction ROM.'
FROM exercises s, exercises t
WHERE s.name = 'Bent Over Two-Dumbbell Row' AND s.created_by IS NULL
  AND t.name = 'Bent Over Barbell Row' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Bent Over Barbell Row <-> One-Arm Dumbbell Row (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 82,
  'One-arm row provides bench support reducing lower back stress; allows greater unilateral ROM. Same horizontal pull pattern.'
FROM exercises s, exercises t
WHERE s.name = 'Bent Over Barbell Row' AND s.created_by IS NULL
  AND t.name = 'One-Arm Dumbbell Row' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 82,
  'Barbell row loads both sides simultaneously; one-arm DB row supports torso and addresses imbalances.'
FROM exercises s, exercises t
WHERE s.name = 'One-Arm Dumbbell Row' AND s.created_by IS NULL
  AND t.name = 'Bent Over Barbell Row' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Bent Over Barbell Row <-> Seated Cable Rows (same_muscles)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 75,
  'Seated cable row removes lower back demand with chest pad support; same horizontal pull muscles (lats, rhomboids, mid-traps).'
FROM exercises s, exercises t
WHERE s.name = 'Bent Over Barbell Row' AND s.created_by IS NULL
  AND t.name = 'Seated Cable Rows' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 75,
  'Barbell row taxes lower back isometrically; cable row provides back support. Both target mid-back and lats.'
FROM exercises s, exercises t
WHERE s.name = 'Seated Cable Rows' AND s.created_by IS NULL
  AND t.name = 'Bent Over Barbell Row' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Bent Over Barbell Row <-> T-Bar Row with Handle (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 85,
  'T-bar row uses same bent-over position with neutral grip; allows heavier loading with chest support on some setups.'
FROM exercises s, exercises t
WHERE s.name = 'Bent Over Barbell Row' AND s.created_by IS NULL
  AND t.name = 'T-Bar Row with Handle' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 85,
  'Both are bent-over rowing movements; T-bar provides neutral grip option and potentially chest support.'
FROM exercises s, exercises t
WHERE s.name = 'T-Bar Row with Handle' AND s.created_by IS NULL
  AND t.name = 'Bent Over Barbell Row' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Seated Cable Rows <-> Inverted Row (same_muscles)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 72,
  'Inverted row is a bodyweight horizontal pull; cable row allows precise load selection. Both target mid-back, lats, and biceps.'
FROM exercises s, exercises t
WHERE s.name = 'Seated Cable Rows' AND s.created_by IS NULL
  AND t.name = 'Inverted Row' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 72,
  'Cable row allows adjustable resistance; inverted row uses bodyweight and angle to control intensity.'
FROM exercises s, exercises t
WHERE s.name = 'Inverted Row' AND s.created_by IS NULL
  AND t.name = 'Seated Cable Rows' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Vertical Pull <-> Horizontal Pull (same_muscles, different plane)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 55,
  'Both target lats, biceps, and rear delts; pulldowns emphasize lat width (vertical adduction) while rows emphasize thickness (horizontal extension).'
FROM exercises s, exercises t
WHERE s.name = 'Wide-Grip Lat Pulldown' AND s.created_by IS NULL
  AND t.name = 'Seated Cable Rows' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 55,
  'Rows build back thickness; pulldowns build width. Both hit lats and biceps but in different planes.'
FROM exercises s, exercises t
WHERE s.name = 'Seated Cable Rows' AND s.created_by IS NULL
  AND t.name = 'Wide-Grip Lat Pulldown' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Reverse Grip Bent-Over Rows <-> Bent Over Barbell Row (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 85,
  'Supinated grip increases bicep involvement and shifts emphasis to lower lats; same bent-over row mechanics.'
FROM exercises s, exercises t
WHERE s.name = 'Reverse Grip Bent-Over Rows' AND s.created_by IS NULL
  AND t.name = 'Bent Over Barbell Row' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 85,
  'Pronated grip emphasizes upper back/rear delt; supinated grip shifts to lower lat and bicep.'
FROM exercises s, exercises t
WHERE s.name = 'Bent Over Barbell Row' AND s.created_by IS NULL
  AND t.name = 'Reverse Grip Bent-Over Rows' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- =============================================================================
-- 13. SHOULDER PRESS PATTERNS (Deltoids / Triceps)
-- =============================================================================

-- Barbell Shoulder Press <-> Dumbbell Shoulder Press (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 90,
  'Same overhead press pattern; dumbbells allow natural arc path and unilateral correction. Barbell allows heavier loading.'
FROM exercises s, exercises t
WHERE s.name = 'Barbell Shoulder Press' AND s.created_by IS NULL
  AND t.name = 'Dumbbell Shoulder Press' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 90,
  'Barbell allows heavier overhead loading; dumbbells provide greater ROM and address bilateral asymmetries.'
FROM exercises s, exercises t
WHERE s.name = 'Dumbbell Shoulder Press' AND s.created_by IS NULL
  AND t.name = 'Barbell Shoulder Press' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Barbell Shoulder Press <-> Standing Military Press (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 95,
  'Military press is a strict standing barbell overhead press; essentially the same exercise. Standing adds core demand.'
FROM exercises s, exercises t
WHERE s.name = 'Barbell Shoulder Press' AND s.created_by IS NULL
  AND t.name = 'Standing Military Press' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 95,
  'Both are barbell overhead presses; standing military press adds core stabilization demand.'
FROM exercises s, exercises t
WHERE s.name = 'Standing Military Press' AND s.created_by IS NULL
  AND t.name = 'Barbell Shoulder Press' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Barbell Shoulder Press <-> Seated Barbell Military Press (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 92,
  'Seated version removes standing balance demand; allows slightly heavier loads. Same overhead pressing pattern.'
FROM exercises s, exercises t
WHERE s.name = 'Barbell Shoulder Press' AND s.created_by IS NULL
  AND t.name = 'Seated Barbell Military Press' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 92,
  'Seated military press allows more focus on shoulders; standing version recruits core for stability.'
FROM exercises s, exercises t
WHERE s.name = 'Seated Barbell Military Press' AND s.created_by IS NULL
  AND t.name = 'Barbell Shoulder Press' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Dumbbell Shoulder Press <-> Arnold Dumbbell Press (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 82,
  'Arnold press adds pronation-to-supination rotation; increases anterior delt and rotator cuff involvement through greater ROM.'
FROM exercises s, exercises t
WHERE s.name = 'Dumbbell Shoulder Press' AND s.created_by IS NULL
  AND t.name = 'Arnold Dumbbell Press' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 82,
  'Standard DB press is simpler; Arnold press adds rotational component for greater anterior delt engagement.'
FROM exercises s, exercises t
WHERE s.name = 'Arnold Dumbbell Press' AND s.created_by IS NULL
  AND t.name = 'Dumbbell Shoulder Press' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Shoulder Press <-> Leverage Shoulder Press (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 78,
  'Leverage machine provides fixed path and back support; reduces stabilizer demand. Good for isolation or training to failure.'
FROM exercises s, exercises t
WHERE s.name = 'Barbell Shoulder Press' AND s.created_by IS NULL
  AND t.name = 'Leverage Shoulder Press' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 78,
  'Free weight press recruits more stabilizers; machine provides safety and consistent path for fatigued sets.'
FROM exercises s, exercises t
WHERE s.name = 'Leverage Shoulder Press' AND s.created_by IS NULL
  AND t.name = 'Barbell Shoulder Press' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- =============================================================================
-- 14. LATERAL RAISES (Medial Deltoid)
-- =============================================================================

-- Side Lateral Raise <-> Cable Seated Lateral Raise (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 85,
  'Cable provides constant tension through full ROM; dumbbell loses tension at bottom. Both target medial deltoid via shoulder abduction.'
FROM exercises s, exercises t
WHERE s.name = 'Side Lateral Raise' AND s.created_by IS NULL
  AND t.name = 'Cable Seated Lateral Raise' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 85,
  'Dumbbell lateral raise is simpler setup; cable provides superior tension curve for medial delt.'
FROM exercises s, exercises t
WHERE s.name = 'Cable Seated Lateral Raise' AND s.created_by IS NULL
  AND t.name = 'Side Lateral Raise' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Side Lateral Raise <-> Lateral Raise - With Bands (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 80,
  'Band provides progressive resistance; tension increases as band stretches at top of ROM. Same abduction pattern.'
FROM exercises s, exercises t
WHERE s.name = 'Side Lateral Raise' AND s.created_by IS NULL
  AND t.name = 'Lateral Raise - With Bands' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 80,
  'Both target medial deltoid; band is portable alternative with ascending resistance curve.'
FROM exercises s, exercises t
WHERE s.name = 'Lateral Raise - With Bands' AND s.created_by IS NULL
  AND t.name = 'Side Lateral Raise' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Seated Side Lateral Raise <-> Side Lateral Raise (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 92,
  'Seated version eliminates momentum and lower body cheating; stricter isolation of medial deltoid.'
FROM exercises s, exercises t
WHERE s.name = 'Seated Side Lateral Raise' AND s.created_by IS NULL
  AND t.name = 'Side Lateral Raise' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 92,
  'Standing version allows some body english for heavier loads; seated is stricter on medial delt isolation.'
FROM exercises s, exercises t
WHERE s.name = 'Side Lateral Raise' AND s.created_by IS NULL
  AND t.name = 'Seated Side Lateral Raise' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- =============================================================================
-- 15. FRONT RAISES (Anterior Deltoid)
-- =============================================================================

-- Front Dumbbell Raise <-> Front Cable Raise (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 88,
  'Cable provides constant tension on anterior delt; dumbbell loses tension at bottom. Same shoulder flexion movement.'
FROM exercises s, exercises t
WHERE s.name = 'Front Dumbbell Raise' AND s.created_by IS NULL
  AND t.name = 'Front Cable Raise' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 88,
  'Dumbbell front raise is more accessible; cable version maintains tension throughout full ROM.'
FROM exercises s, exercises t
WHERE s.name = 'Front Cable Raise' AND s.created_by IS NULL
  AND t.name = 'Front Dumbbell Raise' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Front Dumbbell Raise <-> Front Plate Raise (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 85,
  'Plate raise uses neutral grip and bilateral loading; targets same anterior delt via shoulder flexion.'
FROM exercises s, exercises t
WHERE s.name = 'Front Dumbbell Raise' AND s.created_by IS NULL
  AND t.name = 'Front Plate Raise' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 85,
  'Both are shoulder flexion movements for anterior delt; dumbbell allows unilateral work, plate is bilateral.'
FROM exercises s, exercises t
WHERE s.name = 'Front Plate Raise' AND s.created_by IS NULL
  AND t.name = 'Front Dumbbell Raise' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- =============================================================================
-- 16. REAR DELT / FACE PULLS
-- =============================================================================

-- Face Pull <-> Cable Rear Delt Fly (same_muscles)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 78,
  'Both target posterior deltoid and rotator cuff; face pull adds external rotation component important for shoulder health.'
FROM exercises s, exercises t
WHERE s.name = 'Face Pull' AND s.created_by IS NULL
  AND t.name = 'Cable Rear Delt Fly' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 78,
  'Rear delt fly isolates horizontal abduction; face pull adds external rotation for rotator cuff health (Reinold 2004).'
FROM exercises s, exercises t
WHERE s.name = 'Cable Rear Delt Fly' AND s.created_by IS NULL
  AND t.name = 'Face Pull' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Face Pull <-> Bent Over Dumbbell Rear Delt Raise With Head On Bench (same_muscles)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 72,
  'Both target posterior deltoid; face pull uses cable with external rotation, bent-over raise uses dumbbells with horizontal abduction.'
FROM exercises s, exercises t
WHERE s.name = 'Face Pull' AND s.created_by IS NULL
  AND t.name = 'Bent Over Dumbbell Rear Delt Raise With Head On Bench' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 72,
  'Dumbbell rear delt raise isolates posterior delt; face pull adds rotator cuff external rotation component.'
FROM exercises s, exercises t
WHERE s.name = 'Bent Over Dumbbell Rear Delt Raise With Head On Bench' AND s.created_by IS NULL
  AND t.name = 'Face Pull' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Seated Bent-Over Rear Delt Raise <-> Reverse Machine Flyes (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 82,
  'Machine reverse fly provides consistent resistance; dumbbell bent-over raise requires more stabilization. Both target posterior deltoid.'
FROM exercises s, exercises t
WHERE s.name = 'Seated Bent-Over Rear Delt Raise' AND s.created_by IS NULL
  AND t.name = 'Reverse Machine Flyes' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 82,
  'Reverse machine fly provides guided path; dumbbell version requires more postural stability.'
FROM exercises s, exercises t
WHERE s.name = 'Reverse Machine Flyes' AND s.created_by IS NULL
  AND t.name = 'Seated Bent-Over Rear Delt Raise' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Reverse Flyes <-> Cable Rear Delt Fly (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 88,
  'Cable version provides constant tension; dumbbell version is gravity-dependent. Both isolate posterior delt via horizontal abduction.'
FROM exercises s, exercises t
WHERE s.name = 'Reverse Flyes' AND s.created_by IS NULL
  AND t.name = 'Cable Rear Delt Fly' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 88,
  'Dumbbell reverse fly is simpler setup; cable version maintains tension throughout ROM.'
FROM exercises s, exercises t
WHERE s.name = 'Cable Rear Delt Fly' AND s.created_by IS NULL
  AND t.name = 'Reverse Flyes' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- =============================================================================
-- 17. SHRUGS (Upper Trapezius)
-- =============================================================================

-- Barbell Shrug <-> Dumbbell Shrug (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 92,
  'Same shrug pattern; dumbbells at sides allow slightly greater ROM and natural hand position. Barbell allows heavier loading.'
FROM exercises s, exercises t
WHERE s.name = 'Barbell Shrug' AND s.created_by IS NULL
  AND t.name = 'Dumbbell Shrug' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 92,
  'Barbell shrug allows heavier loading; dumbbell version provides more natural arm position and ROM.'
FROM exercises s, exercises t
WHERE s.name = 'Dumbbell Shrug' AND s.created_by IS NULL
  AND t.name = 'Barbell Shrug' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Barbell Shrug <-> Cable Shrugs (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 82,
  'Cable shrugs provide constant tension and different resistance angle; barbell is gravity-dependent vertical only.'
FROM exercises s, exercises t
WHERE s.name = 'Barbell Shrug' AND s.created_by IS NULL
  AND t.name = 'Cable Shrugs' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 82,
  'Both target upper trapezius via scapular elevation; cable provides constant tension, barbell allows heavier loads.'
FROM exercises s, exercises t
WHERE s.name = 'Cable Shrugs' AND s.created_by IS NULL
  AND t.name = 'Barbell Shrug' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Upright Barbell Row <-> Upright Cable Row (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 90,
  'Same upright row movement; cable provides constant tension. Both target upper traps and medial delts.'
FROM exercises s, exercises t
WHERE s.name = 'Upright Barbell Row' AND s.created_by IS NULL
  AND t.name = 'Upright Cable Row' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 90,
  'Barbell allows heavier loading; cable provides smoother resistance curve. Same shoulder abduction + scapular elevation pattern.'
FROM exercises s, exercises t
WHERE s.name = 'Upright Cable Row' AND s.created_by IS NULL
  AND t.name = 'Upright Barbell Row' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- =============================================================================
-- 18. BICEP CURL PATTERNS
-- =============================================================================

-- Barbell Curl <-> Dumbbell Bicep Curl (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 90,
  'Same standing curl pattern; dumbbells allow supination through ROM and independent arm work. Barbell allows heavier bilateral loading.'
FROM exercises s, exercises t
WHERE s.name = 'Barbell Curl' AND s.created_by IS NULL
  AND t.name = 'Dumbbell Bicep Curl' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 90,
  'Barbell curl fixes wrist position (may stress wrists); dumbbell curl allows natural supination.'
FROM exercises s, exercises t
WHERE s.name = 'Dumbbell Bicep Curl' AND s.created_by IS NULL
  AND t.name = 'Barbell Curl' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Barbell Curl <-> EZ-Bar Curl (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 92,
  'EZ bar reduces wrist strain with semi-supinated grip; slightly less bicep peak contraction than straight bar. Nearly identical stimulus.'
FROM exercises s, exercises t
WHERE s.name = 'Barbell Curl' AND s.created_by IS NULL
  AND t.name = 'EZ-Bar Curl' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 92,
  'Straight bar maximizes supination and bicep peak; EZ bar reduces wrist stress. Very similar bicep activation.'
FROM exercises s, exercises t
WHERE s.name = 'EZ-Bar Curl' AND s.created_by IS NULL
  AND t.name = 'Barbell Curl' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Barbell Curl <-> Standing Biceps Cable Curl (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 82,
  'Cable curl provides constant tension; barbell has variable resistance due to gravity. Same elbow flexion pattern.'
FROM exercises s, exercises t
WHERE s.name = 'Barbell Curl' AND s.created_by IS NULL
  AND t.name = 'Standing Biceps Cable Curl' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 82,
  'Cable maintains tension at top of curl where barbell loses it; barbell allows heavier loading.'
FROM exercises s, exercises t
WHERE s.name = 'Standing Biceps Cable Curl' AND s.created_by IS NULL
  AND t.name = 'Barbell Curl' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Barbell Curl <-> Preacher Curl (same_muscles)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 78,
  'Preacher curl eliminates momentum with arm pad support; emphasizes bicep short head and brachialis. Stricter isolation than standing curl.'
FROM exercises s, exercises t
WHERE s.name = 'Barbell Curl' AND s.created_by IS NULL
  AND t.name = 'Preacher Curl' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 78,
  'Standing curl allows some momentum; preacher curl locks arm position for strict bicep isolation.'
FROM exercises s, exercises t
WHERE s.name = 'Preacher Curl' AND s.created_by IS NULL
  AND t.name = 'Barbell Curl' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Preacher Curl <-> Cable Preacher Curl (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 90,
  'Cable version provides constant tension on preacher pad; barbell loses tension at top. Same supported arm position.'
FROM exercises s, exercises t
WHERE s.name = 'Preacher Curl' AND s.created_by IS NULL
  AND t.name = 'Cable Preacher Curl' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 90,
  'Both use arm pad for strict bicep isolation; cable maintains tension throughout ROM.'
FROM exercises s, exercises t
WHERE s.name = 'Cable Preacher Curl' AND s.created_by IS NULL
  AND t.name = 'Preacher Curl' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Concentration Curls <-> Preacher Curl (same_muscles)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 80,
  'Both eliminate momentum for strict bicep isolation; concentration curl uses inner thigh as brace, preacher uses pad.'
FROM exercises s, exercises t
WHERE s.name = 'Concentration Curls' AND s.created_by IS NULL
  AND t.name = 'Preacher Curl' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 80,
  'Both are strict isolation curls; concentration curl is unilateral, preacher can be bilateral.'
FROM exercises s, exercises t
WHERE s.name = 'Preacher Curl' AND s.created_by IS NULL
  AND t.name = 'Concentration Curls' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Hammer Curls <-> Cable Hammer Curls - Rope Attachment (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 88,
  'Both use neutral grip targeting brachialis and brachioradialis; cable provides constant tension vs. gravity-dependent dumbbells.'
FROM exercises s, exercises t
WHERE s.name = 'Hammer Curls' AND s.created_by IS NULL
  AND t.name = 'Cable Hammer Curls - Rope Attachment' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 88,
  'Dumbbell hammer curl is simpler; cable rope version maintains tension at top of movement.'
FROM exercises s, exercises t
WHERE s.name = 'Cable Hammer Curls - Rope Attachment' AND s.created_by IS NULL
  AND t.name = 'Hammer Curls' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Hammer Curls <-> Dumbbell Bicep Curl (same_muscles)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 75,
  'Hammer curl uses neutral grip (more brachialis/brachioradialis); supinated curl targets bicep short head more. Both are elbow flexion.'
FROM exercises s, exercises t
WHERE s.name = 'Hammer Curls' AND s.created_by IS NULL
  AND t.name = 'Dumbbell Bicep Curl' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 75,
  'Supinated curl emphasizes bicep peak; hammer curl targets brachialis for arm thickness. Both build arm size.'
FROM exercises s, exercises t
WHERE s.name = 'Dumbbell Bicep Curl' AND s.created_by IS NULL
  AND t.name = 'Hammer Curls' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Incline Dumbbell Curl <-> Dumbbell Bicep Curl (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 82,
  'Incline position pre-stretches bicep long head; standing allows heavier loads. Incline increases long head activation.'
FROM exercises s, exercises t
WHERE s.name = 'Incline Dumbbell Curl' AND s.created_by IS NULL
  AND t.name = 'Dumbbell Bicep Curl' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 82,
  'Standing allows heavier load; incline pre-stretches long head for greater activation at longer muscle lengths.'
FROM exercises s, exercises t
WHERE s.name = 'Dumbbell Bicep Curl' AND s.created_by IS NULL
  AND t.name = 'Incline Dumbbell Curl' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- =============================================================================
-- 19. TRICEP EXTENSION PATTERNS
-- =============================================================================

-- Triceps Pushdown <-> Triceps Pushdown - Rope Attachment (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 90,
  'Rope allows wrist pronation at bottom for greater lateral head contraction; bar version is simpler. Both are cable pushdowns.'
FROM exercises s, exercises t
WHERE s.name = 'Triceps Pushdown' AND s.created_by IS NULL
  AND t.name = 'Triceps Pushdown - Rope Attachment' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 90,
  'Bar pushdown is straightforward; rope allows split and pronation at bottom for greater tricep squeeze.'
FROM exercises s, exercises t
WHERE s.name = 'Triceps Pushdown - Rope Attachment' AND s.created_by IS NULL
  AND t.name = 'Triceps Pushdown' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Triceps Pushdown <-> Triceps Pushdown - V-Bar Attachment (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 92,
  'V-bar provides neutral grip reducing wrist strain; nearly identical to straight bar pushdown. Same cable extension mechanics.'
FROM exercises s, exercises t
WHERE s.name = 'Triceps Pushdown' AND s.created_by IS NULL
  AND t.name = 'Triceps Pushdown - V-Bar Attachment' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 92,
  'Both are cable tricep pushdowns; V-bar offers neutral grip, straight bar is pronated. Minimal difference.'
FROM exercises s, exercises t
WHERE s.name = 'Triceps Pushdown - V-Bar Attachment' AND s.created_by IS NULL
  AND t.name = 'Triceps Pushdown' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Cable Rope Overhead Triceps Extension <-> Standing Overhead Barbell Triceps Extension (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 85,
  'Both are overhead extensions stretching the long head; cable provides constant tension, barbell allows heavier loads.'
FROM exercises s, exercises t
WHERE s.name = 'Cable Rope Overhead Triceps Extension' AND s.created_by IS NULL
  AND t.name = 'Standing Overhead Barbell Triceps Extension' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 85,
  'Barbell overhead extension allows heavier loading; cable rope provides constant tension and wrist-friendly grip.'
FROM exercises s, exercises t
WHERE s.name = 'Standing Overhead Barbell Triceps Extension' AND s.created_by IS NULL
  AND t.name = 'Cable Rope Overhead Triceps Extension' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Triceps Pushdown <-> Cable Rope Overhead Triceps Extension (same_muscles)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 72,
  'Pushdown emphasizes lateral head; overhead extension stretches and emphasizes long head. Use both for complete tricep development.'
FROM exercises s, exercises t
WHERE s.name = 'Triceps Pushdown' AND s.created_by IS NULL
  AND t.name = 'Cable Rope Overhead Triceps Extension' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 72,
  'Overhead position stretches long head for greater activation; pushdown position emphasizes lateral head.'
FROM exercises s, exercises t
WHERE s.name = 'Cable Rope Overhead Triceps Extension' AND s.created_by IS NULL
  AND t.name = 'Triceps Pushdown' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Lying Triceps Press (Skull Crusher) <-> Decline EZ Bar Triceps Extension (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 85,
  'Decline angle increases ROM and long head stretch; flat skull crusher is the standard version. Both are lying tricep extensions.'
FROM exercises s, exercises t
WHERE s.name = 'Lying Triceps Press' AND s.created_by IS NULL
  AND t.name = 'Decline EZ Bar Triceps Extension' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 85,
  'Both are lying tricep extensions; decline increases ROM and stretch on long head.'
FROM exercises s, exercises t
WHERE s.name = 'Decline EZ Bar Triceps Extension' AND s.created_by IS NULL
  AND t.name = 'Lying Triceps Press' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Lying Triceps Press <-> Lying Dumbbell Tricep Extension (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 88,
  'Dumbbell version allows independent arm work and neutral grip; barbell version allows heavier bilateral loading.'
FROM exercises s, exercises t
WHERE s.name = 'Lying Triceps Press' AND s.created_by IS NULL
  AND t.name = 'Lying Dumbbell Tricep Extension' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 88,
  'Dumbbell lying extension allows neutral grip and unilateral work; barbell (skull crusher) is the classic version.'
FROM exercises s, exercises t
WHERE s.name = 'Lying Dumbbell Tricep Extension' AND s.created_by IS NULL
  AND t.name = 'Lying Triceps Press' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Tricep Dumbbell Kickback <-> Cable One Arm Tricep Extension (same_muscles)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 75,
  'Both are single-arm tricep isolation; kickback requires bent-over position, cable extension is standing. Cable provides constant tension.'
FROM exercises s, exercises t
WHERE s.name = 'Tricep Dumbbell Kickback' AND s.created_by IS NULL
  AND t.name = 'Cable One Arm Tricep Extension' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 75,
  'Cable provides constant tension throughout extension; kickback peaks at full extension only.'
FROM exercises s, exercises t
WHERE s.name = 'Cable One Arm Tricep Extension' AND s.created_by IS NULL
  AND t.name = 'Tricep Dumbbell Kickback' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Close-Grip Bench Press <-> Dips Triceps Version (same_muscles)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 72,
  'Both are compound tricep movements with chest involvement; close-grip bench is horizontal press, dips are vertical press.'
FROM exercises s, exercises t
WHERE s.name = 'Close-Grip Barbell Bench Press' AND s.created_by IS NULL
  AND t.name = 'Dips - Triceps Version' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 72,
  'Both are compound tricep exercises; dips are bodyweight, close-grip bench allows precise loading.'
FROM exercises s, exercises t
WHERE s.name = 'Dips - Triceps Version' AND s.created_by IS NULL
  AND t.name = 'Close-Grip Barbell Bench Press' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- =============================================================================
-- 20. CORE / ABDOMINALS
-- =============================================================================

-- Crunches <-> Cable Crunch (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 80,
  'Cable crunch allows progressive overload beyond bodyweight; same spinal flexion pattern targeting rectus abdominis.'
FROM exercises s, exercises t
WHERE s.name = 'Crunches' AND s.created_by IS NULL
  AND t.name = 'Cable Crunch' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 80,
  'Bodyweight crunch is simpler; cable crunch allows weighted progressive overload for ab strength.'
FROM exercises s, exercises t
WHERE s.name = 'Cable Crunch' AND s.created_by IS NULL
  AND t.name = 'Crunches' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Crunches -> Weighted Crunches (progression)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'progression', 92,
  'Add external load (plate on chest) when bodyweight crunches become too easy for strength development.'
FROM exercises s, exercises t
WHERE s.name = 'Crunches' AND s.created_by IS NULL
  AND t.name = 'Weighted Crunches' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'regression', 92,
  'Bodyweight crunches are the unloaded regression; start here before adding external weight.'
FROM exercises s, exercises t
WHERE s.name = 'Weighted Crunches' AND s.created_by IS NULL
  AND t.name = 'Crunches' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Plank <-> Ab Roller (same_muscles)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 60,
  'Both are anti-extension core exercises; ab roller is dynamic and more challenging, plank is isometric hold.'
FROM exercises s, exercises t
WHERE s.name = 'Plank' AND s.created_by IS NULL
  AND t.name = 'Ab Roller' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 60,
  'Plank is isometric anti-extension; ab roller is dynamic with eccentric/concentric phases. Both strengthen deep core.'
FROM exercises s, exercises t
WHERE s.name = 'Ab Roller' AND s.created_by IS NULL
  AND t.name = 'Plank' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Plank -> Ab Roller (progression)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'progression', 65,
  'Ab roller requires dynamic anti-extension strength; progress from plank holds when 60+ seconds is comfortable.'
FROM exercises s, exercises t
WHERE s.name = 'Plank' AND s.created_by IS NULL
  AND t.name = 'Ab Roller' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Reverse Crunch <-> Crunches (same_muscles)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 78,
  'Reverse crunch lifts pelvis toward ribcage; standard crunch lifts ribcage toward pelvis. Both target rectus abdominis, reverse crunch slightly more lower abs.'
FROM exercises s, exercises t
WHERE s.name = 'Reverse Crunch' AND s.created_by IS NULL
  AND t.name = 'Crunches' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 78,
  'Standard crunch flexes upper spine; reverse crunch flexes lower spine/pelvis. Both hit rectus abdominis.'
FROM exercises s, exercises t
WHERE s.name = 'Crunches' AND s.created_by IS NULL
  AND t.name = 'Reverse Crunch' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Ab Crunch Machine <-> Cable Crunch (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 82,
  'Both are loaded spinal flexion exercises; machine provides fixed path, cable allows more natural crunch movement.'
FROM exercises s, exercises t
WHERE s.name = 'Ab Crunch Machine' AND s.created_by IS NULL
  AND t.name = 'Cable Crunch' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 82,
  'Machine crunch provides guided resistance; cable crunch allows freer movement pattern. Both are weighted ab exercises.'
FROM exercises s, exercises t
WHERE s.name = 'Cable Crunch' AND s.created_by IS NULL
  AND t.name = 'Ab Crunch Machine' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- =============================================================================
-- 21. BACK EXTENSIONS / HYPEREXTENSIONS
-- =============================================================================

-- Hyperextensions <-> Romanian Deadlift (same_muscles)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 60,
  'Both target erector spinae and hamstrings via hip extension; hyperextension is bodyweight, RDL allows barbell loading.'
FROM exercises s, exercises t
WHERE s.name = 'Hyperextensions (Back Extensions)' AND s.created_by IS NULL
  AND t.name = 'Romanian Deadlift' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 60,
  'RDL is a standing hip hinge with barbell; back extension uses a GHD/roman chair. Both target posterior chain.'
FROM exercises s, exercises t
WHERE s.name = 'Romanian Deadlift' AND s.created_by IS NULL
  AND t.name = 'Hyperextensions (Back Extensions)' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- =============================================================================
-- 22. CROSS-PATTERN SUBSTITUTIONS (High-Value Compound Swaps)
-- =============================================================================

-- Barbell Bench Press <-> Leverage Chest Press (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 75,
  'Leverage chest press is machine-guided horizontal press; safer for solo training and beginners. Less stabilizer recruitment.'
FROM exercises s, exercises t
WHERE s.name = 'Barbell Bench Press - Medium Grip' AND s.created_by IS NULL
  AND t.name = 'Leverage Chest Press' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 75,
  'Free weight bench press has greater functional transfer; leverage press is safer for failure training.'
FROM exercises s, exercises t
WHERE s.name = 'Leverage Chest Press' AND s.created_by IS NULL
  AND t.name = 'Barbell Bench Press - Medium Grip' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Incline Press <-> Leverage Incline Chest Press (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 75,
  'Machine incline press provides guided path for upper chest; free weight version recruits more stabilizers.'
FROM exercises s, exercises t
WHERE s.name = 'Barbell Incline Bench Press - Medium Grip' AND s.created_by IS NULL
  AND t.name = 'Leverage Incline Chest Press' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 75,
  'Leverage incline press is safer for solo training; barbell incline recruits more stabilizers.'
FROM exercises s, exercises t
WHERE s.name = 'Leverage Incline Chest Press' AND s.created_by IS NULL
  AND t.name = 'Barbell Incline Bench Press - Medium Grip' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Straight-Arm Pulldown <-> Wide-Grip Lat Pulldown (same_muscles)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 55,
  'Straight-arm pulldown isolates lats without bicep; lat pulldown is compound with bicep involvement. Both target lats.'
FROM exercises s, exercises t
WHERE s.name = 'Straight-Arm Pulldown' AND s.created_by IS NULL
  AND t.name = 'Wide-Grip Lat Pulldown' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 55,
  'Lat pulldown is compound (lats + biceps); straight-arm pulldown isolates lats with arms extended.'
FROM exercises s, exercises t
WHERE s.name = 'Wide-Grip Lat Pulldown' AND s.created_by IS NULL
  AND t.name = 'Straight-Arm Pulldown' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Leverage High Row <-> Seated Cable Rows (same_muscles)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 78,
  'Both are seated rowing movements targeting mid-back; leverage machine provides fixed path, cable allows more natural movement.'
FROM exercises s, exercises t
WHERE s.name = 'Leverage High Row' AND s.created_by IS NULL
  AND t.name = 'Seated Cable Rows' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_muscles', 78,
  'Cable rows allow grip/handle variation; leverage row provides consistent machine path.'
FROM exercises s, exercises t
WHERE s.name = 'Seated Cable Rows' AND s.created_by IS NULL
  AND t.name = 'Leverage High Row' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Machine Bicep Curl <-> Barbell Curl (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 75,
  'Machine curl provides fixed path and consistent resistance; free weight curl recruits more stabilizers.'
FROM exercises s, exercises t
WHERE s.name = 'Machine Bicep Curl' AND s.created_by IS NULL
  AND t.name = 'Barbell Curl' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 75,
  'Free weight curl has more natural movement arc; machine provides guided path for strict isolation.'
FROM exercises s, exercises t
WHERE s.name = 'Barbell Curl' AND s.created_by IS NULL
  AND t.name = 'Machine Bicep Curl' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Machine Triceps Extension <-> Triceps Pushdown (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 78,
  'Machine provides fixed path for tricep extension; cable pushdown allows more natural wrist position and angle adjustment.'
FROM exercises s, exercises t
WHERE s.name = 'Machine Triceps Extension' AND s.created_by IS NULL
  AND t.name = 'Triceps Pushdown' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 78,
  'Cable pushdown offers attachment variety; machine extension provides consistent cam-based resistance.'
FROM exercises s, exercises t
WHERE s.name = 'Triceps Pushdown' AND s.created_by IS NULL
  AND t.name = 'Machine Triceps Extension' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Standing Dumbbell Calf Raise <-> Calf Raise On A Dumbbell (same_pattern)
INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 92,
  'Both are single-dumbbell calf raise variants; one uses a step for greater ROM, similar gastrocnemius loading.'
FROM exercises s, exercises t
WHERE s.name = 'Standing Dumbbell Calf Raise' AND s.created_by IS NULL
  AND t.name = 'Calf Raise On A Dumbbell' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_substitutions (source_exercise_id, target_exercise_id, substitution_type, similarity_score, notes)
SELECT s.id, t.id, 'same_pattern', 92,
  'Both are dumbbell-loaded calf raises; interchangeable for gastrocnemius development.'
FROM exercises s, exercises t
WHERE s.name = 'Calf Raise On A Dumbbell' AND s.created_by IS NULL
  AND t.name = 'Standing Dumbbell Calf Raise' AND t.created_by IS NULL
ON CONFLICT DO NOTHING;
