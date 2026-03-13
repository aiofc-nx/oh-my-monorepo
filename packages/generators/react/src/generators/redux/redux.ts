import type { GeneratorCallback, Tree } from '@nx/devkit';
import {
  addDependenciesToPackageJson,
  formatFiles,
  generateFiles,
  getProjects,
  joinPathFragments,
  names,
} from '@nx/devkit';
import { reduxToolkitVersion, reactReduxVersion } from '../../utils/versions';

export interface ReduxSchema {
  project: string;
  directory?: string;
  skipFormat?: boolean;
  skipPackageJson?: boolean;
}

export async function reduxGenerator(
  tree: Tree,
  options: ReduxSchema,
): Promise<GeneratorCallback> {
  const projects = getProjects(tree);
  const project = projects.get(options.project);

  if (!project) {
    throw new Error(`Project "${options.project}" not found.`);
  }

  const tasks: GeneratorCallback[] = [];
  const projectRoot = project.root;
  const projectSourceRoot = tree.exists(`${projectRoot}/src`)
    ? `${projectRoot}/src`
    : projectRoot;

  const directory = options.directory ?? 'store';

  generateFiles(
    tree,
    joinPathFragments(__dirname, 'files'),
    joinPathFragments(projectSourceRoot, directory),
    {
      ...names(options.project),
      tmpl: '',
    },
  );

  if (!options.skipPackageJson) {
    const depsTask = addDependenciesToPackageJson(
      tree,
      {
        '@reduxjs/toolkit': reduxToolkitVersion,
        'react-redux': reactReduxVersion,
      },
      {},
    );
    tasks.push(depsTask);
  }

  if (!options.skipFormat) {
    await formatFiles(tree);
  }

  return () => {
    tasks.forEach((task) => task());
  };
}

export default reduxGenerator;
