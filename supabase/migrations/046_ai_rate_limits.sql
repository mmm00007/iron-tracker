-- Migration 046: Persistent AI rate limiting
-- Replaces in-memory Python dicts that reset on every dyno restart.
-- Uses atomic upsert for thread-safe, crash-proof rate limiting.

CREATE TABLE IF NOT EXISTS ai_rate_limits (
  user_id   UUID    NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  endpoint  TEXT    NOT NULL,  -- 'identify' or 'analyze'
  day       DATE    NOT NULL DEFAULT CURRENT_DATE,
  count     INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (user_id, endpoint, day)
);

-- RLS: users can only read their own rate limit entries (backend uses service role)
ALTER TABLE ai_rate_limits ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own rate limits"
  ON ai_rate_limits FOR SELECT
  USING (user_id = auth.uid());

-- Auto-cleanup: delete entries older than 7 days to prevent unbounded growth.
-- Run via pg_cron or application-level cleanup.
CREATE INDEX IF NOT EXISTS ai_rate_limits_day_idx ON ai_rate_limits (day);

COMMENT ON TABLE ai_rate_limits IS 'Persistent per-user daily AI request counters. Survives process restarts.';
