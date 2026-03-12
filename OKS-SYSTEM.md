# OKS Coding Agent System

> **OKS** = **O**penCode **K**nowledge **S**ystem

OKS 是一套基于 TDD/BDD 的 AI 辅助开发工作流系统，帮助开发者以规范化的方式完成从需求到代码的完整开发流程。

---

## 📋 目录

- [系统概述](#系统概述)
- [系统架构](#系统架构)
- [快速开始](#快速开始)
- [命令参考](#命令参考)
- [工作流程](#工作流程)
- [脚本工具](#脚本工具)
- [功能模板](#功能模板)
- [常见问题](#常见问题)

---

## 系统概述

### 核心特性

| 特性             | 说明                               |
| ---------------- | ---------------------------------- |
| **阶段防护**     | 自动验证前置条件，防止跳过必要阶段 |
| **TDD/BDD 驱动** | 测试先行，确保代码质量             |
| **进度跟踪**     | 记录开发进度，支持中断恢复         |
| **模板化**       | 标准化的功能模板，快速启动新功能   |

### 开发流程

```
阶段一: 用户故事 (10-15min)
    ↓
阶段二: BDD 场景 (15-20min)
    ↓
阶段三: TDD 循环 (30-40min)
    ↓
阶段四: 代码实现 (30-40min)
    ↓
阶段五: 代码优化 (15-30min)
```

**总耗时**: 2-4 小时 | **测试覆盖率**: >80%

---

## 系统架构

OKS 系统由四个核心部分组成：

```
OKS Coding Agent System
│
├── 📁 .opencode/commands/     # 命令文件（8个）
│   └── oks-*.md               # 可执行命令
│
├── 📁 oks-coding-system/prompts/         # 静态模板
│   └── features/              # 功能目录模板
│
├── 📁 oks-coding-system/scripts/         # 运行脚本（4个）
│   ├── common.sh              # 核心函数库
│   ├── check-prerequisites.sh # 前置检查
│   ├── create-feature.sh      # 创建功能
│   └── validate_feature.sh    # 功能验证
│
└── 📁 .workflow/              # 工作流状态
    ├── progress.json          # 进度跟踪
    ├── workspace-state.json   # 工作区状态
    └── workflow-cli.js        # CLI 工具
```

### 各部分职责

| 组件                         | 职责           | 维护频率       |
| ---------------------------- | -------------- | -------------- |
| `.opencode/commands/`        | 定义可执行命令 | 低（稳定）     |
| `oks-coding-system/prompts/` | 提供功能模板   | 中（按需添加） |
| `oks-coding-system/scripts/` | 提供工具脚本   | 低（稳定）     |
| `.workflow/`                 | 跟踪开发状态   | 高（自动更新） |

---

## 快速开始

### 方式一：完整工作流（推荐）

```bash
# 1. 创建新功能
bash oks-coding-system/scripts/create-feature.sh 用户登录

# 2. 运行完整工作流
/oks-workflow 用户登录
```

### 方式二：快速 TDD

```bash
# 跳过 BDD 和优化，快速开发
/oks-tdd-quick 用户登录
```

### 方式三：分阶段执行

```bash
# 按顺序执行各阶段
/oks-stage-1-user-story 用户登录
/oks-stage-2-bdd 用户登录
/oks-stage-3-tdd 用户登录
/oks-stage-4-implementation 用户登录
/oks-stage-5-optimization 用户登录
```

### 查看进度

```bash
# 查看功能状态
bash oks-coding-system/scripts/check-prerequisites.sh --status --feature="用户登录"
```

---

## 命令参考

### 主命令

| 命令             | 说明                      | 示例                      |
| ---------------- | ------------------------- | ------------------------- |
| `/oks-workflow`  | 完整工作流（阶段 1-5）    | `/oks-workflow 用户登录`  |
| `/oks-tdd-quick` | 快速 TDD（跳过 BDD/优化） | `/oks-tdd-quick 用户登录` |
| `/oks-help`      | 查看帮助                  | `/oks-help`               |

### 阶段命令

| 命令                          | 说明          | 前置条件             |
| ----------------------------- | ------------- | -------------------- |
| `/oks-stage-1-user-story`     | 创建用户故事  | 无                   |
| `/oks-stage-2-bdd`            | 设计 BDD 场景 | 用户故事             |
| `/oks-stage-3-tdd`            | TDD 开发循环  | 用户故事（BDD 可选） |
| `/oks-stage-4-implementation` | 代码实现      | TDD 模块             |
| `/oks-stage-5-optimization`   | 代码优化      | 实现代码             |

### 命令参数

```bash
# 通用参数
/oks-workflow <功能名称> [--skip-bdd] [--skip-optimize] [--stage=<N>] [--resume]

# 示例
/oks-workflow 用户登录                    # 完整流程
/oks-workflow 用户登录 --skip-bdd          # 跳过 BDD
/oks-workflow 用户登录 --stage=3           # 仅执行阶段 3
/oks-workflow 用户登录 --resume            # 恢复执行
```

---

## 工作流程

### 阶段一：用户故事

**目标**: 创建符合 INVEST 原则的用户故事

```bash
/oks-stage-1-user-story 用户登录
```

**输出**:

- `docs/user-stories/用户登录.md` - 用户故事文档
- 功能需求 (FR-001, FR-002...)
- 成功标准 (SC-001, SC-002...)

**耗时**: 10-15 分钟

---

### 阶段二：BDD 场景

**目标**: 从用户故事创建可执行的 BDD 场景

```bash
/oks-stage-2-bdd 用户登录
```

**前置条件**: ✅ 用户故事文档

**输出**:

- `features/用户登录.feature` - Gherkin 特性文件
- 至少 5 个场景（Happy/Error/Edge）

**耗时**: 15-20 分钟

---

### 阶段三：TDD 循环

**目标**: 使用 Red-Green-Refactor 驱动代码设计

```bash
/oks-stage-3-tdd 用户登录
```

**前置条件**: ✅ 用户故事（BDD 可选）

**TDD 循环**:

```
🔴 Red   → 编写失败的测试
🟢 Green → 最简实现让测试通过
🔵 Refactor → 优化代码结构
```

**输出**:

- `src/modules/user/*.spec.ts` - 单元测试
- `src/modules/user/*.ts` - 实现代码
- 测试覆盖率 > 80%

**耗时**: 30-40 分钟

---

### 阶段四：代码实现

**目标**: 实现服务层和数据访问层

```bash
/oks-stage-4-implementation 用户登录
```

**前置条件**: ✅ TDD 模块

**输出**:

- `services/` - 服务层
- `repositories/` - 数据访问层
- `controllers/` - 控制器

**耗时**: 30-40 分钟

---

### 阶段五：代码优化

**目标**: 提升代码质量和性能

```bash
/oks-stage-5-optimization 用户登录
```

**前置条件**: ✅ 实现代码

**优化维度**:

- 性能优化（响应时间 < 200ms）
- 代码质量（重复率 < 5%）
- 架构优化（耦合度 < 0.3）
- 安全加固（0 漏洞）

**耗时**: 15-30 分钟

---

## 脚本工具

### check-prerequisites.sh

检查阶段前置条件：

```bash
# 检查阶段前置条件
bash oks-coding-system/scripts/check-prerequisites.sh --json --stage=bdd --feature="用户登录"

# 初始化功能目录
bash oks-coding-system/scripts/check-prerequisites.sh --init --feature="用户登录"

# 查看功能状态
bash oks-coding-system/scripts/check-prerequisites.sh --status --feature="用户登录"

# 仅输出路径
bash oks-coding-system/scripts/check-prerequisites.sh --paths-only --feature="用户登录"
```

**输出示例**:

```json
{
  "success": true,
  "FEATURE_DIR": "/path/to/features/user-login",
  "AVAILABLE_DOCS": ["user-story.md", "bdd.feature"]
}
```

---

### create-feature.sh

从模板创建新功能：

```bash
# 创建新功能
bash oks-coding-system/scripts/create-feature.sh 用户登录

# 覆盖已存在的功能
bash oks-coding-system/scripts/create-feature.sh --overwrite 用户登录

# JSON 输出
bash oks-coding-system/scripts/create-feature.sh --json 用户登录
```

**输出**:

```
✅ Feature directory created: oks-coding-system/templates/用户登录

📁 Created files:
  - AGENTS.md
  - design.md
  - implementation.md
  - decisions.md
  - bdd-scenarios.md
  - prompts.md

🎯 Next steps:
  1. Fill in the design document
  2. Start the workflow: /oks-workflow 用户登录
```

---

### common.sh

核心函数库（供其他脚本引用）：

| 函数                          | 说明             |
| ----------------------------- | ---------------- |
| `get_feature_paths()`         | 获取所有功能路径 |
| `validate_feature_name()`     | 验证功能名称     |
| `check_stage_prerequisites()` | 检查阶段依赖     |
| `get_workflow_state()`        | 获取工作流状态   |

---

## 功能模板

### 模板结构

```
oks-coding-system/templates/
├── _template/              # 功能模板
│   ├── AGENTS.md           # AI 助手指南
│   ├── design.md           # 设计文档
│   ├── implementation.md   # 实现进度
│   ├── decisions.md        # 决策记录（ADR）
│   ├── bdd-scenarios.md    # BDD 场景
│   └── prompts.md          # 可复用提示词
│
└── user-login/             # 示例功能
    └── ...
```

### 各文件用途

| 文件                | 用途            | 填写时机   |
| ------------------- | --------------- | ---------- |
| `AGENTS.md`         | AI 助手专用指南 | 功能创建时 |
| `design.md`         | 单一事实来源    | 阶段一之前 |
| `implementation.md` | 详细实现进度    | 开发过程中 |
| `decisions.md`      | 架构决策记录    | 做出决策时 |
| `bdd-scenarios.md`  | BDD 场景文档    | 阶段二     |
| `prompts.md`        | 可复用提示词    | 按需添加   |

---

## 常见问题

### Q: 应该使用哪个工作流？

| 场景                 | 推荐工作流       |
| -------------------- | ---------------- |
| 正式项目、质量要求高 | `/oks-workflow`  |
| 快速原型、时间紧张   | `/oks-tdd-quick` |
| 补充特定阶段         | `/oks-stage-N-*` |
| 修复问题             | `/oks-stage-N-*` |

### Q: 可以跳过某个阶段吗？

A: 可以使用参数：

```bash
/oks-workflow 用户登录 --skip-bdd --skip-optimize
```

或直接执行特定阶段：

```bash
/oks-stage-3-tdd 用户登录
```

### Q: 如何从中断处继续？

A: 使用 `--resume` 参数：

```bash
/oks-workflow 用户登录 --resume
```

或查看当前状态：

```bash
bash oks-coding-system/scripts/check-prerequisites.sh --status --feature="用户登录"
```

### Q: 前置条件检查失败怎么办？

A: 系统会提示缺失的前置条件和解决方案：

```
❌ 前置条件未满足

缺失: User story document

建议: Run /oks-stage-1-user-story 用户登录 first
```

### Q: 如何查看所有可用命令？

A: 运行帮助命令：

```bash
/oks-help
```

---

## 🔒 阶段防护机制

每个阶段命令会自动验证前置条件：

```
┌─────────────────────────────────────────────────────────────┐
│                    阶段依赖关系                              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  阶段一: user-story                                          │
│  ├─ 前置: 无                                                 │
│  └─ 产出: docs/user-stories/{feature}.md                    │
│                                                             │
│  阶段二: bdd                                                 │
│  ├─ 前置: 用户故事文档 ✅                                    │
│  └─ 产出: features/{feature}.feature                        │
│                                                             │
│  阶段三: tdd                                                 │
│  ├─ 前置: 用户故事 ✅ + BDD 场景 (可选)                       │
│  └─ 产出: src/modules/{module}/*.spec.ts + *.ts             │
│                                                             │
│  阶段四: implementation                                      │
│  ├─ 前置: 用户故事 ✅ + TDD 模块 ✅                           │
│  └─ 产出: services/, repositories/, controllers/            │
│                                                             │
│  阶段五: optimization                                        │
│  ├─ 前置: 实现代码 ✅                                        │
│  └─ 产出: 优化后的代码                                       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 📚 相关文档

- [功能模板使用指南](oks-coding-system/prompts/README.md)
- [工作区状态说明](.workflow/README.md)
- [前置检查优化说明](oks-coding-system/PREREQUISITES_OPTIMIZATION.md)

---

## 📝 版本信息

- **版本**: 2.1
- **前缀**: oks (OpenCode Knowledge System)
- **更新日期**: 2026-03-11

---

**OKS** = **O**penCode **K**nowledge **S**ystem
