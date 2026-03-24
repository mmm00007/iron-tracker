# Iron Tracker

Machine-aware, set-centric gym tracking PWA.

## Repository & Environments

This project is its own git repo — versioned independently from the NanoClaw workspace.

- **Frontend**: Node.js environment with its own `node_modules` and `package.json`
- **Backend**: Python environment managed by `uv` — venv at `backend/.venv`, deps in `backend/pyproject.toml`. Always use `uv run` / `uv sync`, never `pip install` directly.

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
| Backend | Python 3.12, FastAPI, Pydantic v2, asyncpg, httpx, pytest |
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
cd backend && uv sync --all-extras      # Install deps (uses uv)
cd backend && uv run uvicorn app.main:app --reload  # Dev server (port 8000)
cd backend && uv run pytest             # Run tests
cd backend && uv run ruff check .       # Lint
cd backend && uv run ruff format .      # Format
```

> **Python environment**: Managed by [uv](https://docs.astral.sh/uv/). The venv lives at `backend/.venv`. Always use `uv run` or `uv sync` — never `pip install` directly.

### Code Analysis Tools

| Tool | Command | Use Case |
|------|---------|----------|
| **ast-grep** | `ast-grep` | Structural code search using AST patterns. No false positives from comments/strings. |
| **Tree-sitter CLI** | `tree-sitter` | Parse source into syntax trees. Language-aware analysis and custom queries. |
| **Universal Ctags** | `ctags` | Symbol index (functions, classes, variables). Navigate large codebases. |
| **Ripgrep** | `rg` | Fast text search. Keyword searches, import tracing, string literals. |
| **Joern** | `joern` | Code Property Graph for security: taint analysis, data flow, vulnerability detection. |
| **CodeQL** | `codeql` | Semantic code analysis queries for vulnerability patterns and coding errors. |

```bash
# ast-grep examples for this project
ast-grep -p '$_ as any' -l ts frontend/src/           # Find all `as any` assertions
ast-grep -p 'supabase.from($TABLE)' -l ts frontend/    # Audit Supabase table usage
ast-grep -p 'console.log($$$)' -l ts frontend/src/     # Find debug logs
ast-grep -p 'await $_.mutateAsync($$$)' -l ts frontend/ # Find all mutation calls
```

Prefer ast-grep over grep for pattern-based searches. Use grep for simple keyword lookups. Agents (QA, security) should use ast-grep, Joern, or CodeQL for thorough audits.

## Key Design Decisions

- **Machine as first-class entity**: Exercise → Equipment Variant → Set hierarchy
- **Gym entity**: Gyms → Gym Machines → User Variants (one-tap clone from curated catalog)
- **Set-centric, not session-centric**: Sets are the atomic unit; sessions are derived (90min inactivity gap)
- **Offline-first**: TanStack Query persists to IndexedDB; optimistic updates everywhere
- **Direct CRUD (80%)**: Frontend talks to Supabase directly via RLS — no backend for basic ops
- **AI-proxied (15%)**: Machine photo ID and coaching go through FastAPI to keep API keys server-side
- **Backend DB**: asyncpg (direct Postgres) for backend operations — NOT supabase-py. Service role, no PostgREST.
- **Dark mode default**: Gym environments are dim; seed color #2E75B6
- **1-tap repeat sets**: Pre-fill from last set, single tap to confirm
- **Seed data**: 800+ exercises from yuhonas/free-exercise-db (Unlicense) + wger muscle enrichment (CC-BY-SA)
- **Muscle heatmap**: wger SVG body outlines as React components, paths colored by training volume

## Data Model

Core hierarchy: Exercise → Equipment Variant → Set
Gym hierarchy: Gym → Gym Machine → cloned to Equipment Variant (via gym_machine_id FK)
Muscles: muscle_groups table + exercise_muscles junction table (normalized, not text arrays)

## Data Patterns

- Frontend → Supabase JS Client → PostgreSQL (RLS) for CRUD
- Backend → asyncpg → PostgreSQL (service role) for analytics, AI context, admin ops
- Frontend → FastAPI → Claude API for AI features
- Cron → FastAPI → asyncpg for analytics rollup
- All user data isolated via RLS (`auth.uid() = user_id`)
- Gym/machine catalog is public read, admin-only write

## Code Style

- Frontend: TypeScript strict mode, named exports, barrel files per feature
- Backend: Pydantic v2 with `ConfigDict(from_attributes=True)`, domain-driven modules
- SQL: Snake_case, explicit RLS on every table, indexes on all RLS columns
- Components: One component per file, colocated tests (`Component.test.tsx`)

## Specialist Agents

All agents live in `.claude/agents/`. Use the right specialist for the task at hand.

| Agent | Model | Role |
|-------|-------|------|
| `software-architect` | opus | System design, interfaces, trade-offs, cross-layer decisions |
| `backend-specialist` | sonnet | FastAPI endpoints, asyncpg queries, Python services |
| `frontend-specialist` | sonnet | React components, state management, Supabase client |
| `ux-ui-specialist` | opus | User flows, interaction design, accessibility, visual consistency |
| `fitness-domain-expert` | opus | Exercise science, anatomy, nutrition, training algorithms |
| `qa-reviewer` | opus | Code review, bug detection, test coverage, conventions |
| `security-specialist` | opus | Auth audit, RLS review, threat modeling, OWASP compliance |
| `deployment-specialist` | sonnet | CI/CD, cloud services, env vars, production ops |
| `database-specialist` | sonnet | Schema design, migrations, RLS, query optimization |

**When to invoke:**
- **Architecture decisions** → `software-architect` first, then specialists implement
- **New feature** → `software-architect` for design, then `frontend-specialist` / `backend-specialist` / `database-specialist` for implementation
- **Domain logic** (exercises, 1RM, deload, volume) → `fitness-domain-expert` before implementing
- **UI changes** → `ux-ui-specialist` for design review
- **Before merging** → `qa-reviewer` for code review
- **Security concerns** → `security-specialist` for audit
- **Deploy issues** → `deployment-specialist`

## Error Tracking (Sentry)

Both frontend and backend integrate Sentry for error tracking and performance monitoring.
- Frontend: `@sentry/react` with browser tracing + session replay
- Backend: `sentry-sdk[fastapi,asyncpg]` with endpoint tracing
- DSN is configured via `VITE_SENTRY_DSN` (frontend) and `SENTRY_DSN` (backend)
- Optional — app works without Sentry DSN configured

## Deployment

Frontend and backend deploy independently. Supabase migrations run via CLI.
Cloud deployment (Netlify, Render, Supabase) is handled via Claude Code Desktop or Codex Desktop which have cloud connectors.
