# OKS 开发工作流指南

本文档详细阐述 oksai.cc monorepo 的开发工作流，包括各阶段命令、最佳实践和配置策略。

---

## 📊 工作流概览

```
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                              OKS 开发工作流                                                       │
├──────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                                  │
│   阶段一: 愿景文档 (Vision)                                                                        │
│   ├── 命令: /oks-vision                                                                            │
│   ├── 产出: <project>/docs/specify/vision.md                                                      │
│   └── 约束: 纯业务描述，禁止技术内容                                                              │
│              ↓                                                                                   │
│   阶段二: 用户故事 (User Story)                                                                    │
│   ├── 命令: /oks-user-story                                                                        │
│   ├── 产出: <project>/docs/specify/user-story.md                                                  │
│   └── 约束: 符合 INVEST 原则                                                                      │
│              ↓                                                                                   │
│   阶段三: 技术设计 (Design)                                                                        │
│   ├── 命令: /oks-design                                                                            │
│   ├── 产出: <project>/docs/specify/design.md                                                      │
│   └── 内容: 数据库/API/组件设计                                                                   │
│              ↓                                                                                   │
│   阶段四: BDD 场景 (可跳过)                                                                       │
│   ├── 命令: /oks-bdd                                                                               │
│   ├── 产出: features/{feature}.feature                                                            │
│   └── 约束: 至少 5 个场景 (Happy/Error/Edge)                                                       │
│              ↓                                                                                   │
│   阶段五: TDD 开发 (领域模型)                                                                      │
│   ├── 命令: /oks-tdd                                                                               │
│   ├── 产出: src/modules/{module}/entities/                                                        │
│   └── 约束: 测试覆盖率 > 80%                                                                      │
│              ↓                                                                                   │
│   阶段六: 服务实现 (Implementation)                                                                │
│   ├── 命令: /oks-implementation                                                                    │
│   ├── 产出: services/, controllers/, repositories/                                                │
│   └── 约束: 服务层测试覆盖率 > 80%                                                                 │
│              ↓                                                                                   │
│   阶段七: 代码优化 (可跳过)                                                                       │
│   ├── 命令: /oks-optimization                                                                      │
│   ├── 产出: 优化后的代码 + 性能报告                                                                │
│   └── 约束: 性能提升 > 20%                                                                        │
│                                                                                                  │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 🚀 快速开始

### 完整开发流程

```bash
# 阶段 1: 创建/查看愿景文档
/oks-vision 新建 <项目名称>
# 或查看已有
/oks-vision <项目名称>

# 阶段 2: 创建用户故事
/oks-user-story <功能名称>

# 阶段 3: 创建技术设计
/oks-design <功能名称>

# 阶段 4: BDD 场景（可选）
/oks-bdd <功能名称>

# 阶段 5: TDD 开发
/oks-tdd <功能名称>

# 阶段 6: 服务实现
/oks-implementation <功能名称>

# 阶段 7: 代码优化（可选）
/oks-optimization <功能名称>
```

### 快速原型（跳过 BDD 和优化）

```bash
/oks-vision 新建 <项目名称>
/oks-user-story <功能名称>
/oks-design <功能名称>
/oks-tdd <功能名称>
/oks-implementation <功能名称>
```

### 查看项目和功能列表

```bash
/oks-list
```

---

## 📝 阶段详解

### 阶段一：愿景文档 (Vision)

**命令**: `/oks-vision [项目名称]`

**目的**: 定义项目的业务边界、目标用户和核心功能。

**产出**: `<project>/docs/specify/vision.md`

#### 关键约束

| ✅ 允许        | ❌ 禁止              |
| -------------- | -------------------- |
| 业务问题和目标 | 代码片段、伪代码     |
| 用户角色和场景 | 技术栈选型           |
| 业务功能和流程 | API 接口、数据库结构 |
| 业务约束和规则 | 技术架构图           |

#### 愿景文档模板

```markdown
# {项目名称} - 项目愿景

## 📋 基本信息

- **项目名称**: {project-name}
- **文档版本**: v1.0
- **创建日期**: {YYYY-MM-DD}

## 🎯 适用范围

### 业务边界

{描述项目解决的核心业务问题}

### 使用场景

{列出主要业务场景}

## 👥 使用人员

