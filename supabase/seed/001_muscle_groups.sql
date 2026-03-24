-- Muscle groups from wger fitness database
INSERT INTO muscle_groups (id, name, name_latin, is_front, svg_path_id) VALUES
  (1, 'biceps', 'biceps brachii', true, 'muscle-1'),
  (2, 'shoulders', 'deltoideus', true, 'muscle-2'),
  (3, 'triceps', 'triceps brachii', false, 'muscle-3'),
  (4, 'chest', 'pectoralis major', true, 'muscle-4'),
  (5, 'forearms', 'flexores antebrachii', true, 'muscle-5'),
  (7, 'calves', 'gastrocnemius', false, 'muscle-7'),
  (8, 'glutes', 'glutaeus maximus', false, 'muscle-8'),
  (9, 'traps', 'trapezius', false, 'muscle-9'),
  (10, 'abs', 'rectus abdominis', true, 'muscle-10'),
  (11, 'hamstrings', 'biceps femoris', false, 'muscle-11'),
  (12, 'lats', 'latissimus dorsi', false, 'muscle-12'),
  (13, 'lower back', 'erector spinae', false, 'muscle-13'),
  (14, 'neck', 'sternocleidomastoid', true, 'muscle-14'),
  (15, 'quadriceps', 'quadriceps femoris', true, 'muscle-15'),
  (16, 'adductors', 'adductor magnus', true, 'muscle-16')
ON CONFLICT (id) DO NOTHING;
