import type { GeneratorCallback, Tree } from '@nx/devkit';
import { addDependenciesToPackageJson, formatFiles } from '@nx/devkit';
import { libraryGenerator as jsLibraryGenerator } from '@nx/js';

export type Style = 'css' | 'scss' | 'less' | 'none';

export interface LibraryGeneratorSchema {
  directory: string;
  name?: string;
  style?: Style;
  tags?: string;
  skipFormat?: boolean;
  skipPackageJson?: boolean;
}

export async function libraryGenerator(
  tree: Tree,
  options: LibraryGeneratorSchema,
): Promise<GeneratorCallback> {
  const tasks: GeneratorCallback[] = [];

  const jsLibTask = await jsLibraryGenerator(tree, {
    bundler: 'vite',
    skipFormat: true,
    skipPackageJson: options.skipPackageJson,
    directory: options.directory,
    name: options.name,
  });
  tasks.push(jsLibTask);

  if (!options.skipPackageJson) {
    const depsTask = addDependenciesToPackageJson(
      tree,
      { react: '^19.0.0', 'react-dom': '^19.0.0' },
      { '@testing-library/react': '^16.0.0' },
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

export default libraryGenerator;
