-- Migration 060: Set Clusters (Advanced Set Structures)
-- Groups sets into clusters for correct volume/density/RPE computation.
-- A superset of bench+row is not 6 straight sets; a drop set is not 3 sets
-- for hypertrophic volume purposes. Current analytics conflate these; this
-- migration adds the structural model needed for accurate recovery modeling
-- and coaching.
--
-- Validated by: fitness-domain-expert, data-science-expert, database-specialist
--
-- Key design decisions:
--   - 14 cluster types cover block, metcon, and intensity technique families
--   - superset_type subtype (antagonist/agonist/etc.) drives fatigue modeling
--   - systemic_fatigue_multiplier column on cluster_type_defaults lets analytics
--     weight effective volume per Schoenfeld 2017 / Zaroni 2019
--   - sets.cluster_id ON DELETE SET NULL (sets are sacred — never cascade destroy)
--   - BEFORE-trigger validates cluster_id owner matches set user (defense in depth)
--   - Partial index on sets(cluster_id) WHERE NOT NULL — most sets are unclustered
--   - effective_sets vs mechanical_sets split (data-science-expert): drop set = 1 mechanical
--     set produced + 0.3 per additional drop for hypertrophic volume accounting
--
-- Citations:
--   - Tufano J.J. et al. (2017). Cluster set structures review. Sports Medicine.
--   - Marshall P.W., Robbins D.A. (2020). Intra-set rest systematic review. JSCR.
--   - Schoenfeld B.J. (2017). Drop set hypertrophy. JSCR.
--   - Zaroni R.S. et al. (2019). Superset hypertrophy study. JSCR.
--   - Fink J. et al. (2018). Drop-set protocols. Eur J Transl Myol.
--   - Paz G.A. et al. (2017). Antagonist supersets. Gazzetta Medica.
--   - Seitz L.B., Haff G.G. (2016). Contrast set PAP meta-analysis.
--   - Fagerli B. (2008-2012). Myo-reps method.

BEGIN;

-- =============================================================================
-- 1. REFERENCE TABLE: cluster_type_defaults
-- =============================================================================
-- Per-type fatigue multipliers, default rest, and safety flags. Drives
-- volume_effective computation, UX copy, and autoregulation.

CREATE TABLE IF NOT EXISTS cluster_type_defaults (
  cluster_type                       text        PRIMARY KEY,
  display_name                       text        NOT NULL,
  systemic_fatigue_multiplier        numeric(3,2) NOT NULL
    CHECK (systemic_fatigue_multiplier > 0 AND systemic_fatigue_multiplier <= 3),
  effective_set_coefficient          numeric(3,2) NOT NULL
    CHECK (effective_set_coefficient >= 0 AND effective_set_coefficient <= 1),
  default_intracluster_rest_seconds  smallint    CHECK (default_intracluster_rest_seconds >= 0),
  default_between_rounds_rest_seconds smallint   CHECK (default_between_rounds_rest_seconds >= 0),
  is_high_fatigue_finisher           boolean     NOT NULL DEFAULT false,
  supports_superset_type             boolean     NOT NULL DEFAULT false,
  description                        text,
  citation                           text
);

COMMENT ON TABLE cluster_type_defaults IS
  'Per-cluster-type defaults driving analytics weighting. Fatigue multipliers '
  'are conservative synthesis values from Schoenfeld 2017, Zaroni 2019, Marshall '
  '& Robbins 2020 — heuristics, not research-grade truth. Versioned via migrations.';

COMMENT ON COLUMN cluster_type_defaults.systemic_fatigue_multiplier IS
  'Multiplier vs straight-set baseline (1.0) applied to session_rpe × volume for '
  'fatigue accounting and ACWR. Higher = more recovery cost per unit of work.';

COMMENT ON COLUMN cluster_type_defaults.effective_set_coefficient IS
  'For hypertrophic volume (MEV/MAV/MRV): first sub-set counts as 1.0; '
  'subsequent sub-sets contribute this coefficient. Drop set = 0.30 per Schoenfeld 2017.';

ALTER TABLE cluster_type_defaults ENABLE ROW LEVEL SECURITY;
CREATE POLICY cluster_type_defaults_select ON cluster_type_defaults
  FOR SELECT TO authenticated USING (true);

-- =============================================================================
-- 2. USER TABLE: set_clusters
-- =============================================================================

