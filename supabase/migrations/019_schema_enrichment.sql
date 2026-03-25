-- Migration 019: Schema Enrichment
-- Adds richer exercise metadata, timezone-aware training dates, body weight
-- tracking, workout feedback, exercise substitutions, recommendation scopes,
-- and equipment usage analytics.
--
-- Validated by: fitness-domain-expert, data-science-expert agents

-- =============================================================================
-- 1. EXERCISES: richer metadata
-- =============================================================================

-- Laterality: bilateral/unilateral classification for imbalance analytics
ALTER TABLE exercises
  ADD COLUMN IF NOT EXISTS laterality text CHECK (laterality IN ('bilateral', 'unilateral', 'both'));

-- Aliases: alternate names for search/deduplication
ALTER TABLE exercises
  ADD COLUMN IF NOT EXISTS aliases text[] DEFAULT '{}';

-- Exercise type: push/pull/legs categorization for volume balance analytics
-- Complements movement_pattern (biomechanical) with training-split classification
ALTER TABLE exercises
  ADD COLUMN IF NOT EXISTS exercise_type text CHECK (exercise_type IN (
    'push', 'pull', 'legs', 'core', 'cardio', 'full_body'
  ));

-- GIN index on aliases for @> (contains) queries
CREATE INDEX IF NOT EXISTS exercises_aliases_idx
  ON exercises USING GIN (aliases);

-- Index on exercise_type for filtered queries
CREATE INDEX IF NOT EXISTS exercises_type_idx
  ON exercises (exercise_type)
  WHERE exercise_type IS NOT NULL;

-- Index on laterality for filtered queries
CREATE INDEX IF NOT EXISTS exercises_laterality_idx
  ON exercises (laterality)
  WHERE laterality IS NOT NULL;


-- =============================================================================
-- 2. SETS: duration, distance, training date, side tracking
-- =============================================================================

-- Duration: for isometric holds (planks, wall sits) and time-under-tension
ALTER TABLE sets
  ADD COLUMN IF NOT EXISTS duration_seconds integer CHECK (duration_seconds > 0);

-- Distance: for cardio exercises (rower, run, sled push, carries)
ALTER TABLE sets
  ADD COLUMN IF NOT EXISTS distance_meters numeric CHECK (distance_meters > 0);

-- Distance unit preference (must be set when distance_meters is set)
ALTER TABLE sets
  ADD COLUMN IF NOT EXISTS distance_unit text CHECK (distance_unit IN ('m', 'km', 'mi', 'yd'));

-- Co-constraint: distance and unit must both be set or both be null
ALTER TABLE sets DROP CONSTRAINT IF EXISTS sets_distance_unit_check;
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'sets_distance_co_constraint'
  ) THEN
    ALTER TABLE sets ADD CONSTRAINT sets_distance_co_constraint CHECK (
      (distance_meters IS NULL AND distance_unit IS NULL)
      OR (distance_meters IS NOT NULL AND distance_unit IS NOT NULL)
    );
  END IF;
END $$;

-- Training date: timezone-aware date bucketing (computed via trigger)
ALTER TABLE sets
  ADD COLUMN IF NOT EXISTS training_date date;

-- Side: for unilateral exercise tracking (left/right imbalance detection)
ALTER TABLE sets
  ADD COLUMN IF NOT EXISTS side text CHECK (side IN ('left', 'right'));

-- Index for training_date queries (weekly volume, calendar heatmap)
CREATE INDEX IF NOT EXISTS sets_user_training_date_idx
  ON sets (user_id, training_date DESC)
  WHERE training_date IS NOT NULL;

-- Index for side-based imbalance queries
CREATE INDEX IF NOT EXISTS sets_user_exercise_side_idx
  ON sets (user_id, exercise_id, side, logged_at DESC)
  WHERE side IS NOT NULL;


-- =============================================================================
-- 3. PROFILES: timezone and body dimensions
-- =============================================================================

-- Timezone for training date bucketing (IANA format, e.g., 'America/New_York')
ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS timezone text DEFAULT 'UTC'
    CHECK (timezone IS NULL OR timezone ~ '^[A-Za-z][A-Za-z0-9/_+-]{1,63}$');

-- Day start hour: sets logged before this hour count as previous day
-- Default 4 AM (convention from Whoop, STRONG, gym-tracker)
ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS day_start_hour smallint DEFAULT 4
    CHECK (day_start_hour >= 0 AND day_start_hour <= 23);

-- Height for BMI/FFMI calculations
ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS height_cm numeric CHECK (height_cm > 0 AND height_cm < 300);


-- =============================================================================
-- 4. NEW TABLE: body_weight_log
-- =============================================================================

CREATE TABLE IF NOT EXISTS body_weight_log (
  id              uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  weight          numeric     NOT NULL CHECK (weight > 0),
  weight_unit     text        NOT NULL DEFAULT 'kg' CHECK (weight_unit IN ('kg', 'lb')),
  body_fat_pct    numeric     CHECK (body_fat_pct > 0 AND body_fat_pct < 100),
  source          text        NOT NULL DEFAULT 'manual' CHECK (source IN ('manual', 'smart_scale', 'import')),
  notes           text,
  logged_at       timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now()
);
COMMENT ON TABLE body_weight_log IS 'User body weight over time for relative strength (DOTS, BW multiples) and composition tracking.';

