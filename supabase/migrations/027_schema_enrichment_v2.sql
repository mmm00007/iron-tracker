-- Migration 027: Schema Enrichment V2
-- Adds user exercise preferences, workload balance scores, muscle activation
-- weights view, and updates weekly_muscle_volume to use activation_percent.
--
-- Validated by: database-specialist agent
--
-- Key design decisions:
--   - user_exercise_preferences consolidates exercise_favorites + per-exercise
--     defaults into a single user-scoped table (replaces separate favorites table)
--   - muscle_activation_weights view provides activation percentages with fallback
--     defaults (primary=100, secondary=50) for weighted volume calculations
--   - weekly_muscle_volume updated to use actual activation_percent values instead
--     of the binary function_type-based 1.0/0.5/0.0 weights
--   - workload_balance_scores pre-computed table for weekly/monthly balance metrics
--     including Shannon entropy, push/pull ratio, upper/lower ratio
--   - rest_seconds, workout_cluster_id, activation_percent, and variations already
--     exist from prior migrations — this migration builds on them, not re-adds them
--
-- NOTE: Items 3 (rest_seconds on sets), 4 (workout_cluster_id on sets), and
-- 5 (variations on exercises) from the original request already exist:
--   - rest_seconds: migration 021 (sets.rest_seconds integer CHECK > 0)
--   - workout_cluster_id: migration 021 (sets.workout_cluster_id uuid + recompute function)
--   - variations: migration 015 (exercises.variations text[] DEFAULT '{}')
--   - activation_percent: migration 015 (exercise_muscles.activation_percent smallint 0-100)

BEGIN;

-- =============================================================================
-- 1. NEW TABLE: user_exercise_preferences
-- =============================================================================

-- Per-user exercise preferences: rating, defaults, and favorite flag.
-- Consolidates the pattern from exercise_favorites (migration 014) with richer
-- per-exercise defaults. Does NOT replace exercise_favorites (backward compat);
-- applications should migrate to this table over time.
CREATE TABLE IF NOT EXISTS user_exercise_preferences (
  id                    uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id               uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  exercise_id           uuid        NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
  rating                smallint    CHECK (rating >= 1 AND rating <= 5),
  is_favorite           boolean     NOT NULL DEFAULT false,
  default_weight        numeric     CHECK (default_weight >= 0),
  default_reps          smallint    CHECK (default_reps > 0 AND default_reps <= 100),
  default_rest_seconds  smallint    CHECK (default_rest_seconds > 0 AND default_rest_seconds <= 600),
  notes                 text,
  created_at            timestamptz NOT NULL DEFAULT now(),
  updated_at            timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, exercise_id)
);

COMMENT ON TABLE user_exercise_preferences IS
  'Per-user exercise preferences: rating, favorite flag, default weight/reps/rest. Supersedes exercise_favorites.';

-- Index for "show me my favorites" queries
CREATE INDEX IF NOT EXISTS user_exercise_prefs_favorites_idx
  ON user_exercise_preferences (user_id, is_favorite)
  WHERE is_favorite = true;

-- Index for "best rated exercises" queries
CREATE INDEX IF NOT EXISTS user_exercise_prefs_rating_idx
  ON user_exercise_preferences (user_id, rating DESC)
  WHERE rating IS NOT NULL;

-- Index for user_id (RLS column)
CREATE INDEX IF NOT EXISTS user_exercise_prefs_user_idx
  ON user_exercise_preferences (user_id);

CREATE TRIGGER user_exercise_prefs_updated_at
  BEFORE UPDATE ON user_exercise_preferences
  FOR EACH ROW
  EXECUTE FUNCTION set_updated_at();

ALTER TABLE user_exercise_preferences ENABLE ROW LEVEL SECURITY;

CREATE POLICY user_exercise_prefs_select ON user_exercise_preferences
  FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY user_exercise_prefs_insert ON user_exercise_preferences
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY user_exercise_prefs_update ON user_exercise_preferences
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY user_exercise_prefs_delete ON user_exercise_preferences
  FOR DELETE TO authenticated USING (user_id = auth.uid());

