import type { Tree } from '@nx/devkit';
import type { NormalizedOptions } from '../schema';

export function addLinting(_tree: Tree, _options: NormalizedOptions): void {
  // Lint target is already configured in addProject.ts
  // This function is kept for future extensibility
  // All projects use Biome for linting
}
