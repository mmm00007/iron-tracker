-- Migration 070: Biomechanics Seed Expansion
-- Extends biomechanics coverage (skill_ceiling, fatigue_cost, cns_demand,
-- energy_system, typical_rep_range, common_form_errors) from the ~30
-- exercises seeded in migration 066 to another ~40 common movements:
--   - Machine press/row/squat variants (low skill, low-to-mid fatigue)
--   - Cable isolation (low skill, low fatigue)
--   - Olympic lift accessories (high skill, high fatigue)
--   - Pressing/pulling variants (close-grip, decline, sumo, trap bar)
--   - Core/ab work
--   - Lower-body accessories (single-leg, good morning, hyperextension)
--
-- Also adds exercise_joint_stress for 8 more compound movements.
-- Validated by: fitness-domain-expert, sports-medicine-expert

BEGIN;

-- =============================================================================
-- MACHINE VARIANTS (skill=1-2, fatigue=2-3)
-- =============================================================================

UPDATE exercises SET
  skill_ceiling = 1, fatigue_cost = 2, cns_demand = 2,
  energy_system = 'lactic',
  typical_rep_range_min = 6, typical_rep_range_max = 15,
  common_form_errors = ARRAY['shoulders shrug','seat too high or low','elbows flare','back rounds','incomplete ROM']
WHERE lower(name) IN ('machine chest press','chest press machine','hammer strength chest press')
  AND (skill_ceiling IS NULL OR fatigue_cost IS NULL);

UPDATE exercises SET
  skill_ceiling = 1, fatigue_cost = 2, cns_demand = 2,
  energy_system = 'lactic',
  typical_rep_range_min = 6, typical_rep_range_max = 15,
  common_form_errors = ARRAY['lumbar hyperextension','incomplete lockout','shoulders shrug','head juts forward']
WHERE lower(name) IN ('machine shoulder press','shoulder press machine','seated machine shoulder press')
  AND (skill_ceiling IS NULL OR fatigue_cost IS NULL);

UPDATE exercises SET
  skill_ceiling = 1, fatigue_cost = 2, cns_demand = 2,
  energy_system = 'lactic',
  typical_rep_range_min = 8, typical_rep_range_max = 15,
  common_form_errors = ARRAY['trunk lean to swing weight','elbows flare','shoulders shrug','partial ROM','chest not against pad']
WHERE lower(name) IN ('machine row','t-bar row','chest-supported row','hammer strength row')
  AND (skill_ceiling IS NULL OR fatigue_cost IS NULL);

UPDATE exercises SET
  skill_ceiling = 2, fatigue_cost = 3, cns_demand = 2,
  energy_system = 'lactic',
  typical_rep_range_min = 6, typical_rep_range_max = 15,
  common_form_errors = ARRAY['knees cave inward','partial depth','hips off pad','feet too high or low','back rounds']
WHERE lower(name) IN ('hack squat','machine hack squat','45-degree hack squat')
  AND (skill_ceiling IS NULL OR fatigue_cost IS NULL);

UPDATE exercises SET
  skill_ceiling = 1, fatigue_cost = 1, cns_demand = 1,
  energy_system = 'lactic',
  typical_rep_range_min = 10, typical_rep_range_max = 20,
  common_form_errors = ARRAY['shoulders shrug','momentum','partial ROM','elbows not against pads','torso leans']
WHERE lower(name) IN ('pec deck','machine fly','butterfly','pec deck machine')
  AND (skill_ceiling IS NULL OR fatigue_cost IS NULL);

UPDATE exercises SET
  skill_ceiling = 1, fatigue_cost = 1, cns_demand = 1,
  energy_system = 'lactic',
  typical_rep_range_min = 12, typical_rep_range_max = 25,
  common_form_errors = ARRAY['bouncing at bottom','partial ROM','too fast tempo','incomplete stretch']
WHERE lower(name) IN ('seated calf raise','seated calf raise machine')
  AND (skill_ceiling IS NULL OR fatigue_cost IS NULL);

