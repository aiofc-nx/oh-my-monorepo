import {
  Tree,
  formatFiles,
  generateFiles,
  joinPathFragments,
  readJson,
  writeJson,
  runTasksInSerial,
  names,
  type GeneratorCallback,
} from '@nx/devkit';
import {
  determineProjectNameAndRootOptions,
  ensureRootProjectName,
} from '@nx/devkit/src/generators/project-name-and-root-utils';
import { applicationGenerator } from '@nx/node';
import { addDependenciesToPackageJson } from '@nx/devkit';
import type { NestjsAppGeneratorSchema } from './schema';
import { join } from 'path';

export default async function (
  tree: Tree,
  rawOptions: NestjsAppGeneratorSchema,
): Promise<GeneratorCallback> {
  return await nestjsAppGeneratorInternal(tree, rawOptions);
}

export async function nestjsAppGeneratorInternal(
  tree: Tree,
  rawOptions: NestjsAppGeneratorSchema,
): Promise<GeneratorCallback> {
  const options = await normalizeOptions(tree, rawOptions);
  const tasks: GeneratorCallback[] = [];

  tree.write(joinPathFragments(options.appProjectRoot, 'README.md'), '');

  const appTask = await applicationGenerator(tree, {
    name: options.projectName,
    directory: options.appProjectRoot,
    framework: 'nest',
    bundler: 'webpack',
    unitTestRunner: 'none',
    linter: 'none',
    tags: options.tags,
    skipFormat: true,
  });
  tasks.push(appTask);

  updateTsConfig(tree, options);
  updateProjectJson(tree, options);
  createFiles(tree, options);

  if (!options.skipPackageJson) {
    const depsTask = addDependenciesToPackageJson(
      tree,
      {},
      {
        vitest: '^2.0.0',
        '@vitest/coverage-v8': '^2.0.0',
      },
    );
    if (depsTask) tasks.push(depsTask);
  }

  if (!options.skipFormat) {
    await formatFiles(tree);
  }

  return runTasksInSerial(...tasks);
}

async function normalizeOptions(tree: Tree, options: NestjsAppGeneratorSchema) {
  const directory = options.directory ?? `apps/${options.name}`;
  await ensureRootProjectName({ directory, name: options.name }, 'application');
  const { projectName, projectRoot } = await determineProjectNameAndRootOptions(
    tree,
    {
      name: options.name,
      projectType: 'application',
      directory,
    },
  );

  return {
    ...options,
    projectName,
    appProjectRoot: projectRoot,
    tags: options.tags ?? 'type:app,framework:nest',
    skipPackageJson: options.skipPackageJson ?? false,
  };
}

function updateTsConfig(
  tree: Tree,
  options: Awaited<ReturnType<typeof normalizeOptions>>,
) {
  const tsConfigPath = joinPathFragments(
    options.appProjectRoot,
    'tsconfig.json',
  );

  if (!tree.exists(tsConfigPath)) return;

  const tsConfig = readJson(tree, tsConfigPath);
  tsConfig.extends = '@oksai/tsconfig/nestjs-esm.json';
  tsConfig.files = tsConfig.files || [];
  tsConfig.references = tsConfig.references || [
    { path: './tsconfig.app.json' },
    { path: './tsconfig.spec.json' },
  ];

  writeJson(tree, tsConfigPath, tsConfig);
}

function updateProjectJson(
  _tree: Tree,
  _options: Awaited<ReturnType<typeof normalizeOptions>>,
) {
  // SWC configuration is handled by webpack.config.js
  // No need to modify project.json
}

function createFiles(
  tree: Tree,
  options: Awaited<ReturnType<typeof normalizeOptions>>,
) {
  const substitutions = {
    ...names(options.projectName),
    ...options,
    tmpl: '',
  };

  generateFiles(
    tree,
    join(__dirname, 'files'),
    options.appProjectRoot,
    substitutions,
  );
}
