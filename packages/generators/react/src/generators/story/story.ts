import type { Tree } from '@nx/devkit';
import {
  formatFiles,
  generateFiles,
  getProjects,
  joinPathFragments,
  names,
} from '@nx/devkit';
import { normalizeOptions } from './lib/normalize-options';
import type { StorySchema } from './schema';

export async function storyGenerator(
  tree: Tree,
  options: StorySchema,
): Promise<void> {
  const projects = getProjects(tree);
  const project = projects.get(options.project);

  if (!project) {
    throw new Error(`Project "${options.project}" not found.`);
  }

  const normalizedOptions = normalizeOptions(tree, options);
  const { componentName, componentFileName, path } = normalizedOptions;

  generateFiles(tree, joinPathFragments(__dirname, 'files'), path, {
    ...names(options.name),
    componentName,
    componentFileName,
    tmpl: '',
  });

  if (!options.skipFormat) {
    await formatFiles(tree);
  }
}

export default storyGenerator;
