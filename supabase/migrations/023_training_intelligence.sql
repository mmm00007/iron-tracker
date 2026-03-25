-- Migration 023: Training Intelligence Enrichment
-- Adds sleep/workout windows, equipment ratings, plan adherence tracking,
-- weight range prescriptions, muscle antagonist pairs, user exercise notes,
-- training milestones, exercise progression metadata, and equipment usage view.
--
-- Inspired by: github.com/mmm00007/gym-tracker user_preferences, adherence.js,
-- equipment_set_counts view, and recommendation models.
-- Validated by: fitness-domain-expert, database-specialist agents
--
-- Key design decisions (from expert validation):
--   - Exercise progressions merged into exercise_substitutions (avoids table duplication)
--   - Milestones use partial unique indexes for nullable exercise_id (prevents duplicates)
--   - Adherence ratio is a generated column (eliminates data inconsistency)
--   - Antagonist pairs enforce canonical ordering (muscle_a_id < muscle_b_id)
--   - Equipment usage view wraps RANK() in subquery (valid SQL)
--   - Sleep windows support overnight semantics (22:00 -> 06:30)

BEGIN;

-- =============================================================================
-- 1. PROFILES: Sleep & workout time windows
-- =============================================================================

-- Typical sleep window. Supports overnight semantics (start > end means cross-midnight).
-- Used for deviation detection ("you slept 2h less than usual") and recovery modeling
-- ("late training + early wake = compressed recovery window").
-- Source: Knowles et al. (2018, Sports Medicine): sleep <6h impairs strength performance.
ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS sleep_window_start time,
  ADD COLUMN IF NOT EXISTS sleep_window_end time;

COMMENT ON COLUMN profiles.sleep_window_start IS 'Typical bedtime (e.g., 22:30). Overnight OK: 22:30->06:30 = 8h sleep.';
COMMENT ON COLUMN profiles.sleep_window_end IS 'Typical wake time (e.g., 06:30). Used for recovery deviation detection.';

-- Preferred workout time range. Non-overnight (start must be before end).
-- Source: Chtourou & Souissi (2012, Sports Medicine): time-of-day affects strength.
ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS workout_window_start time,
  ADD COLUMN IF NOT EXISTS workout_window_end time;

COMMENT ON COLUMN profiles.workout_window_start IS 'Preferred earliest workout start. Detects out-of-window training.';
COMMENT ON COLUMN profiles.workout_window_end IS 'Preferred latest workout end.';

-- Workout window ordering constraint (non-overnight)
ALTER TABLE profiles DROP CONSTRAINT IF EXISTS profiles_workout_window_order;
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'profiles_workout_window_order'
  ) THEN
    ALTER TABLE profiles ADD CONSTRAINT profiles_workout_window_order CHECK (
      workout_window_start IS NULL OR workout_window_end IS NULL
      OR workout_window_start < workout_window_end
    );
  END IF;
END $$;


-- =============================================================================
-- 2. EQUIPMENT VARIANTS: Rating
-- =============================================================================

-- User preference rating (1-5). "How much do you like this equipment?"
-- 1 = avoid, 5 = favorite. Used for exercise recommendations and sorting.
-- NOT used for progressive overload or effectiveness inference.
ALTER TABLE equipment_variants
  ADD COLUMN IF NOT EXISTS rating smallint
    CHECK (rating >= 1 AND rating <= 5);

COMMENT ON COLUMN equipment_variants.rating IS 'User preference 1-5. Drives sorting/recommendations, not overload logic.';

-- Index covering the likely access pattern: "best-rated variant for this exercise"
CREATE INDEX IF NOT EXISTS equipment_variants_rating_idx
  ON equipment_variants (user_id, exercise_id, rating DESC)
  WHERE rating IS NOT NULL;


-- =============================================================================
-- 3. NEW TABLE: plan_adherence_log
-- =============================================================================