| 角色    | 岗位职责 | 使用频率         |
| ------- | -------- | ---------------- |
| {角色1} | {职责}   | {高频/中频/低频} |

## 🔧 功能模块

| 模块编号 | 模块名称 | 功能描述 | 优先级 | 状态   |
| -------- | -------- | -------- | ------ | ------ |
| M-001    | {模块名} | {描述}   | P1     | 规划中 |
```

---

### 阶段二：用户故事 (User Story)

**命令**: `/oks-user-story <功能名称>`

**目的**: 将功能需求转化为符合 INVEST 原则的用户故事。

**产出**: `<project>/docs/specify/user-story.md`

**前置条件**: 愿景文档（必需）

#### INVEST 原则

| 原则            | 说明   | 检查点                 |
| --------------- | ------ | ---------------------- |
| **I**ndependent | 独立性 | 故事之间没有依赖       |
| **N**egotiable  | 可协商 | 细节可以讨论           |
| **V**aluable    | 有价值 | 对用户有明确价值       |
| **E**stimable   | 可估算 | 能够估算工作量 (< 3天) |
| **S**mall       | 足够小 | 单次迭代内能完成       |
| **T**estable    | 可测试 | 有明确的验收标准       |

#### 用户故事模板

```markdown
# 用户故事: {功能名称}

## 📋 基本信息

- **功能名称**: {feature-name}
- **所属项目**: {project-name}
- **创建日期**: {YYYY-MM-DD}

## 故事描述

作为 [角色]
我想要 [功能]
以便于 [价值]

## 优先级: P1/P2/P3

## 功能需求

- **FR-001**: 系统必须 [具体能力]
- **FR-002**: 系统必须 [具体能力]

## 验收标准

- [ ] 标准 1: [具体可测试的标准]
- [ ] 标准 2: [具体可测试的标准]

## 成功标准

- **SC-001**: [可衡量的指标]
```

---

### 阶段三：技术设计 (Design)

**命令**: `/oks-design <功能名称>`

**目的**: 创建技术实现方案，包含数据库、API、组件设计。

**产出**: `<project>/docs/specify/design.md`

**前置条件**: 愿景文档 + 用户故事

**重要约定**: 执行前先阅读 `docs/guides/tech-stack.md` 获取技术栈基线。

#### 设计文档结构

```markdown
# {功能名称} - 技术设计

## 📋 基本信息

- **功能名称**: {feature-name}
- **所属项目**: {project-name}

## 🔗 关联文档

| 文档类型 | 路径                              |
| -------- | --------------------------------- |
| 项目愿景 | [vision.md](../vision.md)         |
| 用户故事 | [user-story.md](../user-story.md) |

## 🎯 技术概述

{2-3 句话说明技术实现思路}

## 📦 技术架构

{架构图和核心模块}

## 💾 数据库设计

### 新增表

{SQL 定义和字段说明}

## 🔌 API 设计

### 新增接口

{接口定义、请求/响应格式}

## 🎨 UI 设计（如适用）

{组件列表、页面变更}

## 🔄 数据流

{核心流程和数据流转}

## 🔐 安全设计

{认证授权、数据安全}

## ⚡ 性能设计

{性能目标和优化策略}

## 🧪 测试策略

{单元测试、集成测试、E2E 测试}
```

---

### 阶段四：BDD 场景

**命令**: `/oks-bdd <功能名称>`

**目的**: 从用户故事创建可执行的 BDD 测试场景。

**产出**:

- `features/{feature}.feature`
- `features/step-definitions/{feature}.steps.ts`

**前置条件**: 用户故事（必需）、技术设计（推荐）

**可跳过**: 适合简单功能

#### 场景类型

| 类型        | 说明                   | 最少数量 |
| ----------- | ---------------------- | -------- |
| Happy Path  | 正常流程、预期成功     | 1-2      |
| Error Cases | 验证失败、业务规则违反 | 2-3      |
| Edge Cases  | 边界条件、特殊情况     | 1-2      |

#### Gherkin 语法

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
    And 响应时间小于 200ms

  @validation @FR-002
  Scenario: 密码错误
    Given 用户在登录页面
    When 用户输入邮箱 "test@example.com" 和密码 "WrongPassword"
    Then 登录失败
    And 显示错误消息 "邮箱或密码错误"
```