-- Migrate existing exercise_favorites into user_exercise_preferences
INSERT INTO user_exercise_preferences (user_id, exercise_id, is_favorite, notes, created_at)
SELECT user_id, exercise_id, true, notes, created_at
FROM exercise_favorites
ON CONFLICT (user_id, exercise_id) DO UPDATE SET
  is_favorite = true,
  notes = COALESCE(user_exercise_preferences.notes, EXCLUDED.notes);


-- =============================================================================
-- 2. VIEW: muscle_activation_weights
-- =============================================================================

-- Provides activation percentages for weighted volume calculations, falling back
-- to defaults when activation_percent is NULL:
--   - is_primary = true  → 100 (full agonist activation)
--   - is_primary = false → 50  (moderate synergist activation)
-- Also provides a normalized 0.0-1.0 weight factor for volume calculations.
--
-- This view is the single source of truth for activation-weighted volume queries.
-- Both weekly_muscle_volume and any future analytics should reference this view
-- or use the same logic.
CREATE OR REPLACE VIEW muscle_activation_weights
WITH (security_invoker = false) AS
SELECT
  em.exercise_id,
  em.muscle_group_id,
  em.is_primary,
  em.function_type,
  -- Effective activation: use actual value or fall back to defaults
  COALESCE(
    em.activation_percent,
    CASE WHEN em.is_primary THEN 100 ELSE 50 END
  )                                                     AS effective_activation_pct,
  -- Normalized weight factor (0.0 to 1.0) for volume calculations
  -- Stabilizers (activation < 30 or function_type = 'stabilizer') get 0.0
  -- to align with RP convention (stabilizer volume not counted)
  CASE
    WHEN em.function_type = 'stabilizer' THEN 0.0
    WHEN COALESCE(em.activation_percent,
         CASE WHEN em.is_primary THEN 100 ELSE 50 END) < 30 THEN 0.0
    ELSE COALESCE(
      em.activation_percent,
      CASE WHEN em.is_primary THEN 100 ELSE 50 END
    )::numeric / 100.0
  END                                                   AS volume_weight_factor,
  mg.name                                               AS muscle_group_name,
  mg.is_front                                           AS muscle_is_front
FROM exercise_muscles em
JOIN muscle_groups mg ON mg.id = em.muscle_group_id;

COMMENT ON VIEW muscle_activation_weights IS
  'Activation percentages with fallback defaults (primary=100, secondary=50). '
  'Provides volume_weight_factor (0.0-1.0) for weighted volume calculations. '
  'Stabilizers (function_type or activation <30) get 0.0 per RP convention.';


-- =============================================================================
-- 3. UPDATE VIEW: weekly_muscle_volume (use activation_percent)
-- =============================================================================

-- Replace the binary 1.0/0.5/0.0 weights with actual activation percentages.
-- Uses the muscle_activation_weights view logic inline for performance
-- (avoiding a view-on-view join that PostgreSQL may not optimize well).
CREATE OR REPLACE VIEW weekly_muscle_volume
WITH (security_invoker = true) AS
SELECT
  s.user_id,
  date_trunc('week', s.training_date)::date             AS week_start,
  mg.id                                                  AS muscle_group_id,
  mg.name                                                AS muscle_group_name,
  -- Weighted set count using activation percentages
  -- activation_percent / 100.0 gives proportional set credit
  -- Stabilizers get 0.0 (consistent with RP convention)
  SUM(
    CASE
      WHEN em.function_type = 'stabilizer' THEN 0.0
      WHEN COALESCE(em.activation_percent,
           CASE WHEN em.is_primary THEN 100 ELSE 50 END) < 30 THEN 0.0
      ELSE COALESCE(
        em.activation_percent,
        CASE WHEN em.is_primary THEN 100 ELSE 50 END
      )::numeric / 100.0
    END
  )                                                      AS weighted_sets,
  -- Raw (unweighted) set count for reference
  COUNT(*)                                               AS raw_sets,
  -- Volume (weight x reps, normalized to kg) with activation weighting
  SUM(
    CASE WHEN s.weight_unit = 'lb' THEN s.weight * 0.453592 ELSE s.weight END
    * s.reps
    * CASE
        WHEN em.function_type = 'stabilizer' THEN 0.0
        WHEN COALESCE(em.activation_percent,
             CASE WHEN em.is_primary THEN 100 ELSE 50 END) < 30 THEN 0.0
        ELSE COALESCE(
          em.activation_percent,
          CASE WHEN em.is_primary THEN 100 ELSE 50 END
        )::numeric / 100.0
      END
  )                                                      AS weighted_volume_kg,
  AVG(s.rpe) FILTER (WHERE s.rpe IS NOT NULL)            AS avg_rpe
