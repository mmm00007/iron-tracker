-- Migration 027: Training Context & Progression Enrichment
-- Adds muscle group hierarchy, configurable progression rules, structured
-- injury tracking, and two insight views (training consistency, e1RM progress).
--
-- Validated by: fitness-domain-expert, database-specialist agents
--
-- Key design decisions (from expert validation):
--   - Muscle group hierarchy uses push/pull taxonomy for legs
--     (lower_push = knee extension, lower_pull = hip extension; Boyle, 2016)
--   - Adductors placed in lower_pull (functionally closer to glutes/hamstrings
--     per Escamilla et al., 2009), NOT lower_push
--   - Shoulders in upper_push (compromise: anterior delt dominates in
--     bench/OHP which are the most common delt-loading exercises)
--   - Progression rules: population defaults (user_id=NULL) + user overrides
--   - Stall strategy added per domain expert (critical for "what to do next")
--   - Injury diary separate from soreness (different constructs, different scales)
--   - Training streak = consecutive weeks meeting target frequency
--     (not calendar days, which punishes rest days)
--   - Workload balance index (Shannon entropy) REJECTED: no peer-reviewed support;
--     existing movement_pattern_balance view is superior
--   - Exercise variation catalog REJECTED: redundant with exercise_substitutions

BEGIN;

-- =============================================================================
-- 1. NEW TABLE: muscle_group_categories (reference data)
-- =============================================================================

