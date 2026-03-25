-- Migration 034: Streak Milestones Function
-- Adds a service_role function to detect and persist training consistency
-- streak milestones using the existing training_milestones table.
--
-- Validated by: fitness-domain-expert agent
--
-- Threshold rationale (exercise science evidence):
--   2w  — First commitment signal; predicts habit formation (Lally et al., 2010)
--   4w  — Neural adaptations complete; initial strength plateau (Sale, 1988)
--   8w  — Hypertrophy first detectable at 6-8 weeks (Schoenfeld et al., 2017)
--   12w — Standard mesocycle; ACSM "regular exerciser" threshold
--   24w — Beginner → intermediate transition; connective tissue catches up
--         (Kubo et al., 2010; Rippetoe, Practical Programming)
--   36w — Linear progression typically exhausted; periodization becomes
--         necessary (Baker et al., 1994)
--   52w — Full year of consistent training; major adherence milestone
--         (Sperandei et al., 2016: ~50% dropout before 6 months)

BEGIN;

-- =============================================================================
-- 1. FUNCTION: compute_streak_milestones
-- =============================================================================

-- Reads current_streak_weeks from training_consistency_metrics view and
-- writes milestone records to training_milestones at evidence-based thresholds.
-- Idempotent: uses ON CONFLICT DO NOTHING to avoid duplicates.
-- Called by backend cron after computing consistency metrics.
CREATE OR REPLACE FUNCTION compute_streak_milestones(p_user_id uuid)
RETURNS void AS $$
DECLARE
  v_current_streak integer;
  v_thresholds integer[] := ARRAY[2, 4, 8, 12, 24, 36, 52];
  v_threshold integer;
BEGIN
  -- Get current streak from the consistency metrics view
  SELECT current_streak_weeks INTO v_current_streak
  FROM training_consistency_metrics
  WHERE user_id = p_user_id;

  -- No data or no streak
  IF v_current_streak IS NULL OR v_current_streak < 2 THEN
    RETURN;
  END IF;

  -- Check each milestone threshold and insert if achieved
  FOREACH v_threshold IN ARRAY v_thresholds LOOP
    IF v_current_streak >= v_threshold THEN
      -- Use INSERT ... ON CONFLICT to ensure idempotency.
      -- The training_milestones table has a partial unique index on
      -- (user_id, milestone_type) from migration 023.
      INSERT INTO training_milestones (
        user_id, milestone_type, value, unit, achieved_at, notes
      )
      VALUES (
        p_user_id,
        'streak_' || v_threshold || 'w',
        v_threshold,
        'weeks',
        now(),
        CASE v_threshold
          WHEN 2  THEN 'First streak: 2 consecutive on-target weeks'
          WHEN 4  THEN 'Neural adaptation milestone: 4 weeks consistent'
          WHEN 8  THEN 'Hypertrophy threshold: 8 weeks consistent'
          WHEN 12 THEN 'Regular exerciser: 12-week mesocycle completed'
          WHEN 24 THEN 'Intermediate transition: 6 months consistent'
          WHEN 36 THEN 'Advanced programming milestone: 9 months consistent'
          WHEN 52 THEN 'Iron year: 52 weeks of consistent training'
        END
      )
      ON CONFLICT DO NOTHING;
    END IF;
  END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Restrict to service_role only (called by backend cron)
REVOKE EXECUTE ON FUNCTION compute_streak_milestones(uuid) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION compute_streak_milestones(uuid) FROM authenticated;
GRANT EXECUTE ON FUNCTION compute_streak_milestones(uuid) TO service_role;

COMMENT ON FUNCTION compute_streak_milestones IS
  'Detects and persists training consistency streak milestones at evidence-based '
  'thresholds (2/4/8/12/24/36/52 weeks). Reads from training_consistency_metrics '
  'view, writes to training_milestones table. Idempotent. Service role only.';

COMMIT;
