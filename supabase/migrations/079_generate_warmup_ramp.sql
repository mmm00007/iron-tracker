-- Migration 079: Auto-Generate Warmup Ramp
-- Function that returns NSCA-aligned warmup sets for a given working weight.
--
-- Existing columns (migration 036): exercises.warmup_sets_min, warmup_sets_max,
-- specific_warmup_notes. This migration adds the RAMP GENERATOR — given a
-- user's working weight and optional bar_empty_kg, returns 2-6 warmup sets
-- with percentages aligned to the working load intensity.
--
-- Validated by: fitness-domain-expert
--
-- Algorithm (NSCA Essentials of Strength Training Ch. 15):
--   For barbell compounds, scale ramp to % of working weight:
--     1. Empty bar ramp — 8-10 reps of empty bar (bar_empty_kg)
--     2. 40% ramp — 5-6 reps at 40% of working weight
--     3. 60% ramp — 3-4 reps at 60%
--     4. 80% ramp — 1-2 reps at 80%
--     5. 90% opener — 1 rep at 90% (strength goal only, working >=85% 1RM)
--     6. Working weight
--
--   Ramp set count varies by working_intensity_pct:
--     <50% 1RM  → 1-2 warmup sets (light work)
--     50-70%    → 2-3 warmup sets (moderate)
--     70-85%    → 3-4 warmup sets (heavy)
--     85%+      → 4-6 warmup sets (max effort)
--
-- Citations:
--   - NSCA (2016). Essentials of Strength Training and Conditioning, 4th ed.
--   - Fradkin A.J. et al. (2010). Effects of warming-up on physical performance.
--   - Prieske O. et al. (2020). Static stretching warm-up meta-analysis.

BEGIN;

-- =============================================================================
-- generate_warmup_ramp(working_weight, working_intensity_pct_1rm, bar_empty_kg)
-- =============================================================================

CREATE OR REPLACE FUNCTION generate_warmup_ramp(
  p_working_weight numeric,
  p_working_intensity_pct_1rm numeric DEFAULT 75,
  p_bar_empty_kg numeric DEFAULT 20,
  p_weight_increment numeric DEFAULT 2.5
)
RETURNS TABLE (
  set_number smallint,
  weight numeric,
  reps smallint,
  pct_of_working_weight smallint,
  rest_seconds smallint,
  notes text
)
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
  v_ramp_set_count smallint;
BEGIN
  IF p_working_weight IS NULL OR p_working_weight <= 0 THEN
    RETURN;
  END IF;

  -- Determine ramp density by working intensity
  v_ramp_set_count := CASE
    WHEN p_working_intensity_pct_1rm < 50   THEN 2
    WHEN p_working_intensity_pct_1rm < 70   THEN 3
    WHEN p_working_intensity_pct_1rm < 85   THEN 4
    ELSE                                         5
  END;

  -- For sub-bar working weights, skip empty bar; return a single 50% ramp
  IF p_working_weight < p_bar_empty_kg * 1.5 THEN
    RETURN QUERY SELECT
      1::smallint, p_bar_empty_kg, 8::smallint, 100::smallint, 60::smallint,
      'Empty bar — movement pattern rehearsal'::text;
    RETURN;
  END IF;

  -- Full ramp: always start with empty bar
  RETURN QUERY SELECT
    1::smallint, p_bar_empty_kg, 10::smallint,
    ROUND((p_bar_empty_kg / p_working_weight * 100))::smallint,
    45::smallint,
    'Empty bar — movement pattern + warmup'::text;

  -- 40% ramp (always present)
  IF v_ramp_set_count >= 2 THEN
    RETURN QUERY SELECT
      2::smallint,
      -- Round to nearest weight_increment
      (ROUND((p_working_weight * 0.40) / p_weight_increment) * p_weight_increment)::numeric,
      5::smallint, 40::smallint, 60::smallint,
      '40% ramp — easy, moderate ROM'::text;
  END IF;

  -- 60% ramp
  IF v_ramp_set_count >= 3 THEN
    RETURN QUERY SELECT
      3::smallint,
      (ROUND((p_working_weight * 0.60) / p_weight_increment) * p_weight_increment)::numeric,
      3::smallint, 60::smallint, 90::smallint,
      '60% ramp — full ROM prep'::text;
  END IF;

  -- 80% ramp
  IF v_ramp_set_count >= 4 THEN
    RETURN QUERY SELECT
      4::smallint,
      (ROUND((p_working_weight * 0.80) / p_weight_increment) * p_weight_increment)::numeric,
      2::smallint, 80::smallint, 120::smallint,
      '80% opener — near-working feel'::text;
  END IF;

  -- 90% opener (only for max-effort days)
  IF v_ramp_set_count >= 5 THEN
    RETURN QUERY SELECT
      5::smallint,
      (ROUND((p_working_weight * 0.90) / p_weight_increment) * p_weight_increment)::numeric,
      1::smallint, 90::smallint, 180::smallint,
      '90% opener — top-set prep (strength days)'::text;
  END IF;
