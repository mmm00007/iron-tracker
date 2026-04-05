-- Migration 058: Volume Landmarks (MV/MEV/MAV/MRV per muscle group)
-- Per-user volume prescriptions seeded from evidence-based defaults across
-- 15 muscle groups x 3 experience levels x 3 training goals = 135 seed rows.
--
-- Framework: Renaissance Periodization (Israetel 2017, 2021) volume landmarks
--   MV  = Maintenance Volume: minimum sets/week to preserve gains
--   MEV = Minimum Effective Volume: threshold below which no progress occurs
--   MAV = Maximum Adaptive Volume: productive training target
--   MRV = Maximum Recoverable Volume: ceiling above which recovery fails
--
-- Validated by: fitness-domain-expert, data-science-expert, database-specialist
--
-- Key design decisions:
--   - Maps to existing 15-muscle taxonomy (muscle_groups table, not subdivided delts)
--   - Single int MAV (midpoint of productive range) — can extend to min/max later
--   - Stored ordering constraint enforces MV <= MEV <= MAV <= MRV
--   - SECURITY DEFINER init function per 043 pattern (not a profiles trigger)
--   - Activation-weighted fractional sets: backend cron computes effective_sets
--     from sets + exercise_muscles.activation_percent when comparing to landmarks
--   - Source enum: default (seeded), user_override (manual), computed (learned)
--   - Strength values scaled from hypertrophy (NSCA: ~50% volume at higher intensity)
--   - General values sit between hypertrophy and strength, MRV conservative
--   - Beginner = 75% of intermediate; Advanced = ~115% MRV, unchanged MEV (Israetel coaching)
--
-- Citations:
--   - Israetel M. et al. (2021). Scientific Principles of Hypertrophy Training. RP.
--   - Schoenfeld B.J., Grgic J. (2022). Med Sci Sports Exerc (volume dose-response).
--   - Pelland J.C. et al. (2024). Sports Medicine (fractional volume counting).
--   - NSCA (2016). Essentials of Strength Training and Conditioning, 4th ed. Ch. 21.
--   - Helms E. et al. (2019). The Muscle and Strength Pyramid: Training.

BEGIN;

-- =============================================================================
-- 1. REFERENCE TABLE: volume_landmark_defaults
-- =============================================================================
-- Public-read seed data. One row per (muscle_group, training_goal, experience_level).
-- Service role writes only (seed data loaded via migration).

CREATE TABLE IF NOT EXISTS volume_landmark_defaults (
  id                 serial      PRIMARY KEY,
  muscle_group_id    integer     NOT NULL REFERENCES muscle_groups(id) ON DELETE CASCADE,
  training_goal      text        NOT NULL
    CHECK (training_goal IN ('strength', 'hypertrophy', 'general')),
  experience_level   text        NOT NULL
    CHECK (experience_level IN ('beginner', 'intermediate', 'advanced')),
  mv_sets_per_week   smallint    NOT NULL CHECK (mv_sets_per_week >= 0),
  mev_sets_per_week  smallint    NOT NULL CHECK (mev_sets_per_week >= 0),
  mav_sets_per_week  smallint    NOT NULL CHECK (mav_sets_per_week >= 0),
  mrv_sets_per_week  smallint    NOT NULL CHECK (mrv_sets_per_week >= 0),
  notes              text,
  CONSTRAINT volume_landmark_defaults_ordering_check
    CHECK (mv_sets_per_week <= mev_sets_per_week
           AND mev_sets_per_week <= mav_sets_per_week
           AND mav_sets_per_week <= mrv_sets_per_week),
  UNIQUE (muscle_group_id, training_goal, experience_level)
);

COMMENT ON TABLE volume_landmark_defaults IS
  'Evidence-based default weekly-set landmarks (MV/MEV/MAV/MRV) per muscle, goal, '
  'and experience level. Seeded from Israetel 2021 Renaissance Periodization framework '
  'and NSCA strength guidelines. Used to initialize volume_landmarks for new users.';

