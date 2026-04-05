-- Migration 068: Fixes for 063, 065, 067 (QA review findings)
-- Forward-only corrections identified during qa-reviewer pass.
--
-- Fixes:
--   1. ACWR formula in workload_metrics was dimensionally wrong
--      (dividing 7-day SUM by 28-day SUM produces 0.25x correct ratio).
--      Fix: divide chronic_28d_load by 4 to compare weekly averages.
--   2. body_weight_multiple on personal_records assumed kg, gave inflated
--      values for lb users. Fix: add pr_weight_unit column and normalize.
--   3. phase_adherence_check view was documented in 067 header but never
--      created. Fix: create it.
--
-- Validated by: qa-reviewer agent, data-science-expert

BEGIN;

-- =============================================================================
-- 1. FIX ACWR FORMULA (063)
-- =============================================================================
-- ACWR = acute weekly average / chronic weekly average.
-- acute_7d_load is a 7-day SUM = 1 weekly average worth.
-- chronic_28d_load is a 28-day SUM = 4 weekly averages worth.
-- Correct ratio: acute_7d_load / (chronic_28d_load / 4.0)
-- Source: Gabbett 2016, Hulin 2016 — ACWR compares WEEKLY rolling averages.

ALTER TABLE workload_metrics DROP COLUMN IF EXISTS risk_zone;
ALTER TABLE workload_metrics DROP COLUMN IF EXISTS acwr_ratio;

ALTER TABLE workload_metrics
  ADD COLUMN acwr_ratio numeric(4,2)
    GENERATED ALWAYS AS (
      CASE
        WHEN chronic_28d_load > 0
        THEN ROUND((acute_7d_load / (chronic_28d_load / 4.0))::numeric, 2)
        ELSE NULL
      END
    ) STORED;

ALTER TABLE workload_metrics
  ADD COLUMN risk_zone text
    GENERATED ALWAYS AS (
      CASE
        WHEN chronic_28d_load = 0 THEN 'insufficient_data'
        WHEN (acute_7d_load / (NULLIF(chronic_28d_load, 0) / 4.0)) < 0.8 THEN 'detraining'
        WHEN (acute_7d_load / (NULLIF(chronic_28d_load, 0) / 4.0)) <= 1.3 THEN 'optimal'
        WHEN (acute_7d_load / (NULLIF(chronic_28d_load, 0) / 4.0)) <= 1.5 THEN 'elevated'
        ELSE 'high_risk'
      END
    ) STORED;

COMMENT ON COLUMN workload_metrics.acwr_ratio IS
  'Acute:Chronic Workload Ratio. Compares weekly averages: acute_7d_load / '
  '(chronic_28d_load / 4). Sweet spot 0.8-1.3; >1.5 elevated injury risk (Hulin 2016).';

COMMENT ON COLUMN workload_metrics.risk_zone IS
  'Classification per Hulin 2016 BJSM. Uses corrected ACWR formula (weekly averages).';

-- Recreate the partial index that referenced risk_zone (was dropped with column)
CREATE INDEX IF NOT EXISTS workload_metrics_user_risk_idx
  ON workload_metrics (user_id, risk_zone)
  WHERE risk_zone IN ('elevated', 'high_risk');

-- =============================================================================
-- 2. FIX body_weight_multiple UNIT NORMALIZATION (065)
-- =============================================================================
-- personal_records.value inherits units from the set (kg or lb). Without a
-- stored unit on PR rows, a generated bw_multiple assuming kg yields 2.2x
-- inflated ratios for lb users.

ALTER TABLE personal_records
  ADD COLUMN IF NOT EXISTS pr_weight_unit text
    NOT NULL DEFAULT 'kg'
    CHECK (pr_weight_unit IN ('kg','lb'));

COMMENT ON COLUMN personal_records.pr_weight_unit IS
  'Unit of the PR value column. Defaults to kg. Stored separately from body_weight_unit '
  'because the PR lift weight and bodyweight may have been logged in different units.';

-- Drop and recreate body_weight_multiple with unit normalization.
ALTER TABLE personal_records DROP COLUMN IF EXISTS body_weight_multiple;

