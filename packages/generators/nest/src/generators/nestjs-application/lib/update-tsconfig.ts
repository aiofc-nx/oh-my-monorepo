import { joinPathFragments, Tree, updateJson } from '@nx/devkit';
import type { NormalizedOptions } from '../schema';

export function updateTsConfig(tree: Tree, options: NormalizedOptions): void {
  const tsConfigPath = joinPathFragments(
    options.projectRoot,
    'tsconfig.app.json',
  );

  if (!tree.exists(tsConfigPath)) {
    return;
  }

  updateJson(tree, tsConfigPath, (json) => {
    json.compilerOptions = {
      ...json.compilerOptions,
      experimentalDecorators: true,
      emitDecoratorMetadata: true,
      target: 'es2021',
      moduleResolution: 'node',
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
    options.projectRoot,
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
