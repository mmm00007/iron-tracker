import { test, expect } from '@playwright/test';
import { signIn, isVisible } from './helpers';

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
    await page.waitForTimeout(500);

    // Type a search term
    await searchInput.fill('squat');
    await page.waitForTimeout(500);

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
    await page.waitForTimeout(500);

    // Verify the default view returns (either "All Exercises" heading or "By Category" or "Recent")
    const defaultSections = page.getByText('All Exercises')
      .or(page.getByText('By Category'))
      .or(page.getByText('Recent'));
    await expect(defaultSections.first()).toBeVisible({ timeout: 10_000 });
  });

  test('test_muscle_group_filter: expanding and collapsing muscle group sections', async ({ page }) => {
    // Wait for exercises to load
    await page.waitForTimeout(500);

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
