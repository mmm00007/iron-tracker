import { test, expect, type Page } from '@playwright/test';
import { signIn } from './helpers';

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
    await page.waitForTimeout(500);

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
