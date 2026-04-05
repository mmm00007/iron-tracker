-- Migration 059: Training Phases (Periodization Context)
-- User-declared training phases provide context for analytics, effectiveness
-- scoring, and coaching. Each user has at most one active phase at any time.
--
-- Framework: Block periodization (Bompa 2019, NSCA 2016). Single authoritative
-- phase_type enum covering mainstream block and DUP models, plus a phase_label
-- text column for user custom names ("Push Block A", "Meet Prep 2026-Q2").
--
-- Validated by: fitness-domain-expert, data-science-expert, database-specialist
--
-- Key design decisions:
--   - Enum excludes 'recomp' (nutrition status, not training phase)
--   - Enum excludes 'general' from phase_type; NULL phase_id means general
--   - 'technique_primer' replaces shorter 'technique' (clearer UX)
--   - Added 'active_recovery' as distinct from 'deload'
--   - Single active phase per user enforced via partial unique index on end_date IS NULL
--   - plans.phase_id FK uses ON DELETE SET NULL (plans outlive phases)
--   - phase_type_defaults reference table seeded with NSCA/RP evidence-based targets
--   - deload remains its own phase_type AND a deload_trigger column on main phases
--     (captures both planned and reactive deloads)
--
-- Citations:
--   - NSCA (2016). Essentials of Strength Training and Conditioning, 4th ed. Ch. 21.
--   - Bompa T., Buzzichelli C. (2019). Periodization: Theory and Methodology, 6th ed.
--   - Helms E. et al. (2019). The Muscle and Strength Pyramid: Training.
--   - Israetel M. et al. (2021). Scientific Principles of Hypertrophy Training.
--   - Schoenfeld B.J. et al. (2017). Meta-analysis on rep ranges. JSCR.

BEGIN;

-- =============================================================================
-- 1. REFERENCE TABLE: phase_type_defaults
-- =============================================================================
-- Recommended parameters per phase type. Users can override per phase instance.

CREATE TABLE IF NOT EXISTS phase_type_defaults (
  phase_type                       text        PRIMARY KEY,
  display_name                     text        NOT NULL,
  typical_weeks_min                smallint    NOT NULL CHECK (typical_weeks_min > 0),
  typical_weeks_max                smallint    NOT NULL CHECK (typical_weeks_max >= typical_weeks_min),
  target_rep_range_min             smallint    CHECK (target_rep_range_min > 0),
  target_rep_range_max             smallint    CHECK (target_rep_range_max > 0),
  target_rpe_min                   numeric(3,1) CHECK (target_rpe_min >= 1 AND target_rpe_min <= 10),
  target_rpe_max                   numeric(3,1) CHECK (target_rpe_max >= 1 AND target_rpe_max <= 10),
  target_intensity_pct_1rm_min     smallint    CHECK (target_intensity_pct_1rm_min > 0 AND target_intensity_pct_1rm_min <= 100),
  target_intensity_pct_1rm_max     smallint    CHECK (target_intensity_pct_1rm_max > 0 AND target_intensity_pct_1rm_max <= 100),
  weekly_volume_pct_of_mav_min     smallint    CHECK (weekly_volume_pct_of_mav_min >= 0 AND weekly_volume_pct_of_mav_min <= 200),
  weekly_volume_pct_of_mav_max     smallint    CHECK (weekly_volume_pct_of_mav_max >= 0 AND weekly_volume_pct_of_mav_max <= 200),
  description                      text,
  citation                         text,
  CONSTRAINT phase_type_defaults_rep_order_check
    CHECK (target_rep_range_min IS NULL OR target_rep_range_max IS NULL
           OR target_rep_range_min <= target_rep_range_max),
  CONSTRAINT phase_type_defaults_rpe_order_check
    CHECK (target_rpe_min IS NULL OR target_rpe_max IS NULL
           OR target_rpe_min <= target_rpe_max),
  CONSTRAINT phase_type_defaults_intensity_order_check
    CHECK (target_intensity_pct_1rm_min IS NULL OR target_intensity_pct_1rm_max IS NULL
           OR target_intensity_pct_1rm_min <= target_intensity_pct_1rm_max),
  CONSTRAINT phase_type_defaults_volume_order_check
    CHECK (weekly_volume_pct_of_mav_min IS NULL OR weekly_volume_pct_of_mav_max IS NULL
           OR weekly_volume_pct_of_mav_min <= weekly_volume_pct_of_mav_max)
);

