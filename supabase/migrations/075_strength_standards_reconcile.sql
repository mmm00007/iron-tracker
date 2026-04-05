-- Migration 075: Strength Standards Reconciliation + Percentile View
--
-- DEFECT FIX: Migration 065 attempted to CREATE TABLE strength_standards
-- but that table already existed from migration 025 (with different columns).
-- In production with 025 deployed, 065's CREATE INDEX on exercise_name_normalized
-- would fail → entire 065 transaction rolls back → personal_records never gets
-- the body_weight_at_record / pr_context / dots_score columns → 068's
-- body_weight_multiple generated column also fails (depends on 065's columns).
--
-- This migration:
--   1. Idempotently adds the personal_records columns 065 intended to add
--   2. Recreates pr_context-aware UNIQUE constraints on personal_records
--   3. Rewrites body_weight_multiple (from 068) with unit normalization
--   4. Drops stale classify_lifter_level function
--   5. Creates new classify_lifter_level_v2 using migration 025's actual schema
--   6. Creates user_strength_percentile view using 025's strength_standards
--
-- Safe to run: all ALTER TABLE uses IF NOT EXISTS / IF EXISTS guards.
--
-- Note: the duplicate strength_standards table from 065 (if ever created in a
-- non-production environment) is left in place — drop manually if cleanup needed.

BEGIN;

-- =============================================================================
-- 1. Add personal_records columns (from 065 + 068)
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
  ADD COLUMN IF NOT EXISTS notes text,
  ADD COLUMN IF NOT EXISTS pr_weight_unit text
    NOT NULL DEFAULT 'kg'
    CHECK (pr_weight_unit IN ('kg','lb'));

-- body_weight_multiple: drop if exists, recreate with unit normalization
ALTER TABLE personal_records DROP COLUMN IF EXISTS body_weight_multiple;

ALTER TABLE personal_records
  ADD COLUMN body_weight_multiple numeric(5,2)
    GENERATED ALWAYS AS (
      CASE
        WHEN body_weight_at_record IS NULL OR body_weight_at_record <= 0
        THEN NULL
        ELSE ROUND(
          (
            (CASE WHEN pr_weight_unit = 'lb' THEN value / 2.20462 ELSE value END)
            /
            (CASE WHEN body_weight_unit = 'lb' THEN body_weight_at_record / 2.20462 ELSE body_weight_at_record END)
          )::numeric, 2
        )
      END
    ) STORED;

COMMENT ON COLUMN personal_records.body_weight_multiple IS
  'Generated: normalized PR value / normalized bodyweight. Both converted to kg '
  'before division, so the multiple is always unit-agnostic.';

-- =============================================================================
-- 2. Rebuild pr_context-aware UNIQUE indexes
-- =============================================================================
-- If the original 4-column UNIQUE (user_id, exercise_id, variant_id, record_type,
-- rep_count) is still in place, replace with pr_context-aware versions.

DO $$
BEGIN
  -- Drop the original auto-generated UNIQUE constraint if it exists
  IF EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'personal_records'::regclass AND contype = 'u'
      AND array_length(conkey, 1) = 5
  ) THEN
    EXECUTE (
      SELECT 'ALTER TABLE personal_records DROP CONSTRAINT ' || quote_ident(conname)
      FROM pg_constraint
      WHERE conrelid = 'personal_records'::regclass AND contype = 'u'
        AND array_length(conkey, 1) = 5
      LIMIT 1
    );
  END IF;
END $$;

-- Drop any partial unique indexes from migration 008 / 065
DROP INDEX IF EXISTS personal_records_full_key;
DROP INDEX IF EXISTS personal_records_minimal_key;
DROP INDEX IF EXISTS personal_records_no_rep_key;
DROP INDEX IF EXISTS personal_records_no_variant_key;

-- Recreate with pr_context included
CREATE UNIQUE INDEX IF NOT EXISTS personal_records_full_key
  ON personal_records (user_id, exercise_id, variant_id, record_type, rep_count, pr_context)
  WHERE variant_id IS NOT NULL AND rep_count IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS personal_records_minimal_key
  ON personal_records (user_id, exercise_id, record_type, pr_context)
  WHERE variant_id IS NULL AND rep_count IS NULL;

