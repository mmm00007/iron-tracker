-- Migration 094: Exercise Coaching Cues Catalog
-- Structured per-exercise coaching cues beyond the flat common_form_errors
-- text[] on exercises. Provides setup, execution, lockout, and safety cues
-- that frontend surfaces when user opens an exercise during a session.
--
-- Existing exercises columns (migrations 029, 062):
--   - instructions text[]: freeform step list from seed (verbose)
--   - form_tips text[]: short cues from seed
--   - common_form_errors text[]: error bullets from migration 062
--
-- This migration adds a NORMALIZED cue structure for UI consumption:
--   - cue_type: setup / execution / lockout / breathing / safety
--   - priority: most important cues first
--   - short_text: one-line cue
--   - detailed_text: optional elaboration
--
-- Seeds ~60 cues across 10 tier-1 compound lifts.
-- Validated by: fitness-domain-expert
--
-- Citations:
--   - Rippetoe M. (2011). Starting Strength 3rd ed. — movement model
--   - McGill S. (2016). Low Back Disorders — spinal safety cues
--   - Cressey E. (2018). High Performance Handbook — technique progression

BEGIN;

CREATE TABLE IF NOT EXISTS exercise_coaching_cues (
  id             uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  exercise_id    uuid        NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
  cue_type       text        NOT NULL
    CHECK (cue_type IN ('setup','execution','lockout','breathing','safety','mental','eccentric','tempo')),
  priority       smallint    NOT NULL DEFAULT 1 CHECK (priority >= 1 AND priority <= 10),
  short_text     text        NOT NULL CHECK (length(short_text) <= 140),
  detailed_text  text,
  source         text,
  UNIQUE (exercise_id, cue_type, short_text)
);

COMMENT ON TABLE exercise_coaching_cues IS
  'Normalized coaching cues per exercise. Frontend filters by cue_type '
  'and orders by priority (ascending = most important first). short_text '
  'is SMS-length (<=140 chars) for quick UI consumption.';

COMMENT ON COLUMN exercise_coaching_cues.cue_type IS
  'Category of the cue: setup (rack/stance), execution (movement pattern), '
  'lockout (end-range), breathing (inhale/exhale), safety (injury risk), '
  'mental (focus point), eccentric (lowering phase), tempo (pace).';

CREATE INDEX IF NOT EXISTS exercise_coaching_cues_exercise_type_idx
  ON exercise_coaching_cues (exercise_id, cue_type, priority);

ALTER TABLE exercise_coaching_cues ENABLE ROW LEVEL SECURITY;
CREATE POLICY exercise_coaching_cues_select ON exercise_coaching_cues
  FOR SELECT TO authenticated USING (true);

-- =============================================================================
-- SEED: Coaching cues for top 10 compound lifts
-- =============================================================================

-- Barbell Squat
INSERT INTO exercise_coaching_cues (exercise_id, cue_type, priority, short_text, detailed_text, source)
SELECT e.id, c.cue_type, c.priority, c.short_text, c.detailed_text, c.source
FROM exercises e
CROSS JOIN (VALUES
  ('setup'::text,     1::smallint, 'Bar rests on upper traps (high-bar) or rear delts (low-bar)', NULL::text, 'Rippetoe 2011'::text),
  ('setup',     2, 'Feet shoulder-width, toes 15-30 degrees out', 'Stance must allow hips to descend between thighs', 'NSCA 2016'),
  ('setup',     3, 'Grip bar tight, pull elbows down to lock upper back', NULL, 'Rippetoe 2011'),
  ('execution', 1, 'Break at hips AND knees simultaneously', 'Avoid hinging first then squatting — maintain torso angle', 'Rippetoe 2011'),
  ('execution', 2, 'Drive knees out, tracking over toes', NULL, 'McGill 2016'),
  ('execution', 3, 'Descend to thighs parallel or below (full depth)', NULL, 'NSCA 2016'),
  ('lockout',   1, 'Stand tall at top — squeeze glutes, no hyperextension', NULL, 'McGill 2016'),
  ('breathing', 1, 'Big breath + brace at top, exhale through sticking point', NULL, 'Rippetoe 2011'),
  ('safety',    1, 'Neutral spine throughout — no butt wink at bottom', 'Butt wink = lumbar flexion under load = disc risk', 'McGill 2016'),
  ('safety',    2, 'Use safety pins set 1-2 inches below bottom position', NULL, NULL)
) AS c(cue_type, priority, short_text, detailed_text, source)
WHERE lower(e.name) IN ('barbell squat','back squat','barbell back squat','high bar squat','low bar squat')
ON CONFLICT DO NOTHING;

