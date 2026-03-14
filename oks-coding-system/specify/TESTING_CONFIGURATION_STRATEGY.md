# 测试配置策略

本文档阐述 oksai.cc monorepo 的测试配置策略，包括测试框架选择、不同项目类型的测试配置、覆盖率策略等。

---

## 核心原则

### 1. 测试框架选择

| 框架           | 用途              | 原因                                 |
| -------------- | ----------------- | ------------------------------------ |
| **Vitest**     | 单元测试/集成测试 | 快速、ESM 原生支持、与 Vite 共享配置 |
| **Playwright** | E2E 测试          | 跨浏览器支持、现代化 API             |

### 2. 测试策略矩阵

| 项目类型         | 测试框架           | 测试环境 | 配置文件               |
| ---------------- | ------------------ | -------- | ---------------------- |
| **NestJS 应用**  | Vitest             | Node.js  | `vitest.config.ts`     |
| **NestJS 库**    | Vitest             | Node.js  | `vitest.config.ts`     |
| **React 应用**   | Vitest             | jsdom    | `vitest.config.ts`     |
| **React 组件库** | Vitest + Storybook | jsdom    | `vitest.config.ts`     |
| **E2E 测试**     | Playwright         | Browser  | `playwright.config.ts` |

### 3. 为什么选择 Vitest？

**优势**：

- **速度**：基于 Vite，测试启动和热更新极快
- **ESM 原生**：无需额外配置即可支持 ES Modules
- ** Jest 兼容**：API 与 Jest 兼容，迁移成本低
- **Watch 模式**：智能监听变更，仅运行相关测试
- **内置覆盖率**：使用 v8 覆盖率，性能优异
- **TypeScript 支持**：开箱即用

**与 Jest 对比**：

| 特性       | Vitest        | Jest            |
| ---------- | ------------- | --------------- |
| ESM 支持   | ✅ 原生       | ⚠️ 需配置       |
| 启动速度   | 🚀 极快       | 🐢 较慢         |
| Watch 模式 | ✅ 智能热更新 | ⚠️ 全量重跑     |
| Vite 集成  | ✅ 共享配置   | ❌ 需单独配置   |
| TypeScript | ✅ 开箱即用   | ⚠️ 需要 ts-jest |

---

## 配置文件架构

```
project/
├── vitest.config.ts       # 主测试配置
├── vitest.setup.ts        # 测试环境设置（可选）
├── tsconfig.spec.json     # 测试 TypeScript 配置
└── src/
    ├── __tests__/         # 测试文件目录
    └── **/*.spec.ts       # 测试文件
```

---

## NestJS 测试配置

### vitest.config.ts

```typescript
// apps/api/vitest.config.ts
import { defineConfig } from 'vitest/config';
import { join } from 'path';
import swc from 'unplugin-swc';

export default defineConfig({
  test: {
    globals: true,
    environment: 'node',
    include: [join(__dirname, 'src/**/*.spec.ts')],
    exclude: ['node_modules', 'dist'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'lcov', 'html'],
      exclude: [
        'node_modules/**',
        'dist/**',
        '**/*.spec.ts',
        '**/*.e2e-spec.ts',
        '**/main.ts',
      ],
    },
    testTimeout: 10000,
    hookTimeout: 10000,
  },
  plugins: [
    swc.vite({
      jsc: {
        parser: {
          syntax: 'typescript',
          tsx: true,
          dynamicImport: true,
          decorators: true,
        },
        transform: {
          legacyDecorator: true,
          decoratorMetadata: true,
        },
      },
    }),
  ],
});
```

### tsconfig.spec.json

```json
// apps/api/tsconfig.spec.json
{
  "extends": "./tsconfig.json",
  "compilerOptions": {
    "outDir": "../../dist/out-tsc",
    "module": "commonjs",
    "types": ["node", "vitest/globals"],
    "experimentalDecorators": true,
    "emitDecoratorMetadata": true,
    "target": "es2021",
    "moduleResolution": "node",
    "esModuleInterop": true
  },
  "include": ["src/**/*.spec.ts", "src/**/*.ts"]
}
```

### 测试文件示例

```typescript
// apps/api/src/app/app.controller.spec.ts
import { describe, it, expect, beforeEach } from 'vitest';
import { AppController } from './app.controller';
import { AppService } from './app.service';

describe('AppController', () => {
  let appController: AppController;
  let appService: AppService;

  beforeEach(() => {
    appService = new AppService();
    appController = new AppController(appService);
  });

  describe('getHello', () => {
    it('should return "Hello World!"', () => {
      expect(appController.getHello()).toBe('Hello World!');
    });
  });
});
```

---

