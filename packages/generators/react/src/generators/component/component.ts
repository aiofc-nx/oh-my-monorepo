import type { GeneratorCallback, Tree } from '@nx/devkit';
import {
  formatFiles,
  generateFiles,
  joinPathFragments,
  names,
  getProjects,
} from '@nx/devkit';
import { join } from 'path';

export type Style =
  | 'css'
  | 'scss'
  | 'less'
  | 'styled-components'
  | '@emotion/styled'
  | 'none';

export interface ComponentGeneratorSchema {
  name: string;
  project: string;
  directory?: string;
  style?: Style;
  skipTests?: boolean;
  export?: boolean;
  flat?: boolean;
  skipFormat?: boolean;
  pascalCaseFiles?: boolean;
}

export async function componentGenerator(
  tree: Tree,
  options: ComponentGeneratorSchema,
): Promise<GeneratorCallback> {
  const projects = getProjects(tree);
  const project = projects.get(options.project);

  if (!project) {
    throw new Error(`Project "${options.project}" not found.`);
  }

  const { className, fileName: name } = names(options.name);
  const fileName = options.pascalCaseFiles ? className : name;

  const projectSourceRoot =
    project.sourceRoot ?? joinPathFragments(project.root, 'src');

  const componentPath = options.directory
    ? joinPathFragments(projectSourceRoot, options.directory)
    : options.flat
      ? projectSourceRoot
      : joinPathFragments(projectSourceRoot, 'components', fileName);

  const styleExtension = getStyleExtension(options.style);
  const hasStyles = options.style !== 'none';
  const styledComponent =
    options.style === 'styled-components' ||
    options.style === '@emotion/styled';

  const substitutions = {
    tmpl: '',
    fileName,
    className,
    style: options.style ?? 'css',
    styleExtension,
    hasStyles,
    styledComponent,
  };

  generateFiles(tree, join(__dirname, 'files'), componentPath, substitutions);

  if (options.skipTests) {
    const testFile = joinPathFragments(componentPath, `${fileName}.spec.tsx`);
    if (tree.exists(testFile)) {
      tree.delete(testFile);
    }
  }

  if (!hasStyles || styledComponent) {
    const extensions = ['css', 'scss', 'less'];
    for (const ext of extensions) {
      const styleFile = joinPathFragments(componentPath, `${fileName}.${ext}`);
      if (tree.exists(styleFile)) {
        tree.delete(styleFile);
      }
    }
  }

  if (options.export) {
    const indexPath = joinPathFragments(projectSourceRoot, 'index.ts');
    if (tree.exists(indexPath)) {
      const indexContent = tree.read(indexPath, 'utf-8') ?? '';
      const relativePath = options.flat
        ? `./${fileName}`
        : `./components/${fileName}`;
      const exportStatement = `export * from '${relativePath}';\n`;
      if (!indexContent.includes(exportStatement)) {
        tree.write(indexPath, indexContent + exportStatement);
      }
    }
  }

  if (!options.skipFormat) {
    await formatFiles(tree);
  }

  return () => {};
}

function getStyleExtension(style?: string): string | null {
  if (
    !style ||
    style === 'none' ||
    style === 'styled-components' ||
    style === '@emotion/styled'
  ) {
    return null;
  }
  return style;
}

export default componentGenerator;