-- Auto-computed daily plan adherence. Backend writes this by diffing sets vs plan_items.
-- Adherence is one of the strongest predictors of training outcomes
-- (Steele et al., 2017, PeerJ; Hackett et al., 2018, Sports Medicine).
CREATE TABLE IF NOT EXISTS plan_adherence_log (
  id              uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  plan_id         uuid        NOT NULL REFERENCES plans(id) ON DELETE CASCADE,
  plan_day_id     uuid        REFERENCES plan_days(id) ON DELETE SET NULL,
  training_date   date        NOT NULL,
  planned_sets    integer     NOT NULL DEFAULT 0 CHECK (planned_sets >= 0),
  completed_sets  integer     NOT NULL DEFAULT 0 CHECK (completed_sets >= 0),
  adherence_ratio numeric(4,3) GENERATED ALWAYS AS (
    CASE WHEN planned_sets > 0
      THEN LEAST(completed_sets::numeric / planned_sets, 1.0)
      ELSE NULL
    END
  ) STORED,
  items_complete  integer     NOT NULL DEFAULT 0 CHECK (items_complete >= 0),
  items_partial   integer     NOT NULL DEFAULT 0 CHECK (items_partial >= 0),
  items_skipped   integer     NOT NULL DEFAULT 0 CHECK (items_skipped >= 0),
  surplus_sets    integer     NOT NULL DEFAULT 0 CHECK (surplus_sets >= 0),
  computed_at     timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, plan_id, training_date)
);
COMMENT ON TABLE plan_adherence_log IS 'Auto-computed daily plan adherence. Ratio is a generated column from completed/planned sets.';

CREATE INDEX IF NOT EXISTS plan_adherence_user_date_idx
  ON plan_adherence_log (user_id, training_date DESC);
CREATE INDEX IF NOT EXISTS plan_adherence_plan_date_idx
  ON plan_adherence_log (user_id, plan_id, training_date DESC);

ALTER TABLE plan_adherence_log ENABLE ROW LEVEL SECURITY;

CREATE POLICY plan_adherence_log_select ON plan_adherence_log
  FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY plan_adherence_log_insert ON plan_adherence_log
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY plan_adherence_log_update ON plan_adherence_log
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY plan_adherence_log_delete ON plan_adherence_log
  FOR DELETE TO authenticated USING (user_id = auth.uid());


-- =============================================================================
-- 4. PLAN ITEMS: Weight range & percentage prescriptions
-- =============================================================================

-- Minimum target weight for load range prescriptions (e.g., 75-85 kg).
ALTER TABLE plan_items
  ADD COLUMN IF NOT EXISTS target_weight_min numeric CHECK (target_weight_min >= 0);

-- Maximum target weight.
ALTER TABLE plan_items
  ADD COLUMN IF NOT EXISTS target_weight_max numeric CHECK (target_weight_max >= 0);

-- Co-constraint: min must be <= max when both are set.
ALTER TABLE plan_items DROP CONSTRAINT IF EXISTS plan_items_weight_range_order;
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'plan_items_weight_range_order'
  ) THEN
    ALTER TABLE plan_items ADD CONSTRAINT plan_items_weight_range_order CHECK (
      target_weight_min IS NULL OR target_weight_max IS NULL
      OR target_weight_min <= target_weight_max
    );
  END IF;
END $$;

-- Percentage of estimated 1RM. Most widely used prescription method in
-- evidence-based programs (NSCA Essentials, 4th ed.; Wendler 5/3/1).
-- E.g., 0.75 = 75% of e1RM. Requires a known e1RM for the exercise.
ALTER TABLE plan_items
  ADD COLUMN IF NOT EXISTS target_weight_pct numeric(4,1)
    CHECK (target_weight_pct > 0 AND target_weight_pct <= 120);

COMMENT ON COLUMN plan_items.target_weight_pct IS 'Percentage of estimated 1RM (e.g., 75.0 = 75%). Requires known e1RM.';
COMMENT ON COLUMN plan_items.target_weight_min IS 'Minimum target weight. Existing target_weight is a single fixed value; min/max allows ranges.';


-- =============================================================================
-- 5. NEW TABLE: muscle_antagonist_pairs (reference data)
-- =============================================================================

