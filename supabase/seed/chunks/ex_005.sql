INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'One-Arm Open Palm Kettlebell Clean',
  'pull',
  'intermediate',
  'compound',
  'kettlebell',
  'strength',
  ARRAY['Place one kettlebell between your feet.', 'Grab the handle with one hand and raise the kettlebell rapidly, let it flip so that the ball of the kettlebell lands in the palm of your hand.', 'Throw the kettlebell out in front of you and catch the handle with one hand.', 'Take the kettlebell to the floor and repeat. Make sure to work both arms.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/One-Arm_Open_Palm_Kettlebell_Clean/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/One-Arm_Open_Palm_Kettlebell_Clean/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'One-Arm Overhead Kettlebell Squats',
  'push',
  'expert',
  'compound',
  'kettlebell',
  'strength',
  ARRAY['Clean and press a kettlebell with one arm. Clean the kettlebell to your shoulder by extending through the legs and hips as you pull the kettlebell towards your shoulder. Rotate your wrist as you do so. Press the weight overhead by extending through the elbow.This will be your starting position.', 'Looking straight ahead and keeping a kettlebell locked out above you, flex the knees and hips and lower your torso between your legs, keeping your head and chest up.', 'Pause at the bottom position for a second before rising back to the top, driving through the heels of your feet.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/One-Arm_Overhead_Kettlebell_Squats/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/One-Arm_Overhead_Kettlebell_Squats/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'One-Arm Side Deadlift',
  'pull',
  'expert',
  'compound',
  'barbell',
  'strength',
  ARRAY['Stand to the side of a barbell next to its center. Bend your knees and lower your body until you are able to reach the barbell.', 'Grasp the bar as if you were grabbing a briefcase (palms facing you since the bar is sideways). You may need a wrist wrap if you are using a significant amount of weight. This is your starting position.', 'Use your legs to help lift the barbell up while exhaling. Your arms should extend fully as bring the barbell up until you are in a standing position.', 'Slowly bring the barbell back down while inhaling. Tip: Make sure to bend your knees while lowering the weight to avoid any injury from occurring.', 'Repeat for the recommended amount of repetitions.', 'Switch arms and repeat the movement.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/One-Arm_Side_Deadlift/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/One-Arm_Side_Deadlift/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'One-Arm Side Laterals',
  'push',
  'beginner',
  'isolation',
  'dumbbell',
  'strength',
  ARRAY['Pick a dumbbell and place it in one of your hands. Your non lifting hand should be used to grab something steady such as an incline bench press. Lean towards your lifting arm and away from the hand that is gripping the incline bench as this will allow you to keep your balance.', 'Stand with a straight torso and have the dumbbell by your side at arm''s length with the palm of the hand facing you. This will be your starting position.', 'While maintaining the torso stationary (no swinging), lift the dumbbell to your side with a slight bend on the elbow and your hand slightly tilted forward as if pouring water in a glass. Continue to go up until you arm is parallel to the floor. Exhale as you execute this movement and pause for a second at the top.', 'Lower the dumbbell back down slowly to the starting position as you inhale.', 'Repeat for the recommended amount of repetitions.', 'Switch arms and repeat the exercise.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/One-Arm_Side_Laterals/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/One-Arm_Side_Laterals/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'One-Legged Cable Kickback',
  'push',
  'intermediate',
  'isolation',
  'cable',
  'strength',
  ARRAY['Hook a leather ankle cuff to a low cable pulley and then attach the cuff to your ankle.', 'Face the weight stack from a distance of about two feet, grasping the steel frame for support.', 'While keeping your knees and hips bent slightly and your abs tight, contract your glutes to slowly "kick" the working leg back in a semicircular arc as high as it will comfortably go as you breathe out. Tip: At full extension, squeeze your glutes for a second in order to achieve a peak contraction.', 'Now slowly bring your working leg forward, resisting the pull of the cable until you reach the starting position.', 'Repeat for the recommended amount of repetitions.', 'Switch legs and repeat the movement for the other side.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/One-Legged_Cable_Kickback/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/One-Legged_Cable_Kickback/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'One Arm Against Wall',
  'static',
  'beginner',
  'isolation',
  NULL,
  'stretching',
  ARRAY['From a standing position, place a bent arm against a wall or doorway.', 'Slowly lean toward your arm until you feel a stretch in your lats.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/One_Arm_Against_Wall/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/One_Arm_Against_Wall/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'One Arm Chin-Up',
  'pull',
  'expert',
  'compound',
  'other',
  'strength',
  ARRAY['For this exercise, start out by placing a towel around a chin up bar.', 'Grab the chin-up bar with your palm facing you. One hand will be grabbing the chin-up bar and the other will be grabbing the towel.', 'Bring your torso back around 30 degrees or so while creating a curvature on your lower back and sticking your chest out. This is your starting position.v', 'Pull your torso up until the bar touches your upper chest by drawing the shoulders and the upper arms down and back. Exhale as you perform this portion of the movement. Tip: Concentrate on squeezing the back muscles once you reach the full contracted position. The upper torso should remain stationary as it moves through space and only the arms should move. The forearms should do no other work other than hold the bar.', 'After a second on the contracted position, start to inhale and slowly lower your torso back to the starting position when your arms are fully extended and the lats are fully stretched.', 'Repeat this motion for the prescribed amount of repetitions.', 'Switch arms and repeat the movement.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/One_Arm_Chin-Up/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/One_Arm_Chin-Up/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'One Arm Dumbbell Bench Press',
  'push',
  'beginner',
  'compound',
  'dumbbell',
  'strength',
  ARRAY['Lie down on a flat bench with a dumbbell in one hand on top of your thigh.', 'By using your thigh to help you get the dumbbell up, clean the dumbbell up so that you can hold it in front of you at shoulder width. Use the hand you are not lifting with to help position the dumbbell over you properly.', 'Once at shoulder width, rotate your wrist forward so that the palm of your hand is facing away from you. This will be your starting position.', 'Bring down the weights slowly to your side as you breathe in. Keep full control of the dumbbell at all times. Tip: Use the hand that you are not lifting with to help keep the dumbbell balance as you may struggle a bit at first. Only use your non-lifting hand if it is needed. Otherwise, keep it resting to the side.', 'As you breathe out, push the dumbbells up using your pectoral muscles. Lock your arms in the contracted position, squeeze your chest, hold for a second and then start coming down slowly. Tip: It should take at least twice as long to go down than to come up.', 'Repeat the movement for the prescribed amount of repetitions of your training program.', 'Switch arms and repeat the movement.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/One_Arm_Dumbbell_Bench_Press/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/One_Arm_Dumbbell_Bench_Press/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'One Arm Dumbbell Preacher Curl',
  'pull',
  'beginner',
  'isolation',
  'dumbbell',
  'strength',
  ARRAY['Grab a dumbbell with the right arm and place the upper arm on top of the preacher bench or the incline bench. The dumbbell should be held at shoulder length. This will be your starting position.', 'As you breathe in, slowly lower the dumbbell until your upper arm is extended and the biceps is fully stretched.', 'As you exhale, use the biceps to curl the weight up until your biceps is fully contracted and the dumbbell is at shoulder height. Again, remember that to ensure full contraction you need to bring that small finger higher than the thumb.', 'Squeeze the biceps hard for a second at the contracted position and repeat for the recommended amount of repetitions.', 'Switch arms and repeat the movement.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/One_Arm_Dumbbell_Preacher_Curl/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/One_Arm_Dumbbell_Preacher_Curl/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'One Arm Floor Press',
  'push',
  'intermediate',
  'compound',
  'barbell',
  'strength',
  ARRAY['Lie down on a flat surface with your back pressing against the floor or an exercise mat. Make sure your knees are bent.', 'Have a partner hand you the bar on one hand. When starting, your arm should be just about fully extended, similar to the starting position of a barbell bench press. However, this time your grip will be neutral (palms facing your torso).', 'Make sure the hand you are not using to lift the weight is placed by your side.', 'Begin the exercise by lowering the barbell until your elbow touches the ground. Make sure to breathe in as this is the eccentric (lowering part of the exercise).', 'Then start lifting the barbell back up to the original starting position. Remember to breathe out during the concentric (lifting part of the exercise).', 'Repeat until you have performed your recommended repetitions.', 'Switch arms and repeat the movement.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/One_Arm_Floor_Press/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/One_Arm_Floor_Press/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'One Arm Lat Pulldown',
  'pull',
  'beginner',
  'compound',
  'cable',
  'strength',
  ARRAY['Select an appropriate weight and adjust the knee pad to help keep you down. Grasp the handle with a pronated grip. This will be your starting position.', 'Pull the handle down, squeezing your elbow to your side as you flex the elbow.', 'Pause at the bottom of the motion, and then slowly return the handle to the starting position.', 'For multiple repetitions, avoid completely returning the weight to keep tension on the muscles being worked.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/One_Arm_Lat_Pulldown/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/One_Arm_Lat_Pulldown/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'One Arm Pronated Dumbbell Triceps Extension',
  'push',
  'beginner',
  'isolation',
  'dumbbell',
  'strength',
  ARRAY['Lie flat on a bench while holding a dumbbell at arms length. Your arm should be perpendicular to your body. The palm of your hand should be facing towards your feet as a pronated grip is required to perform this exercise.', 'Place your non lifting hand on your bicep for support.', 'Slowly begin to lower the dumbbell down as you breathe in.', 'Then, begin lifting the dumbbell upward as you contract the triceps. Remember to breathe out during the concentric (lifting part of the exercise).', 'Repeat until you have performed your set repetitions.', 'Switch arms and repeat the movement.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/One_Arm_Pronated_Dumbbell_Triceps_Extension/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/One_Arm_Pronated_Dumbbell_Triceps_Extension/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'One Arm Supinated Dumbbell Triceps Extension',
  'push',
  'beginner',
  'isolation',
  'dumbbell',
  'strength',
  ARRAY['Lie flat on a bench while holding a dumbbell at arms length. Your arm should be perpendicular to your body. The palm of your hand should be facing towards your face as a supinated grip is required to perform this exercise.', 'Place your non lifting hand on your bicep for support.', 'Slowly begin to lower the dumbbell down as you breathe in.', 'Then, begin lifting the dumbbell upward as you contract the triceps. Remember to breathe out during the concentric (lifting part of the exercise).', 'Repeat until you have performed your set repetitions.', 'Switch arms and repeat the movement.', 'Switch arms again and repeat the movement.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/One_Arm_Supinated_Dumbbell_Triceps_Extension/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/One_Arm_Supinated_Dumbbell_Triceps_Extension/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'One Half Locust',
  'static',
  'beginner',
  NULL,
  NULL,
  'stretching',
  ARRAY['Lie facedown on the floor.', 'Put your left hand under your left hipbone to pad your hip and pubic bone.', 'Bend your right knee so you can hold the foot in your right hand.', 'Lift the foot in the air and simultaneously lift your shoulders off the floor. This also stretches the right hip flexor and the chest and shoulders. Switch sides. If it doesn''t bother your back, you can try it with both arms and legs at the same time.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/One_Half_Locust/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/One_Half_Locust/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'One Handed Hang',
  'static',
  'beginner',
  NULL,
  'other',
  'stretching',
  ARRAY['Grab onto a chinup bar with one hand, using a pronated grip. Keep your feet on the floor or a step. Allow the majority of your weight to hang from that hand, while keeping your feet on the ground. Hold for 10-20 seconds and switch sides.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/One_Handed_Hang/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/One_Handed_Hang/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'One Knee To Chest',
  'static',
  'beginner',
  'compound',
  NULL,
  'stretching',
  ARRAY['Start off by lying on the floor.', 'Extend one leg straight and pull the other knee to your chest. Hold under the knee joint to protect the kneecap.', 'Gently tug that knee toward your nose.', 'Switch sides. This stretches the buttocks and lower back of the bent leg and the hip flexor of the straight leg.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/One_Knee_To_Chest/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/One_Knee_To_Chest/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'One Leg Barbell Squat',
  'push',
  'expert',
  'compound',
  'barbell',
  'strength',
  ARRAY['Start by standing about 2 to 3 feet in front of a flat bench with your back facing the bench. Have a barbell in front of you on the floor. Tip: Your feet should be shoulder width apart from each other.', 'Bend the knees and use a pronated grip with your hands being wider than shoulder width apart from each other to lift the barbell up until you can rest it on your chest.', 'Then lift the barbell over your head and rest it on the base of your neck. Move one foot back so that your toe is resting on the flat bench. Your other foot should be stationary in front of you. Keep your head up at all times as looking down will get you off balance and also maintain a straight back. Tip: Make sure your back is straight and chest is out while performing this exercise.', 'As you inhale, slowly lower your leg until your thigh is parallel to the floor. At this point, your knee should be over your toes. Your chest should be directly above the middle of your thigh.', 'Leading with the chest and hips and contracting the quadriceps, elevate your leg back to the starting position as you exhale.', 'Repeat for the recommended amount of repetitions.', 'Switch legs and repeat the movement.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/One_Leg_Barbell_Squat/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/One_Leg_Barbell_Squat/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Open Palm Kettlebell Clean',
  'pull',
  'expert',
  'compound',
  'kettlebell',
  'strength',
  ARRAY['Place one kettlebell between your feet. Clean the kettlebell by extending through the legs and hips as you raise the kettlebell towards your shoulders.', 'Release the kettlebell as it comes up, and let it flip so that the ball of the kettlebell lands in the palms of your hands.', 'Release the kettlebell out in front of you and catch the handle with both hands. Lower the kettlebell to the starting position and repeat.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Open_Palm_Kettlebell_Clean/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Open_Palm_Kettlebell_Clean/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Otis-Up',
  'pull',
  'beginner',
  'compound',
  'other',
  'strength',
  ARRAY['Secure your feet and lay back on the floor. Your knees should be bent. Hold a weight with both hands to your chest. This will be your starting position.', 'Initiate the movement by flexing the hips and spine to raise your torso up from the ground.', 'As you move up, press the weight up so that it is above your head at the top of the movement.', 'Return the weight to your chest as you reverse the sit-up motion, ensuring not to go all the way down to the floor.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Otis-Up/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Otis-Up/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Overhead Cable Curl',
  'pull',
  'intermediate',
  'isolation',
  'cable',
  'strength',
  ARRAY['To begin, set a weight that is comfortable on each side of the pulley machine. Note: Make sure that the amount of weight selected is the same on each side.', 'Now adjust the height of the pulleys on each side and make sure that they are positioned at a height higher than that of your shoulders.', 'Stand in the middle of both sides and use an underhand grip (palms facing towards the ceiling) to grab each handle. Your arms should be fully extended and parallel to the floor with your feet positioned shoulder width apart from each other. Your body should be evenly aligned the handles. This is the starting position.', 'While exhaling, slowly squeeze the biceps on each side until your forearms and biceps touch.', 'While inhaling, move your forearms back to the starting position. Note: Your entire body is stationary during this exercise except for the forearms.', 'Repeat for the recommended amount of repetitions prescribed in your program.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Overhead_Cable_Curl/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Overhead_Cable_Curl/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Overhead Lat',
  'static',
  'expert',
  NULL,
  'other',
  'stretching',
  ARRAY['Sit upright on the floor with your partner behind you. Raise one arm straight up, and flex the elbow, attempting to touch your hand to your back. Your parner should hold your tricep and wrist. This will be your starting position.', 'Attempt to pull your upper arm to your side as your partner prevents you from doing actually doing so.', 'After 10-20 seconds, relax the arm and allow your partner to further stretch the lat by applying gentle pressure to the tricep. Hold for 10-20 seconds, and then switch sides.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Overhead_Lat/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Overhead_Lat/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Overhead Slam',
  'pull',
  'beginner',
  'compound',
  'other',
  'plyometrics',
  ARRAY['Hold a medine ball with both hands and stand with your feet at shoulder width. This will be your starting position.', 'Initiate the countermovement by raising the ball above your head and fully extending your body.', 'Reverse the motion, slamming the ball into the ground directly in front of you as hard as you can.', 'Receive the ball with both hands on the bounce and repeat the movement.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Overhead_Slam/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Overhead_Slam/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Overhead Squat',
  'push',
  'expert',
  'compound',
  'barbell',
  'olympic_weightlifting',
  ARRAY['Start out by having a barbell in front of you on the floor. Your feet should be wider than shoulder width apart from each other.', 'Bend the knees and use a pronated grip (palms facing you) to grab the barbell. Your hands should be at a wider than shoulder width apart from each other before lifting. Once you are positioned, lift the barbell up until you can rest it on your chest.', 'Move the barbell over and slightly behind your head and make sure your arms are fully extended. Keep your head up at all times and also maintain a straight back. Retract your shoulder blades. This is your starting position.', 'Slowly lower the weight by bending your knees until your thighs are parallel to the ground while inhaling. Tip: Keep your back straight while performing this exercise to avoid any injuries and your arms should remain extended and over your head at all times.', 'Now use your feet and legs to help bring the weight back up to the starting position while exhaling.', 'Repeat for the recommended amount of repetitions.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Overhead_Squat/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Overhead_Squat/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Overhead Stretch',
  'static',
  'beginner',
  'compound',
  NULL,
  'stretching',
  ARRAY['Standing straight up, lace your fingers together and open your palms to the ceiling. Keep your shoulders down as you extend your arms up.', 'To create a full torso stretch, pull your tailbone down and stabilize your torso as you do this. Stretch the muscles on both the front and the back of the torso.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Overhead_Stretch/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Overhead_Stretch/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Overhead Triceps',
  'static',
  'expert',
  NULL,
  'body_only',
  'stretching',
  ARRAY['Sit upright on the floor with your partner behind you. Raise one arm straight up, and flex the elbow, attempting to touch your hand to your back. Your parner should hold your elbow and wrist. This will be your starting position.', 'Attempt to extend the arm straight into the air as your partner prevents you from doing actually doing so.', 'After 10-20 seconds, relax the arm and allow your partner to further stretch the tricep by applying gentle pressure to the wrist. Hold for 10-20 seconds, and then switch sides.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Overhead_Triceps/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Overhead_Triceps/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Pallof Press',
  'pull',
  'beginner',
  'isolation',
  'cable',
  'strength',
  ARRAY['Connect a standard handle to a tower, and—if possible—position the cable to shoulder height. If not, a low pulley will suffice.', 'With your side to the cable, grab the handle with both hands and step away from the tower. You should be approximately arm''s length away from the pulley, with the tension of the weight on the cable.', 'With your feet positioned hip-width apart and knees slightly bent, hold the cable to the middle of your chest. This will be your starting position.', 'Press the cable away from your chest, fully extending both arms. You core should be tight and engaged.', 'Hold the repetition for several seconds before returning to the starting position.', 'At the conclusion of the set, repeat facing the other direction.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Pallof_Press/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Pallof_Press/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Pallof Press With Rotation',
  'pull',
  'beginner',
  'compound',
  'cable',
  'strength',
  ARRAY['Connect a standard handle to a tower, and position the cable to shoulder height.', 'With your side to the cable, grab the handle with one hand and step away from the tower. You should be approximately arm''s length away from the pulley, with the tension of the weight on the cable. Align outstretched arm with cable.', 'With your feet positioned hip-width apart, pull the cable into your chest and grab the handle with your other hand. Both hands should be on the handle at this time.', 'Facing forward, press the cable away from your chest. You core should be tight and engaged.', 'Keeping your hips straight, twist your torso away from the pulley until you get a full quarter rotation.', 'Maintain your rigid stance and straight arms. Return to the neutral position in a slow and controlled manner. Your arms should be extended in front of you.', 'With the side tension still engaging your core, bring your hands to your chest and immediately press outward to a fully extended position. This constitutes one rep.', 'Repeat to failure.', 'Then, reposition and repeat the same series of movements on the opposite side.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Pallof_Press_With_Rotation/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Pallof_Press_With_Rotation/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Palms-Down Dumbbell Wrist Curl Over A Bench',
  'pull',
  'beginner',
  'isolation',
  'dumbbell',
  'strength',
  ARRAY['Start out by placing two dumbbells on one side of a flat bench.', 'Kneel down on both of your knees so that your body is facing the flat bench.', 'Use your arms to grab both of the dumbbells with a pronated grip (palms facing down) and bring them up so that your forearms are resting against the flat bench. Your wrists should be hanging over the edge.', 'Start out by curling your wrist upwards and exhaling.', 'Slowly lower your wrists back down to the starting position while inhaling.', 'Your forearms should be stationary as your wrist is the only movement needed to perform this exercise.', 'Repeat for the recommended amount of repetitions.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Palms-Down_Dumbbell_Wrist_Curl_Over_A_Bench/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Palms-Down_Dumbbell_Wrist_Curl_Over_A_Bench/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Palms-Down Wrist Curl Over A Bench',
  'pull',
  'beginner',
  'isolation',
  'barbell',
  'strength',
  ARRAY['Start out by placing a barbell on one side of a flat bench.', 'Kneel down on both of your knees so that your body is facing the flat bench.', 'Use your arms to grab the barbell with a pronated grip (palms down) and bring them up so that your forearms are resting against the flat bench. Your wrists should be hanging over the edge.', 'Start out by curling your wrist upwards and exhaling.', 'Slowly lower your wrists back down to the starting position while inhaling.', 'Your forearms should be stationary as your wrist is the only movement needed to perform this exercise.', 'Repeat for the recommended amount of repetitions.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Palms-Down_Wrist_Curl_Over_A_Bench/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Palms-Down_Wrist_Curl_Over_A_Bench/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Palms-Up Barbell Wrist Curl Over A Bench',
  'pull',
  'beginner',
  'isolation',
  'barbell',
  'strength',
  ARRAY['Start out by placing a barbell on one side of a flat bench.', 'Kneel down on both of your knees so that your body is facing the flat bench.', 'Use your arms to grab the barbell with a supinated grip (palms up) and bring them up so that your forearms are resting against the flat bench. Your wrists should be hanging over the edge.', 'Start out by curling your wrist upwards and exhaling.', 'Slowly lower your wrists back down to the starting position while inhaling.', 'Your forearms should be stationary as your wrist is the only movement needed to perform this exercise.', 'Repeat for the recommended amount of repetitions.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Palms-Up_Barbell_Wrist_Curl_Over_A_Bench/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Palms-Up_Barbell_Wrist_Curl_Over_A_Bench/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Palms-Up Dumbbell Wrist Curl Over A Bench',
  'pull',
  'beginner',
  'isolation',
  'dumbbell',
  'strength',
  ARRAY['Start out by placing two dumbbells on one side of a flat bench.', 'Kneel down on both of your knees so that your body is facing the flat bench.', 'Use your arms to grab both of the dumbbells with a supinated grip (palms up) and bring them up so that your forearms are resting against the flat bench. Your wrists should be hanging over the edge.', 'Start out by curling your wrist upwards and exhaling.', 'Slowly lower your wrists back down to the starting position while inhaling. Make sure to inhale during this part of the exercise.', 'Your forearms should be stationary as your wrist is the only movement needed to perform this exercise.', 'Repeat for the recommended amount of repetitions.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Palms-Up_Dumbbell_Wrist_Curl_Over_A_Bench/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Palms-Up_Dumbbell_Wrist_Curl_Over_A_Bench/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Parallel Bar Dip',
  'push',
  'beginner',
  'compound',
  'other',
  'strength',
  ARRAY['Stand between a set of parallel bars. Place a hand on each bar, and then take a small jump to help you get into the starting position with your arms locked out.', 'Begin by flexing the elbow, lowering your body until your arms break 90 degrees. Avoid swinging, and maintain good posture throughout the descent.', 'Reverse the motion by extending the elbow, pushing yourself back up into the starting position.', 'Repeat for the desired number of repetitions.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Parallel_Bar_Dip/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Parallel_Bar_Dip/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Pelvic Tilt Into Bridge',
  'static',
  'intermediate',
  'compound',
  NULL,
  'stretching',
  ARRAY['Lie down with your feet on the floor, heels directly under your knees.', 'Lift only your tailbone to the ceiling to stretch your lower back. (Don''t lift the entire spine yet.) Pull in your stomach.', 'To go into a bridge, lift the entire spine except the neck.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Pelvic_Tilt_Into_Bridge/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Pelvic_Tilt_Into_Bridge/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Peroneals-SMR',
  'static',
  'intermediate',
  NULL,
  'other',
  'stretching',
  ARRAY['Lay on your side, supporting your weight on your forearm and on a foam roller placed on the outside of your lower leg. Your upper leg can either be on top of your lower leg, or you can cross it in front of you. This will be your starting position.', 'Raise your hips off of the ground and begin to roll from below the knee to above the ankle on the side of your leg, pausing at points of tension for 10-30 seconds. Repeat on the other leg.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Peroneals-SMR/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Peroneals-SMR/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Peroneals Stretch',
  'static',
  'intermediate',
  NULL,
  'other',
  'stretching',
  ARRAY['In a seated position, loop a belt, rope, or band around one foot. This will be your starting position.', 'With the leg extended and the heel off of the ground, pull on the belt so that the foot is inverted, with the inside of the foot being pulled towards you. Hold for 10-20 seconds, and then switch sides.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Peroneals_Stretch/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Peroneals_Stretch/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Physioball Hip Bridge',
  'push',
  'beginner',
  'compound',
  'other',
  'strength',
  ARRAY['Lay on a ball so that your upper back is on the ball with your hips unsupported. Both feet should be flat on the floor, hip width apart or wider. This will be your starting position.', 'Begin by extending the hips using your glutes and hamstrings, raising your hips upward as you bridge.', 'Pause at the top of the motion and return to the starting position.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Physioball_Hip_Bridge/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Physioball_Hip_Bridge/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Pin Presses',
  'push',
  'intermediate',
  'compound',
  'barbell',
  'powerlifting',
  ARRAY['Pin presses remove the eccentric phase of the bench press, developing starting strength. They also allow you to train a desired range of motion.', 'The bench should be set up in a power rack. Set the pins to the desired point in your range of motion, whether it just be lockout or an inch off of your chest. The bar should be moved to the pins and prepared for lifting.', 'Begin by lying on the bench, with the bar directly above the contact point during your regular bench. Tuck your feet underneath you and arch your back. Using the bar to help support your weight, lift your shoulder off the bench and retract them, squeezing the shoulder blades together. Use your feet to drive your traps into the bench. Maintain this tight body position throughout the movement.', 'You can take a standard bench grip, or shoulder width to focus on the triceps. The bar, wrist, and elbow should stay in line at all times. Focus on squeezing the bar and trying to pull it apart.', 'Drive the bar up with as much force as possible. The elbows should be tucked in until lockout.', 'Return the bar to the pins, pausing before beginning the next repetition.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Pin_Presses/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Pin_Presses/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Piriformis-SMR',
  'static',
  'intermediate',
  'isolation',
  'other',
  'stretching',
  ARRAY['Sit with your buttocks on top of a foam roll. Bend your knees, and then cross one leg so that the ankle is over the knee. This will be your starting position.', 'Shift your weight to the side of the crossed leg, rolling over the buttocks until you feel tension in your upper glute. You may assist the stretch by using one hand to pull the bent knee towards your chest. Hold this position for 10-30 seconds, and then switch sides.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Piriformis-SMR/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Piriformis-SMR/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Plank',
  'static',
  'beginner',
  'isolation',
  'body_only',
  'strength',
  ARRAY['Get into a prone position on the floor, supporting your weight on your toes and your forearms. Your arms are bent and directly below the shoulder.', 'Keep your body straight at all times, and hold this position as long as possible. To increase difficulty, an arm or leg can be raised.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Plank/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Plank/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Plate Pinch',
  'static',
  'intermediate',
  'isolation',
  'other',
  'strength',
  ARRAY['Grab two wide-rimmed plates and put them together with the smooth sides facing outward', 'Use your fingers to grip the outside part of the plate and your thumb for the other side thus holding both plates together. This is the starting position.', 'Squeeze the plate with your fingers and thumb. Hold this position for as long as you can.', 'Repeat for the recommended amount of sets prescribed in your program.', 'Switch arms and repeat the movements.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Plate_Pinch/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Plate_Pinch/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Plate Twist',
  'pull',
  'intermediate',
  'compound',
  'other',
  'strength',
  ARRAY['Lie down on the floor or an exercise mat with your legs fully extended and your upper body upright. Grab the plate by its sides with both hands out in front of your abdominals with your arms slightly bent.', 'Slowly cross your legs near your ankles and lift them up off the ground. Your knees should also be bent slightly. Note: Move your upper body back slightly to help keep you balanced turning this exercise. This is the starting position.', 'Move the plate to the left side and touch the floor with it. Breathe out as you perform that movement.', 'Come back to the starting position as you breathe in and then repeat the movement but this time to the right side of the body. Tip: Use a slow controlled movement at all times. Jerking motions can injure the back.', 'Repeat for the recommended amount of repetitions.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Plate_Twist/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Plate_Twist/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Platform Hamstring Slides',
  'pull',
  'beginner',
  'isolation',
  'other',
  'strength',
  ARRAY['For this movement a wooden floor or similar is needed. Lay on your back with your legs extended. Place a gym towel or a light weight underneath your heel. This will be your starting position.', 'Begin the movement by flexing the knee, keeping your other leg straight.', 'Continue bringing the heel closer to you, sliding it on the floor.', 'At full knee flexion, reverse the movement to return to the starting position.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Platform_Hamstring_Slides/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Platform_Hamstring_Slides/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Plie Dumbbell Squat',
  'push',
  'beginner',
  'compound',
  'dumbbell',
  'strength',
  ARRAY['Hold a dumbbell at the base with both hands and stand straight up. Move your legs so that they are wider than shoulder width apart from each other with your knees slightly bent.', 'Your toes should be facing out. Note: Your arms should be stationary while performing the exercise. This is the starting position.', 'Slowly bend the knees and lower your legs until your thighs are parallel to the floor. Make sure to inhale as this is the eccentric part of the exercise.', 'Press mainly with the heel of the foot to bring the body back to the starting position while exhaling.', 'Repeat for the recommended amount of repetitions.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Plie_Dumbbell_Squat/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Plie_Dumbbell_Squat/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Plyo Kettlebell Pushups',
  'push',
  'expert',
  'compound',
  'kettlebell',
  'strength',
  ARRAY['Place a kettlebell on the floor. Place yourself in a pushup position, on your toes with one hand on the ground and one hand holding the kettlebell, with your elbows extended. This will be your starting position.', 'Begin by lowering yourself as low as you can, keeping your back straight.', 'Quickly and forcefully reverse direction, pushing yourself up to the other side of the kettlebell, switching hands as you do so. Continue the movement by descending and repeating the movement back and forth.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Plyo_Kettlebell_Pushups/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Plyo_Kettlebell_Pushups/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Plyo Push-up',
  'push',
  'beginner',
  'compound',
  'body_only',
  'plyometrics',
  ARRAY['Move into a prone position on the floor, supporting your weight on your hands and toes.', 'Your arms should be fully extended with the hands around shoulder width. Keep your body straight throughout the movement. This will be your starting position.', 'Descend by flexing at the elbow, lowering your chest towards the ground.', 'At the bottom, reverse the motion by pushing yourself up through elbow extension as quickly as possible. Attempt to push your upper body up until your hands leave the ground.', 'Return to the starting position and repeat the exercise.', 'For added difficulty, add claps into the movement while you are air borne.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Plyo_Push-up/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Plyo_Push-up/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Posterior Tibialis Stretch',
  'static',
  'intermediate',
  NULL,
  'other',
  'stretching',
  ARRAY['In a seated position, loop a belt, rope, or band around one foot. This will be your starting position.', 'With the leg extended and the heel off of the ground, pull on the belt so that the foot is everted, with the outside of the foot being pulled towards you. Hold for 10-20 seconds, and then switch sides.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Posterior_Tibialis_Stretch/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Posterior_Tibialis_Stretch/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Power Clean',
  'pull',
  'intermediate',
  'compound',
  'barbell',
  'strength',
  ARRAY['Stand with your feet slightly wider than shoulder width apart and toes pointing out slightly.', 'Squat down and grasp bar with a closed, pronated grip. Your hands should be slightly wider than shoulder width apart outside knees with elbows fully extended.', 'Place the bar about 1 inch in front of your shins and over the balls of your feet.', 'Your back should be flat or slightly arched, your chest held up and out and your shoulder blades should be retracted.', 'Keep your head in a neutral position (in line with vertebral column and not tilted or rotated) with your eyes focused straight ahead. Inhale during this phase.', 'Lift the bar from the floor by forcefully extending the hips and the knees as you exhale. Tip: The upper torso should maintain the same angle. Do not bend at the waist yet and do not let the hips rise before the shoulders (this would have the effect of pushing the glutes in the air and stretching the hamstrings.', 'Keep elbows fully extended with the head in a neutral position and the shoulders over the bar.', 'As the bar raises keep it as close to the shins as possible.', 'As the bar passes the knees, thrust your hips forward and slightly bend the knees to avoid locking them. Tip: At this point your thighs should be against the bar.', 'Keep the back flat or slightly arched, elbows fully extended and your head neutral. Tip: You will hold your breath until the next phase.', 'Inhale and then forcefully and quickly extend your hips and knees and stand on your toes.', 'Keep the bar as close to your body as possible. Tip: Your back should be flat with the elbows pointed out to the sides and your head in a neutral position. Also, keep your shoulders over the bar and arms straight as long as possible.', 'When your lower body joints are fully extended, shrug the shoulders upward rapidly without letting the elbows flex yet. Exhale during this portion of the movement.', 'As the shoulders reach their highest elevation flex your elbows to begin pulling your body under the bar.', 'Continue to pull the arms as high and as long as possible. Tip: Due to the explosive nature of this phase, your torso will be erect or with an arched back, your head will be tilted back slightly and your feet may lose contact with the floor.', 'After the lower body has fully extended and the bar reaches near maximal height, pull your body under the bar and rotate the arms around and under the bar.', 'Simultaneously, flex the hips and knees into a quarter squat position.', 'Once the arms are under the bar, inhale and then lift your elbows to position the upper arms parallel to the floor. Rack the bar across the front of your collar bones and front shoulder muscles.', 'Catch the bar with an erect and tight torso, a neutral head position and flat feet. Exhale during this movement.', 'Stand up by extending the hips and knees to a fully erect position.', 'Lower the bar by gradually reducing the muscular tension of the arms to allow a controlled descent of the bar to the thighs. Inhale during this movement.', 'Simultaneously flex the hips and knees to cushion the impact of the bar on the thighs.', 'Squat down with the elbows fully extended until the bar touches the floor.', 'Start over at Phase 1 and repeat for the recommended amount of repetitions.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Power_Clean/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Power_Clean/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Power Clean from Blocks',
  'pull',
  'intermediate',
  'compound',
  'barbell',
  'olympic_weightlifting',
  ARRAY['With a barbell on boxes of the desired height, take a grip just outside the legs. Lower your hips with the weight focused on the heels, back straight, head facing forward, chest up, with your shoulders just in front of the bar. This will be your starting position.', 'Begin the first pull by driving through the heels, extending your knees. Your back angle should stay the same, and your arms should remain straight. As the bar approaches the mid-thigh position, begin extending through the hips.', 'In a jumping motion, accelerate by extending the hips, knees, and ankles, using speed to move the bar upward. There should be no need to actively pull through the arms to accelerate the weight. At the end of the second pull, the body should be fully extended, leaning slightly back, with the arms still extended.', 'As full extension is achieved, transition into the third pull by aggressively shrugging and flexing the arms with the elbows up and out. At peak extension, pull yourself under the bar far enough that it can be racked onto the shoulders, rotating your elbows under the bar as you do so. The bar should be racked onto the protracted shoulders, lightly touching the throat with the hands relaxed.', 'Immediately recover by driving through the heels, keeping the torso upright and elbows up. Continue until you have risen to a standing position, and complete the repetition by returning the weight to the boxes.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Power_Clean_from_Blocks/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Power_Clean_from_Blocks/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Power Jerk',
  'push',
  'expert',
  'compound',
  'barbell',
  'olympic_weightlifting',
  ARRAY['Standing with the weight racked on the front of the shoulders, begin with the dip. With your feet directly under your hips, flex the knees without moving the hips backward. Go down only slightly, and reverse direction as powerfully as possible.', 'Drive through the heels create as much speed and force as possible, and be sure to move your head out of the way as the bar leaves the shoulders.', 'At this moment as the feet leave the floor, the feet must be placed into the receiving position as quickly as possible. In the brief moment the feet are not actively driving against the platform, the athletes effort to push the bar up will drive them down. The feet should be moved to a slightly wider stance, with the knees partially bent.', 'Receive the bar with the arms locked out overhead.', 'Return to a standing position.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Power_Jerk/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Power_Jerk/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Power Partials',
  'push',
  'beginner',
  'isolation',
  'dumbbell',
  'strength',
  ARRAY['Stand up with your torso upright and a dumbbell on each hand being held at arms length. The elbows should be close to the torso.', 'The palms of the hands should be facing your torso. Your feet should be about shoulder width apart. This will be your starting position.', 'Keeping your arms straight and the torso stationary, lift the weights out to your sides until they are about shoulder level height while exhaling.', 'Feel the contraction for a second and begin to lower the weights back down to the starting position while inhaling. Tip: Keep the palms facing down with the little finger slightly higher while lifting and lowering the weights as it will concentrate the stress on your shoulders mainly.', 'Repeat for the recommended amount of repetitions.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Power_Partials/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Power_Partials/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Power Snatch',
  'pull',
  'expert',
  'compound',
  'barbell',
  'olympic_weightlifting',
  ARRAY['Begin with a loaded barbell on the floor. The bar should be close to or touching the shins, and a wide grip should be taken on the bar. The feet should be directly below the hips, with the feet turned out as needed. Lower the hips, with the chest up and the head looking forward. The shoulders should be just in front of the bar. This will be the starting position.', 'Begin the first pull by driving through the front of the heels, raising the bar from the ground. The back angle should stay the same until the bar passes the knees.', 'Transition into the second pull by extending through the hips knees and ankles, driving the bar up as quickly as possible. The bar should be close to the body. At peak extension, shrug the shoulders and allow the elbows to flex to the side.', 'As you move your feet into the receiving position, a slightly wider position, pull yourself below the bar as you elevate the bar overhead. The bar should be received in a partial squat. Continue raising the bar to the overhead position, receiving the bar locked out overhead.', 'Return to a standing position with the weight over head.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Power_Snatch/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Power_Snatch/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Power Snatch from Blocks',
  'pull',
  'intermediate',
  'compound',
  'barbell',
  'olympic_weightlifting',
  ARRAY['Begin with a loaded barbell on boxes or stands of the desired height. A wide grip should be taken on the bar. The feet should be directly below the hips, with the feet turned out as needed. Lower the hips, with the chest up and the head looking forward. The shoulders should be just in front of the bar, with the elbows pointed out. This will be the starting position.', 'Begin the first pull by driving through the front of the heels, raising the bar from the boxes.', 'Transition into the second pull by extending through the hips knees and ankles, driving the bar up as quickly as possible. The bar should be close to the body. At peak extension, shrug the shoulders and allow the elbows to flex to the side.', 'As you move your feet into the receiving position, forcefully pull yourself below the bar as you elevate the bar overhead. The feet should move to just outside the hips, turned out as necessary. Receive the bar above a full squat and with the arms fully extended overhead.', 'Keeping the bar aligned over the front of the heels, your head and chest up, drive through heels of the feet to move to a standing position. Carefully return the weight to the boxes.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Power_Snatch_from_Blocks/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Power_Snatch_from_Blocks/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Power Stairs',
  'pull',
  'intermediate',
  'compound',
  'other',
  'strongman',
  ARRAY['In the power stairs, implements are moved up a staircase. For training purposes, these can be performed with a tire or box.', 'Begin by taking the implement with both hands. Set your feet wide, with your head and chest up. Drive through the ground with your heels, extending your knees and hips to raise the weight from the ground.', 'As you lean back, attempt to swing the weight onto the stairs, which are usually around 16-18" high. You can use your legs to help push the weight onto the stair.', 'Repeat for 3-5 repetitions, and continue with a heavier weight, moving as fast as possible.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Power_Stairs/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Power_Stairs/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Preacher Curl',
  'pull',
  'beginner',
  'isolation',
  'barbell',
  'strength',
  ARRAY['To perform this movement you will need a preacher bench and an E-Z bar. Grab the E-Z curl bar at the close inner handle (either have someone hand you the bar which is preferable or grab the bar from the front bar rest provided by most preacher benches). The palm of your hands should be facing forward and they should be slightly tilted inwards due to the shape of the bar.', 'With the upper arms positioned against the preacher bench pad and the chest against it, hold the E-Z Curl Bar at shoulder length. This will be your starting position.', 'As you breathe in, slowly lower the bar until your upper arm is extended and the biceps is fully stretched.', 'As you exhale, use the biceps to curl the weight up until your biceps is fully contracted and the bar is at shoulder height. Squeeze the biceps hard and hold this position for a second.', 'Repeat for the recommended amount of repetitions.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Preacher_Curl/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Preacher_Curl/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Preacher Hammer Dumbbell Curl',
  'pull',
  'beginner',
  'isolation',
  'dumbbell',
  'strength',
  ARRAY['Place the upper part of both arms on top of the preacher bench as you hold a dumbbell in each hand with the palms facing each other (neutral grip).', 'As you breathe in, slowly lower the dumbbells until your upper arm is extended and the biceps is fully stretched.', 'As you exhale, use the biceps to curl the weight up until your biceps is fully contracted and the dumbbells are at shoulder height.', 'Squeeze the biceps hard for a second at the contracted position and repeat for the recommended amount of repetitions.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Preacher_Hammer_Dumbbell_Curl/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Preacher_Hammer_Dumbbell_Curl/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Press Sit-Up',
  'push',
  'expert',
  'compound',
  'barbell',
  'strength',
  ARRAY['To begin, lie down on a bench with a barbell resting on your chest. Position your legs so they are secure on the extension of the abdominal bench. This is the starting position.', 'While inhaling, tighten your abdominals and glutes. Simultaneously curl your torso as you do when performing a sit-up and press the barbell to an overhead position while exhaling. Tip: Use your arms to push the barbell out as you perform this exercise while still focusing on the abdominal muscles.', 'Lower your upper body back down to the starting position while bringing the barbell back down to your torso. Remember to breathe in while lowering the body.', 'Repeat for the recommended amount of repetitions.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Press_Sit-Up/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Press_Sit-Up/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Prone Manual Hamstring',
  'static',
  'beginner',
  'isolation',
  NULL,
  'strength',
  ARRAY['You will need a partner for this exercise. Lay face down with your legs straight. Your assistant will place their hand on your heel.', 'To begin, flex the knee to curl your leg up. Your partner should provide resistance, starting light and increasing the pressure as the movement is completed. Communicate with your partner to monitor appropriate resistance levels.', 'Pause at the top, returning the leg to the starting position as your partner provides resistance going the other direction.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Prone_Manual_Hamstring/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Prone_Manual_Hamstring/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Prowler Sprint',
  'push',
  'beginner',
  'compound',
  'other',
  'cardio',
  ARRAY['Place your sled on an appropriate surface, loaded to a suitable weight. The sled should provide enough resistance to require effort, but not so heavy that you are significantly slowed down.', 'You may use the upright or the low handles for this exercise. Place your hands on the handles with your arms extended, leaning into the implement.', 'With good posture, drive through the ground with alternating, short steps. Move as fast as you can for a short distance.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Prowler_Sprint/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Prowler_Sprint/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Pull Through',
  'pull',
  'beginner',
  'compound',
  'cable',
  'strength',
  ARRAY['Begin standing a few feet in front of a low pulley with a rope or handle attached. Face away from the machine, straddling the cable, with your feet set wide apart.', 'Begin the movement by reaching through your legs as far as possible, bending at the hips. Keep your knees slightly bent. Keeping your arms straight, extend through the hip to stand straight up. Avoid pulling upward through the shoulders; all of the motion should originate through the hips.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Pull_Through/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Pull_Through/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Pullups',
  'pull',
  'beginner',
  'compound',
  'body_only',
  'strength',
  ARRAY['Grab the pull-up bar with the palms facing forward using the prescribed grip. Note on grips: For a wide grip, your hands need to be spaced out at a distance wider than your shoulder width. For a medium grip, your hands need to be spaced out at a distance equal to your shoulder width and for a close grip at a distance smaller than your shoulder width.', 'As you have both arms extended in front of you holding the bar at the chosen grip width, bring your torso back around 30 degrees or so while creating a curvature on your lower back and sticking your chest out. This is your starting position.', 'Pull your torso up until the bar touches your upper chest by drawing the shoulders and the upper arms down and back. Exhale as you perform this portion of the movement. Tip: Concentrate on squeezing the back muscles once you reach the full contracted position. The upper torso should remain stationary as it moves through space and only the arms should move. The forearms should do no other work other than hold the bar.', 'After a second on the contracted position, start to inhale and slowly lower your torso back to the starting position when your arms are fully extended and the lats are fully stretched.', 'Repeat this motion for the prescribed amount of repetitions.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Pullups/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Pullups/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Push-Up Wide',
  NULL,
  'beginner',
  'compound',
  'body_only',
  'strength',
  ARRAY['With your hands wide apart, support your body on your toes and hands in a plank position. Your elbows should be extended and your body straight. Do not allow your hips to sag. This will be your starting position.', 'To begin, allow the elbows to flex, lowering your chest to the floor as you inhale.', 'Using your pectoral muscles, press your upper body back up to the starting position by extending the elbows. Exhale as you perform this step.', 'After pausing at the contracted position, repeat the movement for the prescribed amount of repetitions.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Push-Up_Wide/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Push-Up_Wide/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Push-Ups - Close Triceps Position',
  'push',
  'intermediate',
  'compound',
  'body_only',
  'strength',
  ARRAY['Lie on the floor face down and place your hands closer than shoulder width for a close hand position. Make sure that you are holding your torso up at arms'' length.', 'Lower yourself until your chest almost touches the floor as you inhale.', 'Using your triceps and some of your pectoral muscles, press your upper body back up to the starting position and squeeze your chest. Breathe out as you perform this step.', 'After a second pause at the contracted position, repeat the movement for the prescribed amount of repetitions.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Push-Ups_-_Close_Triceps_Position/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Push-Ups_-_Close_Triceps_Position/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Push-Ups With Feet Elevated',
  'push',
  'beginner',
  'compound',
  'body_only',
  'strength',
  ARRAY['Lie on the floor face down and place your hands about 36 inches apart from each other holding your torso up at arms length.', 'Place your toes on top of a flat bench. This will allow your body to be elevated. Note: The higher the elevation of the flat bench, the higher the resistance of the exercise is.', 'Lower yourself until your chest almost touches the floor as you inhale.', 'Using your pectoral muscles, press your upper body back up to the starting position and squeeze your chest. Breathe out as you perform this step.', 'After a second pause at the contracted position, repeat the movement for the prescribed amount of repetitions.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Push-Ups_With_Feet_Elevated/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Push-Ups_With_Feet_Elevated/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Push-Ups With Feet On An Exercise Ball',
  'push',
  'intermediate',
  'compound',
  'other',
  'strength',
  ARRAY['Lie on the floor face down and place your hands about 36 inches apart from each other holding your torso up at arms length.', 'Place your toes on top of an exercise ball. This will allow your body to be elevated.', 'Lower yourself until your chest almost touches the floor as you inhale.', 'Using your pectoral muscles, press your upper body back up to the starting position and squeeze your chest. Breathe out as you perform this step.', 'After a second pause at the contracted position, repeat the movement for the prescribed amount of repetitions.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Push-Ups_With_Feet_On_An_Exercise_Ball/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Push-Ups_With_Feet_On_An_Exercise_Ball/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Push Press',
  'push',
  'expert',
  'compound',
  'barbell',
  'olympic_weightlifting',
  NULL,
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Push_Press/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Push_Press/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Push Press - Behind the Neck',
  'push',
  'intermediate',
  'compound',
  'barbell',
  'olympic_weightlifting',
  ARRAY['Standing with the weight racked on the back of the shoulders, begin with the dip. With your feet directly under your hips, flex the knees without moving the hips backward. Go down only slightly, and reverse direction as powerfully as possible. Drive through the heels create as much speed and force as possible, moving the bar in a vertical path.', 'Using the momentum generated, finish pressing the weight overhead be extending through the arms.', 'Return to the starting position, using your legs to absorb the impact.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Push_Press_-_Behind_the_Neck/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Push_Press_-_Behind_the_Neck/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Push Up to Side Plank',
  'push',
  'beginner',
  'compound',
  'body_only',
  'strength',
  ARRAY['Get into pushup position on the toes with your hands just outside of shoulder width.', 'Perform a pushup by allowing the elbows to flex. As you descend, keep your body straight.', 'Do one pushup and as you come up, shift your weight on the left side of the body, twist to the side while bringing the right arm up towards the ceiling in a side plank.', 'Lower the arm back to the floor for another pushup and then twist to the other side.', 'Repeat the series, alternating each side, for 10 or more reps.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Push_Up_to_Side_Plank/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Push_Up_to_Side_Plank/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Pushups',
  'push',
  'beginner',
  'compound',
  'body_only',
  'strength',
  ARRAY['Lie on the floor face down and place your hands about 36 inches apart while holding your torso up at arms length.', 'Next, lower yourself downward until your chest almost touches the floor as you inhale.', 'Now breathe out and press your upper body back up to the starting position while squeezing your chest.', 'After a brief pause at the top contracted position, you can begin to lower yourself downward again for as many repetitions as needed.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Pushups/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Pushups/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Pushups (Close and Wide Hand Positions)',
  'push',
  'beginner',
  'compound',
  'body_only',
  'strength',
  ARRAY['Lie on the floor face down and body straight with your toes on the floor and the hands wider than shoulder width for a wide hand position and closer than shoulder width for a close hand position. Make sure you are holding your torso up at arms length.', 'Lower yourself until your chest almost touches the floor as you inhale.', 'Using your pectoral muscles, press your upper body back up to the starting position and squeeze your chest. Breathe out as you perform this step.', 'After a second pause at the contracted position, repeat the movement for the prescribed amount of repetitions.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Pushups_Close_and_Wide_Hand_Positions/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Pushups_Close_and_Wide_Hand_Positions/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Pyramid',
  'static',
  'beginner',
  NULL,
  'other',
  'stretching',
  ARRAY['Start off by rolling your torso forward onto the ball so your hips rest on top of the ball and become the highest point of your body.', 'Rest your hands and feet on the floor. Your arms and legs can be slightly bent or straight, depending on the size of the ball, your flexibility, and the length of your limbs. This also helps develop stabilizing strength in your torso and shoulders.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Pyramid/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Pyramid/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Quad Stretch',
  'static',
  'intermediate',
  NULL,
  'other',
  'stretching',
  ARRAY['Lay on your side. Loop a belt, rope, or band around your top foot. Flex the knee and extend your hip, attempting to touch your glutes with your foot, and holding the belt with your hands. This will be your starting position.', 'With the belt being held over the shoulder or overhead, gently pull to increase the stretch in the quadriceps. Hold for 10-20 seconds, and then switch sides.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Quad_Stretch/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Quad_Stretch/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Quadriceps-SMR',
  'static',
  'intermediate',
  'isolation',
  'other',
  'stretching',
  ARRAY['Lay facedown on the floor with your weight supported by your hands or forearms. Place a foam roll underneath one leg on the quadriceps, and keep the foot off of the ground. Make sure to relax the leg as much as possible. This will be your starting position.', 'Shifting as much weight onto the leg to be stretched as is tolerable, roll over the foam from above the knee to below the hip, holding points of tension for 10-30 seconds. Switch sides.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Quadriceps-SMR/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Quadriceps-SMR/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Quick Leap',
  'push',
  'beginner',
  'compound',
  'other',
  'plyometrics',
  ARRAY['You will need a box for this exerise.', 'Begin facing the box standing 1-2 feet from its edge.', 'By utilizing your hips, hop onto the box, landing on both legs. Ensure that you land with your legs bent and your feet flat.', 'Immediately upon landing, fully extend through the entire body and swing your arms overhead to explode off of the box. Use your legs to absorb the impact of landing.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Quick_Leap/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Quick_Leap/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Rack Delivery',
  'pull',
  'intermediate',
  'compound',
  'barbell',
  'olympic_weightlifting',
  ARRAY['This drill teaches the delivery of the barbell to the rack position on the shoulders. Begin holding a bar in the scarecrow position, with the upper arms parallel to the floor, and the forearms hanging down. Use a hook grip, with your fingers wrapped over your thumbs.', 'Begin by rotating the elbows around the bar, delivering the bar to the shoulders. As your elbows come forward, relax your grip. The shoulders should be protracted, providing a shelf for the bar, which should lightly contact the throat.', 'It is important that the bar stay close to the body at all times, as with a heavier load any distance will result in an unwanted collision. As the movement becomes smoother, speed and load can be increased before progressing further.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Rack_Delivery/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Rack_Delivery/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Rack Pull with Bands',
  'pull',
  'intermediate',
  'compound',
  'barbell',
  'powerlifting',
  ARRAY['Set up in a power rack with the bar on the pins. The pins should be set to the desired point; just below the knees, just above, or in the mid thigh position. Attach bands to the base of the rack, or secure them with dumbbells. Attach the other end to the bar. You may need to choke the bands to provide tension.', 'Position yourself against the bar in proper deadlifting position. Your feet should be under your hips, your grip shoulder width, back arched, and hips back to engage the hamstrings. Since the weight is typically heavy, you may use a mixed grip, a hook grip, or use straps to aid in holding the weight.', 'With your head looking forward, extend through the hips and knees, pulling the weight up and back until lockout. Be sure to pull your shoulders back as you complete the movement. Return the weight to the pins and repeat.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Rack_Pull_with_Bands/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Rack_Pull_with_Bands/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Rack Pulls',
  'pull',
  'intermediate',
  'compound',
  'barbell',
  'powerlifting',
  ARRAY['Set up in a power rack with the bar on the pins. The pins should be set to the desired point; just below the knees, just above, or in the mid thigh position. Position yourself against the bar in proper deadlifting position. Your feet should be under your hips, your grip shoulder width, back arched, and hips back to engage the hamstrings. Since the weight is typically heavy, you may use a mixed grip, a hook grip, or use straps to aid in holding the weight.', 'With your head looking forward, extend through the hips and knees, pulling the weight up and back until lockout. Be sure to pull your shoulders back as you complete the movement.', 'Return the weight to the pins and repeat.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Rack_Pulls/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Rack_Pulls/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Rear Leg Raises',
  'push',
  'beginner',
  NULL,
  'body_only',
  'stretching',
  ARRAY['Place yourself on your hands knees on an exercise mat. Your head should be looking forward and the bend of the knees should create a 90-degree angle between the hamstrings and the calves. This will be your starting position.', 'Extend one leg up and behind you. The knee and hip should both extend. Repeat for 5-10 repetitions, and then switch sides.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Rear_Leg_Raises/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Rear_Leg_Raises/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Recumbent Bike',
  NULL,
  'beginner',
  NULL,
  'machine',
  'cardio',
  ARRAY['To begin, seat yourself on the bike and adjust the seat to your height.', 'Select the desired option from the menu. You may have to start pedaling to turn it on. You can use the manual setting, or you can select a program to use. Typically, you can enter your age and weight to estimate the amount of calories burned during exercise. The level of resistance can be changed throughout the workout. The handles can be used to monitor your heart rate to help you stay at an appropriate intensity.', 'Recumbent bikes offer convenience, cardiovascular benefits, and have less impact than other activities. A 150 lb person will burn about 230 calories cycling at a moderate rate for 30 minutes, compared to 450 calories or more running.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Recumbent_Bike/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Recumbent_Bike/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Return Push from Stance',
  'push',
  'beginner',
  'compound',
  'other',
  'plyometrics',
  ARRAY['You will need a partner for this drill.', 'Begin in an athletic 2 or 3 point stance.', 'At the signal, move into a position to receive the pass from your partner.', 'Catch the medicine ball with both hands and immediately throw it back to your partner.', 'You can modify this drill by running different routes.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Return_Push_from_Stance/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Return_Push_from_Stance/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Reverse Band Bench Press',
  'push',
  'intermediate',
  'compound',
  'barbell',
  'powerlifting',
  ARRAY['Position a bench inside a power rack, with the bar set to the correct height. Begin by anchoring bands either to band pegs or to the top of the rack. Ensure that you will be position properly under the bands. Attach the other end to the barbell.', 'Lie on the bench, tuck your feet underneath you and arch your back. Using the bar to help support your weight, lift your shoulder off the bench and retract them, squeezing the shoulder blades together. Use your feet to drive your traps into the bench. Maintain this tight body position throughout the movement. However wide your grip, it should cover the ring on the bar.', 'Pull the bar out of the rack without protracting your shoulders. Focus on squeezing the bar and trying to pull it apart. Lower the bar to your lower chest or upper stomach. The bar, wrist, and elbow should stay in line at all times.', 'Pause when the barbell touches your torso, and then drive the bar up with as much force as possible. The elbows should be tucked in until lockout.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Reverse_Band_Bench_Press/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Reverse_Band_Bench_Press/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Reverse Band Box Squat',
  'push',
  'intermediate',
  'compound',
  'barbell',
  'powerlifting',
  ARRAY['Begin in a power rack with a box at the appropriate height behind you. Set up the bands either on band pegs or attached to the top of the rack, ensuring they will be directly above the bar during the squat. Attach the other end to the bar.', 'Begin by stepping under the bar and placing it across the back of the shoulders. Squeeze your shoulder blades together and rotate your elbows forward, attempting to bend the bar across your shoulders. Remove the bar from the rack, creating a tight arch in your lower back, and step back into position. Place your feet wider for more emphasis on the back, glutes, adductors, and hamstrings, or closer together for more quad development. Keep your head facing forward.', 'With your back, shoulders, and core tight, push your knees and butt out and you begin your descent. Sit back with your hips until you are seated on the box. Ideally, your shins should be perpendicular to the ground. Pause when you reach the box, and relax the hip flexors. Never bounce off of a box.', 'Keeping the weight on your heels and pushing your feet and knees out, drive upward off of the box as you lead the movement with your head. Continue upward, maintaining tightness head to toe. Use care to return the barbell to the rack.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Reverse_Band_Box_Squat/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Reverse_Band_Box_Squat/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Reverse Band Deadlift',
  'pull',
  'expert',
  'compound',
  'barbell',
  'powerlifting',
  ARRAY['Set the bar up in a power rack. Attach bands to the top of the rack, using either bands pegs or the frame itself. Attach the other end of the bands to the bar.', 'Approach the bar so that it is centered over your feet. You feet should be about hip width apart. Bend at the hip to grip the bar at shoulder width, allowing your shoulder blades to protract. Typically, you would use an overhand grip or an over/under grip on heavier sets.', 'With your feet, and your grip set, take a big breath and then lower your hips and bend the knees until your shins contact the bar. Look forward with your head, keep your chest up and your back arched, and begin driving through the heels to move the weight upward.', 'After the bar passes the knees, aggressively pull the bar back, pulling your shoulder blades together as you drive your hips forward into the bar.', 'Lower the bar by bending at the hips and guiding it to the floor.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Reverse_Band_Deadlift/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Reverse_Band_Deadlift/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Reverse Band Power Squat',
  'push',
  'expert',
  'compound',
  'barbell',
  'powerlifting',
  ARRAY['Begin in a power rack with the pins and bar set at the appropriate height. After loading the bar, attach bands to the top of the rack, using either pegs or the frame itself. Attach the other end of the bands to the bar.', 'Begin by stepping under the bar and placing it across the back of the shoulders. Squeeze your shoulder blades together and rotate your elbows forward, attempting to bend the bar across your shoulders. Remove the bar from the rack, creating a tight arch in your lower back, and step back into position. Place your feet wide for more emphasis on the back, glutes, adductors, and hamstrings.', 'Keep your head facing forward. With your back, shoulders, and core tight, push your knees and butt out and you begin your descent. Sit back with your hips as much as possible. Ideally, your shins should be perpendicular to the ground. Lower bar position necessitates a greater torso lean to keep the bar over the heels. Continue until you break parallel, which is defined as the crease of the hip being in line with the top of the knee.', 'Keeping the weight on your heels and pushing your feet and knees out, drive upward as you lead the movement with your head. Continue upward, maintaining tightness head to toe, until you have returned to the starting position.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Reverse_Band_Power_Squat/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Reverse_Band_Power_Squat/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Reverse Band Sumo Deadlift',
  'pull',
  'expert',
  'compound',
  'barbell',
  'powerlifting',
  ARRAY['Begin with a bar loaded on the floor inside of a power rack. Attach bands to the top of the rack, using either pegs or the frame itself. Attach the other end to the barbell.', 'Approach the bar so that the bar intersects the middle of the feet. The feet should be set very wide, near the collars. Bend at the hips to grip the bar. The arms should be directly below the shoulders, inside the legs, and you can use a pronated grip, a mixed grip, or hook grip. Relax the shoulders, which in effect lengthens your arms.', 'Take a breath, and then lower your hips, looking forward with your head with your chest up. Drive through the floor, spreading your feet apart, with your weight on the back half of your feet. Extend through the hips and knees.', 'As the bar passes through the knees, lean back and drive the hips into the bar, pulling your shoulder blades together.', 'Return the weight to the ground by bending at the hips and controlling the weight on the way down.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Reverse_Band_Sumo_Deadlift/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Reverse_Band_Sumo_Deadlift/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Reverse Barbell Curl',
  'pull',
  'beginner',
  'isolation',
  'barbell',
  'strength',
  ARRAY['Stand up with your torso upright while holding a barbell at shoulder width with the elbows close to the torso. The palm of your hands should be facing down (pronated grip). This will be your starting position.', 'While holding the upper arms stationary, curl the weights while contracting the biceps as you breathe out. Only the forearms should move. Continue the movement until your biceps are fully contracted and the bar is at shoulder level. Hold the contracted position for a second as you squeeze the muscle.', 'Slowly begin to bring the bar back to starting position as your breathe in.', 'Repeat for the recommended amount of repetitions.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Reverse_Barbell_Curl/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Reverse_Barbell_Curl/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Reverse Barbell Preacher Curls',
  'pull',
  'intermediate',
  'isolation',
  'barbell',
  'strength',
  ARRAY['Grab an EZ-bar using a shoulder width and palms down (pronated) grip.', 'Now place the upper part of both arms on top of the preacher bench and have your arms extended. This will be your starting position.', 'As you exhale, use the biceps to curl the weight up until your biceps are fully contracted and the barbell is at shoulder height. Squeeze the biceps hard for a second at the contracted position.', 'As you breathe in, slowly lower the barbell until your upper arms are extended and the biceps is fully stretched.', 'Repeat for the recommended amount of repetitions.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Reverse_Barbell_Preacher_Curls/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Reverse_Barbell_Preacher_Curls/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Reverse Cable Curl',
  'pull',
  'beginner',
  'isolation',
  'cable',
  'strength',
  ARRAY['Stand up with your torso upright while holding a bar attachment that is attached to a low pulley using a pronated (palms down) and shoulder width grip. Make sure also that you keep the elbows close to the torso. This will be your starting position.', 'While holding the upper arms stationary, curl the weights while contracting the biceps as you breathe out. Only the forearms should move. Continue the movement until your biceps are fully contracted and the bar is at shoulder level. Hold the contracted position for a second as you squeeze the muscle.', 'Slowly begin to bring the bar back to starting position as your breathe in.', 'Repeat for the recommended amount of repetitions.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Reverse_Cable_Curl/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Reverse_Cable_Curl/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Reverse Crunch',
  'pull',
  'beginner',
  'isolation',
  'body_only',
  'strength',
  ARRAY['Lie down on the floor with your legs fully extended and arms to the side of your torso with the palms on the floor. Your arms should be stationary for the entire exercise.', 'Move your legs up so that your thighs are perpendicular to the floor and feet are together and parallel to the floor. This is the starting position.', 'While inhaling, move your legs towards the torso as you roll your pelvis backwards and you raise your hips off the floor. At the end of this movement your knees will be touching your chest.', 'Hold the contraction for a second and move your legs back to the starting position while exhaling.', 'Repeat for the recommended amount of repetitions.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Reverse_Crunch/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Reverse_Crunch/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Reverse Flyes',
  'pull',
  'beginner',
  'isolation',
  'dumbbell',
  'strength',
  ARRAY['To begin, lie down on an incline bench with the chest and stomach pressing against the incline. Have the dumbbells in each hand with the palms facing each other (neutral grip).', 'Extend the arms in front of you so that they are perpendicular to the angle of the bench. The legs should be stationary while applying pressure with the ball of your toes. This is the starting position.', 'Maintaining the slight bend of the elbows, move the weights out and away from each other (to the side) in an arc motion while exhaling. Tip: Try to squeeze your shoulder blades together to get the best results from this exercise.', 'The arms should be elevated until they are parallel to the floor.', 'Feel the contraction and slowly lower the weights back down to the starting position while inhaling.', 'Repeat for the recommended amount of repetitions.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Reverse_Flyes/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Reverse_Flyes/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Reverse Flyes With External Rotation',
  'pull',
  'intermediate',
  'isolation',
  'dumbbell',
  'strength',
  ARRAY['To begin, lie down on an incline bench set at a 30-degree angle with the chest and stomach pressing against the incline.', 'Have the dumbbells in each hand with the palms facing down to the floor. Your arms should be in front of you so that they are perpendicular to the angle of the bench. Tip: Your elbows should have a slight bend. The legs should be stationary while applying pressure with the ball of your toes (your heels should not be touching the floor). This is the starting position.', 'Maintaining the slight bend of the elbows, move the weights out and away from each other in an arc motion while exhaling.', 'As you lift the weight, your wrist should externally rotate by 90-degrees so that you go from a palms down (pronated) grip to a palms facing each other (neutral) grip. Tip: Try to squeeze your shoulder blades together to get the best results from this exercise.', 'The arms should be elevated until they are level with the head.', 'Feel the contraction and slowly lower the weights back down to the starting position while inhaling.', 'Repeat for the recommended amount of repetitions.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Reverse_Flyes_With_External_Rotation/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Reverse_Flyes_With_External_Rotation/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Reverse Grip Bent-Over Rows',
  'pull',
  'intermediate',
  'compound',
  'barbell',
  'strength',
  ARRAY['Stand erect while holding a barbell with a supinated grip (palms facing up).', 'Bend your knees slightly and bring your torso forward, by bending at the waist, while keeping the back straight until it is almost parallel to the floor. Tip: Make sure that you keep the head up. The barbell should hang directly in front of you as your arms hang perpendicular to the floor and your torso. This is your starting position.', 'While keeping the torso stationary, lift the barbell as you breathe out, keeping the elbows close to the body and not doing any force with the forearm other than holding the weights. On the top contracted position, squeeze the back muscles and hold for a second.', 'Slowly lower the weight again to the starting position as you inhale.', 'Repeat for the recommended amount of repetitions.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Reverse_Grip_Bent-Over_Rows/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Reverse_Grip_Bent-Over_Rows/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Reverse Grip Triceps Pushdown',
  'push',
  'beginner',
  'isolation',
  'cable',
  'strength',
  ARRAY['Start by setting a bar attachment (straight or e-z) on a high pulley machine.', 'Facing the bar attachment, grab it with the palms facing up (supinated grip) at shoulder width. Lower the bar by using your lats until your arms are fully extended by your sides. Tip: Elbows should be in by your sides and your feet should be shoulder width apart from each other. This is the starting position.', 'Slowly elevate the bar attachment up as you inhale so it is aligned with your chest. Only the forearms should move and the elbows/upper arms should be stationary by your side at all times.', 'Then begin to lower the cable bar back down to the original staring position while exhaling and contracting the triceps hard.', 'Repeat for the recommended amount of repetitions.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Reverse_Grip_Triceps_Pushdown/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Reverse_Grip_Triceps_Pushdown/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Reverse Hyperextension',
  'pull',
  'intermediate',
  NULL,
  'machine',
  'strength',
  ARRAY['Place your feet between the pads after loading an appropriate weight. Lay on the top pad, allowing your hips to hang off the back, while grasping the handles to hold your position.', 'To begin the movement, flex the hips, pulling the legs forward.', 'Reverse the motion by extending the hips, kicking the leg back. It is very important not to over-extend the hip on this movement, stopping short of your full range of motion.', 'Return by again flexing the hip, pulling the carriage forward as far as you can.', 'Repeat for the desired number of repetitions.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Reverse_Hyperextension/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Reverse_Hyperextension/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Reverse Machine Flyes',
  'pull',
  'beginner',
  'isolation',
  'machine',
  'strength',
  ARRAY['Adjust the handles so that they are fully to the rear. Make an appropriate weight selection and adjust the seat height so the handles are at shoulder level. Grasp the handles with your hands facing inwards. This will be your starting position.', 'In a semicircular motion, pull your hands out to your side and back, contracting your rear delts.', 'Keep your arms slightly bent throughout the movement, with all of the motion occurring at the shoulder joint.', 'Pause at the rear of the movement, and slowly return the weight to the starting position.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Reverse_Machine_Flyes/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Reverse_Machine_Flyes/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Reverse Plate Curls',
  'pull',
  'beginner',
  'isolation',
  'other',
  'strength',
  ARRAY['Start by standing straight with a weighted plate held by both hands and arms fully extended. Use a pronated grip (palms facing down) and make sure your fingers grab the rough side of the plate while your thumb grabs the smooth side. Note: For the best results, grab the weighted plate at an 11:00 and 1:00 o''clock position.', 'Your feet should be shoulder width apart from each other and the weighted plate should be near the groin area. This is the starting position.', 'Slowly lift the plate up while keeping the elbows in and the upper arms stationary until your biceps and forearms touch while exhaling. The plate should be evenly aligned with your torso at this point.', 'Feel the contraction for a second and begin to lower the weight back down to the starting position while inhaling', 'Repeat for the recommended amount of repetitions.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Reverse_Plate_Curls/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Reverse_Plate_Curls/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Reverse Triceps Bench Press',
  'push',
  'intermediate',
  'compound',
  'barbell',
  'strength',
  ARRAY['Lie back on a flat bench. Using a close, supinated grip (around shoulder width), lift the bar from the rack and hold it straight over you with your arms locked extended in front of you and perpendicular to the floor. This will be your starting position.', 'As you breathe in, come down slowly until you feel the bar on your middle chest. Tip: Make sure that as opposed to a regular bench press, you keep the elbows close to the torso at all times in order to maximize triceps involvement.', 'After a second pause, bring the bar back to the starting position as you breathe out and push the bar using your triceps muscles. Lock your arms in the contracted position, hold for a second and then start coming down slowly again. Tip: It should take at least twice as long to go down than to come up.', 'Repeat the movement for the prescribed amount of repetitions.', 'When you are done, place the bar back in the rack.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Reverse_Triceps_Bench_Press/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Reverse_Triceps_Bench_Press/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Rhomboids-SMR',
  'static',
  'intermediate',
  NULL,
  'other',
  'stretching',
  ARRAY['Lay down with your back on the floor. Place a foam roll underneath your upper back, and cross your arms in front of you, protracting your shoulders. This will be your starting position.', 'Raise your hips off of the ground, placing your weight onto the foam roll. Shift your weight to one side at a time, rolling over your middle and upper back. Pause at points of tension for 10-30 seconds.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Rhomboids-SMR/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Rhomboids-SMR/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Rickshaw Carry',
  NULL,
  'intermediate',
  'compound',
  'other',
  'strongman',
  ARRAY['Position the frame at the starting point, and load with the appropriate weight. Standing in the center of the frame, begin by gripping the handles and driving through your heels to lift the frame. Ensure your chest and head are up and your back is straight.', 'Immediately begin walking briskly with quick, controlled steps. Keep your chest up and head forward, and make sure you continue breathing. Bring the frame to the ground after you have reached the end point.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Rickshaw_Carry/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Rickshaw_Carry/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Rickshaw Deadlift',
  'pull',
  'intermediate',
  'compound',
  'other',
  'strongman',
  ARRAY['Load the frame with the desired weight. Center yourself between the handles. You feet should be about hip width apart. Bend at the hips to grip the handles, allowing your shoulder blades to protract.', 'With your feet and your grip set, take a big breath and then lower your hips and flex the knees. Look forward with your head, keep your chest up and your back arched, and begin driving through the heels to move the weight upward. As the weight comes up, pull your shoulder blades together as you drive your hips forward.', 'Lower the weight by bending at the hips and guiding it to the ground.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Rickshaw_Deadlift/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Rickshaw_Deadlift/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;
INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)
VALUES (
  gen_random_uuid(),
  'Ring Dips',
  'push',
  'intermediate',
  'compound',
  'other',
  'strength',
  ARRAY['Grip a ring in each hand, and then take a small jump to help you get into the starting position with your arms locked out.', 'Begin by flexing the elbow, lowering your body until your arms break 90 degrees. Avoid swinging, and maintain good posture throughout the descent.', 'Reverse the motion by extending the elbow, pushing yourself back up into the starting position.', 'Repeat for the desired number of repetitions.'],
  ARRAY['https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Ring_Dips/0.jpg', 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Ring_Dips/1.jpg'],
  false,
  NULL
) ON CONFLICT DO NOTHING;