-- Migration 036: Training Insights & Warm-Up Guidance
-- Adds 4 new tables and 3 exercise columns validated by fitness-domain-expert agent.
--
-- New tables:
--   1. exercise_warmup_prerequisites — links compounds to prep movements
--   2. exercise_effectiveness_scores — per-user rolling-window exercise productivity
--   3. user_rest_recommendations — personalized rest period optimization
--   4. session_quality_scores — persistent pre-computed session quality
--
-- New exercise columns:
--   - warmup_sets_min / warmup_sets_max — evidence-based warm-up set range
--   - specific_warmup_notes — freeform prep guidance
--
-- Domain expert citations:
--   Warm-up: Baechle & Earle (2016, NSCA 4th ed Ch.15), Fradkin et al. (2010, JSCR)
--   Effectiveness: Schoenfeld et al. (2017, JSCR), Helms et al. (2018, JSCR)
--   Rest: de Salles et al. (2009), Schoenfeld et al. (2016), Grgic et al. (2017)
--   Session quality: Steele et al. (2017, PeerJ), Foster et al. (2001, JSCR)
--
-- Key design decisions (from domain expert validation):
--   - Warm-up: ramp based on working weight (not e1RM); range columns (min/max)
--     instead of fixed count; ramp percentages computed dynamically in app layer
--   - Effectiveness: rolling 8-12 week window; confidence intervals on e1RM slope;
--     rank within movement_pattern category (not global); min 6 weeks data
--   - Rest: Spearman rank correlation (not Pearson); controls for set position;
--     partitioned by training goal; min ~84 set-pairs for significance
--   - Session quality: weighted composite (completion 30%, volume 25%, progression 20%,
--     intensity 15%, rest 5%, density 5%); scoring_version for future evolution

BEGIN;

-- =============================================================================
-- 1. EXERCISE COLUMNS: warm-up guidance
-- =============================================================================

-- Range of recommended warm-up sets (depends on working intensity).
-- Compounds: 2-5; isolations: 0-2; machines after compounds: 0-1.
-- Domain expert: "the heavier the working load, the more warm-up sets are needed"
ALTER TABLE exercises ADD COLUMN IF NOT EXISTS warmup_sets_min smallint
  CHECK (warmup_sets_min >= 0 AND warmup_sets_min <= 5);
ALTER TABLE exercises ADD COLUMN IF NOT EXISTS warmup_sets_max smallint
  CHECK (warmup_sets_max >= 0 AND warmup_sets_max <= 8);
ALTER TABLE exercises ADD COLUMN IF NOT EXISTS specific_warmup_notes text;

-- Enforce min <= max when both are set
ALTER TABLE exercises ADD CONSTRAINT exercises_warmup_range_check
  CHECK (warmup_sets_min IS NULL OR warmup_sets_max IS NULL
         OR warmup_sets_min <= warmup_sets_max);

COMMENT ON COLUMN exercises.warmup_sets_min IS
  'Minimum recommended warm-up sets for light working loads (60-70% 1RM). '
  'Actual count scales with working intensity — app computes dynamically.';
COMMENT ON COLUMN exercises.warmup_sets_max IS
  'Maximum warm-up sets for near-maximal loads (90%+ 1RM). '
  'Baechle & Earle (2016): heavier load → more graduated warm-up ramp.';
COMMENT ON COLUMN exercises.specific_warmup_notes IS
  'Freeform prep guidance. E.g., "Band pull-aparts before pressing" or '
  '"Hip circles and goblet squat before heavy squats."';

-- Bulk-populate warm-up ranges based on mechanic (NSCA guidelines)
UPDATE exercises SET warmup_sets_min = 3, warmup_sets_max = 5
WHERE mechanic = 'compound' AND warmup_sets_min IS NULL;

UPDATE exercises SET warmup_sets_min = 0, warmup_sets_max = 2
WHERE mechanic = 'isolation' AND warmup_sets_min IS NULL;