---

### 阶段五：TDD 开发

**命令**: `/oks-tdd <功能名称>`

**目的**: 使用 Red-Green-Refactor 循环开发领域模型。

**产出**: `src/modules/{module}/entities/`

**前置条件**: 用户故事（必需）、技术设计（推荐）、BDD 场景（可选）

#### TDD 适用性判断

| ✅ 适合 TDD                    | ❌ 可能不需要 TDD |
| ------------------------------ | ----------------- |
| 领域实体（User、Order）        | 纯 CRUD 操作      |
| 值对象（Email、Money）         | 数据传递（DTO）   |
| 业务规则（登录锁定、库存扣减） | 配置读取          |
| 状态机（订单状态、支付流程）   | 代理转发          |

#### TDD 循环

```
┌─────────────────────────────────────────┐
│  🔴 Red   → 编写失败的测试              │
│  🟢 Green → 用最简单的方式让测试通过    │
│  🔵 Refactor → 优化代码，保持测试通过   │
└─────────────────────────────────────────┘
```

#### 覆盖率目标

| 类型       | 目标  |
| ---------- | ----- |
| 语句覆盖率 | > 80% |
| 分支覆盖率 | > 70% |
| 函数覆盖率 | > 90% |

---

### 阶段六：服务实现

**命令**: `/oks-implementation <功能名称>`

**目的**: 实现服务层、控制器和数据访问层。

**产出**:

- `src/modules/{module}/services/`
- `src/modules/{module}/controllers/`
- `src/modules/{module}/repositories/`

**前置条件**: TDD 阶段完成、测试覆盖率 > 80%

#### 测试要求

| 层级       | 测试要求 | 覆盖率目标 |
| ---------- | -------- | ---------- |
| 服务层     | ✅ 必需  | > 80%      |
| 控制器     | ✅ 必需  | > 70%      |
| Repository | ⚠️ 推荐  | > 60%      |

#### 项目结构

```
src/modules/{module}/
├── controllers/
│   ├── {module}.controller.ts
│   └── {module}.controller.spec.ts
├── services/
│   ├── {module}.service.ts
│   └── {module}.service.spec.ts
├── entities/
│   └── {module}.entity.ts
└── repositories/
    ├── {module}.repository.ts
    └── {module}.repository.spec.ts
```

---

### 阶段七：E2E 测试（可选）

**命令**: `/oks-e2e <功能名称>`

**目的**: 验证完整用户流程的端到端功能。

**产出**: `e2e/{feature}.spec.ts`

**前置条件**: 服务实现完成

**可跳过**: 适合非关键功能或快速迭代

#### E2E 测试类型

| 类型     | 说明              | 工具            |
| -------- | ----------------- | --------------- |
| 用户流程 | 完整业务流程验证  | Playwright      |
| 页面交互 | UI 组件交互测试   | Playwright      |
| API 集成 | 多服务集成测试    | Playwright/API  |
| 视觉回归 | UI 视觉一致性测试 | Percy/Chromatic |

#### E2E 测试模板

```typescript
// e2e/user-login.spec.ts
import { test, expect } from '@playwright/test';

test.describe('用户登录', () => {
  test('成功登录流程', async ({ page }) => {
    // 1. 访问登录页
    await page.goto('/login');

    // 2. 输入凭据
    await page.fill('[name="email"]', 'test@example.com');
    await page.fill('[name="password"]', 'Password123');

    // 3. 点击登录
    await page.click('button[type="submit"]');

    // 4. 验证跳转
    await expect(page).toHaveURL('/dashboard');

    // 5. 验证欢迎消息
    await expect(page.locator('.welcome')).toContainText('欢迎');
  });

  test('登录失败显示错误', async ({ page }) => {
    await page.goto('/login');

    await page.fill('[name="email"]', 'test@example.com');
    await page.fill('[name="password"]', 'wrongpassword');
    await page.click('button[type="submit"]');

    await expect(page.locator('.error')).toContainText('邮箱或密码错误');
  });
});
```

#### E2E 测试检查清单

- [ ] 覆盖核心用户流程
- [ ] 测试页面加载性能
- [ ] 验证错误提示
- [ ] 测试响应式布局
- [ ] 验证无障碍访问

