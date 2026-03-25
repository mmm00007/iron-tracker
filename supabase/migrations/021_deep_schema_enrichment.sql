-- Migration 021: Deep Schema Enrichment
-- Adds rest tracking, workout clustering, exercise depth, plan programming,
-- insights evidence, volume targets, mesocycles, and training day summaries.
--
-- Inspired by: github.com/mmm00007/gym-tracker data model
-- Validated by: fitness-domain-expert, database-specialist agents
--
-- Key design decisions (from expert validation):
--   - rest_seconds per set (NSCA: rest is a primary programming variable)
--   - workout_cluster_id via application-callable function (not row trigger, avoids recursion)
--   - function_type uses agonist/synergist/stabilizer only (no antagonist per kinesiology best practice)
--   - tempo_prescription on plan_items (goal-dependent, not exercise-inherent)
--   - mesocycle phases use user-friendly names (hypertrophy/strength/peaking vs Issurin terminology)
--   - volume targets enforce MV <= MEV <= MAV <= MRV ordering
--   - training_day_summary normalizes weight to kg for correct volume sums

BEGIN;

-- =============================================================================
-- 1. SETS: Rest period tracking
-- =============================================================================

-- Rest period (seconds) taken BEFORE performing this set.
-- NSCA (Ratamess et al., 2009) prescribes rest as primary programming variable.
-- Schoenfeld et al. (2016): longer rest (3min vs 1min) → superior hypertrophy & strength.
ALTER TABLE sets
  ADD COLUMN IF NOT EXISTS rest_seconds integer CHECK (rest_seconds > 0);

COMMENT ON COLUMN sets.rest_seconds IS 'Seconds rested before this set. Enables training density analysis and rest optimization.';

-- Index for time-windowed rest analysis queries (e.g., "avg rest for exercise X over 30 days")
CREATE INDEX IF NOT EXISTS sets_user_exercise_rest_idx
  ON sets (user_id, exercise_id, logged_at DESC)
  WHERE rest_seconds IS NOT NULL;


-- =============================================================================
-- 2. SETS: Workout clustering (gap-based session grouping)
-- =============================================================================

-- Workout cluster: groups sets within the same training_date that are >90 min apart.
-- Enables multi-workout-per-day tracking (AM cardio + PM strength).
-- Computed by application-callable function, NOT a row-level trigger (avoids recursion).
ALTER TABLE sets
  ADD COLUMN IF NOT EXISTS workout_cluster_id uuid;

COMMENT ON COLUMN sets.workout_cluster_id IS 'Gap-based session cluster. Sets >90min apart on same training_date form separate clusters. Computed via recompute_workout_clusters().';

-- Index for cluster-based queries
CREATE INDEX IF NOT EXISTS sets_user_date_cluster_idx
  ON sets (user_id, training_date, workout_cluster_id)
  WHERE workout_cluster_id IS NOT NULL;

-- Application-callable function to recompute clusters for a user's training date.
-- Called from backend after set insert/update/delete, not from a trigger.
-- Uses 90-minute gap threshold (configurable via cluster_gap_minutes profile column).
CREATE OR REPLACE FUNCTION recompute_workout_clusters(
  p_user_id uuid,
  p_training_date date
) RETURNS void AS $$
DECLARE
  v_gap_minutes integer;
  v_prev_logged_at timestamptz;
  v_cluster_id uuid;
  rec record;
BEGIN
  -- Get user's gap preference (default 90 min)
  SELECT COALESCE(cluster_gap_minutes, 90)
    INTO v_gap_minutes
    FROM profiles
    WHERE id = p_user_id;
  IF NOT FOUND THEN
    v_gap_minutes := 90;
  END IF;

  v_prev_logged_at := NULL;
  v_cluster_id := gen_random_uuid();

  FOR rec IN
    SELECT id, logged_at
    FROM sets
    WHERE user_id = p_user_id AND training_date = p_training_date
    ORDER BY logged_at ASC
  LOOP
    -- If gap from previous set exceeds threshold, start new cluster
    IF v_prev_logged_at IS NOT NULL
       AND EXTRACT(EPOCH FROM (rec.logged_at - v_prev_logged_at)) / 60 > v_gap_minutes
    THEN
      v_cluster_id := gen_random_uuid();
    END IF;

    UPDATE sets SET workout_cluster_id = v_cluster_id
    WHERE id = rec.id AND (workout_cluster_id IS DISTINCT FROM v_cluster_id);

    v_prev_logged_at := rec.logged_at;
  END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION recompute_workout_clusters IS 'Recomputes workout clusters for a user/date using gap-based grouping. Call from backend after set mutations.';

