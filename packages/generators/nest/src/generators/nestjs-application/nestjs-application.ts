import type { GeneratorCallback, Tree } from '@nx/devkit';
import {
  addDependenciesToPackageJson,
  formatFiles,
  runTasksInSerial,
} from '@nx/devkit';
import { applicationGenerator as nodeApplicationGenerator } from '@nx/node';
import { initGenerator } from '../init/init';
import {
  normalizeOptions,
  createFiles,
  updateTsConfig,
  updateProject,
} from './lib';
import type { NestjsApplicationGeneratorSchema } from './schema';
import {
  nestJsVersion,
  nestJsSchematicsVersion,
  reflectMetadataVersion,
  rxjsVersion,
  tsLibVersion,
  vitestVersion,
  vitestCoverageV8Version,
  tsLoaderVersion,
  unpluginSwcVersion,
} from '../../utils/versions';

export async function nestjsApplicationGenerator(
  tree: Tree,
  rawOptions: NestjsApplicationGeneratorSchema,
): Promise<GeneratorCallback> {
  return nestjsApplicationGeneratorInternal(tree, rawOptions);
}

export async function nestjsApplicationGeneratorInternal(
  tree: Tree,
  rawOptions: NestjsApplicationGeneratorSchema & {
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

  const nodeTask = await nodeApplicationGenerator(tree, {
    name: options.projectName,
    directory: options.projectRoot,
    bundler: 'webpack',
    isNest: true,
    unitTestRunner: 'none',
    linter: 'none',
    e2eTestRunner: 'none',
    tags: options.tags,
    skipFormat: true,
    skipPackageJson: options.skipPackageJson,
    addPlugin: options.addPlugin,
    useProjectJson: options.useProjectJson,
  });
  tasks.push(nodeTask);

  createFiles(tree, options);
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
        tslib: tsLibVersion,
      },
      {
        '@nestjs/schematics': nestJsSchematicsVersion,
        '@nestjs/testing': nestJsVersion,
        vitest: vitestVersion,
        '@vitest/coverage-v8': vitestCoverageV8Version,
        'ts-loader': tsLoaderVersion,
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

export default nestjsApplicationGenerator;
