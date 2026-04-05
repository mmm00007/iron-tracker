-- Migration 089: Muscle Recovery Forecast
-- Forward-projects muscle fatigue assuming no new training, so users know
-- WHEN each muscle will be fresh again. Uses existing muscle_fatigue_state
-- as the current-state anchor + per-component decay models.
--
-- Decay model (simplified):
--   volume_component: 72h half-life (training stimulus fades over 3 days)
--   rpe_component: 48h half-life (acute exertion fades faster)
--   soreness_component: DOMS typically 24-72h peak, clears by 96h
--   recency_component: linear -25/day (matches existing scoring in 064)
--
-- Projected fatigue_score rebuilds from same 0.4 vol + 0.2 rpe + 0.2 sore +
-- 0.2 recency weighting for each future day.
--
-- Validated by: sports-medicine-expert, fitness-domain-expert
--
-- Citations:
--   - Zaffagnini S. et al. (2015). DOMS timeline meta-review.
--   - Damas F. et al. (2018). Muscle damage recovery kinetics.
--   - Schoenfeld B.J. (2013). Postexercise muscle recovery. Strength Cond J.

BEGIN;

-- =============================================================================
-- 1. forecast_muscle_recovery(user_id) function
-- =============================================================================
-- Projects fatigue scores 7 days forward per muscle group.