-- =============================================================================
-- CABLE ISOLATION (skill=1, fatigue=1)
-- =============================================================================

UPDATE exercises SET
  skill_ceiling = 1, fatigue_cost = 1, cns_demand = 1,
  energy_system = 'lactic',
  typical_rep_range_min = 10, typical_rep_range_max = 20,
  common_form_errors = ARRAY['trunk rotation','elbows lock out','shoulders roll forward','incomplete stretch','momentum']
WHERE lower(name) IN ('cable fly','cable chest fly','standing cable fly','cable crossover','high-to-low cable fly')
  AND (skill_ceiling IS NULL OR fatigue_cost IS NULL);

UPDATE exercises SET
  skill_ceiling = 1, fatigue_cost = 1, cns_demand = 1,
  energy_system = 'lactic',
  typical_rep_range_min = 12, typical_rep_range_max = 20,
  common_form_errors = ARRAY['traps shrug','elbows drive back','torso sways','partial ROM']
WHERE lower(name) IN ('cable rear delt fly','reverse cable fly','cable reverse fly')
  AND (skill_ceiling IS NULL OR fatigue_cost IS NULL);

UPDATE exercises SET
  skill_ceiling = 1, fatigue_cost = 1, cns_demand = 1,
  energy_system = 'lactic',
  typical_rep_range_min = 10, typical_rep_range_max = 20,
  common_form_errors = ARRAY['elbow drifts','shoulder extension','torso rotation','partial ROM','using body english']
WHERE lower(name) IN ('cable kickback','tricep kickback','cable tricep kickback','dumbbell kickback')
  AND (skill_ceiling IS NULL OR fatigue_cost IS NULL);

UPDATE exercises SET
  skill_ceiling = 2, fatigue_cost = 1, cns_demand = 1,
  energy_system = 'lactic',
  typical_rep_range_min = 8, typical_rep_range_max = 15,
  common_form_errors = ARRAY['shoulders roll forward','elbows lift off pad','incomplete ROM','wrist extended','momentum']
WHERE lower(name) IN ('preacher curl','ez-bar preacher curl','barbell preacher curl','dumbbell preacher curl')
  AND (skill_ceiling IS NULL OR fatigue_cost IS NULL);

UPDATE exercises SET
  skill_ceiling = 1, fatigue_cost = 1, cns_demand = 1,
  energy_system = 'lactic',
  typical_rep_range_min = 8, typical_rep_range_max = 15,
  common_form_errors = ARRAY['swinging body','elbows drift','shoulders shrug','partial ROM','wrist deviation']
WHERE lower(name) IN ('hammer curl','dumbbell hammer curl','cable hammer curl','rope hammer curl')
  AND (skill_ceiling IS NULL OR fatigue_cost IS NULL);

-- =============================================================================
-- CORE / AB WORK (skill=1-2, fatigue=1-2)
-- =============================================================================

UPDATE exercises SET
  skill_ceiling = 1, fatigue_cost = 1, cns_demand = 1,
  energy_system = 'lactic',
  typical_rep_range_min = 10, typical_rep_range_max = 25,
  common_form_errors = ARRAY['hip flexion dominant','incomplete spinal flexion','pulling with neck','momentum','hips leave the floor']
WHERE lower(name) IN ('cable crunch','kneeling cable crunch','rope crunch')
  AND (skill_ceiling IS NULL OR fatigue_cost IS NULL);

UPDATE exercises SET
  skill_ceiling = 2, fatigue_cost = 2, cns_demand = 1,
  energy_system = 'lactic',
  typical_rep_range_min = 8, typical_rep_range_max = 15,
  common_form_errors = ARRAY['swinging','hip flexion only','momentum','incomplete range','shoulders shrug']
WHERE lower(name) IN ('hanging leg raise','hanging knee raise','captain chair leg raise')
  AND (skill_ceiling IS NULL OR fatigue_cost IS NULL);

