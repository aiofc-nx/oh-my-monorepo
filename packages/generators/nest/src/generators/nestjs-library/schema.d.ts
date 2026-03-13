export interface NestjsLibraryGeneratorSchema {
  directory: string;
  name?: string;
  buildable?: boolean;
  controller?: boolean;
  global?: boolean;
  importPath?: string;
  publishable?: boolean;
  service?: boolean;
  skipFormat?: boolean;
  skipTsConfig?: boolean;
  skipPackageJson?: boolean;
  strict?: boolean;
  tags?: string;
  unitTestRunner?: 'vitest' | 'none';
}

export interface NormalizedOptions extends NestjsLibraryGeneratorSchema {
  addPlugin: boolean;
  useProjectJson: boolean;
  fileName: string;
  className: string;
  propertyName: string;
  parsedTags: string[];
  projectName: string;
  projectRoot: string;
}
