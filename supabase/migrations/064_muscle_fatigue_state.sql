-- Migration 064: Muscle Fatigue State (derived, per user x muscle x date)
-- Pre-computed per-muscle fatigue snapshots blending training volume, peak
-- intensity, soreness, and recency into a composite 0-100 score. Used for:
--   - "Train upper body today; your legs are at 85% fatigue"
--   - Muscle-specific recovery tracking heatmap
--   - Auto-regulated set/volume suggestions
--
-- Framework: Multi-factor composite using the activation_percent column
-- from exercise_muscles (fractional-volume counting per Pelland 2024).
--
-- Validated by: data-science-expert, sports-medicine-expert, fitness-domain-expert
--
-- Key design decisions:
--   - Derived table, populated by backend cron (daily, 02:30 UTC)
--   - One row per (user, muscle_group, as_of_date)
--   - fatigue_score composite: 40% volume, 20% peak_rpe, 20% soreness, 20% recency
--   - Activation-weighted effective sets (not raw count) for volume component
--   - Uses 72h window for acute volume + soreness aggregation
--   - NOT a materialized view — different users refresh at different cadences
--   - computation_version enables formula revision without silent mutation
--
-- Citations:
--   - Pelland J.C. et al. (2024). Volume-load quantification. Sports Medicine.
--   - Zaffagnini S. et al. (2015). DOMS timeline (24-72h peak). J Sports Med.
--   - Damas F. et al. (2018). Protein synthesis vs soreness dissociation.
--   - Israetel M. et al. (2021). Volume landmarks recovery curves.
--   - Impellizzeri F.M. et al. (2020). Fatigue monitoring frameworks.

BEGIN;

CREATE TABLE IF NOT EXISTS muscle_fatigue_state (
  id                            uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id                       uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  muscle_group_id               integer     NOT NULL REFERENCES muscle_groups(id) ON DELETE CASCADE,
  as_of_date                    date        NOT NULL,
  -- Composite score, 0=fully recovered, 100=maximal fatigue
  fatigue_score                 numeric(4,1) NOT NULL
    CHECK (fatigue_score >= 0 AND fatigue_score <= 100),
  -- Component scores (each 0-100) for transparency/debugging
  volume_component              numeric(4,1) CHECK (volume_component >= 0 AND volume_component <= 100),
  rpe_component                 numeric(4,1) CHECK (rpe_component >= 0 AND rpe_component <= 100),
  soreness_component            numeric(4,1) CHECK (soreness_component >= 0 AND soreness_component <= 100),
  recency_component             numeric(4,1) CHECK (recency_component >= 0 AND recency_component <= 100),
  -- Raw input features
  effective_sets_last_72h       numeric(5,1) NOT NULL DEFAULT 0
    CHECK (effective_sets_last_72h >= 0),
  peak_rpe_last_72h             numeric(3,1)
    CHECK (peak_rpe_last_72h IS NULL OR (peak_rpe_last_72h >= 0 AND peak_rpe_last_72h <= 10)),
  avg_soreness_last_72h         numeric(3,1)
    CHECK (avg_soreness_last_72h IS NULL OR (avg_soreness_last_72h >= 0 AND avg_soreness_last_72h <= 4)),
  days_since_last_trained       smallint
    CHECK (days_since_last_trained IS NULL OR days_since_last_trained >= 0),
  recovery_status               text        NOT NULL
    CHECK (recovery_status IN ('fresh','ready','recovering','fatigued','overreaching','no_data')),
  computation_version           smallint    NOT NULL DEFAULT 1,
  computed_at                   timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, muscle_group_id, as_of_date)
);

COMMENT ON TABLE muscle_fatigue_state IS
  'Daily per-muscle fatigue snapshots. Composite 0-100 score from volume, RPE, '
  'soreness, and recency. Populated by backend cron. Drives training '
  'recommendations and muscle heatmap visualization.';

COMMENT ON COLUMN muscle_fatigue_state.fatigue_score IS
  'Weighted composite: 40%% volume + 20%% peak_rpe + 20%% soreness + 20%% recency. '
  'Formula in compute_muscle_fatigue() backend function, version-tracked.';

COMMENT ON COLUMN muscle_fatigue_state.effective_sets_last_72h IS
  'Activation-weighted fractional sets (Pelland 2024): SUM(activation_percent/100) '
  'over all working sets targeting this muscle within last 72h.';

COMMENT ON COLUMN muscle_fatigue_state.recovery_status IS
  'fresh: 0-20; ready: 20-40; recovering: 40-60; fatigued: 60-80; overreaching: 80-100.';

CREATE INDEX IF NOT EXISTS muscle_fatigue_state_user_date_idx
  ON muscle_fatigue_state (user_id, as_of_date DESC);

CREATE INDEX IF NOT EXISTS muscle_fatigue_state_user_muscle_idx
  ON muscle_fatigue_state (user_id, muscle_group_id, as_of_date DESC);

-- Partial index for the "current snapshot per user" query pattern
CREATE INDEX IF NOT EXISTS muscle_fatigue_state_user_recent_idx
  ON muscle_fatigue_state (user_id, as_of_date DESC, fatigue_score DESC);

ALTER TABLE muscle_fatigue_state ENABLE ROW LEVEL SECURITY;

CREATE POLICY muscle_fatigue_state_select ON muscle_fatigue_state
  FOR SELECT TO authenticated USING (user_id = auth.uid());

CREATE POLICY muscle_fatigue_state_insert ON muscle_fatigue_state
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());

CREATE POLICY muscle_fatigue_state_update ON muscle_fatigue_state
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

CREATE POLICY muscle_fatigue_state_delete ON muscle_fatigue_state
  FOR DELETE TO authenticated USING (user_id = auth.uid());

-- =============================================================================
-- View: current_muscle_fatigue (latest snapshot per user x muscle)
-- =============================================================================

CREATE OR REPLACE VIEW current_muscle_fatigue
WITH (security_invoker = true) AS
SELECT DISTINCT ON (mfs.user_id, mfs.muscle_group_id)
  mfs.user_id,
  mfs.muscle_group_id,
  mg.name                      AS muscle_name,
  mfs.as_of_date,
  mfs.fatigue_score,
  mfs.recovery_status,
  mfs.effective_sets_last_72h,
  mfs.days_since_last_trained,
  mfs.avg_soreness_last_72h
FROM muscle_fatigue_state mfs
JOIN muscle_groups mg ON mg.id = mfs.muscle_group_id
ORDER BY mfs.user_id, mfs.muscle_group_id, mfs.as_of_date DESC;

COMMENT ON VIEW current_muscle_fatigue IS
  'Latest fatigue snapshot per user per muscle. Powers muscle heatmap UI.';

COMMIT;
