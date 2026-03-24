INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Incline Bench Pull' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Incline Bench Pull' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Incline Bench Pull' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Incline Cable Chest Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Incline Cable Chest Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Incline Cable Chest Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Incline Cable Flye' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Incline Cable Flye' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Incline Dumbbell Bench With Palms Facing In' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Incline Dumbbell Bench With Palms Facing In' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Incline Dumbbell Bench With Palms Facing In' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, true FROM exercises e WHERE e.name = 'Incline Dumbbell Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Incline Dumbbell Flyes' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Incline Dumbbell Flyes' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Incline Dumbbell Flyes - With A Twist' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Incline Dumbbell Flyes - With A Twist' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Incline Dumbbell Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Incline Dumbbell Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Incline Dumbbell Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, true FROM exercises e WHERE e.name = 'Incline Hammer Curls' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, true FROM exercises e WHERE e.name = 'Incline Inner Biceps Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Incline Push-Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Incline Push-Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Incline Push-Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Incline Push-Up Close-Grip' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Incline Push-Up Close-Grip' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Incline Push-Up Close-Grip' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Incline Push-Up Depth Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Incline Push-Up Depth Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Incline Push-Up Depth Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Incline Push-Up Medium' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, false FROM exercises e WHERE e.name = 'Incline Push-Up Medium' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Incline Push-Up Medium' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Incline Push-Up Medium' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Incline Push-Up Reverse Grip' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, false FROM exercises e WHERE e.name = 'Incline Push-Up Reverse Grip' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Incline Push-Up Reverse Grip' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Incline Push-Up Reverse Grip' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Incline Push-Up Wide' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, false FROM exercises e WHERE e.name = 'Incline Push-Up Wide' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Incline Push-Up Wide' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Incline Push-Up Wide' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Intermediate Groin Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Intermediate Hip Flexor and Quad Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Internal Rotation with Band' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Inverted Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Inverted Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Inverted Row with Straps' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Inverted Row with Straps' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Inverted Row with Straps' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Iron Cross' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Iron Cross' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Iron Cross' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Iron Cross' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Iron Cross' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Iron Cross' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Iron Cross' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Iron Crosses (stretch)' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Isometric Chest Squeezes' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Isometric Chest Squeezes' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Isometric Chest Squeezes' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 14, true FROM exercises e WHERE e.name = 'Isometric Neck Exercise - Front And Back' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 14, true FROM exercises e WHERE e.name = 'Isometric Neck Exercise - Sides' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Isometric Wipers' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, false FROM exercises e WHERE e.name = 'Isometric Wipers' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Isometric Wipers' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Isometric Wipers' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'JM Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'JM Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'JM Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Jackknife Sit-Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Janda Sit-Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Jefferson Squats' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Jefferson Squats' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Jefferson Squats' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Jefferson Squats' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Jefferson Squats' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Jefferson Squats' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Jerk Balance' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Jerk Balance' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Jerk Balance' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Jerk Balance' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Jerk Balance' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Jerk Dip Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, false FROM exercises e WHERE e.name = 'Jerk Dip Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Jerk Dip Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Jogging, Treadmill' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Jogging, Treadmill' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Jogging, Treadmill' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, true FROM exercises e WHERE e.name = 'Keg Load' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, false FROM exercises e WHERE e.name = 'Keg Load' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Keg Load' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Keg Load' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Keg Load' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Keg Load' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Keg Load' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Keg Load' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Keg Load' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Keg Load' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Keg Load' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;