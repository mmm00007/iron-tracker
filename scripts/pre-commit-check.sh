#!/usr/bin/env bash
# Fast pre-commit checks (~15-30s). Mirrors CI lint/format/typecheck steps.
# Runs only checks relevant to files staged for commit.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BOLD='\033[1m'
NC='\033[0m'

pass() { echo -e "  ${GREEN}PASS${NC} $1"; }
fail() { echo -e "  ${RED}FAIL${NC} $1"; }
skip() { echo -e "  ${YELLOW}SKIP${NC} $1 (no changes)"; }
header() { echo -e "\n${BOLD}$1${NC}"; }

ERRORS=0

# Detect which areas have staged changes
BACKEND_CHANGED=$(git diff --cached --name-only -- backend/ | head -1)
FRONTEND_CHANGED=$(git diff --cached --name-only -- frontend/ | head -1)

# If nothing staged, check working directory changes instead (for manual runs)
if [ -z "$BACKEND_CHANGED" ] && [ -z "$FRONTEND_CHANGED" ]; then
  BACKEND_CHANGED=$(git diff --name-only -- backend/ | head -1)
  FRONTEND_CHANGED=$(git diff --name-only -- frontend/ | head -1)
fi

# ── Backend checks ────────────────────────────────────────────────────────────
header "Backend"

if [ -n "$BACKEND_CHANGED" ]; then
  cd "$REPO_ROOT/backend"

  # Ruff lint
  if ruff check . --quiet 2>/dev/null; then
    pass "ruff check (lint)"
  else
    fail "ruff check (lint)"
    ERRORS=$((ERRORS + 1))
  fi

  # Ruff format
  if ruff format --check . --quiet 2>/dev/null; then
    pass "ruff format"
  else
    fail "ruff format — run: cd backend && ruff format ."
    ERRORS=$((ERRORS + 1))
  fi

  cd "$REPO_ROOT"
else
  skip "ruff check"
  skip "ruff format"
fi

# ── Frontend checks ───────────────────────────────────────────────────────────
header "Frontend"

if [ -n "$FRONTEND_CHANGED" ]; then
  cd "$REPO_ROOT/frontend"

  # ESLint (skip if plugin deps missing — run 'npm install' to fix)
  if [ ! -d "node_modules/eslint-plugin-jsx-a11y" ]; then
    skip "eslint (missing eslint-plugin-jsx-a11y — run 'npm install')"
  else
    if ESLINT_USE_FLAT_CONFIG=false npx eslint src --ext ts,tsx --max-warnings 15 --quiet 2>/dev/null; then
      pass "eslint"
    else
      fail "eslint"
      ERRORS=$((ERRORS + 1))
    fi
  fi

  # TypeScript — verify tsc works before running type check
  if ! npx tsc --version >/dev/null 2>&1; then
    skip "tsc --noEmit (tsc unavailable — run 'npm install')"
  elif npx tsc --noEmit 2>/dev/null; then
    pass "tsc --noEmit (typecheck)"
  else
    fail "tsc --noEmit (typecheck)"
    ERRORS=$((ERRORS + 1))
  fi

  cd "$REPO_ROOT"
else
  skip "eslint"
  skip "tsc --noEmit"
fi

# ── Result ────────────────────────────────────────────────────────────────────
echo ""
if [ "$ERRORS" -gt 0 ]; then
  echo -e "${RED}${BOLD}$ERRORS check(s) failed.${NC} Fix before committing."
  exit 1
else
  echo -e "${GREEN}${BOLD}All checks passed.${NC}"
  exit 0
fi
