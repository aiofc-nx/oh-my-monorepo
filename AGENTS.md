{
"$schema": "https://opencode.ai/config.json",
"instructions": ["CONTRIBUTING.md", "docs/guidelines.md", ".cursor/rules/*.md"]
}<!-- nx configuration start-->

<!-- Leave the start & end comments to automatically receive updates. -->

# General Guidelines for working with Nx

- For navigating/exploring the workspace, invoke the `nx-workspace` skill first - it has patterns for querying projects, targets, and dependencies
- When running tasks (for example build, lint, test, e2e, etc.), always prefer running the task through `nx` (i.e. `nx run`, `nx run-many`, `nx affected`) instead of using the underlying tooling directly
- Prefix nx commands with the workspace's package manager (e.g., `pnpm nx build`, `npm exec nx test`) - avoids using globally installed CLI
- You have access to the Nx MCP server and its tools, use them to help the user
- For Nx plugin best practices, check `node_modules/@nx/<plugin>/PLUGIN.md`. Not all plugins have this file - proceed without it if unavailable.
- NEVER guess CLI flags - always check nx_docs or `--help` first when unsure

## Scaffolding & Generators

- For scaffolding tasks (creating apps, libs, project structure, setup), ALWAYS invoke the `nx-generate` skill FIRST before exploring or calling MCP tools

## When to use nx_docs

- USE for: advanced config options, unfamiliar flags, migration guides, plugin configuration, edge cases
- DON'T USE for: basic generator syntax (`nx g @nx/react:app`), standard commands, things you already know
- The `nx-generate` skill handles generator discovery internally - don't call nx_docs just to look up generator syntax

<!-- nx configuration end-->

<!-- typescript configuration start-->

# TypeScript Configuration Strategy

完整策略文档: `oks-coding-system/specify/TYPESCRIPT_CONFIGURATION_STRATEGY.md`

## 核心原则

| 类型             | 构建工具 | 模块系统 | `verbatimModuleSyntax` | 配置文件                   |
| ---------------- | -------- | -------- | ---------------------- | -------------------------- |
| **前端应用**     | Vite     | ESNext   | ✅ 启用                | `react.json`               |
| **后端应用**     | Webpack  | CommonJS | ❌ 禁用                | `nestjs-12-cjs.json`       |
| **后端库**       | tsc      | NodeNext | ✅ 启用                | `nestjs-12-esm.json`       |
| **Nx Generator** | tsc      | CommonJS | ❌ 禁用                | `node-library.json` + 覆盖 |

## 配置选择决策

```
创建新项目时：
├── NestJS API 服务 → extends "@oksai/tsconfig/nestjs-12-cjs.json"
├── React SPA      → extends "@oksai/tsconfig/react.json"
├── React 组件库   → extends "@oksai/tsconfig/react-library.json"
└── Node.js 库     → extends "@oksai/tsconfig/node-library.json"
```

## verbatimModuleSyntax 规则

**前端项目 (Vite)** - 启用:

```typescript
// ✅ 必须显式区分类型导入
import { SomeClass } from './module';
import type { SomeType } from './module';
```

**后端应用 (Webpack/CommonJS)** - 禁用:

```typescript
// ✅ 可以混合导入
import { SomeClass, SomeType } from './module';
```

## Generator 包特殊处理

Nx generator 包（`@oksai/nest`, `@oksai/react`）必须设置 `verbatimModuleSyntax: false`:

```json
{
  "extends": "@oksai/tsconfig/node-library.json",
  "compilerOptions": {
    "verbatimModuleSyntax": false
  }
}
```

## 常见错误修复

| 错误     | 原因                         | 解决方案                              |
| -------- | ---------------------------- | ------------------------------------- |
| `TS1287` | CJS + verbatimModuleSyntax   | 设置 `verbatimModuleSyntax: false`    |
| `TS5098` | customConditions + Node 解析 | 使用 `nestjs-12-cjs.json`（独立配置） |
| `TS1295` | ESM imports in CJS           | 确保 module 与 moduleResolution 匹配  |

<!-- typescript configuration end-->

<!-- testing configuration start-->

# Testing Configuration Strategy

完整策略文档: `oks-coding-system/specify/TESTING_CONFIGURATION_STRATEGY.md`

## 核心原则

| 项目类型        | 测试框架   | 测试环境 | 覆盖率目标 |
| --------------- | ---------- | -------- | ---------- |
| **NestJS 应用** | Vitest     | Node.js  | 80%        |
| **React 应用**  | Vitest     | jsdom    | 80%        |
| **核心库**      | Vitest     | Node.js  | 90%        |
| **E2E 测试**    | Playwright | Browser  | -          |

## Vitest 配置要点

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    globals: true, // 启用全局 API
    environment: 'node', // 或 'jsdom'
    coverage: {
      provider: 'v8',
      reporter: ['text', 'lcov'],
    },
  },
});
```

## 测试文件命名

| 类型     | 命名模式        | 示例                  |
| -------- | --------------- | --------------------- |
| 单元测试 | `*.spec.ts`     | `app.service.spec.ts` |
| 组件测试 | `*.test.tsx`    | `Button.test.tsx`     |
| E2E 测试 | `*.e2e-spec.ts` | `auth.e2e-spec.ts`    |

## 常用命令

```bash
pnpm nx test <project>              # 运行测试
pnpm nx test <project> --coverage   # 生成覆盖率
pnpm nx affected --target=test      # 测试受影响项目
```

<!-- testing configuration end-->
