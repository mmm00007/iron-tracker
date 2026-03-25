-- Add missing index on soreness_reports for recovery service queries.
-- The recovery service filters by (user_id, reported_at >= $2) and orders
-- by reported_at DESC, which requires a sequential scan without this index.

CREATE INDEX IF NOT EXISTS soreness_reports_user_reported_idx
  ON soreness_reports (user_id, reported_at DESC);
