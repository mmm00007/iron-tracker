-- Migration 066: Biomechanics Seed Data for Common Exercises
-- Populates skill_ceiling, fatigue_cost, cns_demand, energy_system,
-- typical_rep_range, and common_form_errors for ~50 of the most frequently
-- used exercises. Also populates exercise_joint_stress for compounds where
-- joint loading is clinically significant.
--
-- Matches by normalized name (lower + trim) to handle seed variations.
-- Skips if already populated (uses WHERE col IS NULL guards).
--
-- Validated by: fitness-domain-expert, sports-medicine-expert
--
-- Value conventions:
--   skill_ceiling: 1=no skill (machine), 5=elite technical (snatch)
--   fatigue_cost: 1=very low (cable lateral), 5=very high (heavy deadlift)
--   cns_demand: 1=low, 5=max-effort/1RM/power
--   energy_system: alactic (<10s, power), lactic (30s-2min), mixed

BEGIN;

-- =============================================================================
-- TIER 1: Big compound barbell lifts (skill=4-5, fatigue=4-5, CNS=4-5)
-- =============================================================================

UPDATE exercises SET
  skill_ceiling = 5, fatigue_cost = 5, cns_demand = 5,
  energy_system = 'alactic',
  typical_rep_range_min = 1, typical_rep_range_max = 8,
  common_form_errors = ARRAY['butt wink at depth','knees cave inward','heels lift','forward collapse','chest drops']
WHERE lower(name) IN ('barbell squat', 'barbell back squat', 'back squat', 'high bar squat', 'low bar squat')
  AND (skill_ceiling IS NULL OR fatigue_cost IS NULL);

UPDATE exercises SET
  skill_ceiling = 5, fatigue_cost = 5, cns_demand = 5,
  energy_system = 'alactic',
  typical_rep_range_min = 1, typical_rep_range_max = 6,
  common_form_errors = ARRAY['rounded lumbar spine','hips shoot up first','bar drifts away from body','jerky lockout','hyperextension at top']
WHERE lower(name) IN ('barbell deadlift', 'deadlift', 'conventional deadlift', 'sumo deadlift')
  AND (skill_ceiling IS NULL OR fatigue_cost IS NULL);

UPDATE exercises SET
  skill_ceiling = 4, fatigue_cost = 4, cns_demand = 4,
  energy_system = 'alactic',
  typical_rep_range_min = 3, typical_rep_range_max = 10,
  common_form_errors = ARRAY['elbows flare','bar path drifts','scapula unretracted','feet off floor','arched lower back excessive']
WHERE lower(name) IN ('barbell bench press', 'bench press', 'flat barbell bench press', 'flat bench press')
  AND (skill_ceiling IS NULL OR fatigue_cost IS NULL);

UPDATE exercises SET
  skill_ceiling = 4, fatigue_cost = 4, cns_demand = 4,
  energy_system = 'alactic',
  typical_rep_range_min = 3, typical_rep_range_max = 10,
  common_form_errors = ARRAY['lumbar hyperextension','elbows forward at lockout','head protraction','bar path not vertical','incomplete lockout']
WHERE lower(name) IN ('overhead press', 'barbell overhead press', 'standing overhead press', 'military press', 'strict press')
  AND (skill_ceiling IS NULL OR fatigue_cost IS NULL);

UPDATE exercises SET
  skill_ceiling = 4, fatigue_cost = 4, cns_demand = 3,
  energy_system = 'lactic',
  typical_rep_range_min = 5, typical_rep_range_max = 12,
  common_form_errors = ARRAY['lumbar extension with jerking','bar rides up toward chest','elbows flare','insufficient torso angle','scapula not retracted']
WHERE lower(name) IN ('barbell row', 'bent-over row', 'bent over row', 'pendlay row', 'bent-over barbell row')
  AND (skill_ceiling IS NULL OR fatigue_cost IS NULL);

UPDATE exercises SET
  skill_ceiling = 5, fatigue_cost = 5, cns_demand = 5,
  energy_system = 'alactic',
  typical_rep_range_min = 1, typical_rep_range_max = 6,
  common_form_errors = ARRAY['elbows drop below bar','knees collapse inward','excessive forward lean','bar drifts forward','incomplete rack position']
WHERE lower(name) IN ('front squat', 'barbell front squat', 'clean-grip front squat')
  AND (skill_ceiling IS NULL OR fatigue_cost IS NULL);

