# Prompt for Claude Code Desktop

Copy-paste the following into Claude Code Desktop after opening the `projects/apps/iron-tracker/repo/` directory:

---

Read `docs/deployment/DEPLOYMENT-PLAN.md` and `CLAUDE.md` to understand the Iron Tracker project and deployment plan.

Before starting, verify you have access to connectors for: GitHub, Supabase, Sentry, and Netlify. List which ones are available. If any are missing, tell me which ones I need to install before we proceed.

Once confirmed, you are responsible for Phase 1 (infrastructure setup) and Phase 3 (frontend deployment). Execute these steps in order, waiting for my confirmation between each:

**Phase 1:**
1. Create a private GitHub repo called `iron-tracker` and push all local commits.
2. Create a Supabase project called `iron-tracker`. Run the migration at `supabase/migrations/001_initial_schema.sql`. Then run the seed script `python scripts/seed_exercises.py` (it needs internet access to download exercise data from GitHub) and execute the 3 generated seed SQL files from `supabase/seed/` in order (001, 002, 003). Enable Google OAuth in Supabase Auth settings.
3. Create two Sentry projects: `iron-tracker-frontend` (React) and `iron-tracker-api` (Python/FastAPI). Save both DSN values.

After Phase 1, give me a summary of all URLs, keys, and DSN values I need to hand to Codex Desktop for the Render backend deployment. I will then come back with the Render backend URL.

**Phase 3** (I will tell you when to start this — after Codex deploys the backend to Render):
4. Deploy `frontend/` to Netlify. Build command: `npm run build`, publish dir: `dist`. Add redirect rule `/* /index.html 200` for SPA routing. Set these env vars:
   - `VITE_SUPABASE_URL` — from step 2
   - `VITE_SUPABASE_ANON_KEY` — from step 2
   - `VITE_API_URL` — the Render backend URL I will provide
   - `VITE_SENTRY_DSN` — from step 3 (iron-tracker-frontend)

After deployment, give me the Netlify URL so I can update the backend's `ALLOWED_ORIGINS` on Render.
