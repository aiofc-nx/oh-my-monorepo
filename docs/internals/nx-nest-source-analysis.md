# Nx @nx/node 和 @nx/nest 源码深度分析

> 本文档基于 `/home/arligle/forks/nx/packages/node` 和 `/home/arligle/forks/nx/packages/nest` 源码进行深度分析。

## 目录

1. [架构概览](#1-架构概览)
2. [调用链分析](#2-调用链分析)
3. [关键文件详解](#3-关键文件详解)
4. [Target 配置详解](#4-target-配置详解)
5. [依赖管理机制](#5-依赖管理机制)
6. [实现对比与差异](#6-实现对比与差异)

---

## 1. 架构概览

### 1.1 包结构

```
packages/node/
├── src/
│   ├── generators/
│   │   ├── application/       # 应用生成器
│   │   │   ├── application.ts # 主入口
│   │   │   ├── schema.d.ts    # 类型定义
│   │   │   └── lib/
│   │   │       ├── index.ts
│   │   │       ├── normalize-options.ts
│   │   │       ├── normalized-schema.ts
│   │   │       ├── create-project.ts
│   │   │       ├── create-targets.ts
│   │   │       ├── create-files.ts
│   │   │       ├── add-dependencies.ts
│   │   │       ├── add-linting.ts
│   │   │       └── add-proxy.ts
│   │   ├── library/
│   │   ├── init/
│   │   └── e2e-project/
│   └── utils/
│       ├── versions.ts
│       └── has-webpack-plugin.ts

packages/nest/
├── src/
│   ├── generators/
│   │   ├── application/       # NestJS 应用生成器
│   │   │   ├── application.ts # 主入口
│   │   │   ├── schema.d.ts
│   │   │   ├── lib/
│   │   │   │   ├── index.ts
│   │   │   │   ├── normalize-options.ts
│   │   │   │   ├── update-tsconfig.ts
│   │   │   │   └── create-files.ts
│   │   │   └── files/
│   │   │       ├── common/
│   │   │       │   ├── main.ts__tmpl__
│   │   │       │   └── app/
│   │   │       └── test/
│   │   ├── library/
│   │   ├── init/
│   │   ├── controller/        # 子生成器 (使用 @nestjs/schematics)
│   │   ├── service/
│   │   ├── module/
│   │   └── ...
│   └── utils/
│       ├── ensure-dependencies.ts
│       └── versions.ts
└── generators.json
```

### 1.2 生成器类型

| 生成器      | @nx/node            | @nx/nest                          |
| ----------- | ------------------- | --------------------------------- |
| application | ✅ 独立实现         | ✅ 委托给 @nx/node                |
| library     | ✅ 独立实现         | ✅ 委托给 @nx/js                  |
| init        | ✅ 初始化 Node 依赖 | ✅ 初始化 NestJS 依赖             |
| 子生成器    | -                   | ✅ controller, service, module 等 |

---

## 2. 调用链分析

### 2.1 完整调用链

```
用户命令: nx g @nx/nest:application my-api
    │
    ▼
@nx/nest:applicationGenerator
    │
    ├── normalizeOptions()
    │   └── 确定 projectName, appProjectRoot
    │
    ├── initGenerator()
    │   └── addDependencies()
    │       ├── @nestjs/schematics
    │       └── @nx/nest
    │
    ├── @nx/node:applicationGenerator (toNodeApplicationGeneratorOptions)
    │   │
    │   ├── jsInitGenerator()
    │   │   └── 初始化 @nx/js
    │   │
    │   ├── normalizeOptions()
    │   │   └── 确定 outputPath, importPath, parsedTags
    │   │
    │   ├── addProjectDependencies()
    │   │   └── 添加框架依赖 (无 NestJS 框架依赖)
    │   │
    │   ├── webpackInitGenerator()
    │   │   └── 初始化 @nx/webpack
    │   │
    │   ├── ensureDependencies() (@nx/webpack)
    │   │   └── webpack, webpack-cli, swc-loader 等
    │   │
    │   ├── addAppFiles()
    │   │   └── 创建基础 Node 文件
    │   │
    │   ├── addProject()
    │   │   ├── 创建 project.json
    │   │   ├── build target (getNestWebpackBuildConfig)
    │   │   │   └── executor: nx:run-commands
    │   │   │   └── command: webpack-cli build
    │   │   └── serve target
    │   │       └── executor: @nx/js:node
    │   │
    │   ├── updateTsConfigOptions()
    │   │   └── esModuleInterop: true
    │   │
    │   └── addLintingToApplication() (如果 linter=eslint)
    │
    ├── createFiles() (@nx/nest)
    │   ├── common/
    │   │   ├── main.ts
    │   │   └── app/
    │   │       ├── app.module.ts
    │   │       ├── app.controller.ts
    │   │       └── app.service.ts
    │   └── test/ (如果 unitTestRunner=jest)
    │
    ├── updateTsConfig() (@nx/nest)
    │   ├── experimentalDecorators: true
    │   ├── emitDecoratorMetadata: true
    │   └── target: es2021
    │
    ├── ensureDependencies() (@nx/nest)
    │   ├── @nestjs/common
    │   ├── @nestjs/core
    │   ├── @nestjs/platform-express
    │   ├── reflect-metadata
    │   ├── rxjs
    │   └── tslib
    │
    └── formatFiles()
```

### 2.2 关键发现：@nx/node 如何处理 NestJS

```typescript
// @nx/node/src/generators/application/application.ts
export async function applicationGeneratorInternal(tree: Tree, schema: Schema) {
  // ...
  const options = await normalizeOptions(tree, schema);

  // 关键：检测是否是 NestJS
  if (options.framework === 'nest') {
    // 委托给 @nx/nest
    const { applicationGenerator } = ensurePackage('@nx/nest', nxVersion);
    const nestTasks = await applicationGenerator(tree, {
      ...options,
      skipFormat: true,
    });
    tasks.push(nestTasks);
    return runTasksInSerial(...tasks);
  }

  // 非 NestJS 的处理...
}
```

### 2.3 NestJS 如何配置 Node 选项

```typescript
// @nx/nest/src/generators/application/lib/normalize-options.ts
export function toNodeApplicationGeneratorOptions(
  options: NormalizedOptions,
): NodeApplicationGeneratorOptions {
  return {
    name: options.name,
    directory: options.directory,
    // 关键配置
    bundler: 'webpack', // 强制使用 webpack
    isNest: true, // 标记为 NestJS 项目
    addPlugin: options.addPlugin,
    useProjectJson: options.useProjectJson,
    // ...
  };
}
```

### 2.4 isNest 标志的影响

```typescript
// @nx/node/src/generators/application/lib/create-project.ts
export function addProject(tree: Tree, options: NormalizedSchema, ...) {
  // ...
  if (options.bundler === 'webpack') {
    if (!hasWebpackPlugin(tree) && options.addPlugin === false) {
      // 标准项目：使用 @nx/webpack:webpack
      project.targets.build = getWebpackBuildConfig(tree, project, options);
    } else if (options.isNest) {
      // NestJS 项目：使用 nx:run-commands + webpack-cli
      project.targets.build = getNestWebpackBuildConfig(project);
    }
  }
}
```

---

## 3. 关键文件详解

### 3.1 @nx/nest/application.ts - 主入口

```typescript
// src/generators/application/application.ts
import { applicationGenerator as nodeApplicationGenerator } from '@nx/node';
import { initGenerator } from '../init/init';
import { ensureDependencies } from '../../utils/ensure-dependencies';
import {
  createFiles,
  normalizeOptions,
  toNodeApplicationGeneratorOptions,
  updateTsConfig,
} from './lib';

export async function applicationGeneratorInternal(
  tree: Tree,
  rawOptions: ApplicationGeneratorOptions,
): Promise<GeneratorCallback> {
  const options = await normalizeOptions(tree, rawOptions);
  const tasks: GeneratorCallback[] = [];

  // 1. 初始化 @nx/nest 依赖
  const initTask = await initGenerator(tree, {
    skipPackageJson: options.skipPackageJson,
    skipFormat: true,
  });
  tasks.push(initTask);

  // 2. 调用 @nx/node 生成器
  const nodeApplicationTask = await nodeApplicationGenerator(
    tree,
    toNodeApplicationGeneratorOptions(options),
  );
  tasks.push(nodeApplicationTask);

  // 3. 创建 NestJS 特定文件
  createFiles(tree, options);

  // 4. 更新 TypeScript 配置
  updateTsConfig(tree, options);

  // 5. 安装 NestJS 依赖
  if (!options.skipPackageJson) {
    tasks.push(ensureDependencies(tree));
    if (tree.exists(`${options.appProjectRoot}/package.json`)) {
      tasks.push(ensureDependencies(tree, options.appProjectRoot));
    }
  }

  // 6. 格式化
  if (!options.skipFormat) {
    await formatFiles(tree);
  }

  return runTasksInSerial(...tasks);
}
```

### 3.2 normalize-options.ts - 选项标准化

```typescript
// @nx/nest/src/generators/application/lib/normalize-options.ts
import {
  determineProjectNameAndRootOptions,
  ensureRootProjectName,
} from '@nx/devkit/src/generators/project-name-and-root-utils';
import { isUsingTsSolutionSetup } from '@nx/js/src/utils/typescript/ts-solution-setup';

export async function normalizeOptions(
  tree: Tree,
  options: ApplicationGeneratorOptions,
): Promise<NormalizedOptions> {
  // 1. 确保项目名称存在
  await ensureRootProjectName(options, 'application');

  // 2. 计算项目路径
  const { projectName: appProjectName, projectRoot: appProjectRoot } =
    await determineProjectNameAndRootOptions(tree, {
      name: options.name,
      projectType: 'application',
      directory: options.directory,
      rootProject: options.rootProject,
    });

  // 3. 读取 nx.json 配置
  const nxJson = readNxJson(tree);
  const addPlugin =
    process.env.NX_ADD_PLUGINS !== 'false' &&
    nxJson.useInferencePlugins !== false;

  // 4. 返回标准化选项
  return {
    addPlugin,
    ...options,
    strict: options.strict ?? false,
    appProjectName,
    appProjectRoot,
    linter: options.linter ?? 'eslint',
    unitTestRunner: options.unitTestRunner ?? 'jest',
    e2eTestRunner: options.e2eTestRunner ?? 'jest',
    useProjectJson: options.useProjectJson ?? !isUsingTsSolutionSetup(tree),
  };
}

// 转换为 @nx/node 选项
export function toNodeApplicationGeneratorOptions(
  options: NormalizedOptions,
): NodeApplicationGeneratorOptions {
  return {
    name: options.name,
    directory: options.directory,
    frontendProject: options.frontendProject,
    linter: options.linter,
    skipFormat: true,
    skipPackageJson: options.skipPackageJson,
    standaloneConfig: options.standaloneConfig,
    tags: options.tags,
    unitTestRunner: options.unitTestRunner,
    e2eTestRunner: options.e2eTestRunner,
    setParserOptionsProject: options.setParserOptionsProject,
    rootProject: options.rootProject,
    bundler: 'webpack', // 关键：NestJS 必须使用 webpack
    isNest: true, // 关键：标记为 NestJS
    addPlugin: options.addPlugin,
    useProjectJson: options.useProjectJson,
  };
}
```

### 3.3 update-tsconfig.ts - 装饰器配置

```typescript
// @nx/nest/src/generators/application/lib/update-tsconfig.ts
import { joinPathFragments, updateJson } from '@nx/devkit';
import { isUsingTsSolutionSetup } from '@nx/js/src/utils/typescript/ts-solution-setup';

export function updateTsConfig(tree: Tree, options: NormalizedOptions): void {
  // 关键：直接更新 tsconfig.app.json
  updateJson(
    tree,
    joinPathFragments(options.appProjectRoot, 'tsconfig.app.json'),
    (json) => {
      // NestJS 装饰器支持
      json.compilerOptions.experimentalDecorators = true;
      json.compilerOptions.emitDecoratorMetadata = true;
      json.compilerOptions.target = 'es2021';

      // 非 TS solution 使用 node 模块解析
      if (!isUsingTsSolutionSetup(tree)) {
        json.compilerOptions.moduleResolution = 'node';
      }

      // 严格模式
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

  // TS solution 模式下更新 spec 配置
  if (isUsingTsSolutionSetup(tree)) {
    const tsconfigSpecPath = joinPathFragments(
      options.appProjectRoot,
      'tsconfig.spec.json',
    );
    if (tree.exists(tsconfigSpecPath)) {
      updateJson(tree, tsconfigSpecPath, (json) => {
        json.compilerOptions ??= {};
        json.compilerOptions.experimentalDecorators = true;
        json.compilerOptions.emitDecoratorMetadata = true;
        return json;
      });
    }
  }
}
```

### 3.4 ensure-dependencies.ts - 依赖管理

```typescript
// @nx/nest/src/utils/ensure-dependencies.ts
import { addDependenciesToPackageJson, joinPathFragments } from '@nx/devkit';
import {
  nestJsVersion,
  reflectMetadataVersion,
  rxjsVersion,
  tsLibVersion,
} from './versions';

export function ensureDependencies(
  tree: Tree,
  projectRoot?: string,
): GeneratorCallback {
  const packageJsonPath = projectRoot
    ? joinPathFragments(projectRoot, 'package.json')
    : 'package.json';

  return addDependenciesToPackageJson(
    tree,
    // 运行时依赖
    {
      '@nestjs/common': nestJsVersion,
      '@nestjs/core': nestJsVersion,
      '@nestjs/platform-express': nestJsVersion,
      'reflect-metadata': reflectMetadataVersion,
      rxjs: rxjsVersion,
      tslib: tsLibVersion,
    },
    // 开发依赖
    {
      '@nestjs/testing': nestJsVersion,
    },
    packageJsonPath,
  );
}
```

### 3.5 versions.ts - 版本定义

```typescript
// @nx/nest/src/utils/versions.ts
export const nxVersion = require('../../package.json').version;

export const nestJsVersion = '^11.0.0';
export const nestJsSchematicsVersion = '^11.0.0';
export const rxjsVersion = '^7.8.0';
export const reflectMetadataVersion = '^0.1.13';
export const tsLibVersion = '^2.3.0';
```

---

## 4. Target 配置详解

### 4.1 NestJS 项目的 Build Target

NestJS 项目使用特殊的 `nx:run-commands` 执行器：

```typescript
// @nx/node/src/generators/application/lib/create-targets.ts
export function getNestWebpackBuildConfig(
  project: ProjectConfiguration,
): TargetConfiguration {
  return {
    executor: 'nx:run-commands',
    options: {
      command: 'webpack-cli build',
      args: ['--node-env=production'],
      cwd: project.root,
    },
    configurations: {
      development: {
        args: ['--node-env=development'],
      },
    },
  };
}
```

**为什么不用 `@nx/webpack:webpack`？**

1. NestJS 的 webpack.config.js 使用 `@nx/webpack` 的 `composePlugins` 和 `withNx`
2. 这种配置需要 webpack-cli 直接调用，而不是通过执行器
3. 执行器需要 Nx 上下文，而 webpack-cli 独立运行

### 4.2 标准 Node.js 项目的 Build Target

```typescript
// @nx/node/src/generators/application/lib/create-targets.ts
export function getWebpackBuildConfig(
  tree: Tree,
  project: ProjectConfiguration,
  options: NormalizedSchema,
): TargetConfiguration {
  const sourceRoot = getProjectSourceRoot(project, tree);
  return {
    executor: '@nx/webpack:webpack',
    outputs: ['{options.outputPath}'],
    defaultConfiguration: 'production',
    options: {
      target: 'node',
      compiler: 'tsc',
      outputPath: options.outputPath,
      main: joinPathFragments(sourceRoot, 'main.ts'),
      tsConfig: joinPathFragments(options.appProjectRoot, 'tsconfig.app.json'),
      assets: [joinPathFragments(sourceRoot, 'assets')],
      webpackConfig: joinPathFragments(
        options.appProjectRoot,
        'webpack.config.js',
      ),
      generatePackageJson: options.isUsingTsSolutionConfig ? undefined : true,
    },
    configurations: {
      development: { outputHashing: 'none' },
      production: { ...(options.docker && { generateLockfile: true }) },
    },
  };
}
```

### 4.3 Serve Target

```typescript
export function getServeConfig(options: NormalizedSchema): TargetConfiguration {
  return {
    continuous: true,
    executor: '@nx/js:node',
    defaultConfiguration: 'development',
    dependsOn: ['build'],
    options: {
      buildTarget: `${options.name}:build`,
      runBuildTargetDependencies: false,
    },
    configurations: {
      development: { buildTarget: `${options.name}:build:development` },
      production: { buildTarget: `${options.name}:build:production` },
    },
  };
}
```

### 4.4 Prune Targets (用于 Docker)

```typescript
export function getPruneTargets(
  buildTarget: string,
  outputPath: string,
): {
  prune: TargetConfiguration;
  'prune-lockfile': TargetConfiguration;
  'copy-workspace-modules': TargetConfiguration;
} {
  const lockFileName = getLockFileName(detectPackageManager() ?? 'npm');
  return {
    'prune-lockfile': {
      dependsOn: ['build'],
      cache: true,
      executor: '@nx/js:prune-lockfile',
      outputs: [
        `{workspaceRoot}/${joinPathFragments(outputPath, 'package.json')}`,
        `{workspaceRoot}/${joinPathFragments(outputPath, lockFileName)}`,
      ],
      options: { buildTarget },
    },
    'copy-workspace-modules': {
      dependsOn: ['build'],
      cache: true,
      executor: '@nx/js:copy-workspace-modules',
      outputs: [
        `{workspaceRoot}/${joinPathFragments(outputPath, 'workspace_modules')}`,
      ],
      options: { buildTarget },
    },
    prune: {
      dependsOn: ['prune-lockfile', 'copy-workspace-modules'],
      executor: 'nx:noop',
    },
  };
}
```

---

## 5. 依赖管理机制

### 5.1 三层依赖安装

```
@nx/nest:applicationGenerator
    │
    ├── initGenerator()
    │   └── addDependencies()
    │       ├── @nestjs/schematics (devDep)
    │       └── @nx/nest (devDep)
    │
    ├── @nx/node:applicationGenerator
    │   ├── addProjectDependencies()
    │   │   └── (无 NestJS 框架依赖)
    │   │
    │   └── webpackInitGenerator()
    │       └── ensureDependencies()
    │           ├── webpack (devDep)
    │           ├── webpack-cli (devDep)
    │           └── swc-loader (devDep)
    │
    └── ensureDependencies()
        ├── @nestjs/common (dep)
        ├── @nestjs/core (dep)
        ├── @nestjs/platform-express (dep)
        ├── reflect-metadata (dep)
        ├── rxjs (dep)
        ├── tslib (dep)
        └── @nestjs/testing (devDep)
```

### 5.2 initGenerator 的作用

```typescript
// @nx/nest/src/generators/init/init.ts
export async function initGenerator(
  tree: Tree,
  options: InitGeneratorOptions,
): Promise<GeneratorCallback> {
  let installPackagesTask: GeneratorCallback = () => {};
  if (!options.skipPackageJson) {
    installPackagesTask = addDependencies(tree, options);
  }
  return installPackagesTask;
}

// @nx/nest/src/generators/init/lib/add-dependencies.ts
export function addDependencies(
  tree: Tree,
  options: InitGeneratorOptions,
): GeneratorCallback {
  return addDependenciesToPackageJson(
    tree,
    {},
    {
      '@nestjs/schematics': nestJsSchematicsVersion,
      '@nx/nest': nxVersion,
    },
  );
}
```

### 5.3 PM Workspaces 支持

```typescript
// @nx/nest/src/generators/application/application.ts
if (!options.skipPackageJson) {
  // 1. 安装到根 package.json
  tasks.push(ensureDependencies(tree));

  // 2. 如果项目有 package.json (PM Workspaces)，也安装到项目
  if (tree.exists(`${options.appProjectRoot}/package.json`)) {
    tasks.push(ensureDependencies(tree, options.appProjectRoot));
  }
}
```

---

## 6. 实现对比与差异

### 6.1 官方实现 vs 我们的实现

| 方面             | 官方 @nx/nest                         | 我们的 @oksai/generators     |
| ---------------- | ------------------------------------- | ---------------------------- |
| **目录结构**     | `lib/` 分离辅助函数                   | 单文件                       |
| **调用链**       | init → node → create → update → deps  | 直接调用 node                |
| **tsconfig**     | 直接更新 `tsconfig.app.json`          | 更新根 `tsconfig.json`       |
| **build target** | `nx:run-commands` + `webpack-cli`     | 试图用 `@nx/webpack:webpack` |
| **test target**  | 由 @nx/node 配置 Jest                 | 缺失                         |
| **依赖**         | 三层安装 (init + webpack + nest)      | 单层安装                     |
| **选项转换**     | `toNodeApplicationGeneratorOptions()` | 无                           |

### 6.2 关键差异分析

#### 差异 1: tsconfig 更新方式

**官方**:

```typescript
// 直接更新 tsconfig.app.json
updateJson(tree, `${projectRoot}/tsconfig.app.json`, (json) => {
  json.compilerOptions.experimentalDecorators = true;
  json.compilerOptions.emitDecoratorMetadata = true;
});
```

**我们**:

```typescript
// 更新根 tsconfig.json 的 extends
const tsConfig = readJson(tree, `${projectRoot}/tsconfig.json`);
tsConfig.extends = '@oksai/tsconfig/nestjs-esm.json';
writeJson(tree, `${projectRoot}/tsconfig.json`, tsConfig);
```

**问题**: tsconfig.app.json 继承链可能导致装饰器配置丢失。

#### 差异 2: build target 配置

**官方 (NestJS)**:

```json
{
  "build": {
    "executor": "nx:run-commands",
    "options": {
      "command": "webpack-cli build",
      "args": ["--node-env=production"],
      "cwd": "apps/api"
    }
  }
}
```

**我们尝试的**:

```json
{
  "build": {
    "executor": "@nx/webpack:webpack",
    "options": {
      "target": "node",
      "compiler": "swc",
      "outputPath": "dist/apps/api",
      ...
    }
  }
}
```

**问题**: NestJS 的 webpack.config.js 使用 `composePlugins(withNx())`，
这种配置只能通过 webpack-cli 调用，不能通过 `@nx/webpack:webpack` 执行器。

#### 差异 3: isNest 标志

**官方**:

```typescript
// @nx/node 检测 isNest 标志
if (options.isNest) {
  project.targets.build = getNestWebpackBuildConfig(project);
}
```

**我们**:

- 未使用 `isNest: true` 标志
- 导致使用错误的 build target 配置

### 6.3 正确的实现方案

```typescript
// 1. 正确的选项转换
function toNodeApplicationGeneratorOptions(options: NormalizedOptions) {
  return {
    ...options,
    bundler: 'webpack',
    isNest: true, // 关键
    unitTestRunner: 'none', // 我们用 Vitest
    linter: 'none', // 我们用 Biome
  };
}

// 2. 正确的 tsconfig 更新
function updateTsConfig(tree: Tree, options: NormalizedOptions) {
  updateJson(tree, `${options.projectRoot}/tsconfig.app.json`, (json) => {
    json.compilerOptions.experimentalDecorators = true;
    json.compilerOptions.emitDecoratorMetadata = true;
    json.compilerOptions.target = 'es2021';
    return json;
  });
}

// 3. 添加 Vitest target
function addVitestTarget(tree: Tree, options: NormalizedOptions) {
  const project = readProjectConfiguration(tree, options.projectName);
  project.targets.test = {
    executor: '@nx/vitest:vitest',
    outputs: [`coverage/${options.projectRoot}`],
    options: {
      config: `${options.projectRoot}/vitest.config.ts`,
    },
  };
  updateProjectConfiguration(tree, options.projectName, project);
}

// 4. 正确的依赖安装
function ensureDependencies(tree: Tree, projectRoot?: string) {
  return addDependenciesToPackageJson(
    tree,
    {
      '@nestjs/common': '^11.0.0',
      '@nestjs/core': '^11.0.0',
      '@nestjs/platform-express': '^11.0.0',
      'reflect-metadata': '^0.2.0',
      rxjs: '^7.8.0',
    },
    {
      '@nestjs/testing': '^11.0.0',
      vitest: '^4.0.0',
      '@vitest/coverage-v8': '^4.0.0',
      'swc-loader': '^0.2.7',
    },
    projectRoot ? `${projectRoot}/package.json` : undefined,
  );
}
```

---

## 附录

### A. 源码文件索引

| 文件                                                       | 用途              |
| ---------------------------------------------------------- | ----------------- |
| `node/src/generators/application/application.ts`           | Node 应用主入口   |
| `node/src/generators/application/lib/normalize-options.ts` | 选项标准化        |
| `node/src/generators/application/lib/create-targets.ts`    | Target 配置       |
| `node/src/generators/application/lib/create-project.ts`    | 项目创建          |
| `nest/src/generators/application/application.ts`           | NestJS 应用主入口 |
| `nest/src/generators/application/lib/normalize-options.ts` | 选项标准化 + 转换 |
| `nest/src/generators/application/lib/update-tsconfig.ts`   | 装饰器配置        |
| `nest/src/generators/application/lib/create-files.ts`      | 文件生成          |
| `nest/src/utils/ensure-dependencies.ts`                    | 依赖管理          |
| `nest/src/utils/versions.ts`                               | 版本定义          |

### B. 关键 API

```typescript
// 项目名称和路径
import {
  determineProjectNameAndRootOptions,
  ensureRootProjectName,
} from '@nx/devkit/src/generators/project-name-and-root-utils';

// TS solution 检测
import { isUsingTsSolutionSetup } from '@nx/js/src/utils/typescript/ts-solution-setup';

// JSON 更新
import { updateJson, joinPathFragments } from '@nx/devkit';

// 依赖安装
import { addDependenciesToPackageJson } from '@nx/devkit';

// 任务串行
import { runTasksInSerial } from '@nx/devkit';

// 项目配置
import {
  addProjectConfiguration,
  readProjectConfiguration,
  updateProjectConfiguration,
} from '@nx/devkit';
```

---

**文档版本**: 1.0
**最后更新**: 2025-03-13
**源码版本**: Nx 22.5.4
