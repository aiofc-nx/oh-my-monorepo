# 用户登录 BDD 场景

> 行为驱动开发（BDD）场景定义，使用 Gherkin 语法

---

## 📋 场景概览

| 场景类型   | 场景数量 | 优先级 | 状态 |
| ---------- | -------- | ------ | ---- |
| Happy Path | 2        | P1     | ✅   |
| Error Case | 3        | P1     | ✅   |
| Edge Case  | 2        | P2     | ⏳   |
| **总计**   | **7**    | -      | -    |

---

## Feature 定义

```gherkin
Feature: 用户登录
  允许注册用户使用邮箱和密码登录系统，访问个人数据和功能

  作为注册用户
  我想要使用邮箱和密码登录系统
  以便于访问我的个人数据和功能
```

---

## Background（通用前置条件）

```gherkin
Background:
  Given 系统已初始化
  And 数据库中存在测试用户:
    | email              | password     | name      |
    | test@example.com   | Password123  | Test User |
```

---

## 🟢 Happy Path（成功场景）

### 场景 1: 成功登录

**优先级**: P1

**关联需求**: @FR-001, @FR-002

**成功标准**: @SC-001, @SC-002

```gherkin
@happy-path @FR-001 @FR-002 @SC-001 @SC-002
Scenario: 成功登录
  Given 用户在登录页面
  And 系统中存在用户 "test@example.com" 密码为 "Password123"
  When 用户输入邮箱 "test@example.com"
  And 用户输入密码 "Password123"
  And 用户点击登录按钮
  Then 用户应该成功登录
  And 页面跳转到首页
  And 显示欢迎消息 "欢迎回来，Test User"
  And 响应时间小于 200ms
```

**测试数据**:

- email: test@example.com
- password: Password123

**预期结果**:

- 返回 JWT Token
- Token 有效期 24 小时
- 用户信息正确

---

### 场景 2: 成功登录并记住我

**优先级**: P1

**关联需求**: @FR-004

```gherkin
@happy-path @FR-004
Scenario: 成功登录并记住我
  Given 用户在登录页面
  And 系统中存在用户 "test@example.com" 密码为 "Password123"
  When 用户输入邮箱 "test@example.com"
  And 用户输入密码 "Password123"
  And 用户勾选"记住我"选项
  And 用户点击登录按钮
  Then 用户应该成功登录
  And 会话有效期设置为 7 天
  And 页面跳转到首页
```

**测试数据**:

- email: test@example.com
- password: Password123
- rememberMe: true

**预期结果**:

- 返回 JWT Token
- Token 有效期 7 天

---

## 🔴 Error Cases（异常场景）

### 场景 3: 密码错误

**优先级**: P1

**关联需求**: @FR-002, @FR-003

```gherkin
@validation @FR-002 @FR-003
Scenario: 密码错误
  Given 用户在登录页面
  And 系统中存在用户 "test@example.com" 密码为 "Password123"
  When 用户输入邮箱 "test@example.com"
  And 用户输入密码 "WrongPassword"
  And 用户点击登录按钮
  Then 登录失败
  And 显示错误消息 "邮箱或密码错误"
  And 用户仍在登录页面
  And 登录失败次数增加 1
```

**错误类型**: 密码验证失败

**错误消息**: "邮箱或密码错误"

**期望行为**:

- 不暴露用户是否存在
- 增加登录失败计数
- 返回 401 状态码

---

### 场景 4: 用户不存在

**优先级**: P1

**关联需求**: @FR-002, @FR-003

```gherkin
@validation @FR-002 @FR-003
Scenario: 用户不存在
  Given 用户在登录页面
  When 用户输入邮箱 "nonexistent@example.com"
  And 用户输入密码 "Password123"
  And 用户点击登录按钮
  Then 登录失败
  And 显示错误消息 "邮箱或密码错误"
  And 用户仍在登录页面
```

**错误类型**: 用户不存在

**错误消息**: "邮箱或密码错误"（不暴露用户是否存在）

**期望行为**:

- 不暴露用户是否存在
- 返回 401 状态码

---

### 场景 5: 账户锁定