UPDATE exercises SET
  skill_ceiling = 3, fatigue_cost = 2, cns_demand = 2,
  energy_system = 'lactic',
  typical_rep_range_min = 5, typical_rep_range_max = 15,
  common_form_errors = ARRAY['lumbar sag','hip pike','rolling too far','shoulders shrug','head drops']
WHERE lower(name) IN ('ab wheel rollout','ab rollout','wheel rollout','standing ab rollout')
  AND (skill_ceiling IS NULL OR fatigue_cost IS NULL);

UPDATE exercises SET
  skill_ceiling = 2, fatigue_cost = 2, cns_demand = 1,
  energy_system = 'lactic',
  typical_rep_range_min = 30, typical_rep_range_max = 90,
  common_form_errors = ARRAY['arms do the work','hips open','feet lift','partial rotation','leaning back too much']
WHERE lower(name) IN ('russian twist','seated russian twist','weighted russian twist')
  AND (skill_ceiling IS NULL OR fatigue_cost IS NULL);

UPDATE exercises SET
  skill_ceiling = 2, fatigue_cost = 2, cns_demand = 1,
  energy_system = 'lactic',
  typical_rep_range_min = 20, typical_rep_range_max = 120,
  common_form_errors = ARRAY['hip sag','hip pike','head drops','shoulder shrugs','holding breath']
WHERE lower(name) IN ('plank','front plank','forearm plank','standard plank')
  AND (skill_ceiling IS NULL OR fatigue_cost IS NULL);

-- =============================================================================
-- PRESS/PULL VARIANTS (skill=3-4, fatigue=3-4)
-- =============================================================================

UPDATE exercises SET
  skill_ceiling = 3, fatigue_cost = 4, cns_demand = 4,
  energy_system = 'alactic',
  typical_rep_range_min = 3, typical_rep_range_max = 8,
  common_form_errors = ARRAY['elbows flare','wrists collapse','shoulder internal rotation','partial lockout','bar path not vertical']
WHERE lower(name) IN ('close-grip bench press','close grip bench press','narrow grip bench press')
  AND (skill_ceiling IS NULL OR fatigue_cost IS NULL);

UPDATE exercises SET
  skill_ceiling = 3, fatigue_cost = 4, cns_demand = 4,
  energy_system = 'alactic',
  typical_rep_range_min = 3, typical_rep_range_max = 10,
  common_form_errors = ARRAY['bench angle too steep','incomplete ROM','elbows flare','excessive arch','feet slip']
WHERE lower(name) IN ('decline bench press','decline barbell bench press','decline press')
  AND (skill_ceiling IS NULL OR fatigue_cost IS NULL);

UPDATE exercises SET
  skill_ceiling = 5, fatigue_cost = 5, cns_demand = 5,
  energy_system = 'alactic',
  typical_rep_range_min = 1, typical_rep_range_max = 6,
  common_form_errors = ARRAY['knees cave inward','hips shoot up','bar drifts forward','not hinging properly','lockout incomplete']
WHERE lower(name) IN ('sumo deadlift','sumo barbell deadlift','wide-stance deadlift')
  AND (skill_ceiling IS NULL OR fatigue_cost IS NULL);

UPDATE exercises SET
  skill_ceiling = 3, fatigue_cost = 5, cns_demand = 4,
  energy_system = 'alactic',
  typical_rep_range_min = 3, typical_rep_range_max = 8,
  common_form_errors = ARRAY['excessive forward lean','knees cave','bar drifts','lockout jerky','incomplete hip extension']
WHERE lower(name) IN ('trap bar deadlift','trap-bar deadlift','hex bar deadlift')
  AND (skill_ceiling IS NULL OR fatigue_cost IS NULL);

-- =============================================================================
-- LOWER BODY ACCESSORIES (skill=2-4, fatigue=2-3)
-- =============================================================================

