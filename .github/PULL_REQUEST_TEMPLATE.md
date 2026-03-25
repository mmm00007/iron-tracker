## Summary

<!-- What does this PR do? 1-3 bullet points. -->

## Changes

<!-- List key files/areas modified. -->

## Test plan

- [ ] Backend tests pass (`uv run pytest`)
- [ ] Frontend tests pass (`npm run test`)
- [ ] TypeScript compiles (`npm run typecheck`)
- [ ] Linting passes (`ruff check .` / `npm run lint`)
- [ ] Manually tested on mobile viewport

## Review checklist

- [ ] No `as any` or `# type: ignore` added without justification
- [ ] New DB queries use parameterized placeholders
- [ ] RLS policies cover any new tables
- [ ] No hardcoded secrets or API keys