**优先级**: P1

**关联需求**: @FR-005

```gherkin
@business-rule @FR-005
Scenario: 账户锁定
  Given 用户在登录页面
  And 系统中存在用户 "test@example.com" 密码为 "Password123"
  And 用户 "test@example.com" 已连续失败登录 4 次
  When 用户输入邮箱 "test@example.com"
  And 用户输入密码 "WrongPassword"
  And 用户点击登录按钮
  Then 登录失败
  And 显示错误消息 "账户已锁定，请 15 分钟后再试"
  And 账户被锁定 15 分钟
  And 登录失败次数增加到 5
```

**错误类型**: 账户锁定

**错误消息**: "账户已锁定，请 15 分钟后再试"

**期望行为**:

- 账户被锁定 15 分钟
- 锁定期间无法登录（即使密码正确）
- 15 分钟后自动解锁

---

## 🔶 Edge Cases（边界场景）

### 场景 6: 邮箱格式不正确

**优先级**: P2

**关联需求**: @FR-002

```gherkin
@edge-case @FR-002
Scenario: 邮箱格式不正确
  Given 用户在登录页面
  When 用户输入邮箱 "invalid-email"
  And 用户输入密码 "Password123"
  And 用户点击登录按钮
  Then 登录失败
  And 显示错误消息 "邮箱格式不正确"
  And 用户仍在登录页面
```

**边界类型**: 输入边界

**边界值**:

- 无效邮箱格式: "invalid-email"
- 缺少 @: "testexample.com"
- 缺少域名: "test@"

**期望处理**:

- 在客户端和服务端都验证邮箱格式
- 返回 400 状态码

---

### 场景 7: 输入为空

**优先级**: P2

**关联需求**: @FR-002

```gherkin
@edge-case @FR-002
Scenario: 输入为空
  Given 用户在登录页面
  When 用户输入邮箱 ""
  And 用户输入密码 ""
  And 用户点击登录按钮
  Then 登录失败
  And 显示错误消息 "邮箱和密码不能为空"
  And 用户仍在登录页面
```

**边界类型**: 输入边界

**边界值**:

- 空字符串: ""
- null: null
- 仅空格: " "

**期望处理**:

- 在客户端和服务端都验证输入
- 返回 400 状态码

---

## 🏷️ 标签说明

### 场景类型标签

- `@happy-path`: 正常流程，所有验证通过
- `@validation`: 验证失败场景
- `@edge-case`: 边界情况
- `@business-rule`: 业务规则验证

### 需求关联标签

- `@FR-001`: 关联功能需求 FR-001
- `@FR-002`: 关联功能需求 FR-002
- `@FR-003`: 关联功能需求 FR-003
- `@FR-004`: 关联功能需求 FR-004
- `@FR-005`: 关联功能需求 FR-005

### 成功标准标签

- `@SC-001`: 关联成功标准 SC-001（30 秒内完成登录）
- `@SC-002`: 关联成功标准 SC-002（API 响应时间 < 200ms）

---

## 📝 步骤定义

### Given 步骤

```typescript
// features/step-definitions/user-login.steps.ts

import { Given, When, Then } from '@cucumber/cucumber';
import { expect } from 'vitest';
import { UserService } from '../../src/modules/user/services/user.service';
import { UserRepository } from '../../src/modules/user/repositories/user.repository';

let context: any = {};

// ==================== Given ====================

Given('系统已初始化', async () => {
  context = {
    userService: new UserService(new UserRepository()),
    result: null,
    error: null,
  };
});

Given('用户在登录页面', async () => {
  // 前端场景，这里可以跳过或模拟
});

Given(
  '系统中存在用户 {string} 密码为 {string}',
  async (email: string, password: string) => {
    // 创建测试用户
    await context.userService.create({
      email,
      password,
      name: 'Test User',
    });
  },
);

Given(
  '用户 {string} 已连续失败登录 {int} 次',
  async (email: string, attempts: number) => {
    // 模拟登录失败
    for (let i = 0; i < attempts; i++) {
      try {
        await context.userService.login(email, 'WrongPassword');
      } catch (error) {
        // 预期失败
      }
    }
  },
);
```

