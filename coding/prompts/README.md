# Prompts 目录

本目录包含 AI Agent 开发工作流程的模块化命令文件。

---

## 🆕 功能目录模式（v2.0 新特性）

> **推荐使用功能目录模式**，提供更好的上下文管理和进度跟踪

### 什么是功能目录模式？

功能目录模式将每个功能的所有文档集中在一个目录中，提供：

- ✅ **单一事实来源**: 所有文档集中管理
- ✅ **详细进度跟踪**: 实现日志和中断恢复
- ✅ **架构决策记录**: ADR 格式的决策文档
- ✅ **可复用提示词**: 常见任务的提示词库

### 功能目录结构

```
prompts/
├── workflows/              # 工作流文件
├── features/               # 功能目录（v2.0）
│   ├── _template/          # 功能模板
│   │   ├── AGENTS.md       # AI 助手指南
│   │   ├── design.md       # 设计文档
│   │   ├── implementation.md # 实现进度
│   │   ├── decisions.md    # 决策记录（ADR）
│   │   ├── bdd-scenarios.md # BDD 场景
│   │   └── prompts.md      # 可复用提示词
│   └── user-login/         # 实际功能示例
│       └── ...
└── README.md
```

### 使用功能目录模式

```bash
# 1. 创建新功能
/workflow --init 用户登录

# 2. 填写设计文档
"我要开发用户登录功能。请填写 features/user-login/design.md"

# 3. 开始开发
/workflow 用户登录

# 4. 中断后恢复
/workflow --resume 用户登录
```

---

## 📁 目录结构

```
prompts/
├── workflows/                  # 所有工作流和阶段模块
│   ├── workflow.md                  # 主工作流（总控）
│   ├── tdd-quick.md                # 快速 TDD 工作流
│   ├── stage-1-user-story.md       # 阶段一：用户故事
│   ├── stage-2-bdd-scenario.md     # 阶段二：BDD 场景
│   ├── stage-3-tdd-cycle.md        # 阶段三：TDD 循环
│   ├── stage-4-implementation.md   # 阶段四：代码实现
│   └── stage-5-optimization.md     # 阶段五：代码优化
└── features/                   # 功能目录（v2.0 新增）
    ├── _template/                  # 功能模板
    └── user-login/                 # 实际功能示例
```

---

## 🚀 快速开始

### 方式 1：功能目录模式（推荐）

#### 1.1 创建新功能

```bash
/workflow --init 用户登录
```

#### 1.2 填写设计文档

```bash
"我要开发用户登录功能。这是我的想法：[描述]。
请审查代码库并填写 features/user-login/design.md"
```

#### 1.3 开始开发

```bash
/workflow 用户登录
```

**适用场景**: 正式项目、质量要求高
**预计耗时**: 2-4 小时
**优势**: 完整的文档、进度跟踪、决策记录

---

### 方式 2：参数模式（传统）

#### 2.1 完整工作流

```bash
/workflow 用户登录
```

执行所有 5 个阶段，产出完整的文档、测试和代码。

**适用场景**: 正式项目、质量要求高
**预计耗时**: 2-4 小时

---

### 3. 快速工作流

```bash
/workflow-quick 用户登录
```

跳过 BDD 和优化阶段，快速完成开发。

**适用场景**: 原型开发、快速迭代
**预计耗时**: 1-2 小时

---

### 3. 单阶段执行

```bash
# 仅创建用户故事
/stage-1-user-story 用户登录

# 仅设计 BDD 场景
/stage-2-bdd-scenario 用户登录

# 仅执行 TDD
/stage-3-tdd-cycle 用户登录

# 仅实现代码
/stage-4-implementation 用户登录

# 仅优化代码
/stage-5-optimization 用户登录
```

**适用场景**: 修复问题、补充特定阶段
**预计耗时**: 30 分钟 - 1 小时

---

## 📊 工作流对比

| 工作流         | 阶段      | 耗时   | 覆盖率 | 适用场景 |
| -------------- | --------- | ------ | ------ | -------- |
| **完整工作流** | 1→2→3→4→5 | 2-4h   | >80%   | 正式项目 |
| **快速工作流** | 1→3→4     | 1-2h   | >70%   | 原型开发 |
| **单阶段**     | 指定阶段  | 0.5-1h | -      | 修复问题 |

---

## 🎯 各阶段说明

### 阶段一：用户故事（User Story）

**文件**: `workflows/stage-1-user-story.md`

**输入**: 功能名称
**输出**: `docs/user-stories/$ARGUMENTS.md`
**耗时**: 10-15 分钟

**核心任务**:

- 分析需求
- 识别角色
- 定义价值
- INVEST 验证

**新增特性**:

- **优先级排序**: P1/P2/P3 + 原因说明
- **独立测试描述**: 每个故事可独立开发/测试/部署
- **需求编号**: FR-001, FR-002...
- **成功标准量化**: SC-001, SC-002...
- **待澄清标记**: `[NEEDS CLARIFICATION: ...]`

---

### 阶段二：BDD 场景设计

**文件**: `workflows/stage-2-bdd-scenario.md`

**输入**: 用户故事
**输出**: `features/$ARGUMENTS.feature`
**耗时**: 15-20 分钟

**核心任务**:

- 识别场景（Happy/Error/Edge）
- 编写 Gherkin
- 定义步骤

**新增特性**:

- **边界情况识别**: 提问式引导清单
  - 输入边界、状态边界、时间边界
  - 权限边界、系统边界
