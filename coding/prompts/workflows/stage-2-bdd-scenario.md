---
description: 阶段二 - 设计 BDD 场景（Happy/Error/Edge）
agent: build
argument-hint: '<功能名称>'
---

# 阶段二：BDD 场景设计

从用户故事创建可执行的 BDD 场景。

---

## 当前任务

功能名称: **$ARGUMENTS**

## 项目上下文

当前分支: !`git branch --show-current`
用户故事: !`test -f docs/user-stories/$ARGUMENTS.md && echo "✅ 已存在" || echo "❌ 不存在"`

---

## 前置条件

- [ ] 用户故事文件存在: `docs/user-stories/$ARGUMENTS.md`
- [ ] 验收标准已明确

如果用户故事不存在，先运行：

```bash
/stage-1-user-story $ARGUMENTS
```

---

## 场景设计流程

```
用户故事 → 拆分场景 → 编写 Gherkin → 定义步骤
```

---

## 场景类型

### 1. Happy Path（成功场景）

- 正常流程
- 所有验证通过
- 预期成功

### 2. Error Cases（异常场景）

- 验证失败
- 业务规则违反
- 错误处理

### 3. Edge Cases（边界场景）

- 边界条件
- 特殊情况
- 极端值

---

## 执行步骤

### 1. 读取用户故事

从 `docs/user-stories/$ARGUMENTS.md` 读取：

- 故事描述
- 验收标准
- 业务规则

### 2. 识别场景

从验收标准提取场景：

- 每个验收标准至少 1 个场景
- 覆盖 Happy/Error/Edge 三种类型
- 确保场景独立、可重复

### 3. 编写 Gherkin

创建文件: `features/$ARGUMENTS.feature`

```gherkin
Feature: $ARGUMENTS
  [用户故事描述]

  Background:
    Given 系统初始化状态

  @happy-path
  Scenario: 成功场景
    Given 前置条件
    When 执行动作
    Then 期望结果

  @validation
  Scenario: 验证失败场景
    Given 前置条件
    When 执行动作
    Then 失败并返回错误信息

  @business-rule
  Scenario: 业务规则场景
    Given 业务规则条件
    When 执行动作
    Then 符合业务规则的期望结果
```

### 4. 定义步骤

创建文件: `features/step-definitions/$ARGUMENTS.steps.ts`

```typescript
import { Given, When, Then } from '@cucumber/cucumber';
import { expect } from 'vitest';

let result: any;
let error: Error;

// ==================== Given ====================

Given('前置条件描述', async () => {
  // 设置测试数据和状态
});

// ==================== When ====================

When('执行动作描述', async () => {
  try {
    result = await someAction();
  } catch (e) {
    error = e;
  }
});

// ==================== Then ====================

Then('期望结果描述', () => {
  expect(result).toBeDefined();
});

Then('错误信息包含 {string}', (message: string) => {
  expect(error.message).toContain(message);
});
```

---

## 输出

### Feature 文件

`features/$ARGUMENTS.feature`

**最少场景数**: 3 个（Happy/Error/Edge）

### 步骤定义文件

`features/step-definitions/$ARGUMENTS.steps.ts`

**所有场景可执行**: ✅

---

## 阶段完成条件

- [ ] 至少 3 个场景（Happy/Error/Edge）
- [ ] 所有场景使用标准 Gherkin 语法
- [ ] 步骤定义文件已创建
- [ ] 所有场景可执行（无语法错误）

验证命令:

```bash
pnpm vitest run features/$ARGUMENTS.feature
```

---

## 示例

**输入**: `用户登录`

**输出**: `features/user-login.feature`

```gherkin
Feature: 用户登录
  作为注册用户，我想要使用邮箱和密码登录系统

  Background:
    Given 系统中存在用户 "test@example.com" 密码为 "Password123"

  @happy-path
  Scenario: 成功登录
    Given 用户在登录页面
    When 用户输入邮箱 "test@example.com" 和密码 "Password123"
    And 用户点击登录按钮
    Then 用户应该成功登录
    And 页面跳转到首页
    And 显示欢迎消息 "欢迎回来"

  @validation
  Scenario: 密码错误
    Given 用户在登录页面
    When 用户输入邮箱 "test@example.com" 和密码 "WrongPassword"
    And 用户点击登录按钮
    Then 登录失败
    And 显示错误消息 "邮箱或密码错误"
    And 用户仍在登录页面

  @validation
  Scenario: 用户不存在
    Given 用户在登录页面
    When 用户输入邮箱 "nonexistent@example.com" 和密码 "Password123"
    And 用户点击登录按钮
    Then 登录失败
    And 显示错误消息 "邮箱或密码错误"

  @business-rule
  Scenario: 账户锁定
    Given 用户 "test@example.com" 已连续失败登录 4 次
    When 用户再次输入错误密码
    Then 登录失败
    And 显示错误消息 "账户已锁定，请 15 分钟后再试"
    And 账户被锁定 15 分钟

  @business-rule
  Scenario: 记住我功能
    Given 用户在登录页面
    When 用户输入正确的邮箱和密码
    And 用户勾选"记住我"选项
    And 用户点击登录按钮
    Then 用户成功登录
    And 会话有效期设置为 7 天
```

---

## 场景检查清单

- [ ] 覆盖正常流程（Happy Path）
- [ ] 覆盖异常流程（Error Cases）
- [ ] 覆盖边界条件（Edge Cases）
- [ ] 场景独立、可重复执行
- [ ] 步骤定义清晰
- [ ] 使用标签分类（@happy-path, @validation, @business-rule）

---

## 常见问题

### Q: 如何处理复杂场景？

A: 使用 Scenario Outline 和 Examples：

```gherkin
Scenario Outline: 多种登录失败情况
  Given 用户输入邮箱 "<email>" 和密码 "<password>"
  When 用户点击登录按钮
  Then 显示错误消息 "<error>"

  Examples:
    | email              | password  | error            |
    | invalid-email      | pass123   | 邮箱格式不正确   |
    | test@example.com   |           | 密码不能为空     |
    |                    | pass123   | 邮箱不能为空     |
```

### Q: 步骤定义太复杂怎么办？

A: 提取辅助函数：

```typescript
// 辅助函数
async function createTestUser(email: string, password: string) {
  // ...
}

async function login(email: string, password: string) {
  // ...
}

// 步骤定义
Given('系统中存在用户 {string} 密码为 {string}', async (email, password) => {
  await createTestUser(email, password);
});
```

### Q: 如何测试异步操作？

A: 使用 async/await：

```typescript
When('用户点击登录按钮', async () => {
  result = await userService.login(email, password);
});
```

---

## 下一步

完成 BDD 场景后，可以：

1. **继续到阶段三**: 运行 `/stage-3-tdd $ARGUMENTS` 开始 TDD 循环
2. **验证场景**: 运行 `pnpm vitest run features/$ARGUMENTS.feature`
3. **完整流程**: 运行 `/workflow $ARGUMENTS` 执行完整工作流

---

## 参考资源

- [Gherkin 语法参考](https://cucumber.io/docs/gherkin/reference/)
- [BDD 最佳实践](https://cucumber.io/docs/guides/)
