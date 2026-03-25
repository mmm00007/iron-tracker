-- Migration 025: Exercise Insights & Body Tracking Enrichment
-- Adds default rest periods, compound classification, body measurements,
-- strength standards reference data, and three insight-oriented views.
--
-- Validated by: fitness-domain-expert, database-specialist agents
--
-- Key design decisions (from expert validation):
--   - default_rest_seconds per exercise (NSCA: rest is a primary programming variable)
--   - is_compound as GENERATED column from existing mechanic field (no duplication)
--   - body_measurements separate from body_weight_log (different frequencies, shapes)
--   - strength_standards as reference table (moves hardcoded Python dicts to DB)
--   - weekly_muscle_volume uses agonist=1.0 / synergist=0.5 / stabilizer=0 weighting
--     per RP counting convention (Israetel, 2021)
--   - movement_pattern_balance computes horizontal push:pull and knee:hip ratios
--     (Kolber et al., 2009: push:pull >1.5:1 → shoulder impingement risk)
--   - muscle_workload_coefficients REJECTED by domain expert: no peer-reviewed source
--     for cross-muscle normalization. Use % of MAV from training_volume_targets instead.

BEGIN;

-- =============================================================================
-- 1. EXERCISES: Default rest period (seconds)
-- =============================================================================

-- Recommended rest between sets for this exercise.
-- NSCA guidelines (Ratamess et al., 2009):
--   Compound strength: 180-300s, Compound hypertrophy: 90-180s,
--   Isolation: 60-90s, Endurance: 30-60s.
-- Placed on exercises (not only plan_items) because exercises have inherent
-- rest demands based on muscle mass involvement and metabolic cost.
ALTER TABLE exercises
  ADD COLUMN IF NOT EXISTS default_rest_seconds smallint
    CHECK (default_rest_seconds > 0 AND default_rest_seconds <= 600);

COMMENT ON COLUMN exercises.default_rest_seconds IS
  'Recommended rest (seconds) between sets. NSCA-based: compounds ~120s, isolation ~60s, Olympic ~180s.';


-- =============================================================================
-- 2. EXERCISES: Compound classification (generated column)
-- =============================================================================

-- Generated from existing `mechanic` column (values: 'compound', 'isolation', NULL).
-- Avoids data duplication while providing a boolean for convenient filtering.
-- Used for: cold-start defaults, exercise library grouping, analytics filters.
ALTER TABLE exercises
  ADD COLUMN IF NOT EXISTS is_compound boolean
    GENERATED ALWAYS AS (mechanic = 'compound') STORED;

COMMENT ON COLUMN exercises.is_compound IS
  'Generated from mechanic column. true = multi-joint compound, false = single-joint isolation or NULL mechanic.';

-- Partial index for "show me all compound exercises" queries
CREATE INDEX IF NOT EXISTS exercises_compound_idx
  ON exercises (id)
  WHERE mechanic = 'compound';


-- =============================================================================
-- 3. PROFILES: Denormalized current body weight
-- =============================================================================

-- Cached from the latest body_weight_log entry for fast BW-relative calculations
-- (DOTS score, strength standards, milestone BW multiples).
-- Updated by trigger on body_weight_log INSERT.
ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS current_body_weight_kg numeric
    CHECK (current_body_weight_kg > 0 AND current_body_weight_kg < 500);

COMMENT ON COLUMN profiles.current_body_weight_kg IS
  'Denormalized from latest body_weight_log entry (in kg). Auto-synced via trigger.';

-- Trigger function to sync current_body_weight_kg from body_weight_log.
-- Handles INSERT, UPDATE, and DELETE to keep the cache consistent.
CREATE OR REPLACE FUNCTION sync_profile_body_weight()
RETURNS TRIGGER AS $$
DECLARE
  v_target_user_id uuid;
  v_latest record;
BEGIN
  -- Determine which user to update
  IF TG_OP = 'DELETE' THEN
    v_target_user_id := OLD.user_id;
  ELSE
    v_target_user_id := NEW.user_id;
  END IF;

  -- Find the latest body_weight_log entry for this user
  SELECT weight, weight_unit INTO v_latest
  FROM body_weight_log
  WHERE user_id = v_target_user_id
  ORDER BY logged_at DESC
  LIMIT 1;

  IF v_latest IS NOT NULL THEN
    UPDATE profiles
    SET current_body_weight_kg = CASE
      WHEN v_latest.weight_unit = 'lb' THEN v_latest.weight * 0.453592
      ELSE v_latest.weight
    END
    WHERE id = v_target_user_id;
  ELSE
    -- No weight entries remain; clear the cache
    UPDATE profiles
    SET current_body_weight_kg = NULL
    WHERE id = v_target_user_id;
  END IF;

  IF TG_OP = 'DELETE' THEN
    RETURN OLD;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER body_weight_log_sync_profile
  AFTER INSERT OR UPDATE OR DELETE ON body_weight_log
  FOR EACH ROW
  EXECUTE FUNCTION sync_profile_body_weight();

