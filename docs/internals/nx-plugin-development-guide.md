# Nx 插件开发指南

> 本指南基于官方 Nx 文档和源码，详细介绍如何正确开发 Nx 插件和生成器。

## 目录

1. [核心概念](#1-核心概念)
2. [官方文档要点](#2-官方文档要点)
3. [插件结构规范](#3-插件结构规范)
4. [官方 @nx/nest 分析](#4-官方-nxnest-分析)
5. [当前实现问题](#5-当前实现问题)
6. [正确的开发计划](#6-正确的开发计划)

---

## 1. 核心概念

### 1.1 什么是 Nx 插件？

Nx 插件是一个 npm 包，提供：

- **Generators (生成器)**: 代码脚手架，创建/修改代码
- **Executors (执行器)**: 运行任务（构建、测试、服务）
- **Project Inference (项目推断)**: 自动检测项目配置

### 1.2 Local Generators vs Plugins

| 类型                 | 位置               | 用途           | 发布       |
| -------------------- | ------------------ | -------------- | ---------- |
| **Local Generators** | `tools/my-plugin/` | 内部工作区使用 | 不发布     |
| **Plugins**          | npm 包             | 跨工作区共享   | 发布到 npm |

### 1.3 关键文件

| 文件              | 作用                                   |
| ----------------- | -------------------------------------- |
| `package.json`    | 定义入口点 (`generators`, `executors`) |
| `generators.json` | 生成器注册表                           |
| `executors.json`  | 执行器注册表                           |
| `schema.json`     | 选项定义 (JSON Schema)                 |
| `generator.ts`    | 生成器实现                             |
| `files/`          | 模板文件目录                           |

---

## 2. 官方文档要点

### 2.1 创建插件

```bash
# 1. 安装插件支持
nx add @nx/plugin

# 2. 创建插件
nx g @nx/plugin:plugin tools/my-plugin

# 3. 创建生成器
nx g @nx/plugin:generator tools/my-plugin/src/generators/my-generator
```

### 2.2 生成器结构

```
tools/my-plugin/
├── src/
│   └── generators/
│       └── my-generator/
│           ├── generator.ts      # 入口函数
│           ├── schema.json       # 选项定义
│           └── files/            # 模板文件
├── generators.json               # 生成器注册
└── package.json                  # 包配置
```

### 2.3 生成器函数签名

```typescript
import { Tree, GeneratorCallback } from '@nx/devkit';

// 基本签名
export default async function (tree: Tree, schema: any) {
  // 修改文件...
  return () => {
    // 文件写入磁盘后执行的回调
  };
}

// 带类型的签名
interface MySchema {
  name: string;
  directory?: string;
  skipFormat?: boolean;
}

export default async function (
  tree: Tree,
  schema: MySchema,
): Promise<GeneratorCallback | void> {
  // ...
}
```

### 2.4 schema.json 格式

```json
{
  "cli": "nx",
  "$id": "MyGenerator",
  "title": "My Generator",
  "type": "object",
  "properties": {
    "name": {
      "type": "string",
      "description": "项目名称",
      "$default": {
        "$source": "argv",
        "index": 0
      },
      "x-prompt": "项目名称是什么？",
      "x-priority": "important"
    },
    "directory": {
      "type": "string",
      "description": "项目目录"
    },
    "skipFormat": {
      "type": "boolean",
      "default": false,
      "x-priority": "internal"
    }
  },
  "required": ["name"]
}
```

### 2.5 特殊 Schema 属性

| 属性               | 说明                                                  |
| ------------------ | ----------------------------------------------------- |
| `$default.$source` | 默认值来源：`argv`, `projectName`, `workingDirectory` |
| `x-prompt`         | 交互式提示                                            |
| `x-priority`       | 字段优先级：`important`, `internal`                   |
| `x-deprecated`     | 废弃标记                                              |
| `x-dropdown`       | 下拉选择：`projects`                                  |
| `x-hint`           | 字段提示                                              |

### 2.6 调用其他生成器

```typescript
import { Tree, formatFiles } from '@nx/devkit';
import { libraryGenerator } from '@nx/js';

export default async function (tree: Tree, schema: any) {
  // 调用其他生成器
  await libraryGenerator(tree, {
    name: schema.name,
    directory: schema.directory,
  });

  // 自定义修改
  tree.write('src/custom.ts', '// custom code');

  // 格式化
  await formatFiles(tree);
}
```

---

## 3. 插件结构规范

### 3.1 package.json 必需字段

```json
{
  "name": "@myorg/my-plugin",
  "main": "./dist/index.js",
  "types": "./dist/index.d.ts",
  "generators": "./dist/generators.json",
  "executors": "./dist/executors.json",
  "dependencies": {
    "@nx/devkit": "^22.0.0"
  }
}
```

### 3.2 generators.json 格式

```json
{
  "name": "@myorg/my-plugin",
  "version": "0.1",
  "extends": ["@nx/workspace"],
  "generators": {
    "application": {
      "factory": "./src/generators/application/application#applicationGeneratorInternal",
      "schema": "./src/generators/application/schema.json",
      "aliases": ["app"],
      "x-type": "application",
      "description": "创建应用"
    }
  }
}
```

**字段说明**：

| 字段      | 必需 | 说明                              |
| --------- | ---- | --------------------------------- |
| `name`    | ✅   | 插件名称，与 package.json 一致    |
| `version` | ✅   | generators.json 版本              |
| `extends` | ❌   | 继承其他插件的配置                |
| `factory` | ✅   | 工厂函数路径，格式：`路径#导出名` |
| `schema`  | ✅   | schema.json 路径                  |
| `aliases` | ❌   | CLI 别名                          |
| `x-type`  | ❌   | 项目类型标记                      |
| `hidden`  | ❌   | 是否隐藏                          |

### 3.3 目录结构最佳实践

```
tools/my-plugin/
├── src/
│   ├── generators/
│   │   ├── application/
│   │   │   ├── application.ts       # 主入口
│   │   │   ├── application.spec.ts  # 测试
│   │   │   ├── schema.json          # 选项定义
│   │   │   ├── schema.d.ts          # TypeScript 类型
│   │   │   ├── lib/                 # 辅助函数
│   │   │   │   ├── index.ts
│   │   │   │   ├── normalize-options.ts
│   │   │   │   ├── create-files.ts
│   │   │   │   └── update-config.ts
│   │   │   └── files/               # 模板文件
│   │   │       ├── main.ts__tmpl__
│   │   │       └── app/
│   │   └── library/
│   ├── utils/                       # 共享工具
│   │   ├── versions.ts
│   │   └── dependencies.ts
│   └── index.ts                     # 公共 API
├── generators.json
├── package.json
├── tsconfig.json
└── project.json
```

---

## 4. 官方 @nx/nest 分析

### 4.1 包结构

```
packages/nest/
├── src/
│   ├── generators/
│   │   ├── application/      # 应用生成器
│   │   ├── library/          # 库生成器
│   │   ├── init/             # 初始化
│   │   ├── controller/       # 子生成器
│   │   ├── service/
│   │   ├── module/
│   │   └── ...               # 其他子生成器
│   └── utils/
│       ├── ensure-dependencies.ts
│       └── versions.ts
├── generators.json
├── package.json
└── index.ts
```

### 4.2 Application 生成器调用链

```
@nx/nest:application
│
├── initGenerator()
│   └── 安装 @nx/nest 依赖到 package.json
│
├── @nx/node:applicationGenerator()
│   ├── 创建项目结构
│   ├── 配置 webpack 构建
│   └── 标记 isNest: true
│
├── createFiles()
│   └── 创建 NestJS 特定文件 (main.ts, app.module.ts 等)
│
├── updateTsConfig()
│   ├── experimentalDecorators: true
│   └── emitDecoratorMetadata: true
│
└── ensureDependencies()
    ├── @nestjs/common
    ├── @nestjs/core
    ├── @nestjs/platform-express
    ├── reflect-metadata
    └── rxjs
```

### 4.3 关键实现

**application.ts**:

```typescript
export async function applicationGeneratorInternal(
  tree: Tree,
  rawOptions: ApplicationGeneratorOptions,
): Promise<GeneratorCallback> {
  const options = await normalizeOptions(tree, rawOptions);
  const tasks: GeneratorCallback[] = [];

  // 1. 初始化
  const initTask = await initGenerator(tree, {
    skipPackageJson: options.skipPackageJson,
    skipFormat: true,
  });
  tasks.push(initTask);

  // 2. 调用 @nx/node
  const nodeTask = await nodeApplicationGenerator(
    tree,
    toNodeApplicationGeneratorOptions(options),
  );
  tasks.push(nodeTask);

  // 3. 创建文件
  createFiles(tree, options);

  // 4. 更新配置
  updateTsConfig(tree, options);

  // 5. 安装依赖
  if (!options.skipPackageJson) {
    tasks.push(ensureDependencies(tree));
  }

  // 6. 格式化
  if (!options.skipFormat) {
    await formatFiles(tree);
  }

  return runTasksInSerial(...tasks);
}
```

**updateTsConfig.ts**:

```typescript
export function updateTsConfig(tree: Tree, options: NormalizedOptions): void {
  updateJson(
    tree,
    joinPathFragments(options.appProjectRoot, 'tsconfig.app.json'),
    (json) => {
      json.compilerOptions.experimentalDecorators = true;
      json.compilerOptions.emitDecoratorMetadata = true;
      json.compilerOptions.target = 'es2021';
      return json;
    },
  );
}
```

**ensureDependencies.ts**:

```typescript
export function ensureDependencies(
  tree: Tree,
  projectRoot?: string,
): GeneratorCallback {
  return addDependenciesToPackageJson(
    tree,
    {
      '@nestjs/common': nestJsVersion,
      '@nestjs/core': nestJsVersion,
      '@nestjs/platform-express': nestJsVersion,
      'reflect-metadata': reflectMetadataVersion,
      rxjs: rxjsVersion,
    },
    {
      '@nestjs/testing': nestJsVersion,
    },
    projectRoot ? `${projectRoot}/package.json` : undefined,
  );
}
```

---

## 5. 当前实现问题

### 5.1 结构问题

**当前结构**:

```
tools/generators/
├── src/
│   ├── nestjs-app/
│   │   ├── index.ts           # ❌ 只有这一个文件
│   │   ├── schema.d.ts
│   │   └── files/
│   │       ├── README.md__tmpl__
│   │       └── vitest.config.ts__tmpl__
│   └── vite-react-app/
├── generators.json
└── package.json
```

**问题**:

1. **缺少 lib/ 目录**: 所有逻辑在一个文件中
2. **缺少 normalize-options.ts**: 选项处理不规范
3. **缺少 update-tsconfig.ts**: 装饰器配置不正确
4. **缺少 update-project.ts**: project.json 配置不正确
5. **缺少测试文件**: 没有单元测试

### 5.2 代码问题

**问题 1: vitest.config.ts 模板错误**

```typescript
// ❌ 错误
import { defineVitestConfig } from '@nx/vitest';

// ✅ 正确
import { defineConfig } from 'vitest/config';
```

**问题 2: tsconfig 更新不完整**

```typescript
// ❌ 当前实现 - 只更新根 tsconfig
function updateTsConfig(tree: Tree, options: NormalizedOptions) {
  const tsConfig = readJson(tree, `${options.appProjectRoot}/tsconfig.json`);
  tsConfig.extends = '@oksai/tsconfig/nestjs-esm.json';
  writeJson(tree, `${options.appProjectRoot}/tsconfig.json`, tsConfig);
}

// ✅ 正确实现 - 更新 tsconfig.app.json
function updateTsConfig(tree: Tree, options: NormalizedOptions) {
  updateJson(tree, `${options.appProjectRoot}/tsconfig.app.json`, (json) => {
    json.compilerOptions.experimentalDecorators = true;
    json.compilerOptions.emitDecoratorMetadata = true;
    return json;
  });
}
```

**问题 3: project.json 配置缺失**

```typescript
// ❌ 当前实现 - 空函数
function updateProjectJson(_tree: Tree, _options: NormalizedOptions) {
  // 空实现
}

// ✅ 正确实现
function updateProject(tree: Tree, options: NormalizedOptions) {
  const project = readProjectConfiguration(tree, options.projectName);

  project.targets.build = {
    executor: '@nx/webpack:webpack',
    outputs: ['{options.outputPath}'],
    options: {
      target: 'node',
      compiler: 'swc',
      outputPath: `dist/${options.appProjectRoot}`,
      main: `${options.appProjectRoot}/src/main.ts`,
      tsConfig: `${options.appProjectRoot}/tsconfig.app.json`,
      webpackConfig: `${options.appProjectRoot}/webpack.config.js`,
    },
  };

  project.targets.test = {
    executor: '@nx/vitest:vitest',
    options: {
      config: `${options.appProjectRoot}/vitest.config.ts`,
    },
  };

  updateProjectConfiguration(tree, options.projectName, project);
}
```

**问题 4: 依赖不完整**

```typescript
// ❌ 当前实现
addDependenciesToPackageJson(
  tree,
  {},
  {
    vitest: '^2.0.0',
    '@vitest/coverage-v8': '^2.0.0',
  },
);

// ✅ 正确实现
addDependenciesToPackageJson(
  tree,
  {},
  {
    vitest: '^4.0.0',
    '@vitest/coverage-v8': '^4.0.0',
    'swc-loader': '^0.2.7', // 必需
  },
);
```

---

## 6. 正确的开发计划

### 阶段 1: 重构现有结构

**目标**: 规范化目录结构

```
tools/generators/
├── src/
│   ├── generators/
│   │   ├── nestjs-application/
│   │   │   ├── nestjs-application.ts      # 主入口
│   │   │   ├── nestjs-application.spec.ts # 测试
│   │   │   ├── schema.json
│   │   │   ├── schema.d.ts
│   │   │   ├── lib/
│   │   │   │   ├── index.ts
│   │   │   │   ├── normalize-options.ts
│   │   │   │   ├── create-files.ts
│   │   │   │   ├── update-tsconfig.ts
│   │   │   │   └── update-project.ts
│   │   │   └── files/
│   │   │       ├── vitest.config.ts__tmpl__
│   │   │       └── README.md__tmpl__
│   │   └── vite-react-application/
│   └── utils/
│       ├── versions.ts
│       └── testing.ts
├── generators.json
└── package.json
```

### 阶段 2: 修复 nestjs-application 生成器

**步骤**:

1. **创建 lib/normalize-options.ts**

```typescript
import { Tree, readNxJson } from '@nx/devkit';
import {
  determineProjectNameAndRootOptions,
  ensureRootProjectName,
} from '@nx/devkit/src/generators/project-name-and-root-utils';

export interface NormalizedOptions {
  projectName: string;
  projectRoot: string;
  name: string;
  directory?: string;
  tags?: string;
  skipFormat: boolean;
  skipPackageJson: boolean;
  strict: boolean;
}

export async function normalizeOptions(
  tree: Tree,
  options: NestjsApplicationGeneratorSchema,
): Promise<NormalizedOptions> {
  await ensureRootProjectName(options, 'application');

  const { projectName, projectRoot } = await determineProjectNameAndRootOptions(
    tree,
    {
      name: options.name,
      projectType: 'application',
      directory: options.directory,
    },
  );

  return {
    ...options,
    projectName,
    projectRoot,
    skipFormat: options.skipFormat ?? false,
    skipPackageJson: options.skipPackageJson ?? false,
    strict: options.strict ?? false,
    tags: options.tags ?? 'type:app,framework:nest',
  };
}
```

2. **创建 lib/update-tsconfig.ts**

```typescript
import { Tree, joinPathFragments, updateJson } from '@nx/devkit';
import type { NormalizedOptions } from './normalize-options';

export function updateTsConfig(tree: Tree, options: NormalizedOptions): void {
  updateJson(
    tree,
    joinPathFragments(options.projectRoot, 'tsconfig.app.json'),
    (json) => {
      json.compilerOptions = {
        ...json.compilerOptions,
        experimentalDecorators: true,
        emitDecoratorMetadata: true,
        target: 'es2021',
      };

      if (options.strict) {
        json.compilerOptions = {
          ...json.compilerOptions,
          strictNullChecks: true,
          noImplicitAny: true,
          strictBindCallApply: true,
          forceConsistentCasingInFileNames: true,
          noFallthroughCasesInSwitch: true,
        };
      }

      return json;
    },
  );
}
```

3. **创建 lib/update-project.ts**

```typescript
import {
  Tree,
  joinPathFragments,
  readProjectConfiguration,
  updateProjectConfiguration,
} from '@nx/devkit';
import type { NormalizedOptions } from './normalize-options';

export function updateProject(tree: Tree, options: NormalizedOptions): void {
  const project = readProjectConfiguration(tree, options.projectName);

  // 更新 build target
  project.targets.build = {
    executor: '@nx/webpack:webpack',
    outputs: ['{options.outputPath}'],
    defaultConfiguration: 'production',
    options: {
      target: 'node',
      compiler: 'swc',
      outputPath: `dist/${options.projectRoot}`,
      main: joinPathFragments(options.projectRoot, 'src/main.ts'),
      tsConfig: joinPathFragments(options.projectRoot, 'tsconfig.app.json'),
      webpackConfig: joinPathFragments(
        options.projectRoot,
        'webpack.config.js',
      ),
      assets: [joinPathFragments(options.projectRoot, 'src/assets')],
    },
    configurations: {
      development: {
        outputHashing: 'none',
      },
      production: {},
    },
  };

  // 添加 test target
  project.targets.test = {
    executor: '@nx/vitest:vitest',
    outputs: [`{workspaceRoot}/coverage/${options.projectRoot}`],
    options: {
      config: joinPathFragments(options.projectRoot, 'vitest.config.ts'),
    },
  };

  updateProjectConfiguration(tree, options.projectName, project);
}
```

4. **修复 files/vitest.config.ts**tmpl\*\*\*\*

```typescript
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,
    environment: 'node',
    include: ['src/**/*.spec.ts'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'lcov'],
    },
  },
});
```

5. **创建主入口 nestjs-application.ts**

```typescript
import {
  Tree,
  formatFiles,
  runTasksInSerial,
  addDependenciesToPackageJson,
  GeneratorCallback,
} from '@nx/devkit';
import { applicationGenerator as nodeApplicationGenerator } from '@nx/node';
import { normalizeOptions, NormalizedOptions } from './lib/normalize-options';
import { createFiles } from './lib/create-files';
import { updateTsConfig } from './lib/update-tsconfig';
import { updateProject } from './lib/update-project';
import type { NestjsApplicationGeneratorSchema } from './schema';

export default async function nestjsApplicationGenerator(
  tree: Tree,
  rawOptions: NestjsApplicationGeneratorSchema,
): Promise<GeneratorCallback> {
  return nestjsApplicationGeneratorInternal(tree, {
    addPlugin: false,
    useProjectJson: true,
    ...rawOptions,
  });
}

export async function nestjsApplicationGeneratorInternal(
  tree: Tree,
  rawOptions: NestjsApplicationGeneratorSchema,
): Promise<GeneratorCallback> {
  const options = await normalizeOptions(tree, rawOptions);
  const tasks: GeneratorCallback[] = [];

  // 1. 调用 @nx/node 生成器
  const nodeTask = await nodeApplicationGenerator(tree, {
    name: options.projectName,
    directory: options.projectRoot,
    framework: 'nest',
    bundler: 'webpack',
    unitTestRunner: 'none',
    linter: 'none',
    tags: options.tags,
    skipFormat: true,
  });
  tasks.push(nodeTask);

  // 2. 更新 TypeScript 配置
  updateTsConfig(tree, options);

  // 3. 更新 project.json
  updateProject(tree, options);

  // 4. 创建自定义文件
  createFiles(tree, options);

  // 5. 添加依赖
  if (!options.skipPackageJson) {
    const depsTask = addDependenciesToPackageJson(
      tree,
      {},
      {
        vitest: '^4.0.0',
        '@vitest/coverage-v8': '^4.0.0',
        'swc-loader': '^0.2.7',
      },
    );
    if (depsTask) tasks.push(depsTask);
  }

  // 6. 格式化
  if (!options.skipFormat) {
    await formatFiles(tree);
  }

  return runTasksInSerial(...tasks);
}
```

### 阶段 3: 更新 generators.json

```json
{
  "name": "@oksai/generators",
  "version": "0.1",
  "extends": ["@nx/workspace"],
  "generators": {
    "nestjs-application": {
      "factory": "./src/generators/nestjs-application/nestjs-application#nestjsApplicationGeneratorInternal",
      "schema": "./src/generators/nestjs-application/schema.json",
      "aliases": ["nest-app"],
      "x-type": "application",
      "description": "创建 NestJS 应用（Vitest + Biome）"
    },
    "vite-react-application": {
      "factory": "./src/generators/vite-react-application/vite-react-application",
      "schema": "./src/generators/vite-react-application/schema.json",
      "aliases": ["react-app"],
      "x-type": "application",
      "description": "创建 React 应用（Vite + Vitest + Biome）"
    }
  }
}
```

### 阶段 4: 添加测试

```typescript
// nestjs-application.spec.ts
import { createTreeWithEmptyWorkspace } from '@nx/devkit/testing';
import { nestjsApplicationGenerator } from './nestjs-application';
import { readProjectConfiguration, readJson } from '@nx/devkit';

describe('nestjs-application generator', () => {
  it('should create project with correct targets', async () => {
    const tree = createTreeWithEmptyWorkspace();

    await nestjsApplicationGenerator(tree, { name: 'api' });

    const project = readProjectConfiguration(tree, 'api');

    expect(project.targets.build.executor).toBe('@nx/webpack:webpack');
    expect(project.targets.test.executor).toBe('@nx/vitest:vitest');
  });

  it('should enable decorators', async () => {
    const tree = createTreeWithEmptyWorkspace();

    await nestjsApplicationGenerator(tree, { name: 'api' });

    const tsConfig = readJson(tree, 'apps/api/tsconfig.app.json');

    expect(tsConfig.compilerOptions.experimentalDecorators).toBe(true);
    expect(tsConfig.compilerOptions.emitDecoratorMetadata).toBe(true);
  });
});
```

### 阶段 5: 文档更新

更新 `tools/generators/README.md`：

1. 生成器列表和使用方法
2. 选项说明
3. 生成的文件结构
4. 技术栈说明

---

## 附录

### A. 命令速查

```bash
# 构建生成器
pnpm nx build @oksai/generators

# 运行生成器
pnpm nx g @oksai/generators:nestjs-application my-api

# 调试模式
NX_VERBOSE_LOGGING=true pnpm nx g @oksai/generators:nestjs-application my-api

# Dry run
pnpm nx g @oksai/generators:nestjs-application my-api --dry-run
```

### B. 相关文档

- [Nx Local Generators](https://nx.dev/docs/extending-nx/local-generators)
- [Nx Devkit API](https://nx.dev/packages/devkit)
- [JSON Schema](https://json-schema.org/)

### C. 源码参考

| 包        | 路径                                    | 说明               |
| --------- | --------------------------------------- | ------------------ |
| @nx/nest  | `/home/arligle/forks/nx/packages/nest`  | NestJS 生成器参考  |
| @nx/node  | `/home/arligle/forks/nx/packages/node`  | Node.js 生成器基础 |
| @nx/react | `/home/arligle/forks/nx/packages/react` | React 生成器参考   |

---

**文档版本**: 1.1
**最后更新**: 2025-03-13

## 附录 D: 官方 @nx/plugin 生成器模板

### D.1 标准生成器文件结构

使用 `nx g @nx/plugin:generator` 创建的生成器会生成以下文件：

```
src/generators/my-generator/
├── my-generator.ts           # 主入口
├── my-generator.spec.ts      # 测试
├── schema.json               # 选项定义
├── schema.d.ts               # TypeScript 类型
└── files/                    # 模板目录
    └── src/
        └── index.ts.template
```

### D.2 标准生成器模板

**my-generator.ts.template**:

```typescript
import {
  addProjectConfiguration,
  formatFiles,
  generateFiles,
  Tree,
} from '@nx/devkit';
import * as path from 'path';
import { <%= className %>GeneratorSchema } from './schema';

export async function <%= generatorFnName %> (tree: Tree, options: <%= schemaInterfaceName %>) {
  const projectRoot = `libs/${options.name}`;
  addProjectConfiguration(
    tree,
    options.name,
    {
      root: projectRoot,
      projectType: 'library',
      sourceRoot: `${projectRoot}/src`,
      targets: {}
    }
  );
  generateFiles(tree, path.join(__dirname, 'files'), projectRoot, options);
  await formatFiles(tree);
}

export default <%= generatorFnName %>;
```

**schema.json.template**:

```json
{
  "$schema": "https://json-schema.org/schema",
  "$id": "<%= className %>",
  "title": "",
  "type": "object",
  "properties": {
    "name": {
      "type": "string",
      "description": "",
      "$default": {
        "$source": "argv",
        "index": 0
      },
      "x-prompt": "What name would you like to use?"
    }
  },
  "required": ["name"]
}
```

**schema.d.ts.template**:

```typescript
export interface <%= className %>GeneratorSchema {
    name: string;
}
```

### D.3 generators.json 更新逻辑

当创建新生成器时，`generators.json` 会自动更新：

```typescript
// 自动添加到 generators.json
{
  "generators": {
    "my-generator": {
      "factory": "./src/generators/my-generator/my-generator",
      "schema": "./src/generators/my-generator/schema.json",
      "description": "my-generator generator"
    }
  }
}
```

### D.4 package.json 依赖

自动添加以下依赖：

```json
{
  "dependencies": {
    "@nx/devkit": "workspace:*"
  },
  "devDependencies": {
    "@nx/jest": "workspace:*", // 或 @nx/vitest
    "@nx/js": "workspace:*",
    "@nx/plugin": "workspace:*"
  }
}
```

### D.5 构建资源配置

```json
{
  "targets": {
    "build": {
    "options": {
      "assets": [
        { "input": "./src", "glob": "**/!(*.ts)", "output": "./src" },
        { "input": "./src", "glob": "**/*.d.ts", "output": "./src" },
        { "input": ".", "glob": "generators.json", "output": "." },
        { "input": ".", "glob": "executors.json", "output": "." }
      ]
    }
  }
}
```
