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

/** Navigate to the first available exercise's set logger page. */
async function openFirstExercise(page: Page): Promise<string> {
  const searchInput = page.getByPlaceholder('Search exercises...');
  const searchTerms = ['press', 'row', 'curl', 'squat'];

  for (const term of searchTerms) {
    await searchInput.fill(term);
    await page.waitForTimeout(500);

    const candidate = page.locator('main li button').first();
    if (await candidate.isVisible().catch(() => false)) {
      const rawName = (await candidate.textContent())?.trim() ?? 'Exercise';
      const exerciseName = rawName.split(/\s{2,}|\n/)[0]?.trim() || 'Exercise';
      await candidate.click();
      await expect(page.getByRole('button', { name: 'Log Set' })).toBeVisible();
      return exerciseName;
    }
  }

  await searchInput.fill('');
  await page.waitForTimeout(500);

  const firstResult = page.locator('main li button').first();
  if (!(await firstResult.isVisible().catch(() => false))) {
    throw new Error('No exercise entries were available from search or the default catalog.');
  }

  const rawName = (await firstResult.textContent())?.trim() ?? 'Exercise';
  const exerciseName = rawName.split(/\s{2,}|\n/)[0]?.trim() || 'Exercise';

  await firstResult.click();
  await expect(page.getByRole('button', { name: 'Log Set' })).toBeVisible();

  return exerciseName;
}

test.describe('Set Logging E2E', () => {
  test.beforeEach(async ({ page }) => {
    await signIn(page);
  });

  test('test_log_first_set: log a set with weight and reps and verify it appears', async ({ page }) => {
    await openFirstExercise(page);

    // The set logger page should be visible with weight/reps inputs and the Log Set button
    const logSetButton = page.getByRole('button', { name: 'Log Set' });
    await expect(logSetButton).toBeVisible();

    // Record current delete button count (sets already logged today)
    const deleteButtonsBefore = await page.locator('[aria-label^="Delete set"]').count();

    // Adjust weight using a stepper — tap +2.5
    await page.getByRole('button', { name: '+2.5' }).click();

    // Tap Log Set
    await logSetButton.click();

    // Verify "Set logged" snackbar appears
    await expect(page.getByText('Set logged')).toBeVisible({ timeout: 10_000 });

    // Verify a new set row appeared (delete button count increased)
    await expect(page.locator('[aria-label^="Delete set"]').first()).toBeVisible();
    const deleteButtonsAfter = await page.locator('[aria-label^="Delete set"]').count();
    expect(deleteButtonsAfter).toBeGreaterThanOrEqual(deleteButtonsBefore + 1);
  });

  test('test_one_tap_repeat: second tap logs an identical set via pre-fill', async ({ page }) => {
    await openFirstExercise(page);

    const logSetButton = page.getByRole('button', { name: 'Log Set' });
    await expect(logSetButton).toBeVisible();

    // Log the first set
    await logSetButton.click();
    await expect(page.getByText('Set logged')).toBeVisible({ timeout: 10_000 });

    // Wait for the snackbar to dismiss and pre-fill to apply
    await page.waitForTimeout(1_500);

    // The weight and reps should be pre-filled with the same values (1-tap repeat feature)
    // Simply tap Log Set again — the pre-fill means identical values are ready
    await logSetButton.click();
    await expect(page.getByText('Set logged')).toBeVisible({ timeout: 10_000 });

    // Verify at least 2 sets are now displayed
    const deleteButtons = await page.locator('[aria-label^="Delete set"]').count();
    expect(deleteButtons).toBeGreaterThanOrEqual(2);
  });

  test('test_stepper_adjustment: use +5 weight stepper and verify value changed before logging', async ({ page }) => {
    await openFirstExercise(page);

    const logSetButton = page.getByRole('button', { name: 'Log Set' });
    await expect(logSetButton).toBeVisible();

    // Read the current weight display value
    const weightDisplay = page.locator('[aria-label="Edit weight"]');
    await expect(weightDisplay).toBeVisible();
    const weightTextBefore = await weightDisplay.textContent();
    const weightBefore = parseFloat(weightTextBefore?.replace(/[^\d.]/g, '') ?? '0');

    // Click the +5 stepper
    await page.getByRole('button', { name: '+5' }).click();
    await page.waitForTimeout(300);

    // Verify the weight display updated
    const weightTextAfter = await weightDisplay.textContent();
    const weightAfter = parseFloat(weightTextAfter?.replace(/[^\d.]/g, '') ?? '0');
    expect(weightAfter).toBeCloseTo(weightBefore + 5, 1);

    // Log the set with the adjusted weight
    await logSetButton.click();
    await expect(page.getByText('Set logged')).toBeVisible({ timeout: 10_000 });

    // Verify the set appears
    await expect(page.locator('[aria-label^="Delete set"]').first()).toBeVisible();
  });
});
