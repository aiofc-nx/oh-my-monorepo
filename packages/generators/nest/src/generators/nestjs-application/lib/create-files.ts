import { generateFiles, Tree } from '@nx/devkit';
import { join } from 'path';
import type { NormalizedOptions } from '../schema';

export function createFiles(tree: Tree, options: NormalizedOptions): void {
  generateFiles(tree, join(__dirname, '..', 'files'), options.projectRoot, {
    ...options,
    tmpl: '',
  });
}
