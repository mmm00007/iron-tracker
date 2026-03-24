-- Analysis reports: persistent AI training analysis

CREATE TABLE IF NOT EXISTS analysis_reports (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  scope_type text NOT NULL CHECK (scope_type IN ('day', 'week', 'month')),
  scope_start date NOT NULL,
  scope_end date NOT NULL,
  goals text[], -- e.g. ['strength', 'volume']
  summary text NOT NULL,
  insights jsonb NOT NULL DEFAULT '[]', -- array of {metric, finding, delta, recommendation}
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_analysis_reports_user_id ON analysis_reports(user_id);
CREATE INDEX IF NOT EXISTS idx_analysis_reports_created_at ON analysis_reports(created_at DESC);

ALTER TABLE analysis_reports ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read/create their own analysis reports"
  ON analysis_reports FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);