UPDATE exercises SET
  skill_ceiling = 4, fatigue_cost = 4, cns_demand = 3,
  energy_system = 'lactic',
  typical_rep_range_min = 5, typical_rep_range_max = 12,
  common_form_errors = ARRAY['excessive knee flexion','lumbar rounds at depth','bar drifts forward','hip hinge insufficient','hyperextension at lockout']
WHERE lower(name) IN ('romanian deadlift', 'rdl', 'barbell romanian deadlift', 'stiff-leg deadlift', 'stiff-legged deadlift')
  AND (skill_ceiling IS NULL OR fatigue_cost IS NULL);

-- =============================================================================
-- TIER 2: Olympic & power movements (skill=5, CNS=5, alactic)
-- =============================================================================

UPDATE exercises SET
  skill_ceiling = 5, fatigue_cost = 4, cns_demand = 5,
  energy_system = 'alactic',
  typical_rep_range_min = 1, typical_rep_range_max = 5,
  common_form_errors = ARRAY['early arm bend','bar swings away from body','insufficient triple extension','knees forward at catch','slow transition']
WHERE lower(name) IN ('power clean', 'clean', 'squat clean', 'hang clean', 'hang power clean')
  AND (skill_ceiling IS NULL OR fatigue_cost IS NULL);

UPDATE exercises SET
  skill_ceiling = 5, fatigue_cost = 4, cns_demand = 5,
  energy_system = 'alactic',
  typical_rep_range_min = 1, typical_rep_range_max = 3,
  common_form_errors = ARRAY['pulling with arms early','bar path far from body','press-out at overhead','incomplete overhead lockout','no hip drive']
WHERE lower(name) IN ('snatch', 'power snatch', 'squat snatch', 'hang snatch')
  AND (skill_ceiling IS NULL OR fatigue_cost IS NULL);

UPDATE exercises SET
  skill_ceiling = 4, fatigue_cost = 4, cns_demand = 4,
  energy_system = 'alactic',
  typical_rep_range_min = 3, typical_rep_range_max = 6,
  common_form_errors = ARRAY['dip is too shallow or too deep','knees travel forward','chest collapses','insufficient leg drive','slow reset']
WHERE lower(name) IN ('push press', 'barbell push press')
  AND (skill_ceiling IS NULL OR fatigue_cost IS NULL);

-- =============================================================================
-- TIER 3: Popular compounds (skill=2-3, fatigue=3-4)
-- =============================================================================

UPDATE exercises SET
  skill_ceiling = 3, fatigue_cost = 3, cns_demand = 3,
  energy_system = 'mixed',
  typical_rep_range_min = 5, typical_rep_range_max = 12,
  common_form_errors = ARRAY['bench angle too steep','elbows flare','scapula not retracted','bar travels toward face','legs disengage']
WHERE lower(name) IN ('incline bench press', 'incline barbell bench press', 'incline barbell press')
  AND (skill_ceiling IS NULL OR fatigue_cost IS NULL);

UPDATE exercises SET
  skill_ceiling = 3, fatigue_cost = 3, cns_demand = 2,
  energy_system = 'lactic',
  typical_rep_range_min = 6, typical_rep_range_max = 15,
  common_form_errors = ARRAY['partial depth','trunk rotation','front knee caves inward','back heel lifts','hip hike']
WHERE lower(name) IN ('bulgarian split squat', 'rear foot elevated split squat', 'bss')
  AND (skill_ceiling IS NULL OR fatigue_cost IS NULL);

UPDATE exercises SET
  skill_ceiling = 2, fatigue_cost = 4, cns_demand = 3,
  energy_system = 'lactic',
  typical_rep_range_min = 6, typical_rep_range_max = 15,
  common_form_errors = ARRAY['lumbar hyperextension at top','feet too wide','chin tucks','incomplete hip extension','bench too high or low']
WHERE lower(name) IN ('hip thrust', 'barbell hip thrust', 'glute bridge')
  AND (skill_ceiling IS NULL OR fatigue_cost IS NULL);

UPDATE exercises SET
  skill_ceiling = 3, fatigue_cost = 3, cns_demand = 2,
  energy_system = 'lactic',
  typical_rep_range_min = 4, typical_rep_range_max = 12,
  common_form_errors = ARRAY['kipping or swinging','partial ROM at top','shrug instead of retracting','elbows flare forward','dead hang skipped']
