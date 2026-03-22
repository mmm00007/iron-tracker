# Iron Tracker 🏋️

**The gym tracker that knows your machines.**

Machine-aware, set-centric gym tracking PWA. Track every machine variant independently, log sets with one tap, and get AI-powered machine identification.

## Quick Start

### Frontend
```bash
cd frontend
npm install
npm run dev
```

### Backend
```bash
cd backend
python -m venv .venv
source .venv/bin/activate
pip install -e ".[dev]"
uvicorn app.main:app --reload
```

### Database
Set up a Supabase project and run migrations:
```bash
supabase db push
```

## Project Structure

```
frontend/     React + Vite + TypeScript PWA
backend/      Python FastAPI API server
supabase/     Database migrations and seed data
docs/         Product documentation
```

## Documentation

- [Product Requirements](docs/IronTracker_PRD.docx)
- [Design Document](docs/IronTracker_DesignDocument.docx)
- [UI/UX Specification](docs/IronTracker_UIUX_Spec.docx)
- [Implementation Plan](docs/IronTracker_ImplementationPlan.pdf)
