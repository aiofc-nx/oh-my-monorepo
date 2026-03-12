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
import { libraryGenerator } from '@nx/js';
import { addDependenciesToPackageJson } from '@nx/devkit';
import type { NestjsLibGeneratorSchema } from './schema';
import { join } from 'path';

export default async function (
  tree: Tree,
  rawOptions: NestjsLibGeneratorSchema,
): Promise<GeneratorCallback> {
  return await nestjsLibGeneratorInternal(tree, rawOptions);
}

export async function nestjsLibGeneratorInternal(
  tree: Tree,
  rawOptions: NestjsLibGeneratorSchema,
): Promise<GeneratorCallback> {
  const options = await normalizeOptions(tree, rawOptions);
  const tasks: GeneratorCallback[] = [];

  const libTask = await libraryGenerator(tree, {
    name: options.projectName,
    directory: options.projectRoot,
    bundler: options.buildable || options.publishable ? 'tsc' : 'none',
    unitTestRunner: 'none',
    linter: 'none',
    tags: options.tags,
    skipFormat: true,
    buildable: options.buildable,
    publishable: options.publishable,
    importPath: options.importPath,
  });
  tasks.push(libTask);

  updateTsConfig(tree, options);
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

async function normalizeOptions(tree: Tree, options: NestjsLibGeneratorSchema) {
  const directory = options.directory ?? `libs/${options.name}`;
  await ensureRootProjectName({ directory, name: options.name }, 'library');
  const { projectName, projectRoot, importPath } =
    await determineProjectNameAndRootOptions(tree, {
      name: options.name,
      projectType: 'library',
      directory,
      importPath: options.importPath,
    });

  return {
    ...options,
    projectName,
    projectRoot,
    importPath,
    tags: options.tags ?? 'type:lib,framework:nest',
    skipPackageJson: options.skipPackageJson ?? false,
    buildable: options.buildable ?? false,
    publishable: options.publishable ?? false,
  };
}

function updateTsConfig(
  tree: Tree,
  options: Awaited<ReturnType<typeof normalizeOptions>>,
) {
  const tsConfigPath = joinPathFragments(options.projectRoot, 'tsconfig.json');

  if (!tree.exists(tsConfigPath)) return;

  const tsConfig = readJson(tree, tsConfigPath);
  tsConfig.extends = '@oksai/tsconfig/nestjs-esm.json';

  writeJson(tree, tsConfigPath, tsConfig);
}

function createFiles(
  tree: Tree,
  options: Awaited<ReturnType<typeof normalizeOptions>>,
) {
  const substitutions = {
    ...names(options.projectName),
    ...options,
    tmpl: '',
    fileName: names(options.projectName).fileName,
  };

  generateFiles(
    tree,
    join(__dirname, 'files'),
    options.projectRoot,
    substitutions,
  );
}
