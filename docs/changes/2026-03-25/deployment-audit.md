# Iron Tracker Deployment Audit — 2026-03-25

Comprehensive cross-agent audit of commit, push, and deployment status across all services (Git, GitHub, Render, Netlify, Supabase). Performed by QA reviewer, security specialist, software architect, and deployment specialist agents.

---

## Executive Summary

| Area | Status | Severity |
|------|--------|----------|
| Live services (Render + Netlify) | UP and responding | OK |
| Git local vs remote | In sync for committed work | OK |
| Uncommitted changes | **35 modified + 11 untracked files** | CRITICAL |
| Database migrations | **16 of 22 missing from production** | CRITICAL |
| Hardcoded secrets | **Supabase PAT in source file** | CRITICAL |
| Handoff file with secrets | Still on disk after deployment complete | CRITICAL |
| SECURITY DEFINER function | Cross-user callable via PostgREST | HIGH |
| Test coverage for new services | Zero tests for 4 newest services | HIGH |
| Type mismatches (frontend) | AnalysisReport duplication, FeatureFlags gap | HIGH |

**Bottom line:** The infrastructure is live and healthy, but there is a large gap between the working tree and what is actually deployed. Critical security issues must be addressed before any commit.

---

## 1. Deployment Status

### 1.1 Live Services

| Service | URL | Health |
|---------|-----|--------|
| Backend (Render) | https://iron-tracker-api.onrender.com | `/health` returns `{"status":"ok"}` |
| Frontend (Netlify) | https://iron-tracker-app.netlify.app | HTTP 200 |
| Database (Supabase) | https://mpocalqnhfrbembjryoh.supabase.co | Reachable |
| GitHub Repo | https://github.com/mmm00007/iron-tracker | In sync with local main |

### 1.2 Deployment Phases (from handoff.json)

| Phase | Status | Completed | Agent |
|-------|--------|-----------|-------|
| 1: GitHub + Supabase + Sentry | Complete | 2026-03-24T14:55Z | claude-code-cli |
| 2: Render backend | Complete | 2026-03-24T17:25Z | claude-code-cli |
| 3: Netlify frontend | Complete | 2026-03-24T15:20Z | claude-code-cli |
| 4: E2E + Security audit | **Pending** | TBD | Both |

### 1.3 CI/CD Pipelines

Three GitHub Actions workflows configured:
- **Frontend CI** — ESLint, TypeScript, Vitest (triggers on `frontend/**` push to main)
- **Backend CI** — Ruff, Mypy, pytest with coverage (triggers on `backend/**` push to main)
- **Weekly Trends Cron** — Monday 6AM UTC, calls `/api/analytics/jobs/generate-weekly-trends`

Auto-deploy: Render and Netlify deploy from main on push. No manual deploy step needed.

---

## 2. Git & Version Control

### 2.1 Branch Status

- **Current branch:** `main` (only branch)
- **Remote:** `origin` -> `https://github.com/mmm00007/iron-tracker.git`
- **Unpushed commits:** None — local and remote HEAD match at `c0d8aeb`
- **Stashes:** 2 (both from handoff.json gitignore work)

### 2.2 Uncommitted Changes (CRITICAL)

**35 modified files + 11 untracked files (+2,219 / -820 lines)**

#### Modified Files (key areas):
- **Backend:** `main.py`, `analysis_service.py`, `strength_standards_service.py`, `weekly_summary_service.py`, `advanced_analytics.py` router, tests
- **Frontend:** Theme overhaul, HomePage, StatsPage, HistoryPage, BottomNav, charts, analytics hooks, type updates, package.json
- **Config:** Various service configurations

#### New Untracked Files:
- `backend/app/services/composite_score_service.py` — New composite scoring
- `backend/app/services/muscle_frequency_service.py` — Muscle training frequency
- `supabase/migrations/019_schema_enrichment.sql` — Schema additions
- `supabase/migrations/020_seed_enrichment.sql` — Seed data enrichment
- `supabase/migrations/021_deep_schema_enrichment.sql` — Deep schema work
- `supabase/migrations/022_deep_seed_enrichment.sql` — Deep seed work
- `supabase/seed/004_exercise_substitutions.sql` — Exercise substitutions
- `docs/changes/2026-03-25/*.md` — 4 change documents

---

## 3. Database Migration Gap (CRITICAL)

### 3.1 Applied vs Missing

**Only 6 of 22 migrations are applied to production Supabase:**

| Applied | Skipped/Missing |
|---------|-----------------|
| 001 initial_schema | 002 fix_estimated_1rm_trigger |
| 011 workout_plans | 003 fix_deadlift_muscles |
| 012 analysis_reports | 004 add_missing_indexes |
| 014 exercise_favorites | 005 fix_exercise_cascade |
| 015 library_enhancements | 006 exercise_muscles_insert_policy |
| 018 security_hardening | 007 drop_sessions_view |
| | 008 fix_personal_records_unique |
| | 009 muscle_groups_rls |
| | 010 exercises_updated_at |
| | 013 soreness_reports |
| | 016 sets_updated_at |
| | 017 user_session_names |
| | **019 schema_enrichment** (uncommitted) |
| | **020 seed_enrichment** (uncommitted) |
| | **021 deep_schema_enrichment** (uncommitted) |
| | **022 deep_seed_enrichment** (uncommitted) |

