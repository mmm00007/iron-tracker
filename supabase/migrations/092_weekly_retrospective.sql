-- Migration 092: Weekly Retrospective Synthesis
-- Aggregates ALL training analytics into a single per-user-per-week row.
-- Powers Sunday summary / weekly email / "how'd I do?" dashboard card.
--
-- Composes: sets, session_quality_scores, workload_metrics,
-- weekly_volume_snapshots, pr_events, workout_feedback,
-- exercise_this_week_vs_pr, consistency_vs_baseline.
--
-- Validated by: ux-ui-specialist (summary format), data-science-expert
--
-- Key design decisions:
--   - Only COMPLETED weeks (Monday to Sunday, past, not current).
--   - Surfaces EVENT-LEVEL stats (PRs, streak changes) + AGGREGATE
--     metrics (avg quality, volume, sets) for narrative generation.
--   - Week-over-week deltas where meaningful.
--   - Generated narrative fragments in JSONB for frontend flexibility.

BEGIN;

-- =============================================================================
-- weekly_retrospective view
-- =============================================================================

CREATE OR REPLACE VIEW weekly_retrospective
WITH (security_invoker = true) AS
WITH week_bounds AS (
  -- Generate all (user, week_start) pairs from user's training history
  SELECT DISTINCT
    s.user_id,
    date_trunc('week', s.training_date)::date AS week_start,
    (date_trunc('week', s.training_date) + interval '6 days')::date AS week_end
  FROM sets s
  WHERE s.training_date IS NOT NULL
    AND s.training_date < date_trunc('week', CURRENT_DATE)::date
    AND s.training_date >= date_trunc('week', CURRENT_DATE)::date - interval '90 days'
),
week_sets AS (
  SELECT
    wb.user_id, wb.week_start, wb.week_end,
    COUNT(*) FILTER (WHERE s.set_type = 'working')::integer AS working_sets,
    COUNT(DISTINCT s.training_date)::integer AS training_days,
    COUNT(DISTINCT s.exercise_id)::integer AS distinct_exercises,
    SUM(s.weight * s.reps) FILTER (WHERE s.set_type = 'working')::numeric(10,1) AS total_volume_kg,
    AVG(s.rpe) FILTER (WHERE s.set_type = 'working' AND s.rpe IS NOT NULL)::numeric(3,1) AS avg_rpe
  FROM week_bounds wb
  LEFT JOIN sets s ON s.user_id = wb.user_id AND s.training_date BETWEEN wb.week_start AND wb.week_end
  GROUP BY wb.user_id, wb.week_start, wb.week_end
),
week_quality AS (
  SELECT
    wb.user_id, wb.week_start,
    AVG(sqs.quality_score)::numeric(4,1) AS avg_quality_score,
    MAX(sqs.quality_score)::numeric(4,1) AS best_quality_score,
    COUNT(*)::integer AS sessions_scored
  FROM week_bounds wb
  LEFT JOIN session_quality_scores sqs
    ON sqs.user_id = wb.user_id AND sqs.training_date BETWEEN wb.week_start AND wb.week_end
  GROUP BY wb.user_id, wb.week_start
),
week_prs AS (
  SELECT
    wb.user_id, wb.week_start,
    COUNT(*) FILTER (WHERE pe.record_type = 'estimated_1rm')::integer AS e1rm_prs,
    COUNT(*) FILTER (WHERE pe.record_type = 'max_weight')::integer AS weight_prs,
    COUNT(pe.id)::integer AS total_prs  -- COUNT(pe.id) ignores NULLs from LEFT JOIN
  FROM week_bounds wb
  LEFT JOIN pr_events pe
    ON pe.user_id = wb.user_id
    AND pe.achieved_at::date BETWEEN wb.week_start AND wb.week_end
  GROUP BY wb.user_id, wb.week_start
),
week_feedback AS (
  SELECT
    wb.user_id, wb.week_start,
    AVG(wf.sleep_hours)::numeric(3,1) AS avg_sleep_hours,
    AVG(wf.session_rpe)::numeric(3,1) AS avg_session_rpe,
    AVG(wf.readiness_score)::numeric(3,1) AS avg_readiness,
    AVG(wf.stress_level)::numeric(3,1) AS avg_stress
  FROM week_bounds wb
  LEFT JOIN workout_feedback wf
    ON wf.user_id = wb.user_id AND wf.training_date BETWEEN wb.week_start AND wb.week_end
  GROUP BY wb.user_id, wb.week_start
)
SELECT
  ws.user_id,
  ws.week_start,
  ws.week_end,
  ws.training_days,
  ws.working_sets,
  ws.distinct_exercises,
  ws.total_volume_kg,
  ws.avg_rpe,
  wq.avg_quality_score,
  wq.best_quality_score,
  wq.sessions_scored,
  COALESCE(wp.total_prs, 0) AS prs_this_week,
  COALESCE(wp.e1rm_prs, 0) AS e1rm_prs_this_week,
  wf.avg_sleep_hours,
  wf.avg_session_rpe,
  wf.avg_readiness,
  wf.avg_stress,
  -- Composite "grade" for the week
  CASE
    WHEN ws.training_days = 0 THEN 'rest_week'
    WHEN COALESCE(wp.total_prs, 0) >= 2 AND wq.avg_quality_score >= 75 THEN 'breakthrough'
    WHEN COALESCE(wp.total_prs, 0) >= 1 AND wq.avg_quality_score >= 65 THEN 'great'
    WHEN wq.avg_quality_score >= 70 AND ws.training_days >= 3 THEN 'solid'
    WHEN wq.avg_quality_score >= 55 AND ws.training_days >= 2 THEN 'moderate'
    WHEN ws.training_days >= 1 THEN 'light'
    ELSE 'rest_week'
  END AS week_grade,
  -- Narrative JSONB with user-facing snippets
  jsonb_build_object(
    'headline', CASE
      WHEN ws.training_days = 0 THEN 'Rest week — no training logged'
      WHEN COALESCE(wp.total_prs, 0) >= 2 THEN
        COALESCE(wp.total_prs, 0)::text || ' PRs this week!'
      WHEN ws.training_days >= 5 THEN
        'High-volume week: ' || ws.training_days || ' training days'
      WHEN wq.avg_quality_score >= 75 THEN
        'Strong sessions — ' || wq.avg_quality_score || ' avg quality'
      ELSE
        ws.training_days || ' training days, ' || ws.working_sets || ' working sets'
    END,
    'volume_note', CASE
      WHEN ws.total_volume_kg >= 10000 THEN 'Huge tonnage: ' || ROUND(ws.total_volume_kg/1000.0, 1) || ' tonnes'
      WHEN ws.total_volume_kg >= 5000 THEN 'Good tonnage: ' || ROUND(ws.total_volume_kg/1000.0, 1) || ' tonnes'
      WHEN ws.total_volume_kg > 0 THEN ws.total_volume_kg || ' kg total volume'
      ELSE NULL
    END,
    'sleep_note', CASE
      WHEN wf.avg_sleep_hours IS NULL THEN NULL
      WHEN wf.avg_sleep_hours >= 7.5 THEN 'Well-rested: ' || wf.avg_sleep_hours || 'h avg sleep'
      WHEN wf.avg_sleep_hours < 6.5 THEN 'Sleep-short: ' || wf.avg_sleep_hours || 'h avg — protect recovery'
      ELSE wf.avg_sleep_hours || 'h avg sleep'
    END,
    'pr_note', CASE
      WHEN COALESCE(wp.total_prs, 0) = 0 THEN NULL
      WHEN wp.total_prs = 1 THEN 'Set 1 PR this week'
      ELSE 'Set ' || wp.total_prs || ' PRs this week'
    END,
    'readiness_note', CASE
      WHEN wf.avg_readiness IS NULL THEN NULL
      WHEN wf.avg_readiness >= 4 THEN 'Felt ready (' || wf.avg_readiness || '/5)'
      WHEN wf.avg_readiness <= 2 THEN 'Pushed through fatigue (' || wf.avg_readiness || '/5)'
      ELSE 'Average readiness (' || wf.avg_readiness || '/5)'
    END
  ) AS narrative
