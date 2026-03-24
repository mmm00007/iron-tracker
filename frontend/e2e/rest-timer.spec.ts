import { test, expect, type Page } from '@playwright/test';

const USERNAME = process.env.PLAYWRIGHT_TEST_USERNAME;
const PASSWORD = process.env.PLAYWRIGHT_TEST_PASSWORD;

function requireCredentials() {
  if (!USERNAME || !PASSWORD) {
    throw new Error('Missing PLAYWRIGHT_TEST_USERNAME or PLAYWRIGHT_TEST_PASSWORD');
  }
  return { username: USERNAME, password: PASSWORD };
}

async function isVisible(locator: import('@playwright/test').Locator) {
  try {
    return await locator.isVisible();
  } catch {
    return false;
  }
}

async function clickIfVisible(locator: import('@playwright/test').Locator) {
  if (await isVisible(locator)) {
    await locator.click();
    return true;
  }
  return false;
}

async function waitForKnownPath(page: Page) {
  await page.waitForFunction(
    () => {
      const path = window.location.pathname;
      return path.startsWith('/login') || path.startsWith('/log') || path.startsWith('/onboarding');
    },
    undefined,
    { timeout: 15_000 },
  );
}

async function completeOnboardingIfNeeded(page: Page) {
  for (let step = 0; step < 8 && page.url().includes('/onboarding'); step += 1) {
    if (await isVisible(page.getByRole('button', { name: 'Get Started' }))) {
      await page.getByRole('button', { name: 'Get Started' }).click();
      continue;
    }
    if (await isVisible(page.getByText('Tell us about yourself'))) {
      await clickIfVisible(page.getByRole('button', { name: 'Intermediate' }));
      await clickIfVisible(page.getByRole('button', { name: 'Strength' }));
      await clickIfVisible(page.getByRole('button', { name: 'kg' }));
      await page.getByRole('button', { name: 'Continue' }).click();
      continue;
    }
    if (await isVisible(page.getByText('Select Your Gym'))) {
      if (!(await clickIfVisible(page.getByRole('button', { name: 'Skip' })))) {
        await page.getByRole('button', { name: 'Continue' }).click();
      }
      continue;
    }
    if (await isVisible(page.getByText('Add Your First Machine'))) {
      await page.getByRole('button', { name: 'Skip' }).click();
      continue;
    }
    if (await isVisible(page.getByText("You're all set. Let's lift."))) {
      await page.getByRole('button', { name: 'Start Logging' }).click();
      break;
    }
  }
  await expect(page).toHaveURL(/\/log(?:$|\/)/);
}

async function signIn(page: Page) {
  const { username, password } = requireCredentials();

  await page.goto('/log');
  await waitForKnownPath(page);

  if (page.url().includes('/login')) {
    await page.getByLabel('Email').fill(username);
    await page.getByLabel('Password').fill(password);
    await page.getByRole('button', { name: 'Sign in', exact: true }).click();
  }

  await page.waitForFunction(
    () => window.location.pathname !== '/login',
    undefined,
    { timeout: 20_000 },
  );

  for (let attempt = 0; attempt < 10; attempt += 1) {
    if (await isVisible(page.getByPlaceholder('Search exercises...'))) {
      return;
    }
    if (
      page.url().includes('/onboarding') ||
      (await isVisible(page.getByRole('button', { name: 'Get Started' }))) ||
      (await isVisible(page.getByText('Tell us about yourself'))) ||
      (await isVisible(page.getByText('Select Your Gym'))) ||
      (await isVisible(page.getByText('Add Your First Machine'))) ||
      (await isVisible(page.getByText("You're all set. Let's lift.")))
    ) {
      await completeOnboardingIfNeeded(page);
      break;
    }
    await page.waitForTimeout(1_000);
  }

  await expect(page).toHaveURL(/\/log(?:$|\/)/);
  await expect(page.getByPlaceholder('Search exercises...')).toBeVisible();
}

async function goToTab(page: Page, tabName: 'Log' | 'History' | 'Stats' | 'Profile') {
  await page.getByRole('button', { name: new RegExp(`^${tabName}$`) }).click();
}