WHERE lower(name) IN ('pull-up', 'pull up', 'pullup', 'wide-grip pull-up')
  AND (skill_ceiling IS NULL OR fatigue_cost IS NULL);

UPDATE exercises SET
  skill_ceiling = 3, fatigue_cost = 3, cns_demand = 2,
  energy_system = 'lactic',
  typical_rep_range_min = 4, typical_rep_range_max = 12,
  common_form_errors = ARRAY['partial ROM','kipping','chin doesn''t clear bar','shoulders shrug instead of depress','elbows out too wide']
WHERE lower(name) IN ('chin-up', 'chin up', 'chinup', 'underhand pull-up')
  AND (skill_ceiling IS NULL OR fatigue_cost IS NULL);

UPDATE exercises SET
  skill_ceiling = 3, fatigue_cost = 3, cns_demand = 2,
  energy_system = 'lactic',
  typical_rep_range_min = 5, typical_rep_range_max = 15,
  common_form_errors = ARRAY['excessive forward lean','partial depth','elbows flare','shoulders shrug','swinging']
WHERE lower(name) IN ('dip', 'dips', 'parallel bar dip', 'tricep dip')
  AND (skill_ceiling IS NULL OR fatigue_cost IS NULL);

UPDATE exercises SET
  skill_ceiling = 2, fatigue_cost = 2, cns_demand = 1,
  energy_system = 'lactic',
  typical_rep_range_min = 8, typical_rep_range_max = 25,
  common_form_errors = ARRAY['hip sag','elbows flare','partial ROM','head drops','hip piking']
WHERE lower(name) IN ('push-up', 'push up', 'pushup', 'standard push-up')
  AND (skill_ceiling IS NULL OR fatigue_cost IS NULL);

UPDATE exercises SET
  skill_ceiling = 2, fatigue_cost = 4, cns_demand = 3,
  energy_system = 'lactic',
  typical_rep_range_min = 8, typical_rep_range_max = 20,
  common_form_errors = ARRAY['partial ROM','feet too wide or narrow','lumbar rounds at depth','knees cave','hips shift forward']
WHERE lower(name) IN ('leg press', '45-degree leg press', 'horizontal leg press')
  AND (skill_ceiling IS NULL OR fatigue_cost IS NULL);

UPDATE exercises SET
  skill_ceiling = 2, fatigue_cost = 3, cns_demand = 2,
  energy_system = 'mixed',
  typical_rep_range_min = 6, typical_rep_range_max = 15,
  common_form_errors = ARRAY['excessive weight causing trunk rotation','short ROM','shoulder elevated','elbows flared','hips offset']
WHERE lower(name) IN ('walking lunge', 'dumbbell walking lunge')
  AND (skill_ceiling IS NULL OR fatigue_cost IS NULL);

-- =============================================================================
-- TIER 4: Machine / Isolation (skill=1-2, fatigue=1-2)
-- =============================================================================

UPDATE exercises SET
  skill_ceiling = 1, fatigue_cost = 2, cns_demand = 1,
  energy_system = 'lactic',
  typical_rep_range_min = 8, typical_rep_range_max = 20,
  common_form_errors = ARRAY['momentum / using body to swing','short ROM','elbows flare','shoulders elevated','bar hits chin area']
WHERE lower(name) IN ('lat pulldown', 'cable lat pulldown', 'wide-grip lat pulldown')
  AND (skill_ceiling IS NULL OR fatigue_cost IS NULL);

UPDATE exercises SET
  skill_ceiling = 1, fatigue_cost = 2, cns_demand = 1,
  energy_system = 'lactic',
  typical_rep_range_min = 8, typical_rep_range_max = 20,
  common_form_errors = ARRAY['excessive trunk lean','elbows flare out','rounded shoulders','jerking with hips','short ROM']
WHERE lower(name) IN ('seated cable row', 'cable row', 'seated row')
  AND (skill_ceiling IS NULL OR fatigue_cost IS NULL);

UPDATE exercises SET
  skill_ceiling = 1, fatigue_cost = 1, cns_demand = 1,
  energy_system = 'lactic',
  typical_rep_range_min = 8, typical_rep_range_max = 15,
  common_form_errors = ARRAY['hip flexion to assist','swinging torso','knee lock at top','partial ROM']
