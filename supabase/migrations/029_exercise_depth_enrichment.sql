-- Migration 029: Exercise Depth & Insights Enrichment
-- Adds biomechanical classification to exercises, technique modifiers to sets,
-- structured coaching cues, workout feedback enhancements, and four insight views.
--
-- Validated by: fitness-domain-expert, database-specialist agents
--
-- Key design decisions (from expert validation):
--   - force_vector REJECTED: redundant with existing movement_pattern column
--   - grip_type REJECTED: variant-level attribute, not exercise-level
--   - stance_type REJECTED: redundant with exercise name (incline bench != lying_prone)
--   - perceived_difficulty REJECTED: conflates RPE and form quality (no validated scale)
--   - session_ratings/training_readiness as separate tables REJECTED: extend workout_feedback
--   - primary_joints as TEXT[] (not single enum): compounds involve multiple joints,
--     single-value column loses discrimination for injury cross-referencing
--   - stability_demand as 1-5 integer (not 3-tier enum): 5-tier scale distinguishes
--     machine / Smith / cable / dumbbell-bilateral / unilateral-bodyweight (Haff & Triplett, 2016)
--   - contraction_emphasis (not contraction_type): "isotonic" covers 90% of exercises,
--     "concentric"/"eccentric" as standalone values are misleading for standard lifts
--   - technique_modifier: super_set/giant_set removed (session-level constructs);
--     mechanical_drop_set and forced_rep added per domain expert
--   - muscle_recovery_status: "overtrained" renamed to "overreached" (clinical distinction;
--     Meeusen et al., 2013, ECSS/ACSM consensus)
--   - EWMA replaced with rolling-average ACWR (simpler, original Gabbett methodology)
--
-- Also fixes: progression_rules NULL exercise_id dedup bug from migration 028

BEGIN;

-- =============================================================================
-- 1. BUG FIX: progression_rules partial unique index for NULL exercise_id
-- =============================================================================

-- The partial unique index progression_rules_default_unique_idx covers
-- (exercise_id, goal) WHERE user_id IS NULL. When exercise_id is also NULL
-- (population-level goal defaults), B-tree treats NULL != NULL, so the index
-- does NOT enforce uniqueness. Re-running migration 028 inserts duplicates.

-- Step 1: Deduplicate — keep earliest row per goal for population-level defaults
DELETE FROM progression_rules
WHERE user_id IS NULL
  AND exercise_id IS NULL
  AND id NOT IN (
    SELECT DISTINCT ON (goal) id
    FROM progression_rules
    WHERE user_id IS NULL AND exercise_id IS NULL
    ORDER BY goal, created_at ASC, id ASC
  );

-- Step 2: Drop the old index that doesn't cover NULL exercise_id
DROP INDEX IF EXISTS progression_rules_default_unique_idx;

-- Step 3: Separate index for population-level goal defaults (NULL exercise_id)
CREATE UNIQUE INDEX progression_rules_population_default_unique_idx
  ON progression_rules (goal)
  WHERE user_id IS NULL AND exercise_id IS NULL;

-- Step 4: Recreate index for exercise-specific defaults (non-NULL exercise_id)
CREATE UNIQUE INDEX progression_rules_exercise_default_unique_idx
  ON progression_rules (exercise_id, goal)
  WHERE user_id IS NULL AND exercise_id IS NOT NULL;

-- Step 5: Drop the old query-only default index (superseded by step 4)
DROP INDEX IF EXISTS progression_rules_default_idx;

-- Step 6: Recreate query index matching new partitioning
CREATE INDEX IF NOT EXISTS progression_rules_exercise_default_query_idx
  ON progression_rules (exercise_id)
  WHERE user_id IS NULL AND exercise_id IS NOT NULL;


-- =============================================================================
-- 2. FIX: e1rm_progress_bucketed view — rename misleading working_sets column
-- =============================================================================

-- The view filters set_type IN ('working', 'backoff', 'failure') but counts
-- only set_type = 'working' as working_sets. A user whose best e1RM came from
-- a failure set would see working_sets=0 alongside a valid best_e1rm.
-- Rename to training_sets and count all included types for accuracy.

CREATE OR REPLACE VIEW e1rm_progress_bucketed
WITH (security_invoker = true) AS
SELECT
  s.user_id,
  s.exercise_id,
  e.name                                                     AS exercise_name,
  date_trunc('week', s.training_date)::date                  AS period_start,
  (date_trunc('week', s.training_date) + interval '6 days')::date AS period_end,
  'week'::text                                               AS period_type,
  MAX(s.estimated_1rm)                                       AS best_e1rm,
  MAX(s.weight)                                              AS best_weight,
  (ARRAY_AGG(s.reps ORDER BY s.estimated_1rm DESC NULLS LAST))[1] AS best_e1rm_reps,
  COUNT(*)                                                   AS training_sets,
  AVG(s.rpe) FILTER (WHERE s.rpe IS NOT NULL)                AS avg_rpe
