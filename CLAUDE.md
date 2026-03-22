# Iron Tracker

Machine-aware, set-centric gym tracking PWA.

## Architecture

Monorepo with two apps:

```
frontend/          → React + Vite + TypeScript (deploys to Netlify)
backend/           → Python FastAPI (deploys to Render)
supabase/          → Supabase migrations and seed data
docs/              → Design docs (PRD, Design Doc, UI/UX Spec, Implementation Plan)
```

## Tech Stack

| Layer | Tech |
|-------|------|
| Frontend | React 18, Vite, TypeScript, MUI v6 (MD3 theme), TanStack Router + Query, Zustand, Recharts, Nivo |
| Backend | Python 3.12, FastAPI, Pydantic v2, httpx, pytest |
| Database | Supabase PostgreSQL 15 + Auth + RLS |
| AI | Claude Sonnet via FastAPI proxy (machine photo ID, coaching) |
| Testing | Vitest + React Testing Library (frontend), pytest (backend), Playwright (E2E) |
| Deploy | Netlify (frontend), Render (backend) |

## Commands

### Frontend
```bash
cd frontend && npm install        # Install deps
cd frontend && npm run dev        # Dev server (port 5173)
cd frontend && npm run build      # Production build
cd frontend && npm run test       # Run Vitest
cd frontend && npm run lint       # ESLint
cd frontend && npm run typecheck  # tsc --noEmit
```

### Backend
```bash
cd backend && pip install -e ".[dev]"   # Install deps
cd backend && uvicorn app.main:app --reload  # Dev server (port 8000)
cd backend && pytest                    # Run tests
cd backend && ruff check .              # Lint
cd backend && ruff format .             # Format
```

## Key Design Decisions

- **Machine as first-class entity**: Exercise → Equipment Variant → Set hierarchy
- **Set-centric, not session-centric**: Sets are the atomic unit; sessions are derived (90min inactivity gap)
- **Offline-first**: TanStack Query persists to IndexedDB; optimistic updates everywhere
- **Direct CRUD (80%)**: Frontend talks to Supabase directly via RLS — no backend for basic ops
- **AI-proxied (15%)**: Machine photo ID and coaching go through FastAPI to keep API keys server-side
- **Dark mode default**: Gym environments are dim; seed color #2E75B6
- **1-tap repeat sets**: Pre-fill from last set, single tap to confirm

## Data Patterns

- Frontend → Supabase JS Client → PostgreSQL (RLS) for CRUD
- Frontend → FastAPI → Claude API for AI features
- Cron → FastAPI → Supabase RPC for analytics rollup
- All user data isolated via RLS (`auth.uid() = user_id`)

## Code Style

- Frontend: TypeScript strict mode, named exports, barrel files per feature
- Backend: Pydantic v2 with `ConfigDict(from_attributes=True)`, domain-driven modules
- SQL: Snake_case, explicit RLS on every table, indexes on all RLS columns
- Components: One component per file, colocated tests (`Component.test.tsx`)

## Deployment

Frontend and backend deploy independently. Supabase migrations run via CLI.
Cloud deployment (Netlify, Render, Supabase) is handled via Claude Code Desktop or Codex Desktop which have cloud connectors.