ALTER TABLE volume_landmark_defaults ENABLE ROW LEVEL SECURITY;

CREATE POLICY volume_landmark_defaults_select ON volume_landmark_defaults
  FOR SELECT TO authenticated USING (true);

-- =============================================================================
-- 2. USER TABLE: volume_landmarks
-- =============================================================================
-- Per-user landmarks. Initialized from defaults when profile.primary_goal is set.
-- Can be overridden by user or adaptively learned from training history.

CREATE TABLE IF NOT EXISTS volume_landmarks (
  id                   uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id              uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  muscle_group_id      integer     NOT NULL REFERENCES muscle_groups(id) ON DELETE CASCADE,
  training_goal        text        NOT NULL
    CHECK (training_goal IN ('strength', 'hypertrophy', 'general')),
  mv_sets_per_week     smallint    NOT NULL CHECK (mv_sets_per_week >= 0),
  mev_sets_per_week    smallint    NOT NULL CHECK (mev_sets_per_week >= 0),
  mav_sets_per_week    smallint    NOT NULL CHECK (mav_sets_per_week >= 0),
  mrv_sets_per_week    smallint    NOT NULL CHECK (mrv_sets_per_week >= 0),
  source               text        NOT NULL DEFAULT 'default'
    CHECK (source IN ('default', 'user_override', 'computed')),
  confidence           numeric(3,2) CHECK (confidence >= 0 AND confidence <= 1),
  computation_version  smallint    NOT NULL DEFAULT 1,
  last_validated_at    timestamptz,
  computed_at          timestamptz NOT NULL DEFAULT now(),
  updated_at           timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT volume_landmarks_ordering_check
    CHECK (mv_sets_per_week <= mev_sets_per_week
           AND mev_sets_per_week <= mav_sets_per_week
           AND mav_sets_per_week <= mrv_sets_per_week),
  UNIQUE (user_id, muscle_group_id, training_goal)
);

COMMENT ON TABLE volume_landmarks IS
  'User-specific weekly-set landmarks per muscle group and training goal. '
  'Seeded from volume_landmark_defaults; can be user-overridden or adaptively '
  'learned from training history (min 12 weeks + 8 sessions + CV >= 0.20).';

COMMENT ON COLUMN volume_landmarks.source IS
  'default: seeded from population. user_override: manual edit. computed: learned from history.';

COMMENT ON COLUMN volume_landmarks.confidence IS
  'For computed values: 0-1 confidence based on data points and CV. NULL for default/override.';

CREATE INDEX IF NOT EXISTS volume_landmarks_user_muscle_idx
  ON volume_landmarks (user_id, muscle_group_id);

CREATE INDEX IF NOT EXISTS volume_landmarks_user_goal_idx
  ON volume_landmarks (user_id, training_goal);

ALTER TABLE volume_landmarks ENABLE ROW LEVEL SECURITY;

CREATE POLICY volume_landmarks_select ON volume_landmarks
  FOR SELECT TO authenticated USING (user_id = auth.uid());

CREATE POLICY volume_landmarks_insert ON volume_landmarks
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());

CREATE POLICY volume_landmarks_update ON volume_landmarks
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

CREATE POLICY volume_landmarks_delete ON volume_landmarks
  FOR DELETE TO authenticated USING (user_id = auth.uid());

CREATE TRIGGER volume_landmarks_updated_at
  BEFORE UPDATE ON volume_landmarks
  FOR EACH ROW
  EXECUTE FUNCTION set_updated_at();

-- =============================================================================
-- 3. INITIALIZATION FUNCTION
-- =============================================================================
-- Idempotent: call on user onboarding or profile goal/experience change.
-- Returns number of rows inserted (0 if profile incomplete or already initialized).