## React 测试配置

### vitest.config.ts

```typescript
// apps/web/vitest.config.ts
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';
import { join } from 'path';

export default defineConfig({
  plugins: [react()],
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: ['./vitest.setup.ts'],
    include: [join(__dirname, 'src/**/*.test.{ts,tsx}')],
    exclude: ['node_modules', 'dist', 'e2e'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'lcov', 'html'],
      exclude: [
        'node_modules/**',
        'dist/**',
        '**/*.test.{ts,tsx}',
        '**/*.d.ts',
        'src/main.tsx',
        'src/vite-env.d.ts',
      ],
    },
  },
  resolve: {
    alias: {
      '@': join(__dirname, './src'),
    },
  },
});
```

### vitest.setup.ts

```typescript
// apps/web/vitest.setup.ts
import '@testing-library/jest-dom/vitest';
import { cleanup } from '@testing-library/react';
import { afterEach } from 'vitest';

// 每个测试后自动清理
afterEach(() => {
  cleanup();
});

// Mock window.matchMedia
Object.defineProperty(window, 'matchMedia', {
  writable: true,
  value: (query) => ({
    matches: false,
    media: query,
    onchange: null,
    addListener: () => {},
    removeListener: () => {},
    addEventListener: () => {},
    removeEventListener: () => {},
    dispatchEvent: () => false,
  }),
});
```

### 测试文件示例

```typescript
// apps/web/src/components/Button.test.tsx
import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { Button } from './Button';

describe('Button', () => {
  it('should render with text', () => {
    render(<Button>Click me</Button>);
    expect(screen.getByRole('button', { name: /click me/i })).toBeInTheDocument();
  });

  it('should call onClick when clicked', async () => {
    const user = userEvent.setup();
    const onClick = vi.fn();

    render(<Button onClick={onClick}>Click me</Button>);
    await user.click(screen.getByRole('button'));

    expect(onClick).toHaveBeenCalledTimes(1);
  });

  it('should be disabled when disabled prop is true', () => {
    render(<Button disabled>Click me</Button>);
    expect(screen.getByRole('button')).toBeDisabled();
  });
});
```

---

## 测试环境配置

### Node.js 环境（后端）

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    environment: 'node',
    globals: true,
    // Node.js 特定配置
    pool: 'threads', // 使用线程池
    poolOptions: {
      threads: {
        singleThread: false,
        minThreads: 1,
        maxThreads: 4,
      },
    },
  },
});
```

### jsdom 环境（前端）

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    environment: 'jsdom',
    globals: true,
    // jsdom 特定配置
    environmentOptions: {
      jsdom: {
        url: 'http://localhost:3000',
        pretendToBeVisual: true,
      },
    },
  },
});
```

---

## 覆盖率配置

### 覆盖率目标

| 项目类型   | 语句覆盖率 | 分支覆盖率 | 函数覆盖率 | 行覆盖率 |
| ---------- | ---------- | ---------- | ---------- | -------- |
| **核心库** | 90%        | 85%        | 90%        | 90%      |
| **应用**   | 80%        | 75%        | 80%        | 80%      |
| **工具库** | 95%        | 90%        | 95%        | 95%      |

### 覆盖率配置

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    coverage: {
      provider: 'v8',
      reporter: ['text', 'lcov', 'html', 'json'],

      // 覆盖率阈值
      thresholds: {
        statements: 80,
        branches: 75,
        functions: 80,
        lines: 80,
      },

      // 排除文件
      exclude: [
        'node_modules/**',
        'dist/**',
        '**/*.spec.ts',
        '**/*.test.ts',
        '**/*.e2e-spec.ts',
        '**/index.ts',
        '**/main.ts',
        '**/*.d.ts',
        '**/*.config.ts',
      ],

      // 包含文件
      include: ['src/**/*.{ts,tsx}'],

      // 是否在 CI 中失败
      all: true,
    },
  },
});
```

### 覆盖率报告

```bash
# 生成覆盖率报告
pnpm nx test <project> --coverage

# 查看 HTML 报告
open coverage/<project>/index.html
```

---

## 测试最佳实践

### 1. 测试文件命名

| 类型     | 命名模式        | 示例                  |
| -------- | --------------- | --------------------- |
| 单元测试 | `*.spec.ts`     | `app.service.spec.ts` |
| 组件测试 | `*.test.tsx`    | `Button.test.tsx`     |
| E2E 测试 | `*.e2e-spec.ts` | `auth.e2e-spec.ts`    |

### 2. 测试组织结构

```
src/
├── app/
│   ├── app.module.ts
│   ├── app.controller.ts
│   ├── app.controller.spec.ts    # 单元测试
│   ├── app.service.ts
│   └── app.service.spec.ts       # 单元测试
├── __tests__/                     # 集成测试
│   └── app.integration.spec.ts
└── e2e/                           # E2E 测试
    └── app.e2e-spec.ts
