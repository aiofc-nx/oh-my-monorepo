# OKS Coding System

> **OKS** = **O**penCode **K**nowledge **S**ystem - 一套完整的软件开发生命周期方法论

---

## 📋 概述

OKS Coding System 是一套结构化的软件开发方法论，涵盖从需求分析到代码优化的完整流程。所有命令都以 `oks-` 为前缀，区别于其他命令。

### 核心理念

- **文档驱动**: 先设计，后编码
- **测试驱动**: TDD + BDD 双重保障
- **阶段分明**: 8个开发阶段，逐步推进
- **可追溯性**: 文档间相互关联，形成完整追溯链

---

## 🚀 快速开始

### 标准工作流

```
阶段一: 愿景文档     /oks-vision
    ↓
阶段二: 用户故事     /oks-user-story
    ↓
阶段三: 技术设计     /oks-design
    ↓
阶段四: BDD 场景     /oks-bdd (可选)
    ↓
阶段五: TDD 开发     /oks-tdd
    ↓
阶段六: 服务实现     /oks-implementation
    ↓
阶段七: E2E 测试     /oks-e2e (可选)
    ↓
阶段八: 代码优化     /oks-optimization (可选)
```

### 新功能开发示例

```bash
# 1. 创建/确认项目愿景
/oks-vision user-center

# 2. 创建用户故事
/oks-user-story 用户登录

# 3. 技术设计
/oks-design 用户登录

# 4. BDD 场景（可选）
/oks-bdd 用户登录

# 5. TDD 开发领域模型
/oks-tdd 用户登录

# 6. 实现服务层
/oks-implementation 用户登录

# 7. E2E 测试（可选）
/oks-e2e 用户登录

# 8. 代码优化（可选）
/oks-optimization 用户登录
```

---

## 📚 命令索引

### 核心开发命令

| 命令                  | 功能           | 阶段 | 产出文件                                     |
| --------------------- | -------------- | ---- | -------------------------------------------- |
| `/oks-vision`         | 项目愿景管理   | 1    | `<project>/docs/specify/vision.md`           |
| `/oks-user-story`     | 用户故事设计   | 2    | `<project>/docs/specify/{feature}.md`        |
| `/oks-design`         | 技术设计       | 3    | `<project>/docs/specify/{feature}.md`        |
| `/oks-bdd`            | BDD 场景设计   | 4    | `features/{feature}.feature`                 |
| `/oks-tdd`            | TDD 开发循环   | 5    | `src/modules/{module}/entities/*.entity.ts`  |
| `/oks-implementation` | 服务层实现     | 6    | `src/modules/{module}/services/*.service.ts` |
| `/oks-e2e`            | E2E 端到端测试 | 7    | `e2e/{feature}.spec.ts`                      |
| `/oks-optimization`   | 代码优化       | 8    | 优化后的代码                                 |

### 辅助命令

| 命令             | 功能                       |
| ---------------- | -------------------------- |
| `/oks-generator` | 创建新项目（NestJS/React） |
| `/oks-list`      | 查看项目列表               |
| `/oks-help`      | 查看命令帮助               |

---

## 📁 文档结构

```
<project>/
├── docs/
│   └── specify/
│       ├── vision.md           # 阶段一：项目愿景
│       ├── {feature}.md        # 阶段二/三：用户故事 + 技术设计
│       └── ...
├── features/
│   ├── {feature}.feature       # 阶段四：BDD 场景
│   └── step-definitions/
│       └── {feature}.steps.ts  # BDD 步骤定义
├── src/
│   └── modules/{module}/
│       ├── entities/           # 阶段五：领域模型
│       ├── services/           # 阶段六：服务层
│       ├── controllers/        # 阶段六：控制器
│       └── repositories/       # 阶段六：数据访问层
└── e2e/
    └── {feature}.spec.ts       # 阶段七：E2E 测试
```

---

## 🔄 各阶段详解

### 阶段一：项目愿景 (`/oks-vision`)

**用途**: 定义项目的业务边界、目标用户和核心功能

**用法**:

