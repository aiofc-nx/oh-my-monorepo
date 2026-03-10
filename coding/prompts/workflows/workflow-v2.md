---
description: 完整开发工作流程（US → BDD → TDD → 实现 → 优化）
agent: build
argument-hint: '<功能名称> [--skip-bdd] [--skip-optimize] [--stage=<阶段>]'
---

# 开发工作流程：US → BDD → TDD → 实现 → 优化

> **注意**: 本文档是工作流总控文件，各阶段详情请查看 `workflows/` 目录下的独立文件。

---

## 📋 参数说明

| 参数              | 说明                  | 默认值 |
| ----------------- | --------------------- | ------ |
| `$1`              | 功能名称（必需）      | -      |
| `--skip-bdd`      | 跳过 BDD 场景设计阶段 | false  |
| `--skip-optimize` | 跳过代码优化阶段      | false  |
| `--stage=<阶段>`  | 仅执行指定阶段        | -      |
| `--resume`        | 从上次中断的阶段继续  | false  |

**示例**:

```bash
# 完整流程
/workflow 用户登录

# 快速模式（跳过 BDD 和优化）
/workflow 用户登录 --skip-bdd --skip-optimize

# 单阶段模式
/workflow 用户登录 --stage=tdd

# 恢复模式
/workflow 用户登录 --resume
```

---

## 🎯 执行模式

### 完整模式（默认）

```
阶段一 → 阶段二 → 阶段三 → 阶段四 → 阶段五
```

- **适用**: 正式项目、质量要求高
- **耗时**: 2-4 小时
- **产出**: 完整文档 + 测试 + 代码 + 优化

### 快速模式

```bash
/workflow <功能> --skip-bdd --skip-optimize
```

```
阶段一 → 阶段三 → 阶段四
```

- **适用**: 原型开发、快速迭代
- **耗时**: 1-2 小时
- **产出**: 用户故事 + 测试 + 代码

### 单阶段模式

```bash
/workflow <功能> --stage=<阶段>
```

- **适用**: 修复问题、补充特定阶段
- **耗时**: 30 分钟 - 1 小时
- **产出**: 指定阶段产出物

---

## 📁 阶段文件

| 阶段   | 文件                                  | 说明                              |
| ------ | ------------------------------------- | --------------------------------- |
| 阶段一 | `workflows/stage-1-user-story.md`     | 创建符合 INVEST 原则的用户故事    |
| 阶段二 | `workflows/stage-2-bdd-scenario.md`   | 设计 BDD 场景（Happy/Error/Edge） |
| 阶段三 | `workflows/stage-3-tdd-cycle.md`      | TDD 红-绿-重构循环                |
| 阶段四 | `workflows/stage-4-implementation.md` | 实现服务层和数据访问层            |
| 阶段五 | `workflows/stage-5-optimization.md`   | 代码质量与性能优化                |

---

## 🔄 进度跟踪

### 自动保存进度

进度自动保存到 `.workflow/progress.json`:

```json
{
  "feature": "用户登录",
  "currentStage": "tdd",
  "completedStages": ["user-story", "bdd"],
  "testCoverage": 75,
  "startTime": "2026-03-11T01:30:00Z"
}
```

### 进度可视化

```
用户登录功能开发进度:
[████████░░░░░░░░░░░░] 40% - TDD 开发中

已完成:
✅ 用户故事 (10 min)
✅ BDD 场景 (15 min)
🔄 TDD 循环 (20 min - 进行中)
⏳ 代码实现 (预计 30 min)
⏳ 代码优化 (预计 15 min)
```

---

## 📊 工作流程概览

```mermaid
flowchart LR
    A["阶段一<br/>用户故事"] --> B["阶段二<br/>BDD 场景"]
    B --> C["阶段三<br/>TDD 循环"]
    C --> D["阶段四<br/>代码实现"]
    D --> E["阶段五<br/>代码优化"]
```

### 各阶段产出物

| 阶段       | 产出物              | 完成条件            |
| ---------- | ------------------- | ------------------- |
| **阶段一** | 用户故事文档        | INVEST 所有检查通过 |
| **阶段二** | Feature 文件        | 至少 3 个场景       |
| **阶段三** | 单元测试 + 实现     | 覆盖率 > 80%        |
| **阶段四** | 服务层 + 数据访问层 | 所有 BDD 场景通过   |
| **阶段五** | 优化代码            | 性能提升 > 20%      |

---

## 🚀 快速开始

### 1. 完整流程

```bash
/workflow 用户登录
```

自动执行所有 5 个阶段。

### 2. 仅执行特定阶段

```bash
# 仅创建用户故事
/workflow 用户登录 --stage=user-story

# 仅执行 TDD
/workflow 用户登录 --stage=tdd

# 仅优化代码
/workflow 用户登录 --stage=optimization
```

### 3. 快速开发

```bash
/workflow 用户登录 --skip-bdd --skip-optimize
```

跳过 BDD 和优化阶段，快速完成开发。

---

## 🚨 故障排查

