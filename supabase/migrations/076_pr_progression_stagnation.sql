-- Migration 076: PR Progression Timeline + Stagnation Detection
-- Adds analytics over personal_records history: trajectory, momentum,
-- and stagnation detection per (user, exercise) combination.
--
-- Existing personal_records keeps the BEST record per (user, exercise, type,
-- reps, context). But users also want to see HOW they got there and whether
-- they're currently stuck. This migration builds a time-series interpretation.
--
-- Validated by: data-science-expert (stagnation thresholds)
--
-- Key design decisions:
--   - pr_progression_timeline: all historical PRs per exercise (each beat of
--     the previous PR creates a new row; see pr_events below for raw events)
--   - pr_events: materialized history table populated from sets on insert
--     via trigger (new migration, supplements personal_records which tracks
--     only the current best)
--   - stagnation threshold: 8+ weeks without a new PR = stagnating
--     (evidence: Schoenfeld 2017 - typical intermediate lifters PR every 4-8w)
--   - Recovery thresholds hardcoded here; could move to per-user settings later

BEGIN;

-- =============================================================================
-- 1. pr_events: historical record of EVERY PR (not just current best)
-- =============================================================================
-- Append-only log. When a user achieves a new PR on (exercise, record_type,
-- rep_count, pr_context), we write a new row here (even though personal_records
-- overwrites). This enables timeline/trajectory analytics.

CREATE TABLE IF NOT EXISTS pr_events (
  id               uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id          uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  exercise_id      uuid        NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
  variant_id       uuid        REFERENCES equipment_variants(id) ON DELETE SET NULL,
  record_type      text        NOT NULL
    CHECK (record_type IN ('estimated_1rm','rep_max','max_weight','max_volume')),
  rep_count        integer,
  pr_context       text        NOT NULL DEFAULT 'straight',
  value            numeric     NOT NULL,
  previous_value   numeric,
  delta            numeric     GENERATED ALWAYS AS (value - COALESCE(previous_value, 0)) STORED,
  delta_pct        numeric     GENERATED ALWAYS AS (
    CASE
      WHEN previous_value IS NULL OR previous_value = 0 THEN NULL
      ELSE ROUND(((value - previous_value) / previous_value * 100)::numeric, 2)
    END
  ) STORED,
  set_id           uuid        REFERENCES sets(id) ON DELETE SET NULL,
  body_weight_at_event numeric(5,2),
  achieved_at      timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE pr_events IS
  'Append-only log of PR beats. Every new PR on (user, exercise, record_type, '
  'reps, context) writes a row here, even as personal_records overwrites. '
  'Enables trajectory analytics — personal_records tracks the current best; '
  'this tracks the full timeline.';

COMMENT ON COLUMN pr_events.delta IS
  'Generated: value - previous_value. How much the PR improved by (in kg/lb of value).';

COMMENT ON COLUMN pr_events.delta_pct IS
  'Generated: percentage improvement over previous PR. NULL for first PR.';

CREATE INDEX IF NOT EXISTS pr_events_user_exercise_achieved_idx
  ON pr_events (user_id, exercise_id, achieved_at DESC);

CREATE INDEX IF NOT EXISTS pr_events_user_achieved_idx
  ON pr_events (user_id, achieved_at DESC);

-- Composite index for stagnation queries (most recent PR per user/exercise)
CREATE INDEX IF NOT EXISTS pr_events_latest_per_exercise_idx
  ON pr_events (user_id, exercise_id, record_type, pr_context, achieved_at DESC);

ALTER TABLE pr_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY pr_events_select ON pr_events
  FOR SELECT TO authenticated USING (user_id = auth.uid());

CREATE POLICY pr_events_insert ON pr_events
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());

CREATE POLICY pr_events_delete ON pr_events
  FOR DELETE TO authenticated USING (user_id = auth.uid());

-- pr_events is append-only — no UPDATE policy

-- =============================================================================
-- 2. pr_progression_timeline view
-- =============================================================================
-- Chronological PR timeline per (user, exercise, record_type, pr_context) with
-- cumulative delta and days-since-previous metrics.