COMMENT ON FUNCTION sync_profile_body_weight IS
  'Syncs profiles.current_body_weight_kg from the latest body_weight_log entry. Handles INSERT/UPDATE/DELETE.';


-- =============================================================================
-- 4. NEW TABLE: body_measurements (circumference & skinfold tracking)
-- =============================================================================

-- Separate from body_weight_log because:
--   - Weight is logged daily; circumferences/skinfolds are weekly/monthly
--   - Data shape differs (weight has unit toggle; measurements have site+side)
--   - Different frequency means different UX flows
--
-- Standard sites from NSCA/ACSM body composition assessment protocols.
-- Skinfold sites follow Jackson-Pollock 3/7-site protocols.
CREATE TABLE IF NOT EXISTS body_measurements (
  id               uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id          uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  measured_at      timestamptz NOT NULL DEFAULT now(),
  measurement_type text        NOT NULL CHECK (measurement_type IN (
    'circumference',  -- tape measure (cm/in)
    'skinfold'        -- caliper (mm)
  )),
  site             text        NOT NULL CHECK (site IN (
    -- Circumference sites (NSCA/ACSM standard)
    'neck', 'shoulder', 'chest', 'arm_relaxed', 'arm_flexed',
    'forearm', 'waist', 'hip', 'thigh', 'calf',
    -- Skinfold sites (Jackson-Pollock 7-site)
    'tricep_sf', 'subscapular_sf', 'midaxillary_sf',
    'suprailiac_sf', 'abdomen_sf', 'chest_sf', 'thigh_sf'
  )),
  value            numeric     NOT NULL CHECK (value > 0),
  unit             text        NOT NULL CHECK (unit IN ('cm', 'in', 'mm')),
  side             text        CHECK (side IN ('left', 'right')),
  notes            text,
  created_at       timestamptz NOT NULL DEFAULT now(),
  updated_at       timestamptz NOT NULL DEFAULT now(),

  -- Enforce valid unit per measurement type
  CHECK (
    (measurement_type = 'circumference' AND unit IN ('cm', 'in'))
    OR (measurement_type = 'skinfold' AND unit = 'mm')
  )
);

-- One measurement per site per session (handles nullable side)
CREATE UNIQUE INDEX IF NOT EXISTS body_measurements_unique_with_side_idx
  ON body_measurements (user_id, measured_at, measurement_type, site, side)
  WHERE side IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS body_measurements_unique_no_side_idx
  ON body_measurements (user_id, measured_at, measurement_type, site)
  WHERE side IS NULL;

COMMENT ON TABLE body_measurements IS
  'Circumference and skinfold measurements. Body weight tracked separately in body_weight_log.';

-- Timeline queries: "show me all waist measurements over time"
CREATE INDEX IF NOT EXISTS body_measurements_user_date_idx
  ON body_measurements (user_id, measured_at DESC);

-- Site-specific queries: "my latest arm measurement"
CREATE INDEX IF NOT EXISTS body_measurements_user_site_idx
  ON body_measurements (user_id, measurement_type, site, measured_at DESC);

CREATE TRIGGER body_measurements_updated_at
  BEFORE UPDATE ON body_measurements
  FOR EACH ROW
  EXECUTE FUNCTION set_updated_at();

ALTER TABLE body_measurements ENABLE ROW LEVEL SECURITY;

CREATE POLICY body_measurements_select ON body_measurements
  FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY body_measurements_insert ON body_measurements
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY body_measurements_update ON body_measurements
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY body_measurements_delete ON body_measurements
  FOR DELETE TO authenticated USING (user_id = auth.uid());


-- =============================================================================
-- 5. NEW TABLE: strength_standards (reference data)
-- =============================================================================

