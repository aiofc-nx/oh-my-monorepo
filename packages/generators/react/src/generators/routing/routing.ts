import type { GeneratorCallback, Tree } from '@nx/devkit';
import {
  addDependenciesToPackageJson,
  formatFiles,
  generateFiles,
  joinPathFragments,
  getProjects,
  updateJson,
} from '@nx/devkit';
import { join } from 'path';
import type { RoutingGeneratorSchema, NormalizedOptions } from './schema';

const ROUTER_VERSIONS: Record<string, string> = {
  'react-router-dom': '^7.0.0',
  '@tanstack/react-router': '^1.0.0',
};

export async function routingGenerator(
  tree: Tree,
  rawOptions: RoutingGeneratorSchema,
): Promise<GeneratorCallback> {
  const options = normalizeOptions(tree, rawOptions);
  const tasks: GeneratorCallback[] = [];

  createRoutingFiles(tree, options);
  updateAppFile(tree, options);
  updateTsConfig(tree, options);

  if (!options.skipPackageJson) {
    const depsTask = addDependencies(tree, options);
    tasks.push(depsTask);
  }

  if (!options.skipFormat) {
    await formatFiles(tree);
  }

  return () => {
    tasks.forEach((task) => task());
  };
}

export default routingGenerator;

function normalizeOptions(
  tree: Tree,
  options: RoutingGeneratorSchema,
): NormalizedOptions {
  const projects = getProjects(tree);
  const project = projects.get(options.project);

  if (!project) {
    throw new Error(`Project "${options.project}" not found.`);
  }

  const projectSourceRoot =
    project.sourceRoot ?? joinPathFragments(project.root, 'src');

  return {
    ...options,
    projectRoot: project.root,
    projectSourceRoot,
    routesDirectory: options.directory ?? 'src/routes',
    type: options.type ?? 'react-router',
  };
}

function createRoutingFiles(tree: Tree, options: NormalizedOptions): void {
  const substitutions = {
    tmpl: '',
    routerType: options.type,
  };

  generateFiles(
    tree,
    join(__dirname, 'files', options.type ?? 'react-router'),
    options.projectSourceRoot,
    substitutions,
  );
}

function updateAppFile(tree: Tree, options: NormalizedOptions): void {
  const mainPath = joinPathFragments(options.projectSourceRoot, 'main.tsx');

  if (!tree.exists(mainPath)) {
    return;
  }

  let content = tree.read(mainPath, 'utf-8') ?? '';

  if (options.type === 'react-router') {
    if (!content.includes('BrowserRouter')) {
      content = content.replace(
        /(<StrictMode>)/,
        `<BrowserRouter>
      $1`,
      );
      content = content.replace(
        /(<\/StrictMode>)/,
        `$1
    </BrowserRouter>`,
      );
      content = `import { BrowserRouter } from 'react-router-dom';\n` + content;
    }
  }

  tree.write(mainPath, content);
}

function updateTsConfig(tree: Tree, options: NormalizedOptions): void {
  const tsConfigPath = joinPathFragments(options.projectRoot, 'tsconfig.json');

  if (!tree.exists(tsConfigPath)) {
    return;
  }

  updateJson(tree, tsConfigPath, (json) => {
    json.compilerOptions ??= {};
    if (options.type === 'react-router') {
      json.compilerOptions.jsx = 'react-jsx';
    }
    return json;
  });
}

function addDependencies(
  tree: Tree,
  options: NormalizedOptions,
): GeneratorCallback {
  const routerPackage =
    options.type === 'react-router'
      ? 'react-router-dom'
      : '@tanstack/react-router';
  const version = ROUTER_VERSIONS[routerPackage];

  if (!version) {
    return () => {};
  }

  return addDependenciesToPackageJson(tree, { [routerPackage]: version }, {});
}
