-- Iron Tracker: Initial Schema Migration
-- Creates all tables, indexes, RLS policies, triggers, and materialized views.

-- =============================================================================
-- 1. HELPER FUNCTIONS
-- =============================================================================

-- updated_at trigger function
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Epley estimated 1RM trigger function
CREATE OR REPLACE FUNCTION compute_estimated_1rm()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.reps > 0 AND NEW.weight > 0 THEN
    NEW.estimated_1rm = ROUND((NEW.weight * (1 + NEW.reps / 30.0))::numeric, 2);
  ELSE
    NEW.estimated_1rm = NEW.weight;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =============================================================================
-- 2. TABLES
-- =============================================================================

-- muscle_groups: Reference table for structured muscle data from wger API.
COMMENT ON FUNCTION set_updated_at IS 'Auto-update updated_at column on row modification.';

CREATE TABLE IF NOT EXISTS muscle_groups (
  id          integer       PRIMARY KEY,
  name        text          NOT NULL UNIQUE,
  name_latin  text,
  is_front    boolean       NOT NULL DEFAULT true,
  svg_path_id text
);
COMMENT ON TABLE muscle_groups IS 'Reference table for structured muscle data sourced from wger API.';

-- exercises: Canonical exercise library seeded from yuhonas/free-exercise-db (800+).
CREATE TABLE IF NOT EXISTS exercises (
  id           uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
  name         text         NOT NULL,
  force        text,
  level        text,
  mechanic     text,
  equipment    text,
  category     text,
  instructions text[],
  form_tips    text[],
  image_urls   text[],
  is_custom    boolean      NOT NULL DEFAULT false,
  created_by   uuid         REFERENCES auth.users(id),
  created_at   timestamptz  NOT NULL DEFAULT now()
);
COMMENT ON TABLE exercises IS 'Canonical exercise library. Seed data from free-exercise-db; users can add custom exercises.';

-- Partial unique indexes: seed exercises have unique name; custom exercises have unique (name, created_by).
CREATE UNIQUE INDEX exercises_seed_name_idx
  ON exercises (name)
  WHERE created_by IS NULL;

CREATE UNIQUE INDEX exercises_custom_name_idx
  ON exercises (name, created_by)
  WHERE created_by IS NOT NULL;

-- exercise_muscles: Junction table linking exercises to muscle groups.
CREATE TABLE IF NOT EXISTS exercise_muscles (
  exercise_id     uuid     NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
  muscle_group_id integer  NOT NULL REFERENCES muscle_groups(id) ON DELETE CASCADE,
  is_primary      boolean  NOT NULL DEFAULT true,
  PRIMARY KEY (exercise_id, muscle_group_id)
);
COMMENT ON TABLE exercise_muscles IS 'Junction table mapping exercises to their targeted muscle groups.';

-- gyms: Curated gym locations.
CREATE TABLE IF NOT EXISTS gyms (
  id            uuid             PRIMARY KEY DEFAULT gen_random_uuid(),
  name          text             NOT NULL,
  address       text,
  city          text             NOT NULL,
  latitude      double precision,
  longitude     double precision,
  photo_url     text,
  machine_count integer          NOT NULL DEFAULT 0,
  is_active     boolean          NOT NULL DEFAULT true,
  created_at    timestamptz      NOT NULL DEFAULT now(),
  updated_at    timestamptz      NOT NULL DEFAULT now()
);
COMMENT ON TABLE gyms IS 'Curated gym locations with metadata.';

-- gym_machines: Curated machines at specific gyms.
CREATE TABLE IF NOT EXISTS gym_machines (
  id                uuid      PRIMARY KEY DEFAULT gen_random_uuid(),
  gym_id            uuid      NOT NULL REFERENCES gyms(id) ON DELETE CASCADE,
  exercise_id       uuid      NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
  name              text      NOT NULL,
  equipment_type    text      NOT NULL,
  manufacturer      text,
  weight_range_min  numeric,
  weight_range_max  numeric,
  weight_increment  numeric   DEFAULT 2.5,
  seat_adjustments  integer   DEFAULT 0,
  photo_url         text,
  notes             text,
  sort_order        integer   NOT NULL DEFAULT 0,
  is_active         boolean   NOT NULL DEFAULT true,
  created_at        timestamptz NOT NULL DEFAULT now()
);
COMMENT ON TABLE gym_machines IS 'Curated machines available at specific gyms.';