UPDATE exercises SET
  skill_ceiling = 4, fatigue_cost = 3, cns_demand = 2,
  energy_system = 'mixed',
  typical_rep_range_min = 6, typical_rep_range_max = 15,
  common_form_errors = ARRAY['balance issues','knee tracks over toe','insufficient hip hinge','lumbar rounds','ankle rolls']
WHERE lower(name) IN ('single-leg rdl','single leg romanian deadlift','one-leg rdl')
  AND (skill_ceiling IS NULL OR fatigue_cost IS NULL);

UPDATE exercises SET
  skill_ceiling = 3, fatigue_cost = 3, cns_demand = 2,
  energy_system = 'lactic',
  typical_rep_range_min = 6, typical_rep_range_max = 15,
  common_form_errors = ARRAY['front knee caves inward','trunk leans forward','partial depth','hip hike','rear foot placement']
WHERE lower(name) IN ('reverse lunge','barbell reverse lunge','dumbbell reverse lunge')
  AND (skill_ceiling IS NULL OR fatigue_cost IS NULL);

UPDATE exercises SET
  skill_ceiling = 2, fatigue_cost = 3, cns_demand = 2,
  energy_system = 'lactic',
  typical_rep_range_min = 6, typical_rep_range_max = 15,
  common_form_errors = ARRAY['driving off back leg','box too high','knee caves','trunk rotation','landing hard']
WHERE lower(name) IN ('step-up','step up','dumbbell step-up','barbell step-up','box step-up')
  AND (skill_ceiling IS NULL OR fatigue_cost IS NULL);

UPDATE exercises SET
  skill_ceiling = 3, fatigue_cost = 3, cns_demand = 2,
  energy_system = 'lactic',
  typical_rep_range_min = 8, typical_rep_range_max = 15,
  common_form_errors = ARRAY['heels lift','trunk falls forward','partial depth','knees cave','weight drifts forward']
WHERE lower(name) IN ('goblet squat','dumbbell goblet squat','kettlebell goblet squat')
  AND (skill_ceiling IS NULL OR fatigue_cost IS NULL);

UPDATE exercises SET
  skill_ceiling = 4, fatigue_cost = 4, cns_demand = 3,
  energy_system = 'mixed',
  typical_rep_range_min = 5, typical_rep_range_max = 10,
  common_form_errors = ARRAY['rounding back','insufficient hip hinge','knees lock out','head drops','hyperextension at top']
WHERE lower(name) IN ('good morning','barbell good morning','good mornings')
  AND (skill_ceiling IS NULL OR fatigue_cost IS NULL);

UPDATE exercises SET
  skill_ceiling = 2, fatigue_cost = 2, cns_demand = 1,
  energy_system = 'lactic',
  typical_rep_range_min = 10, typical_rep_range_max = 20,
  common_form_errors = ARRAY['hyperextension at top','jerky movement','partial ROM','rounding lumbar','head back']
WHERE lower(name) IN ('back extension','hyperextension','45-degree back extension','45-degree hyperextension')
  AND (skill_ceiling IS NULL OR fatigue_cost IS NULL);

-- =============================================================================
-- OLYMPIC LIFT ACCESSORIES (skill=5, fatigue=3-4)
-- =============================================================================

UPDATE exercises SET
  skill_ceiling = 5, fatigue_cost = 4, cns_demand = 5,
  energy_system = 'alactic',
  typical_rep_range_min = 1, typical_rep_range_max = 3,
  common_form_errors = ARRAY['early arm pull','incomplete triple extension','bar path away from body','incomplete catch','dropping under too slow']
WHERE lower(name) IN ('hang power snatch','hang snatch','high hang snatch')
  AND (skill_ceiling IS NULL OR fatigue_cost IS NULL);

UPDATE exercises SET
  skill_ceiling = 4, fatigue_cost = 4, cns_demand = 5,
  energy_system = 'alactic',
  typical_rep_range_min = 1, typical_rep_range_max = 5,
  common_form_errors = ARRAY['early arm bend','hips rise too fast','bar path forward','insufficient extension','elbows slow']