-- Restrict to service_role only — not callable by authenticated users via PostgREST RPC.
-- The backend passes JWT-validated user_id; direct RPC access would allow cross-user mutation.
REVOKE EXECUTE ON FUNCTION recompute_workout_clusters(uuid, date) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION recompute_workout_clusters(uuid, date) FROM authenticated;
GRANT EXECUTE ON FUNCTION recompute_workout_clusters(uuid, date) TO service_role;


-- =============================================================================
-- 3. PROFILES: Cluster gap preference
-- =============================================================================

-- User-configurable gap threshold for workout clustering (default 90 min).
-- Domain expert: 60-120 min is the common range across apps (STRONG, Hevy).
ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS cluster_gap_minutes smallint DEFAULT 90
    CHECK (cluster_gap_minutes >= 15 AND cluster_gap_minutes <= 480);

COMMENT ON COLUMN profiles.cluster_gap_minutes IS 'Minutes of inactivity that separates workout clusters within a day. Default 90.';


-- =============================================================================
-- 4. EXERCISES: Difficulty level
-- =============================================================================

-- 1-5 scale based on coordination demands and injury risk:
--   1=Beginner (machine-guided, minimal risk, no coaching)
--   2=Novice (free weights, single-joint, brief instruction sufficient)
--   3=Intermediate (multi-joint compounds, coaching recommended)
--   4=Advanced (complex compounds, significant technique investment)
--   5=Elite (Olympic lifts, advanced gymnastics, coaching required)
-- Distinct from existing `level` TEXT column which stores skill tier labels.
ALTER TABLE exercises
  ADD COLUMN IF NOT EXISTS difficulty_level smallint
    CHECK (difficulty_level >= 1 AND difficulty_level <= 5);

COMMENT ON COLUMN exercises.difficulty_level IS 'Coordination difficulty 1-5. Distinct from level (text skill tier). Based on motor complexity and injury risk.';

CREATE INDEX IF NOT EXISTS exercises_difficulty_idx
  ON exercises (difficulty_level)
  WHERE difficulty_level IS NOT NULL;


-- =============================================================================
-- 5. EXERCISES: Contraindications (safety warnings)
-- =============================================================================

-- Structured safety tags from controlled vocabulary.
-- NOT medical advice — general caution flags for common conditions.
-- Categories: shoulder_impingement, lower_back_herniation, knee_anterior,
--   wrist_strain, elbow_strain, neck_compression, rotator_cuff, hip_impingement
ALTER TABLE exercises
  ADD COLUMN IF NOT EXISTS contraindications text[] DEFAULT '{}';

COMMENT ON COLUMN exercises.contraindications IS 'Safety warning tags (e.g., shoulder_impingement). General caution flags, not medical advice.';

CREATE INDEX IF NOT EXISTS exercises_contraindications_idx
  ON exercises USING GIN (contraindications)
  WHERE contraindications != '{}';


-- =============================================================================
-- 6. EXERCISE_MUSCLES: Function type (biomechanical role)
-- =============================================================================

-- Kinesiology classification (Lippert, Clinical Kinesiology, 7th ed.):
--   agonist: primary mover (maps to is_primary = true)
--   synergist: assists the agonist in producing movement
--   stabilizer: stabilizes joints/posture during movement (includes fixators)
-- Antagonist excluded per domain expert: antagonists are not meaningfully
-- "activated" during exercises; model antagonist pairs separately if needed.
ALTER TABLE exercise_muscles
  ADD COLUMN IF NOT EXISTS function_type text
    CHECK (function_type IN ('agonist', 'synergist', 'stabilizer'));

COMMENT ON COLUMN exercise_muscles.function_type IS 'Biomechanical role: agonist (primary mover), synergist (assists), stabilizer (joint stability).';

CREATE INDEX IF NOT EXISTS exercise_muscles_function_idx
  ON exercise_muscles (exercise_id, function_type)
  WHERE function_type IS NOT NULL;


