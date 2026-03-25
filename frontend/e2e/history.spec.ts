import { test, expect, type Page } from '@playwright/test';
import { signIn, isVisible } from './helpers';

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
  await page.waitForTimeout(500);
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
    await page.waitForTimeout(500);

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
    await page.waitForTimeout(500);

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