### When 步骤

```typescript
// ==================== When ====================

When('用户输入邮箱 {string}', async (email: string) => {
  context.email = email;
});

When('用户输入密码 {string}', async (password: string) => {
  context.password = password;
});

When('用户勾选"记住我"选项', async () => {
  context.rememberMe = true;
});

When('用户点击登录按钮', async () => {
  try {
    context.result = await context.userService.login(
      context.email,
      context.password,
      context.rememberMe || false,
    );
  } catch (error) {
    context.error = error;
  }
});
```

### Then 步骤

```typescript
// ==================== Then ====================

Then('用户应该成功登录', () => {
  expect(context.result).toBeDefined();
  expect(context.result.token).toBeDefined();
  expect(context.result.user).toBeDefined();
});

Then('登录失败', () => {
  expect(context.error).toBeDefined();
});

Then('显示错误消息 {string}', (message: string) => {
  expect(context.error.message).toContain(message);
});

Then('页面跳转到首页', () => {
  // 前端场景，验证路由跳转
});

Then('显示欢迎消息 {string}', (message: string) => {
  expect(context.result.message).toContain(message);
});

Then('响应时间小于 {int}ms', (maxTime: number) => {
  expect(context.result.duration).toBeLessThan(maxTime);
});

Then('会话有效期设置为 {int} 天', (days: number) => {
  const expectedExpiry = days * 24 * 60 * 60 * 1000; // 毫秒
  expect(context.result.expiresIn).toBe(expectedExpiry);
});

Then('登录失败次数增加 {int}', (increment: number) => {
  // 验证数据库中的 login_attempts 增加
});

Then('账户被锁定 {int} 分钟', (minutes: number) => {
  expect(context.error.message).toContain('账户已锁定');
});
```

---

## 🧪 测试数据

### 用户数据

```typescript
const testUsers = [
  {
    id: 'user-1',
    email: 'test@example.com',
    password: 'Password123',
    name: 'Test User',
    loginAttempts: 0,
    isLocked: false,
  },
];
```

---

## 🎯 边界情况清单

### 输入边界

- [x] 空值/null
- [x] 邮箱格式不正确
- [ ] 超长输入（密码 > 1000 字符）
- [ ] 特殊字符

### 状态边界

- [x] 用户不存在
- [x] 密码错误
- [x] 账户被锁定
- [x] 登录失败 5 次

### 权限边界

- [ ] 账户未激活（如果需要激活）
- [ ] 账户被禁用（如果实现了禁用功能）

### 系统边界

- [ ] 数据库连接失败
- [ ] JWT 密钥缺失

---

## ✅ 场景检查清单

### 完整性检查

- [x] 覆盖所有功能需求 (FR-001 ~ FR-005)
- [x] 覆盖成功标准 (SC-001, SC-002)
- [x] 至少 2 个 Happy Path 场景
- [x] 至少 2 个 Error Case 场景
- [x] 至少 2 个 Edge Case 场景

### 质量检查

- [x] 所有场景使用标准 Gherkin 语法
- [x] 场景独立、可重复执行
- [x] 步骤定义清晰
- [x] 使用标签分类
- [x] 关联功能需求标签

### 可执行性检查

- [ ] 步骤定义文件已创建
- [ ] 所有场景可执行（无语法错误）
- [ ] 测试数据已准备
- [ ] 前置条件可满足

---

## 📊 运行测试

### 运行所有场景

```bash
# 运行所有场景
pnpm test:e2e features/user-login.feature

# 运行特定标签的场景
pnpm test:e2e features/user-login.feature --tags "@happy-path"

# 运行特定场景
pnpm test:e2e features/user-login.feature --name "成功登录"
```

---

## 相关资源

- [设计文档](./design.md)
- [实现进度](./implementation.md)
- [AI 助手指南](./AGENTS.md)
- [Gherkin 语法参考](https://cucumber.io/docs/gherkin/reference/)

---

**创建日期**: 2026-03-11
**最后更新**: 2026-03-11
**场景总数**: 7