FROM sets s
JOIN exercise_muscles em ON em.exercise_id = s.exercise_id
JOIN muscle_groups mg    ON mg.id = em.muscle_group_id
WHERE s.set_type IN ('working', 'backoff', 'failure')
  AND s.training_date IS NOT NULL
GROUP BY s.user_id, date_trunc('week', s.training_date), mg.id, mg.name;

COMMENT ON VIEW weekly_muscle_volume IS
  'Weekly sets per muscle group weighted by activation_percent (fallback: primary=100, secondary=50). '
  'Stabilizers and <30% activation get 0.0 per RP convention. Excludes warmups.';


-- =============================================================================
-- 4. NEW TABLE: workload_balance_scores
-- =============================================================================

-- Pre-computed weekly/monthly balance metrics for dashboard analytics.
-- Computed by backend cron job (not real-time) to avoid expensive queries
-- on every page load.
--
-- Metrics:
--   - Shannon entropy: diversity of muscle group training (higher = more balanced)
--     H = -SUM(p_i * ln(p_i)) where p_i = muscle_group_sets / total_sets
--     Max entropy = ln(N) where N = number of trained muscle groups
--   - Push/pull ratio: horizontal+vertical push sets / horizontal+vertical pull sets
--     Target: 0.67-1.0 (Kolber et al., 2009)
--   - Upper/lower ratio: upper body sets / lower body sets
--     Target: depends on goal; balanced ~1:1, bodybuilding often 2:1
--   - Normalized entropy: H / ln(N), ranges 0.0-1.0 for easy comparison
--   - Dominant muscle group: the muscle group with highest weighted volume
CREATE TABLE IF NOT EXISTS workload_balance_scores (
  id                    uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id               uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  period_type           text        NOT NULL CHECK (period_type IN ('week', 'month')),
  period_start          date        NOT NULL,
  period_end            date        NOT NULL,
  -- Shannon entropy of muscle group distribution
  shannon_entropy       numeric(6,4),
  -- Normalized entropy (0.0-1.0): entropy / ln(trained_muscle_count)
  normalized_entropy    numeric(5,4) CHECK (
    normalized_entropy IS NULL OR (normalized_entropy >= 0 AND normalized_entropy <= 1)
  ),
  -- Push/pull ratio (total push sets / total pull sets)
  push_pull_ratio       numeric(5,2),
  -- Upper/lower ratio (upper body sets / lower body sets)
  upper_lower_ratio     numeric(5,2),
  -- Horizontal push:pull ratio (Kolber impingement risk metric)
  h_push_pull_ratio     numeric(5,2),
  -- Number of distinct muscle groups trained
  trained_muscle_count  smallint    CHECK (trained_muscle_count >= 0),
  -- Total weighted sets in the period
  total_weighted_sets   numeric(8,2),
  -- Dominant muscle group (highest weighted volume)
  dominant_muscle_id    integer     REFERENCES muscle_groups(id),
  -- Raw data snapshot for drill-down (muscle_group_id → weighted_sets)
  muscle_distribution   jsonb       DEFAULT '{}',
  -- Computation metadata
  computed_at           timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, period_type, period_start),
  CHECK (period_end >= period_start)
);

