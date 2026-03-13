import {
  joinPathFragments,
  readProjectConfiguration,
  Tree,
  updateProjectConfiguration,
} from '@nx/devkit';
import type { NormalizedOptions } from '../schema';

export function updateProject(tree: Tree, options: NormalizedOptions): void {
  const project = readProjectConfiguration(tree, options.projectName);

  project.targets = project.targets || {};

  project.targets.test = {
    executor: '@nx/vitest:test',
    outputs: [`{workspaceRoot}/coverage/${options.projectRoot}`],
    options: {
      config: joinPathFragments(options.projectRoot, 'vitest.config.ts'),
    },
  };

  project.targets.lint = {
    executor: '@berenddeboer/nx-biome:biome-lint',
    options: {
      lintFilePatterns: [`${options.projectRoot}/**/*.ts`],
    },
  };

  project.targets.serve = {
    continuous: true,
    executor: 'nx:run-commands',
    defaultConfiguration: 'development',
    dependsOn: ['build'],
    options: {
      command: `node ${options.projectRoot}/dist/main.js`,
    },
    configurations: {
      development: {
        command: `node ${options.projectRoot}/dist/main.js`,
      },
      production: {
        command: `node ${options.projectRoot}/dist/main.js`,
      },
    },
  };

  updateProjectConfiguration(tree, options.projectName, project);
}
