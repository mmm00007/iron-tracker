-- Migration 074: Training Recommendations Engine
-- Composes muscle_fatigue_state + volume_landmarks + weekly_muscle_effective_sets
-- + training_phases into per-muscle "train/prioritize/rest/avoid" recommendations
-- with rationale. Powers the home-screen coaching cards.
--
-- Validated by: fitness-domain-expert, data-science-expert
--
-- Key design decisions:
--   - Single function returns all muscle recommendations in one call (cheap for UI)
--   - Phase-aware: deload suppresses any 'prioritize', peaking only prioritizes primary movers
--   - Fatigue takes precedence over landmarks (overreaching always → rest)
--   - Requires fatigue snapshot + landmarks + weekly sets; degrades gracefully if missing
--
-- Citations:
--   - Helms E. et al. (2019). Muscle and Strength Pyramid — volume landmark coaching.
--   - Israetel M. et al. (2021). RP autoregulation logic.
--   - Bompa & Buzzichelli (2019). Periodization — phase-specific volume targets.

BEGIN;

-- =============================================================================
-- get_training_recommendations(user_id, as_of_date)
-- =============================================================================
-- Returns one row per muscle group with a recommendation + rationale.
-- Intended for dashboard: surfaces top 3-5 'prioritize' muscles + any 'avoid'
-- warnings.

