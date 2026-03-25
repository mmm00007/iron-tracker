import { defineConfig } from '@playwright/test';

const isLocal = process.env.PLAYWRIGHT_BASE_URL?.includes('localhost');

export default defineConfig({
  testDir: './e2e',
  fullyParallel: false,
  workers: 1,
  timeout: isLocal ? 60_000 : 90_000,
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
    baseURL: process.env.PLAYWRIGHT_BASE_URL || 'https://iron-tracker-app.netlify.app',
    viewport: { width: 430, height: 932 },
    trace: 'retain-on-failure',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },
});