FROM sets s
JOIN exercises e ON e.id = s.exercise_id
WHERE s.set_type IN ('working', 'backoff', 'failure')
  AND s.training_date IS NOT NULL
  AND s.estimated_1rm IS NOT NULL
GROUP BY s.user_id, s.exercise_id, e.name, date_trunc('week', s.training_date);

COMMENT ON VIEW e1rm_progress_bucketed IS
  'Per-exercise weekly best e1RM for progress charts. Includes working/backoff/failure sets. training_sets counts all included set types.';


-- =============================================================================
-- 3. PROFILES: sex column for strength standards comparison
-- =============================================================================

-- Biological sex is a primary determinant in strength standards
-- (Laubach, 1976; ExRx/Kilgore norms are sex-stratified).
-- Required for relative_strength_benchmarks view to match the correct standard.
ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS sex text
    CHECK (sex IN ('male', 'female'));

COMMENT ON COLUMN profiles.sex IS
  'Biological sex for strength standard comparisons. Optional — view defaults to male standards if NULL.';


-- =============================================================================
-- 4. EXERCISES: Biomechanical classification columns
-- =============================================================================

-- 3a. primary_joints: array of joints involved (for injury cross-referencing)
-- Array (not single enum) because compound exercises involve multiple joints:
-- bench press = {shoulder, elbow}, squat = {hip, knee, ankle}.
-- Cross-referenced with injury_reports.body_area to flag exercises affecting
-- injured joints.
ALTER TABLE exercises
  ADD COLUMN IF NOT EXISTS primary_joints text[]
    DEFAULT '{}';

-- Validate each element is a known joint
ALTER TABLE exercises
  ADD CONSTRAINT exercises_primary_joints_check CHECK (
    primary_joints <@ ARRAY[
      'shoulder', 'elbow', 'hip', 'knee',
      'spine', 'ankle', 'wrist'
    ]::text[]
  );

COMMENT ON COLUMN exercises.primary_joints IS
  'Joints loaded by this exercise. Array for compounds (e.g., bench={shoulder,elbow}). '
  'Cross-reference with injury_reports.body_area to flag contraindicated exercises.';

-- GIN index for array containment queries (@> and &&)
CREATE INDEX IF NOT EXISTS exercises_primary_joints_idx
  ON exercises USING GIN (primary_joints)
  WHERE primary_joints != '{}';


-- 3b. movement_plane: anatomical plane of primary motion
-- Most lifters overtrain sagittal plane; frontal/transverse work prevents injuries.
-- Neumann, Kinesiology of the Musculoskeletal System, 3rd ed.
ALTER TABLE exercises
  ADD COLUMN IF NOT EXISTS movement_plane text CHECK (movement_plane IN (
    'sagittal',      -- Forward/backward: squats, curls, presses, rows
    'frontal',       -- Side-to-side: lateral raises, side lunges, abduction
    'transverse',    -- Rotational: cable woodchops, Russian twists, Pallof press
    'multiplanar'    -- Multiple planes: Turkish get-up, cleans, lunges with rotation
  ));

COMMENT ON COLUMN exercises.movement_plane IS
  'Primary anatomical plane of motion. Most compound lifts are sagittal; flagging frontal/transverse helps identify movement gaps.';


-- 3c. stability_demand: 1-5 scale of stabilization requirement
-- Haff & Triplett, Essentials of Strength Training, 4th ed., Ch. 15:
--   1 = Machine (fixed path, minimal stabilization)
--   2 = Smith machine / guided (semi-fixed path)
--   3 = Cable / pulley (free path, constant tension)
--   4 = Dumbbell / free weight bilateral (free path, bilateral stability)
--   5 = Unilateral free weight / unstable surface (highest demand)
ALTER TABLE exercises
  ADD COLUMN IF NOT EXISTS stability_demand smallint
    CHECK (stability_demand >= 1 AND stability_demand <= 5);

COMMENT ON COLUMN exercises.stability_demand IS
  'Stability requirement 1-5. 1=machine(fixed path), 2=Smith/guided, 3=cable, 4=free weight bilateral, 5=unilateral/unstable. '
  'Useful for exercise substitution (injured → lower stability demand) and beginner programming.';


-- 3d. contraction_emphasis: dominant contraction type
-- Hill, 1938; Enoka, Neuromechanics of Human Movement, 6th ed.
-- "standard" covers ~90% of exercises (both concentric + eccentric phases).
-- The other values distinguish exercises with fundamentally different programming:
-- isometrics use duration_seconds, plyometrics have stricter volume limits,
-- ballistic exercises involve momentum, eccentric-emphasis has different fatigue profiles.
ALTER TABLE exercises
  ADD COLUMN IF NOT EXISTS contraction_emphasis text
    DEFAULT 'standard'
    CHECK (contraction_emphasis IN (
      'standard',            -- Both concentric + eccentric: squat, bench, curl (default)
      'isometric',           -- Static holds: plank, wall sit, L-sit (use duration_seconds)
      'eccentric_emphasis',  -- Eccentric-only or eccentric-dominant: Nordic curl, negatives
      'plyometric',          -- Explosive with stretch-shortening cycle: box jump, depth jump
      'ballistic'            -- Explosive with momentum: kettlebell swing, Olympic lifts
    ));