```bash
/oks-vision                    # 查看愿景列表
/oks-vision <项目名>           # 查看/修改愿景
/oks-vision 新建 <项目名>      # 创建新愿景
```

**核心要素**:

- **适用范围**: 业务边界和使用场景
- **使用人员**: 目标用户群体和角色
- **功能模块**: 核心功能清单及优先级

**重要约束**: 愿景文档必须纯粹描述业务，禁止包含技术实现细节

**产出**: `<project>/docs/specify/vision.md`

---

### 阶段二：用户故事 (`/oks-user-story`)

**用途**: 将功能需求转化为符合 INVEST 原则的用户故事

**用法**:

```bash
/oks-user-story <功能名称>
```

**INVEST 原则**:
| 原则 | 说明 | 检查点 |
| --------------- | -------- | ---------------- |
| **I**ndependent | 独立性 | 故事之间无依赖 |
| **N**egotiable | 可协商 | 细节可讨论 |
| **V**aluable | 有价值 | 对用户有明确价值 |
| **E**stimable | 可估算 | 工作量 < 3 天 |
| **S**mall | 足够小 | 单次迭代完成 |
| **T**estable | 可测试 | 验收标准明确 |

**产出内容**:

- 故事描述（作为...我想要...以便于...）
- 功能需求 (FR-001, FR-002...)
- 验收标准
- 成功标准 (SC-001, SC-002...)

**产出**: `<project>/docs/specify/{feature}.md`

---

### 阶段三：技术设计 (`/oks-design`)

**用途**: 创建技术实现方案

**用法**:

```bash
/oks-design <功能名称>
```

**设计内容**:

- 📦 技术架构（架构图、核心模块）
- 💾 数据库设计（表结构、字段、索引）
- 🔌 API 设计（接口定义、请求/响应格式）
- 🎨 UI 设计（组件、页面、交互流程）
- 🔄 数据流设计
- 🔐 安全设计
- ⚡ 性能设计
- 🧪 测试策略

**重要约束**:

- 必须先读取 `docs/guides/tech-stack.md` 作为技术基线
- 设计文档专注于技术实现，不重复业务内容

**产出**: `<project>/docs/specify/{feature}.md`（追加技术设计内容）

---

### 阶段四：BDD 场景 (`/oks-bdd`)

**用途**: 从用户故事创建可执行的 BDD 测试场景

**用法**:

```bash
/oks-bdd <功能名称>
```

**场景类型**:
| 类型 | 说明 | 最少数量 |
| ------------- | ------------ | -------- |
| Happy Path | 正常流程 | 2 |
| Error Cases | 异常场景 | 2 |
| Edge Cases | 边界条件 | 1 |

**边界情况识别**:

- **输入边界**: 空/null、超长、特殊字符、格式错误
- **状态边界**: 资源不存在、重复、锁定、上限
- **时间边界**: 超时、过期、并发冲突
- **权限边界**: 未登录、权限不足、资源归属
- **系统边界**: 外部服务不可用、连接失败、资源不足

**产出**:

- `features/{feature}.feature`
- `features/step-definitions/{feature}.steps.ts`

---

### 阶段五：TDD 开发 (`/oks-tdd`)

**用途**: 使用 Red-Green-Refactor 循环开发领域模型

**用法**:

```bash
/oks-tdd <功能名称>
```

**TDD 循环**:

```
🔴 Red   → 编写失败的测试
🟢 Green → 用最简代码让测试通过
🔵 Refactor → 优化代码，保持测试通过
```

**适用场景判断**:
| 场景类型 | 示例 | 是否适合 TDD |
| ------------ | ---------------------- | ------------ |
| 领域实体 | User、Order | ✅ 强烈推荐 |
| 值对象 | Email、Money | ✅ 推荐 |
| 业务规则 | 登录锁定、库存扣减 | ✅ 推荐 |
| 纯 CRUD | 简单增删改查 | ❌ 可跳过 |
| 数据传递 | DTO、Request/Response | ❌ 无需测试 |

**测试覆盖率目标**:
| 类型 | 目标 | 优先级 |
| ---------- | ----- | ------ |
| 语句覆盖率 | > 80% | 必需 |
| 分支覆盖率 | > 70% | 推荐 |
| 函数覆盖率 | > 90% | 推荐 |

