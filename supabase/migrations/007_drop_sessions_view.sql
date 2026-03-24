-- Migration 007: Drop dead sessions_view materialized view
--
-- The materialized view was never refreshed and is never queried.
-- Session grouping is derived client-side in sessionGrouping.ts.

DROP INDEX IF EXISTS sessions_view_user_session_idx;
DROP MATERIALIZED VIEW IF EXISTS sessions_view;