ALTER TABLE personal_records
  ADD COLUMN body_weight_multiple numeric(5,2)
    GENERATED ALWAYS AS (
      CASE
        WHEN body_weight_at_record IS NULL OR body_weight_at_record <= 0
        THEN NULL
        ELSE ROUND(
          (
            (CASE WHEN pr_weight_unit = 'lb' THEN value / 2.20462 ELSE value END)
            /
            (CASE WHEN body_weight_unit = 'lb' THEN body_weight_at_record / 2.20462 ELSE body_weight_at_record END)
          )::numeric, 2
        )
      END
    ) STORED;

COMMENT ON COLUMN personal_records.body_weight_multiple IS
  'Generated: normalized PR value / normalized bodyweight. Both converted to kg '
  'before division, so the multiple is always unit-agnostic. Used for strength-standards lookup.';

-- =============================================================================
-- 3. CREATE MISSING phase_adherence_check VIEW (067)
-- =============================================================================
-- Compares recent-week rep ranges and RPE against the user's active phase
-- targets. Surfaces "out of spec" warnings: "you're lifting 3-reps in a
-- hypertrophy phase" or "RPE low for a peaking phase".

CREATE OR REPLACE VIEW phase_adherence_check
WITH (security_invoker = true) AS
WITH last_week_sets AS (
  SELECT
    s.user_id,
    AVG(s.reps)::numeric(4,1)                      AS avg_reps,
    AVG(s.rpe) FILTER (WHERE s.rpe IS NOT NULL)::numeric(3,1) AS avg_rpe,
    COUNT(*)                                       AS working_set_count
  FROM sets s
  WHERE s.training_date >= CURRENT_DATE - interval '7 days'
    AND s.training_date <= CURRENT_DATE
    AND s.set_type = 'working'
  GROUP BY s.user_id
),
active_phase_with_targets AS (
  SELECT
    tp.user_id,
    tp.id                           AS phase_id,
    tp.name                         AS phase_name,
    tp.phase_type,
    tp.start_date,
    COALESCE(tp.target_rep_range_min, ptd.target_rep_range_min) AS rep_min,
    COALESCE(tp.target_rep_range_max, ptd.target_rep_range_max) AS rep_max,
    COALESCE(tp.target_rpe_min,       ptd.target_rpe_min)       AS rpe_min,
    COALESCE(tp.target_rpe_max,       ptd.target_rpe_max)       AS rpe_max
  FROM training_phases tp
  JOIN phase_type_defaults ptd ON ptd.phase_type = tp.phase_type
  WHERE tp.end_date IS NULL
)
SELECT
  apt.user_id,
  apt.phase_id,
  apt.phase_name,
  apt.phase_type,
  apt.start_date                      AS phase_start_date,
  (CURRENT_DATE - apt.start_date)     AS phase_days_elapsed,
  apt.rep_min                         AS target_rep_min,
  apt.rep_max                         AS target_rep_max,
  apt.rpe_min                         AS target_rpe_min,
  apt.rpe_max                         AS target_rpe_max,
  lws.avg_reps                        AS actual_avg_reps_last_7d,
  lws.avg_rpe                         AS actual_avg_rpe_last_7d,
  lws.working_set_count               AS working_sets_last_7d,
  CASE
    WHEN lws.avg_reps IS NULL                                           THEN 'no_data'
    WHEN apt.rep_min IS NULL OR apt.rep_max IS NULL                     THEN 'no_target'
    WHEN lws.avg_reps < apt.rep_min                                     THEN 'reps_below_target'
    WHEN lws.avg_reps > apt.rep_max                                     THEN 'reps_above_target'
    ELSE 'reps_on_target'
  END                                 AS rep_adherence_status,
  CASE
    WHEN lws.avg_rpe IS NULL                                            THEN 'no_data'
    WHEN apt.rpe_min IS NULL OR apt.rpe_max IS NULL                     THEN 'no_target'
    WHEN lws.avg_rpe < apt.rpe_min                                      THEN 'rpe_below_target'
    WHEN lws.avg_rpe > apt.rpe_max                                      THEN 'rpe_above_target'
    ELSE 'rpe_on_target'
  END                                 AS rpe_adherence_status
FROM active_phase_with_targets apt
LEFT JOIN last_week_sets lws ON lws.user_id = apt.user_id;

COMMENT ON VIEW phase_adherence_check IS
  'Compares last 7 days of working-set reps and RPE to the user active training '
  'phase targets (from training_phases or phase_type_defaults fallback). '
  'Surfaces adherence states: on_target / above_target / below_target / no_data / no_target.';

COMMIT;
