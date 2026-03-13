import { Tree } from '@nx/devkit';
import type { NormalizedOptions } from '../schema';

export function deleteFiles(tree: Tree, options: NormalizedOptions): void {
  tree.delete(`${options.projectRoot}/src/lib/${options.fileName}.ts`);

  if (options.unitTestRunner !== 'none') {
    tree.delete(`${options.projectRoot}/src/lib/${options.fileName}.spec.ts`);
  }

  if (!options.buildable && !options.publishable) {
    const packageJsonPath = `${options.projectRoot}/package.json`;
    if (tree.exists(packageJsonPath)) {
      tree.delete(packageJsonPath);
    }
  }
}
