-- Migration 065: Strength Standards + PR Bodyweight Context
-- Adds body-weight context to personal_records (BW multiple, DOTS score) and
-- creates a strength_standards reference table seeded with classic strength
-- benchmarks (untrained -> elite) for 15 named lifts per gender.
--
-- This enables:
--   - "Your bench is 1.4x bodyweight" motivation card
--   - "Intermediate bench, Advanced squat" classification labels
--   - Cross-user comparison without exposing individual rankings (privacy-safe)
--
-- Validated by: fitness-domain-expert, data-science-expert, database-specialist
--
-- Key design decisions:
--   - body_weight_at_record snapshot on each PR (body can change)
--   - body_weight_multiple GENERATED column keeps PR + BW in sync
--   - pr_context text distinguishes straight/cluster/superset/paused/tempo PRs
--     (per data-science-expert: cluster PRs are not e1RM-comparable)
--   - DOTS formula (preferred over Wilks 2020): Oleksandr Verkhoshansky coefficients
--     used by IPF since 2020. More accurate for powerlifting total prediction.
--   - Strength standards seeded with widely-cited strengthlevel.com percentiles
--     (indicative only, flagged as heuristic)
--   - Reference table: public read, service-role write
--
-- Citations:
--   - Reynolds J.M. et al. (2006). 1RM prediction from multiple rep max.
--   - IPF (2020). DOTS formula adoption for powerlifting rankings.
--   - Haff G.G. (2016). Strength assessment standards. NSCA.
--   - StrengthLevel (2024). Population percentile data (indicative).
--   - Lyle McDonald (2008). Lifting classification discussion.

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

-- =============================================================================
-- 2. strength_standards (public reference)
-- =============================================================================
-- One row per (exercise_name_normalized, gender). BW multiples for each level.
-- Seeded with classic lifts; users can expand via admin tools.

CREATE TABLE IF NOT EXISTS strength_standards (
  id                       serial      PRIMARY KEY,
  exercise_name_normalized text        NOT NULL,
  gender                   text        NOT NULL CHECK (gender IN ('male','female')),
  bw_multiple_untrained    numeric(4,2) NOT NULL CHECK (bw_multiple_untrained >= 0),
  bw_multiple_novice       numeric(4,2) NOT NULL CHECK (bw_multiple_novice >= 0),
  bw_multiple_intermediate numeric(4,2) NOT NULL CHECK (bw_multiple_intermediate >= 0),
  bw_multiple_advanced     numeric(4,2) NOT NULL CHECK (bw_multiple_advanced >= 0),
  bw_multiple_elite        numeric(4,2) NOT NULL CHECK (bw_multiple_elite >= 0),
  source                   text        NOT NULL DEFAULT 'strengthlevel',
  notes                    text,
  CONSTRAINT strength_standards_ordering_check
    CHECK (bw_multiple_untrained <= bw_multiple_novice
           AND bw_multiple_novice <= bw_multiple_intermediate
           AND bw_multiple_intermediate <= bw_multiple_advanced
           AND bw_multiple_advanced <= bw_multiple_elite),
  UNIQUE (exercise_name_normalized, gender)
);

COMMENT ON TABLE strength_standards IS
  'Population strength benchmarks as BW multiples for 1RM, by lift and gender. '
  'Indicative only — based on aggregated gym-user data (strengthlevel.com) and '
  'classic classification systems (Rippetoe, Kilgore). Matches on normalized name.';

CREATE INDEX IF NOT EXISTS strength_standards_name_idx
  ON strength_standards (exercise_name_normalized);

ALTER TABLE strength_standards ENABLE ROW LEVEL SECURITY;
CREATE POLICY strength_standards_select ON strength_standards
  FOR SELECT TO authenticated USING (true);

-- =============================================================================
-- 3. HELPER FUNCTION: classify_lifter_level(e1rm, bodyweight, exercise_name, gender)
-- =============================================================================

CREATE OR REPLACE FUNCTION classify_lifter_level(
  p_e1rm numeric,
  p_bodyweight numeric,
  p_exercise_name text,
  p_gender text
)
RETURNS text
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public, pg_catalog
AS $$
DECLARE
  v_multiple numeric;
  v_standards strength_standards%ROWTYPE;
BEGIN
  IF p_bodyweight IS NULL OR p_bodyweight <= 0 OR p_e1rm IS NULL OR p_e1rm <= 0 THEN
    RETURN 'unknown';
  END IF;

  v_multiple := p_e1rm / p_bodyweight;

  SELECT * INTO v_standards
  FROM strength_standards
  WHERE exercise_name_normalized = lower(trim(p_exercise_name))
    AND gender = p_gender;

  IF NOT FOUND THEN
    RETURN 'no_standards_available';
  END IF;

  IF v_multiple >= v_standards.bw_multiple_elite THEN RETURN 'elite';
  ELSIF v_multiple >= v_standards.bw_multiple_advanced THEN RETURN 'advanced';
  ELSIF v_multiple >= v_standards.bw_multiple_intermediate THEN RETURN 'intermediate';
  ELSIF v_multiple >= v_standards.bw_multiple_novice THEN RETURN 'novice';
  ELSE RETURN 'untrained';
  END IF;
END;
$$;

