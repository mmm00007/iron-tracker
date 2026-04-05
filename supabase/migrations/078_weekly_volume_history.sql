-- Migration 078: Weekly Volume History Snapshots
-- Materializes weekly_muscle_effective_sets (view from 067) into a persistent
-- snapshot table for fast trend queries across months/years of training data.
--
-- The view recomputes on every query from sets × exercise_muscles. For users
-- with years of training data, rendering a "volume per muscle over last 12
-- months" chart triggers hundreds of thousands of row joins. The snapshot
-- table makes this O(muscle_groups × weeks) not O(sets).
--
-- Validated by: data-science-expert, database-specialist
--
-- Key design decisions:
--   - Snapshots are append-only history: UPSERT updates current/recent weeks,
--     older weeks are frozen (training data doesn't retroactively change)
--   - Only stores working sets — rest intentionally excluded
--   - activation-weighted effective_sets (matches fractional volume counting)
--   - Backend cron refreshes last 4 weeks daily, plus older weeks on-demand
--   - Retention: unbounded (cheap at ~16 rows/week/user)

BEGIN;

-- =============================================================================
-- 1. weekly_volume_snapshots table
-- =============================================================================

CREATE TABLE IF NOT EXISTS weekly_volume_snapshots (
  id                  uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id             uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  muscle_group_id     integer     NOT NULL REFERENCES muscle_groups(id) ON DELETE CASCADE,
  week_start          date        NOT NULL,
  week_end            date        NOT NULL,
  effective_sets      numeric(5,1) NOT NULL CHECK (effective_sets >= 0),
  mechanical_sets     integer     NOT NULL DEFAULT 0 CHECK (mechanical_sets >= 0),
  avg_rpe             numeric(3,1) CHECK (avg_rpe IS NULL OR (avg_rpe >= 0 AND avg_rpe <= 10)),
  peak_rpe            numeric(3,1) CHECK (peak_rpe IS NULL OR (peak_rpe >= 0 AND peak_rpe <= 10)),
  avg_intensity_pct_1rm numeric(4,1) CHECK (avg_intensity_pct_1rm IS NULL OR (avg_intensity_pct_1rm >= 0 AND avg_intensity_pct_1rm <= 200)),
  total_volume_kg     numeric(8,1) DEFAULT 0 CHECK (total_volume_kg >= 0),
  training_days       smallint    NOT NULL DEFAULT 0 CHECK (training_days >= 0 AND training_days <= 7),
  computation_version smallint    NOT NULL DEFAULT 1,
  computed_at         timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, muscle_group_id, week_start)
);

COMMENT ON TABLE weekly_volume_snapshots IS
  'Per-user per-muscle per-week volume snapshots. Populated from sets × '
  'exercise_muscles via refresh_weekly_volume_snapshots() cron function. '
  'Enables fast trend queries without recomputing from raw sets.';

COMMENT ON COLUMN weekly_volume_snapshots.effective_sets IS
  'Activation-weighted fractional sets: SUM(activation_percent/100) over working sets.';

COMMENT ON COLUMN weekly_volume_snapshots.avg_intensity_pct_1rm IS
  'Weekly average weight as percentage of user''s e1RM for that exercise at the time. '
  'NULL if e1RM not computable (no PR or too-recent data).';

CREATE INDEX IF NOT EXISTS weekly_volume_snapshots_user_week_idx
  ON weekly_volume_snapshots (user_id, week_start DESC);

CREATE INDEX IF NOT EXISTS weekly_volume_snapshots_user_muscle_idx
  ON weekly_volume_snapshots (user_id, muscle_group_id, week_start DESC);

ALTER TABLE weekly_volume_snapshots ENABLE ROW LEVEL SECURITY;

CREATE POLICY weekly_volume_snapshots_select ON weekly_volume_snapshots
  FOR SELECT TO authenticated USING (user_id = auth.uid());

CREATE POLICY weekly_volume_snapshots_insert ON weekly_volume_snapshots
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());

CREATE POLICY weekly_volume_snapshots_update ON weekly_volume_snapshots
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

CREATE POLICY weekly_volume_snapshots_delete ON weekly_volume_snapshots
  FOR DELETE TO authenticated USING (user_id = auth.uid());

-- =============================================================================
-- 2. refresh_weekly_volume_snapshots(user_id, weeks_back)
-- =============================================================================
-- Recomputes the most recent N weeks of volume snapshots for a user.
-- Backend cron runs daily with weeks_back=4 (current + 3 prior weeks to catch
-- any backdated logging). Monthly cron runs with weeks_back=52 for full history.

CREATE OR REPLACE FUNCTION refresh_weekly_volume_snapshots(
  p_user_id uuid,
  p_weeks_back integer DEFAULT 4
)
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_catalog
AS $$
DECLARE
  v_rows_written integer;