-- Deadlift
INSERT INTO exercise_coaching_cues (exercise_id, cue_type, priority, short_text, detailed_text, source)
SELECT e.id, c.cue_type, c.priority, c.short_text, c.detailed_text, c.source
FROM exercises e
CROSS JOIN (VALUES
  ('setup'::text,     1::smallint, 'Bar over mid-foot, shins 1 inch from bar', NULL::text, 'Rippetoe 2011'::text),
  ('setup',     2, 'Hip hinge to bar, shoulders slightly ahead of bar', NULL, 'NSCA 2016'),
  ('setup',     3, 'Lats engaged — pretend to crush oranges in armpits', NULL, 'Wendler 2012'),
  ('execution', 1, 'Push the floor away, bar drags up legs', 'Think legs first, back second — not a back lift', 'Rippetoe 2011'),
  ('execution', 2, 'Hips and shoulders rise at same rate', 'If hips shoot up, weight is too heavy or technique is off', 'McGill 2016'),
  ('lockout',   1, 'Stand fully, shoulders back, squeeze glutes', NULL, NULL),
  ('lockout',   2, 'No lean-back — finish with hip extension, not spine extension', NULL, 'McGill 2016'),
  ('breathing', 1, 'Big breath at top of lift, hold through rep', NULL, 'Rippetoe 2011'),
  ('safety',    1, 'Neutral spine — no lumbar rounding at any point', 'Rounded back deadlifts have high disc injury risk', 'McGill 2016'),
  ('safety',    2, 'Drop weight if grip fails — never hook with wrist flexion', NULL, NULL)
) AS c(cue_type, priority, short_text, detailed_text, source)
WHERE lower(e.name) IN ('deadlift','conventional deadlift','barbell deadlift')
ON CONFLICT DO NOTHING;

-- Bench Press
INSERT INTO exercise_coaching_cues (exercise_id, cue_type, priority, short_text, detailed_text, source)
SELECT e.id, c.cue_type, c.priority, c.short_text, c.detailed_text, c.source
FROM exercises e
CROSS JOIN (VALUES
  ('setup'::text,     1::smallint, 'Retract scapula + slight arch — stable back base', NULL::text, 'NSCA 2016'::text),
  ('setup',     2, 'Grip 1.5x shoulder width, wrists stacked over elbows', NULL, 'NSCA 2016'),
  ('setup',     3, 'Feet planted flat, drive heels down for leg drive', NULL, 'Rippetoe 2011'),
  ('execution', 1, 'Lower to nipple line (flat) or upper sternum (incline)', 'Bar path is a shallow arc, not straight down', 'Rippetoe 2011'),
  ('execution', 2, 'Elbows tucked 45-75° from torso (NOT flared 90°)', 'Flared elbows = shoulder impingement risk', 'McGill 2016'),
  ('execution', 3, 'Pause momentarily on chest — no bouncing', NULL, 'IPF competition rules'),
  ('lockout',   1, 'Press up and slightly back toward rack, full elbow extension', NULL, NULL),
  ('breathing', 1, 'Inhale at top, hold through descent + drive', NULL, 'Rippetoe 2011'),
  ('safety',    1, 'Keep scapulae retracted throughout rep', 'Loss of retraction = shoulder instability', 'Cressey 2018'),
  ('safety',    2, 'Use spotter or safety arms — never bench without backup', NULL, NULL)
) AS c(cue_type, priority, short_text, detailed_text, source)
WHERE lower(e.name) IN ('bench press','barbell bench press','flat bench press','flat barbell bench press')
ON CONFLICT DO NOTHING;

-- Overhead Press
INSERT INTO exercise_coaching_cues (exercise_id, cue_type, priority, short_text, detailed_text, source)
SELECT e.id, c.cue_type, c.priority, c.short_text, c.detailed_text, c.source
FROM exercises e
CROSS JOIN (VALUES
  ('setup'::text,     1::smallint, 'Grip just outside shoulders, wrists over elbows', NULL::text, 'Rippetoe 2011'::text),
  ('setup',     2, 'Bar rests on front delts, elbows slightly ahead of bar', NULL, 'NSCA 2016'),
  ('setup',     3, 'Brace core, glutes tight, no lower-back arch', NULL, 'McGill 2016'),
  ('execution', 1, 'Move head BACK, then press bar straight up', 'Bar path must stay vertical — head moves out of the way', 'Rippetoe 2011'),
  ('execution', 2, 'Once bar passes face, head returns forward under bar', NULL, 'Rippetoe 2011'),
  ('lockout',   1, 'Shrug shoulders at top — bar over ears, arms fully locked', NULL, 'Starting Strength model'),
  ('breathing', 1, 'Big breath + brace, exhale at lockout', NULL, NULL),
  ('safety',    1, 'Avoid lumbar hyperextension — if arching, drop weight', 'Spine acts as lever arm — dangerous under heavy load', 'McGill 2016'),
  ('safety',    2, 'Stop short if shoulders impinge — do not force ROM', NULL, 'Cressey 2018')
) AS c(cue_type, priority, short_text, detailed_text, source)
WHERE lower(e.name) IN ('overhead press','barbell overhead press','standing overhead press','military press','strict press')
ON CONFLICT DO NOTHING;

