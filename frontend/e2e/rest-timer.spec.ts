import { test, expect, type Page } from '@playwright/test';
import { signIn, isVisible } from './helpers';

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
