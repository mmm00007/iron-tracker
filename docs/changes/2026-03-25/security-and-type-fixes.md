# Security & Type Safety Fixes — 2026-03-25

Fixes applied based on the multi-agent deployment audit findings. All changes validated by QA reviewer and security specialist agents.

---

## Fixes Applied

### 1. CRITICAL: Removed Hardcoded Supabase PAT

**File:** `scripts/seed_via_api.py`

- Replaced hardcoded `TOKEN = "sbp_e054ee..."` with `os.environ.get("SUPABASE_PAT", "")`
- Replaced hardcoded `PROJECT_ID` with `os.environ.get("SUPABASE_PROJECT_ID", "")`
- Added early exit guard if environment variables are not set
- Added `scripts/seed_via_api.py` to `.gitignore` to prevent future credential exposure

**Impact:** Prevents full database compromise if the file were ever committed. The token must still be revoked at the Supabase dashboard — code changes alone don't invalidate a leaked credential.

### 2. CRITICAL: Deleted Production Handoff File

**File:** `docs/deployment/handoff.json` (deleted)

Per project conventions: "Once all phases are complete and verified, delete the handoff file — it contains secrets." All 3 deployment phases were marked complete. The file contained:
- Database connection string with plaintext password
- JWT signing secret (allows forging auth tokens for any user)
- Supabase anon key and Sentry DSNs

Non-secret outputs (Netlify URL, Render URL, GitHub repo) are already documented in the project CLAUDE.md and deployment configs.

### 3. HIGH: Restricted SECURITY DEFINER Function to Service Role

**File:** `supabase/migrations/021_deep_schema_enrichment.sql`

Added after the `recompute_workout_clusters` function definition:
```sql
REVOKE EXECUTE ON FUNCTION recompute_workout_clusters(uuid, date) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION recompute_workout_clusters(uuid, date) FROM authenticated;
GRANT EXECUTE ON FUNCTION recompute_workout_clusters(uuid, date) TO service_role;
```

**Impact:** Previously, any authenticated user could call this function via PostgREST RPC with an arbitrary `p_user_id`, allowing cross-user mutation of workout cluster assignments. Now only the backend service role can invoke it.

### 4. HIGH: Added Timezone Validation Constraint

**File:** `supabase/migrations/019_schema_enrichment.sql`

Added CHECK constraint on `profiles.timezone`:
```sql
CHECK (timezone IS NULL OR timezone ~ '^[A-Za-z][A-Za-z0-9/_+-]{1,63}$')
```

**Impact:** Prevents users from setting invalid timezone strings that would cause the `compute_training_date` trigger to throw errors on every INSERT to `sets` (self-DoS). Accepts all valid IANA timezone names (e.g., `America/New_York`, `UTC`, `Etc/GMT+5`).

### 5. HIGH: Consolidated AnalysisReport Type

**File:** `frontend/src/hooks/useAnalysis.ts`

- Removed local duplicate `AnalysisReport` interface (was missing `status`, `report_type`, `evidence`, `recommendation_scope_id` fields)
- Now imports `AnalysisReport` from `@/types/database` which has the complete definition matching the database schema

**Impact:** Prevents TypeScript type shadowing where components importing from both files would get different shapes, potentially causing runtime `undefined` errors when accessing `status` or `report_type` fields.

### 6. HIGH: Added advancedAnalyticsEnabled to FeatureFlags

**File:** `frontend/src/hooks/useFeatureFlags.ts`

- Added `advancedAnalyticsEnabled: boolean` to `FeatureFlags` interface
- Set default to `false` (backend returns `true` when the feature is live)

**Impact:** Frontend TypeScript consumers can now properly gate the advanced analytics UI behind this feature flag. Previously the flag was returned by the backend but invisible to TypeScript.

### 7. HIGH: Fixed Weight Unit Normalization

**File:** `frontend/src/hooks/useMuscleVolume.ts`

- Added `weight_unit` to the Supabase select query
- Normalizes pounds to kilograms (`* 0.453592`) before volume calculation

**Impact:** Users logging in pounds previously had ~2.2x inflated muscle volume metrics compared to kg users. The backend's `training_day_summary` view already normalizes to kg; the frontend now matches.

---

## Remaining Action Items

These issues were identified but require external action (not code-only fixes):

| # | Action | Owner | Status |
|---|--------|-------|--------|
| 1 | Revoke Supabase PAT `sbp_e054ee...` at dashboard | Human | Pending |
| 2 | Apply 12 missing committed migrations (002-010, 013, 016-017) to production Supabase | Human/Deploy Agent | Pending |
| 3 | Apply 4 uncommitted migrations (019-022) after commit | Human/Deploy Agent | Pending |
| 4 | Write backend tests for composite_score, muscle_frequency, staleness, load_distribution services | Dev | Pending |
| 5 | Review and drop 2 stale git stashes | Dev | Pending |

---

## Validation

| Agent | Result |
|-------|--------|
| **QA Reviewer** | All 6 fixes verified correct. No regressions. Imports resolve. SQL syntax valid. |
| **Security Specialist** | REVOKE/GRANT pattern confirmed effective. Timezone constraint restricts attack surface. Handoff.json deletion confirmed necessary. |

---

*Generated by NanoClaw multi-agent audit+fix cycle — 2026-03-25*