UPDATE exercises SET warmup_sets_min = 1, warmup_sets_max = 3
WHERE mechanic IS NULL AND warmup_sets_min IS NULL;


-- =============================================================================
-- 2. TABLE: exercise_warmup_prerequisites
-- =============================================================================

-- Links heavy compound exercises to their preparation/mobility movements.
-- Example: Barbell Squat → {hip circles, goblet squat, empty bar squat}
-- Domain expert: "rotator cuff activation pre-pressing reduces impingement risk"
--   (Kolber et al., 2009, JSCR)
CREATE TABLE IF NOT EXISTS exercise_warmup_prerequisites (
  id                  uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  exercise_id         uuid        NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
  warmup_exercise_id  uuid        REFERENCES exercises(id) ON DELETE SET NULL,
  warmup_name         text        NOT NULL,
  sort_order          smallint    NOT NULL DEFAULT 0,
  duration_seconds    integer     CHECK (duration_seconds > 0 AND duration_seconds <= 300),
  reps                smallint    CHECK (reps > 0 AND reps <= 30),
  context             text        NOT NULL DEFAULT 'activation'
    CHECK (context IN ('mobility', 'activation', 'pattern_rehearsal', 'corrective')),
  notes               text,
  created_at          timestamptz NOT NULL DEFAULT now(),
  UNIQUE (exercise_id, sort_order)
);

COMMENT ON TABLE exercise_warmup_prerequisites IS
  'Preparation movements for compound exercises. Sort_order determines sequence. '
  'warmup_exercise_id is optional FK (prep movement may not be in exercise library). '
  'context: mobility (ROM), activation (muscle firing), pattern_rehearsal (motor pattern), '
  'corrective (injury prevention). Per Fradkin et al. (2010), Opplert & Babault (2018).';

CREATE INDEX IF NOT EXISTS warmup_prereqs_exercise_idx
  ON exercise_warmup_prerequisites (exercise_id, sort_order);

-- Public read (reference data), admin write
ALTER TABLE exercise_warmup_prerequisites ENABLE ROW LEVEL SECURITY;
CREATE POLICY warmup_prereqs_select ON exercise_warmup_prerequisites
  FOR SELECT TO authenticated USING (true);


-- =============================================================================
-- 3. TABLE: exercise_effectiveness_scores
-- =============================================================================

-- Per-user, rolling-window analysis of which exercises drive progress.
-- Domain expert modifications:
--   - Rolling 8-12 week window (not all-time) for meaningful regression
--   - Confidence intervals on e1RM slope (display only when CI excludes zero)
--   - Rank within movement_pattern category (not global)
--   - performance_recovery_cost replaces soreness_cost as primary recovery metric
--   - data_quality enum gates frontend display
--   - Minimum 6 weekly data points for reliable regression
CREATE TABLE IF NOT EXISTS exercise_effectiveness_scores (
  id                       uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id                  uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  exercise_id              uuid        NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
  -- Time window
  window_weeks             smallint    NOT NULL DEFAULT 8
    CHECK (window_weeks >= 4 AND window_weeks <= 52),
  period_start             date        NOT NULL,
  period_end               date        NOT NULL,
  -- e1RM progression (linear regression within window)
  e1rm_slope               numeric,    -- kg/week, positive = gaining
  e1rm_ci_lower            numeric,    -- 95% CI lower bound
  e1rm_ci_upper            numeric,    -- 95% CI upper bound
  -- Efficiency: e1RM gain per 10 effective working sets (RPE ≥7)
  -- Schoenfeld (2017): volume dose-response; Helms (2018): RPE ≥7 = effective
  volume_efficiency         numeric,
  -- Recovery cost (domain expert: use performance-based, not soreness-based)
  perceived_recovery_cost   numeric,    -- avg soreness from affected muscles (0-4)
  performance_recovery_cost numeric,    -- pct sessions where e1RM dropped >5%
  -- Usage consistency
  consistency_score         numeric     CHECK (consistency_score >= 0 AND consistency_score <= 1),
  -- Ranking (within movement_pattern category, not global)
  movement_category         text,       -- from exercises.movement_pattern
  effectiveness_rank        smallint,   -- 1 = most effective in category
  -- Data quality gate
  data_points               integer     NOT NULL DEFAULT 0,
  data_quality              text        NOT NULL DEFAULT 'insufficient'
    CHECK (data_quality IN ('insufficient', 'preliminary', 'reliable')),
  -- Recommendation
  recommendation            text
    CHECK (recommendation IN (
      'keep', 'increase_volume', 'decrease_volume',
      'consider_substitution', 'new_exercise', 'insufficient_data'
    )),
  computed_at               timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, exercise_id, window_weeks, period_start),
  CHECK (period_end >= period_start)
);

