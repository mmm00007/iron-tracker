# Prompt for Claude Code Desktop

Open the `projects/apps/iron-tracker/repo/` directory in Claude Code Desktop, then copy-paste:

---

Read `docs/deployment/DEPLOYMENT-PLAN.md` and `CLAUDE.md` to understand the Iron Tracker project and deployment plan.

Before starting, verify you have access to connectors for: GitHub, Supabase, Sentry, and Netlify. List which ones are available. If any are missing, tell me which ones I need to install before we proceed.

You are responsible for Phase 1, Phase 3, and Phase 5. All credentials and URLs are shared with the other agent (Codex Desktop) via `docs/deployment/handoff.json` — never ask me to relay values manually.

**Phase 1 — Infrastructure Setup:**

1. Add `handoff.json` to the project's `.gitignore`.
2. Create a private GitHub repo called `iron-tracker` and push all local commits.
3. Create a Supabase project called `iron-tracker`. Run the migration at `supabase/migrations/001_initial_schema.sql`. Run the seed script `python scripts/seed_exercises.py` (needs internet to download exercise data from GitHub), then execute the 3 generated seed SQL files from `supabase/seed/` in order (001, 002, 003). Enable Google OAuth in Supabase Auth settings.
4. Create two Sentry projects: `iron-tracker-frontend` (JavaScript/React) and `iron-tracker-api` (Python/FastAPI).
5. Write all outputs to `docs/deployment/handoff.json`:
```json
{
  "project": "iron-tracker",
  "phase1": {
    "status": "complete",
    "completed_by": "claude-code-desktop",
    "timestamp": "<now>",
    "outputs": {
      "github_repo": "<repo URL>",
      "supabase_url": "<project URL>",
      "supabase_anon_key": "<anon key>",
      "supabase_db_url": "<DB connection string>",
      "supabase_jwt_secret": "<JWT secret>",
      "sentry_frontend_dsn": "<frontend DSN>",
      "sentry_backend_dsn": "<backend DSN>"
    }
  },
  "phase2": { "status": "pending" },
  "phase3": { "status": "pending" }
}
```
6. Tell me Phase 1 is done so I can tell Codex Desktop to start Phase 2.

**Phase 3 — Frontend Deployment** (I will tell you when to start — after Codex completes Phase 2):

1. Read `docs/deployment/handoff.json` to get all values you need (Supabase from phase1, Render URL from phase2).
2. Deploy `frontend/` to Netlify. Build command: `npm run build`, publish dir: `dist`. Add redirect rule `/* /index.html 200` for SPA routing. Set env vars:
   - `VITE_SUPABASE_URL` — from handoff phase1
   - `VITE_SUPABASE_ANON_KEY` — from handoff phase1
   - `VITE_API_URL` — from handoff phase2 (`render_url`)
   - `VITE_SENTRY_DSN` — from handoff phase1 (`sentry_frontend_dsn`)
3. Update `docs/deployment/handoff.json`: set `phase3.status` to `"complete"`, write `phase3.outputs.netlify_url`.
4. Tell me Phase 3 is done so I can tell Codex Desktop to update `ALLOWED_ORIGINS` on Render.

**Phase 5 — Seed Data** (after verification):

1. If not already done in Phase 1, run `python scripts/seed_exercises.py` and execute the generated seed files against Supabase.
2. Verify: 800+ exercises are visible in the exercise list.

**When all phases are complete and verified, delete `docs/deployment/handoff.json` — it contains secrets and has served its purpose.**
