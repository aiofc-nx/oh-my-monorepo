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

  if (options.unitTestRunner === 'vitest') {
    project.targets.test = {
      executor: '@nx/vitest:test',
      outputs: [`{workspaceRoot}/coverage/${options.projectRoot}`],
      options: {
        config: joinPathFragments(options.projectRoot, 'vitest.config.ts'),
      },
    };
  }

  project.targets.lint = {
    executor: '@berenddeboer/nx-biome:biome-lint',
    options: {
      lintFilePatterns: [`${options.projectRoot}/**/*.ts`],
    },
  };

  if (options.buildable || options.publishable) {
    project.targets.build = {
      executor: '@nx/js:tsc',
      outputs: ['{options.outputPath}'],
      options: {
        outputPath: `dist/${options.projectRoot}`,
        tsConfig: `${options.projectRoot}/tsconfig.lib.json`,
        packageJson: `${options.projectRoot}/package.json`,
        main: `${options.projectRoot}/src/index.ts`,
        assets: [`${options.projectRoot}/*.md`],
      },
    };
  }

  if (options.tags) {
    project.tags = options.parsedTags;
  } else {
    project.tags = [
      'type:lib',
      'framework:nest',
      'test:vitest',
      'linter:biome',
    ];
  }

  updateProjectConfiguration(tree, options.projectName, project);
}
