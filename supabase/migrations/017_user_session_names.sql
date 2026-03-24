-- Migration 017: User session names
-- Allows users to optionally name sessions (e.g., "Upper Body Day", "Leg Day")
-- Sessions remain derived from sets — this table only stores custom names.

CREATE TABLE IF NOT EXISTS user_session_names (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  session_start timestamptz NOT NULL,
  session_end timestamptz NOT NULL,
  name text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, session_start)
);

CREATE INDEX IF NOT EXISTS idx_session_names_user_id ON user_session_names(user_id);

ALTER TABLE user_session_names ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can CRUD their own session names"
  ON user_session_names FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);