-- =============================================================================
-- 7. NEW TABLE: exercise_tags (user-customizable categorization)
-- =============================================================================

CREATE TABLE IF NOT EXISTS exercise_tags (
  id          uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  exercise_id uuid        NOT NULL REFERENCES exercises(id) ON DELETE RESTRICT,
  tag         text        NOT NULL CHECK (tag ~ '^[a-z0-9_-]+$' AND length(tag) <= 50),
  created_at  timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, exercise_id, tag)
);
COMMENT ON TABLE exercise_tags IS 'User-customizable exercise tags (e.g., arm-day, rehab, competition-lift).';

-- Index for "find all exercises with tag X" queries
CREATE INDEX IF NOT EXISTS exercise_tags_user_tag_idx
  ON exercise_tags (user_id, tag);

ALTER TABLE exercise_tags ENABLE ROW LEVEL SECURITY;

CREATE POLICY exercise_tags_select ON exercise_tags
  FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY exercise_tags_insert ON exercise_tags
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY exercise_tags_update ON exercise_tags
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY exercise_tags_delete ON exercise_tags
  FOR DELETE TO authenticated USING (user_id = auth.uid());


-- =============================================================================
-- 8. PLANS: Goal alignment
-- =============================================================================

-- Training goal for the plan. Separate from phase (which belongs on mesocycles).
-- Domain expert: peaking/deload are phases within a goal, not goals themselves.
ALTER TABLE plans
  ADD COLUMN IF NOT EXISTS goal text CHECK (goal IN (
    'strength',           -- Max force output (1-5 rep focus)
    'hypertrophy',        -- Muscle growth (6-12 rep focus)
    'endurance',          -- Muscular endurance (12+ rep focus)
    'power',              -- Explosive output (Olympic lifts, plyometrics)
    'general',            -- General fitness / GPP
    'body_recomposition'  -- Simultaneous fat loss + muscle gain
  ));

COMMENT ON COLUMN plans.goal IS 'Training goal alignment. Informs default RPE, rest, and rep ranges.';


-- =============================================================================
-- 9. PLAN_ITEMS: Intensity & rest prescriptions
-- =============================================================================

-- RPE target (half-point precision). Tuchscherer's 1-10 scale.
-- Used in powerlifting-oriented programs (RTS, Barbell Medicine).
ALTER TABLE plan_items
  ADD COLUMN IF NOT EXISTS target_rpe numeric(3,1)
    CHECK (target_rpe >= 1 AND target_rpe <= 10);

-- RIR target (Reps in Reserve). Used in hypertrophy programs (RP, Nippard).
-- Capped at 5; RIR > 5 is essentially warm-up level and rarely prescribed.
ALTER TABLE plan_items
  ADD COLUMN IF NOT EXISTS target_rir smallint
    CHECK (target_rir >= 0 AND target_rir <= 5);

-- Consistency constraint: if both RPE and RIR are set, they must agree within 1.
-- RPE 8 ~ RIR 2, so (10 - RPE) should be within 1 of RIR.
ALTER TABLE plan_items DROP CONSTRAINT IF EXISTS plan_items_rpe_rir_consistency;
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'plan_items_rpe_rir_consistency'
  ) THEN
    ALTER TABLE plan_items ADD CONSTRAINT plan_items_rpe_rir_consistency CHECK (
      target_rpe IS NULL OR target_rir IS NULL
      OR abs((10 - target_rpe) - target_rir) <= 1
    );
  END IF;
END $$;

-- Prescribed rest period between sets for this exercise.
-- NSCA defaults: strength 180-300s, hypertrophy 60-120s, endurance 30-60s.
ALTER TABLE plan_items
  ADD COLUMN IF NOT EXISTS rest_target_seconds integer
    CHECK (rest_target_seconds > 0);

-- Tempo prescription (4-digit: eccentric-pause-concentric-pause, e.g., "3110").
-- Placed on plan_items (not exercises) per domain expert: tempo is goal-dependent.
-- A bench press might be "3110" in hypertrophy and "10X0" (explosive) in strength.
ALTER TABLE plan_items
  ADD COLUMN IF NOT EXISTS tempo_prescription text;

-- Superset grouping: items with the same group number in the same plan_day
-- are performed in alternating fashion (supersets, trisets, circuits).
ALTER TABLE plan_items
  ADD COLUMN IF NOT EXISTS superset_group smallint;

