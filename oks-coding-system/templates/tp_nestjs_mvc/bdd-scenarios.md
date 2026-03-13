# {功能名称} BDD 场景

> 行为驱动开发（BDD）场景定义，使用 Gherkin 语法

---

## 📋 场景概览

| 场景类型   | 场景数量       | 优先级 | 状态 |
| ---------- | -------------- | ------ | ---- |
| Happy Path | {场景数量}     | P1     | ✅   |
| Error Case | {场景数量}     | P1     | ✅   |
| Edge Case  | {场景数量}     | P2     | ⏳   |
| **总计**   | **{总场景数}** | -      | -    |

---

## Feature 定义

```gherkin
Feature: {功能名称}
  {功能描述}

  作为 {用户类型}
  我想要 {功能/动作}
  以便于 {获得的价值}
```

---

## Background（通用前置条件）

```gherkin
Background:
  Given 系统已初始化
  And 数据库中存在测试数据
```

---

## 🟢 Happy Path（成功场景）

### 场景 1: {场景名称}

**优先级**: P1

**关联需求**: @FR-001, @FR-002

**成功标准**: @SC-001

```gherkin
@happy-path @FR-001 @FR-002 @SC-001
Scenario: {场景名称}
  Given {前置条件}
  And {额外的前置条件}
  When 用户 {执行动作}
  And {额外的动作}
  Then {期望结果}
  And {额外的验证}
```

**测试数据**:

- {数据 1}: {值}
- {数据 2}: {值}

**预期结果**:

- {结果 1}
- {结果 2}

---

### 场景 2: {场景名称}

**优先级**: P1

```gherkin
@happy-path @FR-003
Scenario: {场景名称}
  Given {前置条件}
  When {执行动作}
  Then {期望结果}
```

---

## 🔴 Error Cases（异常场景）

### 场景 3: {场景名称}

**优先级**: P1

**关联需求**: @FR-002

```gherkin
@validation @FR-002
Scenario: {场景名称}
  Given {前置条件}
  When 用户 {执行错误动作}
  Then 操作失败
  And 显示错误消息 "{错误消息}"
  And {状态验证}
```

**错误类型**: {错误类型}

**错误消息**: "{错误消息}"

**期望行为**:

- {期望行为 1}
- {期望行为 2}

---

### 场景 4: {场景名称}

**优先级**: P1

```gherkin
@validation @FR-002
Scenario: {场景名称}
  Given {前置条件}
  When {执行动作}
  Then 操作失败
  And 显示错误消息 "{错误消息}"
```

---

## 🔶 Edge Cases（边界场景）

### 场景 5: {场景名称}

**优先级**: P2

**关联需求**: @FR-002

```gherkin
@edge-case @FR-002
Scenario: {场景名称}
  Given {边界条件}
  When {执行动作}
  Then {符合预期的结果}
```

**边界类型**: 输入边界 / 状态边界 / 权限边界 / 系统边界

**边界值**:

- {边界 1}: {值}
- {边界 2}: {值}

**期望处理**:

- {如何处理该边界情况}

---

### 场景 6: 输入为空

**优先级**: P2

```gherkin
@edge-case @FR-002
Scenario: 输入为空
  Given 用户在 {页面/功能}
  When 用户输入 {字段} 为空
  And 用户提交
  Then 操作失败
  And 显示错误消息 "{字段}不能为空"
```

---

### 场景 7: 输入超过最大长度

**优先级**: P2

```gherkin
@edge-case @FR-002
Scenario: 输入超过最大长度
  Given 用户在 {页面/功能}
  When 用户输入 {字段} 超过 {场景数量} 个字符
  And 用户提交
  Then 操作失败
  And 显示错误消息 "{字段}长度不能超过{N}个字符"
```

---

## 🔄 Scenario Outline（数据驱动场景）

### 场景 8: {场景名称}

**优先级**: P1

```gherkin
@data-driven @FR-002
Scenario Outline: {场景名称}
  Given {前置条件}
  When 用户输入 {字段} "<{参数}>"
  And 用户提交
  Then 显示错误消息 "<error>"

  Examples:
    | {参数}        | error              |
    | invalid-value | 错误消息 1         |
    | empty         | 错误消息 2         |
    | too-long      | 错误消息 3         |
```

---

## 🏷️ 标签说明

### 场景类型标签

- `@happy-path`: 正常流程，所有验证通过
- `@validation`: 验证失败场景
- `@edge-case`: 边界情况
- `@business-rule`: 业务规则验证
- `@data-driven`: 数据驱动测试

### 需求关联标签

- `@FR-001`: 关联功能需求 FR-001
- `@FR-002`: 关联功能需求 FR-002
- `@SC-001`: 关联成功标准 SC-001

