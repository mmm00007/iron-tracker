-- Migration 061: Structured Tempo + ROM + Form Quality (per-set)
-- Extends sets with structured tempo breakdown (eccentric/pause/concentric/pause),
-- ROM quality classification, and per-set form quality self-assessment.
--
-- The existing `tempo` text column (e.g., "3-1-2-0") is preserved for legacy
-- and free-form logging. The new structured columns enable analytics:
--   - Time Under Tension (TUT) = (ecc + pb + con + pt) * reps
--   - Eccentric emphasis ratio = eccentric_seconds / concentric_seconds
--   - ROM-quality-adjusted volume (partial reps count less toward MAV)
--
-- Validated by: fitness-domain-expert, data-science-expert, database-specialist
--
-- Key design decisions:
--   - Kept text `tempo` column — users can log "3-1-2" freely; analytics use structured
--   - rom_quality distinct from exercise-level movement_plane — this is PER-SET execution
--   - form_quality is self-assessment (1-5), distinct from rpe (effort) and rir (proximity to failure)
--   - Grip/stance REJECTED at set-level per migration 029 (variant-level attributes)
--   - All new columns nullable — backward compatible, no data migration needed
--
-- Citations:
--   - Schoenfeld B.J., Ogborn D., Krieger J.W. (2015). Effect of repetition duration
--     during resistance training on muscle hypertrophy. Sports Medicine.
--   - Wilk M., Golas A. et al. (2020). Impact of different tempo on repetitions.
--     Applied Physiology.
--   - Pareja-Blanco F. et al. (2017). Effects of velocity loss during resistance training.
--     Scand J Med Sci Sports.
--   - Bird S.P. et al. (2005). Designing resistance training programmes — tempo. Sports Med.

BEGIN;

-- =============================================================================
-- 1. STRUCTURED TEMPO BREAKDOWN
-- =============================================================================
-- Tempo convention: eccentric-pause_bottom-concentric-pause_top (e.g., 3-1-2-0).
-- All nullable: users fill what they track. 0.5 second precision.

ALTER TABLE sets
  ADD COLUMN IF NOT EXISTS eccentric_seconds      numeric(4,1)
    CHECK (eccentric_seconds >= 0 AND eccentric_seconds <= 60),
  ADD COLUMN IF NOT EXISTS pause_bottom_seconds   numeric(4,1)
    CHECK (pause_bottom_seconds >= 0 AND pause_bottom_seconds <= 60),
  ADD COLUMN IF NOT EXISTS concentric_seconds     numeric(4,1)
    CHECK (concentric_seconds >= 0 AND concentric_seconds <= 60),
  ADD COLUMN IF NOT EXISTS pause_top_seconds      numeric(4,1)
    CHECK (pause_top_seconds >= 0 AND pause_top_seconds <= 60);

COMMENT ON COLUMN sets.eccentric_seconds IS
  'Seconds per eccentric (lowering) phase. Tempo notation: 1st digit of "3-1-2-0".';

COMMENT ON COLUMN sets.pause_bottom_seconds IS
  'Pause at the bottom of the rep. Tempo notation: 2nd digit. Dead-bottom pauses typical for pause squat/bench.';

COMMENT ON COLUMN sets.concentric_seconds IS
  'Seconds per concentric (lifting) phase. Tempo notation: 3rd digit. "X" (explosive) stored as 0.5 by convention.';

COMMENT ON COLUMN sets.pause_top_seconds IS
  'Pause at the top / lockout. Tempo notation: 4th digit.';

-- =============================================================================
-- 2. ROM QUALITY (per-set execution classification)
-- =============================================================================
-- Per-SET classification of range of motion actually executed. Distinct from
-- exercise-level safe_rom_limits; this is what the lifter actually performed.

ALTER TABLE sets
  ADD COLUMN IF NOT EXISTS rom_quality text
    CHECK (rom_quality IN (
      'full',              -- Complete range of motion, bottom to top
      'partial_top',       -- Half rep, top range only (lockout work)
      'partial_bottom',    -- Half rep, bottom range only (depth work)
      'partial_middle',    -- Middle range only (uncommon; bench boards)
      'pause',             -- Full ROM with intentional pause at hardest point
      'lockout_only',      -- Top-end isometric or quarter rep
      'quarter',           -- 25% ROM
      'half',              -- 50% ROM
      'three_quarter',     -- 75% ROM
      'lengthened_partial' -- Stretch-mediated partials (Ottinger/Beardsley 2023)
    ));

COMMENT ON COLUMN sets.rom_quality IS
  'Per-set ROM classification. NULL = full (default assumption). '
  'lengthened_partial: recent hypertrophy research (Ottinger 2023) showing advantage of stretch-biased partials.';

-- =============================================================================
-- 3. FORM QUALITY (per-set self-assessment)
-- =============================================================================

ALTER TABLE sets
  ADD COLUMN IF NOT EXISTS form_quality smallint
    CHECK (form_quality BETWEEN 1 AND 5);

COMMENT ON COLUMN sets.form_quality IS
  'User self-assessment of form quality for this set (1=poor, 3=acceptable, 5=pristine). '
  'Distinct from RPE (effort) and RIR (proximity to failure). Used to flag low-quality '
  'volume in analytics and surface form cues in coaching.';

-- =============================================================================
-- 4. GENERATED: TUT (Time Under Tension) per set
-- =============================================================================
-- Computed when all 4 tempo columns provided. Useful for hypertrophy analytics
-- (Schoenfeld 2015: 40-60s/set TUT is the "sweet spot" for hypertrophy).

ALTER TABLE sets
  ADD COLUMN IF NOT EXISTS tut_seconds numeric(5,1)
    GENERATED ALWAYS AS (
      CASE
        WHEN eccentric_seconds IS NOT NULL
         AND pause_bottom_seconds IS NOT NULL
         AND concentric_seconds IS NOT NULL
         AND pause_top_seconds IS NOT NULL
         AND reps > 0
        THEN ROUND(
          (eccentric_seconds + pause_bottom_seconds + concentric_seconds + pause_top_seconds)
          * reps::numeric, 1
        )
        ELSE NULL
      END
    ) STORED;

COMMENT ON COLUMN sets.tut_seconds IS
  'Total Time Under Tension for this set. Generated column: (ecc+pb+con+pt)*reps. '
  'NULL if any tempo component not provided. Target 40-60s/set for hypertrophy (Schoenfeld 2015).';

-- =============================================================================
-- 5. INDEXES
-- =============================================================================
-- Only index when values present — most sets will not have structured tempo.

CREATE INDEX IF NOT EXISTS sets_tut_idx
  ON sets (user_id, exercise_id, training_date DESC)
  WHERE tut_seconds IS NOT NULL;

CREATE INDEX IF NOT EXISTS sets_rom_quality_idx
  ON sets (user_id, rom_quality, training_date DESC)
  WHERE rom_quality IS NOT NULL AND rom_quality != 'full';

COMMIT;