FROM week_sets ws
LEFT JOIN week_quality wq ON wq.user_id = ws.user_id AND wq.week_start = ws.week_start
LEFT JOIN week_prs wp     ON wp.user_id = ws.user_id AND wp.week_start = ws.week_start
LEFT JOIN week_feedback wf ON wf.user_id = ws.user_id AND wf.week_start = ws.week_start;

COMMENT ON VIEW weekly_retrospective IS
  'Per-user per-week synthesis of training metrics. Surfaces week_grade '
  '(breakthrough/great/solid/moderate/light/rest_week) + narrative JSONB '
  'with headline/volume_note/sleep_note/pr_note/readiness_note. Powers '
  'Sunday summary + weekly retrospective UI. Only includes COMPLETED weeks.';

-- =============================================================================
-- Week-over-week delta view
-- =============================================================================

CREATE OR REPLACE VIEW weekly_retrospective_with_deltas
WITH (security_invoker = true) AS
SELECT
  wr.*,
  LAG(wr.training_days)     OVER (PARTITION BY wr.user_id ORDER BY wr.week_start) AS prev_week_training_days,
  LAG(wr.working_sets)      OVER (PARTITION BY wr.user_id ORDER BY wr.week_start) AS prev_week_working_sets,
  LAG(wr.total_volume_kg)   OVER (PARTITION BY wr.user_id ORDER BY wr.week_start) AS prev_week_volume_kg,
  LAG(wr.avg_quality_score) OVER (PARTITION BY wr.user_id ORDER BY wr.week_start) AS prev_week_avg_quality,
  LAG(wr.prs_this_week)     OVER (PARTITION BY wr.user_id ORDER BY wr.week_start) AS prev_week_prs,
  -- Deltas
  wr.training_days - LAG(wr.training_days) OVER (PARTITION BY wr.user_id ORDER BY wr.week_start) AS training_days_delta,
  wr.working_sets - LAG(wr.working_sets) OVER (PARTITION BY wr.user_id ORDER BY wr.week_start) AS working_sets_delta,
  ROUND((wr.total_volume_kg - LAG(wr.total_volume_kg) OVER (PARTITION BY wr.user_id ORDER BY wr.week_start))::numeric, 1) AS volume_delta_kg,
  ROUND((wr.avg_quality_score - LAG(wr.avg_quality_score) OVER (PARTITION BY wr.user_id ORDER BY wr.week_start))::numeric, 1) AS quality_delta
FROM weekly_retrospective wr;

COMMENT ON VIEW weekly_retrospective_with_deltas IS
  'weekly_retrospective + week-over-week deltas for training_days, '
  'working_sets, total_volume_kg, avg_quality_score, prs_this_week. '
  'Used for "this week vs last week" comparison UI.';

COMMIT;