-- Romanian Deadlift
INSERT INTO exercise_coaching_cues (exercise_id, cue_type, priority, short_text, detailed_text, source)
SELECT e.id, c.cue_type, c.priority, c.short_text, c.detailed_text, c.source
FROM exercises e
CROSS JOIN (VALUES
  ('setup'::text,     1::smallint, 'Stand tall with bar at hip, slight knee bend', NULL::text, 'NSCA 2016'::text),
  ('setup',     2, 'Scapula retracted, lats engaged, bar close to body', NULL, 'Rippetoe 2011'),
  ('execution', 1, 'Push hips BACK, not just bend forward', 'Weight stays in heels as hips travel backward', 'McGill 2016'),
  ('execution', 2, 'Keep soft-knee position — DO NOT straighten knees', NULL, 'NSCA 2016'),
  ('execution', 3, 'Descend until hamstrings stretched, typically just below knees', NULL, 'Helms 2019'),
  ('lockout',   1, 'Drive hips forward to stand, squeeze glutes at top', NULL, NULL),
  ('breathing', 1, 'Inhale at top, brace through eccentric, exhale on hip drive', NULL, 'Rippetoe 2011'),
  ('safety',    1, 'Neutral spine throughout — stop if lumbar rounds', 'RDL is for hip hinge, NOT spinal flexion', 'McGill 2016')
) AS c(cue_type, priority, short_text, detailed_text, source)
WHERE lower(e.name) IN ('romanian deadlift','rdl','barbell romanian deadlift')
ON CONFLICT DO NOTHING;

-- Pull-up
INSERT INTO exercise_coaching_cues (exercise_id, cue_type, priority, short_text, detailed_text, source)
SELECT e.id, c.cue_type, c.priority, c.short_text, c.detailed_text, c.source
FROM exercises e
CROSS JOIN (VALUES
  ('setup'::text,     1::smallint, 'Pronated grip slightly wider than shoulders', NULL::text, 'NSCA 2016'::text),
  ('setup',     2, 'Dead hang start, arms fully extended, scapulae depressed', NULL, 'Cressey 2018'),
  ('execution', 1, 'Pull elbows DOWN + BACK toward pockets', 'Think elbows, not hands — lats initiate the pull', 'Cressey 2018'),
  ('execution', 2, 'Chest up to bar (not chin to bar)', 'Full ROM finishes at clavicle to bar', 'Rippetoe 2011'),
  ('lockout',   1, 'Hold chest-to-bar briefly, then lower under control', NULL, NULL),
  ('eccentric', 1, 'Control descent 2-3 seconds to full dead hang', 'Eccentric phase drives hypertrophy in pull-ups', 'Schoenfeld 2017'),
  ('safety',    1, 'Avoid kipping or swinging — compromises shoulder health', NULL, 'Cressey 2018')
) AS c(cue_type, priority, short_text, detailed_text, source)
WHERE lower(e.name) IN ('pull-up','pull up','pullup','wide-grip pull-up')
ON CONFLICT DO NOTHING;

-- Barbell Row
INSERT INTO exercise_coaching_cues (exercise_id, cue_type, priority, short_text, detailed_text, source)
SELECT e.id, c.cue_type, c.priority, c.short_text, c.detailed_text, c.source
FROM exercises e
CROSS JOIN (VALUES
  ('setup'::text,     1::smallint, 'Hip hinge to ~45° torso angle, knees soft', NULL::text, 'Pendlay technique'::text),
  ('setup',     2, 'Grip slightly wider than shoulders, bar over mid-foot', NULL, NULL),
  ('execution', 1, 'Pull bar to lower sternum / upper abdomen', NULL, 'NSCA 2016'),
  ('execution', 2, 'Drive elbows back, NOT out — avoid flared elbows', NULL, 'Cressey 2018'),
  ('execution', 3, 'Keep torso fixed — no rocking for momentum', NULL, 'Pendlay technique'),
  ('lockout',   1, 'Squeeze shoulder blades at top, brief pause', NULL, NULL),
  ('safety',    1, 'Neutral spine — stop if lower back rounds', 'Loaded spinal flexion = disc injury risk', 'McGill 2016'),
  ('safety',    2, 'Core braced throughout — treat as quarter-deadlift position', NULL, 'McGill 2016')
) AS c(cue_type, priority, short_text, detailed_text, source)
WHERE lower(e.name) IN ('barbell row','bent-over row','bent over row','pendlay row')
ON CONFLICT DO NOTHING;

