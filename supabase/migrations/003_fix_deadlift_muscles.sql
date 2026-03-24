-- Migration: Fix Barbell Deadlift primary muscle mapping
--
-- Issue #22: "Barbell Deadlift" incorrectly listed lower back (erector spinae, id=13)
-- as the sole primary mover. Anatomically, glutes (id=8) and hamstrings (id=11) are
-- the primary hip extensors driving the lift; erector spinae act isometrically to
-- maintain spinal position and are correctly classified as secondary.
--
-- Source: NSCA Essentials of Strength Training and Conditioning, 4th ed.

-- Step 1: Demote lower back (id=13) from primary to secondary
UPDATE exercise_muscles
SET    is_primary = false
WHERE  exercise_id = (
         SELECT id FROM exercises
         WHERE  name = 'Barbell Deadlift'
         AND    created_by IS NULL
       )
AND    muscle_group_id = 13;

-- Step 2: Promote glutes (id=8) to primary
UPDATE exercise_muscles
SET    is_primary = true
WHERE  exercise_id = (
         SELECT id FROM exercises
         WHERE  name = 'Barbell Deadlift'
         AND    created_by IS NULL
       )
AND    muscle_group_id = 8;

-- Step 3: Promote hamstrings (id=11) to primary
UPDATE exercise_muscles
SET    is_primary = true
WHERE  exercise_id = (
         SELECT id FROM exercises
         WHERE  name = 'Barbell Deadlift'
         AND    created_by IS NULL
       )
AND    muscle_group_id = 11;

-- Step 4: Insert glutes row if it does not already exist (idempotent guard)
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT id, 8, true
FROM   exercises
WHERE  name = 'Barbell Deadlift'
AND    created_by IS NULL
ON CONFLICT DO NOTHING;

-- Step 5: Insert hamstrings row if it does not already exist (idempotent guard)
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT id, 11, true
FROM   exercises
WHERE  name = 'Barbell Deadlift'
AND    created_by IS NULL
ON CONFLICT DO NOTHING;
