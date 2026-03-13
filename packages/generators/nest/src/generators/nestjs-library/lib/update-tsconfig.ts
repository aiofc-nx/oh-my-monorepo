import {
  joinPathFragments,
  readProjectConfiguration,
  Tree,
  updateJson,
} from '@nx/devkit';
import type { NormalizedOptions } from '../schema';

export function updateTsConfig(tree: Tree, options: NormalizedOptions): void {
  const project = readProjectConfiguration(tree, options.projectName);
  const tsConfigLibPath = joinPathFragments(project.root, 'tsconfig.lib.json');

  if (!tree.exists(tsConfigLibPath)) {
    return;
  }

  updateJson(tree, tsConfigLibPath, (json) => {
    json.compilerOptions = {
      ...json.compilerOptions,
      target: 'es2021',
      experimentalDecorators: true,
      emitDecoratorMetadata: true,
    };

    if (options.strict) {
      json.compilerOptions = {
        ...json.compilerOptions,
        strictNullChecks: true,
        noImplicitAny: true,
        strictBindCallApply: true,
        forceConsistentCasingInFileNames: true,
        noFallthroughCasesInSwitch: true,
      };
    }

    return json;
  });

  const tsConfigSpecPath = joinPathFragments(
    project.root,
    'tsconfig.spec.json',
  );
  if (tree.exists(tsConfigSpecPath)) {
    updateJson(tree, tsConfigSpecPath, (json) => {
      json.compilerOptions = {
        ...json.compilerOptions,
        experimentalDecorators: true,
        emitDecoratorMetadata: true,
      };
      return json;
    });
  }
}
