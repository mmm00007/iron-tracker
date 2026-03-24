# Iron Tracker Deployment Plan

## Agent Capabilities Matrix

| Capability | Claude Code Desktop | Codex Desktop | This CLI Session |
|------------|-------------------|---------------|------------------|
| GitHub (create repo, push, PRs) | Connector | - | - |
| Netlify (deploy frontend) | Connector | Deploy skill | - |
| Supabase (project, migrations, edge functions) | Connector | - | - |
| Sentry (create project, configure DSN) | Connector | Read-only observability | - |
| Render (deploy backend) | - | Deploy skill | - |
| Playwright (E2E testing) | Skill | Skill | - |
| Security audit | Skill | Skill | - |
| Code generation / editing | Full | Full | Full |

## Shared File Handoff

Agents coordinate via `docs/deployment/handoff.json` — no manual copy-paste of credentials between agents. Each agent writes its outputs to the handoff file after completing its phase, and the next agent reads from it. The file is `.gitignore`d since it contains secrets.

See the main `CLAUDE.md` (root of workspace) for the full handoff file format and rules.

## Deployment Sequence

### Phase 1: Repository & Infrastructure Setup (Claude Code Desktop)

**Step 1 — GitHub**
- Create private repo `iron-tracker` on GitHub via connector
- Push all commits from local repo
- Set up branch protection on `main` (require PR reviews)

**Step 2 — Supabase**
- Create Supabase project `iron-tracker` via connector
- Run migration: `supabase/migrations/001_initial_schema.sql`
- Run seed scripts in order:
  1. `supabase/seed/001_muscle_groups.sql`
  2. `supabase/seed/002_exercises.sql`
  3. `supabase/seed/003_exercise_muscles.sql`
- Enable Google OAuth provider in Auth settings
- Write project URL, anon key, DB connection string, and JWT secret to `docs/deployment/handoff.json` under `phase1.outputs`

**Step 3 — Sentry**
- Create Sentry project `iron-tracker-frontend` (JavaScript/React) via connector
- Create Sentry project `iron-tracker-api` (Python/FastAPI) via connector
- Write both DSN values to `docs/deployment/handoff.json` under `phase1.outputs`
- Set `phase1.status` to `"complete"`

### Phase 2: Backend Deployment (Codex Desktop)

**Step 4 — Render**
- Read `docs/deployment/handoff.json` to get Phase 1 outputs (Supabase credentials, Sentry backend DSN)
- Deploy `backend/` as a Python web service via Render deploy skill
- Build command: `pip install .`
- Start command: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
- Set environment variables (values from handoff.json phase1):
  ```
  SUPABASE_URL=<from handoff.json phase1.outputs.supabase_url>
  SUPABASE_DB_URL=<from handoff.json phase1.outputs.supabase_db_url>
  SUPABASE_JWT_SECRET=<from handoff.json phase1.outputs.supabase_jwt_secret>
  ANTHROPIC_API_KEY=<user provides>
  SENTRY_DSN=<from handoff.json phase1.outputs.sentry_backend_dsn>
  ALLOWED_ORIGINS=https://<netlify-domain>  (update after Phase 3)
  DEBUG=false
  ```
- Verify: `GET /health` returns `{"status": "ok"}`
- Write Render service URL to `docs/deployment/handoff.json` under `phase2.outputs.render_url`
- Set `phase2.status` to `"complete"`

### Phase 3: Frontend Deployment (Claude Code Desktop or Codex Desktop)

**Step 5 — Netlify**
- Read `docs/deployment/handoff.json` to get Phase 1 outputs (Supabase, Sentry) and Phase 2 outputs (Render URL)
- Deploy `frontend/` via Netlify connector/skill
- Build command: `npm run build`
- Publish directory: `dist`
- Set environment variables (values from handoff.json):
  ```
  VITE_SUPABASE_URL=<from handoff.json phase1.outputs.supabase_url>
  VITE_SUPABASE_ANON_KEY=<from handoff.json phase1.outputs.supabase_anon_key>
  VITE_API_URL=<from handoff.json phase2.outputs.render_url>
  VITE_SENTRY_DSN=<from handoff.json phase1.outputs.sentry_frontend_dsn>
  ```
