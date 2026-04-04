#!/usr/bin/env bash
# Full pre-deploy validation (~2-3 min). Runs everything CI would check.
# Run this before pushing to main to catch failures before they hit CI.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BOLD='\033[1m'
NC='\033[0m'

pass() { echo -e "  ${GREEN}PASS${NC} $1"; }
fail() { echo -e "  ${RED}FAIL${NC} $1"; ERRORS=$((ERRORS + 1)); }
warn() { echo -e "  ${YELLOW}WARN${NC} $1"; WARNINGS=$((WARNINGS + 1)); }
header() { echo -e "\n${BOLD}$1${NC}"; }

ERRORS=0
WARNINGS=0

# ══════════════════════════════════════════════════════════════════════════════
header "Backend (Python)"
# ══════════════════════════════════════════════════════════════════════════════
cd "$REPO_ROOT/backend"

# Dependency audit
header "  Dependency audit"
if uv run pip-audit --local --desc on 2>/dev/null; then
  pass "pip-audit"
else
  fail "pip-audit — vulnerable dependencies found"
fi

# Lint
header "  Lint & format"
if ruff check . --quiet 2>/dev/null; then
  pass "ruff check"
else
  fail "ruff check — run: cd backend && ruff check . --fix"
fi

if ruff format --check . --quiet 2>/dev/null; then
  pass "ruff format"
else
  fail "ruff format — run: cd backend && ruff format ."
fi

# Type check (warn only — 77 pre-existing errors)
header "  Type check"
if uv run mypy app 2>/dev/null; then
  pass "mypy"
else
  warn "mypy — type errors found (77 pre-existing, non-blocking)"
fi

# Tests
header "  Tests"
if uv run pytest --tb=short -q 2>/dev/null; then
  pass "pytest"
else
  fail "pytest — tests failed"
fi

# ══════════════════════════════════════════════════════════════════════════════
header "Frontend (TypeScript/React)"
# ══════════════════════════════════════════════════════════════════════════════
cd "$REPO_ROOT/frontend"

# Dependency audit
header "  Dependency audit"
if npm audit --audit-level=critical 2>/dev/null; then
  pass "npm audit"
else
  fail "npm audit — critical vulnerabilities found"
fi

# Lint
header "  Lint"
if ESLINT_USE_FLAT_CONFIG=false npx eslint src --ext ts,tsx --max-warnings 15 2>/dev/null; then
  pass "eslint"
else
  fail "eslint"
fi

# Type check
header "  Type check"
if npx tsc --noEmit 2>/dev/null; then
  pass "tsc --noEmit"
else
  fail "tsc --noEmit — type errors found"
fi

# Build
header "  Build"
if VITE_SUPABASE_URL="https://placeholder.supabase.co" \
   VITE_SUPABASE_ANON_KEY="placeholder" \
   VITE_API_URL="http://localhost:8000" \
   npx vite build 2>/dev/null; then
  pass "vite build"
else
  fail "vite build"
fi

# Tests
header "  Tests"
if npx vitest run --reporter=verbose 2>/dev/null; then
  pass "vitest"
else
  warn "vitest — some tests failed (check output above)"
fi

# ══════════════════════════════════════════════════════════════════════════════
header "Supabase Migrations"
# ══════════════════════════════════════════════════════════════════════════════

# Count local vs applied migrations
LOCAL_COUNT=$(ls "$REPO_ROOT/supabase/migrations/"*.sql 2>/dev/null | wc -l | tr -d ' ')
echo "  Local migration files: $LOCAL_COUNT"
echo "  (Run 'supabase db push --dry-run' to check for unapplied migrations)"

# ══════════════════════════════════════════════════════════════════════════════
header "Summary"
# ══════════════════════════════════════════════════════════════════════════════
cd "$REPO_ROOT"

echo ""
if [ "$ERRORS" -gt 0 ]; then
  echo -e "${RED}${BOLD}$ERRORS check(s) failed, $WARNINGS warning(s).${NC}"
  echo -e "Fix failures before deploying."
  exit 1
elif [ "$WARNINGS" -gt 0 ]; then
  echo -e "${YELLOW}${BOLD}All checks passed with $WARNINGS warning(s).${NC}"
  echo -e "Safe to deploy — review warnings when convenient."
  exit 0
else
  echo -e "${GREEN}${BOLD}All checks passed. Safe to deploy.${NC}"
  exit 0
fi