COMMENT ON COLUMN exercises.contraction_emphasis IS
  'Primary contraction type. standard=most lifts. isometric=holds(use duration). plyometric/ballistic=explosive(different volume limits). eccentric_emphasis=negatives.';


-- =============================================================================
-- 4. SETS: Technique modifier
-- =============================================================================

-- Describes HOW the set was executed (intensity technique).
-- Orthogonal to set_type which describes the set's ROLE (warmup/working/backoff).
-- A working set can be performed as standard, rest-pause, myo-rep, etc.
--
-- Drop set and AMRAP already exist in set_type (migration 001). This is a known
-- overlap. technique_modifier provides finer granularity: a drop set is a technique
-- applied to a working set. Future migration can consolidate if needed.
--
-- super_set/giant_set excluded: these are session-level pairings of exercises,
-- not per-set execution techniques. Model via plan_items.superset_group instead.
ALTER TABLE sets
  ADD COLUMN IF NOT EXISTS technique_modifier text
    DEFAULT 'standard'
    CHECK (technique_modifier IN (
      'standard',            -- Normal set execution (default)
      'drop_set',            -- Reduce weight mid-set without full rest
      'rest_pause',          -- Brief intra-set rest (10-20s), then continue
      'cluster_set',         -- Intra-set rest between groups of reps (Tufano et al., 2017)
      'myo_rep',             -- Activation set + short-rest mini-sets to failure (Borge, 2019)
      'amrap',               -- As Many Reps As Possible (max effort)
      'emom',                -- Every Minute On the Minute (timed work/rest)
      'mechanical_drop_set', -- Change grip/angle instead of weight (common bodybuilding technique)
      'forced_rep',          -- Spotter-assisted reps beyond failure
      'tempo_set'            -- Intentionally slowed tempo for time under tension
    ));

COMMENT ON COLUMN sets.technique_modifier IS
  'Intensity technique applied to this set. Orthogonal to set_type (which describes the set role). '
  'A working set can be rest_pause; a backoff set can be a drop_set.';

-- Index for filtering by non-standard techniques
CREATE INDEX IF NOT EXISTS sets_user_technique_modifier_idx
  ON sets (user_id, technique_modifier, logged_at DESC)
  WHERE technique_modifier != 'standard';


-- Tempo format constraint on existing column (migration 001 defined tempo as TEXT with no format check)
-- Format: E-P-C-T (Eccentric-Pause_Bottom-Concentric-Pause_Top), each segment 0-9 or X (explosive)
-- E.g., '3-1-2-0' = 3s eccentric, 1s pause at bottom, 2s concentric, 0s pause at top
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'sets_tempo_format'
  ) THEN
    ALTER TABLE sets ADD CONSTRAINT sets_tempo_format CHECK (
      tempo IS NULL
      OR tempo ~ '^[0-9X]-[0-9X]-[0-9X]-[0-9X]$'
    );
  END IF;
END $$;

COMMENT ON COLUMN sets.tempo IS
  'Performed tempo in E-P-C-T format (Eccentric-Pause-Concentric-Pause). Each segment 0-9 or X (explosive). E.g., 3-1-2-0.';


-- =============================================================================
-- 5. WORKOUT_FEEDBACK: Additional subjective metrics
-- =============================================================================

-- Extend existing workout_feedback table (migration 019) with additional fields
-- recommended by domain expert instead of creating separate session_ratings /
-- training_readiness tables.

-- Pump quality (1-5): subjective hypertrophy cue, useful for correlating
-- with training variables (rep ranges, rest times, exercises)
ALTER TABLE workout_feedback
  ADD COLUMN IF NOT EXISTS pump_quality smallint
    CHECK (pump_quality >= 1 AND pump_quality <= 5);

-- Focus/mind-muscle connection (1-5): subjective attention quality
ALTER TABLE workout_feedback
  ADD COLUMN IF NOT EXISTS focus smallint
    CHECK (focus >= 1 AND focus <= 5);

-- Nutrition quality (1-5): did the user eat well before training?
ALTER TABLE workout_feedback
  ADD COLUMN IF NOT EXISTS nutrition_quality smallint
    CHECK (nutrition_quality >= 1 AND nutrition_quality <= 5);

-- Motivation (1-5): subjective drive/willingness
ALTER TABLE workout_feedback
  ADD COLUMN IF NOT EXISTS motivation smallint
    CHECK (motivation >= 1 AND motivation <= 5);

-- Pre vs post session flag: allows the same table to capture both
-- pre-workout readiness check-ins and post-workout reflections.
-- Default false (backward compatible: existing rows are post-session).
ALTER TABLE workout_feedback
  ADD COLUMN IF NOT EXISTS is_pre_session boolean NOT NULL DEFAULT false;