CREATE OR REPLACE FUNCTION initialize_user_volume_landmarks(p_user_id uuid)
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_catalog
AS $$
DECLARE
  v_inserted integer;
  v_goal     text;
  v_exp      text;
BEGIN
  SELECT primary_goal, experience_level
    INTO v_goal, v_exp
  FROM profiles
  WHERE id = p_user_id;

  IF v_goal IS NULL OR v_exp IS NULL THEN
    RETURN 0;
  END IF;

  INSERT INTO volume_landmarks (
    user_id, muscle_group_id, training_goal,
    mv_sets_per_week, mev_sets_per_week, mav_sets_per_week, mrv_sets_per_week,
    source
  )
  SELECT
    p_user_id, muscle_group_id, training_goal,
    mv_sets_per_week, mev_sets_per_week, mav_sets_per_week, mrv_sets_per_week,
    'default'
  FROM volume_landmark_defaults
  WHERE training_goal = v_goal AND experience_level = v_exp
  ON CONFLICT (user_id, muscle_group_id, training_goal) DO NOTHING;

  GET DIAGNOSTICS v_inserted = ROW_COUNT;
  RETURN v_inserted;
END;
$$;

COMMENT ON FUNCTION initialize_user_volume_landmarks(uuid) IS
  'Seeds volume_landmarks for a user from defaults matching their profile '
  'primary_goal and experience_level. Idempotent via ON CONFLICT DO NOTHING.';

-- =============================================================================
-- 4. SEED DATA: Intermediate hypertrophy (baseline from Israetel 2021)
-- =============================================================================
-- Values are weekly direct sets per muscle, RPE 7-9, working sets only.
-- Activation-weighted fractional volume (backend cron) compares user weekly
-- sets against these landmarks.

INSERT INTO volume_landmark_defaults
  (muscle_group_id, training_goal, experience_level,
   mv_sets_per_week, mev_sets_per_week, mav_sets_per_week, mrv_sets_per_week, notes)