CREATE TABLE IF NOT EXISTS set_clusters (
  id                              uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id                         uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  training_date                   date        NOT NULL,
  cluster_type                    text        NOT NULL
    REFERENCES cluster_type_defaults(cluster_type) ON UPDATE CASCADE ON DELETE RESTRICT,
  superset_type                   text        CHECK (superset_type IN ('antagonist','agonist','pre_exhaust','post_exhaust','unrelated','compound_set')),
  cluster_label                   text,
  planned_rounds                  smallint    CHECK (planned_rounds > 0 AND planned_rounds <= 30),
  completed_rounds                smallint    CHECK (completed_rounds >= 0 AND completed_rounds <= 30),
  planned_intracluster_rest_seconds smallint  CHECK (planned_intracluster_rest_seconds >= 0 AND planned_intracluster_rest_seconds <= 600),
  planned_between_rounds_rest_seconds smallint CHECK (planned_between_rounds_rest_seconds >= 0 AND planned_between_rounds_rest_seconds <= 1800),
  target_failure_rir              smallint    CHECK (target_failure_rir >= 0 AND target_failure_rir <= 5),
  notes                           text,
  created_at                      timestamptz NOT NULL DEFAULT now(),
  updated_at                      timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE set_clusters IS
  'Groups related sets into clusters (supersets, drop sets, rest-pause, etc.). '
  'Each cluster has a type from cluster_type_defaults driving analytics weighting. '
  'Sets link via sets.cluster_id; ownership enforced by BEFORE-insert trigger.';

COMMENT ON COLUMN set_clusters.superset_type IS
  'Only meaningful when cluster_type IN (superset, giant_set). Antagonist pairings '
  'show minimal performance decrement (Robbins 2010); agonist/compound adds fatigue.';

COMMENT ON COLUMN set_clusters.target_failure_rir IS
  'Target reps-in-reserve at each sub-set. 0 = absolute failure (rest-pause, drop set); '
  '2-3 = cluster set preserving bar speed.';

CREATE INDEX IF NOT EXISTS set_clusters_user_date_idx
  ON set_clusters (user_id, training_date DESC);

CREATE INDEX IF NOT EXISTS set_clusters_user_type_idx
  ON set_clusters (user_id, cluster_type);

ALTER TABLE set_clusters ENABLE ROW LEVEL SECURITY;

CREATE POLICY set_clusters_select ON set_clusters
  FOR SELECT TO authenticated USING (user_id = auth.uid());

CREATE POLICY set_clusters_insert ON set_clusters
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());

CREATE POLICY set_clusters_update ON set_clusters
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

CREATE POLICY set_clusters_delete ON set_clusters
  FOR DELETE TO authenticated USING (user_id = auth.uid());

CREATE TRIGGER set_clusters_updated_at
  BEFORE UPDATE ON set_clusters
  FOR EACH ROW
  EXECUTE FUNCTION set_updated_at();

-- =============================================================================
-- 3. EXTEND sets WITH CLUSTER REFERENCES
-- =============================================================================
-- Adds cluster_id (nullable FK), cluster_position (order within cluster),
-- and cluster_round (which round for multi-round clusters).
-- All three nullable — unclustered straight sets remain unchanged.

