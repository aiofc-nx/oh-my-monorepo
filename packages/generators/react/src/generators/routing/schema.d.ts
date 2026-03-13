export type RouterType = 'react-router' | 'tanstack-router';

export interface RoutingGeneratorSchema {
  project: string;
  directory?: string;
  type?: RouterType;
  skipFormat?: boolean;
  skipPackageJson?: boolean;
}

export interface NormalizedOptions extends RoutingGeneratorSchema {
  projectRoot: string;
  projectSourceRoot: string;
  routesDirectory: string;
}