CREATE INDEX IF NOT EXISTS plan_items_superset_idx
  ON plan_items (plan_day_id, superset_group)
  WHERE superset_group IS NOT NULL;


-- =============================================================================
-- 10. ANALYSIS_REPORTS: Structured evidence & classification
-- =============================================================================

-- Structured evidence array: [{source, metric, value, delta, sample_size, confidence}]
-- Enables traceable, auditable AI recommendations.
ALTER TABLE analysis_reports
  ADD COLUMN IF NOT EXISTS evidence jsonb DEFAULT '[]';

-- Report type classification.
ALTER TABLE analysis_reports
  ADD COLUMN IF NOT EXISTS report_type text CHECK (report_type IN (
    'recommendation',  -- General training recommendation
    'weekly_trend',    -- Weekly progress summary
    'deload_alert',    -- Deload/overreaching warning
    'pr_analysis',     -- Personal record analysis
    'balance_report',  -- Body-part balance assessment
    'volume_check'     -- Volume vs MV/MEV/MAV/MRV comparison
  ));

-- Processing status with default for backwards compatibility.
ALTER TABLE analysis_reports
  ADD COLUMN IF NOT EXISTS status text DEFAULT 'ready' CHECK (status IN (
    'ready',       -- Report is complete and viewable
    'failed',      -- Generation failed
    'in_progress', -- Currently generating
    'stale'        -- Data has changed since generation
  ));

-- Indexes for filtering reports by type and status
CREATE INDEX IF NOT EXISTS analysis_reports_type_idx
  ON analysis_reports (user_id, report_type)
  WHERE report_type IS NOT NULL;

CREATE INDEX IF NOT EXISTS analysis_reports_status_idx
  ON analysis_reports (user_id, status)
  WHERE status != 'ready';


-- =============================================================================
-- 11. NEW TABLE: training_volume_targets (personalized volume landmarks)
-- =============================================================================

-- Per-muscle-group weekly set targets. Replaces hardcoded population defaults
-- with user-personalizable thresholds.
-- Framework: Renaissance Periodization (Israetel et al., 2021)
--   MV  = Minimum Viable Volume (maintain muscle at minimum)
--   MEV = Minimum Effective Volume (minimum for adaptation)
--   MAV = Maximum Adaptive Volume (optimal range upper bound)
--   MRV = Maximum Recoverable Volume (exceed → overreaching)
CREATE TABLE IF NOT EXISTS training_volume_targets (
  id              uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  muscle_group_id integer     NOT NULL REFERENCES muscle_groups(id),
  target_mv       smallint    CHECK (target_mv >= 0),
  target_mev      smallint    CHECK (target_mev >= 0),
  target_mav      smallint    CHECK (target_mav >= 0),
  target_mrv      smallint    CHECK (target_mrv >= 0),
  notes           text,
  updated_at      timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, muscle_group_id),
  -- Enforce logical ordering: MV <= MEV <= MAV <= MRV
  CHECK (target_mv IS NULL OR target_mev IS NULL OR target_mv <= target_mev),
  CHECK (target_mev IS NULL OR target_mav IS NULL OR target_mev <= target_mav),
  CHECK (target_mav IS NULL OR target_mrv IS NULL OR target_mav <= target_mrv)
);
COMMENT ON TABLE training_volume_targets IS 'Personalized weekly set targets per muscle group. MV/MEV/MAV/MRV per RP framework.';

CREATE TRIGGER training_volume_targets_updated_at
  BEFORE UPDATE ON training_volume_targets
  FOR EACH ROW
  EXECUTE FUNCTION set_updated_at();

ALTER TABLE training_volume_targets ENABLE ROW LEVEL SECURITY;

CREATE POLICY training_volume_targets_select ON training_volume_targets
  FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY training_volume_targets_insert ON training_volume_targets
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY training_volume_targets_update ON training_volume_targets
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY training_volume_targets_delete ON training_volume_targets
  FOR DELETE TO authenticated USING (user_id = auth.uid());


-- =============================================================================
-- 12. NEW TABLE: mesocycles (periodization block tracking)
-- =============================================================================