---

### 阶段八：代码优化

**命令**: `/oks-optimization <功能名称>`

**目的**: 提升代码质量和性能。

**可跳过**: 适合原型开发

#### 优化维度

| 维度     | 目标             | 优先级 |
| -------- | ---------------- | ------ |
| 性能优化 | 响应时间 < 200ms | 高     |
| 代码质量 | 重复率 < 5%      | 高     |
| 架构优化 | 耦合度 < 0.3     | 中     |
| 安全加固 | 0 安全漏洞       | 高     |

#### 优化工具

```bash
# 性能分析
pnpm vitest run --coverage
pnpm build --analyze

# 代码质量
pnpm jscpd src/              # 重复代码检测
pnpm madge --circular src/  # 循环依赖检测
pnpm biome check src/       # 代码检查

# 安全检查
pnpm audit
```

---

## 📁 文档结构

```
project/
├── docs/
│   └── specify/
│       ├── vision.md           # 阶段一：愿景文档
│       ├── user-story.md        # 阶段二：用户故事
│       └── design.md            # 阶段三：技术设计
├── features/
│   ├── {feature}.feature       # 阶段四：BDD 场景
│   └── step-definitions/
│       └── {feature}.steps.ts
└── src/
    └── modules/
        └── {module}/
            ├── entities/        # 阶段五：领域模型
            ├── services/        # 阶段六：服务层
            ├── controllers/     # 阶段六：控制器
            └── repositories/    # 阶段六：数据访问层
```

---

## 🔗 命令速查表

| 阶段 | 命令                           | 产出                 | 可跳过 |
| ---- | ------------------------------ | -------------------- | ------ |
| 一   | `/oks-vision <项目名>`         | vision.md            | ❌     |
| 二   | `/oks-user-story <功能名>`     | user-story.md        | ❌     |
| 三   | `/oks-design <功能名>`         | design.md            | ❌     |
| 四   | `/oks-bdd <功能名>`            | .feature 文件        | ✅     |
| 五   | `/oks-tdd <功能名>`            | entities/            | ❌     |
| 六   | `/oks-implementation <功能名>` | services/controllers | ❌     |
| 七   | `/oks-e2e <功能名>`            | e2e/\*.spec.ts       | ✅     |
| 八   | `/oks-optimization <功能名>`   | 优化报告             | ✅     |

### 辅助命令

| 命令             | 说明                       |
| ---------------- | -------------------------- |
| `/oks-list`      | 查看所有项目和功能列表     |
| `/oks-generator` | 创建新项目（NestJS/React） |
| `/oks-help`      | 查看命令帮助               |

---

## 🎯 使用场景

### 场景 1: 新功能开发（完整流程）

```bash
/oks-vision 新建 user-center
/oks-user-story 用户登录
/oks-design 用户登录
/oks-bdd 用户登录
/oks-tdd 用户登录
/oks-implementation 用户登录
/oks-e2e 用户登录
/oks-optimization 用户登录
```

### 场景 2: 快速原型（跳过测试优化）

```bash
/oks-vision 新建 prototype-app
/oks-user-story 原型功能
/oks-design 原型功能
/oks-tdd 原型功能
/oks-implementation 原型功能
```

### 场景 3: 生产级功能

```bash
/oks-vision 新建 payment-service
/oks-user-story 支付流程
/oks-design 支付流程
/oks-bdd 支付流程
/oks-tdd 支付流程
/oks-implementation 支付流程
/oks-e2e 支付流程      # 关键功能必须有 E2E
/oks-optimization 支付流程
```

### 场景 4: 只补充设计

```bash
/oks-design 某功能
```

### 场景 5: 补写测试

```bash
/oks-tdd 某功能
/oks-e2e 某功能
```

### 场景 6: Bug 修复后回归

```bash
# 修复后运行相关测试
pnpm vitest run --related src/modules/{module}
pnpm playwright test e2e/{feature}.spec.ts
```

---

## 💡 最佳实践

### 1. 文档先行

- 每个项目先创建愿景文档
- 技术设计完成后再编码
- 保持文档与代码同步

### 2. 测试驱动

- TDD 确保代码质量
- 测试覆盖率 > 80%
- 每个阶段完成后运行测试

### 3. 阶段验证

