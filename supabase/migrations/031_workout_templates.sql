-- Migration 031: Workout Templates
-- Adds workout_templates and workout_template_items tables for quick-start
-- session logging from saved workout structures.
--
-- Validated by: fitness-domain-expert agent, database-specialist agent
--
-- Key design decisions:
--   - Templates are lightweight plan alternatives for repeat workouts
--   - source_type tracks provenance (manual, from_session, from_plan_day)
--   - Template items use rep range (min/max) and support variant_id,
--     matching plan_items pattern per domain expert recommendation
--   - use_count and last_used_at enable "most used" sorting
--   - RLS follows plan_days/plan_items hierarchical pattern

BEGIN;

-- =============================================================================
-- 1. TABLE: workout_templates
-- =============================================================================

CREATE TABLE IF NOT EXISTS workout_templates (
  id                uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id           uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name              text        NOT NULL CHECK (length(trim(name)) > 0),
  description       text,
  source_type       text        NOT NULL DEFAULT 'manual'
    CHECK (source_type IN ('manual', 'from_session', 'from_plan_day')),
  source_date       date,
  source_plan_day_id uuid       REFERENCES plan_days(id) ON DELETE SET NULL,
  is_pinned         boolean     NOT NULL DEFAULT false,
  use_count         integer     NOT NULL DEFAULT 0 CHECK (use_count >= 0),
  last_used_at      timestamptz,
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE workout_templates IS
  'Saved workout structures for quick-start logging. Lighter than plans — '
  'designed for repeat sessions with one-tap start.';
COMMENT ON COLUMN workout_templates.source_type IS
  'manual = user-created; from_session = cloned from past training day; '
  'from_plan_day = cloned from a plan day.';

-- Indexes
CREATE INDEX IF NOT EXISTS workout_templates_user_idx
  ON workout_templates (user_id, is_pinned DESC, last_used_at DESC NULLS LAST);

CREATE INDEX IF NOT EXISTS workout_templates_use_count_idx
  ON workout_templates (user_id, use_count DESC)
  WHERE use_count > 0;

-- RLS
ALTER TABLE workout_templates ENABLE ROW LEVEL SECURITY;

CREATE POLICY workout_templates_select ON workout_templates
  FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY workout_templates_insert ON workout_templates
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY workout_templates_update ON workout_templates
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY workout_templates_delete ON workout_templates
  FOR DELETE TO authenticated USING (user_id = auth.uid());

CREATE TRIGGER workout_templates_updated_at
  BEFORE UPDATE ON workout_templates
  FOR EACH ROW
  EXECUTE FUNCTION set_updated_at();


-- =============================================================================
-- 2. TABLE: workout_template_items
-- =============================================================================

CREATE TABLE IF NOT EXISTS workout_template_items (
  id                uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  template_id       uuid        NOT NULL REFERENCES workout_templates(id) ON DELETE CASCADE,
  exercise_id       uuid        NOT NULL REFERENCES exercises(id) ON DELETE RESTRICT,
  variant_id        uuid        REFERENCES equipment_variants(id) ON DELETE SET NULL,
  sort_order        smallint    NOT NULL DEFAULT 0,
  target_sets       smallint    CHECK (target_sets > 0 AND target_sets <= 20),
  target_reps_min   smallint    CHECK (target_reps_min > 0 AND target_reps_min <= 100),
  target_reps_max   smallint    CHECK (target_reps_max > 0 AND target_reps_max <= 100),
  target_weight     numeric     CHECK (target_weight >= 0),
  target_rpe        numeric(3,1) CHECK (target_rpe >= 1 AND target_rpe <= 10),
  target_rir        smallint    CHECK (target_rir >= 0 AND target_rir <= 10),
  rest_seconds      integer     CHECK (rest_seconds > 0 AND rest_seconds <= 600),
  superset_group    smallint,
  notes             text,
  CONSTRAINT template_items_rep_range_check
    CHECK (target_reps_min IS NULL OR target_reps_max IS NULL
           OR target_reps_min <= target_reps_max)
);

COMMENT ON TABLE workout_template_items IS
  'Individual exercises within a workout template. Mirrors plan_items fields '
  'with variant_id for machine-specific prescriptions.';
COMMENT ON COLUMN workout_template_items.variant_id IS
  'Equipment variant for machine-specific templates (e.g., "Bench on Hammer Strength, seat 3").';
COMMENT ON COLUMN workout_template_items.target_rir IS
  'Reps In Reserve (0-10). Alternative intensity metric to RPE. '
  'Many lifters prefer RIR for hypertrophy (RP convention).';

-- Indexes
CREATE INDEX IF NOT EXISTS workout_template_items_template_idx
  ON workout_template_items (template_id, sort_order);

CREATE INDEX IF NOT EXISTS workout_template_items_exercise_idx
  ON workout_template_items (exercise_id);

-- RLS (hierarchical via template ownership)
ALTER TABLE workout_template_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY workout_template_items_select ON workout_template_items
  FOR SELECT TO authenticated
  USING (template_id IN (
    SELECT id FROM workout_templates WHERE user_id = auth.uid()
  ));
CREATE POLICY workout_template_items_insert ON workout_template_items
  FOR INSERT TO authenticated
  WITH CHECK (template_id IN (
    SELECT id FROM workout_templates WHERE user_id = auth.uid()
  ));
CREATE POLICY workout_template_items_update ON workout_template_items
  FOR UPDATE TO authenticated
  USING (template_id IN (
    SELECT id FROM workout_templates WHERE user_id = auth.uid()
  ))
  WITH CHECK (template_id IN (
    SELECT id FROM workout_templates WHERE user_id = auth.uid()
  ));
CREATE POLICY workout_template_items_delete ON workout_template_items
  FOR DELETE TO authenticated
  USING (template_id IN (
    SELECT id FROM workout_templates WHERE user_id = auth.uid()
  ));

COMMIT;