-- Standard antagonist muscle pairs for superset recommendations and balance analytics.
-- Agonist-to-antagonist volume ratios >1.5:1 are a risk factor for shoulder
-- impingement (Kolber et al., 2009). Antagonist supersets show minimal
-- performance decrement (Robbins et al., 2010; Paz et al., 2017, JSCR).
--
-- Symmetric relationship: if A opposes B, then B opposes A.
-- Canonical ordering enforced: muscle_a_id < muscle_b_id (one row per pair).
CREATE TABLE IF NOT EXISTS muscle_antagonist_pairs (
  id                    serial    PRIMARY KEY,
  muscle_a_id           integer   NOT NULL REFERENCES muscle_groups(id),
  muscle_b_id           integer   NOT NULL REFERENCES muscle_groups(id),
  pair_name             text      NOT NULL,
  pair_strength         text      NOT NULL DEFAULT 'strong' CHECK (pair_strength IN ('strong', 'moderate')),
  CHECK (muscle_a_id < muscle_b_id),
  UNIQUE (muscle_a_id, muscle_b_id)
);
COMMENT ON TABLE muscle_antagonist_pairs IS 'Symmetric antagonist pairs. Canonical ordering: muscle_a_id < muscle_b_id.';

CREATE INDEX IF NOT EXISTS muscle_antagonist_b_idx
  ON muscle_antagonist_pairs (muscle_b_id);

ALTER TABLE muscle_antagonist_pairs ENABLE ROW LEVEL SECURITY;

-- Public read (reference data, same as muscle_groups)
CREATE POLICY muscle_antagonist_pairs_select ON muscle_antagonist_pairs
  FOR SELECT TO authenticated USING (true);


-- =============================================================================
-- 6. NEW TABLE: user_exercise_notes
-- =============================================================================

-- Per-exercise personal notes. Experienced lifters maintain form cues,
-- injury considerations, and setup preferences per exercise.
-- form_cues and injury_notes kept separate: injury warnings surface
-- before exercise begins (distinct UX action from showing form cues).
CREATE TABLE IF NOT EXISTS user_exercise_notes (
  id                    uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id               uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  exercise_id           uuid        NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
  form_cues             text,
  injury_notes          text,
  personal_best_context text,
  preferred_grip        text,
  preferred_stance      text,
  preferred_rep_range   text,
  created_at            timestamptz NOT NULL DEFAULT now(),
  updated_at            timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, exercise_id)
);
COMMENT ON TABLE user_exercise_notes IS 'Per-exercise personal notes: form cues, injury flags, grip/stance preferences.';

CREATE TRIGGER user_exercise_notes_updated_at
  BEFORE UPDATE ON user_exercise_notes
  FOR EACH ROW
  EXECUTE FUNCTION set_updated_at();

ALTER TABLE user_exercise_notes ENABLE ROW LEVEL SECURITY;

CREATE POLICY user_exercise_notes_select ON user_exercise_notes
  FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY user_exercise_notes_insert ON user_exercise_notes
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY user_exercise_notes_update ON user_exercise_notes
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY user_exercise_notes_delete ON user_exercise_notes
  FOR DELETE TO authenticated USING (user_id = auth.uid());


-- =============================================================================
-- 7. NEW TABLE: training_milestones
-- =============================================================================

-- Strength milestones use bodyweight multiples (the standard metric in
-- the lifting community; ExRx, Kilgore, Symmetric Strength).
-- BW milestones use e1RM at time of achievement, locked to BW at that time.
-- Once achieved, milestones are permanent (not re-evaluated on BW change).
--
-- Streak milestones are "consistency" based (target frequency met for N weeks),
-- NOT raw consecutive days (which incentivizes training through injury).
CREATE TABLE IF NOT EXISTS training_milestones (
  id              uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  milestone_type  text        NOT NULL,
  exercise_id     uuid        REFERENCES exercises(id) ON DELETE SET NULL,
  value           numeric,
  unit            text        CHECK (unit IS NULL OR unit IN ('kg', 'lb', 'sets', 'reps', 'days', 'weeks', 'ratio')),
  achieved_at     timestamptz NOT NULL DEFAULT now(),
  body_weight_at  numeric,
  notes           text
);
COMMENT ON TABLE training_milestones IS 'Permanent achievements. BW milestones locked to body weight at time of achievement.';