COMMENT ON TABLE exercise_effectiveness_scores IS
  'Per-user exercise effectiveness analysis over a rolling window. '
  'e1RM slope via weighted linear regression (recent data weighted higher). '
  'Rank within movement_pattern category (squat vs squat, not squat vs curl). '
  'data_quality gates frontend display: insufficient (<6 weeks), preliminary (6-8), reliable (>8). '
  'Computed by backend cron. Citations: Schoenfeld (2017), Helms (2018), Rippetoe (2011).';

CREATE INDEX IF NOT EXISTS effectiveness_user_exercise_idx
  ON exercise_effectiveness_scores (user_id, exercise_id, period_start DESC);
CREATE INDEX IF NOT EXISTS effectiveness_user_category_idx
  ON exercise_effectiveness_scores (user_id, movement_category, effectiveness_rank)
  WHERE data_quality = 'reliable';
CREATE INDEX IF NOT EXISTS effectiveness_recommendation_idx
  ON exercise_effectiveness_scores (user_id, recommendation)
  WHERE recommendation IN ('consider_substitution', 'increase_volume', 'decrease_volume');

ALTER TABLE exercise_effectiveness_scores ENABLE ROW LEVEL SECURITY;
CREATE POLICY effectiveness_select ON exercise_effectiveness_scores
  FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY effectiveness_insert ON exercise_effectiveness_scores
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY effectiveness_update ON exercise_effectiveness_scores
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY effectiveness_delete ON exercise_effectiveness_scores
  FOR DELETE TO authenticated USING (user_id = auth.uid());


-- =============================================================================
-- 4. TABLE: user_rest_recommendations
-- =============================================================================

-- Per-exercise personalized rest period optimization.
-- Domain expert modifications:
--   - Spearman rank correlation (robust to non-linearity and outliers)
--   - Controls for set position within exercise (fatigue accumulation confounder)
--   - Partitioned by training goal (NSCA: rest needs differ by goal)
--   - Minimum ~84 set-pairs for statistical significance (Cohen, 1988)
--   - Based on: de Salles (2009), Schoenfeld (2016), Grgic (2017)
CREATE TABLE IF NOT EXISTS user_rest_recommendations (
  id                     uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id                uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  exercise_id            uuid        NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
  -- Rest recommendation partitioned by goal
  training_goal          text        NOT NULL DEFAULT 'general'
    CHECK (training_goal IN ('strength', 'hypertrophy', 'endurance', 'general')),
  -- Computed optimal rest
  optimal_rest_seconds   integer     CHECK (optimal_rest_seconds > 0 AND optimal_rest_seconds <= 600),
  min_effective_rest     integer     CHECK (min_effective_rest > 0),
  max_useful_rest        integer     CHECK (max_useful_rest > 0),
  -- Statistical metrics
  spearman_rho           numeric(5,4),  -- Spearman rank correlation (-1 to 1)
  p_value                numeric(8,6),  -- statistical significance
  set_position_controlled boolean    NOT NULL DEFAULT false,
  -- Sample size (domain expert: ~84 set-pairs minimum for medium effect)
  sessions_sampled       integer     NOT NULL DEFAULT 0,
  set_pairs_sampled      integer     NOT NULL DEFAULT 0,
  -- Data sufficiency
  confidence             numeric(3,2) CHECK (confidence >= 0 AND confidence <= 1),
  data_quality           text        NOT NULL DEFAULT 'insufficient'
    CHECK (data_quality IN ('insufficient', 'preliminary', 'reliable')),
  computed_at            timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, exercise_id, training_goal),
  CHECK (min_effective_rest IS NULL OR max_useful_rest IS NULL
         OR min_effective_rest <= max_useful_rest)
);

