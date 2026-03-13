import { names, readNxJson, Tree } from '@nx/devkit';
import { determineProjectNameAndRootOptions } from '@nx/devkit/src/generators/project-name-and-root-utils';
import { isUsingTsSolutionSetup } from '@nx/js/src/utils/typescript/ts-solution-setup';
import type {
  ApplicationGeneratorSchema,
  NormalizedOptions,
  Style,
} from '../schema';

export async function normalizeOptions(
  tree: Tree,
  options: ApplicationGeneratorSchema & {
    addPlugin?: boolean;
    useProjectJson?: boolean;
  },
): Promise<NormalizedOptions> {
  await ensureRootProjectName(options, 'application');

  const {
    projectName,
    projectRoot: appProjectRoot,
    importPath,
  } = await determineProjectNameAndRootOptions(tree, {
    name: options.name,
    projectType: 'application',
    directory: options.directory,
    rootProject: options.rootProject,
  });

  const nxJson = readNxJson(tree);
  const addPlugin =
    options.addPlugin ??
    (process.env.NX_ADD_PLUGINS !== 'false' &&
      (nxJson?.useInferencePlugins ?? true));

  options.rootProject = appProjectRoot === '.';

  const isUsingTsSolutionConfig = isUsingTsSolutionSetup(tree);
  const appProjectName =
    !isUsingTsSolutionConfig || options.name ? projectName : importPath;

  const e2eProjectName = options.rootProject ? 'e2e' : `${appProjectName}-e2e`;
  const e2eProjectRoot = options.rootProject ? 'e2e' : `${appProjectRoot}-e2e`;

  const parsedTags = options.tags
    ? options.tags.split(',').map((s) => s.trim())
    : [];

  const style: Style = options.style ?? 'css';
  const hasStyles = style !== 'none';

  const nameVariants = names(appProjectName);

  return {
    ...options,
    addPlugin,
    useProjectJson: options.useProjectJson ?? !isUsingTsSolutionConfig,
    projectName: appProjectName,
    appProjectRoot,
    importPath,
    e2eProjectName,
    e2eProjectRoot,
    parsedTags,
    fileName: 'app',
    className: nameVariants.className,
    style,
    hasStyles,
    routing: options.routing ?? false,
    strict: options.strict ?? true,
    unitTestRunner: options.unitTestRunner ?? 'vitest',
    e2eTestRunner: options.e2eTestRunner ?? 'playwright',
    skipFormat: options.skipFormat ?? false,
    skipPackageJson: options.skipPackageJson ?? false,
  };
}

async function ensureRootProjectName(
  options: { name?: string; rootProject?: boolean },
  projectType: string,
): Promise<void> {
  if (options.name) {
    return;
  }

  if (options.rootProject) {
    options.name = projectType;
  }
}
