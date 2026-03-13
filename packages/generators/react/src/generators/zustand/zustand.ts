import type { GeneratorCallback, Tree } from '@nx/devkit';
import {
  addDependenciesToPackageJson,
  formatFiles,
  generateFiles,
  getProjects,
  joinPathFragments,
  names,
} from '@nx/devkit';
import { zustandVersion } from '../../utils/versions';

export interface ZustandSchema {
  project: string;
  name?: string;
  directory?: string;
  skipFormat?: boolean;
  skipPackageJson?: boolean;
}

export async function zustandGenerator(
  tree: Tree,
  options: ZustandSchema,
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

  const storeName = options.name ?? 'store';
  const directory = options.directory ?? 'store';

  generateFiles(
    tree,
    joinPathFragments(__dirname, 'files'),
    joinPathFragments(projectSourceRoot, directory),
    {
      ...names(storeName),
      storeName,
      tmpl: '',
    },
  );

  if (!options.skipPackageJson) {
    const depsTask = addDependenciesToPackageJson(
      tree,
      {
        zustand: zustandVersion,
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

export default zustandGenerator;