COMMENT ON TABLE workload_balance_scores IS
  'Pre-computed balance metrics per week/month. Shannon entropy, push/pull ratio, upper/lower ratio. '
  'Computed by backend cron. muscle_distribution holds per-muscle-group breakdown.';

-- Primary lookup: user's balance scores over time
CREATE INDEX IF NOT EXISTS workload_balance_user_period_idx
  ON workload_balance_scores (user_id, period_type, period_start DESC);

-- Index for "find unbalanced weeks" queries
CREATE INDEX IF NOT EXISTS workload_balance_entropy_idx
  ON workload_balance_scores (user_id, normalized_entropy)
  WHERE normalized_entropy IS NOT NULL;

ALTER TABLE workload_balance_scores ENABLE ROW LEVEL SECURITY;

CREATE POLICY workload_balance_scores_select ON workload_balance_scores
  FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY workload_balance_scores_insert ON workload_balance_scores
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY workload_balance_scores_update ON workload_balance_scores
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY workload_balance_scores_delete ON workload_balance_scores
  FOR DELETE TO authenticated USING (user_id = auth.uid());


-- =============================================================================
-- 5. FUNCTION: compute_workload_balance (service_role only)
-- =============================================================================

-- Computes and upserts workload balance scores for a given user and period.
-- Called by backend cron job after analytics_cache refresh.
CREATE OR REPLACE FUNCTION compute_workload_balance(
  p_user_id       uuid,
  p_period_type   text,
  p_period_start  date,
  p_period_end    date
) RETURNS void AS $$
DECLARE
  v_total_weighted numeric;
  v_trained_count  integer;
  v_entropy        numeric;
  v_norm_entropy   numeric;
  v_push_sets      numeric;
  v_pull_sets      numeric;
  v_upper_sets     numeric;
  v_lower_sets     numeric;
  v_h_push         numeric;
  v_h_pull         numeric;
  v_dominant_id    integer;
  v_distribution   jsonb;
