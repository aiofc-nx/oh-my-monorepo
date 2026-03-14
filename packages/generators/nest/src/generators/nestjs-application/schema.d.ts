export interface NestjsApplicationGeneratorSchema {
  directory: string;
  name?: string;
  bundler?: 'vite' | 'webpack';
  validation?: 'zod' | 'valibot' | 'arktype' | 'class-validator';
  tags?: string;
  skipFormat?: boolean;
  skipPackageJson?: boolean;
  strict?: boolean;
}

export interface NormalizedOptions extends NestjsApplicationGeneratorSchema {
  addPlugin: boolean;
  useProjectJson: boolean;
  projectName: string;
  projectRoot: string;
}