COMMENT ON TABLE phase_type_defaults IS
  'Evidence-based recommended parameters per training phase type. Used to '
  'pre-fill training_phases form fields and for analytics normalization.';

ALTER TABLE phase_type_defaults ENABLE ROW LEVEL SECURITY;
CREATE POLICY phase_type_defaults_select ON phase_type_defaults
  FOR SELECT TO authenticated USING (true);

-- =============================================================================
-- 2. USER TABLE: training_phases
-- =============================================================================

CREATE TABLE IF NOT EXISTS training_phases (
  id                              uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id                         uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name                            text        NOT NULL CHECK (length(trim(name)) > 0),
  phase_type                      text        NOT NULL
    REFERENCES phase_type_defaults(phase_type) ON UPDATE CASCADE ON DELETE RESTRICT,
  phase_label                     text,
  start_date                      date        NOT NULL,
  end_date                        date,
  planned_weeks                   smallint    CHECK (planned_weeks > 0 AND planned_weeks <= 52),
  target_rep_range_min            smallint    CHECK (target_rep_range_min > 0 AND target_rep_range_min <= 100),
  target_rep_range_max            smallint    CHECK (target_rep_range_max > 0 AND target_rep_range_max <= 100),
  target_rpe_min                  numeric(3,1) CHECK (target_rpe_min >= 1 AND target_rpe_min <= 10),
  target_rpe_max                  numeric(3,1) CHECK (target_rpe_max >= 1 AND target_rpe_max <= 10),
  target_weekly_sets_adjustment   numeric(4,2) NOT NULL DEFAULT 1.00
                                              CHECK (target_weekly_sets_adjustment >= 0 AND target_weekly_sets_adjustment <= 3),
  deload_trigger                  text        CHECK (deload_trigger IN ('planned', 'auto_fatigue', 'user_initiated', 'none')),
  mesocycle_number                smallint    CHECK (mesocycle_number > 0),
  autoregulation_mode             text        NOT NULL DEFAULT 'rpe_based'
                                              CHECK (autoregulation_mode IN ('fixed_plan', 'rpe_based', 'velocity_based', 'intuitive')),
  notes                           text,
  created_at                      timestamptz NOT NULL DEFAULT now(),
  updated_at                      timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT training_phases_date_order_check
    CHECK (end_date IS NULL OR end_date >= start_date),
  CONSTRAINT training_phases_rep_range_order_check
    CHECK (target_rep_range_min IS NULL OR target_rep_range_max IS NULL
           OR target_rep_range_min <= target_rep_range_max),
  CONSTRAINT training_phases_rpe_range_order_check
    CHECK (target_rpe_min IS NULL OR target_rpe_max IS NULL
           OR target_rpe_min <= target_rpe_max)
);

COMMENT ON TABLE training_phases IS
  'User-declared training phases providing periodization context for analytics. '
  'Single active phase per user via partial unique index on (user_id) WHERE end_date IS NULL. '
  'NULL phase_id on sets/plans resolves to a user''s implicit "general" phase.';

COMMENT ON COLUMN training_phases.phase_label IS
  'User-friendly custom name (e.g., "Push Block A", "Meet Prep Q2"). Distinct from canonical phase_type.';

COMMENT ON COLUMN training_phases.deload_trigger IS
  'planned: scheduled in advance; auto_fatigue: triggered by ACWR/fatigue signals; user_initiated: ad-hoc.';

-- Enforce single active phase per user
CREATE UNIQUE INDEX IF NOT EXISTS training_phases_one_active_per_user_idx
  ON training_phases (user_id)
  WHERE end_date IS NULL;

-- Common access patterns
CREATE INDEX IF NOT EXISTS training_phases_user_start_idx
  ON training_phases (user_id, start_date DESC);

CREATE INDEX IF NOT EXISTS training_phases_user_range_idx
  ON training_phases (user_id, start_date, end_date);

ALTER TABLE training_phases ENABLE ROW LEVEL SECURITY;

CREATE POLICY training_phases_select ON training_phases
  FOR SELECT TO authenticated USING (user_id = auth.uid());

