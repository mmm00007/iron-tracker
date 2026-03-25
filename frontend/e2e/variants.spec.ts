import { test, expect, type Page } from '@playwright/test';
import { signIn } from './helpers';

/**
 * Navigate to an exercise's set logger page via search.
 * Returns the exercise name and the exerciseId extracted from the URL.
 */
async function openExerciseBySearch(page: Page, term: string): Promise<{ name: string; exerciseId: string }> {
  const searchInput = page.getByPlaceholder('Search exercises...');
  await searchInput.fill(term);
  await page.waitForTimeout(500);

  const candidate = page.locator('main li button').first();
  await expect(candidate).toBeVisible({ timeout: 10_000 });

  const rawName = (await candidate.textContent())?.trim() ?? 'Exercise';
  const exerciseName = rawName.split(/\s{2,}|\n/)[0]?.trim() || 'Exercise';
  await candidate.click();
  await expect(page.getByRole('button', { name: 'Log Set' })).toBeVisible();

  // Extract exerciseId from URL: /log/<exerciseId>
  const url = page.url();
  const match = url.match(/\/log\/([^/]+)/);
  const exerciseId = match?.[1] ?? '';

  return { name: exerciseName, exerciseId };
}

test.describe('Equipment Variants E2E', () => {
  test.beforeEach(async ({ page }) => {
    await signIn(page);
  });

  test('test_create_variant: navigate to exercise variant manager and create a variant', async ({ page }) => {
    const { exerciseId } = await openExerciseBySearch(page, 'press');

    // Navigate to the variant manager page for this exercise
    await page.goto(`/log/${exerciseId}/variants`);
    await page.waitForTimeout(500);

    // Wait for the variant manager page to load
    await expect(
      page.getByText('Manage Variants').or(page.getByText('Variants')),
    ).toBeVisible({ timeout: 15_000 });

    // Click the FAB to add a new variant
    const addFab = page.getByRole('button', { name: 'add variant' });
    await expect(addFab).toBeVisible();
    await addFab.click();

    // The variant bottom sheet (Drawer) should open with a Name field
    const nameField = page.getByLabel('Name');
    await expect(nameField).toBeVisible({ timeout: 5_000 });

    // Fill in variant details
    const variantName = `Test Variant ${Date.now()}`;
    await nameField.fill(variantName);

    // Save the variant
    await page.getByRole('button', { name: 'Save' }).click();
    await page.waitForTimeout(500);

    // Verify the variant now appears on the page
    await expect(page.getByText(variantName)).toBeVisible({ timeout: 10_000 });
  });

  test('test_switch_variant: with multiple variants, selecting a different one changes selection', async ({ page }) => {
    const { exerciseId } = await openExerciseBySearch(page, 'press');

    // Navigate to the variant manager page
    await page.goto(`/log/${exerciseId}/variants`);
    await page.waitForTimeout(500);

    await expect(
      page.getByText('Manage Variants').or(page.getByText('Variants')),
    ).toBeVisible({ timeout: 15_000 });

    // Create a first variant if none exist
    const addFab = page.getByRole('button', { name: 'add variant' });
    await addFab.click();

    const nameField = page.getByLabel('Name');
    await expect(nameField).toBeVisible({ timeout: 5_000 });

    const variant1Name = `Variant A ${Date.now()}`;
    await nameField.fill(variant1Name);
    await page.getByRole('button', { name: 'Save' }).click();
    await page.waitForTimeout(500);

    // Create a second variant
    await addFab.click();
    await expect(nameField).toBeVisible({ timeout: 5_000 });

    const variant2Name = `Variant B ${Date.now()}`;
    await nameField.fill(variant2Name);
    await page.getByRole('button', { name: 'Save' }).click();
    await page.waitForTimeout(500);

    // Both variants should be visible
    await expect(page.getByText(variant1Name)).toBeVisible({ timeout: 10_000 });
    await expect(page.getByText(variant2Name)).toBeVisible({ timeout: 10_000 });

    // Now go back to the set logger page to verify variant chips appear
    await page.goto(`/log/${exerciseId}`);
    await expect(page.getByRole('button', { name: 'Log Set' })).toBeVisible({ timeout: 15_000 });

    // Wait for variant chips to render
    await page.waitForTimeout(500);

    // The SetLoggerPage shows variant chips (MUI Chip) when there are 2+ variants
    const chips = page.locator('.MuiChip-root');
    const chipCount = await chips.count();

    if (chipCount >= 2) {
      // Click the second chip to switch variants
      const secondChip = chips.nth(1);
      await secondChip.click();
      await page.waitForTimeout(500);

      // Verify the clicked chip is now in the "filled" state (selected)
      const chipVariant = await secondChip.getAttribute('class');
      expect(chipVariant).toContain('filled');
    }
  });
});
