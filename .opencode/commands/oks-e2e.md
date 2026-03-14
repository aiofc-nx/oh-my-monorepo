---
description: E2E 端到端测试（Playwright）
agent: build
argument-hint: '<功能名称>'
---

## ⚠️ 参数验证

!`if [ -z "$ARGUMENTS" ]; then
  echo "❌ **错误: 缺少功能名称**"
  echo ""
  echo "**用法**: /oks-e2e <功能名称>"
  echo ""
  echo "**示例**: /oks-e2e 用户登录"
  exit 1
fi`

---

## 🔒 前置条件检查

!`
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

# 检查实现阶段是否完成

if [ ! -d "$REPO_ROOT/src/modules" ]; then
echo "❌ **前置条件未满足**"
echo ""
echo "缺失: 服务实现代码"
echo ""
echo "**解决方案**:"
echo " /oks-implementation $ARGUMENTS"
exit 1
fi

echo "✅ 前置条件检查通过"
`

---

# E2E 端到端测试

使用 Playwright 验证完整用户流程。

---

## 当前任务

功能名称: **$ARGUMENTS**

## 项目上下文

当前分支: !`git branch --show-current`

---

## 前置条件

- [ ] 服务实现已完成（阶段六）
- [ ] 本地服务可启动
- [ ] Playwright 已配置

如果未完成，先运行：

```bash
/oks-implementation $ARGUMENTS
```

---

## E2E 测试类型

| 类型     | 说明              | 工具           |
| -------- | ----------------- | -------------- |
| 用户流程 | 完整业务流程验证  | Playwright     |
| 页面交互 | UI 组件交互测试   | Playwright     |
| API 集成 | 多服务集成测试    | Playwright/API |
| 视觉回归 | UI 视觉一致性测试 | Percy          |

---

## 执行步骤

### 1. 确认 Playwright 配置

检查 `playwright.config.ts` 是否存在：

!`
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

if [ -f "$REPO_ROOT/playwright.config.ts" ]; then
echo "✅ Playwright 配置已存在"
elif [ -f "$REPO_ROOT/e2e/playwright.config.ts" ]; then
echo "✅ Playwright 配置已存在 (e2e/)"
else
echo "⚠️ Playwright 配置不存在"
echo ""
echo "初始化命令:"
echo " pnpm nx g @oksai/react:playwright-e2e --project=<project>"
fi
`

### 2. 创建 E2E 测试文件

**文件位置**: `e2e/{feature}.spec.ts`

```typescript
// e2e/{feature}.spec.ts
import { test, expect } from '@playwright/test';

test.describe('{功能名称}', () => {
  test.beforeEach(async ({ page }) => {
    // 前置条件：登录等
  });

  test('成功场景描述', async ({ page }) => {
    // 1. 访问页面
    await page.goto('/path');

    // 2. 执行操作
    await page.fill('[name="field"]', 'value');
    await page.click('button[type="submit"]');

    // 3. 验证结果
    await expect(page).toHaveURL('/expected-path');
    await expect(page.locator('.element')).toContainText('预期文本');
  });

  test('失败场景描述', async ({ page }) => {
    // 测试错误处理
  });

  test('边界场景描述', async ({ page }) => {
    // 测试边界条件
  });
});
```

### 3. 编写测试场景

#### 3.1 场景覆盖要求

| 场景类型    | 最少数量 | 说明         |
| ----------- | -------- | ------------ |
| Happy Path  | 1-2      | 正常用户流程 |
| Error Cases | 1-2      | 错误处理     |
| Edge Cases  | 1        | 边界条件     |

#### 3.2 从 BDD 场景转换

如果已有 BDD 场景（`features/{feature}.feature`），转换为 E2E 测试：

```gherkin
# BDD 场景
Scenario: 成功登录
  Given 用户在登录页面
  When 用户输入邮箱和密码
  Then 用户成功登录
```