CREATE INDEX IF NOT EXISTS body_weight_log_user_logged_idx
  ON body_weight_log (user_id, logged_at DESC);

CREATE TRIGGER body_weight_log_updated_at
  BEFORE UPDATE ON body_weight_log
  FOR EACH ROW
  EXECUTE FUNCTION set_updated_at();

ALTER TABLE body_weight_log ENABLE ROW LEVEL SECURITY;

CREATE POLICY body_weight_log_select ON body_weight_log
  FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY body_weight_log_insert ON body_weight_log
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY body_weight_log_update ON body_weight_log
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY body_weight_log_delete ON body_weight_log
  FOR DELETE TO authenticated USING (user_id = auth.uid());


-- =============================================================================
-- 5. NEW TABLE: workout_feedback
-- =============================================================================

CREATE TABLE IF NOT EXISTS workout_feedback (
  id                  uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id             uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  training_date       date        NOT NULL,
  session_rpe         smallint    CHECK (session_rpe >= 1 AND session_rpe <= 10),
  readiness_score     smallint    CHECK (readiness_score >= 1 AND readiness_score <= 5),
  prior_sleep_quality smallint    CHECK (prior_sleep_quality >= 1 AND prior_sleep_quality <= 5),
  sleep_hours         numeric     CHECK (sleep_hours >= 0 AND sleep_hours <= 24),
  stress_level        smallint    CHECK (stress_level >= 1 AND stress_level <= 5),
  notes               text,
  created_at          timestamptz NOT NULL DEFAULT now(),
  updated_at          timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, training_date)
);
COMMENT ON TABLE workout_feedback IS 'Post-session subjective data: sRPE, readiness, sleep, stress. Enables correlation with performance metrics.';

CREATE INDEX IF NOT EXISTS workout_feedback_user_date_idx
  ON workout_feedback (user_id, training_date DESC);
CREATE INDEX IF NOT EXISTS workout_feedback_user_created_idx
  ON workout_feedback (user_id, created_at DESC);

CREATE TRIGGER workout_feedback_updated_at
  BEFORE UPDATE ON workout_feedback
  FOR EACH ROW
  EXECUTE FUNCTION set_updated_at();

ALTER TABLE workout_feedback ENABLE ROW LEVEL SECURITY;

CREATE POLICY workout_feedback_select ON workout_feedback
  FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY workout_feedback_insert ON workout_feedback
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY workout_feedback_update ON workout_feedback
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY workout_feedback_delete ON workout_feedback
  FOR DELETE TO authenticated USING (user_id = auth.uid());


-- =============================================================================
-- 6. NEW TABLE: exercise_substitutions
-- =============================================================================

CREATE TABLE IF NOT EXISTS exercise_substitutions (
  id                  uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  source_exercise_id  uuid        NOT NULL REFERENCES exercises(id) ON DELETE RESTRICT,
  target_exercise_id  uuid        NOT NULL REFERENCES exercises(id) ON DELETE RESTRICT,
  substitution_type   text        NOT NULL CHECK (substitution_type IN (
    'same_pattern',   -- same movement, different equipment
    'same_muscles',   -- same primary muscles, different pattern
    'regression',     -- easier variant of the same movement
    'progression'     -- harder variant of the same movement
  )),
  similarity_score    smallint    CHECK (similarity_score >= 1 AND similarity_score <= 100),
  notes               text,
  UNIQUE (source_exercise_id, target_exercise_id),
  CHECK (source_exercise_id != target_exercise_id)
);
COMMENT ON TABLE exercise_substitutions IS 'Directional exercise alternatives with type and similarity score.';

CREATE INDEX IF NOT EXISTS exercise_subs_source_idx
  ON exercise_substitutions (source_exercise_id, similarity_score DESC);
CREATE INDEX IF NOT EXISTS exercise_subs_target_idx
  ON exercise_substitutions (target_exercise_id);
CREATE INDEX IF NOT EXISTS exercise_subs_type_idx
  ON exercise_substitutions (substitution_type);

-- Exercise substitutions are reference data (public read for all authenticated)
ALTER TABLE exercise_substitutions ENABLE ROW LEVEL SECURITY;

CREATE POLICY exercise_subs_select ON exercise_substitutions
  FOR SELECT TO authenticated USING (true);


-- =============================================================================
-- 7. NEW TABLE: recommendation_scopes
-- =============================================================================

CREATE TABLE IF NOT EXISTS recommendation_scopes (
  id                   uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id              uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  grouping             text        NOT NULL DEFAULT 'training_day' CHECK (grouping IN (
    'training_day', 'session', 'week', 'cluster'
  )),
  date_start           date,
  date_end             date,
  included_set_types   text[]      NOT NULL DEFAULT '{working}',
  comparison_scope_id  uuid        REFERENCES recommendation_scopes(id) ON DELETE SET NULL,
  metadata             jsonb       DEFAULT '{}',
  created_at           timestamptz NOT NULL DEFAULT now(),
  CHECK (date_start IS NULL OR date_end IS NULL OR date_start <= date_end)
);
COMMENT ON TABLE recommendation_scopes IS 'Reproducible analysis parameters for AI insights. Enables scope comparison.';