-- Population-level strength benchmarks for exercise classification.
-- Moves hardcoded Python dicts (strength_standards_service.py) into the database
-- for easier updates, auditing, and client-side access via Supabase RLS.
--
-- Sources:
--   - NSCA Essentials of Strength Training, 4th ed., Table 18.7
--   - ExRx.net strength standards
--   - Rippetoe & Kilgore, Practical Programming (2006)
--   - Hoffman, Norms for Fitness (2006) — female norms
--
-- Classification tiers:
--   beginner    — untrained or <6 months regular lifting
--   novice      — 6-12 months consistent training
--   intermediate — 1-3 years consistent training
--   advanced    — 3-5+ years, competitive recreational
--   elite       — top 5%, competitive/national-level
--
-- Values are absolute 1RM in kg, calibrated for reference body weights
-- (80kg male / 60kg female). The application layer scales by user BW ratio.
CREATE TABLE IF NOT EXISTS strength_standards (
  id              uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  exercise_name   text        NOT NULL,
  sex             text        NOT NULL CHECK (sex IN ('male', 'female')),
  reference_bw_kg numeric     NOT NULL CHECK (reference_bw_kg > 0),
  beginner_1rm    numeric     NOT NULL CHECK (beginner_1rm >= 0),
  novice_1rm      numeric     NOT NULL CHECK (novice_1rm >= 0),
  intermediate_1rm numeric    NOT NULL CHECK (intermediate_1rm >= 0),
  advanced_1rm    numeric     NOT NULL CHECK (advanced_1rm >= 0),
  elite_1rm       numeric     NOT NULL CHECK (elite_1rm >= 0),
  -- Bodyweight-relative ratios (more accurate when user BW is known)
  -- E.g., beginner_bw_ratio = 0.50 means 50% of bodyweight
  beginner_bw_ratio  numeric  CHECK (beginner_bw_ratio >= 0),
  novice_bw_ratio    numeric  CHECK (novice_bw_ratio >= 0),
  intermediate_bw_ratio numeric CHECK (intermediate_bw_ratio >= 0),
  advanced_bw_ratio  numeric  CHECK (advanced_bw_ratio >= 0),
  elite_bw_ratio     numeric  CHECK (elite_bw_ratio >= 0),
  source          text        NOT NULL DEFAULT 'nsca_exrx',
  notes           text,
  -- Enforce ordering: beginner <= novice <= intermediate <= advanced <= elite
  CHECK (beginner_1rm <= novice_1rm),
  CHECK (novice_1rm <= intermediate_1rm),
  CHECK (intermediate_1rm <= advanced_1rm),
  CHECK (advanced_1rm <= elite_1rm),
  CHECK (beginner_bw_ratio IS NULL OR novice_bw_ratio IS NULL OR beginner_bw_ratio <= novice_bw_ratio),
  CHECK (novice_bw_ratio IS NULL OR intermediate_bw_ratio IS NULL OR novice_bw_ratio <= intermediate_bw_ratio),
  CHECK (intermediate_bw_ratio IS NULL OR advanced_bw_ratio IS NULL OR intermediate_bw_ratio <= advanced_bw_ratio),
  CHECK (advanced_bw_ratio IS NULL OR elite_bw_ratio IS NULL OR advanced_bw_ratio <= elite_bw_ratio),
  UNIQUE (exercise_name, sex)
);

COMMENT ON TABLE strength_standards IS
  'Population strength benchmarks (1RM, kg). Calibrated per reference BW. App scales by user BW ratio.';

-- Index for lookup by exercise name (case-insensitive)
CREATE INDEX IF NOT EXISTS strength_standards_name_idx
  ON strength_standards (lower(exercise_name));

ALTER TABLE strength_standards ENABLE ROW LEVEL SECURITY;

-- Public read (reference data, like muscle_groups)
CREATE POLICY strength_standards_select ON strength_standards
  FOR SELECT TO authenticated USING (true);


-- =============================================================================
-- 6. RECOMMENDATION_SCOPES: Extend grouping enum
-- =============================================================================

-- Add 'mesocycle' and 'custom' grouping options for richer AI analysis scoping.
-- Must dynamically find the auto-generated constraint name since migration 019
-- used an inline CHECK (no explicit name).
DO $$ DECLARE v_conname text;
BEGIN
  SELECT conname INTO v_conname FROM pg_constraint
  WHERE conrelid = 'recommendation_scopes'::regclass
    AND contype = 'c'
    AND pg_get_constraintdef(oid) LIKE '%training_day%'
    AND pg_get_constraintdef(oid) LIKE '%grouping%';
  IF v_conname IS NOT NULL THEN
    EXECUTE 'ALTER TABLE recommendation_scopes DROP CONSTRAINT ' || quote_ident(v_conname);
  END IF;