### 3.2 Risk

The 12 committed-but-unapplied migrations (002-010, 013, 016-017) contain important fixes:
- 1RM trigger fix (002), deadlift muscle mapping (003), missing indexes (004), cascade fixes (005)
- RLS policies for exercise_muscles (006), muscle_groups (009)
- Soreness reports table (013), sets updated_at trigger (016), user session names (017)

The 4 uncommitted migrations (019-022) introduce new tables, views, triggers, and seed data that the new backend services depend on.

**The deployed backend code may be calling queries that depend on schema objects that don't exist yet.**

---

## 4. Security Findings

### CRITICAL

#### SEC-1: Supabase PAT Hardcoded in Source Code

**File:** `scripts/seed_via_api.py:13`

```python
TOKEN = "sbp_e054eedb99faa2fa56e52802db6dc5b81f8e066f"
```

A live Supabase Management API Personal Access Token is hardcoded. This file is NOT in `.gitignore`. If committed, anyone with repo read access gets full management API access to the production database — schema destruction, data exfiltration, admin user creation.

**Action required:**
1. Revoke the token immediately at Supabase dashboard
2. Replace with `os.environ["SUPABASE_PAT"]`
3. Add `scripts/seed_via_api.py` to `.gitignore`

#### SEC-2: Handoff File with Production Secrets Still on Disk

**File:** `docs/deployment/handoff.json`