CREATE INDEX gym_machines_gym_exercise_idx ON gym_machines (gym_id, exercise_id);
CREATE INDEX gym_machines_gym_sort_idx     ON gym_machines (gym_id, sort_order);
CREATE INDEX gym_machines_gym_active_idx   ON gym_machines (gym_id, is_active);

-- user_gym_memberships: Links users to their gyms.
CREATE TABLE IF NOT EXISTS user_gym_memberships (
  id         uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  gym_id     uuid        NOT NULL REFERENCES gyms(id) ON DELETE CASCADE,
  is_primary boolean     NOT NULL DEFAULT false,
  joined_at  timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, gym_id)
);
COMMENT ON TABLE user_gym_memberships IS 'Tracks which gyms a user belongs to.';

-- equipment_variants: User personal machine/equipment library.
CREATE TABLE IF NOT EXISTS equipment_variants (
  id              uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  exercise_id     uuid        NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
  gym_machine_id  uuid        REFERENCES gym_machines(id) ON DELETE SET NULL,
  name            text        NOT NULL,
  equipment_type  text        NOT NULL,
  manufacturer    text,
  weight_increment numeric    DEFAULT 2.5,
  weight_unit     text        NOT NULL DEFAULT 'kg' CHECK (weight_unit IN ('kg', 'lb')),
  seat_settings   jsonb       DEFAULT '{}',
  notes           text,
  photo_url       text,
  last_used_at    timestamptz,
  created_at      timestamptz NOT NULL DEFAULT now()
);
COMMENT ON TABLE equipment_variants IS 'User personal equipment library with machine-specific settings.';

CREATE INDEX equipment_variants_user_exercise_idx
  ON equipment_variants (user_id, exercise_id, last_used_at DESC);

-- sets: The atomic unit of training data.
CREATE TABLE IF NOT EXISTS sets (
  id            uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  exercise_id   uuid        NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
  variant_id    uuid        REFERENCES equipment_variants(id) ON DELETE SET NULL,
  weight        numeric     NOT NULL DEFAULT 0,
  weight_unit   text        NOT NULL DEFAULT 'kg' CHECK (weight_unit IN ('kg', 'lb')),
  reps          integer     NOT NULL DEFAULT 0,
  rpe           numeric     CHECK (rpe >= 1 AND rpe <= 10),
  rir           integer     CHECK (rir >= 0 AND rir <= 10),
  set_type      text        NOT NULL DEFAULT 'working'
                            CHECK (set_type IN ('warmup', 'working', 'backoff', 'dropset', 'amrap', 'failure')),
  tempo         text,
  notes         text,
  estimated_1rm numeric,
  logged_at     timestamptz NOT NULL DEFAULT now(),
  synced_at     timestamptz
);
COMMENT ON TABLE sets IS 'Atomic training data: each row is one set performed by a user.';

CREATE INDEX sets_user_exercise_logged_idx ON sets (user_id, exercise_id, logged_at DESC);
CREATE INDEX sets_user_logged_idx          ON sets (user_id, logged_at DESC);
CREATE INDEX sets_user_variant_logged_idx  ON sets (user_id, variant_id, logged_at DESC);

-- personal_records: Tracks PRs across multiple record types.
CREATE TABLE IF NOT EXISTS personal_records (
  id           uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  exercise_id  uuid        NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
  variant_id   uuid        REFERENCES equipment_variants(id) ON DELETE SET NULL,
  record_type  text        NOT NULL
                           CHECK (record_type IN ('estimated_1rm', 'rep_max', 'max_weight', 'max_volume')),
  rep_count    integer,
  value        numeric     NOT NULL,
  set_id       uuid        REFERENCES sets(id) ON DELETE SET NULL,
  achieved_at  timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, exercise_id, variant_id, record_type, rep_count)
);
COMMENT ON TABLE personal_records IS 'Personal records across exercises, variants, and record types.';

-- soreness_reports: User-reported muscle soreness.
CREATE TABLE IF NOT EXISTS soreness_reports (
  id              uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  muscle_group_id integer     NOT NULL REFERENCES muscle_groups(id),
  severity        integer     NOT NULL CHECK (severity >= 0 AND severity <= 4),
  reported_at     timestamptz NOT NULL DEFAULT now()
);
COMMENT ON TABLE soreness_reports IS 'User-reported muscle soreness levels (0-4 scale).';

