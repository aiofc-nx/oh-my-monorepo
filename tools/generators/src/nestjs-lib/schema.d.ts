export interface NestjsLibGeneratorSchema {
  name: string;
  directory?: string;
  tags?: string;
  importPath?: string;
  buildable?: boolean;
  publishable?: boolean;
  skipFormat?: boolean;
  skipPackageJson?: boolean;
}