WHERE lower(name) IN ('leg extension', 'seated leg extension', 'machine leg extension')
  AND (skill_ceiling IS NULL OR fatigue_cost IS NULL);

UPDATE exercises SET
  skill_ceiling = 1, fatigue_cost = 1, cns_demand = 1,
  energy_system = 'lactic',
  typical_rep_range_min = 8, typical_rep_range_max = 15,
  common_form_errors = ARRAY['hips lift off pad','short ROM','jerky contraction','incomplete range']
WHERE lower(name) IN ('leg curl', 'lying leg curl', 'seated leg curl', 'prone leg curl')
  AND (skill_ceiling IS NULL OR fatigue_cost IS NULL);

UPDATE exercises SET
  skill_ceiling = 1, fatigue_cost = 1, cns_demand = 1,
  energy_system = 'lactic',
  typical_rep_range_min = 10, typical_rep_range_max = 20,
  common_form_errors = ARRAY['momentum swing','shoulders shrug','trapezius dominates','elbows rotate forward','wrist bent']
WHERE lower(name) IN ('lateral raise', 'dumbbell lateral raise', 'cable lateral raise', 'side lateral raise')
  AND (skill_ceiling IS NULL OR fatigue_cost IS NULL);

UPDATE exercises SET
  skill_ceiling = 1, fatigue_cost = 1, cns_demand = 1,
  energy_system = 'lactic',
  typical_rep_range_min = 10, typical_rep_range_max = 20,
  common_form_errors = ARRAY['elbows drop','using traps','momentum','incomplete squeeze','grip too narrow']
WHERE lower(name) IN ('face pull', 'cable face pull', 'rope face pull')
  AND (skill_ceiling IS NULL OR fatigue_cost IS NULL);

UPDATE exercises SET
  skill_ceiling = 2, fatigue_cost = 2, cns_demand = 1,
  energy_system = 'lactic',
  typical_rep_range_min = 6, typical_rep_range_max = 15,
  common_form_errors = ARRAY['swinging torso','elbows flare','shoulders roll forward','incomplete supination','partial ROM']
WHERE lower(name) IN ('barbell curl', 'ez-bar curl', 'bicep curl', 'standing barbell curl')
  AND (skill_ceiling IS NULL OR fatigue_cost IS NULL);

UPDATE exercises SET
  skill_ceiling = 1, fatigue_cost = 1, cns_demand = 1,
  energy_system = 'lactic',
  typical_rep_range_min = 10, typical_rep_range_max = 20,
  common_form_errors = ARRAY['elbows drift forward','body leans into movement','using shoulders','partial ROM','grip too narrow']
WHERE lower(name) IN ('tricep pushdown', 'cable tricep pushdown', 'rope pushdown')
  AND (skill_ceiling IS NULL OR fatigue_cost IS NULL);

UPDATE exercises SET
  skill_ceiling = 1, fatigue_cost = 1, cns_demand = 1,
  energy_system = 'lactic',
  typical_rep_range_min = 10, typical_rep_range_max = 25,
  common_form_errors = ARRAY['bouncing at bottom','partial ROM','quick contraction','body english','incomplete stretch']
WHERE lower(name) IN ('standing calf raise', 'calf raise', 'seated calf raise', 'donkey calf raise')
  AND (skill_ceiling IS NULL OR fatigue_cost IS NULL);

-- =============================================================================
-- exercise_joint_stress: Top 10 compound movements
-- =============================================================================
-- Uses CTE to find matching exercises by name and joins to seed joint stress.
-- Skips if exercise name not found (no-ops safely).

WITH squat_ids AS (
  SELECT id FROM exercises WHERE lower(name) IN ('barbell squat', 'back squat', 'barbell back squat', 'high bar squat', 'low bar squat')
)
INSERT INTO exercise_joint_stress (exercise_id, joint, stress_level, stress_type, notes)
SELECT id, joint, stress_level, stress_type, notes
FROM squat_ids,
     (VALUES
       ('lumbar_spine'::text, 3::smallint, 'compression'::text, 'Heavy axial load through spine'),
       ('lumbar_spine'::text, 2::smallint, 'shear'::text, 'Forward lean tendency creates shear'),
       ('knee'::text, 3::smallint, 'compression'::text, 'Patellofemoral stress at deep flexion'),
       ('hip'::text, 3::smallint, 'compression'::text, 'Primary load path through hip'),
       ('ankle'::text, 2::smallint, 'compression'::text, 'Dorsiflexion demand at depth')
     ) AS jstress(joint, stress_level, stress_type, notes)