BEGIN
  -- Compute per-muscle-group weighted sets for the period
  WITH muscle_stats AS (
    SELECT
      mg.id AS muscle_group_id,
      SUM(
        CASE
          WHEN em.function_type = 'stabilizer' THEN 0.0
          WHEN COALESCE(em.activation_percent,
               CASE WHEN em.is_primary THEN 100 ELSE 50 END) < 30 THEN 0.0
          ELSE COALESCE(
            em.activation_percent,
            CASE WHEN em.is_primary THEN 100 ELSE 50 END
          )::numeric / 100.0
        END
      ) AS weighted_sets
    FROM sets s
    JOIN exercise_muscles em ON em.exercise_id = s.exercise_id
    JOIN muscle_groups mg    ON mg.id = em.muscle_group_id
    WHERE s.user_id = p_user_id
      AND s.training_date >= p_period_start
      AND s.training_date <= p_period_end
      AND s.set_type IN ('working', 'backoff', 'failure')
    GROUP BY mg.id
    HAVING SUM(
      CASE
        WHEN em.function_type = 'stabilizer' THEN 0.0
        WHEN COALESCE(em.activation_percent,
             CASE WHEN em.is_primary THEN 100 ELSE 50 END) < 30 THEN 0.0
        ELSE COALESCE(
          em.activation_percent,
          CASE WHEN em.is_primary THEN 100 ELSE 50 END
        )::numeric / 100.0
      END
    ) > 0
  )
  SELECT
    SUM(weighted_sets),
    COUNT(*),
    -- Shannon entropy: -SUM(p_i * ln(p_i))
    -SUM(
      (weighted_sets / NULLIF(SUM(weighted_sets) OVER (), 0))
      * LN(weighted_sets / NULLIF(SUM(weighted_sets) OVER (), 0))
    ),
    -- JSON distribution
    jsonb_object_agg(muscle_group_id, ROUND(weighted_sets, 2)),
    -- Dominant muscle
    (ARRAY_AGG(muscle_group_id ORDER BY weighted_sets DESC))[1]
  INTO v_total_weighted, v_trained_count, v_entropy, v_distribution, v_dominant_id
  FROM muscle_stats;

  -- Normalized entropy
  IF v_trained_count > 1 THEN
    v_norm_entropy := ROUND(v_entropy / LN(v_trained_count), 4);
  ELSE
    v_norm_entropy := NULL;
  END IF;

  -- Push/pull ratio from movement patterns
  SELECT
    COALESCE(SUM(CASE WHEN e.movement_pattern IN ('horizontal_push', 'vertical_push') THEN 1 ELSE 0 END), 0),
    COALESCE(SUM(CASE WHEN e.movement_pattern IN ('horizontal_pull', 'vertical_pull') THEN 1 ELSE 0 END), 0),
    COALESCE(SUM(CASE WHEN e.movement_pattern IN ('horizontal_push', 'horizontal_pull', 'vertical_push', 'vertical_pull') THEN 1 ELSE 0 END), 0),
    COALESCE(SUM(CASE WHEN e.movement_pattern IN ('squat', 'hip_hinge', 'lunge') THEN 1 ELSE 0 END), 0),
    COALESCE(SUM(CASE WHEN e.movement_pattern = 'horizontal_push' THEN 1 ELSE 0 END), 0),
    COALESCE(SUM(CASE WHEN e.movement_pattern = 'horizontal_pull' THEN 1 ELSE 0 END), 0)
  INTO v_push_sets, v_pull_sets, v_upper_sets, v_lower_sets, v_h_push, v_h_pull
  FROM sets s
  JOIN exercises e ON e.id = s.exercise_id
  WHERE s.user_id = p_user_id
    AND s.training_date >= p_period_start
    AND s.training_date <= p_period_end
    AND s.set_type IN ('working', 'backoff', 'failure');

  -- Upsert the score
  INSERT INTO workload_balance_scores (
    user_id, period_type, period_start, period_end,
    shannon_entropy, normalized_entropy,
    push_pull_ratio, upper_lower_ratio, h_push_pull_ratio,
    trained_muscle_count, total_weighted_sets,
    dominant_muscle_id, muscle_distribution, computed_at
  ) VALUES (
    p_user_id, p_period_type, p_period_start, p_period_end,
    ROUND(v_entropy, 4),
    v_norm_entropy,
    ROUND(v_push_sets::numeric / NULLIF(v_pull_sets, 0), 2),
    ROUND(v_upper_sets::numeric / NULLIF(v_lower_sets, 0), 2),
    ROUND(v_h_push::numeric / NULLIF(v_h_pull, 0), 2),
    v_trained_count,
    ROUND(v_total_weighted, 2),
    v_dominant_id,
    COALESCE(v_distribution, '{}'),
    now()
  )
  ON CONFLICT (user_id, period_type, period_start)
  DO UPDATE SET
    period_end           = EXCLUDED.period_end,
    shannon_entropy      = EXCLUDED.shannon_entropy,
    normalized_entropy   = EXCLUDED.normalized_entropy,
    push_pull_ratio      = EXCLUDED.push_pull_ratio,
    upper_lower_ratio    = EXCLUDED.upper_lower_ratio,
    h_push_pull_ratio    = EXCLUDED.h_push_pull_ratio,
    trained_muscle_count = EXCLUDED.trained_muscle_count,
    total_weighted_sets  = EXCLUDED.total_weighted_sets,
    dominant_muscle_id   = EXCLUDED.dominant_muscle_id,
    muscle_distribution  = EXCLUDED.muscle_distribution,
    computed_at          = EXCLUDED.computed_at;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION compute_workload_balance IS
  'Computes and upserts workload balance scores (entropy, ratios) for a user/period. '
  'Call from backend cron after set mutations.';

-- Restrict to service_role only (same pattern as recompute_workout_clusters)
REVOKE EXECUTE ON FUNCTION compute_workload_balance(uuid, text, date, date) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION compute_workload_balance(uuid, text, date, date) FROM authenticated;
GRANT EXECUTE ON FUNCTION compute_workload_balance(uuid, text, date, date) TO service_role;

COMMIT;