-- Partial unique indexes to handle nullable exercise_id correctly.
-- PostgreSQL: NULL != NULL in UNIQUE constraints, so we need two indexes.
CREATE UNIQUE INDEX IF NOT EXISTS training_milestones_global_idx
  ON training_milestones (user_id, milestone_type)
  WHERE exercise_id IS NULL;

CREATE UNIQUE INDEX IF NOT EXISTS training_milestones_exercise_idx
  ON training_milestones (user_id, milestone_type, exercise_id)
  WHERE exercise_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS training_milestones_user_date_idx
  ON training_milestones (user_id, achieved_at DESC);

ALTER TABLE training_milestones ENABLE ROW LEVEL SECURITY;

CREATE POLICY training_milestones_select ON training_milestones
  FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY training_milestones_insert ON training_milestones
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY training_milestones_update ON training_milestones
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY training_milestones_delete ON training_milestones
  FOR DELETE TO authenticated USING (user_id = auth.uid());


-- =============================================================================
-- 8. EXERCISE SUBSTITUTIONS: Progression metadata
-- =============================================================================

-- Extend existing exercise_substitutions table with progression metadata
-- instead of creating a separate exercise_progressions table.
-- Domain expert recommendation: all exercise relationships in one table.

-- Progression ordering within a chain (e.g., push-up chain: 1->2->3->4).
ALTER TABLE exercise_substitutions
  ADD COLUMN IF NOT EXISTS progression_order smallint
    CHECK (progression_order >= 1);

-- Prerequisite e1RM ratio (bodyweight multiple) before progressing.
-- E.g., 0.8 = "can do 0.8x BW before attempting this progression."
ALTER TABLE exercise_substitutions
  ADD COLUMN IF NOT EXISTS prerequisite_1rm_ratio numeric(3,2)
    CHECK (prerequisite_1rm_ratio > 0 AND prerequisite_1rm_ratio <= 5);

COMMENT ON COLUMN exercise_substitutions.progression_order IS 'Sequence within a progression chain. Only set for regression/progression types.';
COMMENT ON COLUMN exercise_substitutions.prerequisite_1rm_ratio IS 'BW multiple e1RM required before progressing. E.g., 0.8 = 80% bodyweight.';

-- Index for traversing progression chains
CREATE INDEX IF NOT EXISTS exercise_subs_progression_idx
  ON exercise_substitutions (source_exercise_id, progression_order)
  WHERE progression_order IS NOT NULL;


-- =============================================================================
-- 9. VIEW: equipment_usage_stats
-- =============================================================================

-- Per-equipment-variant usage statistics with recency ranking.
-- Wraps RANK() in subquery per database-specialist recommendation.
CREATE OR REPLACE VIEW equipment_usage_stats
WITH (security_invoker = true) AS
SELECT
  sub.*,
  RANK() OVER (PARTITION BY sub.user_id ORDER BY sub.sets_30d DESC) AS rank_30d,
  RANK() OVER (PARTITION BY sub.user_id ORDER BY sub.sets_90d DESC) AS rank_90d
FROM (
  SELECT
    user_id,
    variant_id AS equipment_variant_id,
    exercise_id,
    COUNT(*) FILTER (WHERE logged_at >= NOW() - interval '30 days')  AS sets_30d,
    COUNT(*) FILTER (WHERE logged_at >= NOW() - interval '90 days')  AS sets_90d,
    COUNT(*)                                                          AS sets_all_time,
    MAX(logged_at)                                                    AS last_used_at
  FROM sets
  WHERE variant_id IS NOT NULL
  GROUP BY user_id, variant_id, exercise_id
) sub;

COMMENT ON VIEW equipment_usage_stats IS 'Per-variant set counts over 30d/90d/all-time with recency ranking. RLS via security_invoker.';


COMMIT;
