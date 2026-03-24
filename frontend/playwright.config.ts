import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  fullyParallel: false,
  workers: 1,
  timeout: 90_000,
  expect: {
    timeout: 10_000,
  },
  reporter: [
    ['list'],
    ['json', { outputFile: '../output/playwright/results.json' }],
    ['html', { open: 'never', outputFolder: '../output/playwright/html-report' }],
  ],
  outputDir: '../output/playwright/test-results',
  use: {
    baseURL: 'https://iron-tracker-app.netlify.app',
    viewport: { width: 430, height: 932 },
    trace: 'retain-on-failure',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },
});
