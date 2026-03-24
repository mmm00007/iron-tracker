INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Power Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Power Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Power Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Power Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Power Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Power Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Power Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Power Clean from Blocks' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Power Clean from Blocks' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Power Jerk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, false FROM exercises e WHERE e.name = 'Power Jerk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Power Jerk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Power Jerk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Power Jerk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Power Jerk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Power Jerk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Power Partials' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Power Snatch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Power Snatch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Power Snatch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Power Snatch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Power Snatch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Power Snatch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Power Snatch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Power Snatch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Power Snatch from Blocks' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Power Snatch from Blocks' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Power Snatch from Blocks' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Power Snatch from Blocks' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Power Snatch from Blocks' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Power Snatch from Blocks' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Power Snatch from Blocks' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Power Snatch from Blocks' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Power Snatch from Blocks' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Power Stairs' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 16, false FROM exercises e WHERE e.name = 'Power Stairs' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Power Stairs' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Power Stairs' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Power Stairs' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Power Stairs' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Power Stairs' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Power Stairs' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, true FROM exercises e WHERE e.name = 'Preacher Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, true FROM exercises e WHERE e.name = 'Preacher Hammer Dumbbell Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Preacher Hammer Dumbbell Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Press Sit-Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Press Sit-Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Press Sit-Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Press Sit-Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Prone Manual Hamstring' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Prowler Sprint' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Prowler Sprint' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Prowler Sprint' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Prowler Sprint' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Prowler Sprint' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Prowler Sprint' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, true FROM exercises e WHERE e.name = 'Pull Through' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Pull Through' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Pull Through' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Pullups' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Pullups' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Pullups' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Push-Up Wide' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, false FROM exercises e WHERE e.name = 'Push-Up Wide' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Push-Up Wide' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Push-Up Wide' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Push-Ups - Close Triceps Position' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Push-Ups - Close Triceps Position' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Push-Ups - Close Triceps Position' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Push-Ups With Feet Elevated' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Push-Ups With Feet Elevated' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Push-Ups With Feet Elevated' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Push-Ups With Feet On An Exercise Ball' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Push-Ups With Feet On An Exercise Ball' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Push-Ups With Feet On An Exercise Ball' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Push Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Push Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Push Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Push Press - Behind the Neck' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Push Press - Behind the Neck' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Push Press - Behind the Neck' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Push Press - Behind the Neck' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Push Up to Side Plank' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, false FROM exercises e WHERE e.name = 'Push Up to Side Plank' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Push Up to Side Plank' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Push Up to Side Plank' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Pushups' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Pushups' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Pushups' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Pushups (Close and Wide Hand Positions)' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Pushups (Close and Wide Hand Positions)' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Pushups (Close and Wide Hand Positions)' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, true FROM exercises e WHERE e.name = 'Pyramid' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Pyramid' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Quad Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Quadriceps-SMR' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Quick Leap' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Quick Leap' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Quick Leap' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Rack Delivery' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;