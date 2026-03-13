import { addProjectConfiguration, joinPathFragments, Tree } from '@nx/devkit';
import type { NormalizedOptions } from '../schema';

export function addE2e(tree: Tree, options: NormalizedOptions): void {
  if (options.e2eTestRunner === 'none' || !options.e2eProjectRoot) {
    return;
  }

  const e2eProjectRoot = options.e2eProjectRoot;

  addProjectConfiguration(tree, options.e2eProjectName!, {
    root: e2eProjectRoot,
    sourceRoot: joinPathFragments(e2eProjectRoot, 'src'),
    projectType: 'application',
    targets: {
      e2e: {
        executor: '@nx/playwright:playwright',
        options: {
          configFile: joinPathFragments(e2eProjectRoot, 'playwright.config.ts'),
          devServerTarget: `${options.projectName}:serve:development`,
          webServer: {
            command: `pnpm nx serve ${options.projectName}`,
            url: 'http://localhost:4200',
            reuseExistingServer: true,
          },
        },
        configurations: {
          production: {
            devServerTarget: `${options.projectName}:serve:production`,
          },
        },
      },
    },
    tags: options.parsedTags.map((t) => t.replace('type:app', 'type:e2e')),
  });

  createE2eFiles(tree, options);
}

function createE2eFiles(tree: Tree, options: NormalizedOptions): void {
  const e2eProjectRoot = options.e2eProjectRoot!;

  tree.write(
    joinPathFragments(e2eProjectRoot, 'playwright.config.ts'),
    `import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './src',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  use: {
    baseURL: 'http://localhost:4200',
    trace: 'on-first-retry',
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },
    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
    },
  ],
  webServer: {
    command: 'pnpm nx serve ${options.projectName}',
    url: 'http://localhost:4200',
    reuseExistingServer: !process.env.CI,
  },
});
`,
  );

  tree.write(
    joinPathFragments(e2eProjectRoot, 'src', 'example.spec.ts'),
    `import { test, expect } from '@playwright/test';

test('has title', async ({ page }) => {
  await page.goto('/');

  await expect(page).toHaveTitle(/Welcome/);
});

test('get started link', async ({ page }) => {
  await page.goto('/');

  await page.getByRole('link', { name: 'Get Started' }).click();

  await expect(page).toHaveURL(/docs/);
});
`,
  );
}