```

### 3. 使用 Vitest 全局变量

```typescript
// ✅ 推荐：使用全局变量（需配置 globals: true）
import { describe, it, expect, beforeEach, vi } from 'vitest';

describe('MyService', () => {
  it('should work', () => {
    expect(true).toBe(true);
  });
});

// ⚠️ 替代方案：显式导入
import { test, expect } from 'vitest';

test('should work', () => {
  expect(true).toBe(true);
});
```

### 4. Mock 策略

**日期 Mock**:

```typescript
import { vi, beforeEach, afterEach } from 'vitest';

beforeEach(() => {
  vi.useFakeTimers();
  vi.setSystemTime(new Date('2024-01-01'));
});

afterEach(() => {
  vi.useRealTimers();
});
```

**依赖 Mock**:

```typescript
import { vi } from 'vitest';

// 模块 Mock
vi.mock('@/services/api', () => ({
  fetchUser: vi.fn(() => Promise.resolve({ id: 1, name: 'Test' })),
}));

// 部分模块 Mock
vi.mock('@/services/api', async (importOriginal) => {
  const actual = await importOriginal();
  return {
    ...actual,
    fetchUser: vi.fn(() => Promise.resolve({ id: 1 })),
  };
});
```

**NestJS 服务 Mock**:

```typescript
import { Test, TestingModule } from '@nestjs/testing';

describe('AppController', () => {
  let appController: AppController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [AppController],
      providers: [
        {
          provide: AppService,
          useValue: {
            getHello: vi.fn(() => 'Mocked Hello'),
          },
        },
      ],
    }).compile();

    appController = module.get<AppController>(AppController);
  });

  it('should return mocked hello', () => {
    expect(appController.getHello()).toBe('Mocked Hello');
  });
});
```

### 5. 异步测试

```typescript
describe('Async Operations', () => {
  it('should handle async/await', async () => {
    const result = await fetchData();
    expect(result).toBeDefined();
  });

  it('should handle promises', () => {
    return expect(fetchData()).resolves.toEqual({ data: 'test' });
  });

  it('should reject with error', async () => {
    await expect(fetchError()).rejects.toThrow('Error message');
  });
});
```

---

## CI/CD 集成

### GitHub Actions 配置

```yaml
# .github/workflows/test.yml
name: Test

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'pnpm'

      - name: Install dependencies
        run: pnpm install --frozen-lockfile

      - name: Run tests
        run: pnpm nx run-many --target=test --all --coverage

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info
```

### Nx 命令

```bash
# 运行所有测试
pnpm nx run-many --target=test --all

# 运行受影响项目的测试
pnpm nx affected --target=test

# 运行带覆盖率
pnpm nx test <project> --coverage

# 并行运行
pnpm nx run-many --target=test --all --parallel=4
```

---

## E2E 测试（Playwright）

### playwright.config.ts

```typescript
// apps/web-e2e/playwright.config.ts
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './src',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,

  reporter: [['html'], ['junit', { outputFile: 'test-results/junit.xml' }]],

  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },

  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },
    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
    },
  ],

  webServer: {
    command: 'pnpm nx serve web',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
});
```

### E2E 测试示例

```typescript
// apps/web-e2e/src/login.spec.ts
import { test, expect } from '@playwright/test';

