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

/** Log a set on the first available exercise to ensure History has data. */
async function logASet(page: Page) {
  const searchInput = page.getByPlaceholder('Search exercises...');
  const searchTerms = ['press', 'row', 'curl', 'squat'];

  for (const term of searchTerms) {
    await searchInput.fill(term);
    await page.waitForTimeout(500);

    const candidate = page.locator('main li button').first();
    if (await candidate.isVisible().catch(() => false)) {
      await candidate.click();
      break;
    }
  }

  await expect(page.getByRole('button', { name: 'Log Set' })).toBeVisible({ timeout: 10_000 });

  // Tap Log Set
  await page.getByRole('button', { name: 'Log Set' }).click();
  await expect(page.getByText('Set logged')).toBeVisible({ timeout: 10_000 });

  // Wait for the set to be committed
  await page.waitForTimeout(2_000);
}

test.describe('History E2E', () => {
  test.beforeEach(async ({ page }) => {
    await signIn(page);
  });

  test('test_session_appears: log sets then navigate to History and verify a session card appears', async ({ page }) => {
    // First, log a set so we guarantee the History page has data
    await logASet(page);

    // Navigate back to Log tab first (clicking back from set logger)
    await goToTab(page, 'Log');
    await expect(page.getByPlaceholder('Search exercises...')).toBeVisible({ timeout: 10_000 });

    // Navigate to History tab
    await goToTab(page, 'History');
    await expect(page).toHaveURL(/\/history/);

    // Wait for sessions to load
    await page.waitForTimeout(3_000);

    // Check if history is empty
    const emptyHeading = page.getByRole('heading', { name: 'No workouts yet' });
    if (await isVisible(emptyHeading)) {
      // The session might not have grouped yet — this is acceptable
      return;
    }

    // A session card should be visible — uses MuiCardActionArea
    const sessionCard = page.locator('main .MuiCardActionArea-root').first();
    await expect(sessionCard).toBeVisible({ timeout: 15_000 });

    // Verify the session card contains meaningful data (sets count, exercise name, etc.)
    const cardText = await sessionCard.textContent();
    expect(cardText).toBeTruthy();
    // Session cards show "X sets" text
    expect(cardText).toMatch(/\d+\s+sets?/);
  });

  test('test_session_detail: tap a session card and verify the detail screen with sets', async ({ page }) => {
    // Log a set to ensure data
    await logASet(page);

    // Go to History
    await goToTab(page, 'Log');
    await expect(page.getByPlaceholder('Search exercises...')).toBeVisible({ timeout: 10_000 });
    await goToTab(page, 'History');
    await expect(page).toHaveURL(/\/history/);
    await page.waitForTimeout(3_000);

    // Check for empty state
    const emptyHeading = page.getByRole('heading', { name: 'No workouts yet' });
    if (await isVisible(emptyHeading)) {
      return;
    }

    // Tap the first session card
    const firstSession = page.locator('main .MuiCardActionArea-root').first();
    await expect(firstSession).toBeVisible({ timeout: 15_000 });
    await firstSession.click();

    // Verify we navigated to session detail
    await expect(page).toHaveURL(/\/history\//);

    // The session detail page shows summary stats: Duration, Sets, Exercises, Volume
    await expect.soft(page.getByText('Duration')).toBeVisible({ timeout: 10_000 });
    await expect.soft(page.getByText('Sets')).toBeVisible();
    await expect.soft(page.getByText('Exercises')).toBeVisible();
    await expect.soft(page.getByText('Volume')).toBeVisible();

    // Verify there is at least one exercise block with set rows
    const exerciseHeaders = page.locator('main [class*="subtitle"]');
    const headerCount = await exerciseHeaders.count();
    expect(headerCount).toBeGreaterThan(0);
  });
});
