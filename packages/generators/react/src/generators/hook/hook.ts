import type { GeneratorCallback, Tree } from '@nx/devkit';
import { formatFiles, joinPathFragments, names, getProjects } from '@nx/devkit';

export interface HookGeneratorSchema {
  name: string;
  project: string;
  directory?: string;
  skipTests?: boolean;
  skipFormat?: boolean;
}

export async function hookGenerator(
  tree: Tree,
  options: HookGeneratorSchema,
): Promise<GeneratorCallback> {
  const projects = getProjects(tree);
  const project = projects.get(options.project);

  if (!project) {
    throw new Error(`Project "${options.project}" not found.`);
  }

  const { className, fileName } = names(options.name);
  const projectSourceRoot =
    project.sourceRoot ?? joinPathFragments(project.root, 'src');

  const hookDirectory = options.directory
    ? joinPathFragments(projectSourceRoot, options.directory)
    : joinPathFragments(projectSourceRoot, 'hooks');

  const hookName = className.startsWith('use') ? className : `use${className}`;
  const hookFileName = fileName.startsWith('use')
    ? fileName
    : `use-${fileName}`;

  tree.write(
    joinPathFragments(hookDirectory, `${hookFileName}.ts`),
    `export function ${hookName}() {
  // TODO: Implement hook
}

export default ${hookName};
`,
  );

  if (!options.skipTests) {
    tree.write(
      joinPathFragments(hookDirectory, `${hookFileName}.spec.ts`),
      `import { describe, it, expect } from 'vitest';
import { renderHook } from '@testing-library/react';
import { ${hookName} } from './${hookFileName}';

describe('${hookName}', () => {
  it('should be defined', () => {
    const { result } = renderHook(() => ${hookName}());
    expect(result.current).toBeDefined();
  });
});
`,
    );
  }

  if (!options.skipFormat) {
    await formatFiles(tree);
  }

  return () => {};
}

export default hookGenerator;