CREATE INDEX IF NOT EXISTS recommendation_scopes_user_idx
  ON recommendation_scopes (user_id, created_at DESC);

ALTER TABLE recommendation_scopes ENABLE ROW LEVEL SECURITY;

CREATE POLICY recommendation_scopes_select ON recommendation_scopes
  FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY recommendation_scopes_insert ON recommendation_scopes
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY recommendation_scopes_update ON recommendation_scopes
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY recommendation_scopes_delete ON recommendation_scopes
  FOR DELETE TO authenticated USING (user_id = auth.uid());

-- Link analysis_reports to recommendation_scopes
ALTER TABLE analysis_reports
  ADD COLUMN IF NOT EXISTS recommendation_scope_id uuid
    REFERENCES recommendation_scopes(id) ON DELETE SET NULL;


-- =============================================================================
-- 8. TRIGGER: compute_training_date
-- =============================================================================

CREATE OR REPLACE FUNCTION compute_training_date()
RETURNS TRIGGER AS $$
DECLARE
  v_timezone text;
  v_day_start_hour smallint;
BEGIN
  -- Get user's timezone preferences
  SELECT COALESCE(timezone, 'UTC'), COALESCE(day_start_hour, 4)
    INTO v_timezone, v_day_start_hour
    FROM profiles
    WHERE id = NEW.user_id;

  -- Default to UTC/4AM if no profile exists
  IF NOT FOUND THEN
    v_timezone := 'UTC';
    v_day_start_hour := 4;
  END IF;

  -- Compute training date: shift by day_start_hour so late-night sets
  -- count as the previous day (e.g., 2AM with 4AM boundary → yesterday)
  NEW.training_date := (
    (NEW.logged_at AT TIME ZONE v_timezone)
    - (v_day_start_hour || ' hours')::interval
  )::date;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION compute_training_date IS 'Computes timezone-aware training date from logged_at, shifting by day_start_hour boundary.';

-- Apply trigger on INSERT and UPDATE of logged_at
DROP TRIGGER IF EXISTS sets_compute_training_date ON sets;
CREATE TRIGGER sets_compute_training_date
  BEFORE INSERT OR UPDATE OF logged_at ON sets
  FOR EACH ROW
  EXECUTE FUNCTION compute_training_date();

-- Backfill training_date for existing sets (using UTC/4AM defaults if no profile)
UPDATE sets s
SET training_date = (
  (s.logged_at AT TIME ZONE COALESCE(p.timezone, 'UTC'))
  - (COALESCE(p.day_start_hour, 4) || ' hours')::interval
)::date
FROM profiles p
WHERE p.id = s.user_id
  AND s.training_date IS NULL;

-- Backfill sets with no matching profile (use UTC/4AM)
UPDATE sets
SET training_date = (logged_at AT TIME ZONE 'UTC' - interval '4 hours')::date
WHERE training_date IS NULL;


-- =============================================================================
-- 9. VIEW: equipment_usage_stats
-- =============================================================================

-- SECURITY INVOKER ensures RLS policies on sets are enforced (PostgreSQL 15+)
CREATE OR REPLACE VIEW exercise_usage_stats
WITH (security_invoker = true) AS
SELECT
  user_id,
  exercise_id,
  COUNT(*) FILTER (WHERE logged_at >= NOW() - interval '7 days')  AS sets_7d,
  COUNT(*) FILTER (WHERE logged_at >= NOW() - interval '30 days') AS sets_30d,
  COUNT(*) FILTER (WHERE logged_at >= NOW() - interval '90 days') AS sets_90d,
  COUNT(*)                                                         AS sets_all_time,
  MAX(logged_at)                                                   AS last_used_at
FROM sets
GROUP BY user_id, exercise_id;

COMMENT ON VIEW exercise_usage_stats IS 'Set counts per exercise over 7d/30d/90d/all-time windows. RLS-enforced via security_invoker.';


-- =============================================================================
-- 10. AUTO-DERIVE exercise_type FROM movement_pattern (where unambiguous)
-- =============================================================================

-- Populate exercise_type from movement_pattern for unambiguous mappings
UPDATE exercises SET exercise_type = 'push'
WHERE movement_pattern IN ('horizontal_push', 'vertical_push')
  AND exercise_type IS NULL;

UPDATE exercises SET exercise_type = 'pull'
WHERE movement_pattern IN ('horizontal_pull', 'vertical_pull')
  AND exercise_type IS NULL;

UPDATE exercises SET exercise_type = 'legs'
WHERE movement_pattern IN ('squat', 'hip_hinge', 'lunge')
  AND exercise_type IS NULL;

UPDATE exercises SET exercise_type = 'core'
WHERE movement_pattern = 'rotation'
  AND exercise_type IS NULL;

UPDATE exercises SET exercise_type = 'full_body'
WHERE movement_pattern = 'carry'
  AND exercise_type IS NULL;
