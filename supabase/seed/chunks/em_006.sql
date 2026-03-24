INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Decline Close-Grip Bench To Skull Crusher' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Decline Close-Grip Bench To Skull Crusher' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Decline Close-Grip Bench To Skull Crusher' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Decline Crunch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Decline Dumbbell Bench Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Decline Dumbbell Bench Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Decline Dumbbell Bench Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Decline Dumbbell Flyes' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Decline Dumbbell Triceps Extension' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Decline EZ Bar Triceps Extension' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Decline Oblique Crunch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Decline Push-Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Decline Push-Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Decline Push-Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Decline Reverse Crunch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Decline Smith Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Decline Smith Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Decline Smith Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, true FROM exercises e WHERE e.name = 'Deficit Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Deficit Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Deficit Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Deficit Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Deficit Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Deficit Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Deficit Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Depth Jump Leap' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Depth Jump Leap' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 16, false FROM exercises e WHERE e.name = 'Depth Jump Leap' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Depth Jump Leap' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Depth Jump Leap' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Depth Jump Leap' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Dip Machine' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Dip Machine' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Dip Machine' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Dips - Chest Version' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Dips - Chest Version' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Dips - Chest Version' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Dips - Triceps Version' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Dips - Triceps Version' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Dips - Triceps Version' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, true FROM exercises e WHERE e.name = 'Donkey Calf Raises' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Double Kettlebell Alternating Hang Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Double Kettlebell Alternating Hang Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Double Kettlebell Alternating Hang Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Double Kettlebell Alternating Hang Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Double Kettlebell Alternating Hang Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Double Kettlebell Alternating Hang Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Double Kettlebell Alternating Hang Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Double Kettlebell Alternating Hang Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Double Kettlebell Jerk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Double Kettlebell Jerk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Double Kettlebell Jerk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Double Kettlebell Jerk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Double Kettlebell Push Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Double Kettlebell Push Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Double Kettlebell Push Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Double Kettlebell Push Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Double Kettlebell Snatch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Double Kettlebell Snatch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Double Kettlebell Snatch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Double Kettlebell Snatch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Double Kettlebell Windmill' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Double Kettlebell Windmill' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Double Kettlebell Windmill' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Double Kettlebell Windmill' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Double Kettlebell Windmill' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Double Leg Butt Kick' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Double Leg Butt Kick' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 16, false FROM exercises e WHERE e.name = 'Double Leg Butt Kick' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Double Leg Butt Kick' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Double Leg Butt Kick' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Double Leg Butt Kick' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, true FROM exercises e WHERE e.name = 'Downward Facing Balance' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, false FROM exercises e WHERE e.name = 'Downward Facing Balance' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Downward Facing Balance' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, true FROM exercises e WHERE e.name = 'Drag Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Drag Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Drop Push' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Drop Push' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Drop Push' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, true FROM exercises e WHERE e.name = 'Dumbbell Alternate Bicep Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Dumbbell Alternate Bicep Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Dumbbell Bench Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Dumbbell Bench Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Dumbbell Bench Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Dumbbell Bench Press with Neutral Grip' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Dumbbell Bench Press with Neutral Grip' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Dumbbell Bench Press with Neutral Grip' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, true FROM exercises e WHERE e.name = 'Dumbbell Bicep Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Dumbbell Bicep Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Dumbbell Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Dumbbell Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Dumbbell Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Dumbbell Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Dumbbell Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Dumbbell Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Dumbbell Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Dumbbell Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Dumbbell Floor Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Dumbbell Floor Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;