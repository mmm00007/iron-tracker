-- Exercise muscle relationships from yuhonas/free-exercise-db

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = '3/4 Sit-Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = '90/90 Hamstring' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = '90/90 Hamstring' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Ab Crunch Machine' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Ab Roller' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Ab Roller' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 16, true FROM exercises e WHERE e.name = 'Adductor' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 16, true FROM exercises e WHERE e.name = 'Adductor/Groin' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Advanced Kettlebell Windmill' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Advanced Kettlebell Windmill' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Advanced Kettlebell Windmill' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Advanced Kettlebell Windmill' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Air Bike' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'All Fours Quad Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'All Fours Quad Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, true FROM exercises e WHERE e.name = 'Alternate Hammer Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Alternate Hammer Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Alternate Heel Touchers' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, true FROM exercises e WHERE e.name = 'Alternate Incline Dumbbell Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Alternate Incline Dumbbell Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Alternate Leg Diagonal Bound' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Alternate Leg Diagonal Bound' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 16, false FROM exercises e WHERE e.name = 'Alternate Leg Diagonal Bound' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Alternate Leg Diagonal Bound' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Alternate Leg Diagonal Bound' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Alternate Leg Diagonal Bound' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Alternating Cable Shoulder Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Alternating Cable Shoulder Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Alternating Deltoid Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Alternating Floor Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, false FROM exercises e WHERE e.name = 'Alternating Floor Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Alternating Floor Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Alternating Floor Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Alternating Hang Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Alternating Hang Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Alternating Hang Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Alternating Hang Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Alternating Hang Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Alternating Hang Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Alternating Hang Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Alternating Kettlebell Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Alternating Kettlebell Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Alternating Kettlebell Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Alternating Kettlebell Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Alternating Kettlebell Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Alternating Renegade Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, false FROM exercises e WHERE e.name = 'Alternating Renegade Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Alternating Renegade Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Alternating Renegade Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Alternating Renegade Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Alternating Renegade Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, true FROM exercises e WHERE e.name = 'Ankle Circles' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, true FROM exercises e WHERE e.name = 'Ankle On The Knee' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, true FROM exercises e WHERE e.name = 'Anterior Tibialis-SMR' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Anti-Gravity Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Anti-Gravity Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Anti-Gravity Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Anti-Gravity Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Arm Circles' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Arm Circles' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Arnold Dumbbell Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Arnold Dumbbell Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Around The Worlds' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Around The Worlds' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, true FROM exercises e WHERE e.name = 'Atlas Stone Trainer' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Atlas Stone Trainer' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Atlas Stone Trainer' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Atlas Stone Trainer' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Atlas Stone Trainer' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Atlas Stone Trainer' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, true FROM exercises e WHERE e.name = 'Atlas Stones' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, false FROM exercises e WHERE e.name = 'Atlas Stones' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 16, false FROM exercises e WHERE e.name = 'Atlas Stones' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Atlas Stones' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Atlas Stones' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Atlas Stones' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Atlas Stones' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Atlas Stones' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Atlas Stones' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Atlas Stones' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Atlas Stones' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, true FROM exercises e WHERE e.name = 'Axle Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Axle Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Axle Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Axle Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Axle Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Axle Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Axle Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Back Flyes - With Bands' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Back Flyes - With Bands' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Back Flyes - With Bands' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Backward Drag' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Backward Drag' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Backward Drag' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Backward Drag' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Backward Drag' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Backward Drag' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Backward Medicine Ball Throw' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, true FROM exercises e WHERE e.name = 'Balance Board' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Balance Board' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Balance Board' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Ball Leg Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Ball Leg Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Ball Leg Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Band Assisted Pull-Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, false FROM exercises e WHERE e.name = 'Band Assisted Pull-Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Band Assisted Pull-Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Band Assisted Pull-Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Band Good Morning' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Band Good Morning' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Band Good Morning' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Band Good Morning (Pull Through)' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Band Good Morning (Pull Through)' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Band Good Morning (Pull Through)' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 16, true FROM exercises e WHERE e.name = 'Band Hip Adductions' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Band Pull Apart' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Band Pull Apart' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Band Pull Apart' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Band Skull Crusher' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Barbell Ab Rollout' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Barbell Ab Rollout' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Barbell Ab Rollout' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Barbell Ab Rollout - On Knees' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Barbell Ab Rollout - On Knees' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Barbell Ab Rollout - On Knees' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Barbell Bench Press - Medium Grip' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Barbell Bench Press - Medium Grip' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Barbell Bench Press - Medium Grip' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, true FROM exercises e WHERE e.name = 'Barbell Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Barbell Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, true FROM exercises e WHERE e.name = 'Barbell Curls Lying Against An Incline' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, true FROM exercises e WHERE e.name = 'Barbell Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Barbell Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Barbell Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Barbell Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Barbell Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Barbell Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Barbell Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Barbell Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Barbell Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Barbell Full Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Barbell Full Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Barbell Full Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Barbell Full Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Barbell Full Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, true FROM exercises e WHERE e.name = 'Barbell Glute Bridge' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Barbell Glute Bridge' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Barbell Glute Bridge' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Barbell Guillotine Bench Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Barbell Guillotine Bench Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Barbell Guillotine Bench Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Barbell Hack Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Barbell Hack Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Barbell Hack Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Barbell Hack Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, true FROM exercises e WHERE e.name = 'Barbell Hip Thrust' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Barbell Hip Thrust' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Barbell Hip Thrust' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Barbell Incline Bench Press - Medium Grip' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Barbell Incline Bench Press - Medium Grip' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Barbell Incline Bench Press - Medium Grip' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Barbell Incline Shoulder Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Barbell Incline Shoulder Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Barbell Lunge' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Barbell Lunge' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Barbell Lunge' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Barbell Lunge' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Barbell Rear Delt Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Barbell Rear Delt Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Barbell Rear Delt Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Barbell Rear Delt Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Barbell Rollout from Bench' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Barbell Rollout from Bench' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Barbell Rollout from Bench' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Barbell Rollout from Bench' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Barbell Rollout from Bench' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, true FROM exercises e WHERE e.name = 'Barbell Seated Calf Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Barbell Shoulder Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Barbell Shoulder Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Barbell Shoulder Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, true FROM exercises e WHERE e.name = 'Barbell Shrug' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, true FROM exercises e WHERE e.name = 'Barbell Shrug Behind The Back' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Barbell Shrug Behind The Back' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Barbell Shrug Behind The Back' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Barbell Side Bend' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Barbell Side Bend' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Barbell Side Split Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Barbell Side Split Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Barbell Side Split Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Barbell Side Split Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Barbell Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Barbell Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Barbell Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Barbell Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Barbell Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Barbell Squat To A Bench' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Barbell Squat To A Bench' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Barbell Squat To A Bench' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Barbell Squat To A Bench' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Barbell Squat To A Bench' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Barbell Step Ups' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Barbell Step Ups' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Barbell Step Ups' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Barbell Step Ups' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Barbell Step Ups' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Barbell Walking Lunge' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Barbell Walking Lunge' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Barbell Walking Lunge' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Barbell Walking Lunge' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Battling Ropes' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Battling Ropes' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Battling Ropes' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Bear Crawl Sled Drags' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Bear Crawl Sled Drags' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Bear Crawl Sled Drags' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Bear Crawl Sled Drags' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Behind Head Chest Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Behind Head Chest Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Bench Dips' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Bench Dips' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Bench Dips' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Bench Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Bench Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Bench Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Bench Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Bench Press - Powerlifting' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Bench Press - Powerlifting' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Bench Press - Powerlifting' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Bench Press - Powerlifting' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Bench Press - Powerlifting' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Bench Press - With Bands' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Bench Press - With Bands' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Bench Press - With Bands' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Bench Press with Chains' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Bench Press with Chains' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Bench Press with Chains' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Bench Press with Chains' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Bench Sprint' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Bench Sprint' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Bench Sprint' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Bench Sprint' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Bent-Arm Barbell Pullover' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Bent-Arm Barbell Pullover' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Bent-Arm Barbell Pullover' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Bent-Arm Barbell Pullover' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Bent-Arm Barbell Pullover' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Bent-Arm Dumbbell Pullover' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Bent-Arm Dumbbell Pullover' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Bent-Arm Dumbbell Pullover' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Bent-Arm Dumbbell Pullover' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Bent-Knee Hip Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Bent Over Barbell Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Bent Over Barbell Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Bent Over Barbell Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Bent Over Barbell Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Bent Over Dumbbell Rear Delt Raise With Head On Bench' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Bent Over Low-Pulley Side Lateral' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Bent Over Low-Pulley Side Lateral' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Bent Over Low-Pulley Side Lateral' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Bent Over Low-Pulley Side Lateral' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Bent Over One-Arm Long Bar Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Bent Over One-Arm Long Bar Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Bent Over One-Arm Long Bar Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Bent Over One-Arm Long Bar Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Bent Over One-Arm Long Bar Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Bent Over Two-Arm Long Bar Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Bent Over Two-Arm Long Bar Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Bent Over Two-Arm Long Bar Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Bent Over Two-Dumbbell Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Bent Over Two-Dumbbell Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Bent Over Two-Dumbbell Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Bent Over Two-Dumbbell Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Bent Over Two-Dumbbell Row With Palms In' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Bent Over Two-Dumbbell Row With Palms In' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Bent Over Two-Dumbbell Row With Palms In' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Bent Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Bent Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Bent Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Bent Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Bent Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Bent Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Bent Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Bicycling' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Bicycling' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Bicycling' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Bicycling' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Bicycling, Stationary' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Bicycling, Stationary' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Bicycling, Stationary' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Bicycling, Stationary' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Board Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Board Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Board Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Board Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Board Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Body-Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, false FROM exercises e WHERE e.name = 'Body-Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Body-Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Body Tricep Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Bodyweight Flyes' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, false FROM exercises e WHERE e.name = 'Bodyweight Flyes' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Bodyweight Flyes' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Bodyweight Flyes' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Bodyweight Mid Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Bodyweight Mid Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Bodyweight Mid Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Bodyweight Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Bodyweight Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Bodyweight Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Bodyweight Walking Lunge' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Bodyweight Walking Lunge' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Bodyweight Walking Lunge' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Bodyweight Walking Lunge' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Bosu Ball Cable Crunch With Side Bends' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, true FROM exercises e WHERE e.name = 'Bottoms-Up Clean From The Hang Position' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Bottoms-Up Clean From The Hang Position' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Bottoms-Up Clean From The Hang Position' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Bottoms Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Box Jump (Multiple Response)' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Box Jump (Multiple Response)' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 16, false FROM exercises e WHERE e.name = 'Box Jump (Multiple Response)' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Box Jump (Multiple Response)' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Box Jump (Multiple Response)' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Box Jump (Multiple Response)' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Box Skip' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Box Skip' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 16, false FROM exercises e WHERE e.name = 'Box Skip' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Box Skip' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Box Skip' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Box Skip' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Box Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 16, false FROM exercises e WHERE e.name = 'Box Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Box Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Box Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Box Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Box Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Box Squat with Bands' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Box Squat with Bands' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 16, false FROM exercises e WHERE e.name = 'Box Squat with Bands' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Box Squat with Bands' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Box Squat with Bands' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Box Squat with Bands' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Box Squat with Bands' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Box Squat with Chains' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Box Squat with Chains' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 16, false FROM exercises e WHERE e.name = 'Box Squat with Chains' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Box Squat with Chains' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Box Squat with Chains' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Box Squat with Chains' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Box Squat with Chains' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, true FROM exercises e WHERE e.name = 'Brachialis-SMR' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Bradford/Rocky Presses' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Bradford/Rocky Presses' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Butt-Ups' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, true FROM exercises e WHERE e.name = 'Butt Lift (Bridge)' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Butt Lift (Bridge)' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Butterfly' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Cable Chest Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Cable Chest Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Cable Chest Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Cable Crossover' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Cable Crossover' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Cable Crunch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Cable Deadlifts' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Cable Deadlifts' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Cable Deadlifts' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Cable Deadlifts' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Cable Deadlifts' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, true FROM exercises e WHERE e.name = 'Cable Hammer Curls - Rope Attachment' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Cable Hip Adduction' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Cable Incline Pushdown' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Cable Incline Triceps Extension' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Cable Internal Rotation' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Cable Iron Cross' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Cable Judo Flip' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Cable Lying Triceps Extension' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Cable One Arm Tricep Extension' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, true FROM exercises e WHERE e.name = 'Cable Preacher Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Cable Preacher Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Cable Rear Delt Fly' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Cable Reverse Crunch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Cable Rope Overhead Triceps Extension' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Cable Rope Rear-Delt Rows' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Cable Rope Rear-Delt Rows' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Cable Rope Rear-Delt Rows' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Cable Russian Twists' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Cable Seated Crunch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Cable Seated Lateral Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Cable Seated Lateral Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Cable Seated Lateral Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Cable Shoulder Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Cable Shoulder Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, true FROM exercises e WHERE e.name = 'Cable Shrugs' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, true FROM exercises e WHERE e.name = 'Cable Wrist Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, true FROM exercises e WHERE e.name = 'Calf-Machine Shoulder Shrug' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, true FROM exercises e WHERE e.name = 'Calf Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, true FROM exercises e WHERE e.name = 'Calf Press On The Leg Press Machine' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, true FROM exercises e WHERE e.name = 'Calf Raise On A Dumbbell' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, true FROM exercises e WHERE e.name = 'Calf Raises - With Bands' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, true FROM exercises e WHERE e.name = 'Calf Stretch Elbows Against Wall' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

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

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Clean and Jerk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Clean and Jerk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Clean and Jerk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Clean and Jerk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Clean and Jerk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Clean and Jerk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Clean and Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, false FROM exercises e WHERE e.name = 'Clean and Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Clean and Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Clean and Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Clean and Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Clean and Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Clean and Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Clean and Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Clean and Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Clean and Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Clean and Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Clean from Blocks' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Clean from Blocks' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Clean from Blocks' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Clean from Blocks' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Clean from Blocks' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Clean from Blocks' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Clock Push-Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Clock Push-Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Clock Push-Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Close-Grip Barbell Bench Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Close-Grip Barbell Bench Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Close-Grip Barbell Bench Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Close-Grip Dumbbell Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Close-Grip Dumbbell Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Close-Grip Dumbbell Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, true FROM exercises e WHERE e.name = 'Close-Grip EZ-Bar Curl with Band' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Close-Grip EZ-Bar Curl with Band' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Close-Grip EZ-Bar Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Close-Grip EZ-Bar Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Close-Grip EZ-Bar Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, true FROM exercises e WHERE e.name = 'Close-Grip EZ Bar Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Close-Grip EZ Bar Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Close-Grip Front Lat Pulldown' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Close-Grip Front Lat Pulldown' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Close-Grip Front Lat Pulldown' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Close-Grip Front Lat Pulldown' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Close-Grip Push-Up off of a Dumbbell' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, false FROM exercises e WHERE e.name = 'Close-Grip Push-Up off of a Dumbbell' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Close-Grip Push-Up off of a Dumbbell' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Close-Grip Push-Up off of a Dumbbell' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, true FROM exercises e WHERE e.name = 'Close-Grip Standing Barbell Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Close-Grip Standing Barbell Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Cocoons' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Conan''s Wheel' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, false FROM exercises e WHERE e.name = 'Conan''s Wheel' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Conan''s Wheel' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Conan''s Wheel' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Conan''s Wheel' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Conan''s Wheel' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Conan''s Wheel' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Conan''s Wheel' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, true FROM exercises e WHERE e.name = 'Concentration Curls' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Concentration Curls' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Cross-Body Crunch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, true FROM exercises e WHERE e.name = 'Cross Body Hammer Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Cross Body Hammer Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Cross Over - With Bands' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Cross Over - With Bands' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Cross Over - With Bands' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, true FROM exercises e WHERE e.name = 'Crossover Reverse Lunge' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, false FROM exercises e WHERE e.name = 'Crossover Reverse Lunge' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Crossover Reverse Lunge' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Crossover Reverse Lunge' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Crossover Reverse Lunge' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Crossover Reverse Lunge' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Crucifix' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Crucifix' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Crunch - Hands Overhead' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Crunch - Legs On Exercise Ball' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Crunches' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Cuban Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Cuban Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, true FROM exercises e WHERE e.name = 'Dancer''s Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Dancer''s Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Dancer''s Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Dead Bug' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, true FROM exercises e WHERE e.name = 'Deadlift with Bands' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Deadlift with Bands' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Deadlift with Bands' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Deadlift with Bands' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Deadlift with Bands' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Deadlift with Bands' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Deadlift with Bands' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, true FROM exercises e WHERE e.name = 'Deadlift with Chains' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Deadlift with Chains' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Deadlift with Chains' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Deadlift with Chains' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Deadlift with Chains' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Deadlift with Chains' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Deadlift with Chains' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Decline Barbell Bench Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Decline Barbell Bench Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Decline Barbell Bench Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

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

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Dumbbell Floor Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Dumbbell Flyes' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Dumbbell Incline Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Dumbbell Incline Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Dumbbell Incline Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Dumbbell Incline Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Dumbbell Incline Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Dumbbell Incline Shoulder Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Dumbbell Incline Shoulder Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Dumbbell Lunges' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Dumbbell Lunges' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Dumbbell Lunges' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Dumbbell Lunges' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Dumbbell Lying One-Arm Rear Lateral Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Dumbbell Lying One-Arm Rear Lateral Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, true FROM exercises e WHERE e.name = 'Dumbbell Lying Pronation' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Dumbbell Lying Rear Lateral Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, true FROM exercises e WHERE e.name = 'Dumbbell Lying Supination' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Dumbbell One-Arm Shoulder Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Dumbbell One-Arm Shoulder Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Dumbbell One-Arm Triceps Extension' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Dumbbell One-Arm Upright Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Dumbbell One-Arm Upright Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Dumbbell One-Arm Upright Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, true FROM exercises e WHERE e.name = 'Dumbbell Prone Incline Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Dumbbell Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Dumbbell Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Dumbbell Rear Lunge' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Dumbbell Rear Lunge' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Dumbbell Rear Lunge' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Dumbbell Rear Lunge' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Dumbbell Scaption' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Dumbbell Scaption' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Dumbbell Seated Box Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Dumbbell Seated Box Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Dumbbell Seated Box Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Dumbbell Seated Box Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, true FROM exercises e WHERE e.name = 'Dumbbell Seated One-Leg Calf Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Dumbbell Shoulder Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Dumbbell Shoulder Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, true FROM exercises e WHERE e.name = 'Dumbbell Shrug' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Dumbbell Side Bend' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Dumbbell Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Dumbbell Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Dumbbell Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Dumbbell Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Dumbbell Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Dumbbell Squat To A Bench' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Dumbbell Squat To A Bench' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Dumbbell Squat To A Bench' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Dumbbell Squat To A Bench' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Dumbbell Squat To A Bench' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Dumbbell Step Ups' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Dumbbell Step Ups' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Dumbbell Step Ups' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Dumbbell Step Ups' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Dumbbell Tricep Extension -Pronated Grip' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Dynamic Back Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Dynamic Chest Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Dynamic Chest Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, true FROM exercises e WHERE e.name = 'EZ-Bar Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'EZ-Bar Skullcrusher' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'EZ-Bar Skullcrusher' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Elbow Circles' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Elbow Circles' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Elbow to Knee' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Elbows Back' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Elbows Back' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Elevated Back Lunge' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Elevated Back Lunge' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Elevated Back Lunge' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Elevated Cable Rows' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Elevated Cable Rows' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Elevated Cable Rows' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Elliptical Trainer' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Elliptical Trainer' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Elliptical Trainer' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Elliptical Trainer' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Exercise Ball Crunch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Exercise Ball Pull-In' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Extended Range One-Arm Kettlebell Floor Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Extended Range One-Arm Kettlebell Floor Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Extended Range One-Arm Kettlebell Floor Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'External Rotation' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'External Rotation with Band' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'External Rotation with Cable' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Face Pull' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Face Pull' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, true FROM exercises e WHERE e.name = 'Farmer''s Walk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, false FROM exercises e WHERE e.name = 'Farmer''s Walk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Farmer''s Walk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Farmer''s Walk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Farmer''s Walk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Farmer''s Walk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Farmer''s Walk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Fast Skipping' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Fast Skipping' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 16, false FROM exercises e WHERE e.name = 'Fast Skipping' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Fast Skipping' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Fast Skipping' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Fast Skipping' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, true FROM exercises e WHERE e.name = 'Finger Curls' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Flat Bench Cable Flyes' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Flat Bench Leg Pull-In' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Flat Bench Lying Leg Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, true FROM exercises e WHERE e.name = 'Flexor Incline Dumbbell Curls' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Floor Glute-Ham Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Floor Glute-Ham Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Floor Glute-Ham Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Floor Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Floor Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Floor Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Floor Press with Chains' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Floor Press with Chains' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Floor Press with Chains' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, true FROM exercises e WHERE e.name = 'Flutter Kicks' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Flutter Kicks' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, true FROM exercises e WHERE e.name = 'Foot-SMR' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Forward Drag with Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Forward Drag with Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Forward Drag with Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Forward Drag with Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Forward Drag with Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Forward Drag with Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Forward Drag with Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Frankenstein Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, false FROM exercises e WHERE e.name = 'Frankenstein Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Frankenstein Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Frankenstein Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Frankenstein Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Freehand Jump Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Freehand Jump Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Freehand Jump Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Freehand Jump Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Frog Hops' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Frog Hops' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Frog Hops' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Frog Hops' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Frog Sit-Ups' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Front Barbell Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Front Barbell Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Front Barbell Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Front Barbell Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Front Barbell Squat To A Bench' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Front Barbell Squat To A Bench' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Front Barbell Squat To A Bench' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Front Barbell Squat To A Bench' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Front Box Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Front Box Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 16, false FROM exercises e WHERE e.name = 'Front Box Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Front Box Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Front Box Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Front Box Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Front Cable Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Front Cone Hops (or hurdle hops)' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Front Cone Hops (or hurdle hops)' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 16, false FROM exercises e WHERE e.name = 'Front Cone Hops (or hurdle hops)' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Front Cone Hops (or hurdle hops)' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Front Cone Hops (or hurdle hops)' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Front Cone Hops (or hurdle hops)' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Front Dumbbell Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Front Incline Dumbbell Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Front Leg Raises' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Front Plate Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Front Raise And Pullover' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Front Raise And Pullover' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Front Raise And Pullover' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Front Raise And Pullover' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Front Squat (Clean Grip)' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, false FROM exercises e WHERE e.name = 'Front Squat (Clean Grip)' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Front Squat (Clean Grip)' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Front Squat (Clean Grip)' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Front Squats With Two Kettlebells' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Front Squats With Two Kettlebells' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Front Squats With Two Kettlebells' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Front Two-Dumbbell Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Full Range-Of-Motion Lat Pulldown' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Full Range-Of-Motion Lat Pulldown' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Full Range-Of-Motion Lat Pulldown' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Full Range-Of-Motion Lat Pulldown' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Gironda Sternum Chins' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Gironda Sternum Chins' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Gironda Sternum Chins' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Glute Ham Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Glute Ham Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Glute Ham Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, true FROM exercises e WHERE e.name = 'Glute Kickback' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Glute Kickback' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Goblet Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Goblet Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Goblet Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Goblet Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Goblet Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Good Morning' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, false FROM exercises e WHERE e.name = 'Good Morning' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Good Morning' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Good Morning' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Good Morning off Pins' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, false FROM exercises e WHERE e.name = 'Good Morning off Pins' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Good Morning off Pins' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Good Morning off Pins' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Gorilla Chin/Crunch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Gorilla Chin/Crunch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Gorilla Chin/Crunch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 16, true FROM exercises e WHERE e.name = 'Groin and Back Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 16, true FROM exercises e WHERE e.name = 'Groiners' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Hack Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Hack Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Hack Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Hack Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, true FROM exercises e WHERE e.name = 'Hammer Curls' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Hammer Grip Incline DB Bench Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Hammer Grip Incline DB Bench Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Hammer Grip Incline DB Bench Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Hamstring-SMR' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Hamstring Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Handstand Push-Ups' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Handstand Push-Ups' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Hang Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Hang Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Hang Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Hang Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Hang Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Hang Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Hang Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Hang Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Hang Clean - Below the Knees' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Hang Clean - Below the Knees' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Hang Clean - Below the Knees' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Hang Clean - Below the Knees' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Hang Clean - Below the Knees' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Hang Clean - Below the Knees' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Hang Clean - Below the Knees' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Hang Clean - Below the Knees' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Hang Snatch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, false FROM exercises e WHERE e.name = 'Hang Snatch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Hang Snatch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Hang Snatch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Hang Snatch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Hang Snatch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Hang Snatch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Hang Snatch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Hang Snatch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Hang Snatch - Below Knees' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, false FROM exercises e WHERE e.name = 'Hang Snatch - Below Knees' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Hang Snatch - Below Knees' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Hang Snatch - Below Knees' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Hang Snatch - Below Knees' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Hang Snatch - Below Knees' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Hang Snatch - Below Knees' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Hang Snatch - Below Knees' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Hang Snatch - Below Knees' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Hanging Bar Good Morning' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, false FROM exercises e WHERE e.name = 'Hanging Bar Good Morning' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Hanging Bar Good Morning' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Hanging Bar Good Morning' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Hanging Leg Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Hanging Pike' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Heaving Snatch Balance' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, false FROM exercises e WHERE e.name = 'Heaving Snatch Balance' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Heaving Snatch Balance' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Heaving Snatch Balance' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Heaving Snatch Balance' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Heaving Snatch Balance' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Heaving Snatch Balance' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Heavy Bag Thrust' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, false FROM exercises e WHERE e.name = 'Heavy Bag Thrust' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Heavy Bag Thrust' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Heavy Bag Thrust' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, true FROM exercises e WHERE e.name = 'High Cable Curls' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, true FROM exercises e WHERE e.name = 'Hip Circles (prone)' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 16, false FROM exercises e WHERE e.name = 'Hip Circles (prone)' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, true FROM exercises e WHERE e.name = 'Hip Extension with Bands' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Hip Extension with Bands' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Hip Flexion with Band' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, true FROM exercises e WHERE e.name = 'Hip Lift with Band' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Hip Lift with Band' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Hip Lift with Band' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, true FROM exercises e WHERE e.name = 'Hug A Ball' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Hug A Ball' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Hug A Ball' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, true FROM exercises e WHERE e.name = 'Hug Knees To Chest' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Hug Knees To Chest' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Hurdle Hops' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Hurdle Hops' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 16, false FROM exercises e WHERE e.name = 'Hurdle Hops' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Hurdle Hops' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Hurdle Hops' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Hurdle Hops' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, true FROM exercises e WHERE e.name = 'Hyperextensions (Back Extensions)' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Hyperextensions (Back Extensions)' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Hyperextensions (Back Extensions)' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, true FROM exercises e WHERE e.name = 'Hyperextensions With No Hyperextension Bench' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Hyperextensions With No Hyperextension Bench' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Hyperextensions With No Hyperextension Bench' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, true FROM exercises e WHERE e.name = 'IT Band and Glute Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, true FROM exercises e WHERE e.name = 'Iliotibial Tract-SMR' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Inchworm' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Incline Barbell Triceps Extension' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Incline Barbell Triceps Extension' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

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

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Kettlebell Arnold Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Kettlebell Arnold Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Kettlebell Dead Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Kettlebell Dead Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Kettlebell Dead Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Kettlebell Dead Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Kettlebell Dead Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Kettlebell Dead Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Kettlebell Figure 8' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Kettlebell Figure 8' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Kettlebell Figure 8' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Kettlebell Hang Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Kettlebell Hang Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Kettlebell Hang Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Kettlebell Hang Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Kettlebell Hang Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Kettlebell Hang Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Kettlebell One-Legged Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Kettlebell One-Legged Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Kettlebell One-Legged Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Kettlebell Pass Between The Legs' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Kettlebell Pass Between The Legs' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Kettlebell Pass Between The Legs' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Kettlebell Pass Between The Legs' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Kettlebell Pirate Ships' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, false FROM exercises e WHERE e.name = 'Kettlebell Pirate Ships' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Kettlebell Pistol Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Kettlebell Pistol Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Kettlebell Pistol Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Kettlebell Pistol Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Kettlebell Pistol Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Kettlebell Seated Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Kettlebell Seated Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Kettlebell Seesaw Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Kettlebell Seesaw Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, true FROM exercises e WHERE e.name = 'Kettlebell Sumo High Pull' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 16, false FROM exercises e WHERE e.name = 'Kettlebell Sumo High Pull' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Kettlebell Sumo High Pull' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Kettlebell Sumo High Pull' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Kettlebell Sumo High Pull' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Kettlebell Sumo High Pull' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Kettlebell Thruster' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Kettlebell Thruster' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Kettlebell Thruster' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Kettlebell Turkish Get-Up (Lunge style)' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, false FROM exercises e WHERE e.name = 'Kettlebell Turkish Get-Up (Lunge style)' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Kettlebell Turkish Get-Up (Lunge style)' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Kettlebell Turkish Get-Up (Lunge style)' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Kettlebell Turkish Get-Up (Lunge style)' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Kettlebell Turkish Get-Up (Squat style)' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, false FROM exercises e WHERE e.name = 'Kettlebell Turkish Get-Up (Squat style)' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Kettlebell Turkish Get-Up (Squat style)' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Kettlebell Turkish Get-Up (Squat style)' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Kettlebell Turkish Get-Up (Squat style)' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Kettlebell Turkish Get-Up (Squat style)' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Kettlebell Windmill' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Kettlebell Windmill' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Kettlebell Windmill' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Kettlebell Windmill' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Kettlebell Windmill' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Kipping Muscle Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, false FROM exercises e WHERE e.name = 'Kipping Muscle Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Kipping Muscle Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Kipping Muscle Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Kipping Muscle Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Kipping Muscle Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Kipping Muscle Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Kipping Muscle Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, true FROM exercises e WHERE e.name = 'Knee Across The Body' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Knee Across The Body' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Knee Across The Body' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, true FROM exercises e WHERE e.name = 'Knee Circles' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Knee Circles' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Knee Circles' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Knee/Hip Raise On Parallel Bars' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Knee Tuck Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Knee Tuck Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 16, false FROM exercises e WHERE e.name = 'Knee Tuck Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Knee Tuck Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Knee Tuck Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Knee Tuck Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Kneeling Arm Drill' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, false FROM exercises e WHERE e.name = 'Kneeling Arm Drill' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Kneeling Cable Crunch With Alternating Oblique Twists' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Kneeling Cable Triceps Extension' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, true FROM exercises e WHERE e.name = 'Kneeling Forearm Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Kneeling High Pulley Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Kneeling High Pulley Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Kneeling High Pulley Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Kneeling Hip Flexor' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Kneeling Hip Flexor' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, true FROM exercises e WHERE e.name = 'Kneeling Jump Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Kneeling Jump Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Kneeling Jump Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Kneeling Jump Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Kneeling Single-Arm High Pulley Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Kneeling Single-Arm High Pulley Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Kneeling Single-Arm High Pulley Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, true FROM exercises e WHERE e.name = 'Kneeling Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, false FROM exercises e WHERE e.name = 'Kneeling Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Kneeling Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Kneeling Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Landmine 180''s' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Landmine 180''s' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Landmine 180''s' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Landmine 180''s' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Landmine Linear Jammer' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, false FROM exercises e WHERE e.name = 'Landmine Linear Jammer' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Landmine Linear Jammer' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Landmine Linear Jammer' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Landmine Linear Jammer' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Landmine Linear Jammer' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Landmine Linear Jammer' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 16, true FROM exercises e WHERE e.name = 'Lateral Bound' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Lateral Bound' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Lateral Bound' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Lateral Bound' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Lateral Bound' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Lateral Bound' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 16, true FROM exercises e WHERE e.name = 'Lateral Box Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Lateral Box Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Lateral Box Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Lateral Box Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Lateral Box Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Lateral Box Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 16, true FROM exercises e WHERE e.name = 'Lateral Cone Hops' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Lateral Cone Hops' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Lateral Cone Hops' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Lateral Cone Hops' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Lateral Cone Hops' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Lateral Cone Hops' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Lateral Raise - With Bands' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Latissimus Dorsi-SMR' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Leg-Over Floor Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Leg-Over Floor Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Leg-Over Floor Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Leg-Up Hamstring Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Leg Extensions' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, true FROM exercises e WHERE e.name = 'Leg Lift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Leg Lift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Leg Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Leg Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Leg Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Leg Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Leg Pull-In' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Leverage Chest Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Leverage Chest Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Leverage Chest Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Leverage Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Leverage Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Leverage Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Leverage Decline Chest Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Leverage Decline Chest Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Leverage Decline Chest Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Leverage High Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Leverage High Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Leverage Incline Chest Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Leverage Incline Chest Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Leverage Incline Chest Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Leverage Iso Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Leverage Iso Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Leverage Iso Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Leverage Shoulder Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Leverage Shoulder Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, true FROM exercises e WHERE e.name = 'Leverage Shrug' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Leverage Shrug' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Linear 3-Part Start Technique' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Linear 3-Part Start Technique' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Linear 3-Part Start Technique' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Linear Acceleration Wall Drill' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Linear Acceleration Wall Drill' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Linear Acceleration Wall Drill' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Linear Acceleration Wall Drill' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Linear Depth Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Linear Depth Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Linear Depth Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Linear Depth Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Log Lift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, false FROM exercises e WHERE e.name = 'Log Lift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Log Lift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Log Lift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Log Lift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Log Lift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Log Lift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Log Lift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Log Lift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Log Lift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'London Bridges' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'London Bridges' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'London Bridges' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'London Bridges' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Looking At Ceiling' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Low Cable Crossover' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Low Cable Crossover' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Low Cable Triceps Extension' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Low Pulley Row To Neck' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Low Pulley Row To Neck' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Low Pulley Row To Neck' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Low Pulley Row To Neck' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, true FROM exercises e WHERE e.name = 'Lower Back-SMR' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Lower Back Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Lunge Pass Through' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Lunge Pass Through' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Lunge Pass Through' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Lunge Pass Through' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Lunge Sprint' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Lunge Sprint' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Lunge Sprint' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Lunge Sprint' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 16, true FROM exercises e WHERE e.name = 'Lying Bent Leg Groin' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, true FROM exercises e WHERE e.name = 'Lying Cable Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Lying Cambered Barbell Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Lying Cambered Barbell Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Lying Cambered Barbell Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Lying Cambered Barbell Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, true FROM exercises e WHERE e.name = 'Lying Close-Grip Bar Curl On High Pulley' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Lying Close-Grip Barbell Triceps Extension Behind The Head' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Lying Close-Grip Barbell Triceps Press To Chin' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, true FROM exercises e WHERE e.name = 'Lying Crossover' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Lying Dumbbell Tricep Extension' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Lying Dumbbell Tricep Extension' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Lying Dumbbell Tricep Extension' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 14, true FROM exercises e WHERE e.name = 'Lying Face Down Plate Neck Resistance' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 14, true FROM exercises e WHERE e.name = 'Lying Face Up Plate Neck Resistance' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, true FROM exercises e WHERE e.name = 'Lying Glute' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Lying Glute' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Lying Hamstring' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Lying Hamstring' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, true FROM exercises e WHERE e.name = 'Lying High Bench Barbell Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Lying Leg Curls' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Lying Machine Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Lying Machine Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Lying Machine Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Lying Machine Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Lying One-Arm Lateral Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Lying Prone Quadriceps' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Lying Rear Delt Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, true FROM exercises e WHERE e.name = 'Lying Supine Dumbbell Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Lying T-Bar Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Lying T-Bar Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Lying T-Bar Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Lying Triceps Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Machine Bench Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Machine Bench Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Machine Bench Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, true FROM exercises e WHERE e.name = 'Machine Bicep Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, true FROM exercises e WHERE e.name = 'Machine Preacher Curls' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Machine Shoulder (Military) Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Machine Shoulder (Military) Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Machine Triceps Extension' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Medicine Ball Chest Pass' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Medicine Ball Chest Pass' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Medicine Ball Chest Pass' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Medicine Ball Full Twist' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Medicine Ball Full Twist' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Medicine Ball Scoop Throw' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, false FROM exercises e WHERE e.name = 'Medicine Ball Scoop Throw' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Medicine Ball Scoop Throw' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Medicine Ball Scoop Throw' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Middle Back Shrug' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Middle Back Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, false FROM exercises e WHERE e.name = 'Middle Back Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Middle Back Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Middle Back Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Mixed Grip Chin' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Mixed Grip Chin' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Mixed Grip Chin' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, true FROM exercises e WHERE e.name = 'Monster Walk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Mountain Climbers' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Mountain Climbers' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Mountain Climbers' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Mountain Climbers' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Moving Claw Series' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Moving Claw Series' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Moving Claw Series' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Muscle Snatch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Muscle Snatch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Muscle Snatch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Muscle Snatch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Muscle Snatch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Muscle Snatch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Muscle Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, false FROM exercises e WHERE e.name = 'Muscle Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Muscle Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Muscle Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Muscle Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Muscle Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Muscle Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Muscle Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Narrow Stance Hack Squats' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Narrow Stance Hack Squats' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Narrow Stance Hack Squats' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Narrow Stance Hack Squats' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Narrow Stance Leg Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Narrow Stance Leg Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Narrow Stance Leg Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Narrow Stance Leg Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Narrow Stance Squats' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Narrow Stance Squats' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Narrow Stance Squats' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Narrow Stance Squats' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Narrow Stance Squats' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Natural Glute Ham Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Natural Glute Ham Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Natural Glute Ham Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Natural Glute Ham Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 14, true FROM exercises e WHERE e.name = 'Neck-SMR' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Neck Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Neck Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Neck Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Oblique Crunches' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Oblique Crunches - On The Floor' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Olympic Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Olympic Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Olympic Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Olympic Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'On-Your-Back Quad Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'On Your Side Quad Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'One-Arm Dumbbell Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'One-Arm Dumbbell Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'One-Arm Dumbbell Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'One-Arm Dumbbell Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'One-Arm Flat Bench Dumbbell Flye' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'One-Arm High-Pulley Cable Side Bends' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'One-Arm Incline Lateral Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'One-Arm Kettlebell Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'One-Arm Kettlebell Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'One-Arm Kettlebell Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'One-Arm Kettlebell Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'One-Arm Kettlebell Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'One-Arm Kettlebell Clean and Jerk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'One-Arm Kettlebell Floor Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'One-Arm Kettlebell Floor Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'One-Arm Kettlebell Jerk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'One-Arm Kettlebell Jerk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'One-Arm Kettlebell Jerk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'One-Arm Kettlebell Jerk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'One-Arm Kettlebell Military Press To The Side' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'One-Arm Kettlebell Military Press To The Side' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'One-Arm Kettlebell Para Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'One-Arm Kettlebell Para Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'One-Arm Kettlebell Push Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'One-Arm Kettlebell Push Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'One-Arm Kettlebell Push Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'One-Arm Kettlebell Push Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'One-Arm Kettlebell Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'One-Arm Kettlebell Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'One-Arm Kettlebell Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'One-Arm Kettlebell Snatch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'One-Arm Kettlebell Snatch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'One-Arm Kettlebell Snatch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'One-Arm Kettlebell Snatch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'One-Arm Kettlebell Snatch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'One-Arm Kettlebell Snatch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'One-Arm Kettlebell Snatch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'One-Arm Kettlebell Split Jerk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'One-Arm Kettlebell Split Jerk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'One-Arm Kettlebell Split Jerk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'One-Arm Kettlebell Split Jerk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'One-Arm Kettlebell Split Jerk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'One-Arm Kettlebell Split Snatch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'One-Arm Kettlebell Split Snatch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'One-Arm Kettlebell Split Snatch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'One-Arm Kettlebell Swings' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'One-Arm Kettlebell Swings' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'One-Arm Kettlebell Swings' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'One-Arm Kettlebell Swings' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'One-Arm Kettlebell Swings' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'One-Arm Long Bar Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'One-Arm Long Bar Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'One-Arm Long Bar Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'One-Arm Medicine Ball Slam' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'One-Arm Medicine Ball Slam' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'One-Arm Medicine Ball Slam' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'One-Arm Open Palm Kettlebell Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'One-Arm Open Palm Kettlebell Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'One-Arm Open Palm Kettlebell Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'One-Arm Open Palm Kettlebell Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'One-Arm Open Palm Kettlebell Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'One-Arm Open Palm Kettlebell Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'One-Arm Overhead Kettlebell Squats' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'One-Arm Overhead Kettlebell Squats' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'One-Arm Overhead Kettlebell Squats' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'One-Arm Overhead Kettlebell Squats' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'One-Arm Overhead Kettlebell Squats' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'One-Arm Side Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, false FROM exercises e WHERE e.name = 'One-Arm Side Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'One-Arm Side Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'One-Arm Side Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'One-Arm Side Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'One-Arm Side Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'One-Arm Side Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'One-Arm Side Laterals' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, true FROM exercises e WHERE e.name = 'One-Legged Cable Kickback' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'One-Legged Cable Kickback' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'One Arm Against Wall' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'One Arm Chin-Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'One Arm Chin-Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'One Arm Chin-Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'One Arm Chin-Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'One Arm Dumbbell Bench Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'One Arm Dumbbell Bench Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'One Arm Dumbbell Bench Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, true FROM exercises e WHERE e.name = 'One Arm Dumbbell Preacher Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'One Arm Floor Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'One Arm Floor Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'One Arm Floor Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'One Arm Lat Pulldown' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'One Arm Lat Pulldown' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'One Arm Lat Pulldown' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'One Arm Pronated Dumbbell Triceps Extension' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'One Arm Supinated Dumbbell Triceps Extension' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'One Half Locust' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, false FROM exercises e WHERE e.name = 'One Half Locust' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'One Half Locust' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'One Half Locust' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'One Handed Hang' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'One Handed Hang' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, true FROM exercises e WHERE e.name = 'One Knee To Chest' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'One Knee To Chest' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'One Knee To Chest' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'One Leg Barbell Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'One Leg Barbell Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'One Leg Barbell Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'One Leg Barbell Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Open Palm Kettlebell Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Open Palm Kettlebell Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Open Palm Kettlebell Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Open Palm Kettlebell Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Open Palm Kettlebell Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Otis-Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Otis-Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Otis-Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Otis-Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, true FROM exercises e WHERE e.name = 'Overhead Cable Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Overhead Lat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Overhead Lat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Overhead Slam' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Overhead Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, false FROM exercises e WHERE e.name = 'Overhead Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Overhead Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Overhead Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Overhead Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Overhead Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Overhead Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Overhead Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Overhead Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Overhead Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Overhead Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Overhead Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Overhead Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Overhead Triceps' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Overhead Triceps' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Pallof Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Pallof Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Pallof Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Pallof Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Pallof Press With Rotation' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Pallof Press With Rotation' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Pallof Press With Rotation' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Pallof Press With Rotation' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, true FROM exercises e WHERE e.name = 'Palms-Down Dumbbell Wrist Curl Over A Bench' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, true FROM exercises e WHERE e.name = 'Palms-Down Wrist Curl Over A Bench' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, true FROM exercises e WHERE e.name = 'Palms-Up Barbell Wrist Curl Over A Bench' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, true FROM exercises e WHERE e.name = 'Palms-Up Dumbbell Wrist Curl Over A Bench' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Parallel Bar Dip' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Parallel Bar Dip' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Parallel Bar Dip' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, true FROM exercises e WHERE e.name = 'Pelvic Tilt Into Bridge' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, true FROM exercises e WHERE e.name = 'Peroneals-SMR' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, true FROM exercises e WHERE e.name = 'Peroneals Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, true FROM exercises e WHERE e.name = 'Physioball Hip Bridge' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Physioball Hip Bridge' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Pin Presses' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Pin Presses' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Pin Presses' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Pin Presses' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Pin Presses' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Pin Presses' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, true FROM exercises e WHERE e.name = 'Piriformis-SMR' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Plank' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, true FROM exercises e WHERE e.name = 'Plate Pinch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Plate Twist' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Platform Hamstring Slides' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Platform Hamstring Slides' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Plie Dumbbell Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, false FROM exercises e WHERE e.name = 'Plie Dumbbell Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Plie Dumbbell Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Plie Dumbbell Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Plie Dumbbell Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Plyo Kettlebell Pushups' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Plyo Kettlebell Pushups' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Plyo Kettlebell Pushups' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Plyo Push-up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Plyo Push-up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Plyo Push-up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, true FROM exercises e WHERE e.name = 'Posterior Tibialis Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Power Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Power Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Power Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

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

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Rack Delivery' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Rack Delivery' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, true FROM exercises e WHERE e.name = 'Rack Pull with Bands' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Rack Pull with Bands' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Rack Pull with Bands' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Rack Pull with Bands' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Rack Pull with Bands' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Rack Pull with Bands' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, true FROM exercises e WHERE e.name = 'Rack Pulls' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Rack Pulls' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Rack Pulls' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Rack Pulls' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Rack Pulls' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Rear Leg Raises' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Recumbent Bike' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Recumbent Bike' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Recumbent Bike' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Recumbent Bike' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Return Push from Stance' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Return Push from Stance' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Return Push from Stance' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Reverse Band Bench Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Reverse Band Bench Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Reverse Band Bench Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Reverse Band Bench Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Reverse Band Bench Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Reverse Band Bench Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Reverse Band Box Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Reverse Band Box Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 16, false FROM exercises e WHERE e.name = 'Reverse Band Box Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Reverse Band Box Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Reverse Band Box Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Reverse Band Box Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Reverse Band Box Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Reverse Band Box Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, true FROM exercises e WHERE e.name = 'Reverse Band Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Reverse Band Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 16, false FROM exercises e WHERE e.name = 'Reverse Band Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Reverse Band Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Reverse Band Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Reverse Band Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Reverse Band Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Reverse Band Power Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 16, false FROM exercises e WHERE e.name = 'Reverse Band Power Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Reverse Band Power Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Reverse Band Power Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Reverse Band Power Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Reverse Band Power Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Reverse Band Sumo Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Reverse Band Sumo Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 16, false FROM exercises e WHERE e.name = 'Reverse Band Sumo Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Reverse Band Sumo Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Reverse Band Sumo Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Reverse Band Sumo Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Reverse Band Sumo Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Reverse Band Sumo Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Reverse Band Sumo Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, true FROM exercises e WHERE e.name = 'Reverse Barbell Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Reverse Barbell Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, true FROM exercises e WHERE e.name = 'Reverse Barbell Preacher Curls' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Reverse Barbell Preacher Curls' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, true FROM exercises e WHERE e.name = 'Reverse Cable Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Reverse Cable Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Reverse Crunch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Reverse Flyes' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Reverse Flyes With External Rotation' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Reverse Grip Bent-Over Rows' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Reverse Grip Bent-Over Rows' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Reverse Grip Bent-Over Rows' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Reverse Grip Bent-Over Rows' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Reverse Grip Triceps Pushdown' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Reverse Hyperextension' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Reverse Hyperextension' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Reverse Hyperextension' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Reverse Machine Flyes' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, true FROM exercises e WHERE e.name = 'Reverse Plate Curls' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Reverse Plate Curls' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Reverse Triceps Bench Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Reverse Triceps Bench Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Reverse Triceps Bench Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Rhomboids-SMR' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Rhomboids-SMR' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, true FROM exercises e WHERE e.name = 'Rickshaw Carry' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, false FROM exercises e WHERE e.name = 'Rickshaw Carry' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Rickshaw Carry' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Rickshaw Carry' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Rickshaw Carry' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Rickshaw Carry' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Rickshaw Carry' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Rickshaw Carry' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Rickshaw Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Rickshaw Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Rickshaw Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Rickshaw Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Rickshaw Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Rickshaw Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Ring Dips' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Ring Dips' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Ring Dips' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Rocket Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Rocket Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Rocket Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, true FROM exercises e WHERE e.name = 'Rocking Standing Calf Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Rocky Pull-Ups/Pulldowns' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Rocky Pull-Ups/Pulldowns' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Rocky Pull-Ups/Pulldowns' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Rocky Pull-Ups/Pulldowns' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Romanian Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Romanian Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Romanian Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Romanian Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Romanian Deadlift from Deficit' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Romanian Deadlift from Deficit' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Romanian Deadlift from Deficit' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Romanian Deadlift from Deficit' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Romanian Deadlift from Deficit' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Rope Climb' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Rope Climb' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Rope Climb' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Rope Climb' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Rope Climb' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Rope Crunch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Rope Jumping' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Rope Jumping' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Rope Jumping' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Rope Straight-Arm Pulldown' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Round The World Shoulder Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Round The World Shoulder Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Round The World Shoulder Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Rowing, Stationary' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Rowing, Stationary' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Rowing, Stationary' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Rowing, Stationary' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Rowing, Stationary' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Rowing, Stationary' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Rowing, Stationary' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Runner''s Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Runner''s Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Running, Treadmill' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Running, Treadmill' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Running, Treadmill' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Running, Treadmill' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Russian Twist' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Russian Twist' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Sandbag Load' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, false FROM exercises e WHERE e.name = 'Sandbag Load' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Sandbag Load' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Sandbag Load' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Sandbag Load' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Sandbag Load' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Sandbag Load' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Sandbag Load' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Sandbag Load' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Sandbag Load' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Sandbag Load' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, true FROM exercises e WHERE e.name = 'Scapular Pull-Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Scapular Pull-Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Scapular Pull-Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Scissor Kick' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Scissors Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Scissors Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Scissors Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Seated Band Hamstring Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Seated Barbell Military Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Seated Barbell Military Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Seated Barbell Twist' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Seated Bent-Over One-Arm Dumbbell Triceps Extension' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Seated Bent-Over Rear Delt Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Seated Bent-Over Two-Arm Dumbbell Triceps Extension' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, true FROM exercises e WHERE e.name = 'Seated Biceps' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Seated Biceps' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Seated Biceps' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Seated Cable Rows' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Seated Cable Rows' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Seated Cable Rows' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Seated Cable Rows' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Seated Cable Shoulder Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Seated Cable Shoulder Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, true FROM exercises e WHERE e.name = 'Seated Calf Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, true FROM exercises e WHERE e.name = 'Seated Calf Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Seated Calf Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Seated Calf Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, true FROM exercises e WHERE e.name = 'Seated Close-Grip Concentration Barbell Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, true FROM exercises e WHERE e.name = 'Seated Dumbbell Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, true FROM exercises e WHERE e.name = 'Seated Dumbbell Inner Biceps Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, true FROM exercises e WHERE e.name = 'Seated Dumbbell Palms-Down Wrist Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, true FROM exercises e WHERE e.name = 'Seated Dumbbell Palms-Up Wrist Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Seated Dumbbell Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Seated Dumbbell Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Seated Flat Bench Leg Pull-In' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Seated Floor Hamstring Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Seated Floor Hamstring Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Seated Front Deltoid' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Seated Front Deltoid' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, true FROM exercises e WHERE e.name = 'Seated Glute' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 16, false FROM exercises e WHERE e.name = 'Seated Glute' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, true FROM exercises e WHERE e.name = 'Seated Good Mornings' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Seated Good Mornings' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Seated Hamstring' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Seated Hamstring' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

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

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Single Leg Glute Bridge' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Single Leg Push-off' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Single Leg Push-off' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Single Leg Push-off' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Sit-Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Sit Squats' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Sit Squats' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Sit Squats' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Sit Squats' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Skating' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Skating' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 16, false FROM exercises e WHERE e.name = 'Skating' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Skating' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Skating' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Skating' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Sled Drag - Harness' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Sled Drag - Harness' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Sled Drag - Harness' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Sled Drag - Harness' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Sled Overhead Backward Walk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Sled Overhead Backward Walk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Sled Overhead Backward Walk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Sled Overhead Backward Walk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Sled Overhead Triceps Extension' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Sled Push' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Sled Push' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Sled Push' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Sled Push' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Sled Push' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Sled Push' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Sled Reverse Flye' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Sled Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Sled Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Sled Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Sledgehammer Swings' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Sledgehammer Swings' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Sledgehammer Swings' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Sledgehammer Swings' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Sledgehammer Swings' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Sledgehammer Swings' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Smith Incline Shoulder Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Smith Incline Shoulder Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, true FROM exercises e WHERE e.name = 'Smith Machine Behind the Back Shrug' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Smith Machine Behind the Back Shrug' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Smith Machine Bench Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Smith Machine Bench Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Smith Machine Bench Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Smith Machine Bent Over Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Smith Machine Bent Over Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Smith Machine Bent Over Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Smith Machine Bent Over Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, true FROM exercises e WHERE e.name = 'Smith Machine Calf Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Smith Machine Close-Grip Bench Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Smith Machine Close-Grip Bench Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Smith Machine Close-Grip Bench Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Smith Machine Decline Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Smith Machine Decline Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Smith Machine Decline Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Smith Machine Hang Power Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Smith Machine Hang Power Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Smith Machine Hang Power Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Smith Machine Hang Power Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Smith Machine Hang Power Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Smith Machine Hang Power Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Smith Machine Hip Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Smith Machine Incline Bench Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Smith Machine Incline Bench Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Smith Machine Incline Bench Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Smith Machine Leg Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Smith Machine Leg Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Smith Machine Leg Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Smith Machine Leg Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Smith Machine One-Arm Upright Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Smith Machine One-Arm Upright Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Smith Machine One-Arm Upright Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Smith Machine Overhead Shoulder Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Smith Machine Overhead Shoulder Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Smith Machine Pistol Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Smith Machine Pistol Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Smith Machine Pistol Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Smith Machine Pistol Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, true FROM exercises e WHERE e.name = 'Smith Machine Reverse Calf Raises' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Smith Machine Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Smith Machine Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Smith Machine Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Smith Machine Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Smith Machine Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Smith Machine Stiff-Legged Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Smith Machine Stiff-Legged Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Smith Machine Stiff-Legged Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, true FROM exercises e WHERE e.name = 'Smith Machine Upright Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Smith Machine Upright Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Smith Machine Upright Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Smith Machine Upright Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Smith Single-Leg Split Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Smith Single-Leg Split Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Smith Single-Leg Split Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Smith Single-Leg Split Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Snatch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Snatch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Snatch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Snatch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Snatch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Snatch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Snatch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Snatch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Snatch Balance' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Snatch Balance' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Snatch Balance' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Snatch Balance' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Snatch Balance' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Snatch Balance' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Snatch Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Snatch Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Snatch Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Snatch Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Snatch Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Snatch Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Snatch Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Snatch Pull' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Snatch Pull' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Snatch Pull' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Snatch Pull' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Snatch Pull' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Snatch Pull' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, true FROM exercises e WHERE e.name = 'Snatch Shrug' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Snatch Shrug' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Snatch Shrug' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Snatch from Blocks' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Snatch from Blocks' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Snatch from Blocks' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Snatch from Blocks' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Snatch from Blocks' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Snatch from Blocks' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Snatch from Blocks' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Snatch from Blocks' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Snatch from Blocks' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Speed Band Overhead Triceps' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Speed Box Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Speed Box Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Speed Box Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Speed Box Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Speed Squats' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Speed Squats' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Speed Squats' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Speed Squats' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Speed Squats' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Spell Caster' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Spell Caster' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Spell Caster' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Spider Crawl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Spider Crawl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Spider Crawl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Spider Crawl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, true FROM exercises e WHERE e.name = 'Spider Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Spinal Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Spinal Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Spinal Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 14, false FROM exercises e WHERE e.name = 'Spinal Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Spinal Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Split Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Split Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Split Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Split Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Split Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Split Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Split Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Split Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Split Jerk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Split Jerk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Split Jerk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Split Jerk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Split Jerk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Split Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Split Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Split Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Split Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Split Snatch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Split Snatch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Split Snatch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Split Snatch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Split Snatch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Split Snatch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Split Snatch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Split Snatch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Split Snatch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Split Snatch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Split Squat with Dumbbells' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Split Squat with Dumbbells' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Split Squat with Dumbbells' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Split Squats' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Split Squats' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Split Squats' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Split Squats' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Squat Jerk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Squat Jerk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Squat Jerk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Squat Jerk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Squat Jerk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Squat Jerk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Squat with Bands' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 16, false FROM exercises e WHERE e.name = 'Squat with Bands' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Squat with Bands' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Squat with Bands' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Squat with Bands' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Squat with Bands' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Squat with Chains' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 16, false FROM exercises e WHERE e.name = 'Squat with Chains' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Squat with Chains' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Squat with Chains' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Squat with Chains' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Squat with Chains' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Squat with Plate Movers' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Squat with Plate Movers' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 16, false FROM exercises e WHERE e.name = 'Squat with Plate Movers' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Squat with Plate Movers' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Squat with Plate Movers' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Squat with Plate Movers' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Squats - With Bands' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Squats - With Bands' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Squats - With Bands' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Squats - With Bands' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Squats - With Bands' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Stairmaster' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Stairmaster' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Stairmaster' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Stairmaster' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Standing Alternating Dumbbell Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Standing Alternating Dumbbell Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, true FROM exercises e WHERE e.name = 'Standing Barbell Calf Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Standing Barbell Press Behind Neck' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Standing Barbell Press Behind Neck' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Standing Bent-Over One-Arm Dumbbell Triceps Extension' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Standing Bent-Over One-Arm Dumbbell Triceps Extension' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Standing Bent-Over Two-Arm Dumbbell Triceps Extension' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, true FROM exercises e WHERE e.name = 'Standing Biceps Cable Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, true FROM exercises e WHERE e.name = 'Standing Biceps Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Standing Biceps Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Standing Biceps Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Standing Bradford Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Standing Bradford Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Standing Cable Chest Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Standing Cable Chest Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Standing Cable Chest Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Standing Cable Lift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Standing Cable Lift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Standing Cable Wood Chop' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Standing Cable Wood Chop' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, true FROM exercises e WHERE e.name = 'Standing Calf Raises' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, true FROM exercises e WHERE e.name = 'Standing Concentration Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Standing Concentration Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, true FROM exercises e WHERE e.name = 'Standing Dumbbell Calf Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Standing Dumbbell Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Standing Dumbbell Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, true FROM exercises e WHERE e.name = 'Standing Dumbbell Reverse Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Standing Dumbbell Reverse Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Standing Dumbbell Straight-Arm Front Delt Raise Above Head' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Standing Dumbbell Triceps Extension' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, true FROM exercises e WHERE e.name = 'Standing Dumbbell Upright Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Standing Dumbbell Upright Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Standing Dumbbell Upright Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Standing Elevated Quad Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Standing Front Barbell Raise Over Head' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, true FROM exercises e WHERE e.name = 'Standing Gastrocnemius Calf Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Standing Gastrocnemius Calf Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Standing Hamstring and Calf Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, true FROM exercises e WHERE e.name = 'Standing Hip Circles' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 16, false FROM exercises e WHERE e.name = 'Standing Hip Circles' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Standing Hip Flexors' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, true FROM exercises e WHERE e.name = 'Standing Inner-Biceps Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Standing Lateral Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Standing Leg Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Standing Long Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Standing Long Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Standing Long Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Standing Long Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Standing Low-Pulley Deltoid Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Standing Low-Pulley Deltoid Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Standing Low-Pulley One-Arm Triceps Extension' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Standing Low-Pulley One-Arm Triceps Extension' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Standing Low-Pulley One-Arm Triceps Extension' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Standing Military Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Standing Military Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, true FROM exercises e WHERE e.name = 'Standing Olympic Plate Hand Squeeze' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Standing Olympic Plate Hand Squeeze' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, true FROM exercises e WHERE e.name = 'Standing One-Arm Cable Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, true FROM exercises e WHERE e.name = 'Standing One-Arm Dumbbell Curl Over Incline Bench' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Standing One-Arm Dumbbell Triceps Extension' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Standing One-Arm Dumbbell Triceps Extension' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Standing One-Arm Dumbbell Triceps Extension' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Standing Overhead Barbell Triceps Extension' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Standing Overhead Barbell Triceps Extension' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Standing Palm-In One-Arm Dumbbell Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Standing Palm-In One-Arm Dumbbell Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Standing Palms-In Dumbbell Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Standing Palms-In Dumbbell Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, true FROM exercises e WHERE e.name = 'Standing Palms-Up Barbell Behind The Back Wrist Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, true FROM exercises e WHERE e.name = 'Standing Pelvic Tilt' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Standing Pelvic Tilt' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Standing Rope Crunch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, true FROM exercises e WHERE e.name = 'Standing Soleus And Achilles Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Standing Toe Touches' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Standing Toe Touches' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Standing Towel Triceps Extension' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Standing Two-Arm Overhead Throw' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Standing Two-Arm Overhead Throw' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Standing Two-Arm Overhead Throw' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Star Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Star Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Star Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Star Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Star Jump' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, true FROM exercises e WHERE e.name = 'Step-up with Knee Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Step-up with Knee Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Step-up with Knee Raise' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Step Mill' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Step Mill' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Step Mill' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Step Mill' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Stiff-Legged Barbell Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Stiff-Legged Barbell Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Stiff-Legged Barbell Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Stiff-Legged Dumbbell Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Stiff-Legged Dumbbell Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Stiff-Legged Dumbbell Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, true FROM exercises e WHERE e.name = 'Stiff Leg Barbell Good Morning' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Stiff Leg Barbell Good Morning' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Stiff Leg Barbell Good Morning' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Stomach Vacuum' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Straight-Arm Dumbbell Pullover' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Straight-Arm Dumbbell Pullover' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Straight-Arm Dumbbell Pullover' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Straight-Arm Dumbbell Pullover' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Straight-Arm Pulldown' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Straight Bar Bench Mid Rows' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Straight Bar Bench Mid Rows' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Straight Bar Bench Mid Rows' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Straight Raises on Incline Bench' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Straight Raises on Incline Bench' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Stride Jump Crossover' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Stride Jump Crossover' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 16, false FROM exercises e WHERE e.name = 'Stride Jump Crossover' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Stride Jump Crossover' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Stride Jump Crossover' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Sumo Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 16, false FROM exercises e WHERE e.name = 'Sumo Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Sumo Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Sumo Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Sumo Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Sumo Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Sumo Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Sumo Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Sumo Deadlift with Bands' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 16, false FROM exercises e WHERE e.name = 'Sumo Deadlift with Bands' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Sumo Deadlift with Bands' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Sumo Deadlift with Bands' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Sumo Deadlift with Bands' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Sumo Deadlift with Bands' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Sumo Deadlift with Bands' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Sumo Deadlift with Bands' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Sumo Deadlift with Chains' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Sumo Deadlift with Chains' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 16, false FROM exercises e WHERE e.name = 'Sumo Deadlift with Chains' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Sumo Deadlift with Chains' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Sumo Deadlift with Chains' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Sumo Deadlift with Chains' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Sumo Deadlift with Chains' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Sumo Deadlift with Chains' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Sumo Deadlift with Chains' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, true FROM exercises e WHERE e.name = 'Superman' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Superman' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Superman' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Supine Chest Throw' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Supine Chest Throw' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Supine Chest Throw' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Supine One-Arm Overhead Throw' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Supine One-Arm Overhead Throw' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Supine One-Arm Overhead Throw' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Supine One-Arm Overhead Throw' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Supine Two-Arm Overhead Throw' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Supine Two-Arm Overhead Throw' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Supine Two-Arm Overhead Throw' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Supine Two-Arm Overhead Throw' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Suspended Fallout' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Suspended Fallout' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Suspended Fallout' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Suspended Fallout' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Suspended Push-Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Suspended Push-Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Suspended Push-Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Suspended Reverse Crunch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Suspended Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Suspended Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Suspended Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Suspended Split Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Suspended Split Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 16, false FROM exercises e WHERE e.name = 'Suspended Split Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Suspended Split Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Suspended Split Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Suspended Split Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Svend Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Svend Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Svend Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Svend Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'T-Bar Row with Handle' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'T-Bar Row with Handle' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'T-Bar Row with Handle' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Tate Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Tate Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Tate Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'The Straddle' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 16, false FROM exercises e WHERE e.name = 'The Straddle' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'The Straddle' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, true FROM exercises e WHERE e.name = 'Thigh Abductor' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Thigh Abductor' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 16, true FROM exercises e WHERE e.name = 'Thigh Adductor' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Thigh Adductor' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Thigh Adductor' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Tire Flip' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Tire Flip' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Tire Flip' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Tire Flip' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Tire Flip' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Tire Flip' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Tire Flip' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Tire Flip' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Tire Flip' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Tire Flip' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Toe Touchers' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Torso Rotation' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Trail Running/Walking' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Trail Running/Walking' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Trail Running/Walking' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Trail Running/Walking' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Trap Bar Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Trap Bar Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Trap Bar Deadlift' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Tricep Dumbbell Kickback' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Tricep Side Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Tricep Side Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Triceps Overhead Extension with Rope' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Triceps Pushdown' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Triceps Pushdown - Rope Attachment' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Triceps Pushdown - V-Bar Attachment' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Triceps Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Triceps Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Tuck Crunch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, true FROM exercises e WHERE e.name = 'Two-Arm Dumbbell Preacher Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Two-Arm Kettlebell Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Two-Arm Kettlebell Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Two-Arm Kettlebell Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Two-Arm Kettlebell Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Two-Arm Kettlebell Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Two-Arm Kettlebell Clean' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Two-Arm Kettlebell Jerk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Two-Arm Kettlebell Jerk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Two-Arm Kettlebell Jerk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Two-Arm Kettlebell Jerk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Two-Arm Kettlebell Military Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Two-Arm Kettlebell Military Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Two-Arm Kettlebell Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Two-Arm Kettlebell Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Two-Arm Kettlebell Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Underhand Cable Pulldowns' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Underhand Cable Pulldowns' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Underhand Cable Pulldowns' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Underhand Cable Pulldowns' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Upper Back-Leg Grab' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Upper Back-Leg Grab' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Upper Back-Leg Grab' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Upper Back Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Upper Back Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Upright Barbell Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, false FROM exercises e WHERE e.name = 'Upright Barbell Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, true FROM exercises e WHERE e.name = 'Upright Cable Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Upright Cable Row' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 9, true FROM exercises e WHERE e.name = 'Upright Row - With Bands' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Upright Row - With Bands' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, true FROM exercises e WHERE e.name = 'Upward Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Upward Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Upward Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'V-Bar Pulldown' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'V-Bar Pulldown' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'V-Bar Pulldown' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'V-Bar Pulldown' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'V-Bar Pullup' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'V-Bar Pullup' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'V-Bar Pullup' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'V-Bar Pullup' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Vertical Swing' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Vertical Swing' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'Vertical Swing' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Vertical Swing' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Walking, Treadmill' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Walking, Treadmill' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Walking, Treadmill' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Walking, Treadmill' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, true FROM exercises e WHERE e.name = 'Weighted Ball Hyperextension' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Weighted Ball Hyperextension' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Weighted Ball Hyperextension' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Weighted Ball Hyperextension' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Weighted Ball Side Bend' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, true FROM exercises e WHERE e.name = 'Weighted Bench Dip' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, false FROM exercises e WHERE e.name = 'Weighted Bench Dip' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Weighted Bench Dip' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Weighted Crunches' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Weighted Jump Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Weighted Jump Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Weighted Jump Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Weighted Jump Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Weighted Jump Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Weighted Pull Ups' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Weighted Pull Ups' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Weighted Pull Ups' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Weighted Sissy Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Weighted Sissy Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Weighted Sissy Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Weighted Sissy Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Weighted Sit-Ups - With Bands' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Weighted Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Weighted Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Weighted Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Weighted Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Wide-Grip Barbell Bench Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Wide-Grip Barbell Bench Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Wide-Grip Barbell Bench Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Wide-Grip Decline Barbell Bench Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Wide-Grip Decline Barbell Bench Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Wide-Grip Decline Barbell Bench Press' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 4, true FROM exercises e WHERE e.name = 'Wide-Grip Decline Barbell Pullover' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Wide-Grip Decline Barbell Pullover' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 3, false FROM exercises e WHERE e.name = 'Wide-Grip Decline Barbell Pullover' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Wide-Grip Lat Pulldown' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Wide-Grip Lat Pulldown' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Wide-Grip Lat Pulldown' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Wide-Grip Lat Pulldown' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Wide-Grip Pulldown Behind The Neck' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Wide-Grip Pulldown Behind The Neck' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Wide-Grip Pulldown Behind The Neck' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Wide-Grip Pulldown Behind The Neck' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, true FROM exercises e WHERE e.name = 'Wide-Grip Rear Pull-Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, false FROM exercises e WHERE e.name = 'Wide-Grip Rear Pull-Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 12, false FROM exercises e WHERE e.name = 'Wide-Grip Rear Pull-Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Wide-Grip Rear Pull-Up' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, true FROM exercises e WHERE e.name = 'Wide-Grip Standing Barbell Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Wide Stance Barbell Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Wide Stance Barbell Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Wide Stance Barbell Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Wide Stance Barbell Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Wide Stance Barbell Squat' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'Wide Stance Stiff Legs' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 16, false FROM exercises e WHERE e.name = 'Wide Stance Stiff Legs' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Wide Stance Stiff Legs' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Wide Stance Stiff Legs' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, true FROM exercises e WHERE e.name = 'Wind Sprints' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, true FROM exercises e WHERE e.name = 'Windmills' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Windmills' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Windmills' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Windmills' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, true FROM exercises e WHERE e.name = 'World''s Greatest Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'World''s Greatest Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'World''s Greatest Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, false FROM exercises e WHERE e.name = 'World''s Greatest Stretch' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, true FROM exercises e WHERE e.name = 'Wrist Circles' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, true FROM exercises e WHERE e.name = 'Wrist Roller' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 2, false FROM exercises e WHERE e.name = 'Wrist Roller' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, true FROM exercises e WHERE e.name = 'Wrist Rotations with Straight Bar' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Yoke Walk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 10, false FROM exercises e WHERE e.name = 'Yoke Walk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Yoke Walk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 16, false FROM exercises e WHERE e.name = 'Yoke Walk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Yoke Walk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Yoke Walk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Yoke Walk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 13, false FROM exercises e WHERE e.name = 'Yoke Walk' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 15, true FROM exercises e WHERE e.name = 'Zercher Squats' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 7, false FROM exercises e WHERE e.name = 'Zercher Squats' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 8, false FROM exercises e WHERE e.name = 'Zercher Squats' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 11, false FROM exercises e WHERE e.name = 'Zercher Squats' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, true FROM exercises e WHERE e.name = 'Zottman Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Zottman Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 1, true FROM exercises e WHERE e.name = 'Zottman Preacher Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)
SELECT e.id, 5, false FROM exercises e WHERE e.name = 'Zottman Preacher Curl' AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
