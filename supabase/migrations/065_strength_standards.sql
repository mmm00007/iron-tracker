-- Migration 065: PR Bodyweight Context
-- Adds body-weight context to personal_records (BW multiple, pr_context, DOTS).
--
-- HISTORICAL NOTE: An earlier version of this migration also tried to create
-- a second strength_standards table with different columns than the one from
-- migration 025. That CREATE TABLE + seed was removed after discovering the
-- conflict — in production where 025 pre-exists, the duplicate CREATE
-- would skip (IF NOT EXISTS) and the subsequent CREATE INDEX on a column
-- that didn't match would fail, rolling back the entire migration.
-- Strength-standard integration was moved to migration 075, which works with
-- migration 025's existing schema.
--
-- This enables:
--   - "Your bench is 1.4x bodyweight" motivation card
--   - "Intermediate bench, Advanced squat" classification labels (via 075)
--
-- Validated by: fitness-domain-expert, data-science-expert, database-specialist
--
-- Key design decisions:
--   - body_weight_at_record snapshot on each PR (body can change)
--   - body_weight_multiple GENERATED column keeps PR + BW in sync
--     (refined in migration 068 with unit normalization)
--   - pr_context text distinguishes straight/cluster/superset/paused/tempo PRs
--     (per data-science-expert: cluster PRs are not e1RM-comparable)
--
-- Citations:
--   - Reynolds J.M. et al. (2006). 1RM prediction from multiple rep max.
--   - Haff G.G. (2016). Strength assessment standards. NSCA.

BEGIN;

-- =============================================================================
-- 1. EXTEND personal_records WITH BODYWEIGHT CONTEXT
-- =============================================================================

ALTER TABLE personal_records
  ADD COLUMN IF NOT EXISTS body_weight_at_record numeric(5,2)
    CHECK (body_weight_at_record IS NULL OR (body_weight_at_record > 20 AND body_weight_at_record < 300)),
  ADD COLUMN IF NOT EXISTS body_weight_unit text
    DEFAULT 'kg'
    CHECK (body_weight_unit IN ('kg','lb')),
  ADD COLUMN IF NOT EXISTS pr_context text
    NOT NULL DEFAULT 'straight'
    CHECK (pr_context IN ('straight','cluster','superset','paused','tempo','partial_rom','bracing')),
  ADD COLUMN IF NOT EXISTS dots_score numeric(6,2)
    CHECK (dots_score IS NULL OR (dots_score > 0 AND dots_score < 1000)),
  ADD COLUMN IF NOT EXISTS is_competition_lift boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS notes text;

-- Generated column: bw_multiple. Uses kg-normalized values.
-- (If body_weight_unit='lb', caller converts before storing body_weight_at_record.)
ALTER TABLE personal_records
  ADD COLUMN IF NOT EXISTS body_weight_multiple numeric(5,2)
    GENERATED ALWAYS AS (
      CASE
        WHEN body_weight_at_record IS NOT NULL AND body_weight_at_record > 0
        THEN ROUND((value / body_weight_at_record)::numeric, 2)
        ELSE NULL
      END
    ) STORED;

COMMENT ON COLUMN personal_records.body_weight_at_record IS
  'User bodyweight (kg) at the time the PR was achieved. Enables historical '
  'BW-multiple analytics even as the user changes weight.';

COMMENT ON COLUMN personal_records.body_weight_multiple IS
  'Generated: PR value / bodyweight at record. The relative-strength metric lifters care about.';

COMMENT ON COLUMN personal_records.pr_context IS
  'Context for the PR achievement. straight: standard set; cluster: cluster-set PR; '
  'superset: achieved within superset; paused: competition-style pause; tempo: '
  'slow-tempo variant; partial_rom: reduced ROM; bracing: equipped lift (belt/wraps).';

COMMENT ON COLUMN personal_records.dots_score IS
  'IPF DOTS score (2020+). Nullable — computed backend-side for powerlifting lifts only.';

-- Update the unique constraint to include pr_context
-- (old constraint allowed only one PR per user/ex/variant/type/reps;
--  new allows one per (..., pr_context) so cluster and straight PRs coexist)
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'personal_records_user_id_exercise_id_variant_id_record_type_key'
  ) THEN
    ALTER TABLE personal_records
      DROP CONSTRAINT personal_records_user_id_exercise_id_variant_id_record_type_key;
  END IF;
END $$;

-- Recreate the partial unique indexes to include pr_context
DROP INDEX IF EXISTS personal_records_full_key;
CREATE UNIQUE INDEX personal_records_full_key
  ON personal_records (user_id, exercise_id, variant_id, record_type, rep_count, pr_context)
  WHERE variant_id IS NOT NULL AND rep_count IS NOT NULL;

DROP INDEX IF EXISTS personal_records_minimal_key;
CREATE UNIQUE INDEX personal_records_minimal_key
  ON personal_records (user_id, exercise_id, record_type, pr_context)
  WHERE variant_id IS NULL AND rep_count IS NULL;

DROP INDEX IF EXISTS personal_records_no_rep_key;
CREATE UNIQUE INDEX personal_records_no_rep_key
  ON personal_records (user_id, exercise_id, variant_id, record_type, pr_context)
  WHERE variant_id IS NOT NULL AND rep_count IS NULL;

DROP INDEX IF EXISTS personal_records_no_variant_key;
CREATE UNIQUE INDEX personal_records_no_variant_key
  ON personal_records (user_id, exercise_id, record_type, rep_count, pr_context)
  WHERE variant_id IS NULL AND rep_count IS NOT NULL;

COMMIT;

-- Removed: duplicate strength_standards table + seed + classify_lifter_level
-- function. Migration 025 already owns strength_standards. Migration 075
-- creates the classify_lifter_level function and user_strength_percentile
-- view using 025's existing schema.
-- =============================================================================
-- REMOVED: strength_standards (conflicts with migration 025)
-- =============================================================================