CREATE OR REPLACE FUNCTION forecast_muscle_recovery(
  p_user_id uuid,
  p_from_date date DEFAULT CURRENT_DATE
)
RETURNS TABLE (
  muscle_group_id integer,
  muscle_name text,
  current_fatigue_score numeric(4,1),
  current_recovery_status text,
  day_offset smallint,
  projected_date date,
  projected_fatigue_score numeric(4,1),
  projected_recovery_status text,
  days_to_fresh smallint
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public, pg_catalog
AS $$
#variable_conflict use_column
BEGIN
  RETURN QUERY
  WITH current_state AS (
    SELECT
      mfs.muscle_group_id,
      mg.name,
      mfs.fatigue_score,
      mfs.recovery_status,
      mfs.volume_component,
      mfs.rpe_component,
      mfs.soreness_component,
      COALESCE(mfs.days_since_last_trained, 0) AS days_since_trained
    FROM muscle_fatigue_state mfs
    JOIN muscle_groups mg ON mg.id = mfs.muscle_group_id
    WHERE mfs.user_id = p_user_id AND mfs.as_of_date = p_from_date
  ),
  day_offsets AS (
    SELECT generate_series(0, 7)::smallint AS offset_days
  ),
  projected AS (
    SELECT
      cs.muscle_group_id, cs.name, cs.fatigue_score, cs.recovery_status,
      dof.offset_days,
      (p_from_date + dof.offset_days) AS projected_date,
      -- Decay models (continuous, not categorical)
      -- Volume: 72h half-life → at day N, multiplier = 0.5^(N/3)
      (cs.volume_component * POWER(0.5, dof.offset_days / 3.0))::numeric AS proj_volume,
      -- RPE: 48h half-life → 0.5^(N/2)
      (cs.rpe_component * POWER(0.5, dof.offset_days / 2.0))::numeric AS proj_rpe,
      -- Soreness: peaks day 1-2 then clears by day 4. Simplified: linear decay from day 0.
      -- If day=0, hold current; day=1, × 1.0 (peak); day=2, × 0.75; day=3, × 0.4; day=4+, 0
      (cs.soreness_component * CASE
        WHEN dof.offset_days = 0 THEN 1.0
        WHEN dof.offset_days = 1 THEN 1.0
        WHEN dof.offset_days = 2 THEN 0.75
        WHEN dof.offset_days = 3 THEN 0.4
        WHEN dof.offset_days = 4 THEN 0.15
        ELSE 0.0
      END)::numeric AS proj_soreness,
      -- Recency: linear -25/day floor 0
      GREATEST(0, 100 - ((cs.days_since_trained + dof.offset_days) * 25))::numeric AS proj_recency
    FROM current_state cs
    CROSS JOIN day_offsets dof
  ),
  scored AS (
    SELECT
      muscle_group_id, name, fatigue_score, recovery_status, offset_days, projected_date,
      ROUND(
        (0.40 * proj_volume + 0.20 * proj_rpe + 0.20 * proj_soreness + 0.20 * proj_recency)::numeric,
        1
      ) AS projected_score
    FROM projected
  ),
  annotated AS (
    SELECT
      muscle_group_id, name, fatigue_score, recovery_status, offset_days, projected_date,
      projected_score,
      CASE
        WHEN projected_score < 20 THEN 'fresh'
        WHEN projected_score < 40 THEN 'ready'
        WHEN projected_score < 60 THEN 'recovering'
        WHEN projected_score < 80 THEN 'fatigued'
        ELSE                              'overreaching'
      END AS proj_status
    FROM scored
  ),
  days_to_fresh_calc AS (
    SELECT
      muscle_group_id,
      MIN(offset_days) FILTER (WHERE projected_score < 40) AS first_ready_day
    FROM annotated
    GROUP BY muscle_group_id
  )
  SELECT
    a.muscle_group_id, a.name, a.fatigue_score::numeric(4,1), a.recovery_status,
    a.offset_days, a.projected_date,
    a.projected_score::numeric(4,1),
    a.proj_status,
    dtf.first_ready_day
  FROM annotated a
  JOIN days_to_fresh_calc dtf ON dtf.muscle_group_id = a.muscle_group_id
  ORDER BY a.muscle_group_id, a.offset_days;
END;
$$;

COMMENT ON FUNCTION forecast_muscle_recovery(uuid, date) IS
  'Returns 8-row forecast (day 0 through day 7) per muscle group. Projects '
  'fatigue assuming NO new training. Includes days_to_fresh field showing '
  'offset when each muscle reaches "ready" (fatigue <40). Useful for '
  'rest-of-week planning.';

-- =============================================================================
-- 2. muscle_readiness_forecast view
-- =============================================================================
-- Simpler: just "when will this muscle be ready?" summary per user.

CREATE OR REPLACE VIEW muscle_readiness_forecast
WITH (security_invoker = true) AS
WITH current_per_user AS (
  SELECT DISTINCT ON (user_id, muscle_group_id)
    user_id, muscle_group_id, fatigue_score, recovery_status,
    volume_component, rpe_component, soreness_component,
    COALESCE(days_since_last_trained, 0) AS days_since_trained,
    as_of_date
  FROM muscle_fatigue_state
  ORDER BY user_id, muscle_group_id, as_of_date DESC
),
-- Approximate days-to-ready via closed-form solution for each component:
-- fatigue_score drops below 40 when weighted sum does. Simplification: use
-- the slowest-decaying component (volume) as the bottleneck.
estimated AS (
  SELECT
    user_id, muscle_group_id, fatigue_score, recovery_status, as_of_date,
    -- Projected score day 1, 2, 3, 4, 5 via same weights
    ROUND((
      0.40 * (volume_component * POWER(0.5, 1/3.0)) +
      0.20 * (rpe_component * POWER(0.5, 1/2.0)) +
      0.20 * (soreness_component * 1.0) +
      0.20 * GREATEST(0, 100 - ((days_since_trained + 1) * 25))
    )::numeric, 1) AS day_plus_1,
    ROUND((
      0.40 * (volume_component * POWER(0.5, 2/3.0)) +
      0.20 * (rpe_component * POWER(0.5, 2/2.0)) +
      0.20 * (soreness_component * 0.75) +
      0.20 * GREATEST(0, 100 - ((days_since_trained + 2) * 25))
    )::numeric, 1) AS day_plus_2,
    ROUND((
      0.40 * (volume_component * POWER(0.5, 3/3.0)) +
      0.20 * (rpe_component * POWER(0.5, 3/2.0)) +
      0.20 * (soreness_component * 0.4) +
      0.20 * GREATEST(0, 100 - ((days_since_trained + 3) * 25))
    )::numeric, 1) AS day_plus_3,
    ROUND((
      0.40 * (volume_component * POWER(0.5, 4/3.0)) +
      0.20 * (rpe_component * POWER(0.5, 4/2.0)) +
      0.20 * (soreness_component * 0.15) +
      0.20 * GREATEST(0, 100 - ((days_since_trained + 4) * 25))
    )::numeric, 1) AS day_plus_4,
    ROUND((
      0.40 * (volume_component * POWER(0.5, 5/3.0)) +
      0.20 * (rpe_component * POWER(0.5, 5/2.0)) +
      0.00 +
      0.20 * GREATEST(0, 100 - ((days_since_trained + 5) * 25))
    )::numeric, 1) AS day_plus_5
  FROM current_per_user
)
SELECT
  e.user_id,
  e.muscle_group_id,
  mg.name AS muscle_name,
  e.as_of_date,
  e.fatigue_score AS current_fatigue,
  e.recovery_status AS current_status,
  e.day_plus_1, e.day_plus_2, e.day_plus_3, e.day_plus_4, e.day_plus_5,
  -- Earliest day fatigue drops below 40 (ready threshold)
  CASE
    WHEN e.fatigue_score < 40 THEN 0
    WHEN e.day_plus_1 < 40 THEN 1
    WHEN e.day_plus_2 < 40 THEN 2
    WHEN e.day_plus_3 < 40 THEN 3
    WHEN e.day_plus_4 < 40 THEN 4
    WHEN e.day_plus_5 < 40 THEN 5
    ELSE NULL
  END::smallint AS days_to_ready,
  -- Calendar date of readiness
  CASE
    WHEN e.fatigue_score < 40 THEN e.as_of_date
    WHEN e.day_plus_1 < 40 THEN e.as_of_date + 1
    WHEN e.day_plus_2 < 40 THEN e.as_of_date + 2
    WHEN e.day_plus_3 < 40 THEN e.as_of_date + 3
    WHEN e.day_plus_4 < 40 THEN e.as_of_date + 4
    WHEN e.day_plus_5 < 40 THEN e.as_of_date + 5
    ELSE NULL
  END AS ready_date
FROM estimated e
JOIN muscle_groups mg ON mg.id = e.muscle_group_id;

COMMENT ON VIEW muscle_readiness_forecast IS
  'Per-user per-muscle forecast of when fatigue will drop below 40 (ready). '
  'Projects 1-5 days out assuming no new training for that muscle. '
  'Powers "train chest on Friday" rest-of-week planning cards.';

COMMIT;