**产出**: `src/modules/{module}/entities/*.entity.ts`

---

### 阶段六：服务实现 (`/oks-implementation`)

**用途**: 实现服务层、控制器和数据访问层

**用法**:

```bash
/oks-implementation <功能名称>
```

**实现层次**:

```
src/modules/{module}/
├── controllers/
│   ├── {module}.controller.ts      # HTTP 请求处理
│   └── {module}.controller.spec.ts # 控制器测试（覆盖率 > 70%）
├── services/
│   ├── {module}.service.ts         # 业务逻辑协调
│   └── {module}.service.spec.ts    # 服务测试（覆盖率 > 80%）
└── repositories/
    ├── {module}.repository.ts      # 数据访问
    └── {module}.repository.spec.ts # Repository 测试
```

**测试优先原则**:

- 服务层测试覆盖率 > 80%（必需）
- 控制器测试覆盖率 > 70%（必需）
- 每个实现文件必须有对应的测试文件

**产出**:

- `src/modules/{module}/services/*.service.ts`
- `src/modules/{module}/controllers/*.controller.ts`
- `src/modules/{module}/repositories/*.repository.ts`

---

### 阶段七：E2E 测试 (`/oks-e2e`)

**用途**: 使用 Playwright 验证完整用户流程

**用法**:

```bash
/oks-e2e <功能名称>
```

**测试类型**:
| 类型 | 说明 | 工具 |
| -------- | ---------------- | ---------- |
| 用户流程 | 完整业务流程验证 | Playwright |
| 页面交互 | UI 组件交互测试 | Playwright |
| API 集成 | 多服务集成测试 | Playwright |

**选择器策略优先级**:

1. test-id: `page.locator('[data-testid="submit"]')`
2. role + name: `page.getByRole('button', { name: '提交' })`
3. label: `page.getByLabel('邮箱')`
4. placeholder: `page.getByPlaceholder('请输入')`
5. CSS（最后选择）: `page.locator('.submit-btn')`

**常用命令**:

```bash
pnpm playwright test                    # 运行所有 E2E 测试
pnpm playwright test e2e/{feature}.spec.ts  # 运行特定文件
pnpm playwright test --ui               # 带界面运行
pnpm playwright test --debug            # 调试模式
```

**产出**: `e2e/{feature}.spec.ts`

---

### 阶段八：代码优化 (`/oks-optimization`)

**用途**: 提升代码质量和性能

**用法**:

```bash
/oks-optimization <功能名称>
```

**优化维度**:
| 维度 | 目标 | 优先级 |
| ------------ | ---------------- | ------ |
| 性能优化 | 响应时间 < 200ms | 高 |
| 代码质量 | 重复率 < 5% | 高 |
| 架构优化 | 耦合度 < 0.3 | 中 |
| 安全加固 | 0 安全漏洞 | 高 |

**优化工具**:

```bash
pnpm vitest run --coverage     # 性能分析
pnpm jscpd src/                # 重复代码检测
pnpm madge --circular src/     # 循环依赖检测
pnpm biome check src/          # 代码检查
pnpm audit                     # 安全检查
```

**优化流程**:

1. 记录优化前基准
2. 执行一项优化
3. 运行测试 → 必须通过
4. 记录优化后数据
5. 对比效果，决定是否保留

---

## 🛠️ 项目创建 (`/oks-generator`)

**用途**: 使用 `@oksai/nest` 和 `@oksai/react` 创建应用或库

**核心约定**:

- **应用（App）** → `apps/<name>`
- **内部库（Internal Lib）** → `libs/<name>`
- **公共包（Public Package）** → `packages/<name>`

**可用生成器**:
| 类型 | 生成器 | 技术栈 |
| --------------- | -------------------------------- | ------------------------ |
| NestJS 应用 | `@oksai/nest:nestjs-application` | Webpack + Vitest + Biome |
| NestJS 库 | `@oksai/nest:nestjs-library` | TypeScript + Vitest |
| React 应用 | `@oksai/react:application` | Vite + Vitest + Biome |
| React 库 | `@oksai/react:library` | Vite + TypeScript |

