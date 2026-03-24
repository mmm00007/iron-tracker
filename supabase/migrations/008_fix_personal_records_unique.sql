-- Migration: Fix personal_records UNIQUE constraint to handle nullable columns correctly.
--
-- Problem: The original inline UNIQUE constraint
--   UNIQUE (user_id, exercise_id, variant_id, record_type, rep_count)
-- does not prevent duplicates when variant_id IS NULL and/or rep_count IS NULL
-- because in PostgreSQL, NULL != NULL, so two rows with identical non-null columns
-- but both having NULL variant_id are considered distinct by the constraint.
--
-- Fix: Drop the old constraint and replace it with four partial unique indexes,
-- each covering one combination of NULL / non-NULL for the two nullable columns.

-- Drop the auto-generated constraint from the CREATE TABLE statement in 001_initial_schema.sql.
-- PostgreSQL truncates identifier names to 63 characters; the generated name is:
--   personal_records_user_id_exercise_id_variant_id_record_type_rep_key
ALTER TABLE personal_records
  DROP CONSTRAINT IF EXISTS personal_records_user_id_exercise_id_variant_id_record_type_rep_key;

-- Case 1: Both variant_id and rep_count are non-null.
CREATE UNIQUE INDEX personal_records_full_key
  ON personal_records (user_id, exercise_id, variant_id, record_type, rep_count)
  WHERE variant_id IS NOT NULL AND rep_count IS NOT NULL;

-- Case 2: variant_id is null, rep_count is non-null.
CREATE UNIQUE INDEX personal_records_no_variant_key
  ON personal_records (user_id, exercise_id, record_type, rep_count)
  WHERE variant_id IS NULL AND rep_count IS NOT NULL;

-- Case 3: variant_id is non-null, rep_count is null.
CREATE UNIQUE INDEX personal_records_no_rep_key
  ON personal_records (user_id, exercise_id, variant_id, record_type)
  WHERE variant_id IS NOT NULL AND rep_count IS NULL;

-- Case 4: Both variant_id and rep_count are null.
CREATE UNIQUE INDEX personal_records_minimal_key
  ON personal_records (user_id, exercise_id, record_type)
  WHERE variant_id IS NULL AND rep_count IS NULL;