-- Hierarchical grouping of the 16 individual muscle groups into broader
-- functional categories. Enables rollup volume analysis ("total upper push
-- volume this week") and split classification.
--
-- A muscle can belong to multiple categories (e.g., shoulders could be
-- in both upper_push and a future "shoulders" isolation category).
CREATE TABLE IF NOT EXISTS muscle_group_categories (
  id             serial   PRIMARY KEY,
  category_name  text     NOT NULL UNIQUE,
  display_name   text     NOT NULL,
  display_order  smallint NOT NULL UNIQUE
);

COMMENT ON TABLE muscle_group_categories IS
  'Functional grouping of muscle groups for hierarchical volume analysis. Push/pull taxonomy.';

ALTER TABLE muscle_group_categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY muscle_group_categories_select ON muscle_group_categories
  FOR SELECT TO authenticated USING (true);


-- Junction table: which muscles belong to which categories
CREATE TABLE IF NOT EXISTS muscle_group_category_members (
  muscle_group_id integer NOT NULL REFERENCES muscle_groups(id),
  category_id     integer NOT NULL REFERENCES muscle_group_categories(id),
  PRIMARY KEY (muscle_group_id, category_id)
);

COMMENT ON TABLE muscle_group_category_members IS
  'Maps individual muscle groups to functional categories. Many-to-many.';

-- Reverse lookup: "which muscles are in category X?"
CREATE INDEX IF NOT EXISTS muscle_group_cat_members_category_idx
  ON muscle_group_category_members (category_id);

ALTER TABLE muscle_group_category_members ENABLE ROW LEVEL SECURITY;

CREATE POLICY muscle_group_category_members_select ON muscle_group_category_members
  FOR SELECT TO authenticated USING (true);


-- =============================================================================
-- 2. NEW TABLE: progression_rules (configurable per exercise/goal)
-- =============================================================================

-- Defines when and how to increase training load. Population defaults
-- (user_id = NULL) provide evidence-based starting points; users can
-- override per exercise.
--
-- Distinction from plan_items: plan items are prescriptive ("do 3x8 at 80kg
-- today"); progression rules are adaptive ("when you hit 3x8 at RPE 7,
-- increase to 82.5kg next session").
--
-- Sources:
--   - Linear: Rippetoe, Starting Strength (3rd ed.)
--   - Double progression: standard hypertrophy model (RP, Helms et al.)
--   - RPE-based: Tuchscherer/RTS, Barbell Medicine
--   - Wave: Wendler 5/3/1, undulating periodization
--   - Percentage-based: Sheiko, Smolov
CREATE TABLE IF NOT EXISTS progression_rules (
  id                    uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id               uuid        REFERENCES auth.users(id) ON DELETE CASCADE,
  exercise_id           uuid        REFERENCES exercises(id) ON DELETE RESTRICT,
  goal                  text        NOT NULL CHECK (goal IN (
    'strength', 'hypertrophy', 'endurance', 'power', 'general', 'body_recomposition'
  )),
  target_rep_range_min  smallint    NOT NULL CHECK (target_rep_range_min > 0),
  target_rep_range_max  smallint    NOT NULL CHECK (target_rep_range_max >= target_rep_range_min),
  load_increment_kg     numeric     NOT NULL DEFAULT 2.5
                                    CHECK (load_increment_kg > 0 AND load_increment_kg <= 20),
  progression_model     text        NOT NULL DEFAULT 'double_progression' CHECK (progression_model IN (
    'linear',               -- Add weight every session (Starting Strength)
    'double_progression',   -- Hit top of rep range across all sets, then increase (most common hypertrophy model)
    'wave',                 -- Undulating: cycle through intensity/volume phases (5/3/1)
    'rpe_based',            -- Autoregulate by RPE target (RTS/Barbell Medicine)
    'percentage_based',     -- % of 1RM prescription (Sheiko)
    'rep_target'            -- Total reps across sets at a weight (Gironda, newer RP protocols)
  )),
  min_reps_to_progress  smallint    NOT NULL DEFAULT 1 CHECK (min_reps_to_progress >= 1),
  min_sets_at_target    smallint    NOT NULL DEFAULT 2 CHECK (min_sets_at_target >= 1),
  max_progression_weeks smallint    DEFAULT 4 CHECK (max_progression_weeks >= 2 AND max_progression_weeks <= 52),
  stall_strategy        text        DEFAULT 'deload_and_retry' CHECK (stall_strategy IN (
    'deload_and_retry',   -- Reduce load 10%, rebuild (Starting Strength reset)
    'reduce_weight',      -- Drop to 90% and continue at current rep scheme
    'increase_reps',      -- Switch to rep progression (add reps instead of weight)
    'switch_variation'    -- Suggest exercise substitution via exercise_substitutions
  )),
  created_at            timestamptz NOT NULL DEFAULT now(),
  updated_at            timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE progression_rules IS
  'Configurable progression logic per exercise/goal. user_id=NULL = population defaults. load_increment_kg is always in kg; app converts for lb users.';

-- Partial unique indexes for NULL user_id (population defaults vs user overrides)
CREATE UNIQUE INDEX IF NOT EXISTS progression_rules_default_unique_idx
  ON progression_rules (exercise_id, goal)
  WHERE user_id IS NULL;

CREATE UNIQUE INDEX IF NOT EXISTS progression_rules_user_unique_idx
  ON progression_rules (user_id, exercise_id, goal)
  WHERE user_id IS NOT NULL;

-- Query indexes
CREATE INDEX IF NOT EXISTS progression_rules_user_exercise_idx
  ON progression_rules (user_id, exercise_id)
  WHERE user_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS progression_rules_default_idx
  ON progression_rules (exercise_id)
  WHERE user_id IS NULL;

CREATE TRIGGER progression_rules_updated_at
  BEFORE UPDATE ON progression_rules
  FOR EACH ROW
  EXECUTE FUNCTION set_updated_at();

ALTER TABLE progression_rules ENABLE ROW LEVEL SECURITY;

-- Users see their own rules + population defaults (user_id IS NULL)
CREATE POLICY progression_rules_select ON progression_rules
  FOR SELECT TO authenticated
  USING (user_id = auth.uid() OR user_id IS NULL);

CREATE POLICY progression_rules_insert ON progression_rules
  FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY progression_rules_update ON progression_rules
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

CREATE POLICY progression_rules_delete ON progression_rules
  FOR DELETE TO authenticated
  USING (user_id = auth.uid());


-- =============================================================================
-- 3. NEW TABLE: injury_reports (structured pain tracking)
-- =============================================================================

-- Separate from soreness_reports (which tracks normal DOMS on 0-4 scale).
-- Injury tracking uses the clinical NRS 0-10 pain scale (Hawker et al., 2011)
-- and captures structured metadata for safety-aware recommendations.
--
-- Key interaction: when limits_training = true, the recommendation engine
-- should cross-reference exercises.contraindications and exercise_substitutions
-- to suggest safe alternatives.
CREATE TABLE IF NOT EXISTS injury_reports (
  id                   uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id              uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  reported_at          timestamptz NOT NULL DEFAULT now(),
  location_type        text        NOT NULL CHECK (location_type IN (
    'joint', 'muscle', 'tendon', 'ligament', 'nerve', 'bone', 'other'
  )),
  body_area            text        NOT NULL CHECK (body_area IN (
    -- Lateralized sites
    'left_shoulder', 'right_shoulder',
    'left_elbow', 'right_elbow',
    'left_wrist', 'right_wrist',
    'left_hand', 'right_hand',
    'left_hip', 'right_hip',
    'left_knee', 'right_knee',
    'left_ankle', 'right_ankle',
    'left_foot', 'right_foot',
    'left_calf', 'right_calf',
    'left_forearm', 'right_forearm',
    'left_shin', 'right_shin',
    -- Midline sites
    'lower_back', 'upper_back', 'neck', 'chest', 'abdomen'
  )),
  pain_level           smallint    NOT NULL CHECK (pain_level >= 0 AND pain_level <= 10),
  onset_type           text        NOT NULL CHECK (onset_type IN (
    'acute',      -- Sudden onset during activity (possible strain/sprain)
    'gradual',    -- Developed over days/weeks (overuse, tendinopathy)
    'recurring'   -- Previously resolved but returned
  )),
  mechanism            text        CHECK (mechanism IN (
    'during_warmup',   -- Pain during warmup (benign if resolves; pathological if persists)
    'during_exercise',
    'post_exercise',
    'unrelated',
    'unknown'
  )),
  affected_exercise_id uuid        REFERENCES exercises(id) ON DELETE SET NULL,
  limits_training      boolean     NOT NULL DEFAULT false,
  status               text        NOT NULL DEFAULT 'active' CHECK (status IN (
    'active',       -- Currently experiencing pain
    'recovering',   -- Improving but not resolved
    'chronic',      -- Persists >12 weeks (clinical definition)
    'resolved'      -- Fully resolved
  )),
  resolved_at          timestamptz,
  notes                text,
  created_at           timestamptz NOT NULL DEFAULT now(),
  updated_at           timestamptz NOT NULL DEFAULT now(),

  -- Resolved_at must be set iff status = 'resolved'
  CHECK (
    (status = 'resolved' AND resolved_at IS NOT NULL)
    OR (status != 'resolved' AND resolved_at IS NULL)
  )
);

COMMENT ON TABLE injury_reports IS
  'Structured injury/pain tracking. NRS 0-10 scale (distinct from soreness 0-4). NOT medical advice.';
COMMENT ON COLUMN injury_reports.pain_level IS
  'NRS pain scale 0-10 (0=no pain, 10=worst imaginable). Distinct from soreness_reports.level (0-4 DOMS).';
COMMENT ON COLUMN injury_reports.limits_training IS
  'If true, recommendation engine should exclude exercises affecting this body area.';

CREATE INDEX IF NOT EXISTS injury_reports_user_status_idx
  ON injury_reports (user_id, status)
  WHERE status != 'resolved';

CREATE INDEX IF NOT EXISTS injury_reports_user_body_area_idx
  ON injury_reports (user_id, body_area);

CREATE INDEX IF NOT EXISTS injury_reports_user_exercise_idx
  ON injury_reports (user_id, affected_exercise_id)
  WHERE affected_exercise_id IS NOT NULL;

CREATE TRIGGER injury_reports_updated_at
  BEFORE UPDATE ON injury_reports
  FOR EACH ROW
  EXECUTE FUNCTION set_updated_at();

ALTER TABLE injury_reports ENABLE ROW LEVEL SECURITY;

CREATE POLICY injury_reports_select ON injury_reports
  FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY injury_reports_insert ON injury_reports
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY injury_reports_update ON injury_reports
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY injury_reports_delete ON injury_reports
  FOR DELETE TO authenticated USING (user_id = auth.uid());


-- =============================================================================
-- 4. INDEX: Supporting index for e1RM progress queries
-- =============================================================================

-- Covers GROUP BY (user_id, exercise_id, training_date) for the bucketed
-- e1RM view and exercise_performance_summary.
CREATE INDEX IF NOT EXISTS sets_user_exercise_date_idx
  ON sets (user_id, exercise_id, training_date DESC);


-- =============================================================================
-- 5. VIEW: training_consistency_metrics
-- =============================================================================

-- Training consistency per user: streak (consecutive weeks meeting frequency
-- target), regularity index (CV of inter-session gaps), rolling frequency.
--
-- Streak is defined as consecutive weeks where the user completed >= their
-- training_days_per_week target. This avoids penalizing rest days
-- (Fry & Kraemer, 1997: daily training without rest promotes overtraining).
-- A tolerance of -1 day is applied (3/4 days still counts).
--
-- Regularity index = coefficient of variation of inter-session intervals.
-- Lower CV = more consistent. CV < 0.3 indicates regular training
-- (standard time-series regularity threshold).
CREATE OR REPLACE VIEW training_consistency_metrics
WITH (security_invoker = true) AS
WITH
  -- Get user's target frequency
  user_targets AS (
    SELECT id AS user_id, COALESCE(training_days_per_week, 3) AS target_days
    FROM profiles
  ),
  -- Count distinct training days per ISO week
  weekly_counts AS (
    SELECT
      s.user_id,
      date_trunc('week', s.training_date)::date AS week_start,
      COUNT(DISTINCT s.training_date) AS days_trained
    FROM sets s
    WHERE s.training_date IS NOT NULL
      AND s.training_date >= CURRENT_DATE - interval '52 weeks'
    GROUP BY s.user_id, date_trunc('week', s.training_date)
  ),
  -- Mark weeks as "met target" (with -1 tolerance)
  weekly_met AS (
    SELECT
      wc.user_id,
      wc.week_start,
      wc.days_trained,
      (wc.days_trained >= ut.target_days - 1) AS met_target
    FROM weekly_counts wc
    JOIN user_targets ut ON ut.user_id = wc.user_id
  ),
  -- Current streak: count consecutive recent weeks that met target
  -- (walk backwards from most recent week)
  streak_calc AS (
    SELECT
      user_id,
      week_start,
      met_target,
      ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY week_start DESC) AS rn,
      -- Break group: first week that didn't meet target breaks the streak
      SUM(CASE WHEN NOT met_target THEN 1 ELSE 0 END)
        OVER (PARTITION BY user_id ORDER BY week_start DESC ROWS UNBOUNDED PRECEDING)
        AS breaks
    FROM weekly_met
  ),
  -- Inter-session gaps for regularity
  session_gaps AS (
    SELECT
      user_id,
      training_date,
      training_date - LAG(training_date) OVER (
        PARTITION BY user_id ORDER BY training_date
      ) AS gap_days
    FROM (
      SELECT DISTINCT user_id, training_date
      FROM sets
      WHERE training_date IS NOT NULL
        AND training_date >= CURRENT_DATE - interval '12 weeks'
    ) sub
  )
SELECT
  p.id AS user_id,
  -- Current streak (weeks meeting target, counting backwards from now)
  COALESCE(
    (SELECT COUNT(*) FROM streak_calc sc
     WHERE sc.user_id = p.id AND sc.breaks = 0),
    0
  )::integer AS current_streak_weeks,
  -- 4-week rolling average sessions per week
  COALESCE(
    (SELECT COUNT(DISTINCT training_date)::numeric / 4
     FROM sets
     WHERE user_id = p.id
       AND training_date >= CURRENT_DATE - 28
       AND training_date IS NOT NULL),
    0
  ) AS avg_sessions_per_week_4w,
  -- Regularity index (CV of inter-session gaps; lower = more consistent)
  COALESCE(
    (SELECT
       CASE WHEN AVG(gap_days) > 0
         THEN ROUND((STDDEV(gap_days) / AVG(gap_days))::numeric, 3)
         ELSE NULL
       END
     FROM session_gaps sg
     WHERE sg.user_id = p.id AND sg.gap_days IS NOT NULL),
    NULL
  ) AS regularity_cv,
  -- Total weeks with any training (last 52 weeks)
  COALESCE(
    (SELECT COUNT(*) FROM weekly_counts wc WHERE wc.user_id = p.id),
    0
  )::integer AS active_weeks_52w,
  -- Weeks meeting target (last 52 weeks)
  COALESCE(
    (SELECT COUNT(*) FROM weekly_met wm
     WHERE wm.user_id = p.id AND wm.met_target),
    0
  )::integer AS target_met_weeks_52w
FROM profiles p;

COMMENT ON VIEW training_consistency_metrics IS
  'Per-user consistency: streak (weeks meeting frequency target), regularity CV, rolling frequency. 52-week window.';


-- =============================================================================
-- 6. VIEW: e1rm_progress_bucketed
-- =============================================================================

-- Per-exercise, per-week best estimated 1RM for progress charting.
-- Working sets only (excludes warmups).
-- Frontend can normalize to percent-of-peak for multi-exercise overlay charts.
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
  COUNT(*) FILTER (WHERE s.set_type = 'working')             AS working_sets,
  AVG(s.rpe) FILTER (WHERE s.rpe IS NOT NULL)                AS avg_rpe
FROM sets s
JOIN exercises e ON e.id = s.exercise_id
WHERE s.set_type IN ('working', 'backoff', 'failure')
  AND s.training_date IS NOT NULL
  AND s.estimated_1rm IS NOT NULL
GROUP BY s.user_id, s.exercise_id, e.name, date_trunc('week', s.training_date);

COMMENT ON VIEW e1rm_progress_bucketed IS
  'Per-exercise weekly best e1RM for progress charts. Working sets only. Frontend normalizes to %-of-peak.';


COMMIT;
