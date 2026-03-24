# Prompt for Codex Desktop

Open the `projects/apps/iron-tracker/repo/` directory in Codex Desktop, then copy-paste:

---

Read `docs/deployment/DEPLOYMENT-PLAN.md` and `CLAUDE.md` to understand the Iron Tracker project and deployment plan.

You are responsible for Phase 2 and Phase 4. All credentials and URLs are shared with the other agent (Claude Code Desktop) via `docs/deployment/handoff.json` — never ask the user to relay values manually. Read this file at the start of each phase to get upstream values.

**Phase 2 — Backend Deployment:**

1. Read `docs/deployment/handoff.json` and confirm `phase1.status` is `"complete"`. If not, stop and tell me.
2. Deploy `backend/` to Render as a Python web service:
   - Build command: `pip install .`
   - Start command: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
3. Set environment variables using values from `handoff.json` phase1:
   - `SUPABASE_URL` — from `phase1.outputs.supabase_url`
   - `SUPABASE_DB_URL` — from `phase1.outputs.supabase_db_url`
   - `SUPABASE_JWT_SECRET` — from `phase1.outputs.supabase_jwt_secret`
   - `ANTHROPIC_API_KEY` — I will provide this value when you ask
   - `SENTRY_DSN` — from `phase1.outputs.sentry_backend_dsn`
   - `ALLOWED_ORIGINS` — set to `*` temporarily (will be updated after Phase 3)
   - `DEBUG` — `false`
4. Verify: `GET /health` returns `{"status": "ok"}`.
5. Update `docs/deployment/handoff.json`: set `phase2.status` to `"complete"`, write `phase2.outputs.render_url` with the Render service URL.
6. Tell me Phase 2 is done so I can tell Claude Code Desktop to start Phase 3.

**After Phase 3** (I will tell you when — after Claude Code Desktop deploys the frontend):

1. Read `docs/deployment/handoff.json` to get `phase3.outputs.netlify_url`.
2. Update `ALLOWED_ORIGINS` on Render to the Netlify URL (replacing the temporary `*`).
3. Verify CORS works: frontend at the Netlify URL can reach the backend.

**Phase 4 — Verification:**

1. **Sentry Verification** — Use Sentry read-only observability to confirm:
   - Frontend errors are captured (trigger a test error)
   - Backend traces are recorded (check `/health` transaction)
   - Performance data flows (FCP, TTI metrics)
   - Source maps are uploaded (readable stack traces)

2. **E2E Testing** — Use Playwright to test:
   - Sign up with email → lands on onboarding
   - Complete onboarding → lands on Log tab
   - Search for "Bench Press" → tap → Set Logger loads
   - Log a set (100kg x 8) → set appears in session list
   - Navigate to History → session card visible
   - Navigate to Stats → weekly snapshot renders

3. **Security Audit** — Verify:
   - RLS policies enforce user isolation (can't read other users' sets)
   - JWT validation rejects invalid/expired tokens
   - AI endpoint rate limiting works (11th request returns 429)
   - No API keys exposed in frontend bundle
   - CORS only allows the configured Netlify origin

Report the results of all verification steps. If any issues are found, fix them.
