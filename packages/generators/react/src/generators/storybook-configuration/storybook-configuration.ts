import type { GeneratorCallback, Tree } from '@nx/devkit';
import {
  addDependenciesToPackageJson,
  formatFiles,
  joinPathFragments,
  getProjects,
  updateProjectConfiguration,
} from '@nx/devkit';
import {
  storybookVersion,
  storybookReactVersion,
  storybookReactViteVersion,
  storybookAddonEssentialsVersion,
  storybookAddonInteractionsVersion,
  storybookTestVersion,
} from '../../utils/versions';

export interface StorybookConfigurationSchema {
  project: string;
  skipFormat?: boolean;
  skipPackageJson?: boolean;
  configureCypress?: boolean;
  configureTestRunner?: boolean;
}

export async function storybookConfigurationGenerator(
  tree: Tree,
  options: StorybookConfigurationSchema,
): Promise<GeneratorCallback> {
  const projects = getProjects(tree);
  const project = projects.get(options.project);

  if (!project) {
    throw new Error(`Project "${options.project}" not found.`);
  }

  const tasks: GeneratorCallback[] = [];

  const projectRoot = project.root;

  tree.write(
    joinPathFragments(projectRoot, '.storybook', 'main.ts'),
    `import type { StorybookConfig } from '@storybook/react-vite';

const config: StorybookConfig = {
  stories: ['../src/**/*.mdx', '../src/**/*.stories.@(js|jsx|mjs|ts|tsx)'],
  addons: [
    '@storybook/addon-essentials',
    '@storybook/addon-interactions',
  ],
  framework: {
    name: '@storybook/react-vite',
    options: {},
  },
  docs: {},
  typescript: {
    reactDocgen: 'react-docgen-typescript',
  },
};

export default config;
`,
  );

  tree.write(
    joinPathFragments(projectRoot, '.storybook', 'preview.ts'),
    `import type { Preview } from '@storybook/react';

const preview: Preview = {
  parameters: {
    controls: {
      matchers: {
        color: /(background|color)$/i,
        date: /Date$/i,
      },
    },
  },
};

export default preview;
`,
  );

  tree.write(
    joinPathFragments(projectRoot, '.storybook', 'tsconfig.json'),
    `{
  "extends": "../tsconfig.json",
  "compilerOptions": {
    "emitDecoratorMetadata": true,
    "experimentalDecorators": true
  },
  "include": ["../src/**/*.stories.ts", "../src/**/*.stories.tsx"]
}
`,
  );

  project.targets = project.targets || {};
  project.targets.storybook = {
    executor: '@nx/storybook:storybook',
    options: {
      port: 4400,
      configDir: joinPathFragments(projectRoot, '.storybook'),
      browserTarget: `${options.project}:build`,
    },
    configurations: {
      ci: {
        quiet: true,
      },
    },
  };

  project.targets['build-storybook'] = {
    executor: '@nx/storybook:build',
    outputs: [`{workspaceRoot}/dist/storybook/${options.project}`],
    options: {
      outputDir: joinPathFragments('dist', 'storybook', options.project),
      configDir: joinPathFragments(projectRoot, '.storybook'),
      browserTarget: `${options.project}:build`,
    },
    configurations: {
      ci: {
        quiet: true,
      },
    },
  };

  if (options.configureTestRunner) {
    project.targets['test-storybook'] = {
      executor: 'nx:run-commands',
      options: {
        command: `test-storybook -c ${joinPathFragments(projectRoot, '.storybook')}`,
      },
    };
  }

  updateProjectConfiguration(tree, options.project, project);

  if (!options.skipPackageJson) {
    const depsTask = addDependenciesToPackageJson(
      tree,
      {},
      {
        '@storybook/react': storybookReactVersion,
        '@storybook/react-vite': storybookReactViteVersion,
        '@storybook/addon-essentials': storybookAddonEssentialsVersion,
        '@storybook/addon-interactions': storybookAddonInteractionsVersion,
        '@storybook/test': storybookTestVersion,
        storybook: storybookVersion,
        '@storybook/blocks': storybookVersion,
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

export default storybookConfigurationGenerator;
