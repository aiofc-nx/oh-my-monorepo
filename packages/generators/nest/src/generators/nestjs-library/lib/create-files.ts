import { generateFiles, Tree } from '@nx/devkit';
import { join } from 'path';
import type { NormalizedOptions } from '../schema';

export function createFiles(tree: Tree, options: NormalizedOptions): void {
  const substitutions = {
    ...options,
    tmpl: '',
  };

  generateFiles(
    tree,
    join(__dirname, '..', 'files', 'common'),
    options.projectRoot,
    substitutions,
  );

  if (options.controller) {
    generateFiles(
      tree,
      join(__dirname, '..', 'files', 'controller'),
      options.projectRoot,
      substitutions,
    );

    if (options.unitTestRunner === 'none') {
      tree.delete(
        `${options.projectRoot}/src/lib/${options.fileName}.controller.spec.ts`,
      );
    }
  }

  if (options.service) {
    generateFiles(
      tree,
      join(__dirname, '..', 'files', 'service'),
      options.projectRoot,
      substitutions,
    );

    if (options.unitTestRunner === 'none') {
      tree.delete(
        `${options.projectRoot}/src/lib/${options.fileName}.service.spec.ts`,
      );
    }
  }
}