-- analytics_cache: Pre-computed analytics for dashboard performance.
CREATE TABLE IF NOT EXISTS analytics_cache (
  id           uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  cache_type   text        NOT NULL,
  exercise_id  uuid        REFERENCES exercises(id) ON DELETE CASCADE,
  period_start date,
  period_end   date,
  data         jsonb       NOT NULL,
  computed_at  timestamptz NOT NULL DEFAULT now()
);
COMMENT ON TABLE analytics_cache IS 'Pre-computed analytics cache for dashboard queries.';

CREATE INDEX analytics_cache_lookup_idx
  ON analytics_cache (user_id, cache_type, exercise_id, period_start);

-- profiles: User profile and preferences.
CREATE TABLE IF NOT EXISTS profiles (
  id                     uuid        PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name           text,
  experience_level       text        CHECK (experience_level IN ('beginner', 'intermediate', 'advanced')),
  primary_goal           text        CHECK (primary_goal IN ('strength', 'hypertrophy', 'general')),
  preferred_weight_unit  text        NOT NULL DEFAULT 'kg'
                                     CHECK (preferred_weight_unit IN ('kg', 'lb')),
  training_days_per_week integer     DEFAULT 4
                                     CHECK (training_days_per_week >= 1 AND training_days_per_week <= 7),
  theme_seed_color       text        DEFAULT '#2E75B6',
  onboarding_completed   boolean     NOT NULL DEFAULT false,
  created_at             timestamptz NOT NULL DEFAULT now(),
  updated_at             timestamptz NOT NULL DEFAULT now()
);
COMMENT ON TABLE profiles IS 'User profile, preferences, and onboarding state.';

-- =============================================================================
-- 3. MATERIALIZED VIEW
-- =============================================================================

CREATE MATERIALIZED VIEW sessions_view AS
WITH ordered_sets AS (
  SELECT
    id,
    user_id,
    exercise_id,
    variant_id,
    weight,
    reps,
    logged_at,
    logged_at - LAG(logged_at) OVER (PARTITION BY user_id ORDER BY logged_at) AS gap
  FROM sets
),
session_groups AS (
  SELECT *,
    SUM(CASE WHEN gap IS NULL OR gap > interval '90 minutes' THEN 1 ELSE 0 END)
      OVER (PARTITION BY user_id ORDER BY logged_at) AS session_number
  FROM ordered_sets
)
SELECT
  user_id,
  session_number,
  MIN(logged_at) AS started_at,
  MAX(logged_at) AS ended_at,
  COUNT(*)       AS total_sets,
  COUNT(DISTINCT exercise_id) AS exercise_count,
  SUM(weight * reps)          AS total_volume
FROM session_groups
GROUP BY user_id, session_number;

CREATE UNIQUE INDEX sessions_view_user_session_idx
  ON sessions_view (user_id, session_number);

-- =============================================================================
-- 4. TRIGGERS
-- =============================================================================

-- Auto-update updated_at on profiles
CREATE TRIGGER profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION set_updated_at();

-- Auto-update updated_at on gyms
CREATE TRIGGER gyms_updated_at
  BEFORE UPDATE ON gyms
  FOR EACH ROW
  EXECUTE FUNCTION set_updated_at();

-- Auto-compute estimated_1rm on sets INSERT
CREATE TRIGGER sets_compute_estimated_1rm
  BEFORE INSERT ON sets
  FOR EACH ROW
  EXECUTE FUNCTION compute_estimated_1rm();

-- =============================================================================
-- 5. ROW LEVEL SECURITY
-- =============================================================================

-- muscle_groups: public reference data, no RLS needed
GRANT SELECT ON muscle_groups TO authenticated;

-- exercises: SELECT for all authenticated; write only own custom exercises
ALTER TABLE exercises ENABLE ROW LEVEL SECURITY;

CREATE POLICY exercises_select ON exercises
  FOR SELECT TO authenticated
  USING (true);

CREATE POLICY exercises_insert ON exercises
  FOR INSERT TO authenticated
  WITH CHECK (created_by = auth.uid());

