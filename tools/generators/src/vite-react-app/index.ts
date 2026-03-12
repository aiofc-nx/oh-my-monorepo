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
import { applicationGenerator } from '@nx/react';
import type { ViteReactAppGeneratorSchema } from './schema';

export default async function (
  tree: Tree,
  rawOptions: ViteReactAppGeneratorSchema,
): Promise<GeneratorCallback> {
  return await viteReactAppGeneratorInternal(tree, rawOptions);
}

export async function viteReactAppGeneratorInternal(
  tree: Tree,
  rawOptions: ViteReactAppGeneratorSchema,
): Promise<GeneratorCallback> {
  const options = await normalizeOptions(tree, rawOptions);
  const tasks: GeneratorCallback[] = [];

  // 使用官方 React 生成器，强制使用 Vite
  const appTask = await applicationGenerator(tree, {
    name: options.projectName,
    directory: options.appProjectRoot,
    bundler: 'vite', // 强制使用 Vite
    style: options.style,
    routing: options.routing,
    unitTestRunner: 'vitest', // 强制使用 Vitest
    e2eTestRunner: 'none', // 禁用 e2e 测试
    linter: 'none', // 禁用 linter（使用 Biome）
    tags: options.tags,
    skipFormat: true,
    inSourceTests: options.inSourceTests,
    skipPackageJson: options.skipPackageJson,
  });
  tasks.push(appTask);

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
  options: ViteReactAppGeneratorSchema,
) {
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
    tags: options.tags ?? 'type:app,framework:react,bundler:vite',
    style: options.style ?? 'css',
    routing: options.routing ?? false,
    inSourceTests: options.inSourceTests ?? false,
    skipPackageJson: options.skipPackageJson ?? false,
  };
}
