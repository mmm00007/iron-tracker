# Iron Tracker Live Playwright Audit

Date: 2026-03-24
Target: https://iron-tracker-app.netlify.app
Method: Live Playwright run against the deployed app with a provided QA account

## Audit Assets

- Test config: `frontend/playwright.config.ts`
- Test suite: `frontend/e2e/live-audit.spec.ts`
- Artifacts: `output/playwright/`

Final full-suite status:

- Passed: auth, machine identify page load/upload flow, profile save/sign-out, desktop shell
- Failed: logging, history, stats

Important note:

- The history and stats failures are downstream effects of the primary logging/data issue below. Those screens rendered their empty states, but deeper validation was blocked because the QA account could not actually start logging workouts from the Log screen.

## Findings

### 1. P1: The core logging flow is blocked because no exercise catalog is available on the live app

Severity: High

What happened:

- After sign-in, the Log screen loaded but returned no exercise entries.
- Searching common terms like `press`, `row`, `curl`, and `squat` produced "No exercises found".
- Clearing the search still did not expose any default exercise list.

Why this matters:

- This blocks the primary user journey: a user cannot choose an exercise, open the set logger, or create workout history organically.
- It also cascades into empty History and Stats screens because the test account cannot produce workout data through the intended UI.

Reproduction:

1. Sign in with the QA account.
2. Open Log.
3. Search for common exercise names.
4. Observe that no exercise entries appear and the default catalog is also empty.

Likely fix areas:

- Verify the production `exercises` table is seeded and readable for authenticated users.
- Verify production RLS/policies for `exercises` and `muscle_groups`.
- Check the client fetch path in `frontend/src/hooks/useExercises.ts`.

Related code:

- [frontend/src/hooks/useExercises.ts](/Users/maximemansour/nanoclaw-sandbox-3228/projects/apps/iron-tracker/repo/frontend/src/hooks/useExercises.ts#L7)

### 2. P1: Machine identification rejects authenticated requests with `401` and shows `Could not validate credentials`

Severity: High

What happened:

- The machine identify screen loaded correctly.
- Uploading a sample image triggered repeated `POST https://iron-tracker-api.onrender.com/api/ai/identify-machine` calls.
- The backend responded `401`.
- The UI ended in an error state that read: `Couldn't identify machine` / `Could not validate credentials`.

Why this matters:

- This breaks the AI-assisted onboarding/logging path.
- It also makes the onboarding "Open Camera" step effectively unusable in production.

Reproduction:

1. Sign in.
2. Open `/log/identify`.
3. Upload an image from gallery.
4. Wait for the request to finish.
5. Observe the user-facing credential-validation error.

Evidence from the Playwright run:

- Repeated `401` responses from `POST /api/ai/identify-machine`
- User-facing error text: `Could not validate credentials`

Likely fix areas:

- Verify the Render backend is validating Supabase JWTs against the correct issuer/audience/project.
- Verify the frontend is hitting the correct `VITE_API_URL`.
- Verify any auth middleware on the AI route accepts the same bearer token format the frontend sends.

Related code:

- [frontend/src/hooks/useMachineIdentify.ts](/Users/maximemansour/nanoclaw-sandbox-3228/projects/apps/iron-tracker/repo/frontend/src/hooks/useMachineIdentify.ts#L16)

### 3. P2: The deployed app throws a CSP worker violation on every audited screen

Severity: Medium

What happened:

- Across auth, log, history, stats, machine identify, and profile, the browser console repeatedly logged:
  `Creating a worker from 'blob:...' violates the following Content Security Policy directive: "script-src 'self'"`.

Why this matters:

- Something in the deployed app expects worker support and is being blocked in production.
- Even if the app appears usable, this is a real runtime misconfiguration and can disable background-worker-dependent behavior.

Reproduction:

1. Open the live app.
2. Watch the browser console.
3. Observe repeated CSP worker violations.

Likely fix areas:

- If blob workers are intentional, add the correct CSP directive such as `worker-src 'self' blob:`.
- If they are not intentional, identify which package is attempting worker creation and remove or reconfigure it for production.

### 4. P2: The "Create custom exercise" button is a dead CTA in the no-results state

Severity: Medium

What happened:

- The no-results UI renders a `Create custom exercise` button.
- In code, the button handler is optional and the Log page renders the component without providing one.

Why this matters:

- When search fails, the fallback CTA appears actionable but cannot do anything.
- This is especially visible right now because the deployed catalog is empty.

Likely fix areas:

- Either wire this button to a real creation flow or remove it until the flow exists.

Related code:

- [frontend/src/pages/log/ExerciseListPage.tsx](/Users/maximemansour/nanoclaw-sandbox-3228/projects/apps/iron-tracker/repo/frontend/src/pages/log/ExerciseListPage.tsx#L142)
- [frontend/src/pages/log/ExerciseListPage.tsx](/Users/maximemansour/nanoclaw-sandbox-3228/projects/apps/iron-tracker/repo/frontend/src/pages/log/ExerciseListPage.tsx#L285)

### 5. P2: The machine-identify "Create Variant" action is still dead even after the backend auth issue is fixed

Severity: Medium

What happened:

- `MachineIdentifyPage` hardcodes `exerciseId` to an empty string.
- The `VariantBottomSheet` only renders when `exerciseId` is truthy.
- That means a successful AI identification still cannot open the creation sheet as intended.

Why this matters:

- Fixing the `401` alone will not fully restore the machine-identify workflow.
- The success CTA remains broken by construction.

Likely fix areas:

- Pass a real `exerciseId` into the route/search params or redesign the variant creation flow so it does not depend on a missing value.

Related code:

- [frontend/src/pages/log/MachineIdentifyPage.tsx](/Users/maximemansour/nanoclaw-sandbox-3228/projects/apps/iron-tracker/repo/frontend/src/pages/log/MachineIdentifyPage.tsx#L426)
- [frontend/src/pages/log/MachineIdentifyPage.tsx](/Users/maximemansour/nanoclaw-sandbox-3228/projects/apps/iron-tracker/repo/frontend/src/pages/log/MachineIdentifyPage.tsx#L520)

## Areas That Looked Healthy

- Auth form validation rendered correctly.
- Forgot-password page rendered correctly.
- Profile save worked.
- Sign-out worked.
- The not-found page rendered.
- The desktop shell stayed usable enough for top-level navigation.

## Not Counted As Product Defects

- Google Fonts failed to load in the headless environment during some runs. I did not count that as an app defect because it may be environment-specific.
- Sentry ingest requests were sometimes aborted during navigation. I did not count those as app defects for the same reason.

## Recommended Fix Order

1. Restore the exercise catalog in production so the primary logging flow works.
2. Fix AI route authentication so machine identification stops returning `401`.
3. Fix the dead fallback CTAs (`Create custom exercise`, `Create Variant`).
4. Clean up the CSP worker policy so production console/runtime behavior matches the app's actual needs.