COMMENT ON TABLE user_rest_recommendations IS
  'Personalized inter-set rest recommendations per exercise and training goal. '
  'Uses Spearman rank correlation between rest_seconds and next-set performance, '
  'controlling for set position (fatigue accumulation confounder). '
  'NSCA rest guidelines: strength 3-5min, hypertrophy 1.5-3min, endurance 30-90s. '
  'Minimum 84 set-pairs for significance (Cohen, 1988). '
  'Citations: de Salles (2009), Schoenfeld (2016), Grgic (2017), Harris (1976).';

CREATE INDEX IF NOT EXISTS rest_recs_user_exercise_idx
  ON user_rest_recommendations (user_id, exercise_id);
CREATE INDEX IF NOT EXISTS rest_recs_user_goal_idx
  ON user_rest_recommendations (user_id, training_goal)
  WHERE data_quality IN ('preliminary', 'reliable');

ALTER TABLE user_rest_recommendations ENABLE ROW LEVEL SECURITY;
CREATE POLICY rest_recs_select ON user_rest_recommendations
  FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY rest_recs_insert ON user_rest_recommendations
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY rest_recs_update ON user_rest_recommendations
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY rest_recs_delete ON user_rest_recommendations
  FOR DELETE TO authenticated USING (user_id = auth.uid());


-- =============================================================================
-- 5. TABLE: session_quality_scores
-- =============================================================================

-- Persistent pre-computed session quality composite score.
-- Domain expert weighting (evidence-based priority, most predictive first):
--   completion_score: 30%  (Steele 2017: adherence is #1 predictor of outcomes)
--   volume_score:     25%  (Schoenfeld 2017: dose-response for hypertrophy)
--   progression_score:20%  (Kraemer & Ratamess 2004: progressive overload principle)
--   intensity_score:  15%  (RPE management, Helms 2018)
--   rest_score:        5%  (Grgic 2017: less impactful when volume equated)
--   density_score:     5%  (time-efficiency indicator, not outcome predictor)
--
-- Session quality = 0.30*completion + 0.25*volume + 0.20*progression
--                 + 0.15*intensity + 0.05*rest + 0.05*density
CREATE TABLE IF NOT EXISTS session_quality_scores (
  id                  uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id             uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  training_date       date        NOT NULL,
  workout_cluster_id  uuid,
  -- Composite score (0-100)
  quality_score       smallint    NOT NULL CHECK (quality_score >= 0 AND quality_score <= 100),
  -- Sub-scores (0-100 each)
  volume_score        smallint    CHECK (volume_score >= 0 AND volume_score <= 100),
  intensity_score     smallint    CHECK (intensity_score >= 0 AND intensity_score <= 100),
  completion_score    smallint    CHECK (completion_score >= 0 AND completion_score <= 100),
  density_score       smallint    CHECK (density_score >= 0 AND density_score <= 100),
  progression_score   smallint    CHECK (progression_score >= 0 AND progression_score <= 100),
  rest_score          smallint    CHECK (rest_score >= 0 AND rest_score <= 100),
  -- Progression detail (domain expert: track both directions)
  exercises_progressed  smallint  NOT NULL DEFAULT 0,
  exercises_regressed   smallint  NOT NULL DEFAULT 0,
  exercises_maintained  smallint  NOT NULL DEFAULT 0,
  exercises_total       smallint  NOT NULL DEFAULT 0,
  -- Session-level metrics for drill-down
  total_working_sets    integer,
  total_volume_kg       numeric,
  session_duration_min  numeric,
  avg_rpe               numeric(3,1),
  -- Subjective anchoring (Foster et al., 2001: session RPE)
  session_rpe           smallint  CHECK (session_rpe >= 1 AND session_rpe <= 10),
  -- Scoring version for future evolution without invalidating history
  scoring_version       smallint  NOT NULL DEFAULT 1,
  computed_at           timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, training_date, workout_cluster_id)
);

