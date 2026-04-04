-- Migration 057: Missing Composite Indexes for Analytics Queries
-- Adds indexes identified by the database schema audit as beneficial
-- for analytical/dashboard queries that currently rely on seq scans.
--
-- All CREATE INDEX IF NOT EXISTS — safe to re-run.

-- Analysis reports: fast period-scoped queries ("all week reports for Jan 2025")
-- Currently only has user_id and created_at indexes; this composite index
-- covers the common (user_id, scope_type, scope_start) query pattern.
CREATE INDEX IF NOT EXISTS analysis_reports_user_scope_start_idx
  ON analysis_reports (user_id, scope_type, scope_start DESC);

-- Training milestones: fast per-exercise milestone lookup
-- Currently only has (user_id, achieved_at) index; this covers
-- "show all milestones for exercise X" which the frontend detail view needs.
CREATE INDEX IF NOT EXISTS training_milestones_user_exercise_idx
  ON training_milestones (user_id, exercise_id, achieved_at DESC)
  WHERE exercise_id IS NOT NULL;

-- Exercise effectiveness scores: fast trending queries
-- Used by compute_substitution_patterns to assess progression readiness.
CREATE INDEX IF NOT EXISTS exercise_effectiveness_user_period_idx
  ON exercise_effectiveness_scores (user_id, period_end DESC);

-- Exercise warmup prerequisites: fast lookup by exercise
-- "What warmup exercises should I do before bench press?"
CREATE INDEX IF NOT EXISTS exercise_warmup_exercise_idx
  ON exercise_warmup_prerequisites (exercise_id);