**用法示例**:

```bash
# 创建 NestJS 应用
pnpm nx g @oksai/nest:nestjs-application --directory=apps/api

# 创建带 Controller 和 Service 的 NestJS 库
pnpm nx g @oksai/nest:nestjs-library --directory=libs/user --service --controller

# 创建 React 应用（带 SCSS）
pnpm nx g @oksai/react:application --directory=apps/web --style=scss

# 创建 React 库
pnpm nx g @oksai/react:library --directory=libs/shared-ui
```

**自动创建开发文档**:
项目创建后会自动在 `<project>/docs/specify/` 添加开发文档模板：

- `vision.md` - 愿景文档
- `design.md` - 设计文档
- `implementation.md` - 实现进度
- `decisions.md` - 架构决策记录
- `bdd-scenarios.md` - BDD 测试场景
- `user-story.md` - 用户故事

---

## ✅ 阶段完成条件

### 愿景阶段

- [ ] 适用范围明确
- [ ] 使用人员定义完整
- [ ] 功能模块按优先级排序
- [ ] 纯业务描述（无技术内容）

### 用户故事阶段

- [ ] 符合 INVEST 所有原则
- [ ] 功能需求已编号 (FR-001, FR-002...)
- [ ] 成功标准已量化 (SC-001, SC-002...)
- [ ] 至少 3 个验收标准

### 技术设计阶段

- [ ] 数据库设计完成
- [ ] API 设计完成
- [ ] 数据流设计完成
- [ ] 边界情况已识别

### BDD 阶段

- [ ] 至少 5 个场景（Happy + Error + Edge）
- [ ] 所有场景使用标准 Gherkin 语法
- [ ] 步骤定义文件已创建

### TDD 阶段

- [ ] 所有单元测试通过
- [ ] 测试覆盖率 > 80%
- [ ] 代码复杂度 < 10

### 实现阶段

- [ ] 服务层测试覆盖率 > 80%
- [ ] 控制器测试覆盖率 > 70%
- [ ] 所有 BDD 场景通过

### E2E 阶段

- [ ] 所有 E2E 测试通过
- [ ] 测试在 CI 环境通过

### 优化阶段

- [ ] 性能提升 > 20%
- [ ] 代码重复率 < 5%
- [ ] 无安全漏洞

---

## 🔗 命令间关系

```
/oks-vision (前置)
     ↓
/oks-user-story (必需前置: vision)
     ↓
/oks-design (必需前置: user-story)
     ↓
/oks-bdd (可选前置: user-story, design)
     ↓
/oks-tdd (必需前置: user-story)
     ↓
/oks-implementation (必需前置: tdd)
     ↓
/oks-e2e (必需前置: implementation)
     ↓
/oks-optimization (必需前置: implementation)

/oks-generator (独立，创建新项目)
/oks-list (独立，查看项目列表)
```

---

## 💡 最佳实践

### 文档优先

1. 每个项目先创建愿景文档
2. 技术设计完成后再编码
3. 保持文档与代码同步更新

### 测试驱动

1. TDD 确保领域模型质量
2. BDD 确保功能符合需求
3. E2E 确保用户流程正确

### 分阶段验证

1. 每个阶段完成后运行相关测试
2. 确保所有检查项通过
3. 记录问题和解决方案

### 可选阶段

- BDD 阶段可跳过（但推荐执行）
- E2E 阶段可跳过（但推荐执行）
- 优化阶段可跳过（根据需要）

---

## 📖 参考资源

- [Nx 官方文档](https://nx.dev)
- [NestJS 文档](https://docs.nestjs.com/)
- [React 文档](https://react.dev/)
- [Vitest 文档](https://vitest.dev/)
- [Playwright 文档](https://playwright.dev/)
- [TDD 最佳实践](https://testdriven.io/test-driven-development/)
- [INVEST 原则](<https://en.wikipedia.org/wiki/INVEST_(mnemonic)>)

---

## 📝 版本信息

**版本**: 3.1.0  
**更新日期**: 2026-03-14
