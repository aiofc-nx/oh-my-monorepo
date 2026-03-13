# Nx 生成器机制深度解析

> 本文档详细阐述 Nx 生成器的核心机制、实现原理以及最佳实践。

## 目录

1. [架构概览](#1-架构概览)
2. [Devkit 核心 API](#2-devkit-核心-api)
3. [Plugin 插件机制](#3-plugin-插件机制)
4. [NestJS 生成器实现](#4-nestjs-生成器实现)
5. [@oksai/generators 问题分析](#5-oksai-generators-问题分析)
6. [修复方案](#6-修复方案)
7. [最佳实践](#7-最佳实践)

---

## 1. 架构概览

### 1.1 整体架构图

```
┌─────────────────────────────────────────────────────────────────────┐
│                          用户命令                                    │
│                   nx generate @org/plugin:generator                 │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│                          Nx CLI                                      │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────────────┐ │
│  │ 解析生成器字符串 │  │ 加载插件配置   │  │ 验证 schema.json      │ │
│  └────────────────┘  └────────────────┘  └────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    generators.json / executors.json                  │
│                                                                      │
│  {                                                                   │
│    "generators": {                                                   │
│      "application": {                                                │
│        "factory": "./src/generators/app#appGenerator",              │
│        "schema": "./src/generators/app/schema.json"                 │
│      }                                                               │
│    }                                                                 │
│  }                                                                   │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│                        @nx/devkit                                    │
│  ┌─────────────────────────────────────────────────────────────────┐│
│  │                         Tree (虚拟文件系统)                       ││
│  │  read() | write() | delete() | exists() | listChanges()        ││
│  └─────────────────────────────────────────────────────────────────┘│
│  ┌───────────────────┐  ┌───────────────────┐  ┌─────────────────┐  │
│  │ generateFiles()   │  │ updateJson()      │  │ formatFiles()   │  │
│  │ (模板生成)         │  │ (JSON 更新)       │  │ (代码格式化)    │  │
│  └───────────────────┘  └───────────────────┘  └─────────────────┘  │
│  ┌───────────────────┐  ┌───────────────────┐  ┌─────────────────┐  │
│  │ addProjectConfig()│  │ runTasksInSerial()│  │ names()         │  │
│  │ (项目配置)         │  │ (回调串行执行)    │  │ (命名转换)      │  │
│  └───────────────────┘  └───────────────────┘  └─────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│                        生成器实现                                    │
│                                                                      │
│  export async function myGenerator(tree: Tree, schema: Schema) {    │
│    // 1. 标准化选项                                                  │
│    const options = await normalizeOptions(tree, schema);            │
│                                                                      │
│    // 2. 调用基础生成器                                              │
│    const baseTask = await baseGenerator(tree, options);             │
│                                                                      │
│    // 3. 创建框架特定文件                                            │
│    createFiles(tree, options);                                       │
│                                                                      │
│    // 4. 更新配置                                                    │
│    updateTsConfig(tree, options);                                    │
│                                                                      │
│    // 5. 安装依赖                                                    │
│    const depsTask = ensureDependencies(tree);                        │
│                                                                      │
│    // 6. 格式化文件                                                  │
│    await formatFiles(tree);                                          │
│                                                                      │
│    // 7. 返回回调链                                                  │
│    return runTasksInSerial(baseTask, depsTask);                     │
│  }                                                                   │
└─────────────────────────────────────────────────────────────────────┘
```

### 1.2 核心概念

| 概念                  | 说明                              | 示例                               |
| --------------------- | --------------------------------- | ---------------------------------- |
| **Tree**              | 虚拟文件系统，记录所有文件变更    | `tree.read()`, `tree.write()`      |
| **Generator**         | 代码生成函数，接收 Tree 和 schema | `async function gen(tree, schema)` |
| **GeneratorCallback** | 生成器完成后执行的回调            | 安装依赖、打印提示                 |
| **Executor**          | 任务执行器，运行构建/测试等       | `@nx/webpack:webpack`              |
| **Target**            | 项目中的可执行目标                | `build`, `test`, `serve`           |

### 1.3 文件变更流程

```
用户执行 nx generate
        │
        ▼
创建 Tree 实例 (内存中的虚拟文件系统)
        │
        ▼
执行生成器函数 (所有文件操作记录在 Tree 中)
        │
        ├── tree.write('file.ts', content)  → 记录 CREATE 操作
        ├── tree.read('existing.ts')        → 读取文件内容
        ├── tree.delete('old.ts')           → 记录 DELETE 操作
        └── updateJson(tree, 'tsconfig.json', ...) → 记录 UPDATE 操作
        │
        ▼
Tree.lock() (锁定，防止后续修改)
        │
        ▼
将变更写入磁盘 (实际文件系统操作)
        │
        ▼
执行 GeneratorCallback (安装依赖等)
```

---

## 2. Devkit 核心 API

### 2.1 Tree - 虚拟文件系统

Tree 是 Nx 的核心抽象，代表一个记录所有变更的虚拟文件系统。

```typescript
interface Tree {
  root: string;

  // 文件读取
  read(filePath: string): Buffer | null;
  read(filePath: string, encoding: BufferEncoding): string | null;

  // 文件写入
  write(
    filePath: string,
    content: Buffer | string,
    options?: TreeWriteOptions,
  ): void;

  // 文件删除
  delete(filePath: string): void;

  // 文件检查
  exists(filePath: string): boolean;
  isFile(filePath: string): boolean;

  // 目录操作
  children(dirPath: string): string[];

  // 重命名
  rename(from: string, to: string): void;

  // 获取变更列表
  listChanges(): FileChange[];

  // 权限修改
  changePermissions(filePath: string, mode: Mode): void;
}

interface FileChange {
  path: string;
  type: 'CREATE' | 'UPDATE' | 'DELETE';
  content: Buffer | null;
}
```

**使用示例**:

```typescript
import { Tree } from '@nx/devkit';

function myGenerator(tree: Tree, schema: any) {
  // 读取现有文件
  const packageJson = tree.read('package.json', 'utf-8');

  // 创建新文件
  tree.write(
    'src/new-file.ts',
    `
    export const hello = "world";
  `,
  );

  // 检查文件是否存在
  if (tree.exists('tsconfig.json')) {
    const tsConfig = tree.read('tsconfig.json', 'utf-8');
  }

  // 删除文件
  tree.delete('old-file.ts');

  // 查看所有变更
  const changes = tree.listChanges();
  console.log(
    `Created ${changes.filter((c) => c.type === 'CREATE').length} files`,
  );
}
```

### 2.2 文件生成 - generateFiles

从模板目录生成文件，支持 EJS 模板语法和文件名替换。

```typescript
function generateFiles(
  tree: Tree,
  srcFolder: string, // 模板目录（绝对路径）
  target: string, // 目标目录（相对于 tree root）
  substitutions: Record<string, any>, // 替换变量
  options?: GenerateFilesOptions,
): void;

interface GenerateFilesOptions {
  overwriteStrategy?: 'overwrite' | 'keepExisting' | 'throwIfExisting';
}
```

**模板命名约定**:

| 模板文件名                         | 生成文件名               | 说明                         |
| ---------------------------------- | ------------------------ | ---------------------------- |
| `__name__.ts__tmpl__`              | `my-component.ts`        | `__name__` 被替换为 fileName |
| `__className__.service.ts__tmpl__` | `MyComponent.service.ts` | 使用 className 格式          |
| `index.ts__tmpl__`                 | `index.ts`               | `__tmpl__` 后缀被移除        |

**模板语法**:

```typescript
// 模板文件: __name__.controller.ts__tmpl__
import { Controller } from '@nestjs/common';

@Controller('<%= propertyName %>')
export class <%= className %>Controller {
  // <%= constantName %> constant
}
```

**使用示例**:

```typescript
import { generateFiles, names } from '@nx/devkit';
import * as path from 'path';

function createFiles(tree: Tree, options: { name: string }) {
  // names() 生成各种命名格式
  const projectName = names(options.name);
  // {
  //   name: 'my-component',
  //   className: 'MyComponent',
  //   propertyName: 'myComponent',
  //   constantName: 'MY_COMPONENT',
  //   fileName: 'my-component'
  // }

  generateFiles(
    tree,
    path.join(__dirname, 'files'), // 模板目录
    'libs/my-lib', // 目标目录
    {
      ...projectName,
      tmpl: '', // 用于移除 __tmpl__ 后缀
      customVariable: 'value',
    },
  );
}
```

### 2.3 JSON 操作

```typescript
// 读取 JSON 文件
function readJson<T extends object = any>(
  tree: Tree,
  path: string,
  options?: JsonParseOptions,
): T;

// 写入 JSON 文件
function writeJson<T extends object = object>(
  tree: Tree,
  path: string,
  value: T,
  options?: JsonSerializeOptions,
): void;

// 更新 JSON 文件
function updateJson<T extends object = any, U extends object = T>(
  tree: Tree,
  path: string,
  updater: (value: T) => U,
  options?: JsonParseOptions & JsonSerializeOptions,
): void;
```

**使用示例**:

```typescript
import { readJson, writeJson, updateJson, joinPathFragments } from '@nx/devkit';

function configureProject(tree: Tree, projectRoot: string) {
  // 读取 tsconfig.json
  const tsConfig = readJson(
    tree,
    joinPathFragments(projectRoot, 'tsconfig.json'),
    {
      expectComments: true, // 支持 JSON 注释
    },
  );

  // 更新 tsconfig.app.json
  updateJson(
    tree,
    joinPathFragments(projectRoot, 'tsconfig.app.json'),
    (json) => {
      json.compilerOptions = {
        ...json.compilerOptions,
        experimentalDecorators: true,
        emitDecoratorMetadata: true,
        target: 'es2021',
      };
      return json;
    },
  );

  // 写入新文件
  writeJson(tree, `${projectRoot}/my-config.json`, {
    setting1: 'value1',
    setting2: 'value2',
  });
}
```

### 2.4 项目配置

```typescript
interface ProjectConfiguration {
  name?: string;
  root: string;
  sourceRoot?: string;
  projectType?: 'library' | 'application';
  targets?: Record<string, TargetConfiguration>;
  tags?: string[];
  implicitDependencies?: string[];
  namedInputs?: Record<string, (string | InputDefinition)[]>;
  metadata?: ProjectMetadata;
}

interface TargetConfiguration<T = any> {
  executor?: string; // 执行器，如 '@nx/webpack:webpack'
  command?: string; // 简单命令（替代 executor）
  outputs?: string[]; // 输出路径
  inputs?: (InputDefinition | string)[];
  dependsOn?: (TargetDependencyConfig | string)[];
  options?: T; // 目标选项
  configurations?: Record<string, any>;
  defaultConfiguration?: string;
  cache?: boolean; // 是否缓存
  parallelism?: boolean; // 是否并行执行
  continuous?: boolean; // 是否持续运行（如 serve）
}
```

**操作函数**:

```typescript
// 添加项目配置
function addProjectConfiguration(
  tree: Tree,
  projectName: string,
  projectConfiguration: ProjectConfiguration,
  standalone?: boolean,
): void;

// 读取项目配置
function readProjectConfiguration(
  tree: Tree,
  projectName: string,
): ProjectConfiguration;

// 更新项目配置
function updateProjectConfiguration(
  tree: Tree,
  projectName: string,
  projectConfiguration: ProjectConfiguration,
): void;

// 删除项目配置
function removeProjectConfiguration(tree: Tree, projectName: string): void;

// 获取所有项目
function getProjects(tree: Tree): Map<string, ProjectConfiguration>;
```

**使用示例**:

```typescript
import {
  addProjectConfiguration,
  readProjectConfiguration,
  updateProjectConfiguration,
  joinPathFragments,
} from '@nx/devkit';

function createNestApp(tree: Tree, options: { name: string }) {
  const projectRoot = `apps/${options.name}`;

  // 方式 1: 直接添加项目
  addProjectConfiguration(tree, options.name, {
    root: projectRoot,
    sourceRoot: `${projectRoot}/src`,
    projectType: 'application',
    targets: {
      build: {
        executor: '@nx/webpack:webpack',
        outputs: ['{options.outputPath}'],
        options: {
          outputPath: `dist/${projectRoot}`,
          main: `${projectRoot}/src/main.ts`,
          tsConfig: `${projectRoot}/tsconfig.app.json`,
          webpackConfig: `${projectRoot}/webpack.config.js`,
        },
      },
      serve: {
        executor: '@nx/js:node',
        continuous: true,
        dependsOn: ['build'],
        options: {
          buildTarget: `${options.name}:build`,
        },
      },
    },
    tags: ['type:app', 'framework:nest'],
  });

  // 方式 2: 更新现有项目
  const project = readProjectConfiguration(tree, options.name);
  project.targets.test = {
    executor: '@nx/jest:jest',
    outputs: [`coverage/${projectRoot}`],
    options: {
      jestConfig: `${projectRoot}/jest.config.ts`,
    },
  };
  updateProjectConfiguration(tree, options.name, project);
}
```

### 2.5 命名工具

```typescript
function names(name: string): {
  name: string; // 原始名称: 'my-awesome-lib'
  className: string; // PascalCase: 'MyAwesomeLib'
  propertyName: string; // camelCase: 'myAwesomeLib'
  constantName: string; // UPPER_SNAKE_CASE: 'MY_AWESOME_LIB'
  fileName: string; // kebab-case: 'my-awesome-lib'
};
```

**使用示例**:

```typescript
import { names, generateFiles } from '@nx/devkit';
import * as path from 'path';

function createComponent(tree: Tree, componentName: string) {
  const { className, propertyName, fileName } = names(componentName);

  generateFiles(tree, path.join(__dirname, 'files'), 'src/components', {
    className, // MyComponent
    propertyName, // myComponent
    fileName, // my-component
    tmpl: '',
  });
}
```

### 2.6 依赖管理

```typescript
function addDependenciesToPackageJson(
  tree: Tree,
  dependencies: Record<string, string>,
  devDependencies: Record<string, string>,
  packageJsonPath?: string,
  keepExistingVersions?: boolean,
): GeneratorCallback;
```

**使用示例**:

```typescript
import { addDependenciesToPackageJson, runTasksInSerial } from '@nx/devkit';

export default function myGenerator(tree: Tree): GeneratorCallback {
  // 添加到根 package.json
  const rootDeps = addDependenciesToPackageJson(
    tree,
    // 运行时依赖
    {
      '@nestjs/common': '^11.0.0',
      '@nestjs/core': '^11.0.0',
      'reflect-metadata': '^0.2.0',
    },
    // 开发依赖
    {
      '@nestjs/testing': '^11.0.0',
      '@types/node': '^20.0.0',
    },
  );

  // 添加到项目级 package.json (PM Workspaces)
  const projectDeps = addDependenciesToPackageJson(
    tree,
    { lodash: '^4.17.21' },
    {},
    'libs/my-lib/package.json',
  );

  // 串行执行所有安装
  return runTasksInSerial(rootDeps, projectDeps);
}
```

### 2.7 回调组合 - runTasksInSerial

```typescript
function runTasksInSerial(
  ...tasks: (GeneratorCallback | undefined | null)[]
): GeneratorCallback;

type GeneratorCallback = () => void | Promise<void>;
```

**使用示例**:

```typescript
import { runTasksInSerial, addDependenciesToPackageJson } from '@nx/devkit';

export default async function myGenerator(tree: Tree, schema: Schema) {
  const tasks: GeneratorCallback[] = [];

  // 1. 安装 React
  tasks.push(
    addDependenciesToPackageJson(
      tree,
      { react: '^18.0.0', 'react-dom': '^18.0.0' },
      {},
    ),
  );

  // 2. 安装测试库
  tasks.push(
    addDependenciesToPackageJson(
      tree,
      {},
      { '@testing-library/react': '^14.0.0' },
    ),
  );

  // 3. 其他初始化
  tasks.push(await initGenerator(tree, schema));

  // 串行执行所有回调
  return runTasksInSerial(...tasks);
}
```

### 2.8 格式化 - formatFiles

```typescript
async function formatFiles(
  tree: Tree,
  options?: {
    sortRootTsconfigPaths?: boolean;
  },
): Promise<void>;
```

**使用示例**:

```typescript
import { formatFiles, Tree } from '@nx/devkit';

export default async function myGenerator(tree: Tree, schema: Schema) {
  // 创建/修改文件...

  // 格式化所有变更的文件
  if (!schema.skipFormat) {
    await formatFiles(tree, {
      sortRootTsconfigPaths: true,
    });
  }
}
```

---

## 3. Plugin 插件机制

### 3.1 插件目录结构

```
packages/my-plugin/
├── package.json           # 包配置，定义入口点
├── generators.json        # 生成器注册
├── executors.json         # 执行器注册（可选）
├── migrations.json        # 迁移脚本（可选）
├── src/
│   ├── generators/
│   │   ├── application/
│   │   │   ├── application.ts    # 生成器实现
│   │   │   ├── schema.json       # JSON Schema
│   │   │   ├── schema.d.ts       # TypeScript 类型
│   │   │   ├── lib/              # 辅助函数
│   │   │   └── files/            # 模板文件
│   │   └── library/
│   ├── executors/
│   │   └── my-executor/
│   │       ├── executor.ts
│   │       └── schema.json
│   └── index.ts           # 公共 API 导出
└── README.md
```

### 3.2 package.json 配置

```json
{
  "name": "@myorg/my-plugin",
  "version": "1.0.0",
  "main": "./index.js",
  "types": "./index.d.ts",
  "generators": "./generators.json",
  "executors": "./executors.json",
  "nx-migrations": "./migrations.json",
  "dependencies": {
    "@nx/devkit": "^22.0.0"
  }
}
```

**入口点字段**:

| 字段            | 说明       | 别名（向后兼容） |
| --------------- | ---------- | ---------------- |
| `generators`    | 生成器配置 | `schematics`     |
| `executors`     | 执行器配置 | `builders`       |
| `nx-migrations` | 迁移配置   | `ng-update`      |

### 3.3 generators.json 配置

```json
{
  "name": "@myorg/my-plugin",
  "version": "0.1",
  "extends": ["@nx/workspace"],
  "generators": {
    "application": {
      "factory": "./src/generators/application/application#applicationGenerator",
      "schema": "./src/generators/application/schema.json",
      "aliases": ["app"],
      "description": "Create a new application",
      "x-type": "application"
    },
    "library": {
      "factory": "./src/generators/library/library",
      "schema": "./src/generators/library/schema.json",
      "aliases": ["lib"],
      "description": "Create a new library",
      "x-type": "library"
    },
    "init": {
      "factory": "./src/generators/init/init",
      "schema": "./src/generators/init/schema.json",
      "hidden": true
    }
  }
}
```

**配置字段说明**:

| 字段           | 类型     | 必填 | 说明                              |
| -------------- | -------- | ---- | --------------------------------- |
| `factory`      | string   | ✅   | 工厂函数路径，格式: `路径#导出名` |
| `schema`       | string   | ✅   | JSON Schema 文件路径              |
| `aliases`      | string[] | ❌   | CLI 别名                          |
| `description`  | string   | ❌   | 生成器描述                        |
| `hidden`       | boolean  | ❌   | 是否隐藏（内部使用）              |
| `x-type`       | string   | ❌   | 项目类型 (application/library)    |
| `x-deprecated` | string   | ❌   | 废弃提示信息                      |

### 3.4 executors.json 配置

```json
{
  "executors": {
    "build": {
      "implementation": "./src/executors/build/build.impl",
      "batchImplementation": "./src/executors/build/build.batch-impl",
      "schema": "./src/executors/build/schema.json",
      "description": "Build a project"
    },
    "serve": {
      "implementation": "./src/executors/serve/serve.impl",
      "schema": "./src/executors/serve/schema.json",
      "description": "Serve a project"
    }
  }
}
```

**配置字段说明**:

| 字段                  | 类型    | 必填 | 说明                 |
| --------------------- | ------- | ---- | -------------------- |
| `implementation`      | string  | ✅   | 实现文件路径         |
| `schema`              | string  | ✅   | JSON Schema 文件路径 |
| `batchImplementation` | string  | ❌   | 批量实现路径         |
| `preferBatch`         | boolean | ❌   | 是否优先使用批量实现 |
| `description`         | string  | ❌   | 执行器描述           |
| `hasher`              | string  | ❌   | 自定义哈希函数路径   |

### 3.5 schema.json 格式

```json
{
  "$schema": "https://json-schema.org/schema",
  "cli": "nx",
  "$id": "ApplicationGenerator",
  "title": "Application Generator",
  "description": "Create a new application",
  "type": "object",
  "properties": {
    "name": {
      "type": "string",
      "description": "The name of the application",
      "$default": {
        "$source": "argv",
        "index": 0
      },
      "x-prompt": "What name would you like to use?",
      "x-priority": "important"
    },
    "directory": {
      "type": "string",
      "description": "The directory to create the application in"
    },
    "tags": {
      "type": "string",
      "description": "Comma-separated list of tags"
    },
    "skipFormat": {
      "type": "boolean",
      "description": "Skip formatting files",
      "default": false
    }
  },
  "required": ["name"],
  "additionalProperties": false
}
```

**特殊字段**:

| 字段               | 说明                                             |
| ------------------ | ------------------------------------------------ |
| `$default.$source` | 默认值来源：`argv` (命令行参数)                  |
| `$default.index`   | 参数索引位置                                     |
| `x-prompt`         | 交互式提示文本                                   |
| `x-priority`       | 字段优先级：`important`, `internal`, `dependent` |

### 3.6 执行器实现

```typescript
import { PromiseExecutor } from '@nx/devkit';

interface MyExecutorSchema {
  outputPath: string;
  main: string;
}

const runExecutor: PromiseExecutor<MyExecutorSchema> = async (
  options,
  context,
) => {
  console.log('Building project:', context.projectName);
  console.log('Output path:', options.outputPath);

  // 执行构建逻辑...

  return {
    success: true,
    // 可选的终端输出
    stdout: 'Build completed successfully',
    // 可选的输出路径
    outputPath: options.outputPath,
  };
};

export default runExecutor;
```

---

## 4. NestJS 生成器实现

### 4.1 官方 @nx/nest 架构

```
@nx/nest
    │
    ├── application 生成器
    │   │
    │   ├── initGenerator()         # 安装 @nx/nest 依赖
    │   │
    │   ├── @nx/node:application    # 创建基础项目
    │   │   └── bundler: 'webpack'
    │   │   └── isNest: true
    │   │
    │   ├── createFiles()           # 创建 NestJS 文件
    │   │   └── main.ts
    │   │   └── app.module.ts
    │   │   └── app.controller.ts
    │   │   └── app.service.ts
    │   │
    │   ├── updateTsConfig()        # 启用装饰器
    │   │   └── experimentalDecorators: true
    │   │   └── emitDecoratorMetadata: true
    │   │
    │   └── ensureDependencies()    # 安装 NestJS 依赖
    │       └── @nestjs/common
    │       └── @nestjs/core
    │       └── @nestjs/platform-express
    │       └── reflect-metadata
    │       └── rxjs
    │
    ├── library 生成器
    │   │
    │   ├── @nx/js:library          # 创建基础库
    │   │
    │   ├── createFiles()           # 创建 NestJS 库文件
    │   │
    │   ├── updateTsConfig()        # 启用装饰器
    │   │
    │   └── addProject()            # 添加 build target
    │
    └── 子生成器 (controller, service, module, etc.)
        │
        └── @nestjs/schematics      # 包装 NestJS 官方 schematics
```

### 4.2 Application 生成器实现

**主入口**:

```typescript
// src/generators/application/application.ts
import type { GeneratorCallback, Tree } from '@nx/devkit';
import { formatFiles, runTasksInSerial } from '@nx/devkit';
import { applicationGenerator as nodeApplicationGenerator } from '@nx/node';
import { initGenerator } from '../init/init';
import { ensureDependencies } from '../../utils/ensure-dependencies';
import {
  createFiles,
  normalizeOptions,
  toNodeApplicationGeneratorOptions,
  updateTsConfig,
} from './lib';

export async function applicationGenerator(
  tree: Tree,
  rawOptions: ApplicationGeneratorOptions,
): Promise<GeneratorCallback> {
  return applicationGeneratorInternal(tree, {
    addPlugin: false,
    useProjectJson: true,
    ...rawOptions,
  });
}

export async function applicationGeneratorInternal(
  tree: Tree,
  rawOptions: ApplicationGeneratorOptions,
): Promise<GeneratorCallback> {
  const options = await normalizeOptions(tree, rawOptions);
  const tasks: GeneratorCallback[] = [];

  // 1. 初始化依赖
  const initTask = await initGenerator(tree, {
    skipPackageJson: options.skipPackageJson,
    skipFormat: true,
  });
  tasks.push(initTask);

  // 2. 调用 @nx/node 应用生成器
  const nodeTask = await nodeApplicationGenerator(
    tree,
    toNodeApplicationGeneratorOptions(options),
  );
  tasks.push(nodeTask);

  // 3. 创建 NestJS 特定文件
  createFiles(tree, options);

  // 4. 更新 TypeScript 配置
  updateTsConfig(tree, options);

  // 5. 安装依赖
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

**选项标准化**:

```typescript
// src/generators/application/lib/normalize-options.ts
import {
  determineProjectNameAndRootOptions,
  ensureRootProjectName,
} from '@nx/devkit/src/generators/project-name-and-root-utils';

export async function normalizeOptions(
  tree: Tree,
  options: ApplicationGeneratorOptions,
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
    appProjectName: projectName,
    appProjectRoot: projectRoot,
    linter: options.linter ?? 'eslint',
    unitTestRunner: options.unitTestRunner ?? 'jest',
  };
}

export function toNodeApplicationGeneratorOptions(options: NormalizedOptions) {
  return {
    name: options.name,
    directory: options.directory,
    bundler: 'webpack', // NestJS 需要 webpack 插件
    isNest: true, // 标记为 NestJS 项目
    unitTestRunner: options.unitTestRunner,
    linter: options.linter,
    skipFormat: true,
  };
}
```

**TypeScript 配置更新**:

```typescript
// src/generators/application/lib/update-tsconfig.ts
import { joinPathFragments, updateJson } from '@nx/devkit';

export function updateTsConfig(tree: Tree, options: NormalizedOptions): void {
  updateJson(
    tree,
    joinPathFragments(options.appProjectRoot, 'tsconfig.app.json'),
    (json) => {
      // NestJS 装饰器支持
      json.compilerOptions.experimentalDecorators = true;
      json.compilerOptions.emitDecoratorMetadata = true;
      json.compilerOptions.target = 'es2021';
      json.compilerOptions.moduleResolution = 'node';

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
}
```

### 4.3 依赖管理

```typescript
// src/utils/versions.ts
export const nxVersion = require('../../package.json').version;

export const nestJsVersion = '^11.0.0';
export const nestJsSchematicsVersion = '^11.0.0';
export const rxjsVersion = '^7.8.0';
export const reflectMetadataVersion = '^0.1.13';

// src/utils/ensure-dependencies.ts
import { addDependenciesToPackageJson, joinPathFragments } from '@nx/devkit';
import { nestJsVersion, reflectMetadataVersion, rxjsVersion } from './versions';

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
    },
    // 开发依赖
    {
      '@nestjs/testing': nestJsVersion,
    },
    packageJsonPath,
  );
}
```

### 4.4 project.json 目标配置

**Webpack 构建 (官方方式 1)**:

```json
{
  "targets": {
    "build": {
      "executor": "nx:run-commands",
      "options": {
        "command": "webpack-cli build",
        "args": ["--node-env=production"],
        "cwd": "apps/api"
      },
      "configurations": {
        "development": {
          "args": ["--node-env=development"]
        }
      }
    }
  }
}
```

**Webpack 构建 (官方方式 2)**:

```json
{
  "targets": {
    "build": {
      "executor": "@nx/webpack:webpack",
      "outputs": ["{options.outputPath}"],
      "defaultConfiguration": "production",
      "options": {
        "target": "node",
        "compiler": "tsc",
        "outputPath": "dist/apps/api",
        "main": "apps/api/src/main.ts",
        "tsConfig": "apps/api/tsconfig.app.json",
        "webpackConfig": "apps/api/webpack.config.js",
        "assets": ["apps/api/src/assets"]
      },
      "configurations": {
        "development": {
          "outputHashing": "none"
        },
        "production": {}
      }
    }
  }
}
```

**服务运行**:

```json
{
  "targets": {
    "serve": {
      "executor": "@nx/js:node",
      "continuous": true,
      "defaultConfiguration": "development",
      "dependsOn": ["build"],
      "options": {
        "buildTarget": "api:build",
        "runBuildTargetDependencies": false
      },
      "configurations": {
        "development": {
          "buildTarget": "api:build:development"
        },
        "production": {
          "buildTarget": "api:build:production"
        }
      }
    }
  }
}
```

---

## 5. @oksai/generators 问题分析

### 5.1 当前实现

```typescript
// tools/generators/src/nestjs-app/index.ts
export async function nestjsAppGeneratorInternal(
  tree: Tree,
  rawOptions: NestjsAppGeneratorSchema,
): Promise<GeneratorCallback> {
  const options = await normalizeOptions(tree, rawOptions);
  const tasks: GeneratorCallback[] = [];

  // 1. 调用 @nx/node 生成器
  const appTask = await applicationGenerator(tree, {
    name: options.projectName,
    directory: options.appProjectRoot,
    framework: 'nest',
    bundler: 'webpack',
    unitTestRunner: 'none',
    linter: 'none',
    tags: options.tags,
    skipFormat: true,
  });
  tasks.push(appTask);

  // 2. 更新 tsconfig
  updateTsConfig(tree, options);

  // 3. 更新 project.json (空实现!)
  updateProjectJson(tree, options);

  // 4. 创建文件
  createFiles(tree, options);

  // 5. 添加依赖
  if (!options.skipPackageJson) {
    const depsTask = addDependenciesToPackageJson(
      tree,
      {},
      {
        vitest: '^2.0.0',
        '@vitest/coverage-v8': '^2.0.0',
      },
    );
    if (depsTask) tasks.push(depsTask);
  }

  await formatFiles(tree);
  return runTasksInSerial(...tasks);
}
```

### 5.2 问题清单

| #   | 问题                              | 原因                                                          | 影响                                | 严重性 |
| --- | --------------------------------- | ------------------------------------------------------------- | ----------------------------------- | ------ |
| 1   | **vitest.config.ts 使用错误 API** | 模板使用 `defineVitestConfig` 从 `@nx/vitest`，但该导出不存在 | 构建报错 `TS2305`                   | 🔴 高  |
| 2   | **tsconfig 装饰器配置缺失**       | 只更新根 tsconfig.json，未更新 tsconfig.app.json              | 装饰器报错 `TS1241`                 | 🔴 高  |
| 3   | **project.json 未修复**           | `updateProjectJson()` 是空实现                                | 使用错误的 `nx:run-commands` 执行器 | 🔴 高  |
| 4   | **缺少 swc-loader 依赖**          | 未添加 webpack SWC 加载器                                     | 构建失败 "Missing SWC dependencies" | 🔴 高  |
| 5   | **缺少 test target**              | 创建了 vitest.config.ts 但未添加 test 任务                    | `nx test api` 不可用                | 🟡 中  |
| 6   | **vitest 版本不匹配**             | 模板使用 `^2.0.0`，工作区使用 `^4.0.18`                       | 潜在兼容性问题                      | 🟢 低  |

### 5.3 详细分析

#### 问题 1: vitest.config.ts

**当前模板**:

```typescript
// tools/generators/src/nestjs-app/files/vitest.config.ts__tmpl__
import { defineVitestConfig } from '@nx/vitest'; // ❌ 不存在

export default defineVitestConfig({
  test: {
    globals: true,
    environment: 'node',
    include: ['src/**/*.spec.ts'],
  },
});
```

**正确实现**:

```typescript
import { defineConfig } from 'vitest/config'; // ✅ 使用 vitest 原生 API

export default defineConfig({
  test: {
    globals: true,
    environment: 'node',
    include: ['src/**/*.spec.ts'],
  },
});
```

#### 问题 2: tsconfig 装饰器配置

**当前实现**:

```typescript
function updateTsConfig(tree: Tree, options: NormalizedOptions) {
  const tsConfigPath = joinPathFragments(
    options.appProjectRoot,
    'tsconfig.json',
  );

  const tsConfig = readJson(tree, tsConfigPath);
  tsConfig.extends = '@oksai/tsconfig/nestjs-esm.json'; // ❌ 继承链问题
  writeJson(tree, tsConfigPath, tsConfig);
}
```

**问题**: tsconfig.app.json 继承 tsconfig.json，但装饰器配置可能在继承链中丢失。

**正确实现**:

```typescript
function updateTsConfig(tree: Tree, options: NormalizedOptions) {
  // 直接更新 tsconfig.app.json
  updateJson(
    tree,
    joinPathFragments(options.appProjectRoot, 'tsconfig.app.json'),
    (json) => {
      json.compilerOptions = {
        ...json.compilerOptions,
        experimentalDecorators: true,
        emitDecoratorMetadata: true,
        target: 'es2021',
      };
      return json;
    },
  );
}
```

#### 问题 3: project.json 配置

**当前生成的配置**:

```json
{
  "targets": {
    "build": {
      "executor": "nx:run-commands",
      "options": {
        "command": "webpack-cli build",
        "args": ["--node-env=production"],
        "cwd": "apps/api"
      }
    }
  }
}
```

**问题**: webpack-cli 无法找到 Nx 上下文，导致 `ensureNxWebpackExecutionContext` 失败。

**正确配置**:

```typescript
function updateProjectJson(tree: Tree, options: NormalizedOptions) {
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

#### 问题 4: 缺少依赖

**当前依赖**:

```typescript
addDependenciesToPackageJson(
  tree,
  {},
  {
    vitest: '^2.0.0',
    '@vitest/coverage-v8': '^2.0.0',
  },
);
```

**缺少的依赖**:

```typescript
addDependenciesToPackageJson(
  tree,
  {},
  {
    vitest: '^4.0.0',
    '@vitest/coverage-v8': '^4.0.0',
    'swc-loader': '^0.2.7', // ❌ 缺少
  },
);
```

---

## 6. 修复方案

### 6.1 方案 A: 修复现有生成器

**修改文件列表**:

| 文件                                                             | 修改内容                                         |
| ---------------------------------------------------------------- | ------------------------------------------------ |
| `tools/generators/src/nestjs-app/index.ts`                       | 修复 `updateTsConfig()` 和 `updateProjectJson()` |
| `tools/generators/src/nestjs-app/files/vitest.config.ts__tmpl__` | 使用 `vitest/config` API                         |
| `tools/generators/src/nestjs-app/lib/update-tsconfig.ts`         | 新增，直接更新 tsconfig.app.json                 |
| `tools/generators/src/nestjs-app/lib/update-project.ts`          | 新增，修复 build/test target                     |

**实现代码**:

```typescript
// tools/generators/src/nestjs-app/lib/update-tsconfig.ts
import { joinPathFragments, updateJson, Tree } from '@nx/devkit';
import type { NormalizedOptions } from '../schema';

export function updateTsConfig(tree: Tree, options: NormalizedOptions): void {
  // 更新 tsconfig.app.json
  updateJson(
    tree,
    joinPathFragments(options.appProjectRoot, 'tsconfig.app.json'),
    (json) => {
      json.compilerOptions = {
        ...json.compilerOptions,
        experimentalDecorators: true,
        emitDecoratorMetadata: true,
        target: 'es2021',
        moduleResolution: 'node',
      };
      return json;
    },
  );

  // 更新 tsconfig.spec.json (如果存在)
  const specConfigPath = joinPathFragments(
    options.appProjectRoot,
    'tsconfig.spec.json',
  );
  if (tree.exists(specConfigPath)) {
    updateJson(tree, specConfigPath, (json) => {
      json.compilerOptions ??= {};
      json.compilerOptions.experimentalDecorators = true;
      json.compilerOptions.emitDecoratorMetadata = true;
      return json;
    });
  }
}
```

```typescript
// tools/generators/src/nestjs-app/lib/update-project.ts
import {
  joinPathFragments,
  readProjectConfiguration,
  updateProjectConfiguration,
  Tree,
} from '@nx/devkit';
import type { NormalizedOptions } from '../schema';

export function updateProject(tree: Tree, options: NormalizedOptions): void {
  const project = readProjectConfiguration(tree, options.projectName);

  // 修复 build target
  project.targets.build = {
    executor: '@nx/webpack:webpack',
    outputs: ['{options.outputPath}'],
    defaultConfiguration: 'production',
    options: {
      target: 'node',
      compiler: 'swc',
      outputPath: `dist/${options.appProjectRoot}`,
      main: joinPathFragments(options.appProjectRoot, 'src/main.ts'),
      tsConfig: joinPathFragments(options.appProjectRoot, 'tsconfig.app.json'),
      webpackConfig: joinPathFragments(
        options.appProjectRoot,
        'webpack.config.js',
      ),
      assets: [joinPathFragments(options.appProjectRoot, 'src/assets')],
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
    outputs: [`{workspaceRoot}/coverage/${options.appProjectRoot}`],
    options: {
      config: joinPathFragments(options.appProjectRoot, 'vitest.config.ts'),
    },
  };

  updateProjectConfiguration(tree, options.projectName, project);
}
```

```typescript
// tools/generators/src/nestjs-app/files/vitest.config.ts__tmpl__
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

```typescript
// tools/generators/src/nestjs-app/index.ts (更新后的主入口)
import {
  Tree,
  formatFiles,
  runTasksInSerial,
  addDependenciesToPackageJson,
  readProjectConfiguration,
  updateProjectConfiguration,
  updateJson,
  joinPathFragments,
} from '@nx/devkit';
import { applicationGenerator } from '@nx/node';
import type { NestjsAppGeneratorSchema } from './schema';
import { normalizeOptions } from './lib/normalize-options';
import { updateTsConfig } from './lib/update-tsconfig';
import { updateProject } from './lib/update-project';
import { createFiles } from './lib/create-files';

export async function nestjsAppGeneratorInternal(
  tree: Tree,
  rawOptions: NestjsAppGeneratorSchema,
): Promise<GeneratorCallback> {
  const options = await normalizeOptions(tree, rawOptions);
  const tasks: GeneratorCallback[] = [];

  // 1. 调用 @nx/node 生成器
  const appTask = await applicationGenerator(tree, {
    name: options.projectName,
    directory: options.appProjectRoot,
    framework: 'nest',
    bundler: 'webpack',
    unitTestRunner: 'none',
    linter: 'none',
    tags: options.tags,
    skipFormat: true,
  });
  tasks.push(appTask);

  // 2. 更新 TypeScript 配置（装饰器支持）
  updateTsConfig(tree, options);

  // 3. 更新 project.json（build/test target）
  updateProject(tree, options);

  // 4. 创建自定义文件（vitest.config.ts）
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

  // 6. 格式化文件
  if (!options.skipFormat) {
    await formatFiles(tree);
  }

  return runTasksInSerial(...tasks);
}
```

### 6.2 方案 B: 复制官方 @nx/nest 并定制

**步骤**:

1. 复制官方包:

```bash
cp -r /home/arligle/forks/nx/packages/nest packages/nest
```

2. 修改 package.json:

```json
{
  "name": "@oksai/nest",
  "version": "0.0.1",
  "main": "./index.js",
  "types": "./index.d.ts",
  "generators": "./generators.json"
}
```

3. 定制修改:
   - 替换 Jest → Vitest
   - 替换 ESLint → Biome
   - 更新模板文件

**对比**:

| 方面           | 方案 A (修复) | 方案 B (复制)        |
| -------------- | ------------- | -------------------- |
| **工作量**     | 小            | 大                   |
| **维护成本**   | 低            | 高                   |
| **功能完整性** | 基础          | 完整（包含子生成器） |
| **与官方同步** | 容易          | 困难                 |
| **定制灵活性** | 中            | 高                   |

### 6.3 推荐方案

**短期**: 使用方案 A 修复现有生成器

**长期**: 考虑创建 `@oksai/nest` 插件，提供完整的 NestJS 生成器支持

---

## 7. 最佳实践

### 7.1 生成器设计原则

1. **单一职责**: 每个生成器只做一件事
2. **可组合性**: 生成器之间可以相互调用
3. **幂等性**: 多次运行产生相同结果
4. **可测试性**: 所有逻辑可单元测试

### 7.2 代码组织

```
generators/
├── application/
│   ├── application.ts          # 主入口
│   ├── schema.json             # JSON Schema
│   ├── schema.d.ts             # TypeScript 类型
│   ├── lib/
│   │   ├── index.ts            # 导出
│   │   ├── normalize-options.ts
│   │   ├── create-files.ts
│   │   ├── update-tsconfig.ts
│   │   └── update-project.ts
│   └── files/
│       ├── main.ts__tmpl__
│       └── app/
│           ├── app.module.ts__tmpl__
│           └── app.controller.ts__tmpl__
└── library/
    └── ...
```

### 7.3 测试策略

```typescript
import { createTreeWithEmptyWorkspace } from '@nx/devkit/testing';
import applicationGenerator from './application';

describe('application generator', () => {
  it('should create project with correct targets', async () => {
    const tree = createTreeWithEmptyWorkspace();

    await applicationGenerator(tree, { name: 'api' });

    const project = readProjectConfiguration(tree, 'api');

    expect(project.targets.build.executor).toBe('@nx/webpack:webpack');
    expect(project.targets.test.executor).toBe('@nx/vitest:vitest');
  });

  it('should enable decorators in tsconfig', async () => {
    const tree = createTreeWithEmptyWorkspace();

    await applicationGenerator(tree, { name: 'api' });

    const tsConfig = readJson(tree, 'apps/api/tsconfig.app.json');

    expect(tsConfig.compilerOptions.experimentalDecorators).toBe(true);
    expect(tsConfig.compilerOptions.emitDecoratorMetadata).toBe(true);
  });
});
```

### 7.4 错误处理

```typescript
export async function myGenerator(tree: Tree, schema: Schema) {
  // 验证输入
  if (!schema.name) {
    throw new Error('Name is required');
  }

  // 检查项目是否存在
  if (tree.exists(`apps/${schema.name}`)) {
    throw new Error(`Project ${schema.name} already exists`);
  }

  // 使用 try-failure 确保清理
  try {
    // 生成逻辑
  } catch (error) {
    // 记录错误
    console.error('Generator failed:', error);
    throw error;
  }
}
```

### 7.5 文档和注释

````typescript
/**
 * 创建 NestJS 应用生成器
 *
 * @param tree - Nx 虚拟文件系统
 * @param rawOptions - 生成器选项
 * @returns GeneratorCallback - 安装依赖的回调函数
 *
 * @example
 * ```bash
 * nx g @oksai/nest:application my-api
 * ```
 *
 * 生成的项目结构:
 * ```
 * apps/my-api/
 * ├── src/
 * │   ├── main.ts
 * │   └── app/
 * │       ├── app.module.ts
 * │       ├── app.controller.ts
 * │       └── app.service.ts
 * ├── project.json
 * ├── tsconfig.json
 * ├── tsconfig.app.json
 * ├── vitest.config.ts
 * └── webpack.config.js
 * ```
 */
export async function applicationGenerator(
  tree: Tree,
  rawOptions: ApplicationGeneratorOptions,
): Promise<GeneratorCallback> {
  // ...
}
````

---

## 附录

### A. 相关源码位置

| 包         | 路径                                     | 说明                       |
| ---------- | ---------------------------------------- | -------------------------- |
| @nx/devkit | `/home/arligle/forks/nx/packages/devkit` | 核心 API                   |
| @nx/plugin | `/home/arligle/forks/nx/packages/plugin` | 插件工具                   |
| @nx/nest   | `/home/arligle/forks/nx/packages/nest`   | NestJS 生成器              |
| @nx/node   | `/home/arligle/forks/nx/packages/node`   | Node.js 生成器             |
| @nx/js     | `/home/arligle/forks/nx/packages/js`     | JavaScript/TypeScript 工具 |

### B. 官方文档

- [Nx Devkit API](https://nx.dev/reference/nx-devkit-overview)
- [Plugin Development](https://nx.dev/extending-nx/intro/getting-started)
- [Generators](https://nx.dev/extending-nx/generators/creating-files)
- [Executors](https://nx.dev/extending-nx/executors/creating-executors)

### C. 版本信息

| 组件     | 版本   |
| -------- | ------ |
| Nx       | 22.5.4 |
| @nx/nest | 22.5.4 |
| @nx/node | 22.5.4 |
| NestJS   | 11.x   |
| Vitest   | 4.x    |

---

**文档版本**: 1.0
**最后更新**: 2025-03-13
**作者**: Claude AI