END $$;

ALTER TABLE recommendation_scopes
  ADD CONSTRAINT recommendation_scopes_grouping_check CHECK (
    grouping IN ('training_day', 'session', 'week', 'cluster', 'mesocycle', 'custom')
  );


-- =============================================================================
-- 7. VIEW: exercise_performance_summary
-- =============================================================================

-- Per-exercise aggregated stats for library browsing and quick insights.
-- Filters to working sets only for weight/e1RM stats (excludes warmups).
-- RLS via security_invoker.
CREATE OR REPLACE VIEW exercise_performance_summary
WITH (security_invoker = true) AS
SELECT
  s.user_id,
  s.exercise_id,
  e.name                                                         AS exercise_name,
  e.movement_pattern,
  e.mechanic,
  e.is_compound,
  COUNT(*)                                                       AS total_sets,
  COUNT(*) FILTER (WHERE s.set_type = 'working')                 AS working_sets,
  MAX(s.weight) FILTER (WHERE s.set_type = 'working')            AS best_weight,
  MAX(s.estimated_1rm) FILTER (WHERE s.set_type = 'working')     AS best_e1rm,
  -- Last working set weight and reps
  (ARRAY_AGG(s.weight ORDER BY s.logged_at DESC) FILTER (WHERE s.set_type = 'working'))[1]
                                                                 AS last_weight,
  (ARRAY_AGG(s.reps ORDER BY s.logged_at DESC) FILTER (WHERE s.set_type = 'working'))[1]
                                                                 AS last_reps,
  AVG(s.rpe) FILTER (WHERE s.rpe IS NOT NULL AND s.set_type = 'working')
                                                                 AS avg_rpe_all,
  AVG(s.rpe) FILTER (
    WHERE s.rpe IS NOT NULL AND s.set_type = 'working'
      AND s.logged_at >= NOW() - interval '30 days'
  )                                                              AS avg_rpe_30d,
  MIN(s.logged_at)                                               AS first_logged_at,
  MAX(s.logged_at)                                               AS last_logged_at,
  COUNT(DISTINCT s.training_date)                                AS distinct_training_days,
  COUNT(DISTINCT s.training_date) FILTER (
    WHERE s.training_date >= CURRENT_DATE - 7
  )                                                              AS sessions_7d,
  COUNT(DISTINCT s.training_date) FILTER (
    WHERE s.training_date >= CURRENT_DATE - 30
  )                                                              AS sessions_30d
FROM sets s
JOIN exercises e ON e.id = s.exercise_id
GROUP BY s.user_id, s.exercise_id, e.name, e.movement_pattern, e.mechanic, e.is_compound;

COMMENT ON VIEW exercise_performance_summary IS
  'Per-exercise aggregated stats. Working sets only for weight/e1RM. RLS via security_invoker.';


-- =============================================================================
-- 8. VIEW: weekly_muscle_volume
-- =============================================================================

-- Weekly working sets per muscle group, weighted by biomechanical role.
-- Counting convention (Israetel, RP, 2021):
--   agonist (primary mover): 1.0 set
--   synergist (assists):     0.5 set
--   stabilizer:              0.0 set (not counted toward hypertrophy volume)
-- This aligns with "direct" vs "indirect" volume in the RP framework.
-- Excludes warmup sets per standard practice.
CREATE OR REPLACE VIEW weekly_muscle_volume
WITH (security_invoker = true) AS
SELECT
  s.user_id,
  date_trunc('week', s.training_date)::date                     AS week_start,
  mg.id                                                          AS muscle_group_id,
  mg.name                                                        AS muscle_group_name,
  -- Weighted set count per RP convention
  SUM(
    CASE em.function_type
      WHEN 'agonist'    THEN 1.0
      WHEN 'synergist'  THEN 0.5
      ELSE 0.0  -- stabilizer or unknown
    END
  )                                                              AS weighted_sets,
  -- Raw (unweighted) set count for reference
  COUNT(*)                                                       AS raw_sets,
  -- Volume (weight x reps, normalized to kg)
  SUM(
    CASE WHEN s.weight_unit = 'lb' THEN s.weight * 0.453592 ELSE s.weight END
    * s.reps
    * CASE em.function_type
        WHEN 'agonist'   THEN 1.0
        WHEN 'synergist' THEN 0.5
        ELSE 0.0
      END
  )                                                              AS weighted_volume_kg,
  AVG(s.rpe) FILTER (WHERE s.rpe IS NOT NULL)                    AS avg_rpe