```bash
# 每个阶段完成后运行
pnpm vitest run
pnpm vitest run --coverage
```

### 4. 架构决策记录 (ADR)

每个重要技术决策应记录在 `docs/specify/decisions.md`：

```markdown
# 架构决策记录 (ADR)

## ADR-001: 使用 JWT 进行身份认证

- **状态**: 已采纳
- **日期**: 2024-01-01
- **决策者**: 开发团队

### 背景

需要为 API 服务选择身份认证方案。

### 决策

采用 JWT (JSON Web Token) 进行无状态身份认证。

### 理由

1. 无状态，易于横向扩展
2. 跨服务共享方便
3. 社区支持完善

### 后果

- 需要处理 Token 刷新
- 无法主动使 Token 失效
- 需要安全存储 Secret

---

## ADR-002: 数据库选型

- **状态**: 提议中
- **日期**: 2024-01-02
```

### ADR 状态说明

| 状态   | 说明                     |
| ------ | ------------------------ |
| 提议中 | 正在讨论，尚未决定       |
| 已采纳 | 团队同意，正在或将要实施 |
| 已废弃 | 不再使用，记录历史原因   |
| 已替代 | 被新的 ADR 替代          |

---

## 🔗 CI/CD 集成

### 提交前检查（Pre-commit）

```bash
# 自动运行（通过 git hooks）
pnpm nx affected --target=lint,test,build
```

### CI 流水线

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Lint      │────▶│    Test     │────▶│   Build     │────▶│    E2E      │
│  (每次提交)  │     │  (每次提交)  │     │ (PR/合并)   │     │ (合并main)  │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
```

### CI 阶段说明

| 阶段   | 触发条件         | 执行命令                                    | 超时  |
| ------ | ---------------- | ------------------------------------------- | ----- |
| Lint   | 每次提交         | `pnpm nx affected --target=lint`            | 5min  |
| Test   | 每次提交         | `pnpm nx affected --target=test --coverage` | 15min |
| Build  | PR / 合并到 main | `pnpm nx affected --target=build`           | 20min |
| E2E    | 合并到 main      | `pnpm nx run-many --target=e2e --all`       | 30min |
| Deploy | 手动触发 / 定时  | `pnpm nx run-many --target=deploy --all`    | 10min |

### 质量门禁

| 指标       | 阈值       | 失败处理 |
| ---------- | ---------- | -------- |
| 测试覆盖率 | > 80%      | 阻止合并 |
| Lint 错误  | = 0        | 阻止合并 |
| 构建错误   | = 0        | 阻止合并 |
| E2E 失败   | = 0        | 阻止部署 |
| 安全漏洞   | Critical=0 | 阻止合并 |

### Nx Cloud 集成

```bash
# 查看任务分布
pnpm nx run-many --target=build --graph

# 查看受影响项目
pnpm nx affected:graph

