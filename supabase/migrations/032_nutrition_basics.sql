-- Migration 032: Nutrition Basics
-- Adds daily nutrition logging and profile-level macronutrient targets.
--
-- Validated by: fitness-domain-expert agent
--
-- Key design decisions:
--   - Daily totals only (not per-meal) — minimum viable nutrition for a
--     lifting-focused app. Avoids becoming a food diary while enabling
--     protein:bodyweight ratio tracking and training-nutrition correlation.
--   - fiber_g included per ISSN/ACSM guidelines for body recomposition
--   - protein_target_g_per_kg is the evidence-based metric (Jager et al., 2017:
--     1.6-2.2 g/kg for resistance-trained individuals)
--   - source column supports future import integrations (MFP, Cronometer)
--   - UNIQUE on (user_id, logged_date) — one summary per user per day

BEGIN;

-- =============================================================================
-- 1. TABLE: nutrition_logs
-- =============================================================================

CREATE TABLE IF NOT EXISTS nutrition_logs (
  id              uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  logged_date     date        NOT NULL,
  calories_kcal   integer     CHECK (calories_kcal >= 0 AND calories_kcal <= 15000),
  protein_g       numeric     CHECK (protein_g >= 0 AND protein_g <= 1000),
  carbs_g         numeric     CHECK (carbs_g >= 0 AND carbs_g <= 2000),
  fat_g           numeric     CHECK (fat_g >= 0 AND fat_g <= 1000),
  fiber_g         numeric     CHECK (fiber_g >= 0 AND fiber_g <= 200),
  water_ml        integer     CHECK (water_ml >= 0 AND water_ml <= 20000),
  source          text        NOT NULL DEFAULT 'manual'
    CHECK (source IN ('manual', 'myfitnesspal', 'cronometer', 'apple_health', 'other')),
  notes           text,
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, logged_date)
);

COMMENT ON TABLE nutrition_logs IS
  'Daily nutrition summaries. One row per user per day. Enables '
  'protein:bodyweight ratio analysis and training-nutrition correlation. '
  'Designed for daily totals, not per-meal logging.';
COMMENT ON COLUMN nutrition_logs.fiber_g IS
  'Daily fiber intake (g). Included per ISSN/ACSM guidelines as satiety '
  'marker relevant to body recomposition goal.';
COMMENT ON COLUMN nutrition_logs.source IS
  'Data origin: manual entry or imported from MyFitnessPal, Cronometer, '
  'Apple Health, or other external sources.';

-- Indexes
CREATE INDEX IF NOT EXISTS nutrition_logs_user_date_idx
  ON nutrition_logs (user_id, logged_date DESC);

-- RLS
ALTER TABLE nutrition_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY nutrition_logs_select ON nutrition_logs
  FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY nutrition_logs_insert ON nutrition_logs
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY nutrition_logs_update ON nutrition_logs
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY nutrition_logs_delete ON nutrition_logs
  FOR DELETE TO authenticated USING (user_id = auth.uid());

CREATE TRIGGER nutrition_logs_updated_at
  BEFORE UPDATE ON nutrition_logs
  FOR EACH ROW
  EXECUTE FUNCTION set_updated_at();


-- =============================================================================
-- 2. PROFILE EXTENSIONS: Nutrition Targets
-- =============================================================================

ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS calorie_target integer
    CHECK (calorie_target >= 500 AND calorie_target <= 15000),
  ADD COLUMN IF NOT EXISTS protein_target_g numeric
    CHECK (protein_target_g >= 10 AND protein_target_g <= 500),
  ADD COLUMN IF NOT EXISTS protein_target_g_per_kg numeric
    CHECK (protein_target_g_per_kg >= 0.5 AND protein_target_g_per_kg <= 5.0);

COMMENT ON COLUMN profiles.calorie_target IS
  'Daily calorie target (kcal). Used for dashboard compliance indicator.';
COMMENT ON COLUMN profiles.protein_target_g IS
  'Daily protein target (g). Absolute value for quick comparison.';
COMMENT ON COLUMN profiles.protein_target_g_per_kg IS
  'Daily protein target relative to body weight (g/kg). ISSN recommends '
  '1.6-2.2 g/kg for resistance-trained individuals (Jager et al., 2017).';


-- =============================================================================
-- 3. VIEW: nutrition_training_correlation
-- =============================================================================

-- Joins daily nutrition with training day summaries for correlation analysis.
-- Only shows days where both nutrition AND training data exist.
CREATE OR REPLACE VIEW nutrition_training_correlation
WITH (security_invoker = true) AS
SELECT
  n.user_id,
  n.logged_date,
  n.calories_kcal,
  n.protein_g,
  n.carbs_g,
  n.fat_g,
  n.fiber_g,
  -- Protein per kg (requires current_body_weight_kg from profile)
  CASE
    WHEN p.current_body_weight_kg > 0 AND n.protein_g IS NOT NULL
    THEN ROUND(n.protein_g / p.current_body_weight_kg, 2)
  END AS protein_per_kg,
  -- Training metrics from same day
  tds.total_sets,
  tds.working_sets,
  tds.total_volume_kg,
  tds.avg_rpe,
  tds.duration_minutes,
  tds.best_estimated_1rm
FROM nutrition_logs n
JOIN profiles p ON p.id = n.user_id
JOIN training_day_summary tds
  ON tds.user_id = n.user_id
  AND tds.training_date = n.logged_date;

COMMENT ON VIEW nutrition_training_correlation IS
  'Joins daily nutrition with training summaries. RLS via security_invoker. '
  'Only includes days with both nutrition and training data.';

COMMIT;
