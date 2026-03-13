import type { GeneratorCallback, Tree } from '@nx/devkit';
import { addDependenciesToPackageJson, formatFiles } from '@nx/devkit';
import type { InitGeneratorSchema } from './schema';
import {
  reactVersion,
  reactDomVersion,
  viteVersion,
  vitePluginReactVersion,
  vitestVersion,
  vitestCoverageV8Version,
  jsdomVersion,
  testingLibraryReactVersion,
  testingLibraryJestDomVersion,
  playwrightVersion,
  playwrightCoreVersion,
  typescriptVersion,
} from '../../utils/versions';

export async function reactInitGenerator(
  tree: Tree,
  options: InitGeneratorSchema,
): Promise<GeneratorCallback> {
  const tasks: GeneratorCallback[] = [];

  if (!options.skipPackageJson) {
    const depsTask = addDependenciesToPackageJson(
      tree,
      {
        react: reactVersion,
        'react-dom': reactDomVersion,
      },
      {
        vite: viteVersion,
        '@vitejs/plugin-react': vitePluginReactVersion,
        vitest: vitestVersion,
        '@vitest/coverage-v8': vitestCoverageV8Version,
        jsdom: jsdomVersion,
        '@testing-library/react': testingLibraryReactVersion,
        '@testing-library/jest-dom': testingLibraryJestDomVersion,
        '@playwright/test': playwrightVersion,
        'playwright-core': playwrightCoreVersion,
        typescript: typescriptVersion,
      },
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

export default reactInitGenerator;
