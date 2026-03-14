# @oksai/tsconfig

Shared TypeScript configurations for oksai.cc monorepo.

**Location**: `packages/tsconfig/`

**完整策略文档**: `oks-coding-system/specify/TYPESCRIPT_CONFIGURATION_STRATEGY.md`

## 核心原则

| 类型             | 构建工具 | 模块系统 | `verbatimModuleSyntax` | 配置文件                   |
| ---------------- | -------- | -------- | ---------------------- | -------------------------- |
| **前端应用**     | Vite     | ESNext   | ✅ 启用                | `react.json`               |
| **后端应用**     | Webpack  | CommonJS | ❌ 禁用                | `nestjs-12-cjs.json`       |
| **后端库**       | tsc      | NodeNext | ✅ 启用                | `nestjs-12-esm.json`       |
| **Nx Generator** | tsc      | CommonJS | ❌ 禁用                | `node-library.json` + 覆盖 |

## Available Configurations

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

### `base.json`

所有 ESM 项目的共享基础配置。

**Features**:

- Strict mode enabled
- ES2022 target
- `verbatimModuleSyntax: true` - 强制显式类型导入
- `module: NodeNext` - 现代 ESM 模块系统
- Decorator metadata support
- `customConditions: ["oh-my-monorepo"]`

**`verbatimModuleSyntax: true` 的含义**:

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

---

### `nestjs-12-cjs.json` ⭐ 推荐

NestJS 服务端应用（Webpack 构建）。

**注意**: 此配置**不继承** `base.json`，是完全独立的配置。

**Features**:

- `module: CommonJS` - CommonJS 模块系统
- `moduleResolution: Node` - Node.js 解析
- `verbatimModuleSyntax: false` - 兼容 CommonJS
- Decorator metadata enabled
- Source maps enabled
- Vitest types included

**Usage**:

```json
{
  "extends": "@oksai/tsconfig/nestjs-12-cjs.json",
  "compilerOptions": {
    "outDir": "./dist",
    "rootDir": "./src"
  }
}
```

**为什么后端应用使用 CommonJS？**

- Webpack + CommonJS 是成熟稳定的组合
- 大部分 NestJS 生态库仍是 CommonJS
- 避免运行时 ESM/CJS 互操作问题
- 装饰器元数据在 CommonJS 下更稳定

---

### `nestjs-12-esm.json`

NestJS 库项目或需要 ESM 的后端项目。

**Extends**: `base.json`

**Features**:

- `module: NodeNext` - ESM 模块系统
- `verbatimModuleSyntax: true`
- Decorator metadata enabled
- Source maps enabled

**Usage**:

```json
{
  "extends": "@oksai/tsconfig/nestjs-12-esm.json",
  "compilerOptions": {
    "outDir": "./dist",
    "rootDir": "./src"
  }
}
```

---

### `react.json`

React 前端应用（Vite 构建）。

**Extends**: `base.json`

**Features**:

- `jsx: react-jsx` - React JSX transform
- `module: ESNext`
- `moduleResolution: bundler` - Vite/Rollup 专用
- `allowImportingTsExtensions: true`
- ES2020 target（更广泛的浏览器支持）

**Usage**:

```json
{
  "extends": "@oksai/tsconfig/react.json",
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    }
  }
}
```

---

### `react-library.json`

React 组件库。

**Extends**: `base.json`

**Features**:

- React JSX transform
- DOM types included
- ESNext modules
- Bundler resolution

**Usage**:

```json
{
  "extends": "@oksai/tsconfig/react-library.json",
  "compilerOptions": {
    "outDir": "./dist",
    "rootDir": "./src"
  }
}
```

---

### `node-library.json`

通用 Node.js 库（ESM）。

**Extends**: `base.json`

**Features**:

- NodeNext module system
- Composite project references
- Declaration files generation
- Vitest types included

**Usage**:

```json
{
  "extends": "@oksai/tsconfig/node-library.json",
  "compilerOptions": {
    "outDir": "./dist",
    "rootDir": "./src"
  }
}
```

**Nx Generator 包特殊处理**:

