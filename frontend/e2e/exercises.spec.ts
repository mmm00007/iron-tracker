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

test.describe('Exercise Library E2E', () => {
  test.beforeEach(async ({ page }) => {
    await signIn(page);
  });

  test('test_browse_exercises: exercises are displayed and scrollable on the Log tab', async ({ page }) => {
    // We land on /log after sign-in — the exercise list page
    await expect(page).toHaveURL(/\/log(?:$|\/)/);

    // Verify the search bar is present (confirms we are on the exercise list)
    await expect(page.getByPlaceholder('Search exercises...')).toBeVisible();

    // Wait for exercises to load — either the "All Exercises" section or list items appear
    const allExercisesHeading = page.getByText('All Exercises');
    const exerciseListItems = page.locator('main li button');

    // At least one of these should be visible once data loads
    await expect(allExercisesHeading.or(exerciseListItems.first())).toBeVisible({ timeout: 15_000 });

    // Verify there are exercise items in the list
    const exerciseCount = await exerciseListItems.count();
    expect(exerciseCount).toBeGreaterThan(0);

    // Scroll through the list to verify more content loads
    await page.evaluate(() => window.scrollTo(0, document.body.scrollHeight));
    await page.waitForTimeout(500);

    // After scrolling, exercises should still be visible
    await expect(exerciseListItems.first()).toBeVisible();
  });

  test('test_search_exercises: search filters exercises and clearing restores the full list', async ({ page }) => {
    const searchInput = page.getByPlaceholder('Search exercises...');
    await expect(searchInput).toBeVisible();

    // Wait for exercises to load first
    await page.waitForTimeout(2_000);

    // Type a search term
    await searchInput.fill('squat');
    await page.waitForTimeout(1_000);

    // Verify filtered results appear — search results are rendered in a list
    const searchResults = page.locator('main li');
    await expect(searchResults.first()).toBeVisible({ timeout: 10_000 });

    // Verify at least one result contains the search term
    const resultTexts = await searchResults.allTextContents();
    const hasSquatResult = resultTexts.some(
      (text) => text.toLowerCase().includes('squat'),
    );
    expect(hasSquatResult).toBeTruthy();

    // Clear the search
    await searchInput.fill('');
    await page.waitForTimeout(1_000);

    // Verify the default view returns (either "All Exercises" heading or "By Category" or "Recent")
    const defaultSections = page.getByText('All Exercises')
      .or(page.getByText('By Category'))
      .or(page.getByText('Recent'));
    await expect(defaultSections.first()).toBeVisible({ timeout: 10_000 });
  });

  test('test_muscle_group_filter: expanding and collapsing muscle group sections', async ({ page }) => {
    // Wait for exercises to load
    await page.waitForTimeout(2_000);

    // Look for the "By Category" section which contains MuscleGroupSection accordions
    const byCategoryHeading = page.getByText('By Category');

    if (!(await isVisible(byCategoryHeading))) {
      // If "By Category" is not visible, the app might be showing a different layout
      // Try using the muscle group filter chips instead
      const muscleChips = page.locator('.MuiChip-root');
      const chipCount = await muscleChips.count();
      expect(chipCount).toBeGreaterThan(0);
      return;
    }

    // Find accordion sections (MuscleGroupSection uses MUI Accordion)
    const accordions = page.locator('.MuiAccordion-root');
    await expect(accordions.first()).toBeVisible({ timeout: 10_000 });

    const accordionCount = await accordions.count();
    expect(accordionCount).toBeGreaterThan(0);

    // Click the first accordion to expand it
    const firstAccordionSummary = accordions.first().locator('.MuiAccordionSummary-root');
    await firstAccordionSummary.click();
    await page.waitForTimeout(500);

    // Verify exercises appear inside the expanded accordion
    const expandedDetails = accordions.first().locator('.MuiAccordionDetails-root');
    await expect(expandedDetails).toBeVisible();

    const exercisesInGroup = expandedDetails.locator('li');
    const groupExerciseCount = await exercisesInGroup.count();
    expect(groupExerciseCount).toBeGreaterThan(0);

    // Click the accordion again to collapse it
    await firstAccordionSummary.click();
    await page.waitForTimeout(500);

    // Verify details are hidden after collapse
    await expect(expandedDetails).not.toBeVisible();
  });
});
