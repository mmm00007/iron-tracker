import { test, expect, type Page } from '@playwright/test';
import { signIn, isVisible, waitForKnownPath } from './helpers';

const browserIssues = new WeakMap<Page, string[]>();
const observations = new WeakMap<Page, string[]>();

function note(page: Page, message: string) {
  observations.get(page)?.push(message);
}

function recordIssue(page: Page, message: string) {
  browserIssues.get(page)?.push(message);
}

async function goToTab(page: Page, tabName: 'Log' | 'History' | 'Stats' | 'Profile') {
  await page.getByRole('button', { name: new RegExp(`^${tabName}$`) }).click();
}

async function openFirstExercise(page: Page) {
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

test.beforeEach(async ({ page }) => {
  browserIssues.set(page, []);
  observations.set(page, []);

  page.on('pageerror', (error) => {
    recordIssue(page, `[pageerror] ${error.message}`);
  });

  page.on('console', (msg) => {
    if (msg.type() === 'error') {
      recordIssue(page, `[console:error] ${msg.text()}`);
    }
  });

  page.on('requestfailed', (request) => {
    recordIssue(
      page,
      `[requestfailed] ${request.method()} ${request.url()} :: ${request.failure()?.errorText ?? 'unknown error'}`,
    );
  });

  page.on('response', (response) => {
    const request = response.request();
    if ((request.resourceType() === 'fetch' || request.resourceType() === 'xhr') && response.status() >= 400) {
      recordIssue(page, `[response:${response.status()}] ${request.method()} ${response.url()}`);
    }
  });
});

test.afterEach(async ({ page }, testInfo) => {
  const issueLines = browserIssues.get(page) ?? [];
  const observationLines = observations.get(page) ?? [];

  if (issueLines.length > 0) {
    await testInfo.attach('browser-issues', {
      body: issueLines.join('\n'),
      contentType: 'text/plain',
    });
  }

  if (observationLines.length > 0) {
    await testInfo.attach('observations', {
      body: observationLines.join('\n'),
      contentType: 'text/plain',
    });
  }
});

test('auth flow validates inputs, exposes password reset, and allows sign-in', async ({ page }) => {
  await page.goto('/log');
  await waitForKnownPath(page);

  await expect(page).toHaveURL(/\/login/);
  await expect(page.getByRole('button', { name: 'Sign in', exact: true })).toBeVisible();

  await page.getByRole('button', { name: 'Sign in', exact: true }).click();
  await expect.soft(page.getByText('Email is required')).toBeVisible();
  await expect.soft(page.getByText('Password is required')).toBeVisible();

  await page.getByRole('link', { name: 'Forgot password?' }).click();
  await expect(page).toHaveURL(/\/forgot-password/);
  await expect.soft(page.getByText('Reset your password')).toBeVisible();
  await expect.soft(page.getByRole('button', { name: 'Send reset link' })).toBeVisible();

  await page.getByRole('link', { name: /Back to sign in/i }).click();
  await expect(page).toHaveURL(/\/login/);

  await signIn(page);
});

test('logging flow can find an exercise, capture metadata, and record a set', async ({ page }) => {
  await signIn(page);
  const exerciseName = await openFirstExercise(page);

  await page.getByRole('button', { name: '+2.5' }).click();
  await page.getByText('RPE').click();
  await page.getByRole('button', { name: '8.5' }).click();
  await page.getByText('Set Type').click();
  await page.getByRole('button', { name: 'AMRAP' }).click();
  await page.getByText('Notes').click();
  await page.getByPlaceholder('Add a note for this set…').fill('playwright live audit');

  const deleteButtonsBefore = await page.locator('[aria-label^="Delete set"]').count();

  await page.getByRole('button', { name: 'Log Set' }).click();
  await expect(page.getByText('Set logged')).toBeVisible();
  await expect(page.locator('[aria-label^="Delete set"]').first()).toBeVisible();

  const deleteButtonsAfter = await page.locator('[aria-label^="Delete set"]').count();
  expect.soft(deleteButtonsAfter).toBeGreaterThanOrEqual(deleteButtonsBefore + 1);
  await expect.soft(page.getByText('RPE 8.5')).toBeVisible();
  await expect.soft(page.getByText('AMRAP')).toBeVisible();
  await expect.soft(page.getByText(/playwright live audit/)).toBeVisible();

  note(page, `Logged a live test set on exercise "${exerciseName}".`);
});

test('history flow shows sessions and opens session details', async ({ page }) => {
  await signIn(page);
  await goToTab(page, 'History');

  await expect(page).toHaveURL(/\/history/);

  if (await isVisible(page.getByRole('heading', { name: 'No workouts yet' }))) {
    note(page, 'History remained empty during the audit run.');
    return;
  }

  const firstSession = page.locator('main .MuiCardActionArea-root').first();
  await expect(firstSession).toBeVisible();
  await firstSession.click();

  await expect(page).toHaveURL(/\/history\//);
  await expect.soft(page.getByText('Duration')).toBeVisible();
  await expect.soft(page.getByText('Sets')).toBeVisible();
  await expect.soft(page.getByText('Exercises')).toBeVisible();
  await expect.soft(page.getByText('Volume')).toBeVisible();
});

test('stats flow loads filters and drills into an exercise when data exists', async ({ page }) => {
  await signIn(page);
  await goToTab(page, 'Stats');

  await expect(page).toHaveURL(/\/stats/);
  await expect.soft(page.getByRole('heading', { name: 'Stats' })).toBeVisible();
  await page.getByRole('button', { name: 'This Week' }).click();
  await page.getByRole('button', { name: 'This Month' }).click();

  if (await isVisible(page.getByRole('heading', { name: 'Your stats will appear here' }))) {
    note(page, 'Stats page showed the empty state.');
    return;
  }

  const topExercise = page.locator('main .MuiListItemButton-root').first();
  await expect(topExercise).toBeVisible();
  await topExercise.click();

  await expect(page).toHaveURL(/\/stats\//);
  await expect.soft(page.getByRole('tab', { name: 'Strength' })).toBeVisible();
  await expect.soft(page.getByRole('tab', { name: 'Volume' })).toBeVisible();
  await expect.soft(page.getByRole('tab', { name: 'History' })).toBeVisible();

  await page.getByRole('tab', { name: 'Volume' }).click();
  await expect.soft(page.getByText('Weekly Volume')).toBeVisible();

  await page.getByRole('tab', { name: 'History' }).click();
  await expect.soft(page.getByText('All Sets')).toBeVisible();
});

test('machine identify flow accepts file upload and responds gracefully', async ({ page }) => {
  await signIn(page);
  await page.goto('/log/identify');

  await expect(page).toHaveURL(/\/log\/identify/);
  await expect.soft(page.getByText('Identify a Machine')).toBeVisible();
  await expect.soft(page.getByRole('button', { name: 'Take Photo' })).toBeVisible();
  await expect.soft(page.getByRole('button', { name: 'Choose from Gallery' })).toBeVisible();

  const sampleImage = new URL('../public/icons/icon-512.png', import.meta.url).pathname;
  await page.locator('input[type="file"]').nth(1).setInputFiles(sampleImage);

  await page.waitForTimeout(20_000);

  const stillLoading = await isVisible(page.getByText('Identifying machine…'));
  const sawError = await isVisible(page.getByText("Couldn't identify machine"));
  const sawResult = await isVisible(page.getByRole('button', { name: 'Create Variant' }));

  expect.soft(sawError || sawResult || !stillLoading).toBeTruthy();

  if (stillLoading) {
    note(page, 'Machine identify remained in the loading state for 20 seconds after upload.');
  }

  if (sawError) {
    const errorText = (await page.locator('main').textContent())?.replace(/\s+/g, ' ').trim() ?? '';
    note(page, `Machine identify returned an error state: ${errorText}`);
  }

  if (sawResult) {
    await page.getByRole('button', { name: 'Create Variant' }).click();
    const sheetVisible = await isVisible(page.getByRole('dialog'));
    expect.soft(sheetVisible).toBeTruthy();
    if (!sheetVisible) {
      note(page, 'Create Variant action did not open a bottom sheet after a successful identification.');
    }
  }
});

test('profile can save and sign out, and unknown routes show the not-found state', async ({ page }) => {
  await signIn(page);
  await goToTab(page, 'Profile');

  await expect(page).toHaveURL(/\/profile/);
  await expect.soft(page.getByRole('heading', { name: 'Profile' })).toBeVisible();
  await page.getByRole('button', { name: 'Save' }).click();
  await expect.soft(page.getByText('Profile saved successfully.')).toBeVisible();

  await page.getByRole('button', { name: 'Sign out' }).click();
  await expect(page).toHaveURL(/\/login/);

  await page.goto('/definitely-not-a-real-route');
  await expect.soft(page.getByText('Page not found')).toBeVisible();
  await expect.soft(page.getByRole('button', { name: 'Go to Log' })).toBeVisible();
});

test.describe('desktop smoke', () => {
  test.use({ viewport: { width: 1440, height: 900 } });

  test('desktop layout keeps auth and primary navigation usable', async ({ page }) => {
    await signIn(page);

    await expect.soft(page.getByText('Iron Tracker').first()).toBeVisible();
    await expect.soft(page.getByRole('button', { name: 'Log' })).toBeVisible();
    await expect.soft(page.getByRole('button', { name: 'History' })).toBeVisible();
    await expect.soft(page.getByRole('button', { name: 'Stats' })).toBeVisible();
    await expect.soft(page.getByRole('button', { name: 'Profile' })).toBeVisible();

    await goToTab(page, 'Profile');
    await expect.soft(page.getByRole('heading', { name: 'Profile' })).toBeVisible();
  });
});
