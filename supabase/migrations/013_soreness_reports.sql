-- Soreness reports: track recovery per muscle group

CREATE TABLE IF NOT EXISTS soreness_reports (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  muscle_group_id integer NOT NULL REFERENCES muscle_groups(id),
  level smallint NOT NULL CHECK (level BETWEEN 0 AND 4), -- 0=none, 1=mild, 2=moderate, 3=severe, 4=extreme
  training_date date NOT NULL, -- which training session caused this
  reported_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, muscle_group_id, training_date)
);

CREATE INDEX IF NOT EXISTS idx_soreness_reports_user_id ON soreness_reports(user_id);
CREATE INDEX IF NOT EXISTS idx_soreness_reports_training_date ON soreness_reports(training_date);

ALTER TABLE soreness_reports ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can CRUD their own soreness reports"
  ON soreness_reports FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);