END;
$$;

COMMENT ON FUNCTION generate_warmup_ramp(numeric, numeric, numeric, numeric) IS
  'Returns NSCA-aligned warmup ramp for a working weight. Ramp density scales '
  'with working intensity: 2 sets for <50%% 1RM, up to 5 sets for >=85%% 1RM. '
  'Weights rounded to nearest weight_increment (default 2.5 kg). '
  'p_bar_empty_kg = 20 for standard barbell, 15 for women''s bar, 0 for dumbbell.';

-- =============================================================================
-- generate_warmup_ramp_for_user(user_id, exercise_id, working_weight)
-- =============================================================================
-- Smart wrapper: looks up user's e1RM for the exercise to estimate working
-- intensity automatically.

CREATE OR REPLACE FUNCTION generate_warmup_ramp_for_user(
  p_user_id uuid,
  p_exercise_id uuid,
  p_working_weight numeric,
  p_bar_empty_kg numeric DEFAULT 20
)
RETURNS TABLE (
  set_number smallint,
  weight numeric,
  reps smallint,
  pct_of_working_weight smallint,
  rest_seconds smallint,
  notes text
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public, pg_catalog
AS $$
DECLARE
  v_e1rm numeric;
  v_intensity_pct numeric;
  v_increment numeric := 2.5;
BEGIN
  -- Look up user's best e1RM for this exercise (from personal_records)
  SELECT MAX(pr.value) INTO v_e1rm
  FROM personal_records pr
  WHERE pr.user_id = p_user_id
    AND pr.exercise_id = p_exercise_id
    AND pr.record_type = 'estimated_1rm'
    AND pr.pr_context = 'straight';

  -- Compute working intensity; if no e1RM known, assume moderate (75%)
  IF v_e1rm IS NOT NULL AND v_e1rm > 0 THEN
    v_intensity_pct := (p_working_weight / v_e1rm) * 100;
  ELSE
    v_intensity_pct := 75;
  END IF;

  -- Look up preferred weight increment from user's equipment_variants if present
  SELECT MIN(ev.weight_increment) INTO v_increment
  FROM equipment_variants ev
  WHERE ev.user_id = p_user_id
    AND ev.exercise_id = p_exercise_id
    AND ev.weight_increment IS NOT NULL;

  v_increment := COALESCE(v_increment, 2.5);

  RETURN QUERY
  SELECT * FROM generate_warmup_ramp(p_working_weight, v_intensity_pct, p_bar_empty_kg, v_increment);
END;
$$;

COMMENT ON FUNCTION generate_warmup_ramp_for_user(uuid, uuid, numeric, numeric) IS
  'Per-user wrapper: auto-estimates working intensity from user''s current e1RM '
  'and picks weight_increment from their equipment_variants. Returns generate_warmup_ramp.';

COMMIT;
