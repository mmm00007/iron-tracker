# Iron Tracker — Gap Implementation Plan

**Date**: 2026-03-24
**Scope**: Address all verified gaps between the initial specification documents and the current implementation.
**Method**: Deep-dive audit of all 5 spec docs (PRD, Design Document, UI/UX Spec, Implementation Plan, Addendum) cross-referenced against every source file, migration, and config in the repo.

---

## Table of Contents

1. [Gap Inventory](#1-gap-inventory)
2. [Accepted Deviations](#2-accepted-deviations)
3. [Phase 1 — CI/CD & Testing Foundation](#3-phase-1--cicd--testing-foundation)
4. [Phase 2 — Core UX Completions](#4-phase-2--core-ux-completions)
5. [Phase 3 — Should-Have Features](#5-phase-3--should-have-features)
6. [Phase 4 — AI Intelligence Layer](#6-phase-4--ai-intelligence-layer)
7. [Phase 5 — Polish & Optimization](#7-phase-5--polish--optimization)
8. [Dependency Graph](#8-dependency-graph)
9. [Estimated Effort](#9-estimated-effort)

---

## 1. Gap Inventory

Every gap was verified by reading source files, not inferred. Status codes:
- **MISSING** — No implementation exists
- **PARTIAL** — Code exists but is incomplete or not wired up
- **DEVIATION** — Implemented differently than spec (may be acceptable)

### 1.1 Infrastructure & CI/CD

| ID | Gap | Spec Reference | Status | Current State |
|----|-----|---------------|--------|---------------|
| G-01 | GitHub Actions backend CI | M1-S3 | MISSING | No `.github/workflows/` directory exists |
| G-02 | GitHub Actions frontend CI | M1-S4 | MISSING | Same |
| G-03 | mypy type checking | M1-S3 (ruff + mypy) | MISSING | ruff configured; no mypy in pyproject.toml |
| G-04 | Netlify config in repo | M1-S5 | MISSING | Configured via UI only; no `netlify.toml` |
| G-05 | Render config in repo | M1-S5 | MISSING | Configured via UI only; no `render.yaml` |

### 1.2 Database & Backend

| ID | Gap | Spec Reference | Status | Current State |
|----|-----|---------------|--------|---------------|
| G-06 | PR detection trigger | M2-S4 | MISSING | No `check_personal_record()` PG function; done client-side in `usePRDetection.ts` |
| G-07 | `updated_at` on sets table | M10-S5 | MISSING | Column does not exist; sets treated as immutable |
| G-08 | `session_group` generated column | M2-S3 | MISSING | Not in schema; sessions derived client-side |
| G-09 | `user_session_names` table | M7-S5 | MISSING | No table, no session naming feature |
| G-10 | Supabase RPC functions | M7-S1, M8-S7 | MISSING | No `get_user_sessions()`, `compute_exercise_1rm_trend()`, `compute_weekly_volume()` |
| G-11 | Backend exercise search endpoint | M3-S5 | MISSING | All exercise queries go direct to Supabase |
| G-12 | Backend deload endpoint | M12-S2 | MISSING | No `/api/recommendations/deload-status` |
| G-13 | Backend recovery endpoint | M12-S3 | MISSING | No `/api/recommendations/recovery` |
| G-14 | Backend coach endpoint | M12-S7 | MISSING | Has `/api/ai/analyze` but not conversational `/api/ai/coach` |
| G-15 | Backend weight suggestion endpoint | M12-S1 | MISSING | Rollout flag `weightSuggestionEnabled=true` but no endpoint |
| G-16 | WeightProgressionEngine service | M12-S1 | MISSING | No service class |
| G-17 | Muscle recovery score model | M12-S3 | MISSING | No service class |
| G-18 | Redis/persistent rate limiting | Design Doc §3.1 | MISSING | Rate limiting is in-memory dict; resets on restart |
| G-19 | AI token usage logging | M11-S6 | MISSING | Only error logging; no per-request token tracking |
| G-20 | Pydantic-to-TypeScript type sync | M3-S6 | MISSING | Types manually maintained in `database.ts` |

### 1.3 Frontend UX

| ID | Gap | Spec Reference | Status | Current State |
|----|-----|---------------|--------|---------------|
| G-21 | Swipe-to-delete integration | M5-S7 | PARTIAL | `useSwipeToDelete.ts` exists (71 lines) but NOT wired to SetRow; only has IconButton delete |
| G-22 | Swipe-to-edit / inline edit | M5-S8 | MISSING | SetRow is read-only; no edit mode |
| G-23 | Soreness tracking UI + prompts | M9-S8, US-501 | MISSING | `soreness_reports` table exists; no UI for reporting or body silhouette tapping |
| G-24 | Session naming UI | M7-S5 | MISSING | SessionDetailPage is read-only |
| G-25 | Rest timer browser notifications | M6-S5 | MISSING | Visual-only timer; no `Notification` API or `navigator.vibrate` |
| G-26 | Light mode toggle | US-605, UI/UX §1.2 | MISSING | Hardcoded `palette.mode: 'dark'` in `theme.ts` |
| G-27 | Alphabet scrubber | M3-S2, UI/UX §3.1.1 | MISSING | Exercise list has no A-Z scrubber |
| G-28 | Recovery heatmap visualization | M12-S6 | MISSING | No muscle recovery heatmap on stats |
| G-29 | Sync conflict resolution | M10-S5 | MISSING | No `updated_at` comparison; no last-write-wins logic |
| G-30 | Volume chart stacked by muscle group | M8-S6 | DEVIATION | Stacked by variant (correct for exercise view); spec also wants per-muscle-group stacking on stats dashboard |

### 1.4 Testing

| ID | Gap | Spec Reference | Status | Current State |
|----|-----|---------------|--------|---------------|
| G-31 | Backend test coverage (90% target) | §1.2 | PARTIAL | 5 test functions across 2 files; ~5% estimated coverage |
| G-32 | Frontend test coverage (85% target) | §1.2 | PARTIAL | 2 test files; ~2% estimated coverage |
| G-33 | Integration tests (RLS, auth flows) | §1.2 | MISSING | No integration tests |
| G-34 | E2E test scenarios per spec | §1.2 | PARTIAL | 1 audit harness covers flows; not the 15-20 discrete scenarios from spec |
| G-35 | Contract tests (type drift detection) | §1.3 | MISSING | No CI step to detect type drift |

---

## 2. Accepted Deviations

These items differ from the spec but are **functionally correct or superior**. No action required unless explicitly requested.

| Item | Spec Says | Actual | Why It's Acceptable |
|------|-----------|--------|-------------------|
| JWT verification | JWKS asymmetric | HS256 symmetric with `SUPABASE_JWT_SECRET` | Supabase's standard approach; simpler, equally secure for this use case |
| Service worker | Workbox | Custom `sw.js` | Implements identical strategies (network-first, cache-first); fewer dependencies |
| Exercise schema | `primary_muscles text[]` array columns | Normalized `exercise_muscles` junction table with `activation_percent` | Superior: NSCA-validated, allows richer queries, proper relational modeling |
| DB client | `supabase-py` async | `asyncpg` direct | Lower latency, full SQL control, no ORM overhead |
| Session grouping | Supabase RPC `get_user_sessions()` | Client-side `sessionGrouping.ts` | Acceptable at current scale; avoids server round-trip for history browsing |
| PR detection | PostgreSQL trigger `check_personal_record()` | Client-side `usePRDetection.ts` | Instant UX (no server wait); trade-off: PRs may miss if user clears cache before sync |
| Exercise count | ~400 seed exercises | 873 exercises from free-exercise-db | Exceeds spec |
| AI max_tokens | 300 | 1024 (identify) / 1000 (analyze) | Allows richer responses; cost is marginal |
| Bottom nav | 4 tabs (Log, History, Stats, Profile) | 5 destinations + Home dashboard | Richer navigation; extra Home page is a bonus |
| Data export | Listed as gap initially | `DataExport.tsx` (155 lines) | **Already implemented** — CSV + JSON for sets and PRs |
| Weight suggestion chip | Listed as gap initially | Lines 463-497 of `SetLoggerPage.tsx` | **Already implemented** — RPE-based suggestion with color coding |
| Numpad quick-select | Needed verification | Lines 125-153 of `NumpadBottomSheet.tsx` | **Already implemented** — last 4 unique values shown |

---

## 3. Phase 1 — CI/CD & Testing Foundation

**Goal**: Establish the quality gates that every subsequent phase depends on. No feature work ships without CI catching regressions.

**Duration**: ~1 week

### Step 1.1 — GitHub Actions Backend CI (G-01, G-03)

**Create** `.github/workflows/backend-ci.yml`

```yaml
# Triggers: push to main/develop, all PRs
# Steps: checkout → setup Python 3.12 → uv sync → ruff check → mypy → pytest --cov
# Fail on: any lint error, type error, or test failure
# Artifact: coverage report
```

**Substeps**:
1. Create workflow file with matrix for Python 3.12
2. Add `[tool.mypy]` section to `backend/pyproject.toml`:
   - `strict = true`, `plugins = ["pydantic.mypy"]`
   - Ignore errors in `__pycache__`, `.venv`
3. Fix any mypy errors that surface (estimate: 10-20 type annotations to add/fix)
4. Verify: push a deliberately failing test → CI red; push fix → CI green

**Files to create/modify**:
- `NEW: .github/workflows/backend-ci.yml`
- `EDIT: backend/pyproject.toml` (add mypy config)

### Step 1.2 — GitHub Actions Frontend CI (G-02)

**Create** `.github/workflows/frontend-ci.yml`

```yaml
# Triggers: push to main/develop, all PRs
# Steps: checkout → setup Node 20 → npm ci → eslint → tsc --noEmit → vitest run --coverage
# Fail on: any lint error, type error, or test failure
# Artifact: coverage report
```

**Files to create**:
- `NEW: .github/workflows/frontend-ci.yml`

### Step 1.3 — Netlify & Render Config in Repo (G-04, G-05)

**Create** declarative config files so deploys are reproducible.

**Files to create**:
- `NEW: netlify.toml` — build command, publish dir, redirect rules, env var references
- `NEW: render.yaml` — service type, build/start commands, env groups

### Step 1.4 — Backend Test Coverage Push (G-31)

Write tests for all untested backend code. Target: 90% line coverage on business logic.

**Test files to create**:

| File | Tests | Coverage Target |
|------|-------|----------------|
| `tests/test_analytics.py` | `test_weekly_summary_returns_data`, `test_weekly_summary_empty_user`, `test_weekly_summary_delta_computation`, `test_compute_1rm_trend`, `test_1rm_epley_formula`, `test_1rm_empty_exercise` | analytics_service.py |
| `tests/test_analysis.py` | `test_analyze_success`, `test_analyze_rate_limit`, `test_analyze_no_data` | analysis_service.py |
| `tests/test_weekly_summary_service.py` | `test_generate_summaries`, `test_skip_inactive_user` | weekly_summary_service.py |
| `tests/test_auth.py` | `test_valid_jwt`, `test_expired_jwt_401`, `test_missing_header_401`, `test_malformed_token_401` | auth.py |
| `tests/test_config.py` | `test_settings_from_env`, `test_missing_required_raises` | config.py |

**Files to create**:
- `NEW: backend/tests/test_analytics.py`
- `NEW: backend/tests/test_analysis.py`
- `NEW: backend/tests/test_weekly_summary_service.py`
- `NEW: backend/tests/test_auth.py`
- `NEW: backend/tests/test_config.py`

### Step 1.5 — Frontend Test Coverage Push (G-32)

Write tests for core hooks, components, and utilities. Target: 85% coverage on business logic.

**Priority test files** (highest-value code paths first):

| File to Test | Test File | Key Tests |
|-------------|-----------|-----------|
| `useSets.ts` | `useSets.test.ts` | log set mutation payload, optimistic update, rollback on error, pre-fill from last set |
| `usePRDetection.ts` / `prDetection.ts` | `prDetection.test.ts` | Epley formula, PR detected, no PR, first-set-is-PR, rep max PR |
| `sessionGrouping.ts` | `sessionGrouping.test.ts` | single session, two sessions (>90min gap), midnight span, empty sets |
| `deloadDetection.ts` | `deloadDetection.test.ts` | deload triggered, no deload, edge cases |
| `analytics.ts` | `analytics.test.ts` | weekly snapshot, volume by muscle, training frequency, streak |
| `formatters.ts` | `formatters.test.ts` | volume formatting, relative dates |
| `SetLoggerPage.tsx` | `SetLoggerPage.test.tsx` | renders zones, stepper +5/-5, pre-fill, log set button |
| `VariantChipRow.tsx` | `VariantChipRow.test.tsx` | renders chips, MRU order, hidden with <=1, add chip |
| `RestTimerPill.tsx` | `RestTimerPill.test.tsx` | visible when running, hidden when idle, time format, color transition |
| `WeeklySnapshotCard.tsx` | `WeeklySnapshotCard.test.tsx` | improvement (green), decline (red), first week |
| `PRCelebration.tsx` | `PRCelebration.test.tsx` | renders on PR, auto-dismiss 4s, reduced motion |
| `NumpadBottomSheet.tsx` | `NumpadBottomSheet.test.tsx` | digit input, decimal, backspace, quick-select |
| `authStore.ts` | `authStore.test.ts` | sign in, sign out, session change |

**Files to create**: ~13 new test files adjacent to source.

### Step 1.6 — E2E Test Expansion (G-34)

The existing `live-audit.spec.ts` is a comprehensive smoke test. Add scenario-specific Playwright tests matching the spec.

**Files to create**:
- `NEW: frontend/e2e/exercises.spec.ts` — browse, search, create custom, muscle group filter
- `NEW: frontend/e2e/set-logging.spec.ts` — log first set, one-tap repeat, stepper, numpad, delete, edit
- `NEW: frontend/e2e/variants.spec.ts` — create first variant, switch variant, edit, delete
- `NEW: frontend/e2e/history.spec.ts` — session appears, detail drill-down, exercise history
- `NEW: frontend/e2e/rest-timer.spec.ts` — auto-starts, persists across tabs, +30s

---

## 4. Phase 2 — Core UX Completions

**Goal**: Close the remaining Must-Have UX gaps so the app matches the spec for daily training use.

**Duration**: ~1.5 weeks

### Step 2.1 — Wire Swipe-to-Delete into SetRow (G-21)

The `useSwipeToDelete.ts` hook (71 lines) already implements left-swipe with threshold, visual feedback, and haptics. It just needs to be integrated.

**Changes**:
1. Import `useSwipeToDelete` in the SetRow component
2. Attach pointer event handlers to the set row element
3. Add undo snackbar with 5-second timeout (on swipe complete, show snackbar; only fire DELETE mutation after timeout or on snackbar dismiss)
4. Remove the current IconButton delete (replaced by swipe gesture)

**Files to modify**:
- `EDIT: frontend/src/components/log/SetRow.tsx` — wire swipe handlers + undo snackbar

### Step 2.2 — Inline Set Editing (G-22)

Allow tap on a session set row to enter edit mode.

**Changes**:
1. Add `isEditing` state to SetRow
2. On tap: replace weight/reps display with editable TextFields + stepper buttons
3. Show Save/Cancel buttons in place of set number badge
4. Save triggers an UPDATE mutation; Cancel restores original values
5. Only sets from today's session are editable (check `logged_at` against today)

**Files to modify**:
- `EDIT: frontend/src/components/log/SetRow.tsx` — add edit mode
- `EDIT: frontend/src/hooks/useSets.ts` — add `useUpdateSet()` mutation hook

### Step 2.3 — Rest Timer Browser Notifications (G-25)

**Changes**:
1. On first timer start: call `Notification.requestPermission()`
2. On timer complete (in the Zustand store or RestTimerPill effect):
   - If permission granted: `new Notification('Rest Complete', { body: 'Time for your next set!' })`
   - Always: `navigator.vibrate?.([200, 100, 200])`
3. If permission denied: no error, just haptic

**Files to modify**:
- `EDIT: frontend/src/components/log/RestTimerPill.tsx` — add notification on completion
- `EDIT: frontend/src/stores/workoutStore.ts` — add `onComplete` callback if needed

### Step 2.4 — Sync Conflict Resolution (G-29, G-07)

**Changes**:

Database:
1. New migration: add `updated_at` column to `sets` table with `DEFAULT now()`
2. Add `set_updated_at` trigger on sets (reuse existing function)

Frontend:
3. In set update mutations: compare `updated_at` from server response against cached version
4. If server is newer → accept server data, update cache
5. If client is newer → keep client data (last-write-wins by `updated_at`)

**Files to create/modify**:
- `NEW: supabase/migrations/016_sets_updated_at.sql`
- `EDIT: frontend/src/hooks/useSets.ts` — add conflict check in `onSettled`

### Step 2.5 — Light Mode Toggle (G-26)

**Changes**:
1. Add `themeMode` to `profiles` table or use the existing `theme_seed_color` approach (store `'dark' | 'light'` in profile or Zustand)
2. Create a `useThemeMode` hook that reads from profile / localStorage
3. In `theme.ts`: make `palette.mode` dynamic based on the hook
4. Add toggle in Profile page (MUI Switch component)

**Files to modify**:
- `EDIT: frontend/src/theme.ts` — parameterize `palette.mode`
- `NEW: frontend/src/hooks/useThemeMode.ts`
- `EDIT: frontend/src/pages/profile/ProfilePage.tsx` — add toggle
- `EDIT: frontend/src/main.tsx` or `App.tsx` — wire dynamic theme

---

## 5. Phase 3 — Should-Have Features

**Goal**: Complete the "Should Have" features from the PRD priority matrix.

**Duration**: ~2 weeks

### Step 3.1 — Soreness Tracking UI (G-23)

This is a multi-component feature. The `soreness_reports` table (migration 013) already exists with RLS.

**Components to build**:

1. **SorenessPrompt dialog** — Appears on app open 24-48 hours after a session
   - Logic: query last session's `logged_at`; if 24-48h ago and no soreness report for that date → show prompt
   - Full-screen dialog with body silhouette SVG
   - Tappable muscle groups (16 groups from `muscle_groups` table)
   - Each muscle: 0-4 severity scale (slider or segmented buttons)
   - Save button inserts to `soreness_reports`

2. **Body silhouette component** — SVG with `svg_path_id` from muscle_groups table
   - Color-coded by soreness level (green=0, yellow=1-2, red=3-4)
   - Reusable for both soreness reporting and recovery visualization

3. **TanStack Query hooks**:
   - `useSorenessPrompt()` — determines if prompt should show
   - `useReportSoreness()` — mutation to insert reports
   - `useSorenessHistory(period)` — query recent reports

**Files to create**:
- `NEW: frontend/src/components/soreness/SorenessPrompt.tsx`
- `NEW: frontend/src/components/soreness/BodySilhouette.tsx`
- `NEW: frontend/src/hooks/useSoreness.ts`
- `EDIT: frontend/src/components/layout/AppLayout.tsx` — mount SorenessPrompt

### Step 3.2 — Session Naming (G-09, G-24)

**Database**:
1. New migration: create `user_session_names` table
   - Columns: `id` (uuid PK), `user_id` (FK), `session_start` (timestamptz), `session_end` (timestamptz), `name` (text), `created_at`
   - RLS: `user_id = auth.uid()`
   - Unique on `(user_id, session_start)`

**Frontend**:
2. Long-press handler on session card date header → reveals inline text input
3. `useSessionName(sessionStart)` query hook
4. `useRenameSession()` mutation hook
5. Display custom name above date when set

**Files to create/modify**:
- `NEW: supabase/migrations/016_user_session_names.sql` (or next number)
- `NEW: frontend/src/hooks/useSessionNames.ts`
- `EDIT: frontend/src/pages/history/HistoryPage.tsx` — add long-press + name display
- `EDIT: frontend/src/pages/history/SessionDetailPage.tsx` — show name in header

### Step 3.3 — Alphabet Scrubber on Exercise List (G-27)

**Changes**:
1. Build `AlphabetScrubber` component: fixed vertical strip on right edge, A-Z letters
2. On tap/drag: scroll exercise list to the corresponding letter section
3. Only show in "All Exercises" view (not in search or muscle group views)

**Files to create/modify**:
- `NEW: frontend/src/components/exercises/AlphabetScrubber.tsx`
- `EDIT: frontend/src/pages/log/ExerciseListPage.tsx` — integrate scrubber

### Step 3.4 — Volume Chart Stacked by Muscle Group (G-30)

The current `VolumeChart.tsx` stacks by variant (correct for per-exercise view). The stats dashboard also needs a muscle-group-level volume chart.

**Changes**:
1. Create `MuscleVolumeChart.tsx` — Recharts BarChart with ISO weeks on x-axis, stacked segments by muscle group
2. Hook: `useWeeklyMuscleVolume(period)` — query sets joined with exercise_muscles, grouped by week + muscle group
3. Add to StatsPage as a dashboard card

**Files to create/modify**:
- `NEW: frontend/src/components/stats/MuscleVolumeChart.tsx`
- `NEW: frontend/src/hooks/useMuscleVolume.ts`
- `EDIT: frontend/src/pages/stats/StatsPage.tsx` — add card

---

## 6. Phase 4 — AI Intelligence Layer

**Goal**: Build the deterministic recommendation engines and the LLM coaching layer (M12).

**Duration**: ~3 weeks

### Step 4.1 — WeightProgressionEngine (G-16, G-15)

**Backend service** at `backend/app/services/weight_progression.py`:

```
Class WeightProgressionEngine:
  suggest_weight(user_id, exercise_id, variant_id, target_rpe) -> SuggestionResult

  Algorithm:
    1. Fetch last N sets for exercise+variant
    2. Compute rolling e1RM (Epley)
    3. Apply target RPE percentage (RPE 8 ≈ 80% of 1RM, etc.)
    4. Round to nearest weight_increment from variant
    5. Return: suggested_weight, rationale_text
```

**Endpoint**: `GET /api/recommendations/weight-suggestion?exercise_id=X&variant_id=Y&target_rpe=8`

**Frontend**: The weight suggestion chip already exists (SetLoggerPage lines 463-497) but uses simple RPE comparison. Enhance it to call the backend endpoint when online, fall back to client-side logic when offline.

**Files to create/modify**:
- `NEW: backend/app/services/weight_progression.py`
- `NEW: backend/app/routers/recommendations.py`
- `EDIT: backend/app/main.py` — include recommendations router
- `EDIT: backend/app/models/schemas.py` — add WeightSuggestion model
- `EDIT: frontend/src/pages/log/SetLoggerPage.tsx` — enhance suggestion chip with API call
- `NEW: backend/tests/test_weight_progression.py`

### Step 4.2 — Deload Recommendation Engine (G-12)

**Backend service** at `backend/app/services/deload_engine.py`:

```
Class DeloadEngine:
  check_deload_status(user_id) -> DeloadStatus

  Triggers:
    - 4+ weeks consecutive volume increase
    - Declining e1RM for 2+ weeks on key compounds
    - Average RPE > 8.5 over 2 weeks

  Prescription:
    - Volume reduction: 40-60%
    - Intensity reduction: 10-15%
    - Duration: 1 week
```

**Endpoint**: `GET /api/recommendations/deload-status`

**Frontend**: The existing `DeloadBanner.tsx` + `deloadDetection.ts` use basic volume-drop detection. Replace with backend API call (keep client-side as offline fallback).

**Files to create/modify**:
- `NEW: backend/app/services/deload_engine.py`
- `EDIT: backend/app/routers/recommendations.py` — add deload endpoint
- `EDIT: backend/app/models/schemas.py` — add DeloadStatus model
- `EDIT: frontend/src/utils/deloadDetection.ts` — add API integration
- `NEW: backend/tests/test_deload_engine.py`

### Step 4.3 — Muscle Recovery Score Model (G-17, G-13, G-28)

**Backend service** at `backend/app/services/recovery_model.py`:

```
Class RecoveryModel:
  compute_recovery(user_id) -> list[MuscleRecoveryScore]

  Per muscle group:
    - Base: hours since last training (exponential decay toward 100%)
    - Penalty: higher volume → slower recovery
    - Penalty: soreness level 3-4 adds recovery penalty
    - Score: 0-100%
```

**Endpoint**: `GET /api/recommendations/recovery`

**Frontend**:
1. `RecoveryHeatmap.tsx` — Body silhouette (reuse from Step 3.1) colored by recovery score
2. Add to StatsPage dashboard
3. `useRecoveryScores()` hook

**Files to create/modify**:
- `NEW: backend/app/services/recovery_model.py`
- `EDIT: backend/app/routers/recommendations.py` — add recovery endpoint
- `EDIT: backend/app/models/schemas.py` — add MuscleRecoveryScore model
- `NEW: frontend/src/components/stats/RecoveryHeatmap.tsx`
- `NEW: frontend/src/hooks/useRecovery.ts`
- `EDIT: frontend/src/pages/stats/StatsPage.tsx` — add recovery card
- `NEW: backend/tests/test_recovery_model.py`

### Step 4.4 — LLM Coaching Endpoint (G-14)

**Endpoint**: `POST /api/ai/coach`

```json
Request:  { "query": "Why should I deload?", "context_weeks": 4 }
Response: { "response": "Based on your last 4 weeks...", "sources": [...] }
```

**Backend**:
1. Inject context: last N weeks of training data, recovery scores, active PRs, user profile
2. System prompt: explain deterministic engine outputs, do NOT make independent programming decisions
3. Token budget: 2000 input, 500 output
4. Rate limit: 5 queries/user/day

**Files to create/modify**:
- `NEW: backend/app/services/coaching_service.py`
- `EDIT: backend/app/routers/ai.py` — add `/api/ai/coach` endpoint
- `EDIT: backend/app/models/schemas.py` — add CoachRequest, CoachResponse
- `NEW: backend/tests/test_coaching.py`

**Frontend** (future — profile tab integration): Not in scope for this phase. The endpoint is backend-ready for when a conversational UI is built.

### Step 4.5 — AI Token Usage Logging (G-19)

**Changes**:
1. After each Claude API call: log `user_id`, `endpoint`, `input_tokens`, `output_tokens`, `model`, `timestamp`
2. Store in a lightweight `ai_usage_log` table or just structured logging (Sentry breadcrumbs or stdout JSON)
3. For cost monitoring: aggregate token usage per day/user

**Files to modify**:
- `EDIT: backend/app/services/ai_service.py` — extract `usage` from Claude response, log it
- `EDIT: backend/app/services/analysis_service.py` — same
- `EDIT: backend/app/services/coaching_service.py` — same (once created)

---

## 7. Phase 5 — Polish & Optimization

**Goal**: Close remaining spec gaps and achieve launch checklist compliance.

**Duration**: ~1.5 weeks

### Step 5.1 — Backend Exercise Search Endpoint (G-11)

**Endpoint**: `GET /api/exercises/search?q={query}&limit=20`

Uses PostgreSQL trigram similarity (`pg_trgm` extension) or `ILIKE` with ranking. Returns exercises ordered by relevance.

**Files to create/modify**:
- `NEW: backend/app/routers/exercises.py`
- `EDIT: backend/app/main.py` — include exercises router
- `NEW: supabase/migrations/0XX_exercise_search_index.sql` — create trigram GIN index on `exercises.name`
- `NEW: backend/tests/test_exercises.py`

### Step 5.2 — Pydantic-to-TypeScript Type Sync (G-20, G-35)

**Setup**:
1. Install `openapi-typescript` as a dev dependency in frontend
2. Add npm script: `"generate:types": "openapi-typescript http://localhost:8000/openapi.json -o src/api/types.generated.ts"`
3. Add CI step: regenerate types → `git diff --exit-code` → fail if drifted

**Files to create/modify**:
- `EDIT: frontend/package.json` — add `generate:types` script and `openapi-typescript` dev dep
- `NEW: frontend/src/api/types.generated.ts` — auto-generated (gitignored or committed)
- `EDIT: .github/workflows/frontend-ci.yml` — add type drift detection step

### Step 5.3 — Redis for Persistent Rate Limiting (G-18)

Replace in-memory rate limiting with Redis (Upstash) for persistence across deploys.

**Changes**:
1. Add `upstash-redis` or `redis` to pyproject.toml
2. Create `backend/app/core/redis.py` — connection setup
3. Replace `_rate_limit_store` dict with Redis `INCR` + `EXPIRE` (TTL = end of UTC day)
4. Replace `_image_cache` OrderedDict with Redis `SET` + `EX` (TTL = 30 days)

**Files to create/modify**:
- `EDIT: backend/pyproject.toml` — add redis dependency
- `NEW: backend/app/core/redis.py`
- `EDIT: backend/app/routers/ai.py` — swap in-memory → Redis
- `EDIT: backend/app/config.py` — add `REDIS_URL` setting

### Step 5.4 — Integration Tests (G-33)

Write integration tests that hit a real Supabase test project.

**Test file**: `backend/tests/integration/test_rls.py`

Key tests:
- `test_user_cannot_read_other_users_sets`
- `test_user_cannot_read_other_users_variants`
- `test_seed_exercises_readable_by_authenticated`
- `test_anon_cannot_read_exercises`
- `test_user_cannot_modify_seed_exercises`
- `test_variant_isolation`
- `test_set_check_constraints` (weight >= 0, rpe 1-10)

**Files to create**:
- `NEW: backend/tests/integration/__init__.py`
- `NEW: backend/tests/integration/test_rls.py`
- `NEW: backend/tests/integration/conftest.py` — test Supabase credentials

### Step 5.5 — Performance Audit (Launch Checklist)

Run and document:
- Lighthouse Performance, PWA, Accessibility scores (target >= 90 each)
- FCP < 1.5s on 4G throttle
- Bundle size < 200KB gzipped (initial route)
- EXPLAIN ANALYZE on key queries

No code changes — just run audits and fix any blockers that surface.

---

## 8. Dependency Graph

```
Phase 1 (CI/CD + Tests)
  ├── 1.1 Backend CI ─────────────── independent
  ├── 1.2 Frontend CI ────────────── independent
  ├── 1.3 Deploy configs ─────────── independent
  ├── 1.4 Backend tests ──────────── depends on 1.1 (CI runs them)
  ├── 1.5 Frontend tests ─────────── depends on 1.2 (CI runs them)
  └── 1.6 E2E tests ──────────────── depends on 1.2

Phase 2 (Core UX) — can start in parallel with Phase 1
  ├── 2.1 Swipe-to-delete ────────── independent
  ├── 2.2 Inline set editing ─────── independent
  ├── 2.3 Timer notifications ────── independent
  ├── 2.4 Sync conflict resolution ── independent (DB migration)
  └── 2.5 Light mode toggle ─────── independent

Phase 3 (Should-Have) — after Phase 2
  ├── 3.1 Soreness UI ────────────── independent
  ├── 3.2 Session naming ─────────── independent (DB migration)
  ├── 3.3 Alphabet scrubber ──────── independent
  └── 3.4 Muscle volume chart ────── independent

Phase 4 (AI Intelligence) — after Phase 1 backend tests
  ├── 4.1 Weight progression ─────── independent
  ├── 4.2 Deload engine ──────────── depends on 4.1 (shared router)
  ├── 4.3 Recovery model ─────────── depends on 3.1 (uses soreness data)
  ├── 4.4 LLM coaching ───────────── depends on 4.1, 4.2, 4.3 (injects their outputs)
  └── 4.5 Token logging ──────────── independent

Phase 5 (Polish) — after Phase 4
  ├── 5.1 Exercise search endpoint ── independent
  ├── 5.2 Type sync ──────────────── depends on 5.1 (needs all endpoints for OpenAPI)
  ├── 5.3 Redis rate limiting ────── independent
  ├── 5.4 Integration tests ──────── depends on all DB migrations
  └── 5.5 Performance audit ──────── depends on all features complete
```

---

## 9. Estimated Effort

| Phase | Steps | Estimated Duration | Can Parallelize With |
|-------|-------|-------------------|---------------------|
| **Phase 1** — CI/CD & Testing | 6 steps | 5-7 days | Phase 2 |
| **Phase 2** — Core UX | 5 steps | 5-7 days | Phase 1 |
| **Phase 3** — Should-Have | 4 steps | 7-10 days | — |
| **Phase 4** — AI Intelligence | 5 steps | 10-15 days | — |
| **Phase 5** — Polish | 5 steps | 5-7 days | — |
| **Total** | **25 steps** | **~5-6 weeks** | |

### Priority if time-constrained

If only 2 weeks are available, focus on:
1. **Phase 1.1-1.2** (CI/CD) — 2 days
2. **Phase 2.1-2.3** (swipe gestures + notifications) — 3 days
3. **Phase 1.4-1.5** (critical tests only) — 3 days
4. **Phase 3.1** (soreness UI) — 2 days

These deliver the highest spec compliance per day invested.

---

## Appendix: Files Inventory

### Files to Create (New)

| # | Path | Phase |
|---|------|-------|
| 1 | `.github/workflows/backend-ci.yml` | 1.1 |
| 2 | `.github/workflows/frontend-ci.yml` | 1.2 |
| 3 | `netlify.toml` | 1.3 |
| 4 | `render.yaml` | 1.3 |
| 5 | `backend/tests/test_analytics.py` | 1.4 |
| 6 | `backend/tests/test_analysis.py` | 1.4 |
| 7 | `backend/tests/test_weekly_summary_service.py` | 1.4 |
| 8 | `backend/tests/test_auth.py` | 1.4 |
| 9 | `backend/tests/test_config.py` | 1.4 |
| 10 | `frontend/src/utils/prDetection.test.ts` | 1.5 |
| 11 | `frontend/src/utils/sessionGrouping.test.ts` | 1.5 |
| 12 | `frontend/src/utils/deloadDetection.test.ts` | 1.5 |
| 13 | `frontend/src/utils/analytics.test.ts` | 1.5 |
| 14 | `frontend/src/utils/formatters.test.ts` | 1.5 |
| 15 | `frontend/src/hooks/useSets.test.ts` | 1.5 |
| 16 | `frontend/src/components/variants/VariantChipRow.test.tsx` | 1.5 |
| 17 | `frontend/src/components/log/RestTimerPill.test.tsx` | 1.5 |
| 18 | `frontend/src/components/stats/WeeklySnapshotCard.test.tsx` | 1.5 |
| 19 | `frontend/src/components/log/PRCelebration.test.tsx` | 1.5 |
| 20 | `frontend/src/components/log/NumpadBottomSheet.test.tsx` | 1.5 |
| 21 | `frontend/src/stores/authStore.test.ts` | 1.5 |
| 22 | `frontend/src/pages/log/SetLoggerPage.test.tsx` (expand existing) | 1.5 |
| 23 | `frontend/e2e/exercises.spec.ts` | 1.6 |
| 24 | `frontend/e2e/set-logging.spec.ts` | 1.6 |
| 25 | `frontend/e2e/variants.spec.ts` | 1.6 |
| 26 | `frontend/e2e/history.spec.ts` | 1.6 |
| 27 | `frontend/e2e/rest-timer.spec.ts` | 1.6 |
| 28 | `supabase/migrations/016_sets_updated_at.sql` | 2.4 |
| 29 | `frontend/src/hooks/useThemeMode.ts` | 2.5 |
| 30 | `frontend/src/components/soreness/SorenessPrompt.tsx` | 3.1 |
| 31 | `frontend/src/components/soreness/BodySilhouette.tsx` | 3.1 |
| 32 | `frontend/src/hooks/useSoreness.ts` | 3.1 |
| 33 | `supabase/migrations/017_user_session_names.sql` | 3.2 |
| 34 | `frontend/src/hooks/useSessionNames.ts` | 3.2 |
| 35 | `frontend/src/components/exercises/AlphabetScrubber.tsx` | 3.3 |
| 36 | `frontend/src/components/stats/MuscleVolumeChart.tsx` | 3.4 |
| 37 | `frontend/src/hooks/useMuscleVolume.ts` | 3.4 |
| 38 | `backend/app/services/weight_progression.py` | 4.1 |
| 39 | `backend/app/routers/recommendations.py` | 4.1 |
| 40 | `backend/tests/test_weight_progression.py` | 4.1 |
| 41 | `backend/app/services/deload_engine.py` | 4.2 |
| 42 | `backend/tests/test_deload_engine.py` | 4.2 |
| 43 | `backend/app/services/recovery_model.py` | 4.3 |
| 44 | `backend/tests/test_recovery_model.py` | 4.3 |
| 45 | `frontend/src/components/stats/RecoveryHeatmap.tsx` | 4.3 |
| 46 | `frontend/src/hooks/useRecovery.ts` | 4.3 |
| 47 | `backend/app/services/coaching_service.py` | 4.4 |
| 48 | `backend/tests/test_coaching.py` | 4.4 |
| 49 | `backend/app/routers/exercises.py` | 5.1 |
| 50 | `backend/tests/test_exercises.py` | 5.1 |
| 51 | `supabase/migrations/0XX_exercise_search_index.sql` | 5.1 |
| 52 | `frontend/src/api/types.generated.ts` | 5.2 |
| 53 | `backend/app/core/redis.py` | 5.3 |
| 54 | `backend/tests/integration/test_rls.py` | 5.4 |

### Files to Modify (Existing)

| # | Path | Phase | Change |
|---|------|-------|--------|
| 1 | `backend/pyproject.toml` | 1.1, 5.3 | Add mypy config, redis dep |
| 2 | `frontend/src/components/log/SetRow.tsx` | 2.1, 2.2 | Wire swipe + edit mode |
| 3 | `frontend/src/hooks/useSets.ts` | 2.2, 2.4 | Add useUpdateSet, conflict check |
| 4 | `frontend/src/components/log/RestTimerPill.tsx` | 2.3 | Add Notification API |
| 5 | `frontend/src/theme.ts` | 2.5 | Dynamic palette.mode |
| 6 | `frontend/src/main.tsx` | 2.5 | Wire theme provider |
| 7 | `frontend/src/pages/profile/ProfilePage.tsx` | 2.5 | Add theme toggle |
| 8 | `frontend/src/components/layout/AppLayout.tsx` | 3.1 | Mount SorenessPrompt |
| 9 | `frontend/src/pages/history/HistoryPage.tsx` | 3.2 | Session naming |
| 10 | `frontend/src/pages/history/SessionDetailPage.tsx` | 3.2 | Show name in header |
| 11 | `frontend/src/pages/log/ExerciseListPage.tsx` | 3.3 | Integrate scrubber |
| 12 | `frontend/src/pages/stats/StatsPage.tsx` | 3.4, 4.3 | Add muscle volume + recovery cards |
| 13 | `backend/app/main.py` | 4.1, 5.1 | Include new routers |
| 14 | `backend/app/models/schemas.py` | 4.1-4.4 | Add recommendation models |
| 15 | `frontend/src/pages/log/SetLoggerPage.tsx` | 4.1 | Enhance suggestion chip |
| 16 | `frontend/src/utils/deloadDetection.ts` | 4.2 | API integration |
| 17 | `backend/app/routers/ai.py` | 4.4 | Add coach endpoint |
| 18 | `backend/app/services/ai_service.py` | 4.5 | Token logging |
| 19 | `backend/app/services/analysis_service.py` | 4.5 | Token logging |
| 20 | `backend/app/config.py` | 5.3 | Add REDIS_URL |
| 21 | `frontend/package.json` | 5.2 | Add generate:types script |
| 22 | `.github/workflows/frontend-ci.yml` | 5.2 | Type drift step |
