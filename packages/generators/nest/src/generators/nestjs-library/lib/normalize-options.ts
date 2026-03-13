import { names, readNxJson, Tree } from '@nx/devkit';
import { determineProjectNameAndRootOptions } from '@nx/devkit/src/generators/project-name-and-root-utils';
import { isUsingTsSolutionSetup } from '@nx/js/src/utils/typescript/ts-solution-setup';
import type {
  NestjsLibraryGeneratorSchema,
  NormalizedOptions,
} from '../schema';

export async function normalizeOptions(
  tree: Tree,
  options: NestjsLibraryGeneratorSchema & {
    addPlugin?: boolean;
    useProjectJson?: boolean;
  },
): Promise<NormalizedOptions> {
  const { projectName, projectRoot, importPath } =
    await determineProjectNameAndRootOptions(tree, {
      name: options.name,
      projectType: 'library',
      directory: options.directory,
      importPath: options.importPath,
    });

  const nxJson = readNxJson(tree);
  const addPlugin =
    options.addPlugin ??
    (process.env.NX_ADD_PLUGINS !== 'false' &&
      (nxJson?.useInferencePlugins ?? true));

  const { className, fileName, propertyName } = names(
    options.name ?? projectName,
  );

  const parsedTags = options.tags
    ? options.tags.split(',').map((s) => s.trim())
    : [];

  return {
    ...options,
    addPlugin,
    useProjectJson: options.useProjectJson ?? !isUsingTsSolutionSetup(tree),
    className,
    fileName,
    propertyName,
    projectName,
    projectRoot,
    importPath,
    parsedTags,
    buildable: options.buildable ?? false,
    controller: options.controller ?? false,
    global: options.global ?? false,
    publishable: options.publishable ?? false,
    service: options.service ?? false,
    skipFormat: options.skipFormat ?? false,
    skipPackageJson: options.skipPackageJson ?? false,
    skipTsConfig: options.skipTsConfig ?? false,
    strict: options.strict ?? true,
    unitTestRunner: options.unitTestRunner ?? 'vitest',
  };
}