CREATE UNIQUE INDEX IF NOT EXISTS personal_records_no_rep_key
  ON personal_records (user_id, exercise_id, variant_id, record_type, pr_context)
  WHERE variant_id IS NOT NULL AND rep_count IS NULL;

CREATE UNIQUE INDEX IF NOT EXISTS personal_records_no_variant_key
  ON personal_records (user_id, exercise_id, record_type, rep_count, pr_context)
  WHERE variant_id IS NULL AND rep_count IS NOT NULL;

-- =============================================================================
-- 3. Replace classify_lifter_level with 025-schema-compatible version
-- =============================================================================

DROP FUNCTION IF EXISTS classify_lifter_level(numeric, numeric, text, text);

CREATE OR REPLACE FUNCTION classify_lifter_level(
  p_e1rm numeric,
  p_bodyweight numeric,
  p_exercise_name text,
  p_sex text
)
RETURNS text
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public, pg_catalog
AS $$
DECLARE
  v_ratio numeric;
  v_std RECORD;
BEGIN
  IF p_bodyweight IS NULL OR p_bodyweight <= 0 OR p_e1rm IS NULL OR p_e1rm <= 0 THEN
    RETURN 'unknown';
  END IF;

  v_ratio := p_e1rm / p_bodyweight;

  -- Match on strength_standards (from migration 025). Case-insensitive name match.
  SELECT beginner_bw_ratio, novice_bw_ratio, intermediate_bw_ratio,
         advanced_bw_ratio, elite_bw_ratio,
         beginner_1rm, novice_1rm, intermediate_1rm, advanced_1rm, elite_1rm,
         reference_bw_kg
  INTO v_std
  FROM strength_standards
  WHERE lower(exercise_name) = lower(trim(p_exercise_name))
    AND sex = p_sex
  LIMIT 1;

  IF NOT FOUND THEN
    RETURN 'no_standards_available';
  END IF;

  -- Prefer BW-ratio comparison if available
  IF v_std.beginner_bw_ratio IS NOT NULL THEN
    IF v_ratio >= v_std.elite_bw_ratio        THEN RETURN 'elite';
    ELSIF v_ratio >= v_std.advanced_bw_ratio  THEN RETURN 'advanced';
    ELSIF v_ratio >= v_std.intermediate_bw_ratio THEN RETURN 'intermediate';
    ELSIF v_ratio >= v_std.novice_bw_ratio    THEN RETURN 'novice';
    ELSIF v_ratio >= v_std.beginner_bw_ratio  THEN RETURN 'beginner';
    ELSE                                           RETURN 'untrained';
    END IF;
  -- Fall back to absolute 1RM comparison scaled to user bodyweight
  ELSE
    IF p_e1rm >= v_std.elite_1rm        THEN RETURN 'elite';
    ELSIF p_e1rm >= v_std.advanced_1rm  THEN RETURN 'advanced';
    ELSIF p_e1rm >= v_std.intermediate_1rm THEN RETURN 'intermediate';
    ELSIF p_e1rm >= v_std.novice_1rm    THEN RETURN 'novice';
    ELSIF p_e1rm >= v_std.beginner_1rm  THEN RETURN 'beginner';
    ELSE                                     RETURN 'untrained';
    END IF;
  END IF;
END;
$$;

COMMENT ON FUNCTION classify_lifter_level(numeric, numeric, text, text) IS
  'Returns strength classification (untrained/beginner/novice/intermediate/advanced/elite) '
  'based on 1RM and bodyweight, comparing against strength_standards (migration 025). '
  'Uses BW-relative ratios preferred; falls back to absolute 1RM values. '
  'Case-insensitive exercise name match.';

-- =============================================================================
-- 4. user_strength_percentile view
-- =============================================================================
-- Combines personal_records (with new body_weight_multiple) + strength_standards
-- + profiles to show each user's current classification per named lift, plus
-- their distance to the next level as a BW multiple.