Contains: DB connection string with password, JWT secret (allows forging any user's JWT), Supabase anon key, Sentry DSNs. The file IS in `.gitignore` but per the project's own conventions: "Once all phases are complete and verified, delete the handoff file." All 3 phases are complete.

**Action required:** Delete the file now. Rotate JWT secret and DB password if any exposure is suspected.

### HIGH

#### SEC-3: SECURITY DEFINER Function Callable Cross-User

**File:** `supabase/migrations/021_deep_schema_enrichment.sql:98`

`recompute_workout_clusters(p_user_id uuid, p_training_date date)` is `SECURITY DEFINER` and callable by any authenticated user via PostgREST RPC. No caller identity check — any user can pass another user's UUID and modify their workout cluster assignments.

**Action required:** Add migration 023:
```sql
REVOKE EXECUTE ON FUNCTION recompute_workout_clusters(uuid, date) FROM PUBLIC, authenticated;
GRANT EXECUTE ON FUNCTION recompute_workout_clusters(uuid, date) TO service_role;
```

#### SEC-4: Timezone Column Lacks Validation

**File:** `supabase/migrations/019_schema_enrichment.sql:291`

`profiles.timezone` is user-writable text with no CHECK constraint. Invalid values cause every INSERT to `sets` to throw a PostgreSQL error (self-DoS). Add:
```sql
CHECK (timezone ~ '^[A-Za-z][A-Za-z0-9/_+-]{1,63}$')
```

### MEDIUM

- **SEC-5:** Unbounded `notes` text fields on `body_weight_log`, `workout_feedback`, `mesocycles` — add `CHECK (length(notes) <= 2000)`
- **SEC-6:** `exercise_substitutions` write protection relies on implicit RLS deny (correct but fragile)

---

## 5. QA Findings

### CRITICAL

#### QA-1: Zero Test Coverage for 4 New Services

No tests exist for: `composite_score_service.py`, `muscle_frequency_service.py`, `staleness_service.py`, `load_distribution_service.py`. These contain non-trivial logic (entropy calculations, Jaccard similarity, timezone-aware DOW conversion).

### HIGH

#### QA-2: Weight Unit Normalization Missing in Frontend

**File:** `frontend/src/hooks/useMuscleVolume.ts:80`

```typescript
const volume = set.weight * set.reps;
```

Does not account for `weight_unit` (kg vs lb). Users logging in pounds get ~2.2x inflated volume. The backend's `training_day_summary` view correctly normalizes to kg, but the frontend hook doesn't. The query also doesn't select `weight_unit`.

#### QA-3: Dashboard Test Docstring Stale

`test_new_analytics.py:571` says "13 metrics" but dashboard now has 17. The test doesn't assert the 4 newest fields.

### MEDIUM

- **QA-4:** Migration 019 not wrapped in `BEGIN`/`COMMIT` (unlike 021/022)
- **QA-5:** Comment says `equipment_usage_stats` but view is `exercise_usage_stats` (019:325)
- **QA-6:** Composite score's progressive overload dimension excluded for most users (requires 3+ days per exercise in 28-day window)
- **QA-7:** `muscle_frequency_service.py` counts calendar dates, not training sessions (misses two-a-day training)

---

## 6. Architecture Findings

### Data Flow Dead Zone

Seven new tables and five new columns from migrations 019-021 are typed in the frontend (`database.ts`) but **zero backend service files read from them**:

| New Table/Column | Should Feed Into | Current Status |
|-----------------|------------------|----------------|
| `workout_feedback` (RPE, sleep, readiness) | `recovery_service.py`, `session_quality_service.py` | Not wired |
| `body_weight_log` | `strength_standards_service.py` (BW multiples) | Not wired |
| `training_volume_targets` | `volume_landmarks_service.py` | Uses hardcoded defaults |
| `mesocycles` | `periodization_service.py` | Uses heuristic detection |
| `workout_cluster_id` | Backend post-set-mutation hook | No caller exists |

### Type Mismatches

1. **`AnalysisReport` duplication:** `useAnalysis.ts` defines its own `AnalysisReport` (missing `status`, `report_type`, `evidence`, `recommendation_scope_id`) vs `types/database.ts`. Components importing from both will shadow.
2. **`FeatureFlags` gap:** Backend returns `advancedAnalyticsEnabled: true` but frontend `FeatureFlags` interface doesn't declare it.

### Performance Notes

- Dashboard endpoint fires 17 parallel `asyncpg.Pool.acquire()` calls with `max_size=10` pool — 7 will queue
- Frontend `fetchUserSets` loads up to 5,000 raw rows (now ~25% heavier with new columns). `training_day_summary` view and `exercise_usage_stats` view exist but are unused by the frontend
- Calendar heatmap groups by `logged_at.slice(0,10)` in UTC, not by `training_date` — wrong day for non-UTC users

---

## 7. Recommended Action Plan

### Immediate (Before Any Commit)

| # | Action | Owner | Severity |
|---|--------|-------|----------|
| 1 | Revoke Supabase PAT `sbp_e054ee...` | Human | CRITICAL |
| 2 | Delete `docs/deployment/handoff.json` | Human | CRITICAL |
| 3 | Add `scripts/seed_via_api.py` to `.gitignore` | Dev | CRITICAL |
| 4 | Replace hardcoded PAT with env var in `seed_via_api.py` | Dev | CRITICAL |

### Before Push to Main

| # | Action | Severity |
|---|--------|----------|
| 5 | Apply 12 missing committed migrations (002-010, 013, 016-017) to Supabase | CRITICAL |
| 6 | Add `REVOKE EXECUTE` for `recompute_workout_clusters` from public/authenticated | HIGH |
| 7 | Add timezone CHECK constraint to profiles | HIGH |
| 8 | Fix `AnalysisReport` type duplication in `useAnalysis.ts` | HIGH |
| 9 | Add `advancedAnalyticsEnabled` to `FeatureFlags` interface | HIGH |
| 10 | Add weight_unit normalization to `useMuscleVolume.ts` | HIGH |

### After Push (Follow-up)

| # | Action | Severity |
|---|--------|----------|
| 11 | Write tests for composite_score, muscle_frequency, staleness, load_distribution services | HIGH |
| 12 | Wire `workout_feedback` into `recovery_service.py` | MEDIUM |
| 13 | Wire `training_volume_targets` into `volume_landmarks_service.py` | MEDIUM |
| 14 | Update frontend calendar bucketing to use `training_date` | MEDIUM |
| 15 | Route frontend analytics through `training_day_summary` view | MEDIUM |
| 16 | Add `created_at` to `training_volume_targets` table | LOW |
| 17 | Wrap migration 019 in `BEGIN`/`COMMIT` | LOW |
| 18 | Add length constraints to `notes` columns | LOW |

---

## 8. Stash Review

Two stashes exist:
- `stash@{0}`: WIP on main: `caed2d9 chore: add handoff.json to .gitignore`
- `stash@{1}`: WIP on main: `039fb17 chore: add handoff.json to .gitignore`

Both reference commits related to adding `handoff.json` to `.gitignore`. Since that entry is already in `.gitignore`, these stashes likely contain superseded work. Review with `git stash show -p stash@{0}` and drop if no longer needed.

---

## Agents Used

| Agent | Role | Key Findings |
|-------|------|-------------|
| **QA Reviewer** | Code review, bug detection, test coverage | 14 findings (3 critical, 4 high, 5 medium, 2 low) |
| **Security Specialist** | Auth audit, RLS review, secrets scan | 6 findings (2 critical, 2 high, 2 medium) |
| **Software Architect** | Architecture consistency, data flow, contracts | 8 findings (type mismatches, dead zones, performance) |
| **Deployment Specialist** | Service health, migration sync, CI/CD status | 16 missing migrations, services healthy, CI configured |

---

*Generated by NanoClaw multi-agent audit — 2026-03-25*
