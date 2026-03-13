import type { GeneratorCallback, Tree } from '@nx/devkit';
import {
  addDependenciesToPackageJson,
  formatFiles,
  runTasksInSerial,
} from '@nx/devkit';
import { libraryGenerator as jsLibraryGenerator } from '@nx/js';
import { initGenerator } from '../init/init';
import {
  normalizeOptions,
  createFiles,
  deleteFiles,
  updateTsConfig,
  updateProject,
  addExportsToBarrelFile,
} from './lib';
import type { NestjsLibraryGeneratorSchema } from './schema';
import {
  nestJsVersion,
  nestJsSchematicsVersion,
  reflectMetadataVersion,
  rxjsVersion,
  vitestVersion,
  vitestCoverageV8Version,
  unpluginSwcVersion,
} from '../../utils/versions';

export async function nestjsLibraryGenerator(
  tree: Tree,
  rawOptions: NestjsLibraryGeneratorSchema,
): Promise<GeneratorCallback> {
  return nestjsLibraryGeneratorInternal(tree, rawOptions);
}

export async function nestjsLibraryGeneratorInternal(
  tree: Tree,
  rawOptions: NestjsLibraryGeneratorSchema & {
    addPlugin?: boolean;
    useProjectJson?: boolean;
  },
): Promise<GeneratorCallback> {
  const options = await normalizeOptions(tree, rawOptions);
  const tasks: GeneratorCallback[] = [];

  const initTask = await initGenerator(tree, {
    skipPackageJson: options.skipPackageJson,
    skipFormat: true,
  });
  tasks.push(initTask);

  const jsLibraryTask = await jsLibraryGenerator(tree, {
    name: options.name,
    bundler: options.buildable || options.publishable ? 'tsc' : 'none',
    directory: options.directory,
    importPath: options.importPath,
    linter: 'none',
    publishable: options.publishable,
    buildable: options.buildable,
    skipFormat: true,
    skipTsConfig: options.skipTsConfig,
    skipPackageJson: options.skipPackageJson,
    strict: options.strict,
    tags: options.tags,
    unitTestRunner: 'none',
    addPlugin: options.addPlugin,
    useProjectJson: options.useProjectJson,
  });
  tasks.push(jsLibraryTask);

  deleteFiles(tree, options);
  createFiles(tree, options);
  addExportsToBarrelFile(tree, options);
  updateTsConfig(tree, options);
  updateProject(tree, options);

  if (!options.skipPackageJson) {
    const depsTask = addDependenciesToPackageJson(
      tree,
      {
        '@nestjs/common': nestJsVersion,
        '@nestjs/core': nestJsVersion,
        '@nestjs/platform-express': nestJsVersion,
        'reflect-metadata': reflectMetadataVersion,
        rxjs: rxjsVersion,
      },
      {
        '@nestjs/schematics': nestJsSchematicsVersion,
        '@nestjs/testing': nestJsVersion,
        vitest: vitestVersion,
        '@vitest/coverage-v8': vitestCoverageV8Version,
        'unplugin-swc': unpluginSwcVersion,
      },
    );
    tasks.push(depsTask);
  }

  if (!options.skipFormat) {
    await formatFiles(tree);
  }

  return runTasksInSerial(...tasks);
}

export default nestjsLibraryGenerator;
