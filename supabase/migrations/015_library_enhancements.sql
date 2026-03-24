-- Migration 015: Library data model enhancements
-- Adds fields from design docs + gym-tracker richness for exercises, machines, gyms

-- =========================================================================
-- exercises: richer exercise data
-- =========================================================================
ALTER TABLE exercises
  ADD COLUMN IF NOT EXISTS source_id       text,
  ADD COLUMN IF NOT EXISTS movement_pattern text CHECK (movement_pattern IN (
    'squat', 'hip_hinge', 'lunge', 'horizontal_push', 'vertical_push',
    'horizontal_pull', 'vertical_pull', 'carry', 'rotation', 'isolation', 'other'
  )),
  ADD COLUMN IF NOT EXISTS variations      text[]   DEFAULT '{}',
  ADD COLUMN IF NOT EXISTS default_weight  numeric  DEFAULT 0,
  ADD COLUMN IF NOT EXISTS default_reps    integer  DEFAULT 10,
  ADD COLUMN IF NOT EXISTS video_url       text,
  ADD COLUMN IF NOT EXISTS notes           text;

-- =========================================================================
-- exercise_muscles: activation percentage for heatmap intensity
-- =========================================================================
ALTER TABLE exercise_muscles
  ADD COLUMN IF NOT EXISTS activation_percent smallint CHECK (
    activation_percent IS NULL OR (activation_percent >= 0 AND activation_percent <= 100)
  );

-- =========================================================================
-- equipment_variants: default variant + weight range
-- =========================================================================
ALTER TABLE equipment_variants
  ADD COLUMN IF NOT EXISTS is_default       boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS weight_range_min numeric,
  ADD COLUMN IF NOT EXISTS weight_range_max numeric;

-- Only one default variant per user per exercise
CREATE UNIQUE INDEX IF NOT EXISTS equipment_variants_default_idx
  ON equipment_variants (user_id, exercise_id)
  WHERE is_default = true;

-- =========================================================================
-- gym_machines: model, weight unit, seat labels, location
-- =========================================================================
ALTER TABLE gym_machines
  ADD COLUMN IF NOT EXISTS model                   text,
  ADD COLUMN IF NOT EXISTS weight_unit             text NOT NULL DEFAULT 'kg'
                                                   CHECK (weight_unit IN ('kg', 'lb')),
  ADD COLUMN IF NOT EXISTS seat_adjustment_labels  text[] DEFAULT '{}',
  ADD COLUMN IF NOT EXISTS location_hint           text,
  ADD COLUMN IF NOT EXISTS updated_at              timestamptz NOT NULL DEFAULT now();

-- =========================================================================
-- gyms: slug + country
-- =========================================================================
ALTER TABLE gyms
  ADD COLUMN IF NOT EXISTS slug         text UNIQUE,
  ADD COLUMN IF NOT EXISTS country_code text DEFAULT 'US';
