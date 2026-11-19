import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './specs',
  globalSetup: './harness/global-setup.ts',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  // No retries during the PoC: a flaky test should fail loudly, not pass on a retry.
  retries: 0,
  reporter: [['list'], ['html', { open: 'never' }]],
  use: {
    trace: 'retain-on-failure',
    screenshot: 'only-on-failure',
  },
  projects: [{ name: 'chromium', use: { ...devices['Desktop Chrome'] } }],
});