WHERE lower(name) IN ('clean pull','snatch pull','high pull')
  AND (skill_ceiling IS NULL OR fatigue_cost IS NULL);

UPDATE exercises SET
  skill_ceiling = 4, fatigue_cost = 4, cns_demand = 4,
  energy_system = 'alactic',
  typical_rep_range_min = 1, typical_rep_range_max = 5,
  common_form_errors = ARRAY['dip too deep','dip too fast','insufficient leg drive','press-out at top','chest collapses']
WHERE lower(name) IN ('push jerk','barbell push jerk','split jerk')
  AND (skill_ceiling IS NULL OR fatigue_cost IS NULL);

-- =============================================================================
-- exercise_joint_stress: additional compounds
-- =============================================================================

-- Close-grip bench
WITH cgb_ids AS (
  SELECT id FROM exercises WHERE lower(name) IN ('close-grip bench press','close grip bench press','narrow grip bench press')
)
INSERT INTO exercise_joint_stress (exercise_id, joint, stress_level, stress_type, notes)
SELECT id, joint, stress_level, stress_type, notes
FROM cgb_ids,
     (VALUES
       ('elbow'::text, 3::smallint, 'compression'::text, 'Narrow grip concentrates load on elbows'),
       ('wrist'::text, 2::smallint, 'compression'::text, 'Narrow grip increases wrist flexion demand'),
       ('shoulder'::text, 2::smallint, 'compression'::text, 'Less anterior stress than wide grip')
     ) AS jstress(joint, stress_level, stress_type, notes)
ON CONFLICT (exercise_id, joint, stress_type) DO NOTHING;

-- Sumo deadlift
WITH sumo_ids AS (
  SELECT id FROM exercises WHERE lower(name) IN ('sumo deadlift','sumo barbell deadlift','wide-stance deadlift')
)
INSERT INTO exercise_joint_stress (exercise_id, joint, stress_level, stress_type, notes)
SELECT id, joint, stress_level, stress_type, notes
FROM sumo_ids,
     (VALUES
       ('lumbar_spine'::text, 2::smallint, 'compression'::text, 'Lower shear than conventional due to upright torso'),
       ('hip'::text, 3::smallint, 'tension'::text, 'Adductor + glute tension at wide stance'),
       ('knee'::text, 2::smallint, 'shear'::text, 'Wide stance creates external rotation stress'),
       ('sacroiliac'::text, 2::smallint, 'shear'::text, 'Asymmetric load distribution')
     ) AS jstress(joint, stress_level, stress_type, notes)
ON CONFLICT (exercise_id, joint, stress_type) DO NOTHING;

-- Trap bar deadlift
WITH tbd_ids AS (
  SELECT id FROM exercises WHERE lower(name) IN ('trap bar deadlift','trap-bar deadlift','hex bar deadlift')
)
INSERT INTO exercise_joint_stress (exercise_id, joint, stress_level, stress_type, notes)
SELECT id, joint, stress_level, stress_type, notes
FROM tbd_ids,
     (VALUES
       ('lumbar_spine'::text, 2::smallint, 'compression'::text, 'Lower spinal load than conventional (load centered)'),
       ('knee'::text, 2::smallint, 'compression'::text, 'More knee flexion than conventional'),
       ('hip'::text, 2::smallint, 'compression'::text, 'Balanced load path'),
       ('wrist'::text, 1::smallint, 'compression'::text, 'Neutral grip reduces stress')
     ) AS jstress(joint, stress_level, stress_type, notes)
ON CONFLICT (exercise_id, joint, stress_type) DO NOTHING;