```typescript
// E2E 测试
test('成功登录', async ({ page }) => {
  // Given
  await page.goto('/login');

  // When
  await page.fill('[name="email"]', 'test@example.com');
  await page.fill('[name="password"]', 'Password123');
  await page.click('button[type="submit"]');

  // Then
  await expect(page).toHaveURL('/dashboard');
});
```

### 4. 运行测试

```bash
# 运行所有 E2E 测试
pnpm playwright test

# 运行特定文件
pnpm playwright test e2e/{feature}.spec.ts

# 带界面运行
pnpm playwright test --ui

# 调试模式
pnpm playwright test --debug

# 生成测试报告
pnpm playwright show-report
```

---

## 测试模板

### 用户登录示例

```typescript
// e2e/user-login.spec.ts
import { test, expect } from '@playwright/test';

test.describe('用户登录', () => {
  test.use({ storageState: { cookies: [], origins: [] } });

  test('成功登录流程', async ({ page }) => {
    // 1. 访问登录页
    await page.goto('/login');
    await expect(page).toHaveTitle(/登录/);

    // 2. 输入凭据
    await page.fill('[name="email"]', 'test@example.com');
    await page.fill('[name="password"]', 'Password123');

    // 3. 点击登录
    await page.click('button[type="submit"]');

    // 4. 验证跳转
    await expect(page).toHaveURL('/dashboard');

    // 5. 验证欢迎消息
    await expect(page.locator('.welcome')).toContainText('欢迎');

    // 6. 验证性能
    expect(
      page.performance.getEntriesByType('navigation')[0].duration,
    ).toBeLessThan(3000);
  });

  test('登录失败显示错误', async ({ page }) => {
    await page.goto('/login');

    await page.fill('[name="email"]', 'test@example.com');
    await page.fill('[name="password"]', 'wrongpassword');
    await page.click('button[type="submit"]');

    await expect(page.locator('.error')).toContainText('邮箱或密码错误');
    await expect(page).toHaveURL('/login');
  });

  test('表单验证', async ({ page }) => {
    await page.goto('/login');

    // 空表单提交
    await page.click('button[type="submit"]');

    await expect(page.locator('[name="email"] + .error')).toBeVisible();
    await expect(page.locator('[name="password"] + .error')).toBeVisible();
  });

  test('响应式布局', async ({ page }) => {
    // 移动端
    await page.setViewportSize({ width: 375, height: 667 });
    await page.goto('/login');
    await expect(page.locator('.login-form')).toBeVisible();

    // 桌面端
    await page.setViewportSize({ width: 1280, height: 720 });
    await expect(page.locator('.login-form')).toBeVisible();
  });
});
```

### API 集成测试示例

```typescript
// e2e/api-integration.spec.ts
import { test, expect } from '@playwright/test';

test.describe('API 集成', () => {
  test('完整订单流程', async ({ page, request }) => {
    // 1. 创建订单
    const createResponse = await request.post('/api/orders', {
      data: { productId: '123', quantity: 1 },
    });
    expect(createResponse.ok()).toBeTruthy();
    const order = await createResponse.json();

    // 2. 验证订单状态
    const getResponse = await request.get(`/api/orders/${order.id}`);
    expect(getResponse.ok()).toBeTruthy();

    // 3. 页面验证
    await page.goto(`/orders/${order.id}`);
    await expect(page.locator('.order-status')).toContainText('待支付');
  });
});
```

---

## 最佳实践

### 1. 选择器策略

| 优先级 | 选择器类型      | 示例                                         |
| ------ | --------------- | -------------------------------------------- |
| 1      | test-id         | `page.locator('[data-testid="submit"]')`     |
| 2      | role + name     | `page.getByRole('button', { name: '提交' })` |
| 3      | label           | `page.getByLabel('邮箱')`                    |
| 4      | placeholder     | `page.getByPlaceholder('请输入')`            |
| 5      | CSS（最后选择） | `page.locator('.submit-btn')`                |

### 2. 等待策略

