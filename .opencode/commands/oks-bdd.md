---
description: 设计 BDD 场景（Happy/Error/Edge）
agent: build
argument-hint: '<功能名称>'
---

# BDD 场景设计

从用户故事创建可执行的 BDD 场景。

---

## ⚠️ 参数验证和前置检查

!`
if [ -z "$ARGUMENTS" ]; then
echo "❌ **错误: 缺少参数**"
echo ""
echo "**用法**: /oks-bdd <功能名称>"
echo ""
echo "**示例**:"
echo " /oks-bdd 配置项管理"
echo " /oks-bdd 用户登录"
exit 1
fi

# 使用统一的前置检查脚本

RESULT=$(bash oks-coding-system/scripts/check-prerequisites.sh --json --stage=bdd --feature="$ARGUMENTS" 2>&1)
if echo "$RESULT" | grep -q '"error"'; then
  MISSING=$(echo "$RESULT" | grep -o '"missing":\[[^]]*\]' | sed 's/"missing":\[/缺失: /; s/\]//; s/", "/\n  - /g')
  SUGGEST=$(echo "$RESULT" | grep -o '"suggestions":\[[^]]*\]' | sed 's/"suggestions":\[/建议: /; s/\]//; s/", "/\n → /g')
  echo ""
  echo "❌ **前置条件未满足**"
  echo ""
  echo "$MISSING"
echo ""
echo "$SUGGEST"
echo ""
echo "**解决方案**:"
echo " 1. /oks-user-story $ARGUMENTS"
echo " 2. 或 /oks-workflow $ARGUMENTS（自动处理依赖）"
exit 1
fi
`

---

## 当前任务

功能名称: **$ARGUMENTS**

!`
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
PROJECT_ROOT=$(get_project_root "$PROJECT_NAME")
VISION_FILE="$REPO_ROOT/$PROJECT_ROOT/docs/specfiy/vision.md"
PROJECT_NAME=""

# 尝试从 vision 文档获取项目名

for file in "$VISION_DIR"/*-vision.md; do
    if [ -f "$file" ] && grep -qi "$ARGUMENTS" "$file" 2>/dev/null; then
PROJECT_NAME=$(basename "$file" -vision.md)
break
fi
done

# 如果只有一个 vision，使用它

if [ -z "$PROJECT_NAME" ]; then
VISION*COUNT=$(ls -1 "$VISION_DIR"/*-vision.md 2>/dev/null | wc -l)
if [ "$VISION_COUNT" -eq 1 ]; then
PROJECT*NAME=$(basename $(ls -1 "$VISION_DIR"/*-vision.md | head -1) -vision.md)
fi
fi

echo "**项目**: ${PROJECT_NAME:-未确定}"
`

## 项目上下文

当前分支: !`git branch --show-current`

!`

# 根据项目名确定用户故事路径

if [ -n "$PROJECT_NAME" ] && [ -f "$REPO_ROOT/<project>/docs/specfiy/$PROJECT_NAME/$ARGUMENTS.md" ]; then
echo "**用户故事**: ✅ <project>/docs/specfiy/$PROJECT_NAME/$ARGUMENTS.md"
elif [ -f "$REPO_ROOT/<project>/docs/specfiy/$ARGUMENTS.md" ]; then
echo "**用户故事**: ✅ <project>/docs/specfiy/$ARGUMENTS.md"
else
echo "**用户故事**: ❌ 不存在"
fi
`

---

## 前置条件

