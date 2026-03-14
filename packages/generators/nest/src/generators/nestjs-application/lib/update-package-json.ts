import { joinPathFragments, Tree, updateJson } from '@nx/devkit';
import type { NormalizedOptions } from '../schema';
import {
  zodVersion,
  valibotVersion,
  arktypeVersion,
} from '../../../utils/versions';

export function updatePackageJson(tree: Tree, options: NormalizedOptions): void {
  const packageJsonPath = joinPathFragments(options.projectRoot, 'package.json');

  updateJson(tree, packageJsonPath, (json) => {
    // 设置 ESM 类型
    json.type = 'module';

    // ESM exports
    json.exports = {
      '.': {
        import: './dist/main.js',
        types: './dist/main.d.ts',
      },
    };

    json.main = './dist/main.js';
    json.module = './dist/main.js';
    json.types = './dist/main.d.ts';

    // 添加验证库依赖
    json.dependencies = json.dependencies || {};

    if (options.validation === 'zod') {
      json.dependencies['zod'] = zodVersion;
    } else if (options.validation === 'valibot') {
      json.dependencies['valibot'] = valibotVersion;
    } else if (options.validation === 'arktype') {
      json.dependencies['arktype'] = arktypeVersion;
    }

    return json;
  });
}