BEGIN
  WITH weekly_agg AS (
    SELECT
      s.user_id,
      em.muscle_group_id,
      date_trunc('week', s.training_date)::date AS week_start,
      (date_trunc('week', s.training_date) + interval '6 days')::date AS week_end,
      ROUND(SUM(
        COALESCE(em.activation_percent, CASE WHEN em.is_primary THEN 100 ELSE 50 END)::numeric / 100
      ), 1) AS effective_sets,
      COUNT(*)::integer AS mechanical_sets,
      AVG(s.rpe) FILTER (WHERE s.rpe IS NOT NULL)::numeric(3,1) AS avg_rpe,
      MAX(s.rpe)::numeric(3,1) AS peak_rpe,
      SUM(s.weight * s.reps)::numeric(8,1) AS total_volume_kg,
      COUNT(DISTINCT s.training_date)::smallint AS training_days
    FROM sets s
    JOIN exercise_muscles em ON em.exercise_id = s.exercise_id
    WHERE s.user_id = p_user_id
      AND s.training_date IS NOT NULL
      AND s.training_date >= date_trunc('week', CURRENT_DATE - (p_weeks_back * 7))::date
      AND s.training_date <= CURRENT_DATE
      AND s.set_type = 'working'
      AND s.reps > 0
    GROUP BY s.user_id, em.muscle_group_id, date_trunc('week', s.training_date)
  )
  INSERT INTO weekly_volume_snapshots (
    user_id, muscle_group_id, week_start, week_end,
    effective_sets, mechanical_sets, avg_rpe, peak_rpe, total_volume_kg, training_days,
    computation_version, computed_at
  )
  SELECT user_id, muscle_group_id, week_start, week_end,
         effective_sets, mechanical_sets, avg_rpe, peak_rpe, total_volume_kg, training_days,
         1, now()
  FROM weekly_agg
  ON CONFLICT (user_id, muscle_group_id, week_start) DO UPDATE SET
    week_end = EXCLUDED.week_end,
    effective_sets = EXCLUDED.effective_sets,
    mechanical_sets = EXCLUDED.mechanical_sets,
    avg_rpe = EXCLUDED.avg_rpe,
    peak_rpe = EXCLUDED.peak_rpe,
    total_volume_kg = EXCLUDED.total_volume_kg,
    training_days = EXCLUDED.training_days,
    computed_at = now();

  GET DIAGNOSTICS v_rows_written = ROW_COUNT;
  RETURN v_rows_written;
END;
$$;

COMMENT ON FUNCTION refresh_weekly_volume_snapshots(uuid, integer) IS
  'Materializes weekly_muscle_effective_sets data into weekly_volume_snapshots '
  'for the user''s last N weeks. Idempotent via UPSERT. Default 4 weeks covers '
  'backdated set logging. Pass 52 for full-year refresh (monthly cron).';

CREATE OR REPLACE FUNCTION refresh_weekly_volume_snapshots_all_users(
  p_weeks_back integer DEFAULT 4
)
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_catalog
AS $$
DECLARE
  v_total integer := 0;
  v_rows integer;
  v_user record;
BEGIN
  FOR v_user IN
    SELECT DISTINCT user_id FROM sets
    WHERE training_date >= CURRENT_DATE - (p_weeks_back * 7)
  LOOP
    v_rows := refresh_weekly_volume_snapshots(v_user.user_id, p_weeks_back);
    v_total := v_total + v_rows;
  END LOOP;
  RETURN v_total;
END;
$$;

COMMENT ON FUNCTION refresh_weekly_volume_snapshots_all_users(integer) IS
  'Batch wrapper: refresh snapshots for all users with activity in last N weeks. '
  'Intended for daily cron at 03:00 UTC.';

-- =============================================================================
-- 3. volume_trend_per_muscle view: 12-week trend per muscle
-- =============================================================================
-- Per-muscle weekly volumes over last 12 weeks with slope analysis.

CREATE OR REPLACE VIEW volume_trend_per_muscle
WITH (security_invoker = true) AS
WITH recent AS (
  SELECT
    user_id, muscle_group_id,
    week_start, effective_sets, training_days
  FROM weekly_volume_snapshots
  WHERE week_start >= CURRENT_DATE - interval '84 days'
),
with_trend AS (
  SELECT
    user_id, muscle_group_id,
    AVG(effective_sets)::numeric(5,1) AS avg_sets_12w,
    MIN(effective_sets)::numeric(5,1) AS min_sets_12w,
    MAX(effective_sets)::numeric(5,1) AS max_sets_12w,
    STDDEV(effective_sets)::numeric(5,2) AS stddev_sets_12w,
    SUM(training_days) AS training_days_12w,
    -- Simple linear regression slope via REGR_SLOPE
    REGR_SLOPE(effective_sets, EXTRACT(epoch FROM week_start)::numeric / 604800)::numeric(5,2) AS slope_sets_per_week,
    COUNT(*)::integer AS weeks_with_data
  FROM recent
  GROUP BY user_id, muscle_group_id
)
SELECT
  wt.user_id, wt.muscle_group_id, mg.name AS muscle_name,
  wt.avg_sets_12w, wt.min_sets_12w, wt.max_sets_12w, wt.stddev_sets_12w,
  wt.training_days_12w, wt.slope_sets_per_week, wt.weeks_with_data,
  CASE
    WHEN wt.slope_sets_per_week IS NULL OR wt.weeks_with_data < 4 THEN 'insufficient_data'
    WHEN wt.slope_sets_per_week > 0.5 THEN 'increasing'
    WHEN wt.slope_sets_per_week < -0.5 THEN 'decreasing'
    ELSE 'stable'
  END AS trend_direction
FROM with_trend wt
JOIN muscle_groups mg ON mg.id = wt.muscle_group_id;

COMMENT ON VIEW volume_trend_per_muscle IS
  '12-week effective-sets trend per user per muscle: avg, min/max, stddev, '
  'linear slope (sets/week), direction (increasing/decreasing/stable). '
  'Powers per-muscle trend chart + volume-progression coaching.';

COMMIT;
