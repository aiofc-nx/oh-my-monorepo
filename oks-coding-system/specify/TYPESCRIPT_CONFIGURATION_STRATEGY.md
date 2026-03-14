# TypeScript 配置策略

本文档阐述 oksai.cc monorepo 的 TypeScript 配置策略，包括前端与服务端的差异化配置、ESM/CJS 选择、`verbatimModuleSyntax` 策略等。

---

## 核心原则

### 1. 前后端分离策略

| 类型             | 构建工具  | 模块系统 | 模块解析 | `verbatimModuleSyntax` |
| ---------------- | --------- | -------- | -------- | ---------------------- |
| **前端应用**     | Vite      | ESNext   | Bundler  | ✅ 启用                |
| **前端库**       | Vite/tsup | ESNext   | Bundler  | ✅ 启用                |
| **后端应用**     | Webpack   | CommonJS | Node     | ❌ 禁用                |
| **后端库**       | tsc       | NodeNext | NodeNext | ✅ 启用                |
| **Nx Generator** | tsc       | CommonJS | Node     | ❌ 禁用                |

### 2. 为什么后端应用使用 CommonJS？

```
NestJS 服务端应用 → Webpack 构建 → CommonJS
```

**原因：**

- **生态系统兼容性**：大部分 NestJS 生态库仍以 CommonJS 为主
- **Webpack 对 Node.js 的优化**：`target: 'node'` + CommonJS 是成熟稳定的组合
- **运行时稳定性**：避免 ESM/CJS 互操作问题
- **装饰器支持**：`emitDecoratorMetadata` 在 CommonJS 环境下更稳定

### 3. 为什么前端使用 ESNext + Bundler？

```
React 前端应用 → Vite 构建 → ES Modules
```

**原因：**

- **Tree-shaking 优化**：ESM 是 tree-shaking 的最佳选择
- **开发体验**：Vite HMR 依赖原生 ESM
- **现代浏览器支持**：浏览器原生支持 ES Modules
- **Bundler 解析**：`moduleResolution: "bundler"` 为打包工具优化

---

## 配置文件架构

```
packages/tsconfig/
├── base.json              # 基础配置（ESM + NodeNext）
├── nestjs-12-cjs.json     # NestJS 服务端应用（CommonJS，独立配置）
├── nestjs-12-esm.json     # NestJS 库/ESM 项目
├── nestjs.json            # [DEPRECATED] 指向 nestjs-12-esm.json
├── nestjs-esm.json        # [DEPRECATED] 指向 nestjs-12-esm.json
├── react.json             # React 应用
├── react-library.json     # React 库
├── node-library.json      # Node.js 库（ESM）
├── build.json             # 通用构建配置
└── tanstack-start.json    # TanStack Start 应用
```

---

## 配置详解

### base.json - 基础配置

**用途**：所有 ESM 项目的共享基础配置

**关键配置**：

```json
{
  "compilerOptions": {
    "module": "NodeNext", // 现代 ESM 模块系统
    "moduleResolution": "NodeNext", // 现代模块解析
    "target": "ES2022", // 编译目标
    "lib": ["ES2022"], // 运行时库
    "verbatimModuleSyntax": true, // 严格的类型导入语法
    "customConditions": ["oh-my-monorepo"], // Monorepo 条件导出
    "strict": true, // 严格模式
    "noEmit": true // 不生成输出（由构建工具处理）
  }
}
```

**`verbatimModuleSyntax: true` 的含义**：

TypeScript 5.0+ 特性，强制区分类型导入和值导入：

```typescript
// ❌ 错误：混合导入
import { SomeClass, SomeType } from './module';

// ✅ 正确：显式类型导入
import { SomeClass } from './module';
import type { SomeType } from './module';

// ✅ 或使用内联语法
import { SomeClass, type SomeType } from './module';
```

**适用场景**：

- 前端项目（Vite/Rollup 打包）
- ESM 库项目
- 不适用于 CommonJS 项目

---

### nestjs-12-cjs.json - NestJS 服务端应用

**用途**：NestJS 服务端应用（Webpack 构建）

**关键配置**：

```json
{
  "$schema": "https://json.schemastore.org/tsconfig",
  "display": "oksai.cc NestJS 12 (CommonJS)",
  "compilerOptions": {
    // 模块系统
    "module": "CommonJS",
    "moduleResolution": "Node",

    // 编译目标
    "target": "ES2022",
    "lib": ["ES2022"],

    // 输出配置
    "noEmit": false,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,

    // 装饰器支持（NestJS 必需）
    "experimentalDecorators": true,
    "emitDecoratorMetadata": true,

    // 禁用 verbatimModuleSyntax（CommonJS 不兼容）
    // 注意：此配置不继承 base.json，完全独立

    // 类型定义
    "types": ["node", "vitest/globals"],

    // 严格模式
    "strict": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true,
    "strictBindCallApply": true,
    "strictPropertyInitialization": true
  }
}
```

**为什么不继承 base.json？**

