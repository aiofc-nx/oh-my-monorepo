import { names } from '@nx/devkit';
import type { Tree } from '@nx/devkit';

export interface NormalizedOptions {
  name: string;
  fileName: string;
  project: string;
  projectRoot: string;
  projectSourceRoot: string;
  path: string;
  directory: string;
  skipFormat: boolean;
  componentFileName: string;
  componentName: string;
}

export function normalizeOptions(
  tree: Tree,
  options: import('../schema').StorySchema,
): NormalizedOptions {
  const { name: componentName, fileName: componentFileName } = names(
    options.name,
  );

  let path = options.path;
  let directory = options.directory ?? '';

  const projectRoot = tree.exists(`apps/${options.project}`)
    ? `apps/${options.project}`
    : `libs/${options.project}`;

  const projectSourceRoot = tree.exists(`${projectRoot}/src`)
    ? `${projectRoot}/src`
    : projectRoot;

  if (!path) {
    if (directory) {
      path = `${projectSourceRoot}/${directory}`;
    } else {
      path = projectSourceRoot;
    }
  }

  return {
    name: options.name,
    fileName: componentFileName,
    project: options.project,
    projectRoot,
    projectSourceRoot,
    path,
    directory,
    skipFormat: options.skipFormat ?? false,
    componentFileName,
    componentName,
  };
}
