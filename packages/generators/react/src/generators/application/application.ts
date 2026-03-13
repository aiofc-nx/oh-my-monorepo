import type { GeneratorCallback, Tree } from '@nx/devkit';
import {
  addDependenciesToPackageJson,
  formatFiles,
  runTasksInSerial,
} from '@nx/devkit';
import {
  normalizeOptions,
  createFiles,
  addProject,
  addE2e,
  addLinting,
} from './lib';
import type { ApplicationGeneratorSchema } from './schema';
import {
  reactVersion,
  reactDomVersion,
  testingLibraryReactVersion,
} from '../../utils/versions';

export async function applicationGenerator(
  tree: Tree,
  rawOptions: ApplicationGeneratorSchema,
): Promise<GeneratorCallback> {
  return applicationGeneratorInternal(tree, rawOptions);
}

export async function applicationGeneratorInternal(
  tree: Tree,
  rawOptions: ApplicationGeneratorSchema & {
    addPlugin?: boolean;
    useProjectJson?: boolean;
  },
): Promise<GeneratorCallback> {
  const options = await normalizeOptions(tree, rawOptions);
  const tasks: GeneratorCallback[] = [];

  addProject(tree, options);
  createFiles(tree, options);
  addLinting(tree, options);

  if (options.e2eTestRunner === 'playwright') {
    addE2e(tree, options);
  }

  if (!options.skipPackageJson) {
    const depsTask = addDependenciesToPackageJson(
      tree,
      {
        react: reactVersion,
        'react-dom': reactDomVersion,
      },
      {
        '@testing-library/react': testingLibraryReactVersion,
      },
    );
    tasks.push(depsTask);
  }

  if (!options.skipFormat) {
    await formatFiles(tree);
  }

  return runTasksInSerial(...tasks);
}

export default applicationGenerator;