-- Good morning
WITH gm_ids AS (
  SELECT id FROM exercises WHERE lower(name) IN ('good morning','barbell good morning','good mornings')
)
INSERT INTO exercise_joint_stress (exercise_id, joint, stress_level, stress_type, notes)
SELECT id, joint, stress_level, stress_type, notes
FROM gm_ids,
     (VALUES
       ('lumbar_spine'::text, 3::smallint, 'shear'::text, 'Extreme hip hinge creates high shear'),
       ('lumbar_spine'::text, 2::smallint, 'compression'::text, 'Loaded at lumbar lever arm'),
       ('hip'::text, 3::smallint, 'tension'::text, 'Hamstring + glute tension'),
       ('sacroiliac'::text, 2::smallint, 'shear'::text, 'Loaded flexion moment')
     ) AS jstress(joint, stress_level, stress_type, notes)
ON CONFLICT (exercise_id, joint, stress_type) DO NOTHING;

-- Hack squat
WITH hack_ids AS (
  SELECT id FROM exercises WHERE lower(name) IN ('hack squat','machine hack squat','45-degree hack squat')
)
INSERT INTO exercise_joint_stress (exercise_id, joint, stress_level, stress_type, notes)
SELECT id, joint, stress_level, stress_type, notes
FROM hack_ids,
     (VALUES
       ('knee'::text, 3::smallint, 'compression'::text, 'Pat-femoral load at depth'),
       ('hip'::text, 2::smallint, 'compression'::text, 'Reduced hip contribution vs back squat'),
       ('lumbar_spine'::text, 1::smallint, 'compression'::text, 'Back pad reduces axial load')
     ) AS jstress(joint, stress_level, stress_type, notes)
ON CONFLICT (exercise_id, joint, stress_type) DO NOTHING;

-- Decline bench
WITH decline_ids AS (
  SELECT id FROM exercises WHERE lower(name) IN ('decline bench press','decline barbell bench press','decline press')
)
INSERT INTO exercise_joint_stress (exercise_id, joint, stress_level, stress_type, notes)
SELECT id, joint, stress_level, stress_type, notes
FROM decline_ids,
     (VALUES
       ('shoulder'::text, 2::smallint, 'compression'::text, 'Less subacromial stress than flat bench'),
       ('elbow'::text, 2::smallint, 'compression'::text, 'Load through distal arm')
     ) AS jstress(joint, stress_level, stress_type, notes)
ON CONFLICT (exercise_id, joint, stress_type) DO NOTHING;

-- Single-leg RDL
WITH slrdl_ids AS (
  SELECT id FROM exercises WHERE lower(name) IN ('single-leg rdl','single leg romanian deadlift','one-leg rdl')
)
INSERT INTO exercise_joint_stress (exercise_id, joint, stress_level, stress_type, notes)
SELECT id, joint, stress_level, stress_type, notes
FROM slrdl_ids,
     (VALUES
       ('hip'::text, 2::smallint, 'tension'::text, 'Primary target — single-leg hamstring stretch'),
       ('knee'::text, 1::smallint, 'compression'::text, 'Minimal, soft-knee position'),
       ('ankle'::text, 2::smallint, 'compression'::text, 'Balance demand high')
     ) AS jstress(joint, stress_level, stress_type, notes)
ON CONFLICT (exercise_id, joint, stress_type) DO NOTHING;

-- Ab wheel rollout
WITH abw_ids AS (
  SELECT id FROM exercises WHERE lower(name) IN ('ab wheel rollout','ab rollout','wheel rollout')
)
INSERT INTO exercise_joint_stress (exercise_id, joint, stress_level, stress_type, notes)
SELECT id, joint, stress_level, stress_type, notes
FROM abw_ids,
     (VALUES
       ('lumbar_spine'::text, 2::smallint, 'tension'::text, 'Anti-extension isometric load'),
       ('shoulder'::text, 2::smallint, 'tension'::text, 'Overhead flexed position'),
       ('wrist'::text, 1::smallint, 'tension'::text, 'Extended grip position')
     ) AS jstress(joint, stress_level, stress_type, notes)
ON CONFLICT (exercise_id, joint, stress_type) DO NOTHING;

COMMIT;