!`
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
PROJECT_ROOT=$(get_project_root "$PROJECT_NAME")
VISION_FILE="$REPO_ROOT/$PROJECT_ROOT/docs/specfiy/vision.md"
PROJECT_NAME=""

# 尝试从 vision 文档获取项目名

for file in "$VISION_DIR"/*-vision.md; do
    if [ -f "$file" ] && grep -qi "$ARGUMENTS" "$file" 2>/dev/null; then
PROJECT_NAME=$(basename "$file" -vision.md)
break
fi
done

# 如果只有一个 vision，使用它

if [ -z "$PROJECT_NAME" ]; then
VISION*COUNT=$(ls -1 "$VISION_DIR"/*-vision.md 2>/dev/null | wc -l)
if [ "$VISION_COUNT" -eq 1 ]; then
PROJECT*NAME=$(basename $(ls -1 "$VISION_DIR"/*-vision.md | head -1) -vision.md)
fi
fi

# 检查用户故事

if [ -n "$PROJECT_NAME" ] && [ -f "$REPO_ROOT/<project>/docs/specfiy/$PROJECT_NAME/$ARGUMENTS.md" ]; then
USER_STORY_STATUS="✅ <project>/docs/specfiy/$PROJECT_NAME/$ARGUMENTS.md"
elif [ -f "$REPO_ROOT/<project>/docs/specfiy/$ARGUMENTS.md" ]; then
USER_STORY_STATUS="✅ <project>/docs/specfiy/$ARGUMENTS.md"
else
USER_STORY_STATUS="❌ 不存在（必需）"
fi

# 检查设计文档

if [ -n "$PROJECT_NAME" ] && [ -f "$REPO_ROOT/<project>/docs/specfiy/$PROJECT_NAME/$ARGUMENTS.md" ]; then
DESIGN_STATUS="✅ <project>/docs/specfiy/$PROJECT_NAME/$ARGUMENTS.md"
elif [ -f "$REPO_ROOT/<project>/docs/specfiy/$ARGUMENTS.md" ]; then
DESIGN_STATUS="✅ <project>/docs/specfiy/$ARGUMENTS.md"
else
DESIGN_STATUS="⚠️ 不存在（推荐）"
fi

echo "- [ ] **用户故事**: $USER_STORY_STATUS"
echo "- [ ] **技术设计**: $DESIGN_STATUS"
`

> **注意**: 用户故事是必需的前置条件，技术设计是推荐的（有助于设计更准确的测试场景）

如果用户故事不存在，先运行：

```bash
/oks-user-story $ARGUMENTS
```

如果设计文档不存在，建议运行：

```bash
/oks-design $ARGUMENTS
```

---

## 场景设计流程

```
用户故事 → 识别边界 → 拆分场景 → 编写 Gherkin → 定义步骤
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

## 边界情况识别

> 使用提问式引导，确保覆盖所有边界情况

### 边界问题清单

**输入边界**:

- 当输入为空/ null 时会发生什么？
- 当输入超过最大长度时会发生什么？
- 当输入包含特殊字符时会发生什么？
- 当输入格式不正确时会发生什么？

**状态边界**:

- 当资源不存在时会发生什么？
- 当资源已存在（重复）时会发生什么？
- 当资源被锁定/禁用时会发生什么？
- 当资源达到上限时会发生什么？

**时间边界**:

- 当操作超时时会发生什么？
- 当会话过期时会发生什么？
- 当并发操作冲突时会发生什么？

**权限边界**:

- 当用户未登录时会发生什么？
- 当用户权限不足时会发生什么？
- 当资源不属于当前用户时会发生什么？

**系统边界**:

- 当外部服务不可用时会发生什么？
- 当数据库连接失败时会发生什么？
- 当内存/磁盘空间不足时会发生什么？

---

## 执行步骤

### 1. 读取用户故事

从 `<project>/docs/specfiy/$ARGUMENTS.md` 读取：

- 故事描述
- 验收标准
- 功能需求 (FR-001, FR-002...)
- 成功标准 (SC-001, SC-002...)
- 待澄清项

### 2. 识别场景

从验收标准提取场景：

- 每个验收标准至少 1 个场景
- 覆盖 Happy/Error/Edge 三种类型
- 确保场景独立、可重复
- 回答边界问题清单中的问题

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

  @edge-case
  Scenario: 边界场景
    Given 边界条件
    When 执行动作
    Then 符合预期的结果

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

**最少场景数**: 5 个（Happy + 2 Error + 2 Edge）

### 步骤定义文件

`features/step-definitions/$ARGUMENTS.steps.ts`

**所有场景可执行**: ✅

---

## 阶段完成条件

- [ ] 至少 5 个场景（Happy/Error/Edge）
- [ ] 边界问题清单已回答
- [ ] 所有场景使用标准 Gherkin 语法
- [ ] 步骤定义文件已创建
- [ ] 所有场景可执行（无语法错误）
- [ ] 场景覆盖所有功能需求 (FR-XXX)

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

  @happy-path @FR-001
  Scenario: 成功登录
    Given 用户在登录页面
    When 用户输入邮箱 "test@example.com" 和密码 "Password123"
    And 用户点击登录按钮
    Then 用户应该成功登录
    And 页面跳转到首页
    And 显示欢迎消息 "欢迎回来"
    And 响应时间小于 200ms

  @validation @FR-002
  Scenario: 密码错误
    Given 用户在登录页面
    When 用户输入邮箱 "test@example.com" 和密码 "WrongPassword"
    And 用户点击登录按钮
    Then 登录失败
    And 显示错误消息 "邮箱或密码错误"
    And 用户仍在登录页面

  @validation @FR-002
  Scenario: 用户不存在
    Given 用户在登录页面
    When 用户输入邮箱 "nonexistent@example.com" 和密码 "Password123"
    And 用户点击登录按钮
    Then 登录失败
    And 显示错误消息 "邮箱或密码错误"

  @edge-case @FR-002
  Scenario: 邮箱格式不正确
    Given 用户在登录页面
    When 用户输入邮箱 "invalid-email" 和密码 "Password123"
    And 用户点击登录按钮
    Then 登录失败
    And 显示错误消息 "邮箱格式不正确"

  @edge-case @FR-002
  Scenario: 输入为空
    Given 用户在登录页面
    When 用户输入邮箱 "" 和密码 ""
    And 用户点击登录按钮
    Then 登录失败
    And 显示错误消息 "邮箱和密码不能为空"

  @business-rule @FR-005
  Scenario: 账户锁定
    Given 用户 "test@example.com" 已连续失败登录 4 次
    When 用户再次输入错误密码
    Then 登录失败
    And 显示错误消息 "账户已锁定，请 15 分钟后再试"
    And 账户被锁定 15 分钟

  @business-rule @FR-004
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
- [ ] 边界问题清单已回答
- [ ] 场景独立、可重复执行
- [ ] 步骤定义清晰
- [ ] 使用标签分类（@happy-path, @validation, @edge-case, @business-rule）
- [ ] 关联功能需求（@FR-XXX）
- [ ] 包含成功标准验证（如响应时间）

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

### Q: 如何在场景中验证成功标准？

A: 在 Then 步骤中添加量化验证：

```gherkin
Then 响应时间小于 200ms
Then 用户在 30 秒内完成操作
```

```typescript
Then('响应时间小于 {int}ms', async (maxTime: number) => {
  const start = Date.now();
  await someAction();
  const duration = Date.now() - start;
  expect(duration).toBeLessThan(maxTime);
});
```

### Q: 如何关联功能需求？

A: 使用标签关联：

```gherkin
@FR-001 @FR-002
Scenario: 用户登录
```

---

## 💬 常用提示词

### 设计 BDD 场景

```markdown
为 {功能名称} 设计 BDD 场景：