ALTER TABLE sets
  ADD COLUMN IF NOT EXISTS cluster_id       uuid REFERENCES set_clusters(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS cluster_position smallint CHECK (cluster_position > 0 AND cluster_position <= 50),
  ADD COLUMN IF NOT EXISTS cluster_round    smallint CHECK (cluster_round > 0 AND cluster_round <= 50);

COMMENT ON COLUMN sets.cluster_id IS
  'Optional link to set_clusters row. NULL = straight set. ON DELETE SET NULL: '
  'sets are sacred, never cascade-destroyed by cluster metadata deletion.';

COMMENT ON COLUMN sets.cluster_position IS
  'Position of this set within the cluster round. For superset A1/A2/A3 = 1, 2, 3.';

COMMENT ON COLUMN sets.cluster_round IS
  'Which round of the cluster this set belongs to. For 3-round superset: 1, 2, or 3.';

-- Partial index — most sets are unclustered; index only when cluster_id present.
-- NOTE: On deployments with a very large sets table (>10M rows), consider running
-- CREATE INDEX CONCURRENTLY outside this transaction. Not concurrent here for
-- idempotent migration semantics.
CREATE INDEX IF NOT EXISTS sets_cluster_idx
  ON sets (cluster_id, cluster_round, cluster_position)
  WHERE cluster_id IS NOT NULL;

-- =============================================================================
-- 4. DEFENSE-IN-DEPTH: validate cluster ownership on insert/update
-- =============================================================================
-- RLS prevents SELECTing other users' clusters, but a client who guesses a UUID
-- could still attempt to link a set to another user's cluster. This trigger
-- rejects such attempts at the database layer.

CREATE OR REPLACE FUNCTION validate_set_cluster_ownership()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_catalog
AS $$
BEGIN
  IF NEW.cluster_id IS NOT NULL THEN
    IF NOT EXISTS (
      SELECT 1 FROM set_clusters
      WHERE id = NEW.cluster_id AND user_id = NEW.user_id
    ) THEN
      RAISE EXCEPTION 'cluster_id % does not belong to user %', NEW.cluster_id, NEW.user_id
        USING ERRCODE = 'check_violation';
    END IF;
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER sets_validate_cluster_ownership
  BEFORE INSERT OR UPDATE OF cluster_id, user_id ON sets
  FOR EACH ROW
  EXECUTE FUNCTION validate_set_cluster_ownership();

COMMENT ON FUNCTION validate_set_cluster_ownership() IS
  'Enforces that a set can only reference a cluster owned by the same user. '
  'Defense-in-depth beyond RLS. Raises check_violation on mismatch.';

-- =============================================================================
-- 5. SEED DATA: cluster_type_defaults
-- =============================================================================

INSERT INTO cluster_type_defaults (
  cluster_type, display_name,
  systemic_fatigue_multiplier, effective_set_coefficient,
  default_intracluster_rest_seconds, default_between_rounds_rest_seconds,
  is_high_fatigue_finisher, supports_superset_type,
  description, citation
) VALUES
  ('superset', 'Superset',
   1.00, 1.00, 10, 120, false, true,
   'Two exercises back-to-back with minimal rest. Antagonist pairs are recovery-neutral.',
   'Zaroni 2019; Robbins 2010; Paz 2017'),
  ('giant_set', 'Giant Set',
   1.50, 1.00, 10, 180, false, true,
   'Three or more exercises back-to-back. High cardiovascular demand.',
   'Kraemer NSCA 2016'),
  ('cluster_set', 'Cluster Set',
   0.85, 1.00, 20, 180, false, false,
   'Planned intra-rep rest (e.g., 5x1 @ 90% with 20s rest). Preserves bar speed for strength.',
   'Tufano 2017; Haff 2003'),
  ('rest_pause', 'Rest-Pause',
   1.40, 0.50, 15, 180, true, false,
   'Set to failure, brief rest 15-20s, continue to failure, repeat. DC Training signature.',
   'Korak 2017 JSCR'),
  ('drop_set', 'Drop Set',
   1.50, 0.30, 0, 180, true, false,
   'To failure, reduce load 20-30%, continue to failure without rest. Repeat 1-3 drops.',
   'Schoenfeld 2017; Fink 2018'),
  ('mechanical_drop', 'Mechanical Drop Set',
   1.40, 0.40, 0, 180, true, false,
   'Fatigue leverage reduces; switch to mechanically advantaged variant (incline→flat→decline).',
   'Weider principles; Antonio 2018'),
  ('myo_rep', 'Myo-Reps',
   1.25, 0.60, 10, 180, true, false,
   'Activation set to RIR 1-2, then 3-5 mini-sets of 3-5 reps with breath-rest (Fagerli).',
   'Fagerli 2012; Marshall & Robbins 2020'),
  ('emom', 'EMOM',
   1.20, 1.00, 0, 60, false, false,
   'Every Minute On the Minute. Fixed work + variable rest within the minute.',
   'CrossFit methodology; Martinez-Aranda 2018'),
  ('amrap_block', 'AMRAP Block',
   1.35, 1.00, 0, 0, true, false,
   'As Many Rounds/Reps As Possible in time cap. Metabolic and muscular endurance.',
   'Glassman 2007'),
  ('pyramid', 'Pyramid',
   1.10, 1.00, 0, 150, false, false,
   'Ascending load, descending reps across sets (10→8→6→4). Classic bodybuilding.',
   'Zatsiorsky 1995'),
  ('reverse_pyramid', 'Reverse Pyramid',
   1.05, 1.00, 0, 180, false, false,
   'Heaviest set first (still fresh), then descend load / ascend reps.',
   'Berkhan 2009 LeanGains'),
  ('twenty_ones', '21s',
   1.30, 0.80, 0, 90, true, false,
   '7 bottom-half partials + 7 top-half partials + 7 full reps. Biceps/lateral raises.',
   'Weider principles'),
  ('contrast_set', 'Contrast Set',
   1.20, 1.00, 180, 240, false, false,
   'Heavy compound (85-90% 1RM) paired with explosive/plyometric. Post-activation potentiation.',
   'Seitz & Haff 2016'),
  ('partials_post_failure', 'Partials Post-Failure',
   1.40, 0.40, 0, 180, true, false,
   'Full reps to failure, then partial reps in strongest range.',
   'Hedrick 1995; Goto 2004')
ON CONFLICT (cluster_type) DO NOTHING;

COMMIT;