- Configure redirect rule: `/* /index.html 200` (SPA routing)
- Verify: app loads at Netlify URL, dark theme renders
- Write Netlify URL to `docs/deployment/handoff.json` under `phase3.outputs.netlify_url`
- Set `phase3.status` to `"complete"`
- Codex Desktop then updates `ALLOWED_ORIGINS` on Render with the Netlify URL from handoff.json

### Phase 4: Verification (Both)

**Step 6 — E2E Testing (Playwright)**
- Use Playwright skill (available on both Claude Code Desktop and Codex Desktop)
- Test flows:
  1. Sign up with email → lands on onboarding
  2. Complete onboarding → lands on Log tab
  3. Search for "Bench Press" → tap → Set Logger loads
  4. Log a set (100kg × 8) → set appears in session list
  5. Navigate to History → session card visible
  6. Navigate to Stats → weekly snapshot renders
  7. Test offline: disable network → log a set → re-enable → set syncs

**Step 7 — Security Audit**
- Use security skill (available on both)
- Verify:
  - RLS policies enforce user isolation (can't read other users' sets)
  - JWT validation rejects invalid/expired tokens
  - AI endpoint rate limiting works (11th request returns 429)
  - No API keys exposed in frontend bundle
  - CORS only allows configured origins

**Step 8 — Sentry Verification (Codex Desktop)**
- Use Sentry read-only observability skill
- Confirm:
  - Frontend errors are captured (trigger a test error)
  - Backend traces are recorded (check /health transaction)
  - Performance data flows (FCP, TTI metrics)
  - Source maps are uploaded (readable stack traces)

### Phase 5: Seed Data (Claude Code Desktop)

**Step 9 — Run Seed Pipeline**
- Run `python scripts/seed_exercises.py` to generate seed SQL from free-exercise-db
- Execute generated seed files against Supabase via connector
- Verify: 800+ exercises visible in the exercise list

**Step 10 — Gym Data (Manual)**
- Photograph gym machines (see Addendum Section 5.4 for pipeline)
- Process photos with ImageMagick vignette treatment
- Seed gym and gym_machine records via Supabase connector
- This is an ongoing process — start with 1 gym, expand

## Environment Variable Summary

### Frontend (.env)
| Variable | Source | Required |
|----------|--------|----------|
| `VITE_SUPABASE_URL` | Supabase project settings | Yes |
| `VITE_SUPABASE_ANON_KEY` | Supabase project settings | Yes |
| `VITE_API_URL` | Render service URL | Yes |
| `VITE_SENTRY_DSN` | Sentry project settings | No |

### Backend (.env)
| Variable | Source | Required |
|----------|--------|----------|
| `SUPABASE_URL` | Supabase project settings | Yes |
| `SUPABASE_DB_URL` | Supabase → Database → Connection string | Yes |
| `SUPABASE_JWT_SECRET` | Supabase → Settings → API → JWT Secret | Yes |
| `ANTHROPIC_API_KEY` | Anthropic console | Yes |
| `SENTRY_DSN` | Sentry project settings | No |
| `ALLOWED_ORIGINS` | Netlify domain | Yes |
| `DEBUG` | Set to `false` in production | Yes |

## Post-Deployment Monitoring

| What | Where | Who |
|------|-------|-----|
| Frontend errors + performance | Sentry `iron-tracker-frontend` | Codex Desktop (read-only observability skill) |
| Backend errors + traces | Sentry `iron-tracker-api` | Codex Desktop (read-only observability skill) |
| Database health | Supabase dashboard | Claude Code Desktop (connector) |
| Uptime | Render dashboard | Codex Desktop |
| Deployment logs | Netlify / Render dashboards | Both |