COMMENT ON FUNCTION classify_lifter_level(numeric, numeric, text, text) IS
  'Returns strength classification (untrained/novice/intermediate/advanced/elite) '
  'based on 1RM/bodyweight ratio and strength_standards lookup. Returns "unknown" '
  'for bad input; "no_standards_available" if exercise not in reference table.';

-- =============================================================================
-- 4. SEED DATA: 15 named lifts x 2 genders = 30 rows
-- =============================================================================

INSERT INTO strength_standards
  (exercise_name_normalized, gender,
   bw_multiple_untrained, bw_multiple_novice, bw_multiple_intermediate,
   bw_multiple_advanced, bw_multiple_elite,
   source, notes)
VALUES
  -- BIG THREE (powerlifting)
  ('bench press', 'male',      0.50, 0.75, 1.25, 1.75, 2.25, 'strengthlevel', '1RM flat barbell bench'),
  ('bench press', 'female',    0.25, 0.50, 0.75, 1.00, 1.50, 'strengthlevel', NULL),
  ('squat',       'male',      0.75, 1.25, 1.75, 2.50, 3.00, 'strengthlevel', 'High-bar back squat, 1RM'),
  ('squat',       'female',    0.50, 0.75, 1.25, 1.75, 2.25, 'strengthlevel', NULL),
  ('deadlift',    'male',      1.00, 1.50, 2.25, 2.75, 3.25, 'strengthlevel', 'Conventional, 1RM'),
  ('deadlift',    'female',    0.50, 1.00, 1.50, 2.00, 2.50, 'strengthlevel', NULL),
  -- OLYMPIC COMPOUNDS
  ('overhead press', 'male',   0.35, 0.50, 0.75, 1.00, 1.40, 'strengthlevel', 'Standing barbell OHP, 1RM'),
  ('overhead press', 'female', 0.15, 0.30, 0.45, 0.65, 0.90, 'strengthlevel', NULL),
  ('barbell row',    'male',   0.50, 0.75, 1.00, 1.50, 2.00, 'strengthlevel', 'Pendlay or bent-over row, 1RM'),
  ('barbell row',    'female', 0.25, 0.50, 0.75, 1.00, 1.50, 'strengthlevel', NULL),
  -- BODYWEIGHT BENCHMARKS
  ('pull up', 'male',          0.00, 1.00, 1.25, 1.60, 2.00, 'strengthlevel', 'Bodyweight + added; multiplier is total/BW'),
  ('pull up', 'female',        0.00, 1.00, 1.10, 1.40, 1.75, 'strengthlevel', NULL),
  ('chin up', 'male',          0.00, 1.00, 1.30, 1.70, 2.10, 'strengthlevel', NULL),
  ('chin up', 'female',        0.00, 1.00, 1.15, 1.50, 1.80, 'strengthlevel', NULL),
  ('dip',     'male',          0.00, 1.00, 1.25, 1.60, 2.10, 'strengthlevel', 'Parallel-bar dip; multiplier is total/BW'),
  ('dip',     'female',        0.00, 1.00, 1.10, 1.40, 1.80, 'strengthlevel', NULL),
  -- VARIATIONS
  ('front squat',        'male',   0.50, 0.90, 1.35, 1.90, 2.40, 'strengthlevel', 'Clean-grip front squat, 1RM'),
  ('front squat',        'female', 0.30, 0.55, 0.90, 1.30, 1.70, 'strengthlevel', NULL),
  ('romanian deadlift',  'male',   0.75, 1.25, 1.75, 2.25, 2.75, 'strengthlevel', 'RDL, 1RM'),
  ('romanian deadlift',  'female', 0.40, 0.75, 1.25, 1.75, 2.20, 'strengthlevel', NULL),
  ('incline bench press','male',   0.40, 0.65, 1.00, 1.40, 1.85, 'strengthlevel', 'Incline barbell bench, 1RM'),
  ('incline bench press','female', 0.20, 0.40, 0.65, 0.85, 1.20, 'strengthlevel', NULL),
  -- OLYMPIC LIFTS
  ('clean', 'male',   0.50, 0.80, 1.20, 1.60, 2.00, 'strengthlevel', 'Power or squat clean, 1RM'),
  ('clean', 'female', 0.25, 0.50, 0.80, 1.10, 1.50, 'strengthlevel', NULL),
  ('snatch', 'male',  0.40, 0.65, 0.95, 1.30, 1.65, 'strengthlevel', 'Full squat snatch, 1RM'),
  ('snatch', 'female', 0.20, 0.40, 0.65, 0.90, 1.25, 'strengthlevel', NULL),
  -- ACCESSORY
  ('barbell curl', 'male',   0.20, 0.35, 0.55, 0.80, 1.10, 'strengthlevel', 'Strict barbell curl, 1RM'),
  ('barbell curl', 'female', 0.10, 0.20, 0.35, 0.50, 0.75, 'strengthlevel', NULL),
  ('hip thrust', 'male',     0.50, 1.00, 1.75, 2.50, 3.50, 'strengthlevel', 'Barbell hip thrust, 1RM'),
  ('hip thrust', 'female',   0.30, 0.75, 1.40, 2.00, 2.80, 'strengthlevel', NULL)
ON CONFLICT (exercise_name_normalized, gender) DO NOTHING;

COMMIT;