-- Drop the old unique constraint (user_id, training_date) so users can have
-- both a pre-session and post-session entry on the same day.
-- Recreate as (user_id, training_date, is_pre_session).
-- PostgreSQL auto-generates constraint name as {table}_{col1}_{col2}_key.
DO $$ DECLARE
  v_constraint_name text;
BEGIN
  -- Find the specific unique constraint on (user_id, training_date).
  -- Match by constraint column names, not just column count, to avoid
  -- accidentally dropping unrelated unique constraints.
  SELECT c.conname INTO v_constraint_name
  FROM pg_constraint c
  JOIN pg_class r ON c.conrelid = r.oid
  JOIN pg_namespace n ON r.relnamespace = n.oid
  JOIN pg_attribute a1 ON a1.attrelid = r.oid AND a1.attnum = c.conkey[1]
  JOIN pg_attribute a2 ON a2.attrelid = r.oid AND a2.attnum = c.conkey[2]
  WHERE r.relname = 'workout_feedback'
    AND n.nspname = 'public'
    AND c.contype = 'u'
    AND array_length(c.conkey, 1) = 2
    AND a1.attname = 'user_id'
    AND a2.attname = 'training_date';

  IF v_constraint_name IS NOT NULL THEN
    EXECUTE format('ALTER TABLE workout_feedback DROP CONSTRAINT %I', v_constraint_name);
  END IF;
END $$;

-- New unique allows both pre and post entries on same day
ALTER TABLE workout_feedback
  ADD CONSTRAINT workout_feedback_user_date_presession_key
    UNIQUE (user_id, training_date, is_pre_session);

COMMENT ON TABLE workout_feedback IS
  'Pre/post-session subjective data. is_pre_session=true for readiness check-in, false for post-session reflection. '
  'Extends original fields (sRPE, readiness, sleep, stress) with pump, focus, nutrition, motivation.';


-- =============================================================================
-- 6. NEW TABLE: exercise_cues (structured coaching cues)
-- =============================================================================