test.describe('Login Flow', () => {
  test('should login successfully', async ({ page }) => {
    await page.goto('/login');

    await page.fill('[name="email"]', 'test@example.com');
    await page.fill('[name="password"]', 'password123');
    await page.click('button[type="submit"]');

    await expect(page).toHaveURL('/dashboard');
    await expect(page.locator('h1')).toContainText('Welcome');
  });

  test('should show error for invalid credentials', async ({ page }) => {
    await page.goto('/login');

    await page.fill('[name="email"]', 'invalid@example.com');
    await page.fill('[name="password"]', 'wrong');
    await page.click('button[type="submit"]');

    await expect(page.locator('.error-message')).toBeVisible();
  });
});
```

---

## 测试依赖

### NestJS 应用

```json
{
  "devDependencies": {
    "vitest": "^4.0.0",
    "@vitest/coverage-v8": "^4.0.0",
    "@nestjs/testing": "^11.0.0",
    "unplugin-swc": "^1.5.0"
  }
}
```

### React 应用

```json
{
  "devDependencies": {
    "vitest": "^4.0.0",
    "@vitest/coverage-v8": "^4.0.0",
    "@testing-library/react": "^14.0.0",
    "@testing-library/jest-dom": "^6.0.0",
    "@testing-library/user-event": "^14.0.0",
    "jsdom": "^24.0.0"
  }
}
```

### E2E 测试

```json
{
  "devDependencies": {
    "@playwright/test": "^1.40.0"
  }
}
```

---

## 常见问题

### Q: Vitest 与 Jest 的主要区别？

A:
| 特性 | Vitest | Jest |
|------|--------|------|
| 配置 | 继承 Vite 配置 | 需要 jest.config.js |
| ESM | 原生支持 | 需要 @jest/globals |
| Mock | vi.fn() | jest.fn() |
| 快照 | 内置 | 需要 jest-snapshot |
| 启动时间 | 毫秒级 | 秒级 |

### Q: 如何迁移 Jest 到 Vitest？

A:

1. 安装 Vitest: `pnpm add -D vitest @vitest/coverage-v8`
2. 创建 `vitest.config.ts`
3. 全局替换：
   - `jest.fn()` → `vi.fn()`
   - `jest.mock()` → `vi.mock()`
   - `jest.spyOn()` → `vi.spyOn()`
4. 更新 `tsconfig.spec.json` 的 types 为 `["vitest/globals"]`
5. 移除 Jest 相关依赖

### Q: 如何在 CI 中加速测试？

A:

```yaml
# 使用 Nx 缓存
- name: Cache Nx
  uses: actions/cache@v3
  with:
    path: .nx/cache
    key: nx-${{ hashFiles('pnpm-lock.yaml') }}

# 使用分片
- name: Run tests
  run: pnpm nx run-many --target=test --all --shard=${{ matrix.shard }}
  strategy:
    matrix:
      shard: [1/4, 2/4, 3/4, 4/4]
```

### Q: 如何调试测试？

A:

```bash
# 使用 Vitest UI
pnpm vitest --ui

# 使用 Node 调试器
pnpm vitest --inspect-brk

# VS Code 调试
# .vscode/launch.json
{
  "type": "node",
  "request": "launch",
  "name": "Debug Tests",
  "runtimeExecutable": "pnpm",
  "runtimeArgs": ["vitest", "run", "--inspect-brk"],
  "console": "integratedTerminal"
}
```

---

## 快速参考

### Vitest CLI 命令

```bash
# 运行所有测试
pnpm vitest run

# Watch 模式
pnpm vitest

# 运行特定文件
pnpm vitest run app.service.spec.ts

# 生成覆盖率
pnpm vitest run --coverage

# 更新快照
pnpm vitest run -u

# 并行运行
pnpm vitest run --threads

# UI 模式
pnpm vitest --ui
```

### 常用断言

```typescript
// 基本断言
expect(value).toBe(expected);
expect(value).toEqual(expected);
expect(value).toBeTruthy();
expect(value).toBeFalsy();
expect(value).toBeNull();
expect(value).toBeUndefined();
expect(value).toBeDefined();

// 数字
expect(value).toBeGreaterThan(10);
expect(value).toBeLessThan(20);
expect(value).toBeCloseTo(10.5, 2);

// 字符串
expect(string).toMatch(/regex/);
expect(string).toContain('substring');

// 数组
expect(array).toHaveLength(3);
expect(array).toContain(item);
expect(array).toContainEqual({ id: 1 });

// 对象
expect(object).toHaveProperty('name');
expect(object).toHaveProperty('address.city', 'Tokyo');

// 异常
expect(() => fn()).toThrow();
expect(() => fn()).toThrow(Error);
expect(() => fn()).toThrow('error message');

// 异步
await expect(promise).resolves.toBe(value);
await expect(promise).rejects.toThrow();

// Mock
expect(mockFn).toHaveBeenCalled();
expect(mockFn).toHaveBeenCalledWith(arg1, arg2);
expect(mockFn).toHaveBeenCalledTimes(2);
```

---

## 总结

| 维度         | 选择       | 原因                      |
| ------------ | ---------- | ------------------------- |
| **单元测试** | Vitest     | 快速、ESM 原生、Vite 集成 |
| **前端环境** | jsdom      | 模拟浏览器 API            |
| **后端环境** | Node.js    | 原生 Node.js API          |
| **覆盖率**   | v8         | 高性能                    |
| **E2E 测试** | Playwright | 跨浏览器、现代化 API      |

**核心原则**：

1. **Vitest** 作为统一测试框架
2. **覆盖率** 作为质量门禁
3. **测试分类**：单元测试 + 集成测试 + E2E 测试
4. **CI 集成**：自动化测试流程
5. **Mock 策略**：合理隔离依赖