FROM sets s
JOIN exercise_muscles em ON em.exercise_id = s.exercise_id
JOIN muscle_groups mg    ON mg.id = em.muscle_group_id
WHERE s.set_type IN ('working', 'backoff', 'failure')
  AND s.training_date IS NOT NULL
GROUP BY s.user_id, date_trunc('week', s.training_date), mg.id, mg.name;

COMMENT ON VIEW weekly_muscle_volume IS
  'Weekly sets per muscle group. Agonist=1.0, synergist=0.5, stabilizer=0.0 per RP convention. Excludes warmups.';


-- =============================================================================
-- 9. VIEW: movement_pattern_balance
-- =============================================================================

-- Weekly movement pattern ratios for injury prevention and programming balance.
-- Key ratios:
--   horizontal_push : horizontal_pull (target 1:1 to 1:1.5)
--     Kolber et al. (2009): >1.5:1 push:pull → shoulder impingement risk
--   vertical_push : vertical_pull (target ~1:1)
--   knee_dominant : hip_dominant (target ~1:1)
--     Extreme quad dominance → hamstring/ACL injury risk
-- Counts working sets only.
CREATE OR REPLACE VIEW movement_pattern_balance
WITH (security_invoker = true) AS
SELECT
  s.user_id,
  date_trunc('week', s.training_date)::date                     AS week_start,
  -- Per-pattern set counts
  COUNT(*) FILTER (WHERE e.movement_pattern = 'horizontal_push') AS horizontal_push_sets,
  COUNT(*) FILTER (WHERE e.movement_pattern = 'horizontal_pull') AS horizontal_pull_sets,
  COUNT(*) FILTER (WHERE e.movement_pattern = 'vertical_push')   AS vertical_push_sets,
  COUNT(*) FILTER (WHERE e.movement_pattern = 'vertical_pull')   AS vertical_pull_sets,
  COUNT(*) FILTER (WHERE e.movement_pattern IN ('squat', 'lunge')) AS knee_dominant_sets,
  COUNT(*) FILTER (WHERE e.movement_pattern = 'hip_hinge')       AS hip_dominant_sets,
  COUNT(*) FILTER (WHERE e.movement_pattern = 'carry')           AS carry_sets,
  COUNT(*) FILTER (WHERE e.movement_pattern = 'rotation')        AS rotation_sets,
  COUNT(*) FILTER (WHERE e.movement_pattern = 'isolation')       AS isolation_sets,
  -- Ratios (nullif to avoid division by zero)
  ROUND(
    COUNT(*) FILTER (WHERE e.movement_pattern = 'horizontal_push')::numeric
    / NULLIF(COUNT(*) FILTER (WHERE e.movement_pattern = 'horizontal_pull'), 0),
    2
  )                                                              AS h_push_pull_ratio,
  ROUND(
    COUNT(*) FILTER (WHERE e.movement_pattern = 'vertical_push')::numeric
    / NULLIF(COUNT(*) FILTER (WHERE e.movement_pattern = 'vertical_pull'), 0),
    2
  )                                                              AS v_push_pull_ratio,
  ROUND(
    COUNT(*) FILTER (WHERE e.movement_pattern IN ('squat', 'lunge'))::numeric
    / NULLIF(COUNT(*) FILTER (WHERE e.movement_pattern = 'hip_hinge'), 0),
    2
  )                                                              AS knee_hip_ratio,
  -- Total upper vs lower
  COUNT(*) FILTER (WHERE e.movement_pattern IN (
    'horizontal_push', 'horizontal_pull', 'vertical_push', 'vertical_pull'
  ))                                                             AS total_upper_sets,
  COUNT(*) FILTER (WHERE e.movement_pattern IN (
    'squat', 'hip_hinge', 'lunge'
  ))                                                             AS total_lower_sets
FROM sets s
JOIN exercises e ON e.id = s.exercise_id
WHERE s.set_type IN ('working', 'backoff', 'failure')
  AND s.training_date IS NOT NULL
  AND e.movement_pattern IS NOT NULL
GROUP BY s.user_id, date_trunc('week', s.training_date);

COMMENT ON VIEW movement_pattern_balance IS
  'Weekly movement pattern ratios. h_push_pull >1.5 flags shoulder impingement risk (Kolber, 2009).';


COMMIT;
