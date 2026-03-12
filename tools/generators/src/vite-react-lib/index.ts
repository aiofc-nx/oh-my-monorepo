import {
  Tree,
  formatFiles,
  runTasksInSerial,
  type GeneratorCallback,
  addDependenciesToPackageJson,
} from '@nx/devkit';
import {
  determineProjectNameAndRootOptions,
  ensureRootProjectName,
} from '@nx/devkit/src/generators/project-name-and-root-utils';
import { libraryGenerator } from '@nx/react';
import type { ViteReactLibGeneratorSchema } from './schema';

export default async function (
  tree: Tree,
  rawOptions: ViteReactLibGeneratorSchema,
): Promise<GeneratorCallback> {
  return await viteReactLibGeneratorInternal(tree, rawOptions);
}

export async function viteReactLibGeneratorInternal(
  tree: Tree,
  rawOptions: ViteReactLibGeneratorSchema,
): Promise<GeneratorCallback> {
  const options = await normalizeOptions(tree, rawOptions);
  const tasks: GeneratorCallback[] = [];

  // 使用官方 React 库生成器，强制使用 Vite
  const libTask = await libraryGenerator(tree, {
    name: options.projectName,
    directory: options.projectRoot,
    bundler: options.buildable || options.publishable ? 'vite' : 'none',
    style: options.style,
    unitTestRunner: 'vitest',
    linter: 'none',
    tags: options.tags,
    skipFormat: true,
    buildable: options.buildable,
    publishable: options.publishable,
    importPath: options.importPath,
    skipPackageJson: options.skipPackageJson,
  });
  tasks.push(libTask);

  // 添加自定义依赖
  if (!options.skipPackageJson) {
    const depsTask = addDependenciesToPackageJson(
      tree,
      {},
      {
        // Tailwind 相关
        ...(options.style === 'tailwind' && {
          tailwindcss: '^4.0.0',
          '@tailwindcss/vite': '^4.0.0',
        }),
      },
    );
    if (depsTask) tasks.push(depsTask);
  }

  if (!options.skipFormat) {
    await formatFiles(tree);
  }

  return runTasksInSerial(...tasks);
}

async function normalizeOptions(
  tree: Tree,
  options: ViteReactLibGeneratorSchema,
) {
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
    tags: options.tags ?? 'type:lib,framework:react,bundler:vite',
    style: options.style ?? 'css',
    buildable: options.buildable ?? false,
    publishable: options.publishable ?? false,
    skipPackageJson: options.skipPackageJson ?? false,
  };
}
