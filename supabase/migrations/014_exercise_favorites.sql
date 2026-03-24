-- Exercise favorites: users can favorite exercises for quick access

CREATE TABLE IF NOT EXISTS exercise_favorites (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  exercise_id uuid NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
  notes text,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, exercise_id)
);

CREATE INDEX IF NOT EXISTS idx_exercise_favorites_user_id ON exercise_favorites(user_id);

ALTER TABLE exercise_favorites ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can CRUD their own favorites"
  ON exercise_favorites FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);
