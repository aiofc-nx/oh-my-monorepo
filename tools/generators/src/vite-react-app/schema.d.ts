export interface ViteReactAppGeneratorSchema {
  name: string;
  directory?: string;
  tags?: string;
  style?: 'css' | 'tailwind' | 'none';
  routing?: boolean;
  inSourceTests?: boolean;
  skipFormat?: boolean;
  skipPackageJson?: boolean;
}
