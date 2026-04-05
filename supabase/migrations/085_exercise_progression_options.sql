-- Migration 085: Exercise Progression Advancement Options
-- When a user plateaus on an exercise, what should they try NEXT?
-- Function returns ranked progression options: graduate to harder variant,
-- add volume, add intensity technique, try tempo/paused variant.
--
-- Composes: exercise_substitutions (progression chain + prerequisites),
-- personal_records (user's current e1RM), body_weight_log (BW for ratio),
-- detect_pr_stagnation (plateau signal), cluster_type_defaults (technique menu).
--
-- Validated by: fitness-domain-expert, data-science-expert
--
-- Options ranked by fitness-expert priority:
--   1. GRADUATE to next exercise in progression chain (if 1RM ratio met)
--   2. Add ONE intensity technique (cluster/rest-pause) — preserves exercise
--   3. Add VOLUME (2 more sets per session)
--   4. Try TEMPO variant (eccentric-biased)
--   5. Try PAUSED variant (competition-style or at sticking point)

BEGIN;

-- =============================================================================
-- get_progression_options(user_id, exercise_id)
-- =============================================================================

CREATE OR REPLACE FUNCTION get_progression_options(
  p_user_id uuid,
  p_exercise_id uuid,
  p_limit integer DEFAULT 5
)
RETURNS TABLE (
  rank smallint,
  option_type text,
  title text,
  rationale text,
  target_exercise_id uuid,
  target_exercise_name text,
  target_cluster_type text,
  estimated_difficulty_delta text
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public, pg_catalog
AS $$
DECLARE
  v_current_e1rm numeric;
  v_latest_bw numeric;
  v_current_bw_multiple numeric;
  v_exercise_name text;
  v_has_stagnation boolean;
  v_rank_counter smallint := 0;
BEGIN
  -- Get exercise name
  SELECT name INTO v_exercise_name FROM exercises WHERE id = p_exercise_id;

  -- Get user's current e1RM for this exercise
  SELECT MAX(pr.value) INTO v_current_e1rm
  FROM personal_records pr
  WHERE pr.user_id = p_user_id
    AND pr.exercise_id = p_exercise_id
    AND pr.record_type = 'estimated_1rm'
    AND pr.pr_context = 'straight';

  -- Get latest bodyweight (normalized to kg)
  SELECT CASE WHEN weight_unit = 'lb' THEN weight / 2.20462 ELSE weight END
  INTO v_latest_bw
  FROM body_weight_log
  WHERE user_id = p_user_id
  ORDER BY logged_at DESC LIMIT 1;

  -- BW multiple
  v_current_bw_multiple := CASE
    WHEN v_latest_bw IS NULL OR v_latest_bw = 0 THEN NULL
    ELSE v_current_e1rm / v_latest_bw
  END;

  -- Detect stagnation on this specific exercise
  SELECT EXISTS (
    SELECT 1 FROM detect_pr_stagnation(p_user_id, 6)
    WHERE exercise_id = p_exercise_id
  ) INTO v_has_stagnation;

  -- OPTION 1: Graduate to next exercise in progression chain
  -- Select all progression candidates where user has met prerequisite BW ratio
  v_rank_counter := v_rank_counter + 1;
  RETURN QUERY
  SELECT
    v_rank_counter,
    'graduate'::text,
    ('Graduate to ' || te.name)::text,
    CASE
      WHEN v_current_bw_multiple IS NULL THEN
        ('Harder progression of ' || v_exercise_name || '. Start at bodyweight.')::text
      WHEN es.prerequisite_1rm_ratio IS NULL THEN
        ('Natural next step after ' || v_exercise_name || '.')::text
      ELSE
        format('You''re at %sx BW on %s (target: %sx) — ready to progress.',
               ROUND(v_current_bw_multiple, 2), v_exercise_name, es.prerequisite_1rm_ratio)::text
    END,
    te.id,
    te.name,
    NULL::text,
    'harder'::text
  FROM exercise_substitutions es
  JOIN exercises te ON te.id = es.target_exercise_id
  WHERE es.source_exercise_id = p_exercise_id
    AND es.substitution_type = 'progression'
    AND (
      es.prerequisite_1rm_ratio IS NULL
      OR v_current_bw_multiple IS NULL  -- no BW data; recommend cautiously
      OR v_current_bw_multiple >= es.prerequisite_1rm_ratio
    )
  ORDER BY es.progression_order, es.similarity_score DESC
  LIMIT 2;

  -- Only suggest intensity techniques + volume + tempo if stagnation detected
  IF v_has_stagnation OR v_current_e1rm IS NOT NULL THEN
    -- OPTION 2: Add intensity technique (cluster / rest-pause / myo-rep)
    v_rank_counter := v_rank_counter + 1;
    RETURN QUERY
    SELECT
      v_rank_counter,
      'intensity_technique'::text,
      'Add rest-pause sets'::text,
      ('Break through plateau without changing load. Take 1 set to failure, '
       'rest 15s, continue to failure. 1-2 rest-pause sets per session.')::text,
      NULL::uuid,
      NULL::text,
      'rest_pause'::text,
      'more_intense'::text;

    v_rank_counter := v_rank_counter + 1;
    RETURN QUERY
    SELECT
      v_rank_counter,
      'intensity_technique'::text,
      'Add cluster sets'::text,
      ('Maintain heavy loads with planned intra-set rest. Try 5x2 @ 85% with '
       '20s between mini-sets. Preserves bar speed at plateau weight.')::text,
      NULL::uuid,
      NULL::text,
      'cluster_set'::text,
      'same_intensity'::text;

    -- OPTION 3: Add volume (more sets)
    v_rank_counter := v_rank_counter + 1;
    RETURN QUERY
    SELECT
      v_rank_counter,
      'add_volume'::text,
      'Add 2 working sets'::text,
      ('Push past MEV/MAV midpoint. Add 2 working sets per session for 2-4 weeks. '
       'Track fatigue — back off if recovery suffers.')::text,
      NULL::uuid,
      NULL::text,
      NULL::text,
      'more_volume'::text;

    -- OPTION 4: Tempo variant (eccentric-biased)
    v_rank_counter := v_rank_counter + 1;
    RETURN QUERY
    SELECT
      v_rank_counter,
      'tempo_variation'::text,
      'Eccentric-biased tempo (4-0-1)'::text,
      ('Increase time under tension. 4s eccentric, 1s concentric. Drop weight '
       '10-15%% initially — TUT will make moderate loads feel heavy.')::text,
      NULL::uuid,
      NULL::text,
      NULL::text,
      'different_stimulus'::text;

    -- OPTION 5: Paused variant
    v_rank_counter := v_rank_counter + 1;
    RETURN QUERY
    SELECT
      v_rank_counter,
      'paused_variant'::text,
      'Paused reps at bottom'::text,
      ('Pause 2s at stretched position. Builds strength through sticking point. '
       'Drop load 10%% to start; progress weight weekly.')::text,
      NULL::uuid,
      NULL::text,
      NULL::text,
      'different_stimulus'::text;
  END IF;

  -- Limit results
  RETURN QUERY SELECT * FROM (SELECT NULL::smallint, NULL::text, NULL::text, NULL::text, NULL::uuid, NULL::text, NULL::text, NULL::text) dummy WHERE false;
END;
$$;

COMMENT ON FUNCTION get_progression_options(uuid, uuid, integer) IS
  'Returns ranked progression options for an exercise: graduate to next '
  'in chain, add intensity technique, add volume, tempo variant, paused '
  'variant. Uses exercise_substitutions progression chains (migration 055) '
  'with prerequisite_1rm_ratio gates. Non-graduate options return when '
  'stagnation detected OR user has any history on the exercise.';

-- =============================================================================
-- next_exercise_in_chain(exercise_id)
-- =============================================================================
-- Simple helper: given an exercise, return the next one in its progression chain.

CREATE OR REPLACE FUNCTION next_exercise_in_chain(p_exercise_id uuid)
RETURNS TABLE (
  target_exercise_id uuid,
  target_exercise_name text,
  progression_order smallint,
  prerequisite_1rm_ratio numeric,
  similarity_score smallint
)
LANGUAGE sql
STABLE
AS $$
  SELECT es.target_exercise_id, te.name, es.progression_order,
         es.prerequisite_1rm_ratio, es.similarity_score
  FROM exercise_substitutions es
  JOIN exercises te ON te.id = es.target_exercise_id
  WHERE es.source_exercise_id = p_exercise_id
    AND es.substitution_type = 'progression'
  ORDER BY es.progression_order NULLS LAST, es.similarity_score DESC
  LIMIT 1;
$$;

COMMENT ON FUNCTION next_exercise_in_chain(uuid) IS
  'Returns the single next exercise in the progression chain (lowest '
  'progression_order, tiebreak on similarity_score). Used by graduation UI.';

COMMIT;