# 分布式执行
pnpm nx run-many --target=test --agents=3
```

---

## 👥 多人协作

### 分支策略

| 分支类型 | 命名规范            | 说明             | 合并目标 |
| -------- | ------------------- | ---------------- | -------- |
| feature  | `feature/功能名`    | 新功能开发       | develop  |
| fix      | `fix/问题描述`      | Bug 修复         | develop  |
| docs     | `docs/文档描述`     | 文档更新         | main     |
| refactor | `refactor/重构描述` | 代码重构         | develop  |
| hotfix   | `hotfix/紧急修复`   | 生产环境紧急修复 | main     |

### 分支保护规则

| 分支       | 保护策略                         |
| ---------- | -------------------------------- |
| main       | 禁止直接推送，必须通过 PR        |
| develop    | 禁止直接推送，必须通过 PR        |
| release/\* | 禁止直接推送，仅允许 cherry-pick |

### 代码审查清单

- [ ] 代码风格符合规范
- [ ] 测试覆盖率达标
- [ ] 无安全漏洞
- [ ] 文档已更新
- [ ] 无性能退化

### 文档冲突处理

| 场景             | 处理方式                   |
| ---------------- | -------------------------- |
| 同一功能多人开发 | 提前沟通，明确分工         |
| 设计文档冲突     | 先合并用户故事，再重新设计 |
| 测试用例冲突     | 协调测试负责人，统一维护   |

### 协作最佳实践

1. **功能负责制**: 一个功能由一人负责完整流程
2. **设计变更通知**: 修改设计文档需通知相关开发者
3. **PR Review**: 使用 PR Review 确保文档和代码质量
4. **每日同步**: 每日站会同步进度，及时暴露问题

---

## 🔗 CI/CD 集成

### Git Hooks (本地)

```bash
# .husky/pre-commit
pnpm nx affected --target=lint,format --base=HEAD~1
```

```bash
# .husky/pre-push
pnpm nx affected --target=test --base=origin/main
```

### CI 流水线

| 阶段  | 触发条件         | 执行命令                              | 超时  |
| ----- | ---------------- | ------------------------------------- | ----- |
| Lint  | 每次推送         | `pnpm nx affected --target=lint`      | 5min  |
| Test  | 每次推送         | `pnpm nx affected --target=test`      | 15min |
| Build | PR / 合并到 main | `pnpm nx affected --target=build`     | 20min |
| E2E   | 合并到 main      | `pnpm nx run-many --target=e2e --all` | 30min |

### GitHub Actions 配置示例

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - uses: pnpm/action-setup@v2
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'pnpm'
      - run: pnpm install --frozen-lockfile
      - run: pnpm nx affected --target=lint --base=origin/main~1

  test:
    needs: lint
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - uses: pnpm/action-setup@v2
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'pnpm'
      - run: pnpm install --frozen-lockfile
      - run: pnpm nx affected --target=test --base=origin/main~1 --coverage
      - uses: codecov/codecov-action@v3

  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - uses: pnpm/action-setup@v2
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'pnpm'
      - run: pnpm install --frozen-lockfile
      - run: pnpm nx affected --target=build --base=origin/main~1
```

### Nx Cloud 加速

```yaml
# nx.json
{
  'tasksRunnerOptions':
    {
      'default':
        {
          'runner': '@nx/cloud',
          'options':
            { 'cacheableOperations': ['build', 'test', 'lint', 'e2e'] },
        },
    },
}
```

### 部署流程

| 环境    | 触发条件       | 部署方式        |
| ------- | -------------- | --------------- |
| staging | 合并到 develop | 自动部署        |
| prod    | 合并到 main    | 自动部署 + 审批 |
| hotfix  | hotfix/\* 分支 | 快速通道        |

### 质量门禁

| 指标       | 阈值    | 阻断级别 |
| ---------- | ------- | -------- |
| 测试覆盖率 | > 80%   | 强制     |
| Lint 错误  | 0       | 强制     |
| Lint 警告  | < 10    | 建议     |
| 安全漏洞   | 0 高危  | 强制     |
| 构建时间   | < 10min | 建议     |

---

## 📚 相关文档

| 文档                                                             | 说明                |
| ---------------------------------------------------------------- | ------------------- |
| `oks-coding-system/specify/TYPESCRIPT_CONFIGURATION_STRATEGY.md` | TypeScript 配置策略 |
| `oks-coding-system/specify/TESTING_CONFIGURATION_STRATEGY.md`    | 测试配置策略        |
| `docs/guides/tech-stack.md`                                      | 技术栈定义          |

---

## 🔄 阶段依赖关系

```
vision (无依赖)
  ↓
user-story (依赖 vision)
  ↓
design (依赖 user-story)
  ↓
bdd (依赖 design) ← 可跳过
  ↓
tdd (依赖 design，推荐 bdd)
  ↓
implementation (依赖 tdd)
  ↓
e2e (依赖 implementation) ← 可跳过
  ↓
optimization (依赖 implementation) ← 可跳过
```

### 阶段回退策略

| 当前阶段 | 失败条件         | 回退操作                    |
| -------- | ---------------- | --------------------------- |
| 用户故事 | INVEST 不满足    | 重新拆分故事                |
| 设计     | 技术方案不可行   | 返回用户故事，调整需求      |
| BDD      | 场景无法覆盖需求 | 返回设计，补充边界情况      |
| TDD      | 测试覆盖率 < 80% | 补充测试用例                |
| TDD      | 测试无法通过     | 检查设计 → 可能返回设计阶段 |
| 实现     | BDD 场景失败     | 修复实现 → 或调整 BDD 场景  |
| E2E      | 端到端流程失败   | 返回实现，修复集成问题      |
| 优化     | 性能未提升       | 记录技术债务 → 后续迭代     |