CREATE OR REPLACE VIEW user_strength_percentile
WITH (security_invoker = true) AS
WITH best_prs AS (
  SELECT DISTINCT ON (pr.user_id, pr.exercise_id)
    pr.user_id,
    pr.exercise_id,
    pr.value,
    pr.pr_weight_unit,
    pr.body_weight_at_record,
    pr.body_weight_unit,
    pr.body_weight_multiple,
    pr.achieved_at,
    pr.pr_context
  FROM personal_records pr
  WHERE pr.record_type = 'estimated_1rm'
    AND pr.pr_context = 'straight'
  ORDER BY pr.user_id, pr.exercise_id, pr.value DESC
)
SELECT
  bp.user_id,
  bp.exercise_id,
  e.name                          AS exercise_name,
  bp.value                        AS pr_value,
  bp.pr_weight_unit,
  bp.body_weight_at_record,
  bp.body_weight_multiple,
  p.sex                           AS user_sex,
  ss.beginner_bw_ratio,
  ss.novice_bw_ratio,
  ss.intermediate_bw_ratio,
  ss.advanced_bw_ratio,
  ss.elite_bw_ratio,
  classify_lifter_level(
    CASE WHEN bp.pr_weight_unit = 'lb' THEN bp.value / 2.20462 ELSE bp.value END,
    CASE WHEN bp.body_weight_unit = 'lb' THEN bp.body_weight_at_record / 2.20462
         ELSE bp.body_weight_at_record END,
    e.name,
    p.sex
  ) AS current_level,
  -- Distance to next tier as BW multiple
  CASE
    WHEN bp.body_weight_multiple IS NULL OR ss.beginner_bw_ratio IS NULL THEN NULL
    WHEN bp.body_weight_multiple < ss.beginner_bw_ratio     THEN ss.beginner_bw_ratio - bp.body_weight_multiple
    WHEN bp.body_weight_multiple < ss.novice_bw_ratio       THEN ss.novice_bw_ratio - bp.body_weight_multiple
    WHEN bp.body_weight_multiple < ss.intermediate_bw_ratio THEN ss.intermediate_bw_ratio - bp.body_weight_multiple
    WHEN bp.body_weight_multiple < ss.advanced_bw_ratio     THEN ss.advanced_bw_ratio - bp.body_weight_multiple
    WHEN bp.body_weight_multiple < ss.elite_bw_ratio        THEN ss.elite_bw_ratio - bp.body_weight_multiple
    ELSE 0
  END::numeric(4,2) AS delta_to_next_tier_bw_multiple,
  -- Name the next tier
  CASE
    WHEN bp.body_weight_multiple IS NULL OR ss.beginner_bw_ratio IS NULL THEN NULL
    WHEN bp.body_weight_multiple < ss.beginner_bw_ratio     THEN 'beginner'
    WHEN bp.body_weight_multiple < ss.novice_bw_ratio       THEN 'novice'
    WHEN bp.body_weight_multiple < ss.intermediate_bw_ratio THEN 'intermediate'
    WHEN bp.body_weight_multiple < ss.advanced_bw_ratio     THEN 'advanced'
    WHEN bp.body_weight_multiple < ss.elite_bw_ratio        THEN 'elite'
    ELSE 'elite+'
  END AS next_tier
FROM best_prs bp
JOIN exercises e ON e.id = bp.exercise_id
LEFT JOIN profiles p ON p.id = bp.user_id
LEFT JOIN strength_standards ss
  ON lower(ss.exercise_name) = lower(e.name) AND ss.sex = p.sex;

COMMENT ON VIEW user_strength_percentile IS
  'Per-user strength classification on each named lift (estimated_1rm straight-set PRs). '
  'Joins personal_records to strength_standards (migration 025) by lower-cased exercise name. '
  'Shows current tier (untrained→elite) + delta to next tier as BW multiple. '
  'Rows absent when sex is NULL or lift not in strength_standards.';

COMMIT;