### 优先级标签

- `@P1`: 高优先级，必须通过
- `@P2`: 中优先级，应该通过
- `@P3`: 低优先级，可选

---

## 📝 步骤定义

### Given 步骤

```typescript
// features/step-definitions/{feature}.steps.ts

import { Given, When, Then } from '@cucumber/cucumber';
import { expect } from 'vitest';

let context: any = {};

// ==================== Given ====================

Given('系统已初始化', async () => {
  // 初始化测试环境
  context = {};
});

Given(
  '{string} 中存在 {string} {string}',
  async (location: string, resource: string, identifier: string) => {
    // 创建测试数据
  },
);

Given('用户在 {string}', async (page: string) => {
  // 导航到页面
});
```

### When 步骤

```typescript
// ==================== When ====================

When('用户输入 {string} {string}', async (field: string, value: string) => {
  // 输入数据
});

When('用户点击 {string}', async (button: string) => {
  // 点击按钮
});

When('用户提交', async () => {
  // 提交表单
});
```

### Then 步骤

```typescript
// ==================== Then ====================

Then('操作成功', () => {
  expect(context.success).toBe(true);
});

Then('操作失败', () => {
  expect(context.success).toBe(false);
});

Then('显示错误消息 {string}', (message: string) => {
  expect(context.error).toContain(message);
});

Then('{string} 应该是 {string}', (field: string, value: string) => {
  expect(context.data[field]).toBe(value);
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
  },
  {
    id: 'user-2',
    email: 'admin@example.com',
    password: 'Admin123',
    name: 'Admin User',
    role: 'admin',
  },
];
```

### 业务数据

```typescript
const testData = {
  // {数据类型}
  items: [
    { id: 'item-1', name: 'Item 1', value: 100 },
    { id: 'item-2', name: 'Item 2', value: 200 },
  ],
};
```

---

## 🎯 边界情况清单

参考 `design.md` 中的边界情况，确保以下场景已覆盖：

### 输入边界

- [ ] 空值/null
- [ ] 超长输入
- [ ] 特殊字符
- [ ] 格式错误

### 状态边界

- [ ] 资源不存在
- [ ] 资源已存在
- [ ] 资源被锁定
- [ ] 达到上限

### 权限边界

- [ ] 未登录用户
- [ ] 权限不足
- [ ] 资源不属于当前用户

### 系统边界

- [ ] 外部服务不可用
- [ ] 数据库连接失败
- [ ] 超时

---

## ✅ 场景检查清单

### 完整性检查

- [ ] 覆盖所有功能需求 (FR-XXX)
- [ ] 覆盖所有成功标准 (SC-XXX)
- [ ] 至少 3 个 Happy Path 场景
- [ ] 至少 2 个 Error Case 场景
- [ ] 至少 2 个 Edge Case 场景

### 质量检查

- [ ] 所有场景使用标准 Gherkin 语法
- [ ] 场景独立、可重复执行
- [ ] 步骤定义清晰
- [ ] 使用标签分类
- [ ] 关联功能需求标签

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
pnpm test:e2e features/{feature}.feature

# 运行特定标签的场景
pnpm test:e2e features/{feature}.feature --tags "@happy-path"

# 运行特定场景
pnpm test:e2e features/{feature}.feature --name "场景名称"
```

### 查看测试报告

```bash
# 生成测试报告
pnpm test:e2e --reporter=html

# 打开报告
open reports/e2e-report.html
```

---

## 🔧 常见问题

### Q: 如何处理异步操作？

A: 使用 async/await:

```typescript
When('用户点击登录', async () => {
  await page.click('#login-button');
});
```

### Q: 如何在场景间共享数据？

A: 使用 context 对象:

```typescript
let context: any = {};

Given('用户创建订单', async () => {
  context.order = await createOrder();
});

Then('订单应该存在', () => {
  expect(context.order).toBeDefined();
});
```

### Q: 如何调试失败的场景？

A: 使用 verbose 模式:

```bash
pnpm test:e2e features/{feature}.feature --reporter=verbose
```

---

## 相关资源

| 文档             | 路径                                        |
| ---------------- | ------------------------------------------- |
| 项目愿景         | `docs/specify/vision.md`                    |
| 用户故事         | `docs/specify/user-story.md`                |
| 技术设计         | `docs/specify/design.md`                    |
| 实现进度         | `docs/specify/implementation.md`            |
| AI 助手指南      | `docs/specify/AGENTS.md`                    |
| Gherkin 语法参考 | https://cucumber.io/docs/gherkin/reference/ |

---

**创建日期**: {日期}
**最后更新**: {日期}
**场景总数**: {总场景数}