### 失败处理流程

```
问题发现 → 分析原因 → 判断根因：
  ├── 测试写错 → 修复测试 → 继续
  ├── 实现有误 → 修复实现 → 继续
  ├── 设计问题 → 返回设计阶段 → 重新设计
  └── 需求问题 → 返回用户故事 → 调整需求
```

### 技术债务管理

当优化阶段无法完成时，记录技术债务：

```markdown
# 技术债务记录

| 编号   | 描述               | 优先级 | 影响     | 计划解决时间 |
| ------ | ------------------ | ------ | -------- | ------------ |
| TD-001 | 登录接口响应 300ms | 中     | 用户体验 | Sprint 3     |
| TD-002 | 代码重复率 8%      | 低     | 可维护性 | Sprint 4     |
```

---

## 📋 阶段完成条件检查清单

### 阶段一：愿景文档

- [ ] 适用范围已定义
- [ ] 使用人员已明确
- [ ] 功能模块已列出
- [ ] 无技术实现内容

### 阶段二：用户故事

- [ ] 符合 INVEST 所有原则
- [ ] 优先级已设定
- [ ] 功能需求已编号 (FR-001...)
- [ ] 验收标准明确（至少 3 个）
- [ ] 成功标准已量化 (SC-001...)

### 阶段三：技术设计

- [ ] 数据库设计完成
- [ ] API 设计完成
- [ ] 数据流设计完成
- [ ] 边界情况已识别
- [ ] 技术风险已评估
- [ ] 架构决策已记录 (ADR)

### 阶段四：BDD 场景

- [ ] 至少 5 个场景
- [ ] 覆盖 Happy/Error/Edge
- [ ] 使用标准 Gherkin 语法
- [ ] 关联功能需求 (@FR-XXX)

### 阶段五：TDD 开发

- [ ] 所有单元测试通过
- [ ] 测试覆盖率 > 80%
- [ ] 代码复杂度 < 10
- [ ] 所有边界条件已测试

### 阶段六：服务实现

- [ ] 服务层测试覆盖率 > 80%
- [ ] 控制器测试覆盖率 > 70%
- [ ] 所有 BDD 场景通过
- [ ] 所有单元测试通过

### 阶段七：E2E 测试

- [ ] 核心用户流程覆盖
- [ ] 错误场景覆盖
- [ ] 响应式布局验证
- [ ] 性能基准测试

### 阶段八：代码优化

- [ ] 性能提升 > 20%
- [ ] 代码重复率 < 5%
- [ ] 无安全漏洞
- [ ] 无循环依赖

---

## 📁 命令文件位置

所有命令文件位于 `.opencode/commands/` 目录：

| 文件                    | 命令                  |
| ----------------------- | --------------------- |
| `oks-vision.md`         | `/oks-vision`         |
| `oks-user-story.md`     | `/oks-user-story`     |
| `oks-design.md`         | `/oks-design`         |
| `oks-bdd.md`            | `/oks-bdd`            |
| `oks-tdd.md`            | `/oks-tdd`            |
| `oks-implementation.md` | `/oks-implementation` |
| `oks-optimization.md`   | `/oks-optimization`   |
| `oks-generator.md`      | `/oks-generator`      |
| `oks-list.md`           | `/oks-list`           |
| `oks-help.md`           | `/oks-help`           |

---

## 📂 状态存储

工作流进度通过文件存在性检测：

| 阶段   | 检测文件                               |
| ------ | -------------------------------------- |
| 阶段一 | `<project>/docs/specify/vision.md`     |
| 阶段二 | `<project>/docs/specify/user-story.md` |
| 阶段三 | `<project>/docs/specify/design.md`     |
| 阶段四 | `features/{feature}.feature`           |
| 阶段五 | `src/modules/{module}/entities/`       |
| 阶段六 | `src/modules/{module}/services/`       |
| 阶段七 | `e2e/{feature}.spec.ts`                |
| 阶段八 | 优化报告（可选）                       |

---

**OKS** = **O**penCode **K**nowledge **S**ystem

**版本**: 3.1.0  
**更新日期**: 2026-03-14