- **场景关联需求**: @FR-XXX 标签
- **成功标准验证**: 在场景中量化验证

---

### 阶段三：TDD 循环

**文件**: `workflows/stage-3-tdd-cycle.md`

**输入**: BDD 场景
**输出**:

- `src/modules/[module]/[entity].spec.ts`
- `src/modules/[module]/[entity].ts`
  **耗时**: 30-40 分钟

**核心任务**:

- 🔴 Red: 编写失败的测试
- 🟢 Green: 最简实现
- 🔵 Refactor: 优化代码

---

### 阶段四：代码实现

**文件**: `workflows/stage-4-implementation.md`

**输入**: 核心模型
**输出**:

- `src/modules/[module]/services/[module].service.ts`
- `src/modules/[module]/repositories/[module].repository.ts`
  **耗时**: 30-40 分钟

**核心任务**:

- 实现服务层
- 实现数据访问层
- 实现控制器

---

### 阶段五：代码优化

**文件**: `workflows/stage-5-optimization.md`

**输入**: 实现代码
**输出**: 优化后的代码 + 性能报告
**耗时**: 15-30 分钟

**核心任务**:

- 性能分析
- 代码质量检查
- 架构优化
- 安全加固

---

## 💡 使用建议

### 选择合适的工作流

```
需求明确 + 质量要求高
    → 完整工作流（/workflow）

快速原型 + 时间紧张
    → 快速工作流（/workflow-quick）

补充特定阶段
    → 单阶段（/stage-N-xxx）

修复问题
    → 单阶段（/stage-N-xxx）
```

### 参数说明

**通用参数**:

- `<功能名称>`: 功能名称（必需）
- `--skip-bdd`: 跳过 BDD 阶段
- `--skip-optimize`: 跳过优化阶段
- `--stage=<阶段>`: 仅执行指定阶段
- `--resume`: 从上次中断处继续

**示例**:

```bash
# 完整流程
/workflow 用户登录

# 跳过 BDD
/workflow 用户登录 --skip-bdd

# 仅执行 TDD
/workflow 用户登录 --stage=tdd

# 恢复执行
/workflow 用户登录 --resume
```

---

## 🔄 工作流组合

### 组合 1: 用户故事 + BDD

```bash
/stage-1-user-story 用户登录
/stage-2-bdd-scenario 用户登录
```

**适用**: 需求分析和验收标准定义

### 组合 2: TDD + 实现

```bash
/stage-3-tdd-cycle 用户登录
/stage-4-implementation 用户登录
```

**适用**: 已有用户故事，直接开发

### 组合 3: 实现 + 优化

```bash
/stage-4-implementation 用户登录
/stage-5-optimization 用户登录
```

**适用**: 已有测试，补充实现和优化

---

## 📚 相关文档

- [命令文件编写规范](../../.opencode/docs/命令文件编写规范.md)
- [模版文件编写规范](../../.opencode/docs/模版文件编写规范.md)
- [workflow 分析报告](../../.opencode/docs/workflow分析-AI-Agent视角.md)
- [workflow 改进总结](../../.opencode/docs/workflow改进总结.md)

---

## 🛠️ 自定义工作流

### 创建自定义工作流

1. 创建文件: `prompts/workflows/my-workflow.md`
2. 添加 frontmatter:

```yaml
---
description: 我的工作流
agent: build
argument-hint: '<参数>'
---
```

3. 引用阶段:

```markdown
参考 `workflows/stage-1-user-story.md` 执行阶段一
```

### 示例：测试优先工作流

```markdown
---
description: 测试优先工作流（BDD → TDD → 实现）
agent: build
argument-hint: '<功能名称>'
---

# 测试优先工作流

## 阶段一：BDD 场景

参考: `workflows/stage-2-bdd-scenario.md`

## 阶段二：TDD 循环

参考: `workflows/stage-3-tdd-cycle.md`

## 阶段三：代码实现

参考: `workflows/stage-4-implementation.md`
```

---

## 📝 常见问题

### Q: 应该使用哪个工作流？

A: 根据项目需求选择：

- **正式项目**: 完整工作流
- **快速原型**: 快速工作流
- **补充特定阶段**: 单阶段

### Q: 可以跳过某个阶段吗？

A: 可以，使用参数：

```bash
/workflow 用户登录 --skip-bdd --skip-optimize
```

### Q: 如何从中断处继续？

A: 使用 `--resume` 参数：

```bash
/workflow 用户登录 --resume
```

### Q: 各阶段可以独立执行吗？

A: 可以，但需要确保前置条件：

- 阶段二需要阶段一的用户故事
- 阶段三需要阶段二的 BDD 场景
- 阶段四需要阶段三的核心模型

---

**文档版本**: v2.0
**最后更新**: 2026-03-11

**v2.0 更新内容**（功能目录模式）:

- ✨ 新增功能目录模式（features/）
- ✨ 新增 AGENTS.md（AI 助手专用指南）
- ✨ 新增 design.md（单一事实来源）
- ✨ 新增 implementation.md（详细实现进度）
- ✨ 新增 decisions.md（架构决策记录 ADR）
- ✨ 新增 prompts.md（可复用提示词库）
- ✨ 新增 bdd-scenarios.md（BDD 场景文档）
- ✨ 创建 user-login 完整示例
- 📝 更新 workflow.md 支持功能目录模式
- 📝 更新 README.md 文档

**v1.2 更新内容**:

- 阶段一增加优先级排序、独立测试、需求编号、成功标准、待澄清标记
- 阶段二增加边界情况识别清单、场景关联需求标签
