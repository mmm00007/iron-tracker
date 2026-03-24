INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Seated Hamstring and Calf Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Seated Hamstring and Calf Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 14, true FROM exercises e WHERE e.name = 'Seated Head Harness Neck Resistance' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Seated Leg Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Seated Leg Tucks' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, true FROM exercises e WHERE e.name = 'Seated One-Arm Dumbbell Palms-Down Wrist Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, true FROM exercises e WHERE e.name = 'Seated One-Arm Dumbbell Palms-Up Wrist Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Seated One-arm Cable Pulley Rows' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Seated One-arm Cable Pulley Rows' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Seated One-arm Cable Pulley Rows' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Seated One-arm Cable Pulley Rows' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Seated Overhead Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, true FROM exercises e WHERE e.name = 'Seated Palm-Up Barbell Wrist Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, true FROM exercises e WHERE e.name = 'Seated Palms-Down Barbell Wrist Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Seated Side Lateral Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Seated Triceps Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, true FROM exercises e WHERE e.name = 'Seated Two-Arm Palms-Up Low-Pulley Wrist Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'See-Saw Press (Alternating Side Press)' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, false FROM exercises e WHERE e.name = 'See-Saw Press (Alternating Side Press)' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'See-Saw Press (Alternating Side Press)' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Shotgun Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Shotgun Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Shotgun Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Shoulder Circles' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Shoulder Circles' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Shoulder Press - With Bands' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Shoulder Press - With Bands' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Shoulder Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Shoulder Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Shoulder Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Side-Lying Floor Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Side Bridge' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Side Bridge' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Side Hop-Sprint' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Side Hop-Sprint' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 16, false FROM exercises e WHERE e.name = 'Side Hop-Sprint' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Side Hop-Sprint' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Side Hop-Sprint' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Side Jackknife' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Side Lateral Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Side Laterals to Front Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Side Laterals to Front Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 16, true FROM exercises e WHERE e.name = 'Side Leg Raises' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 16, true FROM exercises e WHERE e.name = 'Side Lying Groin Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Side Lying Groin Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 14, true FROM exercises e WHERE e.name = 'Side Neck Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Side Standing Long Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Side Standing Long Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Side Standing Long Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Side Standing Long Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Side To Side Chins' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Side To Side Chins' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Side To Side Chins' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Side To Side Chins' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Side To Side Chins' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Side Wrist Pull' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Side Wrist Pull' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Side Wrist Pull' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Side to Side Box Shuffle' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Side to Side Box Shuffle' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 16, false FROM exercises e WHERE e.name = 'Side to Side Box Shuffle' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Side to Side Box Shuffle' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Side to Side Box Shuffle' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Single-Arm Cable Crossover' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Single-Arm Linear Jammer' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Single-Arm Linear Jammer' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Single-Arm Linear Jammer' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Single-Arm Push-Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Single-Arm Push-Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Single-Arm Push-Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Single-Cone Sprint Drill' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Single-Cone Sprint Drill' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Single-Cone Sprint Drill' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Single-Cone Sprint Drill' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Single-Leg High Box Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Single-Leg High Box Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Single-Leg High Box Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Single-Leg Hop Progression' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Single-Leg Hop Progression' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 16, false FROM exercises e WHERE e.name = 'Single-Leg Hop Progression' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Single-Leg Hop Progression' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Single-Leg Hop Progression' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Single-Leg Lateral Hop' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Single-Leg Lateral Hop' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 16, false FROM exercises e WHERE e.name = 'Single-Leg Lateral Hop' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Single-Leg Lateral Hop' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Single-Leg Lateral Hop' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Single-Leg Leg Extension' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Single-Leg Stride Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Single-Leg Stride Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 16, false FROM exercises e WHERE e.name = 'Single-Leg Stride Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Single-Leg Stride Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Single-Leg Stride Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Single Dumbbell Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Single Dumbbell Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Single Dumbbell Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Single Leg Butt Kick' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Single Leg Butt Kick' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Single Leg Butt Kick' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, true FROM exercises e WHERE e.name = 'Single Leg Glute Bridge' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;