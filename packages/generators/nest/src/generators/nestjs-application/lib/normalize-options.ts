import { readNxJson, Tree } from '@nx/devkit';
import { determineProjectNameAndRootOptions } from '@nx/devkit/src/generators/project-name-and-root-utils';
import { isUsingTsSolutionSetup } from '@nx/js/src/utils/typescript/ts-solution-setup';
import type {
  NestjsApplicationGeneratorSchema,
  NormalizedOptions,
} from '../schema';

export async function normalizeOptions(
  tree: Tree,
  options: NestjsApplicationGeneratorSchema & {
    addPlugin?: boolean;
    useProjectJson?: boolean;
  },
): Promise<NormalizedOptions> {
  const { projectName, projectRoot } = await determineProjectNameAndRootOptions(
    tree,
    {
      name: options.name,
      projectType: 'application',
      directory: options.directory,
    },
  );

  const nxJson = readNxJson(tree);
  const addPlugin =
    options.addPlugin ??
    (process.env.NX_ADD_PLUGINS !== 'false' &&
      (nxJson?.useInferencePlugins ?? true));

  return {
    ...options,
    addPlugin,
    useProjectJson: options.useProjectJson ?? !isUsingTsSolutionSetup(tree),
    projectName,
    projectRoot,
    skipFormat: options.skipFormat ?? false,
    skipPackageJson: options.skipPackageJson ?? false,
    strict: options.strict ?? false,
    tags: options.tags ?? 'type:app,framework:nest,test:vitest,linter:biome',
  };
}