| 配置项                 | base.json | CJS 需求 | 冲突 |
| ---------------------- | --------- | -------- | ---- |
| `module`               | NodeNext  | CommonJS | ❌   |
| `moduleResolution`     | NodeNext  | Node     | ❌   |
| `verbatimModuleSyntax` | true      | false    | ❌   |
| `customConditions`     | 有        | 无       | ❌   |
| `noEmit`               | true      | false    | ❌   |

因此 `nestjs-12-cjs.json` 是**完全独立**的配置，不继承任何其他配置。

---

### nestjs-12-esm.json - NestJS ESM 库

**用途**：NestJS 库项目或需要 ESM 的后端项目

```json
{
  "extends": "./base.json",
  "compilerOptions": {
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "verbatimModuleSyntax": true,
    "experimentalDecorators": true,
    "emitDecoratorMetadata": true,
    "noEmit": false,
    "types": ["node", "vitest/globals"]
  }
}
```

---

### react.json - React 应用

**用途**：React 前端应用（Vite 构建）

```json
{
  "extends": "./base.json",
  "compilerOptions": {
    "jsx": "react-jsx",
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "moduleResolution": "bundler",
    "target": "ES2020",
    "noEmit": true,
    "allowImportingTsExtensions": true,
    "types": ["vitest/globals"]
  }
}
```

**关键差异**：

| 配置项                       | 值        | 原因                     |
| ---------------------------- | --------- | ------------------------ |
| `moduleResolution`           | `bundler` | Vite/Rollup 专用解析策略 |
| `allowImportingTsExtensions` | `true`    | 允许 `.ts` 扩展名导入    |
| `target`                     | `ES2020`  | 更广泛的浏览器支持       |
| `noEmit`                     | `true`    | Vite 负责输出            |

---

### react-library.json - React 库

**用途**：React 组件库

```json
{
  "extends": "./base.json",
  "compilerOptions": {
    "jsx": "react-jsx",
    "module": "ESNext",
    "moduleResolution": "Bundler",
    "types": ["vitest/globals"]
  }
}
```

---

### node-library.json - Node.js 库

**用途**：通用 Node.js 库（ESM）

```json
{
  "extends": "./base.json",
  "compilerOptions": {
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "noEmit": false,
    "types": ["node", "vitest/globals"]
  }
}
```

---

## Generator 生成策略

### NestJS 应用生成器

```typescript
// packages/generators/nest/src/generators/nestjs-application

// 生成的 tsconfig.json
{
  "extends": "@oksai/tsconfig/nestjs-12-cjs.json",
  "compilerOptions": {
    "outDir": "./dist",
    "rootDir": "./src"
  }
}

// update-tsconfig.ts 会覆盖以下配置
{
  "experimentalDecorators": true,
  "emitDecoratorMetadata": true,
  "target": "es2021",
  "moduleResolution": "node",
  "module": "commonjs",
  "verbatimModuleSyntax": false  // 显式禁用，确保 CJS 兼容
}
```

### React 应用生成器

```typescript
// packages/generators/react/src/generators/application

// 生成的 tsconfig.json
{
  "extends": "@oksai/tsconfig/react.json",
  "compilerOptions": {
    "module": "ESNext",
    "moduleResolution": "bundler",
    "target": "ES2020",
    "noEmit": true,
    "verbatimModuleSyntax": true  // 继承自 base.json
  }
}
```

---

## Nx Generator 包的特殊处理

**问题**：Nx generator 包（如 `@oksai/nest`、`@oksai/react`）自身需要编译为 CommonJS

**原因**：

- Nx 使用 `require()` 加载 generators
- Generator 代码在 Node.js 环境运行

**解决方案**：

```json
// packages/generators/nest/tsconfig.json
{
  "extends": "@oksai/tsconfig/node-library.json",
  "compilerOptions": {
    "outDir": "./dist",
    "rootDir": "src",
    "verbatimModuleSyntax": false // 覆盖 base.json 的设置
  }
}
```

**注意**：`verbatimModuleSyntax: false` 是 Generator 包的必要配置，否则会报错：

```
TS1287: A top-level 'export' modifier cannot be used on value declarations
in a CommonJS module when 'verbatimModuleSyntax' is enabled.
```

---

## 项目配置示例

### NestJS 服务端应用

```json
// apps/api/tsconfig.json
{
  "extends": "@oksai/tsconfig/nestjs-12-cjs.json",
  "compilerOptions": {
    "outDir": "./dist",
    "rootDir": "./src"
  }
}
```

```json
// apps/api/tsconfig.app.json（由 Nx 生成）
{
  "extends": "./tsconfig.json",
  "compilerOptions": {
    "outDir": "../../dist/out-tsc",
    "declaration": true,
    "types": ["node"],
    "experimentalDecorators": true,
    "emitDecoratorMetadata": true,
    "module": "commonjs",
    "moduleResolution": "node",
    "verbatimModuleSyntax": false
  },
  "exclude": ["**/*.spec.ts", "**/*.e2e.ts"]
}
```

### React 前端应用