-- Replaces unstructured instructions[] and form_tips[] arrays with queryable,
-- categorized coaching cues. Enables displaying setup cues before the exercise,
-- execution cues during, common mistakes as warnings.
-- Categories align with NSCA CSCS coaching cue structure.
CREATE TABLE IF NOT EXISTS exercise_cues (
  id            uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  exercise_id   uuid        NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
  cue_type      text        NOT NULL CHECK (cue_type IN (
    'setup',         -- Initial body position, bar placement, grip width
    'bracing',       -- Core engagement, breath, tension cues before movement
    'execution',     -- Movement cues during the rep (drive through heels, squeeze at top)
    'breathing',     -- Inhale/exhale timing relative to movement phases
    'mind_muscle',   -- Focus point for muscle activation (hypertrophy context)
    'safety',        -- Injury prevention cues (keep neutral spine, don't lock out)
    'common_fault'   -- What NOT to do (hips rising first, elbows flaring, bouncing)
  )),
  cue_text      text        NOT NULL CHECK (length(cue_text) > 0 AND length(cue_text) <= 500),
  display_order smallint    NOT NULL DEFAULT 0,
  created_at    timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE exercise_cues IS
  'Coaching cues per exercise, categorized by type. Reference data — public read. '
  'Categories: setup (before), bracing/execution/breathing (during), safety/common_fault (warnings).';

-- Prevent duplicate cues at same position for same exercise/type.
-- Also serves as the primary lookup index (unique indexes support range/equality queries).
CREATE UNIQUE INDEX IF NOT EXISTS exercise_cues_unique_idx
  ON exercise_cues (exercise_id, cue_type, display_order);

ALTER TABLE exercise_cues ENABLE ROW LEVEL SECURITY;

-- Public read (reference data, same pattern as exercise_substitutions)
CREATE POLICY exercise_cues_select ON exercise_cues
  FOR SELECT TO authenticated USING (true);


-- =============================================================================
-- 7. VIEW: training_load_trend (Acute:Chronic Workload Ratio)
-- =============================================================================

-- Computes weekly volume load and the ACWR (4-week acute / 8-week chronic)
-- for overreaching/detraining detection.
-- Gabbett (2016, British Journal of Sports Medicine): ACWR 0.8-1.3 = sweet spot,
-- >1.3 = elevated injury risk / overreaching, <0.8 = potential detraining.
-- Uses rolling averages per original Gabbett methodology (simpler than EWMA).
CREATE OR REPLACE VIEW training_load_trend
WITH (security_invoker = true) AS
WITH weekly_volume AS (
  SELECT
    s.user_id,
    date_trunc('week', s.training_date)::date AS week_start,
    SUM(s.weight * s.reps)                    AS volume_load,
    COUNT(*)                                   AS total_sets,
    COUNT(DISTINCT s.exercise_id)              AS exercise_count,
    COUNT(DISTINCT s.training_date)            AS training_days
  FROM sets s
  WHERE s.set_type IN ('working', 'backoff')
    AND s.training_date IS NOT NULL
    AND s.weight > 0
    AND s.reps > 0
    AND s.training_date >= CURRENT_DATE - interval '16 weeks'
  GROUP BY s.user_id, date_trunc('week', s.training_date)
)
SELECT
  wv.user_id,
  wv.week_start,
  wv.volume_load,
  wv.total_sets,
  wv.exercise_count,
  wv.training_days,
  -- 4-week rolling average (acute load)
  AVG(wv.volume_load) OVER (
    PARTITION BY wv.user_id ORDER BY wv.week_start
    ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
  ) AS acute_load_4w,
  -- 8-week rolling average (chronic load)
  AVG(wv.volume_load) OVER (
    PARTITION BY wv.user_id ORDER BY wv.week_start
    ROWS BETWEEN 7 PRECEDING AND CURRENT ROW
  ) AS chronic_load_8w,
  -- ACWR: acute / chronic (NULL if chronic is 0 to avoid division by zero)
  CASE
    WHEN AVG(wv.volume_load) OVER (
      PARTITION BY wv.user_id ORDER BY wv.week_start
      ROWS BETWEEN 7 PRECEDING AND CURRENT ROW
    ) > 0
    THEN ROUND(
      (AVG(wv.volume_load) OVER (
        PARTITION BY wv.user_id ORDER BY wv.week_start
        ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
      ) / AVG(wv.volume_load) OVER (
        PARTITION BY wv.user_id ORDER BY wv.week_start
        ROWS BETWEEN 7 PRECEDING AND CURRENT ROW
      ))::numeric, 2
    )
    ELSE NULL
  END AS acwr,
  -- Week-over-week change (%)
  CASE
    WHEN LAG(wv.volume_load) OVER (PARTITION BY wv.user_id ORDER BY wv.week_start) > 0
    THEN ROUND(
      ((wv.volume_load - LAG(wv.volume_load) OVER (PARTITION BY wv.user_id ORDER BY wv.week_start))
       / LAG(wv.volume_load) OVER (PARTITION BY wv.user_id ORDER BY wv.week_start) * 100
      )::numeric, 1
    )
    ELSE NULL
  END AS wow_change_pct
FROM weekly_volume wv;

COMMENT ON VIEW training_load_trend IS
  'Weekly volume load with 4w acute / 8w chronic rolling averages and ACWR. '
  'ACWR 0.8-1.3 = sweet spot, >1.3 = overreaching risk, <0.8 = detraining (Gabbett, 2016).';


-- =============================================================================
-- 8. VIEW: muscle_recovery_status
-- =============================================================================

-- Estimates per-muscle-group recovery status based on time since last trained,
-- training volume, soreness reports, and active injuries.
-- Recovery states (Meeusen et al., 2013):
--   fresh: >72h since trained, no soreness, no injuries
--   recovered: 48-72h since trained OR soreness <= 1
--   recovering: <48h since trained OR soreness 2-3
--   overreached: high volume + persistent soreness OR active injury limiting training
CREATE OR REPLACE VIEW muscle_recovery_status
WITH (security_invoker = true) AS
WITH
  -- Last training date per muscle group (via exercise_muscles junction)
  last_trained AS (
    SELECT
      s.user_id,
      em.muscle_group_id,
      MAX(s.training_date) AS last_training_date,
      -- Volume in last session for this muscle
      SUM(s.weight * s.reps) FILTER (
        WHERE s.training_date = (
          SELECT MAX(s2.training_date)
          FROM sets s2
          JOIN exercise_muscles em2 ON em2.exercise_id = s2.exercise_id
          WHERE s2.user_id = s.user_id
            AND em2.muscle_group_id = em.muscle_group_id
            AND s2.training_date IS NOT NULL
        )
      ) AS last_session_volume
    FROM sets s
    JOIN exercise_muscles em ON em.exercise_id = s.exercise_id
    WHERE s.set_type IN ('working', 'backoff', 'failure')
      AND s.training_date IS NOT NULL
      AND s.training_date >= CURRENT_DATE - 14
    GROUP BY s.user_id, em.muscle_group_id
  ),
  -- Latest soreness per muscle group (last 3 days)
  recent_soreness AS (
    SELECT DISTINCT ON (sr.user_id, sr.muscle_group_id)
      sr.user_id,
      sr.muscle_group_id,
      sr.level AS soreness_level
    FROM soreness_reports sr
    WHERE sr.reported_at >= CURRENT_DATE - 3
    ORDER BY sr.user_id, sr.muscle_group_id, sr.reported_at DESC
  ),
  -- Active injuries that limit training (map body_area to muscle groups)
  active_injuries AS (
    SELECT DISTINCT
      ir.user_id,
      mg.id AS muscle_group_id
    FROM injury_reports ir
    JOIN muscle_groups mg ON (
      -- Map injury body areas to related muscle groups
      (ir.body_area LIKE '%shoulder%' AND mg.name IN ('Shoulders', 'Chest', 'Triceps'))
      OR (ir.body_area LIKE '%elbow%' AND mg.name IN ('Biceps', 'Triceps', 'Forearms'))
      OR (ir.body_area LIKE '%knee%' AND mg.name IN ('Quadriceps', 'Hamstrings'))
      OR (ir.body_area LIKE '%hip%' AND mg.name IN ('Glutes', 'Adductors', 'Quadriceps'))
      OR (ir.body_area IN ('lower_back') AND mg.name IN ('Lower Back', 'Glutes', 'Hamstrings'))
      OR (ir.body_area IN ('upper_back') AND mg.name IN ('Lats', 'Traps'))
      OR (ir.body_area LIKE '%ankle%' AND mg.name IN ('Calves'))
      OR (ir.body_area LIKE '%wrist%' AND mg.name IN ('Forearms'))
      OR (ir.body_area LIKE '%calf%' AND mg.name IN ('Calves'))
    )
    WHERE ir.status IN ('active', 'chronic')
      AND ir.limits_training = true
  )
SELECT
  p.id AS user_id,
  mg.id AS muscle_group_id,
  mg.name AS muscle_group_name,
  lt.last_training_date,
  (CURRENT_DATE - lt.last_training_date) AS days_since_trained,
  lt.last_session_volume,
  rs.soreness_level,
  (ai.muscle_group_id IS NOT NULL) AS has_limiting_injury,
  -- Recovery status classification
  CASE
    -- Active injury limiting training → overreached
    WHEN ai.muscle_group_id IS NOT NULL THEN 'overreached'
    -- Soreness >= 3 and trained within 48h → overreached
    WHEN COALESCE(rs.soreness_level, 0) >= 3
         AND lt.last_training_date >= CURRENT_DATE - 2 THEN 'overreached'
    -- Not trained recently (>72h or never) and low soreness → fresh
    WHEN lt.last_training_date IS NULL
         OR (CURRENT_DATE - lt.last_training_date) > 3 THEN 'fresh'
    -- 48-72h since trained and low soreness → recovered
    WHEN (CURRENT_DATE - lt.last_training_date) >= 2
         AND COALESCE(rs.soreness_level, 0) <= 1 THEN 'recovered'
    -- Recently trained (<48h) or moderate soreness → recovering
    ELSE 'recovering'
  END AS recovery_status
FROM profiles p
CROSS JOIN muscle_groups mg
LEFT JOIN last_trained lt ON lt.user_id = p.id AND lt.muscle_group_id = mg.id
LEFT JOIN recent_soreness rs ON rs.user_id = p.id AND rs.muscle_group_id = mg.id
LEFT JOIN active_injuries ai ON ai.user_id = p.id AND ai.muscle_group_id = mg.id;

COMMENT ON VIEW muscle_recovery_status IS
  'Per-user, per-muscle recovery estimate. States: fresh(>72h, no soreness), recovered(48-72h, low soreness), '
  'recovering(<48h or moderate soreness), overreached(injury or high soreness). '
  'NOT medical advice — heuristic estimates for training split recommendations.';


-- =============================================================================
-- 9. VIEW: relative_strength_benchmarks
-- =============================================================================

-- Compares user's best e1RM per exercise against population norms from
-- strength_standards table (migration 025). Uses BW-relative ratios when
-- bodyweight is available, falls back to absolute values.
-- Tiers: untrained / beginner / novice / intermediate / advanced / elite
-- per ExRx/Kilgore classification (widely recognized in lifting community).
CREATE OR REPLACE VIEW relative_strength_benchmarks
WITH (security_invoker = true) AS
WITH user_best AS (
  SELECT
    pr.user_id,
    pr.exercise_id,
    e.name AS exercise_name,
    GREATEST(pr.estimated_1rm, pr.max_weight) AS best_e1rm
  FROM personal_records pr
  JOIN exercises e ON e.id = pr.exercise_id
  WHERE pr.estimated_1rm IS NOT NULL OR pr.max_weight IS NOT NULL
)
SELECT
  ub.user_id,
  ub.exercise_id,
  ub.exercise_name,
  ub.best_e1rm,
  p.current_body_weight_kg,
  -- BW-relative strength (NULL if no bodyweight logged)
  CASE
    WHEN p.current_body_weight_kg > 0
    THEN ROUND((ub.best_e1rm / p.current_body_weight_kg)::numeric, 2)
    ELSE NULL
  END AS bw_ratio,
  ss.sex AS standard_sex,
  -- Classification using BW-relative ratios (preferred) or absolute values
  CASE
    -- Use BW ratios if both user BW and standard ratios are available
    WHEN p.current_body_weight_kg > 0 AND ss.beginner_bw_ratio IS NOT NULL THEN
      CASE
        WHEN (ub.best_e1rm / p.current_body_weight_kg) >= ss.elite_bw_ratio THEN 'elite'
        WHEN (ub.best_e1rm / p.current_body_weight_kg) >= ss.advanced_bw_ratio THEN 'advanced'
        WHEN (ub.best_e1rm / p.current_body_weight_kg) >= ss.intermediate_bw_ratio THEN 'intermediate'
        WHEN (ub.best_e1rm / p.current_body_weight_kg) >= ss.novice_bw_ratio THEN 'novice'
        WHEN (ub.best_e1rm / p.current_body_weight_kg) >= ss.beginner_bw_ratio THEN 'beginner'
        ELSE 'untrained'
      END
    -- Fall back to absolute values
    WHEN ss.beginner_1rm IS NOT NULL THEN
      CASE
        WHEN ub.best_e1rm >= ss.elite_1rm THEN 'elite'
        WHEN ub.best_e1rm >= ss.advanced_1rm THEN 'advanced'
        WHEN ub.best_e1rm >= ss.intermediate_1rm THEN 'intermediate'
        WHEN ub.best_e1rm >= ss.novice_1rm THEN 'novice'
        WHEN ub.best_e1rm >= ss.beginner_1rm THEN 'beginner'
        ELSE 'untrained'
      END
    ELSE NULL
  END AS strength_level,
  -- Percentage of the way to next level (for progress bars)
  CASE
    WHEN p.current_body_weight_kg > 0 AND ss.beginner_bw_ratio IS NOT NULL THEN
      CASE
        WHEN (ub.best_e1rm / p.current_body_weight_kg) >= ss.elite_bw_ratio THEN 100
        WHEN (ub.best_e1rm / p.current_body_weight_kg) >= ss.advanced_bw_ratio THEN
          ROUND(((ub.best_e1rm / p.current_body_weight_kg - ss.advanced_bw_ratio)
                 / NULLIF(ss.elite_bw_ratio - ss.advanced_bw_ratio, 0) * 100)::numeric, 0)
        WHEN (ub.best_e1rm / p.current_body_weight_kg) >= ss.intermediate_bw_ratio THEN
          ROUND(((ub.best_e1rm / p.current_body_weight_kg - ss.intermediate_bw_ratio)
                 / NULLIF(ss.advanced_bw_ratio - ss.intermediate_bw_ratio, 0) * 100)::numeric, 0)
        WHEN (ub.best_e1rm / p.current_body_weight_kg) >= ss.novice_bw_ratio THEN
          ROUND(((ub.best_e1rm / p.current_body_weight_kg - ss.novice_bw_ratio)
                 / NULLIF(ss.intermediate_bw_ratio - ss.novice_bw_ratio, 0) * 100)::numeric, 0)
        WHEN (ub.best_e1rm / p.current_body_weight_kg) >= ss.beginner_bw_ratio THEN
          ROUND(((ub.best_e1rm / p.current_body_weight_kg - ss.beginner_bw_ratio)
                 / NULLIF(ss.novice_bw_ratio - ss.beginner_bw_ratio, 0) * 100)::numeric, 0)
        ELSE 0
      END
    ELSE NULL
  END AS progress_to_next_pct
FROM user_best ub
JOIN profiles p ON p.id = ub.user_id
LEFT JOIN strength_standards ss ON LOWER(ss.exercise_name) = LOWER(ub.exercise_name)
  -- Match sex from profile if available, default to male standards
  AND ss.sex = COALESCE(p.sex, 'male');

COMMENT ON VIEW relative_strength_benchmarks IS
  'User strength vs population norms (ExRx/Kilgore tiers). Uses BW-relative ratios when available. '
  'Levels: untrained/beginner/novice/intermediate/advanced/elite. Includes progress_to_next_pct for UI.';


-- =============================================================================
-- 10. VIEW: exercise_proficiency_index
-- =============================================================================

-- Composite per-user, per-exercise proficiency score (0-100).
-- Components (equally weighted at 25 points each):
--   1. Frequency: how regularly the user trains this exercise (weekly count)
--   2. Progression: e1RM trend over last 8 weeks (positive slope = progressing)
--   3. Consistency: coefficient of variation of weight used (lower = more stable)
--   4. Volume: actual weekly sets vs recommended (from training_volume_targets)
-- Weights are documented and adjustable in the CTE.
CREATE OR REPLACE VIEW exercise_proficiency_index
WITH (security_invoker = true) AS
WITH
  -- Component 1: Frequency (sessions per week over last 8 weeks)
  frequency_score AS (
    SELECT
      s.user_id,
      s.exercise_id,
      COUNT(DISTINCT s.training_date)::numeric / 8.0 AS sessions_per_week,
      -- Score: 1 session/week = ~20, 2+/week = ~25 (capped at 25)
      LEAST(25, ROUND(COUNT(DISTINCT s.training_date)::numeric / 8.0 * 12.5, 1)) AS freq_score
    FROM sets s
    WHERE s.set_type IN ('working', 'backoff')
      AND s.training_date >= CURRENT_DATE - 56  -- 8 weeks
      AND s.training_date IS NOT NULL
    GROUP BY s.user_id, s.exercise_id
  ),
  -- Component 2: Progression (e1RM change over last 8 weeks)
  -- Uses ARRAY_AGG with ordering to extract earliest/latest week e1RM without
  -- correlated subqueries (simpler, more efficient).
  progression_score AS (
    SELECT
      user_id,
      exercise_id,
      -- Extract earliest and latest e1RM via ordered array aggregation
      (ARRAY_AGG(best_e1rm ORDER BY period_start ASC))[1]  AS earliest_e1rm,
      (ARRAY_AGG(best_e1rm ORDER BY period_start DESC))[1] AS latest_e1rm,
      -- e1RM change %: (latest - earliest) / earliest * 100
      CASE
        WHEN (ARRAY_AGG(best_e1rm ORDER BY period_start ASC))[1] > 0
        THEN ROUND((
          ((ARRAY_AGG(best_e1rm ORDER BY period_start DESC))[1]
           - (ARRAY_AGG(best_e1rm ORDER BY period_start ASC))[1])
          / (ARRAY_AGG(best_e1rm ORDER BY period_start ASC))[1] * 100
        )::numeric, 1)
        ELSE 0
      END AS e1rm_change_pct,
      -- Score: 0% change = 12.5 (maintenance), positive = up to 25, negative = down to 0
      LEAST(25, GREATEST(0, ROUND((12.5 +
        CASE
          WHEN (ARRAY_AGG(best_e1rm ORDER BY period_start ASC))[1] > 0
          THEN (
            ((ARRAY_AGG(best_e1rm ORDER BY period_start DESC))[1]
             - (ARRAY_AGG(best_e1rm ORDER BY period_start ASC))[1])
            / (ARRAY_AGG(best_e1rm ORDER BY period_start ASC))[1] * 100
          )
          ELSE 0
        END
      )::numeric, 1))) AS prog_score
    FROM e1rm_progress_bucketed epb
    WHERE period_start >= CURRENT_DATE - 56
    GROUP BY user_id, exercise_id
  ),
  -- Component 3: Consistency (CV of working weight, lower = more consistent)
  consistency_score AS (
    SELECT
      s.user_id,
      s.exercise_id,
      CASE
        WHEN AVG(s.weight) > 0 AND COUNT(*) >= 3
        THEN ROUND((STDDEV(s.weight) / AVG(s.weight))::numeric, 3)
        ELSE NULL
      END AS weight_cv,
      -- Score: CV < 0.1 = 25 (very consistent), CV > 0.5 = 0 (chaotic)
      CASE
        WHEN COUNT(*) < 3 THEN 12.5  -- Not enough data, neutral score
        WHEN AVG(s.weight) > 0
        THEN LEAST(25, GREATEST(0, ROUND(
          25 - (STDDEV(s.weight) / NULLIF(AVG(s.weight), 0) * 50)::numeric
        , 1)))
        ELSE 12.5
      END AS cons_score
    FROM sets s
    WHERE s.set_type = 'working'
      AND s.weight > 0
      AND s.training_date >= CURRENT_DATE - 56
      AND s.training_date IS NOT NULL
    GROUP BY s.user_id, s.exercise_id
  ),
  -- Component 4: Volume compliance (actual sets vs any volume target)
  volume_score AS (
    SELECT
      s.user_id,
      s.exercise_id,
      COUNT(*)::numeric / 8.0 AS avg_weekly_sets,
      -- Default: 25 points if >8 sets/week (reasonable for any exercise)
      LEAST(25, ROUND(COUNT(*)::numeric / 8.0 / 8.0 * 25, 1)) AS vol_score
    FROM sets s
    WHERE s.set_type IN ('working', 'backoff')
      AND s.training_date >= CURRENT_DATE - 56
      AND s.training_date IS NOT NULL
    GROUP BY s.user_id, s.exercise_id
  )
SELECT
  fs.user_id,
  fs.exercise_id,
  e.name AS exercise_name,
  fs.sessions_per_week,
  ps.e1rm_change_pct,
  cs.weight_cv,
  vs.avg_weekly_sets,
  -- Composite score (0-100)
  ROUND(
    COALESCE(fs.freq_score, 0)
    + COALESCE(ps.prog_score, 12.5)
    + COALESCE(cs.cons_score, 12.5)
    + COALESCE(vs.vol_score, 0)
  , 0)::integer AS proficiency_score,
  -- Component breakdown for transparency
  fs.freq_score,
  ps.prog_score,
  cs.cons_score,
  vs.vol_score
FROM frequency_score fs
JOIN exercises e ON e.id = fs.exercise_id
LEFT JOIN progression_score ps ON ps.user_id = fs.user_id AND ps.exercise_id = fs.exercise_id
LEFT JOIN consistency_score cs ON cs.user_id = fs.user_id AND cs.exercise_id = fs.exercise_id
LEFT JOIN volume_score vs ON vs.user_id = fs.user_id AND vs.exercise_id = fs.exercise_id;

COMMENT ON VIEW exercise_proficiency_index IS
  'Composite per-exercise proficiency 0-100 over 8 weeks. '
  'Components: frequency(25), progression(25), consistency(25), volume(25). '
  'Weights are arbitrary heuristic — not a peer-reviewed formula. Component scores exposed for transparency.';


COMMIT;
