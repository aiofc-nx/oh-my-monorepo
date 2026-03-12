export interface NestjsAppGeneratorSchema {
  name: string;
  directory?: string;
  tags?: string;
  importPath?: string;
  skipFormat?: boolean;
  skipPackageJson?: boolean;
}