CREATE POLICY training_phases_insert ON training_phases
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());

CREATE POLICY training_phases_update ON training_phases
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

CREATE POLICY training_phases_delete ON training_phases
  FOR DELETE TO authenticated USING (user_id = auth.uid());

CREATE TRIGGER training_phases_updated_at
  BEFORE UPDATE ON training_phases
  FOR EACH ROW
  EXECUTE FUNCTION set_updated_at();

-- =============================================================================
-- 3. LINK: plans.phase_id (optional FK)
-- =============================================================================

ALTER TABLE plans
  ADD COLUMN IF NOT EXISTS phase_id uuid REFERENCES training_phases(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS plans_phase_idx
  ON plans (phase_id) WHERE phase_id IS NOT NULL;

COMMENT ON COLUMN plans.phase_id IS
  'Optional link to the training phase this plan belongs to. NULL = phase-agnostic plan.';

-- =============================================================================
-- 4. UTILITY: phase lookup by date
-- =============================================================================
-- Returns the active phase for a user on a given date (0 or 1 row).

CREATE OR REPLACE FUNCTION get_user_phase_on_date(p_user_id uuid, p_date date)
RETURNS training_phases
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, pg_catalog
AS $$
  SELECT *
  FROM training_phases
  WHERE user_id = p_user_id
    AND start_date <= p_date
    AND (end_date IS NULL OR end_date >= p_date)
  ORDER BY start_date DESC
  LIMIT 1;
$$;

COMMENT ON FUNCTION get_user_phase_on_date(uuid, date) IS
  'Returns active training_phase for a user on a given date, or NULL if none. '
  'Overlapping phases resolved by most recent start_date.';

-- =============================================================================
-- 5. SEED DATA: phase_type_defaults
-- =============================================================================

INSERT INTO phase_type_defaults (
  phase_type, display_name,
  typical_weeks_min, typical_weeks_max,
  target_rep_range_min, target_rep_range_max,
  target_rpe_min, target_rpe_max,
  target_intensity_pct_1rm_min, target_intensity_pct_1rm_max,
  weekly_volume_pct_of_mav_min, weekly_volume_pct_of_mav_max,
  description, citation
) VALUES
  ('hypertrophy', 'Hypertrophy', 4, 6, 8, 15, 7.0, 9.0, 65, 80, 90, 110,
   'High-volume moderate-intensity block targeting muscle growth. Primary MAV occupation.',
   'Schoenfeld 2017 meta; Israetel 2021'),
  ('strength', 'Strength', 3, 5, 3, 6, 7.0, 9.0, 80, 92, 70, 90,
   'Heavier loads, lower reps, moderate volume. Neural and intramuscular adaptations.',
   'NSCA 2016 Ch.21; Helms 2019'),
  ('power', 'Power', 2, 4, 1, 5, 6.0, 8.0, 50, 75, 60, 80,
   'Explosive intent, submaximal loads, full rest. Emphasizes rate of force development.',
   'NSCA 2016; Cormie 2011'),
  ('peaking', 'Peaking / Taper', 1, 3, 1, 3, 8.0, 10.0, 90, 100, 50, 75,
   'Highest intensity, minimal volume. Competition or 1RM test preparation.',
   'Bompa 2019'),
  ('deload', 'Deload', 1, 1, 5, 10, 5.0, 7.0, 60, 75, 40, 60,
   'Planned fatigue dissipation. Volume halved, intensity submaximal.',
   'Helms 2019; Israetel 2021'),
  ('maintenance', 'Maintenance', 4, 52, 6, 12, 6.0, 8.0, 70, 80, 33, 50,
   'Preserve gains during life stress / competing priorities. ~33% normal volume.',
   'Schoenfeld Grgic 2022'),
  ('technique_primer', 'Technique Primer', 1, 2, 6, 10, 5.0, 7.0, 50, 65, 60, 80,
   'Form-focused low-fatigue phase after break or with new movement. Bar speed priority.',
   'Verkhoshansky 2006'),
  ('active_recovery', 'Active Recovery', 1, 1, 10, 15, 4.0, 6.0, 40, 60, 30, 40,
   'Post-peaking or post-illness reintroduction. Movement quality over load.',
   'Bompa 2019')
ON CONFLICT (phase_type) DO NOTHING;

COMMIT;