CREATE OR REPLACE VIEW pr_progression_timeline
WITH (security_invoker = true) AS
SELECT
  pe.user_id,
  pe.exercise_id,
  pe.record_type,
  pe.pr_context,
  pe.rep_count,
  pe.achieved_at,
  pe.value,
  pe.previous_value,
  pe.delta,
  pe.delta_pct,
  pe.body_weight_at_event,
  -- Days since previous PR on same (exercise, record_type, context)
  EXTRACT(epoch FROM
    pe.achieved_at - LAG(pe.achieved_at) OVER (
      PARTITION BY pe.user_id, pe.exercise_id, pe.record_type, pe.pr_context
      ORDER BY pe.achieved_at
    )
  )::integer / 86400 AS days_since_previous_pr,
  -- Cumulative PR count
  COUNT(*) OVER (
    PARTITION BY pe.user_id, pe.exercise_id, pe.record_type, pe.pr_context
    ORDER BY pe.achieved_at
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS pr_sequence_number,
  -- Cumulative total improvement from first PR
  (pe.value - FIRST_VALUE(pe.value) OVER (
    PARTITION BY pe.user_id, pe.exercise_id, pe.record_type, pe.pr_context
    ORDER BY pe.achieved_at
  )) AS cumulative_delta
FROM pr_events pe;

COMMENT ON VIEW pr_progression_timeline IS
  'Chronological PR trajectory per exercise, with cumulative improvement + '
  'days-between-PRs. Powers "PR history" chart and trajectory visualizations.';

-- =============================================================================
-- 3. pr_stagnation_check: detect stuck exercises
-- =============================================================================
-- Returns user's exercises where they have not hit a PR in >= 8 weeks,
-- AND have trained that exercise in the last 4 weeks (so it's still active).

CREATE OR REPLACE FUNCTION detect_pr_stagnation(
  p_user_id uuid,
  p_stagnation_weeks integer DEFAULT 8,
  p_active_window_weeks integer DEFAULT 4
)
RETURNS TABLE (
  exercise_id uuid,
  exercise_name text,
  record_type text,
  pr_context text,
  current_pr_value numeric,
  last_pr_achieved_at timestamptz,
  weeks_since_last_pr integer,
  working_sets_in_active_window integer,
  stagnation_severity text
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, pg_catalog
AS $$
  WITH latest_prs AS (
    SELECT DISTINCT ON (pe.exercise_id, pe.record_type, pe.pr_context)
      pe.exercise_id, pe.record_type, pe.pr_context, pe.value, pe.achieved_at
    FROM pr_events pe
    WHERE pe.user_id = p_user_id
    ORDER BY pe.exercise_id, pe.record_type, pe.pr_context, pe.achieved_at DESC
  ),
  active_exercises AS (
    SELECT
      s.exercise_id,
      COUNT(*) FILTER (WHERE s.set_type = 'working')::integer AS active_working_sets
    FROM sets s
    WHERE s.user_id = p_user_id
      AND s.training_date >= CURRENT_DATE - (p_active_window_weeks * 7)
      AND s.training_date <= CURRENT_DATE
    GROUP BY s.exercise_id
  )
  SELECT
    lp.exercise_id,
    e.name,
    lp.record_type,
    lp.pr_context,
    lp.value,
    lp.achieved_at,
    (CURRENT_DATE - lp.achieved_at::date) / 7 AS weeks_since,
    COALESCE(ae.active_working_sets, 0),
    CASE
      WHEN (CURRENT_DATE - lp.achieved_at::date) / 7 >= (p_stagnation_weeks * 2) THEN 'severe'
      WHEN (CURRENT_DATE - lp.achieved_at::date) / 7 >= (p_stagnation_weeks + 4) THEN 'prolonged'
      ELSE 'mild'
    END
  FROM latest_prs lp
  JOIN exercises e ON e.id = lp.exercise_id
  INNER JOIN active_exercises ae ON ae.exercise_id = lp.exercise_id
  WHERE (CURRENT_DATE - lp.achieved_at::date) / 7 >= p_stagnation_weeks
    AND lp.record_type = 'estimated_1rm'
    AND lp.pr_context = 'straight'
  ORDER BY (CURRENT_DATE - lp.achieved_at::date) DESC;
$$;

COMMENT ON FUNCTION detect_pr_stagnation(uuid, integer, integer) IS
  'Returns exercises where user has not hit a straight-set e1RM PR in N weeks '
  'AND still actively training (working sets in last M weeks). Severity bands: '
  'mild (>= N weeks), prolonged (>= N+4), severe (>= 2N).';

-- =============================================================================
-- 4. pr_momentum_summary view: rate of PR-making per exercise
-- =============================================================================
-- Aggregate view: for each (user, exercise), how many PRs in last 30/90/365 days.
-- High momentum = frequent PRs = currently progressing well.

CREATE OR REPLACE VIEW pr_momentum_summary
WITH (security_invoker = true) AS
SELECT
  pe.user_id,
  pe.exercise_id,
  COUNT(*) FILTER (WHERE pe.achieved_at >= CURRENT_DATE - interval '30 days') AS prs_last_30d,
  COUNT(*) FILTER (WHERE pe.achieved_at >= CURRENT_DATE - interval '90 days') AS prs_last_90d,
  COUNT(*) FILTER (WHERE pe.achieved_at >= CURRENT_DATE - interval '365 days') AS prs_last_365d,
  COUNT(*) AS total_prs,
  MAX(pe.achieved_at) AS most_recent_pr_at,
  MIN(pe.achieved_at) AS first_pr_at,
  -- Average gap between PRs in days
  CASE
    WHEN COUNT(*) < 2 THEN NULL
    ELSE (EXTRACT(epoch FROM MAX(pe.achieved_at) - MIN(pe.achieved_at))::integer / 86400) / NULLIF(COUNT(*) - 1, 0)
  END::integer AS avg_days_between_prs
FROM pr_events pe
WHERE pe.record_type = 'estimated_1rm'
  AND pe.pr_context = 'straight'
GROUP BY pe.user_id, pe.exercise_id;

COMMENT ON VIEW pr_momentum_summary IS
  'Per-exercise PR-making momentum: counts in 30/90/365 day windows + avg gap. '
  'High momentum = frequent PRs. Low momentum (or stagnation) triggers coaching.';

-- =============================================================================
-- 5. Trigger: auto-record pr_events when personal_records is INSERTed
-- =============================================================================
-- When personal_records gets a new row (backend PR-detection cron found a PR),
-- log it to pr_events with the previous PR's value captured.

CREATE OR REPLACE FUNCTION record_pr_event()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_catalog
AS $$
DECLARE
  v_previous_value numeric;
  v_body_weight numeric;
BEGIN
  -- Find the most recent PR of same shape (minus the current one) to get previous_value
  SELECT pe.value INTO v_previous_value
  FROM pr_events pe
  WHERE pe.user_id = NEW.user_id
    AND pe.exercise_id = NEW.exercise_id
    AND pe.record_type = NEW.record_type
    AND COALESCE(pe.variant_id::text, '') = COALESCE(NEW.variant_id::text, '')
    AND COALESCE(pe.rep_count, -1) = COALESCE(NEW.rep_count, -1)
    AND COALESCE(pe.pr_context, 'straight') = COALESCE(NEW.pr_context, 'straight')
  ORDER BY pe.achieved_at DESC
  LIMIT 1;

  v_body_weight := NEW.body_weight_at_record;

  INSERT INTO pr_events (
    user_id, exercise_id, variant_id, record_type, rep_count, pr_context,
    value, previous_value, set_id, body_weight_at_event, achieved_at
  ) VALUES (
    NEW.user_id, NEW.exercise_id, NEW.variant_id,
    NEW.record_type, NEW.rep_count, COALESCE(NEW.pr_context, 'straight'),
    NEW.value, v_previous_value, NEW.set_id, v_body_weight, NEW.achieved_at
  );

  RETURN NEW;
END;
$$;

COMMENT ON FUNCTION record_pr_event() IS
  'Trigger function: auto-logs pr_events row when personal_records gains a new '
  'PR. Captures previous PR value for delta computation.';

CREATE TRIGGER personal_records_log_event
  AFTER INSERT ON personal_records
  FOR EACH ROW
  EXECUTE FUNCTION record_pr_event();

COMMIT;