/** Navigate to the first available exercise and open its set logger. */
async function openFirstExercise(page: Page) {
  const searchInput = page.getByPlaceholder('Search exercises...');
  const searchTerms = ['press', 'row', 'curl', 'squat'];

  for (const term of searchTerms) {
    await searchInput.fill(term);
    await page.waitForTimeout(500);

    const candidate = page.locator('main li button').first();
    if (await candidate.isVisible().catch(() => false)) {
      await candidate.click();
      await expect(page.getByRole('button', { name: 'Log Set' })).toBeVisible();
      return;
    }
  }

  await searchInput.fill('');
  await page.waitForTimeout(500);

  const firstResult = page.locator('main li button').first();
  if (!(await firstResult.isVisible().catch(() => false))) {
    throw new Error('No exercise entries were available.');
  }
  await firstResult.click();
  await expect(page.getByRole('button', { name: 'Log Set' })).toBeVisible();
}

test.describe('Rest Timer E2E', () => {
  test.beforeEach(async ({ page }) => {
    await signIn(page);
  });

  test('test_timer_auto_starts: logging a set triggers the rest timer pill', async ({ page }) => {
    await openFirstExercise(page);

    const logSetButton = page.getByRole('button', { name: 'Log Set' });
    await expect(logSetButton).toBeVisible();

    // Log a set — this triggers the rest timer via startRestTimer()
    await logSetButton.click();
    await expect(page.getByText('Set logged')).toBeVisible({ timeout: 10_000 });

    // The RestTimerPill renders as a fixed-position element with a countdown (e.g. "1:30")
    // or the "Rest Complete" text. It also has a LinearProgress bar and +/- 30s buttons.
    // Wait for the pill to appear — it shows the countdown format "M:SS"
    const timerPill = page.getByText(/^\d+:\d{2}$/).or(page.getByText('Rest Complete'));
    await expect(timerPill).toBeVisible({ timeout: 5_000 });

    // Verify the timer has +30s and -30s adjustment buttons
    const addTimeButton = page.getByRole('button', { name: 'Add 30 seconds' });
    const subtractTimeButton = page.getByRole('button', { name: 'Subtract 30 seconds' });

    // At least one of these should be visible (they hide when timer completes)
    const addVisible = await isVisible(addTimeButton);
    const subtractVisible = await isVisible(subtractTimeButton);
    const restComplete = await isVisible(page.getByText('Rest Complete'));

    // Either the timer is running (with +/- buttons) or it completed
    expect(addVisible || subtractVisible || restComplete).toBeTruthy();
  });

  test('test_timer_persists_across_tabs: rest timer pill stays visible when switching tabs', async ({ page }) => {
    await openFirstExercise(page);

    const logSetButton = page.getByRole('button', { name: 'Log Set' });
    await expect(logSetButton).toBeVisible();

    // Log a set to start the rest timer
    await logSetButton.click();
    await expect(page.getByText('Set logged')).toBeVisible({ timeout: 10_000 });

    // Wait for the timer pill to appear
    const timerPill = page.getByText(/^\d+:\d{2}$/).or(page.getByText('Rest Complete'));
    await expect(timerPill).toBeVisible({ timeout: 5_000 });

    // Navigate to History tab — the GlobalRestTimer is mounted in AppLayout,
    // so it should persist across tab switches
    await goToTab(page, 'History');
    await expect(page).toHaveURL(/\/history/, { timeout: 10_000 });

    // The rest timer pill should still be visible on the History page
    // It is rendered as a fixed-position overlay by GlobalRestTimer in AppLayout
    const timerOnHistory = page.getByText(/^\d+:\d{2}$/).or(page.getByText('Rest Complete'));
    await expect(timerOnHistory).toBeVisible({ timeout: 5_000 });

    // Navigate to Stats tab to double-check persistence
    await goToTab(page, 'Stats');
    await expect(page).toHaveURL(/\/stats/, { timeout: 10_000 });

    const timerOnStats = page.getByText(/^\d+:\d{2}$/).or(page.getByText('Rest Complete'));
    await expect(timerOnStats).toBeVisible({ timeout: 5_000 });
  });
});