```json
{
  "extends": "@oksai/tsconfig/node-library.json",
  "compilerOptions": {
    "verbatimModuleSyntax": false
  }
}
```

---

### `tanstack-start.json`

TanStack Start 应用。

**Extends**: `base.json`

**Usage**:

```json
{
  "extends": "@oksai/tsconfig/tanstack-start.json",
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "~/*": ["./src/*"]
    }
  }
}
```

---

### DEPRECATED Configurations

| 旧配置            | 新配置               | 说明       |
| ----------------- | -------------------- | ---------- |
| `nestjs.json`     | `nestjs-12-cjs.json` | 服务端应用 |
| `nestjs-esm.json` | `nestjs-12-esm.json` | ESM 库     |

---

## Configuration Comparison

| Feature               | base.json | nestjs-12-cjs.json | nestjs-12-esm.json | react.json | node-library.json |
| --------------------- | --------- | ------------------ | ------------------ | ---------- | ----------------- |
| extends               | -         | 无                 | base.json          | base.json  | base.json         |
| module                | NodeNext  | CommonJS           | NodeNext           | ESNext     | NodeNext          |
| moduleResolution      | NodeNext  | Node               | NodeNext           | bundler    | NodeNext          |
| verbatimModuleSyntax  | true      | false              | true               | true       | true              |
| target                | ES2022    | ES2022             | ES2022             | ES2020     | ES2022            |
| jsx                   | -         | -                  | -                  | react-jsx  | -                 |
| noEmit                | true      | false              | false              | true       | false             |
| emitDecoratorMetadata | true      | true               | true               | -          | -                 |

---

## Best Practices

### 1. 配置选择决策

```
创建新项目时：
├── NestJS API 服务 → extends "@oksai/tsconfig/nestjs-12-cjs.json"
├── React SPA      → extends "@oksai/tsconfig/react.json"
├── React 组件库   → extends "@oksai/tsconfig/react-library.json"
└── Node.js 库     → extends "@oksai/tsconfig/node-library.json"
```

### 2. verbatimModuleSyntax 规则

| 场景             | 设置    | 原因              |
| ---------------- | ------- | ----------------- |
| 前端项目（Vite） | `true`  | 优化 tree-shaking |
| ESM 库           | `true`  | 强制显式类型导入  |
| CommonJS 后端    | `false` | 与 CJS 不兼容     |
| Nx Generator     | `false` | 需要编译为 CJS    |

### 3. Dual Configuration

For libraries, use dual configuration:

```json
// tsconfig.json (development)
{
  "extends": "@oksai/tsconfig/node-library.json"
}

// tsconfig.build.json (production)
{
  "extends": ["@oksai/tsconfig/node-library.json", "@oksai/tsconfig/build.json"]
}
```

---

## Troubleshooting

### TS1287: verbatimModuleSyntax 冲突

```
TS1287: A top-level 'export' modifier cannot be used on value declarations
in a CommonJS module when 'verbatimModuleSyntax' is enabled.
```

**Solution**: 设置 `verbatimModuleSyntax: false`

### TS5098: customConditions 不兼容

```
TS5098: Option 'customConditions' can only be used when 'moduleResolution'
is set to 'node16', 'nodenext', or 'bundler'.
```

**Solution**: 使用 `nestjs-12-cjs.json`（独立配置，无 customConditions）

### TS1295: ESM imports in CJS

```
TS1295: ECMAScript imports and exports cannot be written in a CommonJS file
under 'verbatimModuleSyntax'.
```

**Solution**: 确保 `module` 与 `moduleResolution` 匹配：

- CommonJS + Node
- NodeNext + NodeNext

### Configuration not applied

**Solution**: Check that you're extending the correct file and your IDE has reloaded.

### Build cache issues

**Solution**: Clear TypeScript build cache:

```bash
find . -name "*.tsbuildinfo" -delete
pnpm nx reset
```

---

## References

- [TypeScript tsconfig.json](https://www.typescriptlang.org/docs/handbook/tsconfig-json.html)
- [JSON Schema Store](https://json.schemastore.org/tsconfig)
- [TypeScript 5.0 Release Notes](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-5-0.html#verbatimmodulesyntax)
