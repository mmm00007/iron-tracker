INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, true FROM exercises e WHERE e.name = 'Calf Stretch Hands Against Wall' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, true FROM exercises e WHERE e.name = 'Calves-SMR' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Car Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Car Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Car Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Car Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Car Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Car Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Car Drivers' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Car Drivers' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 16, true FROM exercises e WHERE e.name = 'Carioca Quick Step' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, false FROM exercises e WHERE e.name = 'Carioca Quick Step' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Carioca Quick Step' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Carioca Quick Step' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Carioca Quick Step' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Carioca Quick Step' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Carioca Quick Step' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, true FROM exercises e WHERE e.name = 'Cat Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Cat Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Cat Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Catch and Overhead Throw' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, false FROM exercises e WHERE e.name = 'Catch and Overhead Throw' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Catch and Overhead Throw' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Catch and Overhead Throw' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Chain Handle Extension' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Chain Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Chain Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Chain Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Chair Leg Extended Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 16, false FROM exercises e WHERE e.name = 'Chair Leg Extended Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Chair Lower Back Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Chair Lower Back Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Chair Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Chair Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Chair Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Chair Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Chair Upper Body Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Chair Upper Body Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Chair Upper Body Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Chest And Front Of Shoulder Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Chest And Front Of Shoulder Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Chest Push from 3 point stance' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, false FROM exercises e WHERE e.name = 'Chest Push from 3 point stance' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Chest Push from 3 point stance' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Chest Push from 3 point stance' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Chest Push (multiple response)' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, false FROM exercises e WHERE e.name = 'Chest Push (multiple response)' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Chest Push (multiple response)' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Chest Push (multiple response)' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Chest Push (single response)' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, false FROM exercises e WHERE e.name = 'Chest Push (single response)' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Chest Push (single response)' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Chest Push (single response)' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Chest Push with Run Release' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, false FROM exercises e WHERE e.name = 'Chest Push with Run Release' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Chest Push with Run Release' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Chest Push with Run Release' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Chest Stretch on Stability Ball' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, true FROM exercises e WHERE e.name = 'Child''s Pose' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Child''s Pose' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Child''s Pose' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Chin-Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Chin-Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Chin-Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Chin-Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 14, true FROM exercises e WHERE e.name = 'Chin To Chest Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Chin To Chest Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Circus Bell' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Circus Bell' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Circus Bell' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Circus Bell' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Circus Bell' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Circus Bell' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Circus Bell' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Clean Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Clean Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Clean Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Clean Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Clean Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Clean Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Clean Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Clean Pull' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Clean Pull' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Clean Pull' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Clean Pull' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Clean Pull' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Clean Pull' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, true FROM exercises e WHERE e.name = 'Clean Shrug' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Clean Shrug' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Clean Shrug' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Clean and Jerk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, false FROM exercises e WHERE e.name = 'Clean and Jerk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;