-- Hip Thrust
INSERT INTO exercise_coaching_cues (exercise_id, cue_type, priority, short_text, detailed_text, source)
SELECT e.id, c.cue_type, c.priority, c.short_text, c.detailed_text, c.source
FROM exercises e
CROSS JOIN (VALUES
  ('setup'::text,     1::smallint, 'Upper back on bench edge, bar over hip crease', NULL::text, 'Contreras 2014'::text),
  ('setup',     2, 'Feet shoulder-width, heels planted, shins vertical at top', NULL, NULL),
  ('setup',     3, 'Chin tucked, ribs down — neutral spine', NULL, 'McGill 2016'),
  ('execution', 1, 'Drive through heels, squeeze glutes at top', NULL, NULL),
  ('execution', 2, 'Finish with hips fully extended (straight line shoulders-knees)', NULL, 'Contreras 2014'),
  ('lockout',   1, 'Hold contraction 1 second at top before lowering', NULL, NULL),
  ('breathing', 1, 'Exhale forcefully at top, inhale on descent', NULL, NULL),
  ('safety',    1, 'NO lumbar hyperextension at top', 'Rib flare + lumbar arch compromises spine under load', 'McGill 2016')
) AS c(cue_type, priority, short_text, detailed_text, source)
WHERE lower(e.name) IN ('hip thrust','barbell hip thrust','glute bridge')
ON CONFLICT DO NOTHING;

-- Front Squat
INSERT INTO exercise_coaching_cues (exercise_id, cue_type, priority, short_text, detailed_text, source)
SELECT e.id, c.cue_type, c.priority, c.short_text, c.detailed_text, c.source
FROM exercises e
CROSS JOIN (VALUES
  ('setup'::text,     1::smallint, 'Bar rests on front delts, fingers loosely under bar', NULL::text, 'NSCA 2016'::text),
  ('setup',     2, 'Elbows HIGH and parallel to floor', 'Loss of elbow height = bar falls forward', 'Starting Strength'),
  ('setup',     3, 'Upper back tight, core braced', NULL, NULL),
  ('execution', 1, 'Torso stays vertical throughout descent', NULL, NULL),
  ('execution', 2, 'Knees drive OUT, hips descend between thighs', NULL, 'McGill 2016'),
  ('lockout',   1, 'Stand tall, elbows still pointed forward', NULL, NULL),
  ('safety',    1, 'Wrist/shoulder mobility is prerequisite', 'Force rack position = wrist/elbow injury risk', 'Cressey 2018'),
  ('safety',    2, 'If bar rolls forward, ABANDON — do not attempt to recover', NULL, NULL)
) AS c(cue_type, priority, short_text, detailed_text, source)
WHERE lower(e.name) IN ('front squat','barbell front squat','clean-grip front squat')
ON CONFLICT DO NOTHING;

-- Dip
INSERT INTO exercise_coaching_cues (exercise_id, cue_type, priority, short_text, detailed_text, source)
SELECT e.id, c.cue_type, c.priority, c.short_text, c.detailed_text, c.source
FROM exercises e
CROSS JOIN (VALUES
  ('setup'::text,     1::smallint, 'Parallel bars slightly wider than shoulders', NULL::text, 'NSCA 2016'::text),
  ('setup',     2, 'Straight arms to start, shoulders depressed', NULL, 'Cressey 2018'),
  ('execution', 1, 'Slight forward lean 10-20° for chest emphasis', 'Vertical torso = triceps dominant', 'NSCA 2016'),
  ('execution', 2, 'Descend until upper arms parallel to floor', NULL, NULL),
  ('lockout',   1, 'Press to full lockout, squeeze triceps', NULL, NULL),
  ('safety',    1, 'Stop if shoulders feel impinged', 'Excessive depth can stress anterior shoulder', 'Cressey 2018'),
  ('safety',    2, 'Avoid bouncing out of the bottom', NULL, NULL)
) AS c(cue_type, priority, short_text, detailed_text, source)
WHERE lower(e.name) IN ('dip','dips','parallel bar dip','tricep dip')
ON CONFLICT DO NOTHING;

COMMIT;