CREATE POLICY exercises_update ON exercises
  FOR UPDATE TO authenticated
  USING (created_by = auth.uid())
  WITH CHECK (created_by = auth.uid());

CREATE POLICY exercises_delete ON exercises
  FOR DELETE TO authenticated
  USING (created_by = auth.uid());

-- exercise_muscles: SELECT for all authenticated, no user writes
ALTER TABLE exercise_muscles ENABLE ROW LEVEL SECURITY;

CREATE POLICY exercise_muscles_select ON exercise_muscles
  FOR SELECT TO authenticated
  USING (true);

-- gyms: SELECT for all authenticated, writes via service role only
ALTER TABLE gyms ENABLE ROW LEVEL SECURITY;

CREATE POLICY gyms_select ON gyms
  FOR SELECT TO authenticated
  USING (true);

-- gym_machines: SELECT for all authenticated, no user write policies
ALTER TABLE gym_machines ENABLE ROW LEVEL SECURITY;

CREATE POLICY gym_machines_select ON gym_machines
  FOR SELECT TO authenticated
  USING (true);

-- user_gym_memberships: all operations scoped to own user_id
ALTER TABLE user_gym_memberships ENABLE ROW LEVEL SECURITY;

CREATE POLICY user_gym_memberships_select ON user_gym_memberships
  FOR SELECT TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY user_gym_memberships_insert ON user_gym_memberships
  FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY user_gym_memberships_update ON user_gym_memberships
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY user_gym_memberships_delete ON user_gym_memberships
  FOR DELETE TO authenticated
  USING (user_id = auth.uid());

-- equipment_variants: all operations scoped to own user_id
ALTER TABLE equipment_variants ENABLE ROW LEVEL SECURITY;

CREATE POLICY equipment_variants_select ON equipment_variants
  FOR SELECT TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY equipment_variants_insert ON equipment_variants
  FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY equipment_variants_update ON equipment_variants
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY equipment_variants_delete ON equipment_variants
  FOR DELETE TO authenticated
  USING (user_id = auth.uid());

-- sets: all operations scoped to own user_id
ALTER TABLE sets ENABLE ROW LEVEL SECURITY;

CREATE POLICY sets_select ON sets
  FOR SELECT TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY sets_insert ON sets
  FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY sets_update ON sets
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY sets_delete ON sets
  FOR DELETE TO authenticated
  USING (user_id = auth.uid());

-- personal_records: all operations scoped to own user_id
ALTER TABLE personal_records ENABLE ROW LEVEL SECURITY;

CREATE POLICY personal_records_select ON personal_records
  FOR SELECT TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY personal_records_insert ON personal_records
  FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY personal_records_update ON personal_records
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY personal_records_delete ON personal_records
  FOR DELETE TO authenticated
  USING (user_id = auth.uid());

-- soreness_reports: all operations scoped to own user_id
ALTER TABLE soreness_reports ENABLE ROW LEVEL SECURITY;

CREATE POLICY soreness_reports_select ON soreness_reports
  FOR SELECT TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY soreness_reports_insert ON soreness_reports
  FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY soreness_reports_update ON soreness_reports
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY soreness_reports_delete ON soreness_reports
  FOR DELETE TO authenticated
  USING (user_id = auth.uid());

-- analytics_cache: all operations scoped to own user_id
ALTER TABLE analytics_cache ENABLE ROW LEVEL SECURITY;

CREATE POLICY analytics_cache_select ON analytics_cache
  FOR SELECT TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY analytics_cache_insert ON analytics_cache
  FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY analytics_cache_update ON analytics_cache
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY analytics_cache_delete ON analytics_cache
  FOR DELETE TO authenticated
  USING (user_id = auth.uid());

-- profiles: all operations scoped to own id
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY profiles_select ON profiles
  FOR SELECT TO authenticated
  USING (id = auth.uid());

CREATE POLICY profiles_insert ON profiles
  FOR INSERT TO authenticated
  WITH CHECK (id = auth.uid());

CREATE POLICY profiles_update ON profiles
  FOR UPDATE TO authenticated
  USING (id = auth.uid())
  WITH CHECK (id = auth.uid());

CREATE POLICY profiles_delete ON profiles
  FOR DELETE TO authenticated
  USING (id = auth.uid());