### 测试失败

```bash
# 查看详细错误
pnpm vitest run --reporter=verbose

# 回退到 TDD 阶段
/workflow $ARGUMENTS --stage=tdd
```

### BDD 场景失败

```bash
# 运行特定场景
pnpm vitest run features/$ARGUMENTS.feature

# 回退到实现阶段
/workflow $ARGUMENTS --stage=implementation
```

### 覆盖率不足

```bash
# 查看覆盖率报告
pnpm vitest run --coverage

# 补充测试
/workflow $ARGUMENTS --stage=tdd
```

### 性能不达标

```bash
# 继续优化
/workflow $ARGUMENTS --stage=optimization
```

---

## 📚 常用命令

```bash
# 运行所有测试
pnpm vitest run

# 运行特定测试
pnpm vitest run <file-path>

# 运行 BDD 测试
pnpm vitest run features/

# 测试覆盖率
pnpm vitest run --coverage

# 代码格式化
pnpm prettier --write .

# 代码检查
pnpm eslint src/

# 类型检查
pnpm tsc --noEmit
```

---

## 🎯 决策树

```
开始开发 $ARGUMENTS
    │
    ├─→ 用户故事是否符合 INVEST？
    │   ├─ Yes → 继续
    │   └─ No  → 重写用户故事（阶段一）
    │
    ├─→ 是否需要 BDD？
    │   ├─ Yes → 设计 BDD 场景（阶段二）
    │   └─ No  → 跳过（--skip-bdd）
    │
    ├─→ TDD 测试覆盖率 > 80%？
    │   ├─ Yes → 继续
    │   └─ No  → 补充测试（阶段三）
    │
    ├─→ 所有 BDD 场景通过？
    │   ├─ Yes → 继续
    │   └─ No  → 修复实现（阶段四）
    │
    └─→ 是否需要优化？
        ├─ Yes → 代码优化（阶段五）
        └─ No  → 跳过（--skip-optimize）
```

---

## 📖 各阶段详情

### 阶段一：用户故事

**详细文档**: `workflows/stage-1-user-story.md`

**核心任务**:

- 分析需求
- 识别角色
- 定义价值
- INVEST 验证

**产出**: `docs/user-stories/$ARGUMENTS.md`

---

### 阶段二：BDD 场景

**详细文档**: `workflows/stage-2-bdd-scenario.md`

**核心任务**:

- 识别场景（Happy/Error/Edge）
- 编写 Gherkin
- 定义步骤

**产出**:

- `features/$ARGUMENTS.feature`
- `features/step-definitions/$ARGUMENTS.steps.ts`

---

### 阶段三：TDD 循环

**详细文档**: `workflows/stage-3-tdd-cycle.md`

**核心任务**:

- 🔴 编写失败的测试
- 🟢 最简实现
- 🔵 重构优化

**产出**:

- `src/modules/[module]/[entity].spec.ts`
- `src/modules/[module]/[entity].ts`

---

### 阶段四：代码实现

**详细文档**: `workflows/stage-4-implementation.md`

**核心任务**:

- 实现服务层
- 实现数据访问层
- 实现控制器

**产出**:

- `src/modules/[module]/services/[module].service.ts`
- `src/modules/[module]/repositories/[module].repository.ts`

---

### 阶段五：代码优化

**详细文档**: `workflows/stage-5-optimization.md`

**核心任务**:

- 性能分析
- 代码质量检查
- 架构优化
- 安全加固

**产出**: 优化后的代码 + 性能报告

---

## 🔗 快速工作流变体

除了完整工作流，还提供快速变体：

### TDD 快速流程

**文件**: `workflows/tdd-quick.md`

```bash
/workflow-quick 用户登录
```

仅执行: 用户故事 → TDD → 实现

### 仅实现

**文件**: `workflows/implement-only.md`

```bash
/workflow-implement 用户登录
```

跳过用户故事和 BDD，直接从 TDD 开始。

---

## 📝 参考资源

- [阶段一：用户故事](./stage-1-user-story.md)
- [阶段二：BDD 场景](./stage-2-bdd-scenario.md)
- [阶段三：TDD 循环](./stage-3-tdd-cycle.md)
- [阶段四：代码实现](./stage-4-implementation.md)
- [阶段五：代码优化](./stage-5-optimization.md)
- [OpenCode 命令规范](../../.opencode/docs/命令文件编写规范.md)

---

## 💡 使用建议

### 对 AI Agent

1. **首次使用**: 使用完整模式建立基线
2. **常规使用**: 根据复杂度选择模式
3. **遇到错误**: 参考故障排查章节
4. **利用恢复**: 使用 `--resume` 避免重复工作

### 对用户

1. **提供清晰需求**: 使用 INVEST 原则
2. **每阶段验证**: 检查产出物是否满足要求
3. **中断恢复**: 使用 `--resume` 继续未完成的工作
4. **灵活组合**: 根据需要跳过或重试阶段

---

**文档版本**: v2.1（模块化版本）
**最后更新**: 2026-03-11
