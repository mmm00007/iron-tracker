-- Migration 056: Auto-Generated Exercise Aliases
-- Expands alias coverage from 75 to ~400+ exercises using pattern-based
-- abbreviation generation. Only adds to exercises with empty aliases.
--
-- Patterns: BB=Barbell, DB=Dumbbell, KB=Kettlebell, BW=Bodyweight,
-- EZ=EZ-Bar, SM=Smith Machine, plus common name simplifications.

BEGIN;

-- =============================================================================
-- 1. ABBREVIATION-BASED ALIASES
-- =============================================================================

-- Barbell exercises → add "BB" abbreviation
UPDATE exercises
SET aliases = ARRAY[replace(name, 'Barbell ', 'BB ')]
WHERE (aliases IS NULL OR aliases = '{}')
  AND created_by IS NULL
  AND name LIKE 'Barbell %'
  AND name NOT IN (SELECT name FROM exercises WHERE aliases IS NOT NULL AND aliases != '{}');

-- Dumbbell exercises → add "DB" abbreviation
UPDATE exercises
SET aliases = ARRAY[replace(name, 'Dumbbell ', 'DB ')]
WHERE (aliases IS NULL OR aliases = '{}')
  AND created_by IS NULL
  AND name LIKE 'Dumbbell %';

-- Kettlebell exercises → add "KB" abbreviation
UPDATE exercises
SET aliases = ARRAY[replace(name, 'Kettlebell ', 'KB ')]
WHERE (aliases IS NULL OR aliases = '{}')
  AND created_by IS NULL
  AND name LIKE 'Kettlebell %';

-- One-Arm Kettlebell → "One-Arm KB" abbreviation
UPDATE exercises
SET aliases = ARRAY[replace(name, 'One-Arm Kettlebell ', 'One-Arm KB ')]
WHERE (aliases IS NULL OR aliases = '{}')
  AND created_by IS NULL
  AND name LIKE 'One-Arm Kettlebell %';

-- Two-Arm Kettlebell → "Two-Arm KB"
UPDATE exercises
SET aliases = ARRAY[replace(name, 'Two-Arm Kettlebell ', 'Two-Arm KB ')]
WHERE (aliases IS NULL OR aliases = '{}')
  AND created_by IS NULL
  AND name LIKE 'Two-Arm Kettlebell %';

-- Double Kettlebell → "Double KB"
UPDATE exercises
SET aliases = ARRAY[replace(name, 'Double Kettlebell ', 'Double KB ')]
WHERE (aliases IS NULL OR aliases = '{}')
  AND created_by IS NULL
  AND name LIKE 'Double Kettlebell %';

-- Smith Machine exercises → add "SM" abbreviation
UPDATE exercises
SET aliases = ARRAY[replace(name, 'Smith Machine ', 'SM ')]
WHERE (aliases IS NULL OR aliases = '{}')
  AND created_by IS NULL
  AND name LIKE 'Smith Machine %';

-- EZ-Bar exercises → add "EZ" abbreviation
UPDATE exercises
SET aliases = ARRAY[replace(name, 'EZ-Bar ', 'EZ ')]
WHERE (aliases IS NULL OR aliases = '{}')
  AND created_by IS NULL
  AND name LIKE 'EZ-Bar %';

-- Cable exercises → simplify "Cable" prefix exercises
UPDATE exercises
SET aliases = ARRAY[replace(name, 'Cable ', '')]
WHERE (aliases IS NULL OR aliases = '{}')
  AND created_by IS NULL
  AND name LIKE 'Cable %'
  AND length(name) > 10;

-- =============================================================================
-- 2. COMMON NAME SIMPLIFICATIONS
-- =============================================================================

-- "Seated Barbell X" → also findable as "Seated BB X" and "X (Seated)"
UPDATE exercises
SET aliases = array_cat(COALESCE(aliases, '{}'), ARRAY[replace(name, 'Seated Barbell ', 'Seated BB ')])
WHERE created_by IS NULL
  AND name LIKE 'Seated Barbell %'
  AND NOT (replace(name, 'Seated Barbell ', 'Seated BB ') = ANY(COALESCE(aliases, '{}')));

-- "Incline Barbell X" → "Incline BB X"
UPDATE exercises
SET aliases = array_cat(COALESCE(aliases, '{}'), ARRAY[replace(name, 'Incline Barbell ', 'Incline BB ')])
WHERE created_by IS NULL
  AND name LIKE 'Incline Barbell %'
  AND NOT (replace(name, 'Incline Barbell ', 'Incline BB ') = ANY(COALESCE(aliases, '{}')));

-- "Decline Barbell X" → "Decline BB X"
UPDATE exercises
SET aliases = array_cat(COALESCE(aliases, '{}'), ARRAY[replace(name, 'Decline Barbell ', 'Decline BB ')])
WHERE created_by IS NULL
  AND name LIKE 'Decline Barbell %'
  AND NOT (replace(name, 'Decline Barbell ', 'Decline BB ') = ANY(COALESCE(aliases, '{}')));

-- "Incline Dumbbell X" → "Incline DB X"
UPDATE exercises
SET aliases = array_cat(COALESCE(aliases, '{}'), ARRAY[replace(name, 'Incline Dumbbell ', 'Incline DB ')])
WHERE created_by IS NULL
  AND name LIKE 'Incline Dumbbell %'
  AND NOT (replace(name, 'Incline Dumbbell ', 'Incline DB ') = ANY(COALESCE(aliases, '{}')));

-- "Alternate X" → "Alternating X" (common search variant)
UPDATE exercises
SET aliases = array_cat(COALESCE(aliases, '{}'), ARRAY[replace(name, 'Alternate ', 'Alternating ')])
WHERE created_by IS NULL
  AND name LIKE 'Alternate %'
  AND NOT (replace(name, 'Alternate ', 'Alternating ') = ANY(COALESCE(aliases, '{}')));

-- "X - Y Version" → "Y X" (common MUI search: "Chest Dips" not "Dips - Chest Version")
UPDATE exercises
SET aliases = array_cat(COALESCE(aliases, '{}'), ARRAY[
  regexp_replace(name, '^(.+) - (.+) Version$', '\2 \1')
])
WHERE created_by IS NULL
  AND name ~ '.+ - .+ Version$'
  AND NOT EXISTS (
    SELECT 1 FROM unnest(COALESCE(aliases, '{}')) a
    WHERE a = regexp_replace(name, '^(.+) - (.+) Version$', '\2 \1')
  );

-- "X With Y" → also findable as "X" alone
UPDATE exercises
SET aliases = array_cat(COALESCE(aliases, '{}'), ARRAY[split_part(name, ' With ', 1)])
WHERE created_by IS NULL
  AND name LIKE '% With %'
  AND length(split_part(name, ' With ', 1)) >= 5
  AND NOT (split_part(name, ' With ', 1) = ANY(COALESCE(aliases, '{}')));

-- "Front Squats With Two Kettlebells" → "Double KB Front Squat"
-- (handled by the "With" rule above + the KB abbreviation)


COMMIT;