1. 从用户故事中提取所有场景
2. 每个场景包含 Given-When-Then
3. 覆盖 Happy Path（至少 2 个）
4. 覆盖 Error Cases（至少 2 个）
5. 覆盖 Edge Cases（至少 1 个）
6. 使用标签关联功能需求 (@FR-XXX)
```

### 运行 BDD 测试

```markdown
运行 {功能名称} 的 BDD 测试：

1. 运行 pnpm vitest run features/{feature}.feature
2. 检查所有场景是否通过
3. 修复失败的场景
4. 确保覆盖率达到要求
```

### 场景覆盖检查

```markdown
检查 {功能名称} 的场景覆盖：

1. 所有功能需求 (FR-XXX) 是否有对应场景？
2. 所有成功标准 (SC-XXX) 是否可验证？
3. 边界情况是否已覆盖？
4. 业务规则是否已验证？
```

### 编写步骤定义

```markdown
为 {功能名称} 编写步骤定义：

1. 创建 features/step-definitions/{feature}.steps.ts
2. 实现 Given 步骤（前置条件）
3. 实现 When 步骤（用户操作）
4. 实现 Then 步骤（结果验证）
5. 使用辅助函数复用代码
```

---

## 下一步

完成 BDD 场景后，可以：

1. **继续到 TDD**: 运行 `/oks-tdd $ARGUMENTS` 开始 TDD 循环
2. **验证场景**: 运行 `pnpm vitest run features/$ARGUMENTS.feature`
3. **完整流程**: 运行 `/oks-workflow $ARGUMENTS` 执行完整工作流

---

## 参考资源

- [Gherkin 语法参考](https://cucumber.io/docs/gherkin/reference/)
- [BDD 最佳实践](https://cucumber.io/docs/guides/)
- [边界值分析](https://en.wikipedia.org/wiki/Boundary-value_analysis)