CREATE OR REPLACE FUNCTION get_training_recommendations(
  p_user_id uuid,
  p_as_of_date date DEFAULT CURRENT_DATE
)
RETURNS TABLE (
  muscle_group_id integer,
  muscle_name text,
  recommendation text,
  priority smallint,
  rationale text,
  current_fatigue_score numeric(4,1),
  recovery_status text,
  current_weekly_effective_sets numeric(5,1),
  mev_sets_per_week smallint,
  mav_sets_per_week smallint,
  mrv_sets_per_week smallint,
  deficit_to_mav numeric(5,1),
  days_since_last_trained smallint,
  phase_adjusted boolean
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public, pg_catalog
AS $$
DECLARE
  v_user_goal text;
  v_active_phase_type text;
BEGIN
  SELECT primary_goal INTO v_user_goal FROM profiles WHERE id = p_user_id;
  v_user_goal := COALESCE(v_user_goal, 'general');

  SELECT phase_type INTO v_active_phase_type
  FROM training_phases
  WHERE user_id = p_user_id AND end_date IS NULL
  ORDER BY start_date DESC LIMIT 1;

  RETURN QUERY
  WITH fatigue AS (
    SELECT mfs.muscle_group_id, mfs.fatigue_score, mfs.recovery_status, mfs.days_since_last_trained
    FROM muscle_fatigue_state mfs
    WHERE mfs.user_id = p_user_id AND mfs.as_of_date = p_as_of_date
  ),
  weekly_sets AS (
    SELECT wmes.muscle_group_id, wmes.effective_sets
    FROM weekly_muscle_effective_sets wmes
    WHERE wmes.user_id = p_user_id
      AND wmes.week_start = date_trunc('week', p_as_of_date)::date
  ),
  landmarks AS (
    SELECT vl.muscle_group_id, vl.mev_sets_per_week, vl.mav_sets_per_week, vl.mrv_sets_per_week
    FROM volume_landmarks vl
    WHERE vl.user_id = p_user_id AND vl.training_goal = v_user_goal
  ),
  combined AS (
    SELECT
      mg.id                                      AS muscle_group_id,
      mg.name                                    AS muscle_name,
      COALESCE(f.fatigue_score, 0)               AS fatigue,
      COALESCE(f.recovery_status, 'no_data')     AS recovery,
      COALESCE(ws.effective_sets, 0)::numeric(5,1) AS weekly_sets,
      COALESCE(l.mev_sets_per_week, 8)::smallint AS mev,
      COALESCE(l.mav_sets_per_week, 14)::smallint AS mav,
      COALESCE(l.mrv_sets_per_week, 20)::smallint AS mrv,
      f.days_since_last_trained
    FROM muscle_groups mg
    LEFT JOIN fatigue f      ON f.muscle_group_id = mg.id
    LEFT JOIN weekly_sets ws ON ws.muscle_group_id = mg.id
    LEFT JOIN landmarks l    ON l.muscle_group_id = mg.id
  ),
  scored AS (
    SELECT
      c.muscle_group_id, c.muscle_name, c.fatigue, c.recovery, c.weekly_sets,
      c.mev, c.mav, c.mrv, c.days_since_last_trained,
      -- Base recommendation from fatigue first, then landmarks
      CASE
        WHEN c.fatigue >= 80        THEN 'rest'
        WHEN c.fatigue >= 60        THEN 'avoid'
        WHEN c.weekly_sets > c.mrv  THEN 'rest'
        WHEN c.fatigue >= 40        THEN 'train'
        WHEN c.weekly_sets < c.mev  THEN 'prioritize'
        WHEN c.weekly_sets < c.mav  THEN 'train'
        ELSE                             'train'
      END AS base_rec,
      (c.mav - c.weekly_sets)::numeric(5,1) AS deficit
    FROM combined c
  ),
  phase_adjusted AS (
    SELECT
      s.*,
      -- Phase adjustments
      CASE
        -- Deload: nothing 'prioritize', cap at 'train' only if not overreaching
        WHEN v_active_phase_type = 'deload' AND s.base_rec = 'prioritize'  THEN 'train'
        WHEN v_active_phase_type = 'deload' AND s.base_rec = 'train' AND s.fatigue >= 40 THEN 'rest'
        -- Active recovery: similar to deload but more conservative
        WHEN v_active_phase_type = 'active_recovery' AND s.base_rec IN ('prioritize','train') AND s.fatigue > 20 THEN 'rest'
        -- Maintenance: never prioritize
        WHEN v_active_phase_type = 'maintenance' AND s.base_rec = 'prioritize' THEN 'train'
        -- Otherwise keep base rec
        ELSE s.base_rec
      END AS final_rec,
      v_active_phase_type IS NOT NULL AS did_phase_adjust
    FROM scored s
  )
  SELECT
    pa.muscle_group_id,
    pa.muscle_name,
    pa.final_rec,
    -- Priority 1 = highest display priority
    (CASE pa.final_rec
      WHEN 'prioritize' THEN 1
      WHEN 'train'      THEN 2
      WHEN 'avoid'      THEN 3
      WHEN 'rest'       THEN 4
      ELSE                    5
    END)::smallint,
    CASE pa.final_rec
      WHEN 'prioritize' THEN
        format('Only %s of %s weekly sets — below MEV. Add volume this session.',
               pa.weekly_sets, pa.mev)
      WHEN 'train' THEN
        CASE
          WHEN pa.weekly_sets >= pa.mav THEN
            format('At %s sets (MAV %s-%s). Productive training continues.',
                   pa.weekly_sets, pa.mev, pa.mav)
          WHEN pa.fatigue >= 40 THEN
            format('Recovering (%s). Moderate volume OK this session.', pa.recovery)
          ELSE
            format('%s/%s weekly sets — in productive range.', pa.weekly_sets, pa.mav)
        END
      WHEN 'avoid' THEN
        format('Fatigued (score %s). Skip heavy work; light mobility or rest.', pa.fatigue)
      WHEN 'rest' THEN
        CASE
          WHEN pa.fatigue >= 80 THEN
            format('Overreaching (score %s). Full rest 1-2 days.', pa.fatigue)
          WHEN pa.weekly_sets > pa.mrv THEN
            format('Above MRV (%s > %s). Recovery week needed.', pa.weekly_sets, pa.mrv)
          WHEN v_active_phase_type = 'deload' THEN
            'Deload phase — minimize volume.'
          ELSE
            'Recovery needed.'
        END
    END,
    pa.fatigue::numeric(4,1),
    pa.recovery,
    pa.weekly_sets,
    pa.mev, pa.mav, pa.mrv,
    pa.deficit,
    pa.days_since_last_trained::smallint,
    pa.did_phase_adjust
  FROM phase_adjusted pa
  ORDER BY
    CASE pa.final_rec
      WHEN 'prioritize' THEN 1
      WHEN 'train'      THEN 2
      WHEN 'avoid'      THEN 3
      WHEN 'rest'       THEN 4
      ELSE                    5
    END,
    pa.deficit DESC NULLS LAST,
    pa.muscle_name;
END;
$$;

COMMENT ON FUNCTION get_training_recommendations(uuid, date) IS
  'Per-muscle training recommendations composing muscle_fatigue_state + '
  'volume_landmarks + weekly_muscle_effective_sets + active training_phase. '
  'Returns priority-sorted list: prioritize / train / avoid / rest with rationale.';

-- =============================================================================
-- Convenience: top training priorities view
-- =============================================================================
-- The frontend queries this for the home-screen "train these today" card.

CREATE OR REPLACE FUNCTION get_top_training_priorities(
  p_user_id uuid,
  p_limit integer DEFAULT 5
)
RETURNS TABLE (
  muscle_group_id integer,
  muscle_name text,
  recommendation text,
  rationale text,
  deficit_to_mav numeric(5,1)
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, pg_catalog
AS $$
  SELECT
    r.muscle_group_id,
    r.muscle_name,
    r.recommendation,
    r.rationale,
    r.deficit_to_mav
  FROM get_training_recommendations(p_user_id, CURRENT_DATE) r
  WHERE r.recommendation IN ('prioritize','train')
  ORDER BY r.priority, r.deficit_to_mav DESC NULLS LAST
  LIMIT p_limit;
$$;

COMMENT ON FUNCTION get_top_training_priorities(uuid, integer) IS
  'Top N muscle groups to train today. Filters rest/avoid. Ordered by priority '
  'then deficit_to_mav. Used by home-screen coaching cards.';

COMMIT;
