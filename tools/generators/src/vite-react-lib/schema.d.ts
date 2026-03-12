export interface ViteReactLibGeneratorSchema {
  name: string;
  directory?: string;
  tags?: string;
  style?: 'css' | 'tailwind' | 'none';
  buildable?: boolean;
  publishable?: boolean;
  importPath?: string;
  skipFormat?: boolean;
  skipPackageJson?: boolean;
}
