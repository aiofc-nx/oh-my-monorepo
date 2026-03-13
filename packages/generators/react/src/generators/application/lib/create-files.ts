import { generateFiles, joinPathFragments, Tree, updateJson } from '@nx/devkit';
import { join } from 'path';
import type { NormalizedOptions } from '../schema';

export function createFiles(tree: Tree, options: NormalizedOptions): void {
  const substitutions = {
    ...options,
    tmpl: '',
    style: options.style,
    hasStyles: options.hasStyles,
    routing: options.routing,
    strict: options.strict,
    offsetFromRoot: options.appProjectRoot === '.' ? '.' : '..',
  };

  generateFiles(
    tree,
    join(__dirname, '..', 'files', 'common'),
    options.appProjectRoot,
    substitutions,
  );

  generateFiles(
    tree,
    join(__dirname, '..', 'files', 'styles', options.style ?? 'css'),
    options.appProjectRoot,
    substitutions,
  );

  if (options.routing) {
    generateFiles(
      tree,
      join(__dirname, '..', 'files', 'routing'),
      options.appProjectRoot,
      substitutions,
    );
  }

  updateTsConfig(tree, options);
}

function updateTsConfig(tree: Tree, options: NormalizedOptions): void {
  const tsConfigPath = joinPathFragments(
    options.appProjectRoot,
    'tsconfig.app.json',
  );

  if (!tree.exists(tsConfigPath)) {
    return;
  }

  updateJson(tree, tsConfigPath, (json) => {
    json.compilerOptions = {
      ...json.compilerOptions,
      jsx: 'react-jsx',
      module: 'ESNext',
      moduleResolution: 'bundler',
      target: 'ES2020',
      lib: ['ES2020', 'DOM', 'DOM.Iterable'],
      strict: options.strict,
      noEmit: true,
      esModuleInterop: true,
      skipLibCheck: true,
      forceConsistentCasingInFileNames: true,
      resolveJsonModule: true,
      isolatedModules: true,
      allowImportingTsExtensions: true,
    };
    return json;
  });
}