ON CONFLICT (exercise_id, joint, stress_type) DO NOTHING;

WITH deadlift_ids AS (
  SELECT id FROM exercises WHERE lower(name) IN ('deadlift', 'barbell deadlift', 'conventional deadlift', 'sumo deadlift')
)
INSERT INTO exercise_joint_stress (exercise_id, joint, stress_level, stress_type, notes)
SELECT id, joint, stress_level, stress_type, notes
FROM deadlift_ids,
     (VALUES
       ('lumbar_spine'::text, 3::smallint, 'compression'::text, 'High spinal compression at heavy loads'),
       ('lumbar_spine'::text, 3::smallint, 'shear'::text, 'Hip hinge creates significant shear forces'),
       ('hip'::text, 3::smallint, 'tension'::text, 'Posterior chain tension at bottom'),
       ('knee'::text, 1::smallint, 'compression'::text, 'Minimal compared to squat'),
       ('sacroiliac'::text, 2::smallint, 'shear'::text, 'SI joint load under heavy hip hinge')
     ) AS jstress(joint, stress_level, stress_type, notes)
ON CONFLICT (exercise_id, joint, stress_type) DO NOTHING;

WITH bench_ids AS (
  SELECT id FROM exercises WHERE lower(name) IN ('bench press', 'barbell bench press', 'flat bench press')
)
INSERT INTO exercise_joint_stress (exercise_id, joint, stress_level, stress_type, notes)
SELECT id, joint, stress_level, stress_type, notes
FROM bench_ids,
     (VALUES
       ('shoulder'::text, 3::smallint, 'compression'::text, 'Subacromial compression at bottom'),
       ('shoulder'::text, 2::smallint, 'shear'::text, 'Anterior translation under load'),
       ('elbow'::text, 2::smallint, 'compression'::text, 'Load through distal arm'),
       ('wrist'::text, 1::smallint, 'compression'::text, 'Bar path forces wrist extension')
     ) AS jstress(joint, stress_level, stress_type, notes)
ON CONFLICT (exercise_id, joint, stress_type) DO NOTHING;

WITH ohp_ids AS (
  SELECT id FROM exercises WHERE lower(name) IN ('overhead press', 'barbell overhead press', 'military press', 'strict press', 'standing overhead press')
)
INSERT INTO exercise_joint_stress (exercise_id, joint, stress_level, stress_type, notes)
SELECT id, joint, stress_level, stress_type, notes
FROM ohp_ids,
     (VALUES
       ('shoulder'::text, 3::smallint, 'compression'::text, 'Overhead subacromial load'),
       ('elbow'::text, 2::smallint, 'compression'::text, 'Vertical axial load'),
       ('lumbar_spine'::text, 2::smallint, 'compression'::text, 'Extension tendency under load'),
       ('wrist'::text, 2::smallint, 'compression'::text, 'Rack position load')
     ) AS jstress(joint, stress_level, stress_type, notes)
ON CONFLICT (exercise_id, joint, stress_type) DO NOTHING;

WITH front_squat_ids AS (
  SELECT id FROM exercises WHERE lower(name) IN ('front squat', 'barbell front squat')
)
INSERT INTO exercise_joint_stress (exercise_id, joint, stress_level, stress_type, notes)
SELECT id, joint, stress_level, stress_type, notes
FROM front_squat_ids,
     (VALUES
       ('knee'::text, 3::smallint, 'compression'::text, 'More anterior knee stress than back squat'),
       ('lumbar_spine'::text, 2::smallint, 'compression'::text, 'Upright torso reduces shear'),
       ('hip'::text, 2::smallint, 'compression'::text, 'Less hip hinge than back squat'),
       ('wrist'::text, 2::smallint, 'tension'::text, 'Rack position wrist extension'),
       ('elbow'::text, 2::smallint, 'compression'::text, 'Rack position elbow flexion')
     ) AS jstress(joint, stress_level, stress_type, notes)
ON CONFLICT (exercise_id, joint, stress_type) DO NOTHING;

