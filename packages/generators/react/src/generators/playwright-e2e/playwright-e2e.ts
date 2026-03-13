import type { GeneratorCallback, Tree } from '@nx/devkit';
import {
  addDependenciesToPackageJson,
  formatFiles,
  getProjects,
  joinPathFragments,
  updateProjectConfiguration,
} from '@nx/devkit';
import { playwrightVersion } from '../../utils/versions';

export interface PlaywrightE2ESchema {
  project: string;
  skipFormat?: boolean;
  skipPackageJson?: boolean;
}

export async function playwrightE2EGenerator(
  tree: Tree,
  options: PlaywrightE2ESchema,
): Promise<GeneratorCallback> {
  const projects = getProjects(tree);
  const project = projects.get(options.project);

  if (!project) {
    throw new Error(`Project "${options.project}" not found.`);
  }

  const tasks: GeneratorCallback[] = [];
  const projectRoot = project.root;

  tree.write(
    joinPathFragments(projectRoot, 'playwright.config.ts'),
    `import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
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
    command: 'pnpm nx serve ${options.project}',
    url: 'http://localhost:4200',
    reuseExistingServer: !process.env.CI,
  },
});
`,
  );

  tree.write(
    joinPathFragments(projectRoot, 'e2e', 'app.spec.ts'),
    `import { test, expect } from '@playwright/test';

test('has title', async ({ page }) => {
  await page.goto('/');

  await expect(page).toHaveTitle(/React/);
});

test('get started link', async ({ page }) => {
  await page.goto('/');

  await expect(page.getByRole('heading', { name: 'Welcome' })).toBeVisible();
});
`,
  );

  project.targets = project.targets || {};
  project.targets.e2e = {
    executor: 'nx:run-commands',
    options: {
      command: `playwright test`,
      cwd: projectRoot,
    },
    configurations: {
      production: {
        command: `playwright test`,
      },
    },
  };

  project.targets['e2e:ui'] = {
    executor: 'nx:run-commands',
    options: {
      command: `playwright test --ui`,
      cwd: projectRoot,
    },
  };

  updateProjectConfiguration(tree, options.project, project);

  if (!options.skipPackageJson) {
    const depsTask = addDependenciesToPackageJson(
      tree,
      {},
      {
        '@playwright/test': playwrightVersion,
      },
    );
    tasks.push(depsTask);
  }

  if (!options.skipFormat) {
    await formatFiles(tree);
  }

  return () => {
    tasks.forEach((task) => task());
  };
}

export default playwrightE2EGenerator;
