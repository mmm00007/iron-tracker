import { expect, type Page, type Locator } from '@playwright/test';

const USERNAME = process.env.PLAYWRIGHT_TEST_USERNAME;
const PASSWORD = process.env.PLAYWRIGHT_TEST_PASSWORD;

export function requireCredentials() {
  if (!USERNAME || !PASSWORD) {
    throw new Error('Missing PLAYWRIGHT_TEST_USERNAME or PLAYWRIGHT_TEST_PASSWORD');
  }
  return { username: USERNAME, password: PASSWORD };
}

export async function isVisible(locator: Locator) {
  try {
    return await locator.isVisible();
  } catch {
    return false;
  }
}

export async function clickIfVisible(locator: Locator) {
  if (await isVisible(locator)) {
    await locator.click();
    return true;
  }
  return false;
}

export async function waitForKnownPath(page: Page) {
  await page.waitForFunction(
    () => {
      const path = window.location.pathname;
      return path.startsWith('/login') || path.startsWith('/log') || path.startsWith('/onboarding');
    },
    undefined,
    { timeout: 15_000 },
  );
}

export async function completeOnboardingIfNeeded(page: Page) {
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

export async function signIn(page: Page) {
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
    await page.waitForTimeout(500);
  }

  await expect(page).toHaveURL(/\/log(?:$|\/)/);
  await expect(page.getByPlaceholder('Search exercises...')).toBeVisible();
}