-- Tracks training mesocycles (typically 3-6 weeks). Phase nomenclature uses
-- user-friendly names per domain expert (not Issurin academic terminology).
CREATE TABLE IF NOT EXISTS mesocycles (
  id            uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name          text        NOT NULL,
  phase         text        NOT NULL CHECK (phase IN (
    'hypertrophy',   -- High volume, moderate intensity (RP accumulation)
    'strength',      -- Moderate volume, high intensity (intensification)
    'peaking',       -- Low volume, very high intensity (realization)
    'deload',        -- Reduced volume/intensity for recovery
    'transition',    -- Off-season / between programs
    'general'        -- Undulating or concurrent (no specific phase)
  )),
  start_date    date        NOT NULL,
  end_date      date,
  target_weeks  smallint    CHECK (target_weeks >= 1 AND target_weeks <= 52),
  plan_id       uuid        REFERENCES plans(id) ON DELETE SET NULL,
  notes         text,
  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now(),
  CHECK (end_date IS NULL OR end_date >= start_date)
);
COMMENT ON TABLE mesocycles IS 'Training mesocycles for periodization tracking. Typically 3-6 weeks per block.';

CREATE INDEX IF NOT EXISTS mesocycles_user_date_idx
  ON mesocycles (user_id, start_date DESC);

CREATE TRIGGER mesocycles_updated_at
  BEFORE UPDATE ON mesocycles
  FOR EACH ROW
  EXECUTE FUNCTION set_updated_at();

ALTER TABLE mesocycles ENABLE ROW LEVEL SECURITY;

CREATE POLICY mesocycles_select ON mesocycles
  FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY mesocycles_insert ON mesocycles
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY mesocycles_update ON mesocycles
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY mesocycles_delete ON mesocycles
  FOR DELETE TO authenticated USING (user_id = auth.uid());


-- =============================================================================
-- 13. VIEW: training_day_summary
-- =============================================================================

-- Aggregate view for training day analytics. Uses SECURITY INVOKER for RLS.
-- Normalizes weight to kg for correct volume sums (avoids mixing units).
-- Duration = first-to-last set span (does not include post-last-set time).
CREATE OR REPLACE VIEW training_day_summary
WITH (security_invoker = true) AS
SELECT
  user_id,
  training_date,
  COUNT(*)                                                AS total_sets,
  COUNT(*) FILTER (WHERE set_type = 'working')            AS working_sets,
  SUM(reps)                                               AS total_reps,
  SUM(
    CASE WHEN weight_unit = 'lb' THEN weight * 0.453592 ELSE weight END
    * reps
  )                                                       AS total_volume_kg,
  COUNT(DISTINCT exercise_id)                             AS distinct_exercises,
  AVG(rpe) FILTER (WHERE rpe IS NOT NULL)                 AS avg_rpe,
  AVG(rest_seconds) FILTER (WHERE rest_seconds IS NOT NULL) AS avg_rest_seconds,
  MIN(logged_at)                                          AS first_set_at,
  MAX(logged_at)                                          AS last_set_at,
  EXTRACT(EPOCH FROM MAX(logged_at) - MIN(logged_at)) / 60 AS duration_minutes,
  COUNT(DISTINCT workout_cluster_id)                      AS cluster_count,
  MAX(estimated_1rm) FILTER (WHERE set_type = 'working')  AS best_estimated_1rm
FROM sets
WHERE training_date IS NOT NULL
GROUP BY user_id, training_date;

COMMENT ON VIEW training_day_summary IS 'Per-training-day aggregates. Volume normalized to kg. Duration = first-to-last set span. RLS via security_invoker.';


-- =============================================================================
-- 14. AUTO-DERIVE function_type from is_primary (backfill)
-- =============================================================================

-- Set function_type = 'agonist' where is_primary = true and function_type is null
UPDATE exercise_muscles
SET function_type = 'agonist'
WHERE is_primary = true AND function_type IS NULL;

-- Set function_type = 'synergist' where is_primary = false and activation_percent >= 40
UPDATE exercise_muscles
SET function_type = 'synergist'
WHERE is_primary = false AND function_type IS NULL
  AND activation_percent IS NOT NULL AND activation_percent >= 40;

-- Set function_type = 'stabilizer' where is_primary = false and activation_percent < 40
UPDATE exercise_muscles
SET function_type = 'stabilizer'
WHERE is_primary = false AND function_type IS NULL
  AND activation_percent IS NOT NULL AND activation_percent < 40;

COMMIT;
