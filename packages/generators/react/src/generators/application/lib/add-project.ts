import {
  addProjectConfiguration,
  joinPathFragments,
  ProjectConfiguration,
  Tree,
  writeJson,
} from '@nx/devkit';
import type { NormalizedOptions } from '../schema';

export function addProject(tree: Tree, options: NormalizedOptions): void {
  const project: ProjectConfiguration = {
    root: options.appProjectRoot,
    sourceRoot: joinPathFragments(options.appProjectRoot, 'src'),
    projectType: 'application',
    targets: {},
    tags: options.parsedTags,
  };

  if (!options.addPlugin) {
    project.targets = {
      build: createBuildTarget(options),
      serve: createServeTarget(options),
    };

    if (options.unitTestRunner === 'vitest') {
      project.targets.test = createTestTarget(options);
    }
  }

  project.targets = project.targets || {};
  project.targets.lint = {
    executor: '@berenddeboer/nx-biome:biome-lint',
    options: {
      lintFilePatterns: [`${options.appProjectRoot}/**/*.{ts,tsx}`],
    },
  };

  if (options.useProjectJson) {
    addProjectConfiguration(tree, options.projectName, project);
  } else {
    const packageJson = {
      name: options.importPath,
      version: '0.0.1',
      private: true,
      nx: {
        name:
          options.projectName !== options.importPath
            ? options.projectName
            : undefined,
        sourceRoot: project.sourceRoot,
        targets: project.targets,
        tags: project.tags,
      } as Record<string, unknown>,
    };

    Object.keys(packageJson.nx).forEach(
      (key) => packageJson.nx[key] === undefined && delete packageJson.nx[key],
    );

    writeJson(
      tree,
      joinPathFragments(options.appProjectRoot, 'package.json'),
      packageJson,
    );
  }
}

function createBuildTarget(options: NormalizedOptions) {
  return {
    executor: '@nx/vite:build',
    outputs: ['{options.outputPath}'],
    defaultConfiguration: 'production',
    options: {
      outputPath:
        options.appProjectRoot === '.'
          ? 'dist'
          : joinPathFragments('dist', options.appProjectRoot),
      configFile: joinPathFragments(options.appProjectRoot, 'vite.config.ts'),
    },
    configurations: {
      development: {
        mode: 'development',
      },
      production: {
        mode: 'production',
      },
    },
  };
}

function createServeTarget(options: NormalizedOptions) {
  return {
    executor: '@nx/vite:dev-server',
    defaultConfiguration: 'development',
    options: {
      buildTarget: `${options.projectName}:build`,
      configFile: joinPathFragments(options.appProjectRoot, 'vite.config.ts'),
    },
    configurations: {
      development: {
        buildTarget: `${options.projectName}:build:development`,
        hmr: true,
      },
      production: {
        buildTarget: `${options.projectName}:build:production`,
        hmr: false,
      },
    },
  };
}

function createTestTarget(options: NormalizedOptions) {
  return {
    executor: '@nx/vitest:test',
    outputs: [`{workspaceRoot}/coverage/${options.appProjectRoot}`],
    options: {
      config: joinPathFragments(options.appProjectRoot, 'vite.config.ts'),
    },
  };
}