VALUES
  -- HYPERTROPHY, INTERMEDIATE (RP framework baseline)
  (1,  'hypertrophy', 'intermediate', 5,  8,  17, 26, 'biceps: direct work + rowing carryover'),
  (2,  'hypertrophy', 'intermediate', 2,  6,  14, 21, 'shoulders: combined 3 heads; anterior often at MEV from pressing'),
  (3,  'hypertrophy', 'intermediate', 4,  6,  12, 18, 'triceps: indirect pressing contributes ~0.5 sets per bench'),
  (4,  'hypertrophy', 'intermediate', 8,  10, 17, 22, 'chest: Schoenfeld 2022 sweet spot 10-20 sets'),
  (5,  'hypertrophy', 'intermediate', 2,  4,  9,  15, 'forearms: grip work + direct flexion'),
  (7,  'hypertrophy', 'intermediate', 6,  8,  14, 20, 'calves: resistant to hypertrophy, higher frequency needed'),
  (8,  'hypertrophy', 'intermediate', 0,  4,  10, 16, 'glutes: squat/hinge carryover substantial'),
  (9,  'hypertrophy', 'intermediate', 0,  8,  16, 26, 'traps: shrugs, rows, carries, deadlift lockouts'),
  (10, 'hypertrophy', 'intermediate', 0,  0,  18, 25, 'abs: stabilization in compounds gives some MV for free'),
  (11, 'hypertrophy', 'intermediate', 4,  6,  13, 20, 'hamstrings: knee-flexion + hip-extension combined'),
  (12, 'hypertrophy', 'intermediate', 8,  10, 18, 25, 'lats: primary upper pulling emphasis'),
  (13, 'hypertrophy', 'intermediate', 0,  6,  11, 16, 'lower back: erectors hit heavily by compounds'),
  (14, 'hypertrophy', 'intermediate', 0,  0,  6,  12, 'neck: optional, sport-specific for collision athletes'),
  (15, 'hypertrophy', 'intermediate', 6,  8,  15, 20, 'quadriceps: squats + leg press + isolation'),
  (16, 'hypertrophy', 'intermediate', 0,  2,  8,  14, 'adductors: compound squatting covers MV'),

  -- HYPERTROPHY, BEGINNER (75% of intermediate for MRV; MEV slightly lower)
  (1,  'hypertrophy', 'beginner',     4,  6,  13, 20, NULL),
  (2,  'hypertrophy', 'beginner',     2,  5,  11, 16, NULL),
  (3,  'hypertrophy', 'beginner',     3,  5,  9,  14, NULL),
  (4,  'hypertrophy', 'beginner',     6,  8,  13, 17, NULL),
  (5,  'hypertrophy', 'beginner',     2,  3,  7,  11, NULL),
  (7,  'hypertrophy', 'beginner',     5,  6,  11, 15, NULL),
  (8,  'hypertrophy', 'beginner',     0,  3,  8,  12, NULL),
  (9,  'hypertrophy', 'beginner',     0,  6,  12, 20, NULL),
  (10, 'hypertrophy', 'beginner',     0,  0,  14, 19, NULL),
  (11, 'hypertrophy', 'beginner',     3,  5,  10, 15, NULL),
  (12, 'hypertrophy', 'beginner',     6,  8,  14, 19, NULL),
  (13, 'hypertrophy', 'beginner',     0,  5,  8,  12, NULL),
  (14, 'hypertrophy', 'beginner',     0,  0,  5,  9,  NULL),
  (15, 'hypertrophy', 'beginner',     5,  6,  11, 15, NULL),
  (16, 'hypertrophy', 'beginner',     0,  2,  6,  11, NULL),

  -- HYPERTROPHY, ADVANCED (~115% MRV; MEV stable; higher fatigue resistance)
  (1,  'hypertrophy', 'advanced',     6,  8,  20, 30, NULL),
  (2,  'hypertrophy', 'advanced',     3,  6,  16, 24, NULL),
  (3,  'hypertrophy', 'advanced',     5,  6,  14, 21, NULL),
  (4,  'hypertrophy', 'advanced',     9,  10, 20, 26, NULL),
  (5,  'hypertrophy', 'advanced',     3,  4,  11, 17, NULL),
  (7,  'hypertrophy', 'advanced',     7,  8,  16, 23, NULL),
  (8,  'hypertrophy', 'advanced',     0,  4,  12, 19, NULL),
  (9,  'hypertrophy', 'advanced',     0,  8,  19, 30, NULL),
  (10, 'hypertrophy', 'advanced',     0,  0,  21, 29, NULL),
  (11, 'hypertrophy', 'advanced',     5,  6,  15, 23, NULL),
  (12, 'hypertrophy', 'advanced',     9,  10, 21, 29, NULL),
  (13, 'hypertrophy', 'advanced',     0,  6,  13, 19, NULL),
  (14, 'hypertrophy', 'advanced',     0,  0,  7,  14, NULL),
  (15, 'hypertrophy', 'advanced',     7,  8,  17, 23, NULL),
  (16, 'hypertrophy', 'advanced',     0,  2,  10, 17, NULL),

  -- STRENGTH, INTERMEDIATE (NSCA: ~50% volume, >=85% 1RM, lower rep ranges)
  (1,  'strength',    'intermediate', 2,  4,  8,  12, 'biceps: grip/assistance role for pulls'),
  (2,  'strength',    'intermediate', 1,  3,  7,  10, 'shoulders: pressing carryover'),
  (3,  'strength',    'intermediate', 2,  3,  6,  9,  'triceps: lockout strength via close grip/dips'),
  (4,  'strength',    'intermediate', 4,  5,  8,  12, 'chest: bench press focus'),
  (5,  'strength',    'intermediate', 1,  2,  5,  8,  'forearms: grip strength direct'),
  (7,  'strength',    'intermediate', 3,  4,  7,  10, 'calves: ankle stability for squats'),
  (8,  'strength',    'intermediate', 0,  2,  5,  8,  'glutes: squat/deadlift hip extension'),
  (9,  'strength',    'intermediate', 0,  4,  8,  12, 'traps: rack pulls, heavy shrugs, carries'),
  (10, 'strength',    'intermediate', 0,  0,  6,  10, 'abs: anti-extension/anti-rotation bracing'),
  (11, 'strength',    'intermediate', 2,  3,  6,  10, 'hamstrings: RDL, good mornings'),
  (12, 'strength',    'intermediate', 4,  5,  9,  12, 'lats: pull-ups, rows, pulldowns'),
  (13, 'strength',    'intermediate', 0,  3,  5,  8,  'lower back: deadlift + compounds dominant'),
  (14, 'strength',    'intermediate', 0,  0,  3,  6,  'neck: sport-specific'),
  (15, 'strength',    'intermediate', 3,  4,  8,  10, 'quadriceps: squat + variations'),
  (16, 'strength',    'intermediate', 0,  1,  4,  7,  'adductors: stance width contributions'),

  -- STRENGTH, BEGINNER (75% of intermediate)
  (1,  'strength',    'beginner',     2,  3,  6,  9,  NULL),
  (2,  'strength',    'beginner',     1,  2,  5,  8,  NULL),
  (3,  'strength',    'beginner',     1,  2,  5,  7,  NULL),
  (4,  'strength',    'beginner',     3,  4,  6,  9,  NULL),
  (5,  'strength',    'beginner',     1,  2,  4,  6,  NULL),
  (7,  'strength',    'beginner',     2,  3,  5,  8,  NULL),
  (8,  'strength',    'beginner',     0,  2,  4,  6,  NULL),
  (9,  'strength',    'beginner',     0,  3,  6,  9,  NULL),
  (10, 'strength',    'beginner',     0,  0,  5,  8,  NULL),
  (11, 'strength',    'beginner',     2,  2,  5,  8,  NULL),
  (12, 'strength',    'beginner',     3,  4,  7,  9,  NULL),
  (13, 'strength',    'beginner',     0,  2,  4,  6,  NULL),
  (14, 'strength',    'beginner',     0,  0,  2,  5,  NULL),
  (15, 'strength',    'beginner',     2,  3,  6,  8,  NULL),
  (16, 'strength',    'beginner',     0,  1,  3,  5,  NULL),

  -- STRENGTH, ADVANCED (~115% MRV)
  (1,  'strength',    'advanced',     3,  4,  10, 14, NULL),
  (2,  'strength',    'advanced',     2,  3,  8,  12, NULL),
  (3,  'strength',    'advanced',     3,  4,  7,  10, NULL),
  (4,  'strength',    'advanced',     5,  6,  10, 14, NULL),
  (5,  'strength',    'advanced',     2,  2,  6,  9,  NULL),
  (7,  'strength',    'advanced',     4,  5,  9,  12, NULL),
  (8,  'strength',    'advanced',     0,  3,  6,  10, NULL),
  (9,  'strength',    'advanced',     0,  5,  10, 14, NULL),
  (10, 'strength',    'advanced',     0,  0,  7,  12, NULL),
  (11, 'strength',    'advanced',     3,  4,  7,  12, NULL),
  (12, 'strength',    'advanced',     5,  6,  10, 14, NULL),
  (13, 'strength',    'advanced',     0,  4,  6,  10, NULL),
  (14, 'strength',    'advanced',     0,  0,  4,  7,  NULL),
  (15, 'strength',    'advanced',     4,  5,  10, 12, NULL),
  (16, 'strength',    'advanced',     0,  2,  5,  9,  NULL),

  -- GENERAL, INTERMEDIATE (hypertrophy-leaning, lower MRV for non-dedicated)
  (1,  'general',     'intermediate', 4,  6,  12, 18, 'general: sustainable volume, avoid burnout'),
  (2,  'general',     'intermediate', 2,  5,  11, 16, NULL),
  (3,  'general',     'intermediate', 3,  5,  10, 14, NULL),
  (4,  'general',     'intermediate', 6,  8,  12, 16, NULL),
  (5,  'general',     'intermediate', 2,  3,  7,  12, NULL),
  (7,  'general',     'intermediate', 4,  6,  10, 14, NULL),
  (8,  'general',     'intermediate', 0,  3,  8,  12, NULL),
  (9,  'general',     'intermediate', 0,  6,  12, 18, NULL),
  (10, 'general',     'intermediate', 0,  0,  12, 18, NULL),
  (11, 'general',     'intermediate', 3,  5,  10, 14, NULL),
  (12, 'general',     'intermediate', 6,  8,  14, 18, NULL),
  (13, 'general',     'intermediate', 0,  5,  9,  12, NULL),
  (14, 'general',     'intermediate', 0,  0,  4,  9,  NULL),
  (15, 'general',     'intermediate', 5,  6,  12, 16, NULL),
  (16, 'general',     'intermediate', 0,  2,  6,  10, NULL),

  -- GENERAL, BEGINNER (75% of intermediate general)
  (1,  'general',     'beginner',     3,  5,  9,  14, NULL),
  (2,  'general',     'beginner',     2,  4,  8,  12, NULL),
  (3,  'general',     'beginner',     2,  4,  8,  11, NULL),
  (4,  'general',     'beginner',     5,  6,  9,  12, NULL),
  (5,  'general',     'beginner',     2,  2,  5,  9,  NULL),
  (7,  'general',     'beginner',     3,  5,  8,  11, NULL),
  (8,  'general',     'beginner',     0,  2,  6,  9,  NULL),
  (9,  'general',     'beginner',     0,  5,  9,  14, NULL),
  (10, 'general',     'beginner',     0,  0,  9,  14, NULL),
  (11, 'general',     'beginner',     2,  4,  8,  11, NULL),
  (12, 'general',     'beginner',     5,  6,  11, 14, NULL),
  (13, 'general',     'beginner',     0,  4,  7,  9,  NULL),
  (14, 'general',     'beginner',     0,  0,  3,  7,  NULL),
  (15, 'general',     'beginner',     4,  5,  9,  12, NULL),
  (16, 'general',     'beginner',     0,  2,  5,  8,  NULL),

  -- GENERAL, ADVANCED (~110% MRV, conservative vs hypertrophy advanced)
  (1,  'general',     'advanced',     5,  7,  15, 22, NULL),
  (2,  'general',     'advanced',     3,  6,  13, 20, NULL),
  (3,  'general',     'advanced',     4,  6,  12, 17, NULL),
  (4,  'general',     'advanced',     7,  9,  15, 20, NULL),
  (5,  'general',     'advanced',     3,  4,  9,  14, NULL),
  (7,  'general',     'advanced',     5,  7,  13, 18, NULL),
  (8,  'general',     'advanced',     0,  4,  10, 15, NULL),
  (9,  'general',     'advanced',     0,  7,  14, 22, NULL),
  (10, 'general',     'advanced',     0,  0,  15, 22, NULL),
  (11, 'general',     'advanced',     4,  6,  12, 18, NULL),
  (12, 'general',     'advanced',     7,  9,  17, 22, NULL),
  (13, 'general',     'advanced',     0,  6,  11, 15, NULL),
  (14, 'general',     'advanced',     0,  0,  5,  11, NULL),
  (15, 'general',     'advanced',     6,  7,  14, 20, NULL),
  (16, 'general',     'advanced',     0,  2,  7,  12, NULL)
ON CONFLICT (muscle_group_id, training_goal, experience_level) DO NOTHING;

COMMIT;
