# Templates 目录

本目录包含 AI Agent 开发的功能模板和示例。

> **注意**: 实际命令位于 `.opencode/commands/oks-*.md`，使用 `/oks-*` 前缀调用。

---

## 📁 目录结构

```
templates/
├── tp_nestjs_mvc/           # NestJS MVC 功能模板
│   ├── AGENTS.md           # AI 助手指南
│   ├── design.md           # 设计文档
│   ├── implementation.md   # 实现进度
│   ├── decisions.md        # 决策记录（ADR）
│   ├── bdd-scenarios.md    # BDD 场景
│   └── prompts.md          # 可复用提示词
├── user-login/             # 实际功能示例
└── README.md
```

---

## 🆕 功能目录模式

> **推荐使用功能目录模式**，提供更好的上下文管理和进度跟踪

### 什么是功能目录模式？

功能目录模式将每个功能的所有文档集中在一个目录中，提供：

- ✅ **单一事实来源**: 所有文档集中管理
- ✅ **详细进度跟踪**: 实现日志和中断恢复
- ✅ **架构决策记录**: ADR 格式的决策文档
- ✅ **可复用提示词**: 常见任务的提示词库

---

## 🚀 快速开始

### 1. 创建新功能

```bash
# 使用脚本创建
bash oks-coding-system/scripts/create-feature.sh 用户登录

# 或手动复制模板
cp -r oks-coding-system/templates/tp_nestjs_mvc oks-coding-system/templates/user-login
```

### 2. 填写设计文档

在对话中告诉 AI 助手：

```
我要开发用户登录功能。这是我的想法：[描述]。
请审查代码库并填写 features/user-login/design.md
```

### 3. 开始开发

```bash
# 完整工作流
/oks-workflow 用户登录

# 或分阶段执行
/oks-stage-1-user-story 用户登录
/oks-stage-2-bdd 用户登录
/oks-stage-3-tdd 用户登录
/oks-stage-4-implementation 用户登录
/oks-stage-5-optimization 用户登录
```

### 4. 中断后恢复

```bash
/oks-workflow --resume 用户登录
```

---

## 📋 可用命令

> 所有命令使用 `oks-` 前缀，位于 `.opencode/commands/`

| 命令                          | 说明                        |
| ----------------------------- | --------------------------- |
| `/oks-workflow`               | 完整工作流（阶段 1-5）      |
| `/oks-tdd-quick`              | 快速 TDD（跳过 BDD 和优化） |
| `/oks-stage-1-user-story`     | 阶段一：用户故事            |
| `/oks-stage-2-bdd`            | 阶段二：BDD 场景            |
| `/oks-stage-3-tdd`            | 阶段三：TDD 循环            |
| `/oks-stage-4-implementation` | 阶段四：代码实现            |
| `/oks-stage-5-optimization`   | 阶段五：代码优化            |
| `/oks-help`                   | 查看帮助                    |

---

## 🔒 阶段防护

每个阶段命令会自动验证前置条件：

```
阶段一 → 无前置条件
    ↓
阶段二 → 需要用户故事文档
    ↓
阶段三 → 需要用户故事 + BDD 场景(可选)
    ↓
阶段四 → 需要 TDD 模块
    ↓
阶段五 → 需要实现代码
```

手动验证：

```bash
bash oks-coding-system/scripts/check-prerequisites.sh --json --stage=bdd --feature="用户登录"
```

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

**命令**: `/oks-stage-1-user-story <功能名称>`

**输入**: 功能名称
**输出**: `docs/user-stories/{feature}.md`
**耗时**: 10-15 分钟

**核心任务**:

- 分析需求
- 识别角色
- 定义价值
- INVEST 验证

---

### 阶段二：BDD 场景设计

**命令**: `/oks-stage-2-bdd <功能名称>`

**前置**: 用户故事文档
**输出**: `features/{feature}.feature`
**耗时**: 15-20 分钟

**核心任务**:

- 识别场景（Happy/Error/Edge）
- 编写 Gherkin
- 定义步骤

---

### 阶段三：TDD 循环

**命令**: `/oks-stage-3-tdd <功能名称>`

**前置**: 用户故事 + BDD 场景（可选）
**输出**: `src/modules/{module}/*.spec.ts` + `*.ts`
**耗时**: 30-40 分钟

**TDD 循环**:

- 🔴 Red: 编写失败的测试
- 🟢 Green: 最简实现
- 🔵 Refactor: 优化代码

---

### 阶段四：代码实现

**命令**: `/oks-stage-4-implementation <功能名称>`

**前置**: TDD 模块
**输出**: services/, repositories/, controllers/
**耗时**: 30-40 分钟

**核心任务**:

- 实现服务层
- 实现数据访问层
- 实现控制器

---

### 阶段五：代码优化

**命令**: `/oks-stage-5-optimization <功能名称>`

**前置**: 实现代码
**输出**: 优化后的代码 + 性能报告
**耗时**: 15-30 分钟

**优化维度**:

- 性能优化
- 代码质量
- 架构优化
- 安全加固

---

## 📚 相关文档

- [命令参考](.workflow/COMMANDS.md)
- [前置检查说明](../oks-coding-system/PREREQUISITES_OPTIMIZATION.md)
- [工作流 README](.workflow/README.md)
- [快速开始脚本](.workflow/quick-start.sh)

---

## 💡 使用建议

### 选择合适的工作流

```
需求明确 + 质量要求高
    → 完整工作流（/oks-workflow）

快速原型 + 时间紧张
    → 快速工作流（/oks-tdd-quick）

补充特定阶段
    → 单阶段（/oks-stage-N-*）

修复问题
    → 单阶段（/oks-stage-N-*）
```

### 参数说明

```bash
# 完整流程
/oks-workflow 用户登录

# 跳过 BDD
/oks-workflow 用户登录 --skip-bdd

# 单阶段模式
/oks-workflow 用户登录 --stage=tdd

# 恢复模式
/oks-workflow 用户登录 --resume
```

---

## 🔄 工作流组合

### 组合 1: 用户故事 + BDD

```bash
/oks-stage-1-user-story 用户登录
/oks-stage-2-bdd 用户登录
```

**适用**: 需求分析和验收标准定义

### 组合 2: TDD + 实现

```bash
/oks-stage-3-tdd 用户登录
/oks-stage-4-implementation 用户登录
```

**适用**: 已有用户故事，直接开发

### 组合 3: 实现 + 优化

```bash
/oks-stage-4-implementation 用户登录
/oks-stage-5-optimization 用户登录
```

**适用**: 已有测试，补充实现和优化

---

**文档版本**: v3.0
**最后更新**: 2026-03-11

**v3.0 更新内容**:

- 🔧 删除对已删除的 `workflows/` 目录的引用
- 🔧 更新命令为 `oks-*` 前缀
- 🔧 添加阶段防护说明
- 🔧 简化文档结构
