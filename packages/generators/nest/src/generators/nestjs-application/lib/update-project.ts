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

  updateProjectConfiguration(tree, options.projectName, project);
}