```typescript
// ✅ 推荐：使用 auto-waiting
await expect(page.locator('.element')).toBeVisible();

// ✅ 推荐：明确等待条件
await page.waitForSelector('.loaded');

// ❌ 避免：硬编码等待
await page.waitForTimeout(1000); // 不推荐
```

### 3. 测试隔离

```typescript
// 每个测试独立状态
test.use({ storageState: { cookies: [], origins: [] } });

// 或使用 beforeAll/afterAll
test.beforeEach(async ({ page }) => {
  await page.goto('/');
});
```

### 4. Page Object 模式

```typescript
// pages/LoginPage.ts
export class LoginPage {
  constructor(private page: Page) {}

  async goto() {
    await this.page.goto('/login');
  }

  async login(email: string, password: string) {
    await this.page.fill('[name="email"]', email);
    await this.page.fill('[name="password"]', password);
    await this.page.click('button[type="submit"]');
  }
}

// 使用
test('登录', async ({ page }) => {
  const loginPage = new LoginPage(page);
  await loginPage.goto();
  await loginPage.login('test@example.com', 'password');
});
```

---

## 检查清单

### 测试覆盖

- [ ] 覆盖核心用户流程
- [ ] 测试错误处理
- [ ] 验证表单输入
- [ ] 测试响应式布局
- [ ] 验证页面性能

### 代码质量

- [ ] 使用 Page Object 模式
- [ ] 选择器语义化
- [ ] 测试独立可重复
- [ ] 无硬编码等待

### CI 集成

- [ ] 测试在 CI 环境通过
- [ ] 测试报告生成
- [ ] 失败截图/视频保存

---

## 常见问题

### Q: 如何处理登录状态？

A: 使用 `storageState` 保存和复用登录状态：

```typescript
// auth.setup.ts
import { test as setup } from '@playwright/test';

setup('authenticate', async ({ page }) => {
  await page.goto('/login');
  await page.fill('[name="email"]', 'test@example.com');
  await page.fill('[name="password"]', 'Password123');
  await page.click('button[type="submit"]');
  await page.waitForURL('/dashboard');
  await page.context().storageState({ path: 'auth.json' });
});

// playwright.config.ts
export default defineConfig({
  projects: [
    { name: 'setup', testMatch: /auth\.setup\.ts/ },
    {
      name: 'tests',
      dependencies: ['setup'],
      use: { storageState: 'auth.json' },
    },
  ],
});
```

### Q: 如何调试失败的测试？

A: 使用调试模式或查看追踪：

```bash
# 调试模式
pnpm playwright test --debug

# 查看追踪
pnpm playwright test --trace on
pnpm playwright show-trace trace.zip
```

### Q: 如何处理动态内容？

A: 使用 `waitFor` 系列方法：

```typescript
// 等待元素出现
await page.waitForSelector('.loaded');

// 等待请求完成
await page.waitForResponse('**/api/data');

// 等待网络空闲
await page.waitForLoadState('networkidle');
```

---

## 阶段完成条件

- [ ] E2E 测试文件已创建
- [ ] 覆盖 Happy/Error/Edge 场景
- [ ] 所有测试通过
- [ ] 测试在 CI 环境通过
- [ ] 测试报告已生成

验证命令:

```bash
# 运行 E2E 测试
pnpm playwright test

# 生成报告
pnpm playwright show-report
```

---

## 下一步

完成 E2E 测试后，可以：

1. **继续优化**: 运行 `/oks-optimization $ARGUMENTS` 进行代码优化
2. **运行所有测试**: `pnpm vitest run && pnpm playwright test`
3. **提交代码**: `git add . && git commit`

---

## 相关命令

| 命令                  | 说明             |
| --------------------- | ---------------- |
| `/oks-implementation` | 服务实现（前置） |
| `/oks-optimization`   | 代码优化（后续） |
| `/oks-help`           | 查看命令帮助     |

---

## 参考资源

- [Playwright 官方文档](https://playwright.dev/)
- [Playwright 最佳实践](https://playwright.dev/docs/best-practices)
- [Page Object 模式](https://playwright.dev/docs/pom)
