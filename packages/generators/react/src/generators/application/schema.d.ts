export type Style = 'css' | 'scss' | 'less' | 'none';
export type UnitTestRunner = 'vitest' | 'none';
export type E2eTestRunner = 'playwright' | 'none';

export interface ApplicationGeneratorSchema {
  directory: string;
  name?: string;
  style?: Style;
  routing?: boolean;
  unitTestRunner?: UnitTestRunner;
  e2eTestRunner?: E2eTestRunner;
  tags?: string;
  strict?: boolean;
  skipFormat?: boolean;
  skipPackageJson?: boolean;
  rootProject?: boolean;
}

export interface NormalizedOptions extends ApplicationGeneratorSchema {
  addPlugin: boolean;
  useProjectJson: boolean;
  projectName: string;
  appProjectRoot: string;
  e2eProjectName?: string;
  e2eProjectRoot?: string;
  parsedTags: string[];
  fileName: string;
  className: string;
  hasStyles: boolean;
  importPath: string;
}