COMMENT ON TABLE session_quality_scores IS
  'Pre-computed session quality composite with evidence-based sub-score weighting. '
  'scoring_version enables formula evolution without invalidating historical scores. '
  'Composite = 0.30*completion + 0.25*volume + 0.20*progression + 0.15*intensity '
  '+ 0.05*rest + 0.05*density. Computed by backend cron after set mutations. '
  'Citations: Steele (2017), Schoenfeld (2017), Kraemer & Ratamess (2004), '
  'Foster (2001), Helms (2018), Grgic (2017).';

COMMENT ON COLUMN session_quality_scores.exercises_progressed IS
  'Exercises where session-best e1RM exceeded previous session for same exercise. '
  'Primary progression indicator per NSCA progressive overload principle.';
COMMENT ON COLUMN session_quality_scores.scoring_version IS
  'Formula version. Increment when sub-score weights or computation changes. '
  'Enables historical comparison within same version and migration between versions.';

CREATE INDEX IF NOT EXISTS session_quality_user_date_idx
  ON session_quality_scores (user_id, training_date DESC);
CREATE INDEX IF NOT EXISTS session_quality_score_idx
  ON session_quality_scores (user_id, quality_score DESC)
  WHERE scoring_version = 1;

ALTER TABLE session_quality_scores ENABLE ROW LEVEL SECURITY;
CREATE POLICY session_quality_select ON session_quality_scores
  FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY session_quality_insert ON session_quality_scores
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY session_quality_update ON session_quality_scores
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY session_quality_delete ON session_quality_scores
  FOR DELETE TO authenticated USING (user_id = auth.uid());


-- =============================================================================
-- 6. FUNCTION: compute_session_quality (service_role only)
-- =============================================================================

-- Computes and upserts session quality scores for a training date.
-- Implements the evidence-based weighting from domain expert review.
CREATE OR REPLACE FUNCTION compute_session_quality(
  p_user_id        uuid,
  p_training_date  date,
  p_cluster_id     uuid DEFAULT NULL
) RETURNS void AS $$
DECLARE
  v_volume_score      smallint;
  v_intensity_score   smallint;
  v_completion_score  smallint;
  v_density_score     smallint;
  v_progression_score smallint;
  v_rest_score        smallint;
  v_quality_score     smallint;
  v_progressed        smallint := 0;
  v_regressed         smallint := 0;
  v_maintained        smallint := 0;
  v_total_exercises   smallint := 0;
  v_working_sets      integer  := 0;
  v_total_volume      numeric  := 0;
  v_duration_min      numeric;
  v_avg_rpe           numeric;
  v_session_rpe       smallint;