```json
// apps/web/tsconfig.json
{
  "extends": "@oksai/tsconfig/react.json",
  "compilerOptions": {
    "outDir": "./dist",
    "rootDir": "./src",
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    }
  }
}
```

---

## 配置决策矩阵

### 选择正确的配置

| 项目类型                | 推荐配置                   | 构建工具  | 模块系统 |
| ----------------------- | -------------------------- | --------- | -------- |
| NestJS API 服务         | `nestjs-12-cjs.json`       | Webpack   | CommonJS |
| NestJS 库（发布到 npm） | `nestjs-12-esm.json`       | tsc       | NodeNext |
| React SPA               | `react.json`               | Vite      | ESNext   |
| React 组件库            | `react-library.json`       | Vite/tsup | ESNext   |
| Node.js 工具库          | `node-library.json`        | tsc       | NodeNext |
| Nx Generator 包         | `node-library.json` + 覆盖 | tsc       | CommonJS |

### `verbatimModuleSyntax` 使用规则

| 场景             | 设置    | 原因              |
| ---------------- | ------- | ----------------- |
| 前端项目（Vite） | `true`  | 优化 tree-shaking |
| ESM 库           | `true`  | 强制显式类型导入  |
| CommonJS 后端    | `false` | 与 CJS 不兼容     |
| Nx Generator     | `false` | 需要编译为 CJS    |

---

## 常见问题

### Q: 为什么 NestJS 服务端不用 ESM？

A: 虽然 NestJS 12 支持 ESM，但：

1. Webpack + CommonJS 是更成熟稳定的组合
2. 大部分 NestJS 生态库仍是 CommonJS
3. 避免运行时 ESM/CJS 互操作问题
4. 装饰器元数据在 CommonJS 下更稳定

### Q: 何时使用 `moduleResolution: "bundler"`？

A: 仅当项目使用现代打包工具（Vite、Rollup、esbuild）时。特点是：

- 不需要 `.js` 扩展名
- 支持 `allowImportingTsExtensions`
- 优化打包性能

### Q: `types` 字段应该包含什么？

A:

- **生产构建**：`["node"]` 或省略
- **开发/测试**：`["node", "vitest/globals"]`
- **前端项目**：`["vitest/globals"]`（不需要 node）

### Q: 如何处理配置继承冲突？

A: 后配置覆盖前配置。例如：

```json
{
  "extends": "./base.json",
  "compilerOptions": {
    "verbatimModuleSyntax": false // 覆盖 base.json 的 true
  }
}
```

---

## 迁移指南

### 从旧配置迁移

| 旧配置            | 新配置               | 说明       |
| ----------------- | -------------------- | ---------- |
| `nestjs.json`     | `nestjs-12-cjs.json` | 服务端应用 |
| `nestjs-esm.json` | `nestjs-12-esm.json` | ESM 库     |

### 添加新项目

```bash
# NestJS 服务端应用
pnpm nx g @oksai/nest:nestjs-application --directory=apps/api

# React 前端应用
pnpm nx g @oksai/react:application --directory=apps/web
```

---

## 配置文件快速参考

### base.json（ESM 基础）

| 配置项                 | 值         |
| ---------------------- | ---------- |
| `module`               | `NodeNext` |
| `moduleResolution`     | `NodeNext` |
| `target`               | `ES2022`   |
| `verbatimModuleSyntax` | `true`     |
| `strict`               | `true`     |
| `noEmit`               | `true`     |

### nestjs-12-cjs.json（服务端应用）

| 配置项                 | 值              |
| ---------------------- | --------------- |
| `module`               | `CommonJS`      |
| `moduleResolution`     | `Node`          |
| `target`               | `ES2022`        |
| `verbatimModuleSyntax` | `false`（隐式） |
| `noEmit`               | `false`         |
| 继承                   | 无（独立配置）  |

### react.json（前端应用）

| 配置项                 | 值             |
| ---------------------- | -------------- |
| `module`               | `ESNext`       |
| `moduleResolution`     | `bundler`      |
| `target`               | `ES2020`       |
| `verbatimModuleSyntax` | `true`（继承） |
| `noEmit`               | `true`         |
| 继承                   | `base.json`    |

---

## 总结

| 维度                     | 前端      | 后端应用     | 后端库   |
| ------------------------ | --------- | ------------ | -------- |
| **构建工具**             | Vite      | Webpack      | tsc      |
| **模块系统**             | ESNext    | CommonJS     | NodeNext |
| **模块解析**             | bundler   | Node         | NodeNext |
| **verbatimModuleSyntax** | ✅        | ❌           | ✅       |
| **输出**                 | Vite 处理 | Webpack 处理 | tsc 输出 |
| **目标环境**             | 浏览器    | Node.js      | Node.js  |

**核心原则**：

1. **前端**：ESM + Vite + `verbatimModuleSyntax: true`
2. **后端应用**：CommonJS + Webpack + `verbatimModuleSyntax: false`
3. **后端库**：ESM + tsc + `verbatimModuleSyntax: true`
4. **Generator 包**：CommonJS + tsc + `verbatimModuleSyntax: false`
