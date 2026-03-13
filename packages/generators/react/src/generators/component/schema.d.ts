export type Style =
  | 'css'
  | 'scss'
  | 'less'
  | 'styled-components'
  | '@emotion/styled'
  | 'none';

export interface ComponentGeneratorSchema {
  name: string;
  project: string;
  directory?: string;
  style?: Style;
  skipTests?: boolean;
  export?: boolean;
  flat?: boolean;
  skipFormat?: boolean;
  pascalCaseFiles?: boolean;
}

export interface NormalizedOptions extends ComponentGeneratorSchema {
  projectRoot: string;
  projectSourceRoot: string;
  componentPath: string;
  fileName: string;
  className: string;
  styleExtension: string | null;
  hasStyles: boolean;
}