WITH rdl_ids AS (
  SELECT id FROM exercises WHERE lower(name) IN ('romanian deadlift', 'rdl', 'barbell romanian deadlift')
)
INSERT INTO exercise_joint_stress (exercise_id, joint, stress_level, stress_type, notes)
SELECT id, joint, stress_level, stress_type, notes
FROM rdl_ids,
     (VALUES
       ('lumbar_spine'::text, 2::smallint, 'shear'::text, 'Hip hinge pattern'),
       ('hip'::text, 3::smallint, 'tension'::text, 'Primary target — posterior chain stretch'),
       ('knee'::text, 1::smallint, 'compression'::text, 'Minimal, soft-knee position'),
       ('sacroiliac'::text, 2::smallint, 'shear'::text, 'SI joint loads during hinge')
     ) AS jstress(joint, stress_level, stress_type, notes)
ON CONFLICT (exercise_id, joint, stress_type) DO NOTHING;

WITH hip_thrust_ids AS (
  SELECT id FROM exercises WHERE lower(name) IN ('hip thrust', 'barbell hip thrust')
)
INSERT INTO exercise_joint_stress (exercise_id, joint, stress_level, stress_type, notes)
SELECT id, joint, stress_level, stress_type, notes
FROM hip_thrust_ids,
     (VALUES
       ('hip'::text, 3::smallint, 'compression'::text, 'Bar loading over hip crease'),
       ('lumbar_spine'::text, 2::smallint, 'compression'::text, 'Hyperextension risk'),
       ('knee'::text, 1::smallint, 'compression'::text, 'Minimal')
     ) AS jstress(joint, stress_level, stress_type, notes)
ON CONFLICT (exercise_id, joint, stress_type) DO NOTHING;

WITH lunge_ids AS (
  SELECT id FROM exercises WHERE lower(name) IN ('walking lunge', 'dumbbell walking lunge', 'lunge', 'reverse lunge', 'bulgarian split squat')
)
INSERT INTO exercise_joint_stress (exercise_id, joint, stress_level, stress_type, notes)
SELECT id, joint, stress_level, stress_type, notes
FROM lunge_ids,
     (VALUES
       ('knee'::text, 2::smallint, 'compression'::text, 'Front knee loaded under BW+'),
       ('hip'::text, 2::smallint, 'compression'::text, 'Rear hip extension'),
       ('ankle'::text, 2::smallint, 'compression'::text, 'Front ankle dorsiflexion')
     ) AS jstress(joint, stress_level, stress_type, notes)
ON CONFLICT (exercise_id, joint, stress_type) DO NOTHING;

WITH row_ids AS (
  SELECT id FROM exercises WHERE lower(name) IN ('barbell row', 'bent-over row', 'pendlay row', 'bent over row')
)
INSERT INTO exercise_joint_stress (exercise_id, joint, stress_level, stress_type, notes)
SELECT id, joint, stress_level, stress_type, notes
FROM row_ids,
     (VALUES
       ('lumbar_spine'::text, 2::smallint, 'compression'::text, 'Isometric hold under load'),
       ('lumbar_spine'::text, 2::smallint, 'shear'::text, 'Forward-lean shear demand'),
       ('shoulder'::text, 1::smallint, 'tension'::text, 'Retraction at top'),
       ('elbow'::text, 1::smallint, 'compression'::text, 'Minor')
     ) AS jstress(joint, stress_level, stress_type, notes)
ON CONFLICT (exercise_id, joint, stress_type) DO NOTHING;

WITH clean_ids AS (
  SELECT id FROM exercises WHERE lower(name) IN ('power clean', 'clean', 'squat clean', 'hang clean')
)
INSERT INTO exercise_joint_stress (exercise_id, joint, stress_level, stress_type, notes)
SELECT id, joint, stress_level, stress_type, notes
FROM clean_ids,
     (VALUES
       ('lumbar_spine'::text, 2::smallint, 'compression'::text, 'Pull phase axial load'),
       ('lumbar_spine'::text, 2::smallint, 'shear'::text, 'Hip hinge shear'),
       ('shoulder'::text, 2::smallint, 'impact'::text, 'Catch position impact'),
       ('wrist'::text, 2::smallint, 'tension'::text, 'Rack catch hyperextension'),
       ('knee'::text, 2::smallint, 'compression'::text, 'Catch position'),
       ('hip'::text, 3::smallint, 'compression'::text, 'Triple extension load')
     ) AS jstress(joint, stress_level, stress_type, notes)
ON CONFLICT (exercise_id, joint, stress_type) DO NOTHING;

COMMIT;