BEGIN
  -- Aggregate session stats
  SELECT
    COUNT(*) FILTER (WHERE set_type IN ('working', 'backoff', 'failure')),
    COALESCE(SUM(
      CASE WHEN weight_unit = 'lb' THEN weight * 0.453592 ELSE weight END * reps
    ) FILTER (WHERE set_type IN ('working', 'backoff', 'failure')), 0),
    EXTRACT(EPOCH FROM (MAX(logged_at) - MIN(logged_at))) / 60.0,
    AVG(rpe) FILTER (WHERE rpe IS NOT NULL AND set_type IN ('working', 'backoff', 'failure'))
  INTO v_working_sets, v_total_volume, v_duration_min, v_avg_rpe
  FROM sets
  WHERE user_id = p_user_id
    AND training_date = p_training_date
    AND (p_cluster_id IS NULL OR workout_cluster_id = p_cluster_id);

  -- If no sets, skip
  IF v_working_sets = 0 THEN RETURN; END IF;

  -- Count distinct exercises and progression
  WITH exercise_e1rm AS (
    SELECT
      s.exercise_id,
      MAX(s.estimated_1rm) AS best_e1rm
    FROM sets s
    WHERE s.user_id = p_user_id
      AND s.training_date = p_training_date
      AND (p_cluster_id IS NULL OR s.workout_cluster_id = p_cluster_id)
      AND s.set_type IN ('working', 'backoff', 'failure')
      AND s.estimated_1rm IS NOT NULL
    GROUP BY s.exercise_id
  ),
  prev_e1rm AS (
    SELECT DISTINCT ON (exercise_id)
      exercise_id,
      MAX(estimated_1rm) AS prev_best
    FROM sets
    WHERE user_id = p_user_id
      AND training_date < p_training_date
      AND set_type IN ('working', 'backoff', 'failure')
      AND estimated_1rm IS NOT NULL
    GROUP BY exercise_id, training_date
    ORDER BY exercise_id, training_date DESC
  ),
  comparison AS (
    SELECT
      ce.exercise_id,
      CASE
        WHEN pe.prev_best IS NULL THEN 'new'
        WHEN ce.best_e1rm > pe.prev_best * 1.005 THEN 'progressed'
        WHEN ce.best_e1rm < pe.prev_best * 0.95 THEN 'regressed'
        ELSE 'maintained'
      END AS status
    FROM exercise_e1rm ce
    LEFT JOIN prev_e1rm pe ON pe.exercise_id = ce.exercise_id
  )
  SELECT
    COUNT(*),
    COUNT(*) FILTER (WHERE status = 'progressed'),
    COUNT(*) FILTER (WHERE status = 'regressed'),
    COUNT(*) FILTER (WHERE status IN ('maintained', 'new'))
  INTO v_total_exercises, v_progressed, v_regressed, v_maintained
  FROM comparison;

  -- Progression score: % of exercises that improved
  IF v_total_exercises > 0 THEN
    v_progression_score := LEAST(100,
      ((v_progressed * 100 + v_maintained * 50) / v_total_exercises)::smallint
    );
  ELSE
    v_progression_score := 50; -- neutral
  END IF;

  -- Intensity score: RPE in productive range (6-9 is ideal for most goals)
  IF v_avg_rpe IS NOT NULL THEN
    v_intensity_score := CASE
      WHEN v_avg_rpe BETWEEN 6.5 AND 8.5 THEN 100
      WHEN v_avg_rpe BETWEEN 5.5 AND 9.5 THEN 75
      WHEN v_avg_rpe BETWEEN 4.0 AND 10.0 THEN 50
      ELSE 25
    END;
  ELSE
    v_intensity_score := 50; -- no RPE data
  END IF;

  -- Volume score: based on whether working sets are within reasonable range (6-25 per session)
  v_volume_score := CASE
    WHEN v_working_sets BETWEEN 12 AND 20 THEN 100
    WHEN v_working_sets BETWEEN 8 AND 25 THEN 85
    WHEN v_working_sets BETWEEN 4 AND 30 THEN 65
    ELSE 40
  END;

  -- Density score: training efficiency (working sets per hour)
  IF v_duration_min IS NOT NULL AND v_duration_min > 5 THEN
    v_density_score := CASE
      WHEN (v_working_sets / (v_duration_min / 60.0)) BETWEEN 10 AND 25 THEN 100
      WHEN (v_working_sets / (v_duration_min / 60.0)) BETWEEN 5 AND 35 THEN 75
      ELSE 50
    END;
  ELSE
    v_density_score := 50;
  END IF;

  -- Rest score: check if rest_seconds are in appropriate range
  SELECT CASE
    WHEN COUNT(*) FILTER (WHERE rest_seconds IS NOT NULL) = 0 THEN 50
    WHEN AVG(
      CASE WHEN rest_seconds BETWEEN 60 AND 300 THEN 1.0 ELSE 0.0 END
    ) FILTER (WHERE rest_seconds IS NOT NULL) >= 0.7 THEN 90
    WHEN AVG(
      CASE WHEN rest_seconds BETWEEN 30 AND 420 THEN 1.0 ELSE 0.0 END
    ) FILTER (WHERE rest_seconds IS NOT NULL) >= 0.5 THEN 70
    ELSE 40
  END
  INTO v_rest_score
  FROM sets
  WHERE user_id = p_user_id
    AND training_date = p_training_date
    AND (p_cluster_id IS NULL OR workout_cluster_id = p_cluster_id)
    AND set_type IN ('working', 'backoff', 'failure');

  -- Completion score: plan adherence if a plan exists, else neutral
  SELECT COALESCE(
    (SELECT LEAST(100, (adherence_ratio * 100)::smallint)
     FROM plan_adherence_log
     WHERE user_id = p_user_id AND training_date = p_training_date
     LIMIT 1),
    50  -- no plan = neutral
  ) INTO v_completion_score;

  -- Get session RPE from workout_feedback if available
  SELECT session_rpe INTO v_session_rpe
  FROM workout_feedback
  WHERE user_id = p_user_id AND training_date = p_training_date
  LIMIT 1;

  -- Composite: 30% completion + 25% volume + 20% progression + 15% intensity + 5% rest + 5% density
  v_quality_score := (
    0.30 * v_completion_score +
    0.25 * v_volume_score +
    0.20 * v_progression_score +
    0.15 * v_intensity_score +
    0.05 * v_rest_score +
    0.05 * v_density_score
  )::smallint;

  -- Upsert
  INSERT INTO session_quality_scores (
    user_id, training_date, workout_cluster_id,
    quality_score, volume_score, intensity_score, completion_score,
    density_score, progression_score, rest_score,
    exercises_progressed, exercises_regressed, exercises_maintained, exercises_total,
    total_working_sets, total_volume_kg, session_duration_min, avg_rpe,
    session_rpe, scoring_version, computed_at
  ) VALUES (
    p_user_id, p_training_date, p_cluster_id,
    v_quality_score, v_volume_score, v_intensity_score, v_completion_score,
    v_density_score, v_progression_score, v_rest_score,
    v_progressed, v_regressed, v_maintained, v_total_exercises,
    v_working_sets, ROUND(v_total_volume, 2), ROUND(v_duration_min, 1), ROUND(v_avg_rpe, 1),
    v_session_rpe, 1, now()
  )
  ON CONFLICT (user_id, training_date, workout_cluster_id)
  DO UPDATE SET
    quality_score       = EXCLUDED.quality_score,
    volume_score        = EXCLUDED.volume_score,
    intensity_score     = EXCLUDED.intensity_score,
    completion_score    = EXCLUDED.completion_score,
    density_score       = EXCLUDED.density_score,
    progression_score   = EXCLUDED.progression_score,
    rest_score          = EXCLUDED.rest_score,
    exercises_progressed = EXCLUDED.exercises_progressed,
    exercises_regressed  = EXCLUDED.exercises_regressed,
    exercises_maintained = EXCLUDED.exercises_maintained,
    exercises_total      = EXCLUDED.exercises_total,
    total_working_sets   = EXCLUDED.total_working_sets,
    total_volume_kg      = EXCLUDED.total_volume_kg,
    session_duration_min = EXCLUDED.session_duration_min,
    avg_rpe              = EXCLUDED.avg_rpe,
    session_rpe          = EXCLUDED.session_rpe,
    scoring_version      = EXCLUDED.scoring_version,
    computed_at          = EXCLUDED.computed_at;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION compute_session_quality IS
  'Computes session quality composite score with evidence-based sub-score weighting. '
  'Call from backend cron after set mutations. Service-role only.';

REVOKE EXECUTE ON FUNCTION compute_session_quality(uuid, date, uuid) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION compute_session_quality(uuid, date, uuid) FROM authenticated;
GRANT EXECUTE ON FUNCTION compute_session_quality(uuid, date, uuid) TO service_role;

COMMIT;
