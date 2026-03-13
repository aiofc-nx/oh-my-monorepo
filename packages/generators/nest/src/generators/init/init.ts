import type { GeneratorCallback, Tree } from '@nx/devkit';
import { formatFiles, addDependenciesToPackageJson } from '@nx/devkit';
import type { InitGeneratorOptions } from './schema';
import { nestJsSchematicsVersion } from '../../utils/versions';

export async function initGenerator(
  tree: Tree,
  options: InitGeneratorOptions,
): Promise<GeneratorCallback> {
  let installPackagesTask: GeneratorCallback = () => {};

  if (!options.skipPackageJson) {
    installPackagesTask = addDependenciesToPackageJson(
      tree,
      {},
      {
        '@nestjs/schematics': nestJsSchematicsVersion,
      },
    );
  }

  if (!options.skipFormat) {
    await formatFiles(tree);
  }

  return installPackagesTask;
}

export default initGenerator;
