# @oksai/generators 开发指南

> Nx 自定义生成器集合，为 NestJS 和 React 应用提供零配置的最佳实践

> **🎯 核心约定（必须遵守）**：
>
> - **应用（Application）** → 必须放在 `apps/` 目录
> - **内部库（Internal Library）** → 必须放在 `libs/` 目录（私有，仅供内部使用）
> - **公共包（Public Package）** → 必须放在 `packages/` 目录（可发布，供外部使用）
> - **所有命令推荐显式指定** `--directory` 参数
>
> **目录用途**：
>
> - `apps/` - 可部署的应用程序（API、Web、Admin 等）
> - `libs/` - 内部私有库（共享工具、领域逻辑等）
> - `packages/` - 可发布到 npm 的公共包（SDK、配置包、UI 组件库等）

## 📋 目录

- [概述](#概述)
- [快速开始](#快速开始)
- [架构设计](#架构设计)
- [开发生成器](#开发生成器)
- [API 参考](#api-参考)
- [测试](#测试)
- [调试](#调试)
- [最佳实践](#最佳实践)
- [故障排查](#故障排查)
- [示例](#示例)

---

## 概述

### 什么是 @oksai/generators？

`@oksai/generators` 是一个 Nx 插件集合，提供预配置的生成器，用于快速创建 NestJS 和 React 应用/库。

### 核心特性

| 特性           | 说明                                   |
| -------------- | -------------------------------------- |
| **零配置**     | 开箱即用的最佳实践配置                 |
| **现代技术栈** | Vite、Vitest、SWC、Biome               |
| **类型安全**   | 完整的 TypeScript 支持                 |
| **自动化**     | 自动配置 tsconfig、linter、test runner |
| **可扩展**     | 易于添加新的生成器                     |

### 可用生成器

| 生成器           | 描述        | 技术栈                       |
| ---------------- | ----------- | ---------------------------- |
| `nestjs-app`     | NestJS 应用 | Webpack + Vitest + SWC       |
| `nestjs-lib`     | NestJS 库   | TypeScript + Vitest          |
| `vite-react-app` | React 应用  | Vite + TypeScript + Tailwind |
| `vite-react-lib` | React 库    | Vite + TypeScript            |

---

## 快速开始

### 使用生成器

```bash
# 查看所有生成器
pnpm nx list @oksai/generators

# 创建 NestJS 应用（推荐：显式指定目录）
pnpm nx g @oksai/generators:nestjs-app my-api --directory=apps/my-api

# 创建 React 应用（Tailwind，推荐：显式指定目录）
pnpm nx g @oksai/generators:vite-react-app my-web --directory=apps/my-web --style=tailwind

# 创建可构建的库（推荐：显式指定目录）
pnpm nx g @oksai/generators:vite-react-lib my-lib --directory=libs/my-lib --buildable

# 创建 NestJS 库（推荐：显式指定目录）
pnpm nx g @oksai/generators:nestjs-lib shared-utils --directory=libs/shared-utils
```

**验证项目生成在正确的目录**：

```bash
# 对于应用
ls apps/<name> && echo "✅ 应用目录正确" || echo "❌ 错误：应用应该在 apps/<name>"

# 对于库
ls libs/<name> && echo "✅ 库目录正确" || echo "❌ 错误：库应该在 libs/<name>"
```

### 构建生成器

```bash
cd tools/generators
pnpm build
```

### 开发模式

```bash
# 监听文件变化
pnpm watch

# 清理并重建
pnpm build
```

---

## 架构设计

### 目录结构

```
tools/generators/
├── src/                          # 源代码
│   ├── nestjs-app/              # NestJS 应用生成器
│   │   ├── files/              # EJS 模板文件
│   │   │   ├── README.md__tmpl__
│   │   │   └── vitest.config.ts__tmpl__
│   │   ├── index.ts            # 生成器实现
│   │   ├── schema.d.ts         # TypeScript 类型
│   │   └── schema.json         # CLI Schema
│   ├── nestjs-lib/             # NestJS 库生成器
│   ├── vite-react-app/         # React 应用生成器
│   └── vite-react-lib/         # React 库生成器
├── dist/                        # 编译输出
│   ├── src/
│   └── generators.json
├── generators.json             # 生成器配置
├── package.json
└── tsconfig.json
```

### 核心概念

#### 1. 生成器（Generator）

生成器是一个函数，接收 `Tree` 和选项，返回 `GeneratorCallback`：

```typescript
import { Tree, GeneratorCallback } from '@nx/devkit';

export default async function (
  tree: Tree,
  options: Schema,
): Promise<GeneratorCallback> {
  // 1. 标准化选项
  const normalizedOptions = await normalizeOptions(tree, options);

  // 2. 执行生成逻辑
  const tasks: GeneratorCallback[] = [];

  // 3. 运行任务
  return runTasksInSerial(...tasks);
}
```

#### 2. Tree

虚拟文件系统，用于修改文件而不影响实际磁盘：

```typescript
// 创建文件
tree.create('path/to/file.ts', 'content');

// 读取文件
const content = tree.read('path/to/file.ts', 'utf-8');

// 修改文件
tree.write('path/to/file.ts', 'new content');

// 删除文件
tree.delete('path/to/file.ts');
```

#### 3. Schema

定义生成器的输入参数：

```typescript
// schema.d.ts
export interface MyGeneratorSchema {
  name: string;
  directory?: string;
  tags?: string;
  skipFormat?: boolean;
}
```

```json
// schema.json
{
  "$schema": "http://json-schema.org/schema",
  "$id": "MyGenerator",
  "title": "My Generator",
  "properties": {
    "name": {
      "type": "string",
      "description": "项目名称",
      "$default": {
        "$source": "argv",
        "index": 0
      },
      "x-prompt": "项目名称?"
    }
  },
  "required": ["name"]
}
```

#### 4. 模板文件

使用 EJS 模板语法：

```typescript
// vite.config.ts__tmpl__
import { defineConfig } from 'vite';

export default defineConfig({
  server: {
    port: <%= port %>,
  },
});
```

---

## 开发生成器

### 创建新生成器

#### 步骤 1: 创建目录结构

```bash
mkdir -p src/my-generator/files
```

#### 步骤 2: 定义 Schema

```typescript
// src/my-generator/schema.d.ts
export interface MyGeneratorSchema {
  name: string;
  directory?: string;
  tags?: string;
  skipFormat?: boolean;
  skipPackageJson?: boolean;
}
```

```json
// src/my-generator/schema.json
{
  "$schema": "http://json-schema.org/schema",
  "$id": "MyGenerator",
  "title": "My Generator",
  "description": "创建自定义项目",
  "type": "object",
  "properties": {
    "name": {
      "type": "string",
      "description": "项目名称",
      "$default": {
        "$source": "argv",
        "index": 0
      },
      "x-prompt": "项目名称?"
    },
    "directory": {
      "type": "string",
      "description": "项目目录",
      "alias": "dir"
    },
    "tags": {
      "type": "string",
      "description": "项目标签"
    },
    "skipFormat": {
      "type": "boolean",
      "description": "跳过格式化",
      "default": false,
      "x-priority": "internal"
    }
  },
  "required": ["name"]
}
```

#### 步骤 3: 实现生成器

```typescript
// src/my-generator/index.ts
import {
  Tree,
  formatFiles,
  generateFiles,
  runTasksInSerial,
  type GeneratorCallback,
} from '@nx/devkit';
import {
  determineProjectNameAndRootOptions,
  ensureRootProjectName,
} from '@nx/devkit/src/generators/project-name-and-root-utils';
import { join } from 'path';
import type { MyGeneratorSchema } from './schema';

export default async function (
  tree: Tree,
  rawOptions: MyGeneratorSchema,
): Promise<GeneratorCallback> {
  return await myGeneratorInternal(tree, rawOptions);
}

export async function myGeneratorInternal(
  tree: Tree,
  rawOptions: MyGeneratorSchema,
): Promise<GeneratorCallback> {
  const options = await normalizeOptions(tree, rawOptions);
  const tasks: GeneratorCallback[] = [];

  // 创建文件
  createFiles(tree, options);

  // 添加依赖
  // const depsTask = addDependenciesToPackageJson(tree, {}, {});
  // if (depsTask) tasks.push(depsTask);

  // 格式化文件
  if (!options.skipFormat) {
    await formatFiles(tree);
  }

  return runTasksInSerial(...tasks);
}

async function normalizeOptions(tree: Tree, options: MyGeneratorSchema) {
  // 根据项目类型设置默认目录
  const directory = options.directory ?? `apps/${options.name}`; // 应用
  // const directory = options.directory ?? `libs/${options.name}`; // 库

  await ensureRootProjectName({ directory, name: options.name }, 'application');
  const { projectName, projectRoot } = await determineProjectNameAndRootOptions(
    tree,
    {
      name: options.name,
      projectType: 'application',
      directory,
    },
  );

  return {
    ...options,
    projectName,
    projectRoot,
    tags: options.tags ?? 'type:app',
    skipPackageJson: options.skipPackageJson ?? false,
  };
}

function createFiles(
  tree: Tree,
  options: Awaited<ReturnType<typeof normalizeOptions>>,
) {
  const substitutions = {
    ...options,
    tmpl: '',
    fileName: options.projectName,
  };

  generateFiles(
    tree,
    join(__dirname, 'files'),
    options.projectRoot,
    substitutions,
  );
}
```

#### 步骤 4: 创建模板文件

```typescript
// src/my-generator/files/README.md__tmpl__
# <%= name %>

项目描述...

## 快速开始

\`\`\`bash
pnpm nx serve <%= name %>
\`\`\`
```

#### 步骤 5: 注册生成器

```json
// generators.json
{
  "$schema": "http://json-schema.org/schema",
  "name": "@oksai/generators",
  "generators": {
    "my-generator": {
      "factory": "./src/my-generator",
      "schema": "./src/my-generator/schema.json",
      "description": "创建自定义项目"
    }
  }
}
```

#### 步骤 6: 更新构建脚本

```json
// package.json
{
  "scripts": {
    "build": "tsc && npm run copy-files",
    "copy-files": "for dir in src/*/; do name=$(basename \"$dir\"); mkdir -p \"dist/src/$name\"; cp -r \"$dir/files\" \"dist/src/$name/\" 2>/dev/null || true; cp \"$dir/schema.json\" \"dist/src/$name/\" 2>/dev/null || true; done"
  }
}
```

#### 步骤 7: 构建和测试

```bash
# 构建
pnpm build

# 测试
pnpm nx g @oksai/generators:my-generator test --dry-run
```

---

## API 参考

### @nx/devkit 核心工具

#### formatFiles

格式化生成的文件：

```typescript
import { formatFiles } from '@nx/devkit';

if (!options.skipFormat) {
  await formatFiles(tree);
}
```

#### generateFiles

从模板生成文件：

```typescript
import { generateFiles, joinPathFragments } from '@nx/devkit';
import { join } from 'path';

generateFiles(
  tree, // 虚拟文件系统
  join(__dirname, 'files'), // 模板目录
  options.projectRoot, // 目标目录
  {
    ...options, // 模板变量
    tmpl: '',
  },
);
```

#### runTasksInSerial

串行执行回调任务：

```typescript
import { runTasksInSerial, type GeneratorCallback } from '@nx/devkit';

const tasks: GeneratorCallback[] = [];

// 添加任务
tasks.push(callback1);
tasks.push(callback2);

// 串行执行
return runTasksInSerial(...tasks);
```

#### addDependenciesToPackageJson

添加依赖到 package.json：

```typescript
import { addDependenciesToPackageJson } from '@nx/devkit';

const depsTask = addDependenciesToPackageJson(
  tree,
  {
    // dependencies
    'some-package': '^1.0.0',
  },
  {
    // devDependencies
    'some-dev-package': '^2.0.0',
  },
);

if (depsTask) tasks.push(depsTask);
```

#### readJson / writeJson

读写 JSON 文件：

```typescript
import { readJson, writeJson } from '@nx/devkit';

// 读取
const tsConfig = readJson(tree, 'path/to/tsconfig.json');

// 修改
tsConfig.compilerOptions.strict = true;

// 写入
writeJson(tree, 'path/to/tsconfig.json', tsConfig);
```

### 项目路径工具

#### determineProjectNameAndRootOptions

解析项目名和路径：

```typescript
import {
  determineProjectNameAndRootOptions,
  ensureRootProjectName,
} from '@nx/devkit/src/generators/project-name-and-root-utils';

await ensureRootProjectName(options, 'application');
const { projectName, projectRoot, importPath } =
  await determineProjectNameAndRootOptions(tree, {
    name: options.name,
    projectType: 'application',
    directory: options.directory,
  });
```

### 命名工具

#### names

生成各种命名变体：

```typescript
import { names } from '@nx/devkit';

const nameVariants = names('my-project');
// {
//   name: 'my-project',
//   className: 'MyProject',
//   propertyName: 'myProject',
//   constantName: 'MY_PROJECT',
//   fileName: 'my-project'
// }
```

---

## 测试

### 单元测试

```typescript
// src/my-generator/index.spec.ts
import { Tree, createTreeWithEmptyWorkspace } from '@nx/devkit/testing';
import myGenerator from './index';

describe('my-generator', () => {
  let tree: Tree;

  beforeEach(() => {
    tree = createTreeWithEmptyWorkspace();
  });

  it('should create files', async () => {
    await myGenerator(tree, { name: 'test' });

    expect(tree.exists('apps/test/README.md')).toBeTruthy();
  });
});
```

### 集成测试

```bash
# Dry-run 测试
pnpm nx g @oksai/generators:my-generator test --dry-run

# 实际生成测试
pnpm nx g @oksai/generators:my-generator test

# 验证生成的项目
pnpm nx build test
pnpm nx test test
pnpm nx lint test
```

---

## 调试

### 使用 console.log

```typescript
export async function myGenerator(tree: Tree, options: Schema) {
  console.log('Options:', options);
  console.log('Tree root:', tree.root);

  // 列出所有文件
  tree.listChanges().forEach((change) => {
    console.log(`${change.type}: ${change.path}`);
  });
}
```

### 使用 Nx Console

```bash
# VS Code 扩展：Nx Console
# 可视化生成器选项和执行
```

### Dry-run 模式

```bash
# 预览变更，不实际修改
pnpm nx g @oksai/generators:my-generator test --dry-run
```

---

## 最佳实践

### 1. 标准化选项

始终使用 `normalizeOptions` 处理输入，**必须显式设置目录默认值**：

```typescript
async function normalizeOptions(tree: Tree, options: Schema) {
  // ⚠️ 重要：根据项目类型设置正确的默认目录
  // 应用 → apps/<name>
  // 库 → libs/<name>
  const directory = options.directory ?? `apps/${options.name}`;

  // 解析项目路径
  await ensureRootProjectName({ directory, name: options.name }, 'application');
  const { projectName, projectRoot } = await determineProjectNameAndRootOptions(
    tree,
    {
      name: options.name,
      projectType: 'application',
      directory,
    },
  );

  return {
    ...options,
    projectName,
    projectRoot,
    tags: options.tags ?? 'type:app',
    skipFormat: options.skipFormat ?? false,
  };
}
```

**错误示例（已废弃）**：

```typescript
// ❌ 错误：会导致项目生成在根目录
const opts = { directory: options.directory ?? options.name, ...options };
```

**正确示例**：

```typescript
// ✅ 正确：应用默认在 apps/<name>
const directory = options.directory ?? `apps/${options.name}`;

// ✅ 正确：库默认在 libs/<name>
const directory = options.directory ?? `libs/${options.name}`;
```

````

### 2. 委托给官方生成器

尽可能复用官方生成器：

```typescript
import { applicationGenerator } from '@nx/react';

const appTask = await applicationGenerator(tree, {
  name: options.projectName,
  bundler: 'vite',
  style: options.style,
  unitTestRunner: 'vitest',
  e2eTestRunner: 'none',
  linter: 'none',
  skipFormat: true,
});
tasks.push(appTask);
````

### 3. 使用模板文件

对于复杂的文件，使用 EJS 模板：

```
files/
├── README.md__tmpl__
├── tsconfig.json__tmpl__
└── vite.config.ts__tmpl__
```

### 4. 提供清晰的 Schema

```json
{
  "properties": {
    "style": {
      "type": "string",
      "description": "样式方案",
      "enum": ["css", "tailwind", "none"],
      "default": "css",
      "x-prompt": {
        "message": "选择样式方案?",
        "type": "list",
        "items": [
          { "value": "css", "label": "CSS" },
          { "value": "tailwind", "label": "Tailwind CSS" }
        ]
      }
    }
  }
}
```

### 5. 错误处理

```typescript
if (options.publishable && !options.importPath) {
  throw new Error('For publishable libs you have to provide --importPath');
}
```

### 6. 文档和示例

```json
{
  "examples": [
    {
      "command": "nx g my-generator myapp",
      "description": "创建应用"
    },
    {
      "command": "nx g my-generator myapp --style=tailwind",
      "description": "创建带 Tailwind 的应用"
    }
  ]
}
```

### 7. 目录约定（重要）

**必须遵守的目录规则**：

```typescript
// 在 normalizeOptions 中设置正确的默认目录
async function normalizeOptions(tree: Tree, options: Schema) {
  // 应用 → apps/<name>
  const directory = options.directory ?? `apps/${options.name}`;

  // 或库 → libs/<name>
  // const directory = options.directory ?? `libs/${options.name>`;

  // ...
}
```

**目录约定总结**：

| 项目类型    | 默认目录      | 用途       | 示例                                                |
| ----------- | ------------- | ---------- | --------------------------------------------------- |
| NestJS 应用 | `apps/<name>` | 可部署 API | `pnpm nx g nestjs-app api --directory=apps/api`     |
| React 应用  | `apps/<name>` | 可部署前端 | `pnpm nx g vite-react-app web --directory=apps/web` |
| NestJS 库   | `libs/<name>` | 内部私有库 | `pnpm nx g nestjs-lib utils --directory=libs/utils` |
| React 库    | `libs/<name>` | 内部私有库 | `pnpm nx g vite-react-lib ui --directory=libs/ui`   |

**注意**：对于需要对外发布的公共包（如 SDK、配置包、UI 组件库），请手动在 `packages/` 目录中创建，不使用生成器。

**目录用途详解**：

- `apps/` - 应用程序
  - 可部署的服务（API、后台管理、前端应用等）
  - 通常有独立的服务器或构建产物

- `libs/` - 内部私有库
  - 业务逻辑共享模块
  - 工具函数、数据访问层
  - 领域模型、基础设施代码
  - **不对外发布**，仅供项目内部使用

- `packages/` - 公共包（手动管理）
  - 可发布到 npm 的包
  - SDK、客户端库
  - 配置包（如 `@oksai/tsconfig`）
  - UI 组件库（对外发布）
  - **需要独立版本管理**和发布流程

**验证方法**：

```bash
# 生成后立即验证目录
ls apps/<name> || ls libs/<name>

# 或在生成命令后添加验证
pnpm nx g @oksai/generators:nestjs-app api --directory=apps/api && \
  ls apps/api && echo "✅ 目录正确" || echo "❌ 目录错误"
```

---

## 故障排查

### 项目生成在错误目录

**问题**:

```
项目生成在根目录 <name>/ 而非 apps/<name>/ 或 libs/<name>/
```

**原因**:

生成器代码中 `directory` 默认值设置错误（旧代码使用 `options.directory ?? options.name`）

**解决方案**:

1. **检查生成器代码**：

```typescript
// ❌ 错误写法
const opts = { directory: options.directory ?? options.name, ...options };

// ✅ 正确写法（应用）
const directory = options.directory ?? `apps/${options.name}`;

// ✅ 正确写法（库）
const directory = options.directory ?? `libs/${options.name}`;
```

2. **修复并重新构建**：

```bash
cd tools/generators
pnpm build
```

3. **清理错误项目并重新生成**：

```bash
# 删除错误的项目
rm -rf <name> <name>-e2e

# 重新生成（显式指定目录）
pnpm nx g @oksai/generators:nestjs-app <name> --directory=apps/<name>
```

4. **验证目录正确性**：

```bash
ls apps/<name> && echo "✅ 目录正确" || echo "❌ 目录错误"
```

### 生成器未找到

**问题**:

```
Cannot find generator '@oksai/generators:my-generator'
```

**解决方案**:

```bash
# 重新构建
cd tools/generators
pnpm build

# 验证生成器
pnpm nx list @oksai/generators
```

### 模板文件未复制

**问题**:

```
Template file not found
```

**解决方案**:

```bash
# 检查构建脚本
cat tools/generators/package.json | grep copy-files

# 手动复制
cd tools/generators
cp -r src/my-generator/files dist/src/my-generator/
```

### Schema 不生效

**问题**:

```
Invalid option 'xxx'
```

**解决方案**:

```bash
# 检查 schema.json 位置
ls -la dist/src/my-generator/schema.json

# 验证 JSON 格式
npx jsonlint dist/src/my-generator/schema.json
```

### Nx 缓存问题

**问题**:

```
Old files being used
```

**解决方案**:

```bash
# 清除缓存
pnpm nx reset

# 重新构建
cd tools/generators
rm -rf dist
pnpm build
```

---

## 示例

### 完整的生成器示例

```typescript
// src/vite-react-app/index.ts
import {
  Tree,
  formatFiles,
  runTasksInSerial,
  type GeneratorCallback,
  addDependenciesToPackageJson,
} from '@nx/devkit';
import {
  determineProjectNameAndRootOptions,
  ensureRootProjectName,
} from '@nx/devkit/src/generators/project-name-and-root-utils';
import { applicationGenerator } from '@nx/react';
import type { ViteReactAppGeneratorSchema } from './schema';

export default async function (
  tree: Tree,
  rawOptions: ViteReactAppGeneratorSchema,
): Promise<GeneratorCallback> {
  return await viteReactAppGeneratorInternal(tree, rawOptions);
}

export async function viteReactAppGeneratorInternal(
  tree: Tree,
  rawOptions: ViteReactAppGeneratorSchema,
): Promise<GeneratorCallback> {
  const options = await normalizeOptions(tree, rawOptions);
  const tasks: GeneratorCallback[] = [];

  // 使用官方 React 生成器
  const appTask = await applicationGenerator(tree, {
    name: options.projectName,
    directory: options.appProjectRoot,
    bundler: 'vite',
    style: options.style,
    routing: options.routing,
    unitTestRunner: 'vitest',
    e2eTestRunner: 'none',
    linter: 'none',
    tags: options.tags,
    skipFormat: true,
    inSourceTests: options.inSourceTests,
  });
  tasks.push(appTask);

  // 添加自定义依赖
  if (!options.skipPackageJson) {
    const depsTask = addDependenciesToPackageJson(
      tree,
      {},
      {
        ...(options.style === 'tailwind' && {
          tailwindcss: '^4.0.0',
          '@tailwindcss/vite': '^4.0.0',
        }),
      },
    );
    if (depsTask) tasks.push(depsTask);
  }

  if (!options.skipFormat) {
    await formatFiles(tree);
  }

  return runTasksInSerial(...tasks);
}

async function normalizeOptions(
  tree: Tree,
  options: ViteReactAppGeneratorSchema,
) {
  // 应用默认在 apps/<name>
  const directory = options.directory ?? `apps/${options.name}`;
  await ensureRootProjectName({ directory, name: options.name }, 'application');
  const { projectName, projectRoot } = await determineProjectNameAndRootOptions(
    tree,
    {
      name: options.name,
      projectType: 'application',
      directory,
    },
  );

  return {
    ...options,
    projectName,
    appProjectRoot: projectRoot,
    tags: options.tags ?? 'type:app,framework:react,bundler:vite',
    style: options.style ?? 'css',
    routing: options.routing ?? false,
    inSourceTests: options.inSourceTests ?? false,
    skipPackageJson: options.skipPackageJson ?? false,
  };
}
```

---

## 相关资源

- [Nx 官方文档](https://nx.dev)
- [Nx 生成器指南](https://nx.dev/extending-nx/recipes/local-generators)
- [Nx Devkit API](https://nx.dev/nx-api/devkit)
- [EJS 模板语法](https://ejs.co)

---

## 贡献指南

### 开发流程

1. 创建新分支
2. 开发生成器
3. 编写测试
4. 更新文档
5. 提交 PR

### 代码规范

- 使用 TypeScript
- 遵循 Biome 规则
- 添加注释
- 编写测试

### 提交信息

```
feat(generator): add new generator for X
fix(generator): fix bug in Y generator
docs(generator): update documentation
```

---

## 更新日志

### v0.0.1 (2024-03-13)

- ✅ 创建 `nestjs-app` 生成器
- ✅ 创建 `nestjs-lib` 生成器
- ✅ 创建 `vite-react-app` 生成器
- ✅ 创建 `vite-react-lib` 生成器
- ✅ 重命名包为 `@oksai/generators`
- ✅ 删除冗余的 `nx-generate` skill
- ✅ 创建 `oksai-generators` skill

---

## 支持

如有问题，请：

1. 查看本文档
2. 检查 [故障排查](#故障排查) 章节
3. 查看现有生成器代码
4. 提交 Issue
