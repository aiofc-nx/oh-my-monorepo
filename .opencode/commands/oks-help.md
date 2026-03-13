---
description: OKS 命令索引 - 查看所有可用命令
agent: build
argument-hint: ''
---

# OKS Coding Agent 命令索引

> **OKS** = **O**penCode **K**nowledge **S**ystem

所有命令都以 `oks-` 为前缀，以区别于其他命令。

---

## 📋 命令总览

| 命令                  | 功能                            | 阶段   |
| --------------------- | ------------------------------- | ------ |
| `/oks-workflow`       | 完整工作流（自动执行 1-7 阶段） | 全局   |
| `/oks-vision`         | 项目愿景文档                    | 阶段 1 |
| `/oks-user-story`     | 用户故事设计                    | 阶段 2 |
| `/oks-design`         | 技术设计                        | 阶段 3 |
| `/oks-bdd`            | BDD 场景设计                    | 阶段 4 |
| `/oks-tdd`            | TDD 开发循环                    | 阶段 5 |
| `/oks-implementation` | 实现服务层                      | 阶段 6 |
| `/oks-optimization`   | 代码优化                        | 阶段 7 |
| `/oks-generator`      | 创建新项目（NestJS/React）      | 辅助   |
| `/oks-list`           | 查看项目列表                    | 辅助   |
| `/oks-status`         | 查看项目状态                    | 辅助   |

---

## 🚀 快速开始

### 方式 1: 完整工作流（推荐）

```bash
/oks-workflow <功能名称>
```

**示例**:

```bash
/oks-workflow 用户登录
/oks-workflow 购物车功能
```

### 方式 2: 分阶段执行

```bash
# 阶段 1: 愿景文档
/oks-vision 新建 <项目名>
/oks-vision <项目名>

# 阶段 2: 用户故事
/oks-user-story <功能名>

# 阶段 3: 技术设计
/oks-design <功能名>

# 阶段 4: BDD 场景
/oks-bdd <功能名>

# 阶段 5: TDD 开发
/oks-tdd <功能名>

# 阶段 6: 服务实现
/oks-implementation <功能名>

# 阶段 7: 代码优化
/oks-optimization <功能名>
```

---

## 📊 工作流概览

```
阶段一: 愿景文档     /oks-vision
    ↓
阶段二: 用户故事     /oks-user-story
    ↓
阶段三: 技术设计     /oks-design
    ↓
阶段四: BDD 场景     /oks-bdd (可跳过)
    ↓
阶段五: TDD 开发     /oks-tdd
    ↓
阶段六: 服务实现     /oks-implementation
    ↓
阶段七: 代码优化     /oks-optimization (可跳过)
```

---

## 📝 命令详解

### `/oks-workflow`

完整的开发工作流，自动执行阶段 1-7。

**语法**:

```bash
/oks-workflow <功能名称> [选项]
```

**选项**:

| 选项              | 说明                   |
| ----------------- | ---------------------- |
| `--skip-bdd`      | 跳过阶段 4（BDD 场景） |
| `--skip-optimize` | 跳过阶段 7（代码优化） |
| `--from=<阶段>`   | 从指定阶段开始         |
| `--status`        | 查看当前进度           |

**示例**:

```bash
# 完整工作流
/oks-workflow 用户登录

# 快速模式（跳过 BDD 和优化）
/oks-workflow 用户登录 --skip-bdd --skip-optimize

# 从设计阶段开始
/oks-workflow 用户登录 --from=design

# 查看进度
/oks-workflow 用户登录 --status
```

---

### `/oks-vision`

创建和管理项目愿景文档。

**语法**:

```bash
/oks-vision                    # 查看愿景列表
/oks-vision <项目名>           # 查看/修改愿景
/oks-vision 新建 <项目名>      # 创建新愿景
```

**产出**: `<project>/docs/specify/vision.md`

**示例**:

```bash
/oks-vision 新建 user-center
/oks-vision user-center
```

---

### `/oks-user-story`

创建符合 INVEST 原则的用户故事。

**语法**:

```bash
/oks-user-story <功能名称>
```

**产出**: `<project>/docs/specify/user-story.md`

**示例**:

```bash
/oks-user-story 用户登录
/oks-user-story 配置项管理
```

---

### `/oks-design`

创建技术设计文档。

**语法**:

```bash
/oks-design <功能名称>
```

**产出**: `<project>/docs/specify/design.md`

**内容**: 数据库设计、API 设计、组件设计、数据流设计

**示例**:

```bash
/oks-design 用户登录
/oks-design 购物车功能
```

---

### `/oks-bdd`

从用户故事创建可执行的 BDD 场景。

**语法**:

```bash
/oks-bdd <功能名称>
```

**前置条件**:

- ✅ 用户故事已完成
- ⚠️ 技术设计（推荐）

**产出**:

- `features/{feature}.feature`
- `features/step-definitions/{feature}.steps.ts`

**示例**:

```bash
/oks-bdd 用户登录
```

---

### `/oks-tdd`

使用 Red-Green-Refactor 循环开发领域模型。

**语法**:

```bash
/oks-tdd <功能名称>
```

**前置条件**:

- ✅ 用户故事已完成
- ⚠️ 技术设计（推荐）
- ⚠️ BDD 场景（推荐）

**产出**:

- `src/modules/{module}/entities/` - 领域实体
- 单元测试（覆盖率 > 80%）

**示例**:

```bash
/oks-tdd 用户登录
```

---

### `/oks-implementation`

实现服务层、控制器和数据访问层。

**语法**:

```bash
/oks-implementation <功能名称>
```

**前置条件**:

- ✅ TDD 阶段已完成（领域实体）
- ✅ 测试覆盖率 > 80%

**产出**:

- `src/modules/{module}/services/` - 服务层
- `src/modules/{module}/controllers/` - 控制器
- `src/modules/{module}/repositories/` - 数据访问层

**示例**:

```bash
/oks-implementation 用户登录
```

---

### `/oks-optimization`

代码质量与性能优化。

**语法**:

```bash
/oks-optimization <功能名称>
```

**前置条件**:

- ✅ 实现阶段已完成
- ✅ 所有测试通过

**优化维度**:

- 性能优化（响应时间 < 200ms）
- 代码质量（重复率 < 5%）
- 架构优化（耦合度 < 0.3）
- 安全加固（0 漏洞）

**示例**:

```bash
/oks-optimization 用户登录
```

---

## 📁 文档结构

```
docs/
├── visions/                      # 阶段一：愿景文档
│   └── {project}-vision.md
├── user-stories/                 # 阶段二：用户故事
│   └── {project}/
│       └── {feature}.md
├── designs/                      # 阶段三：技术设计
│   ├── tech-stack.md            # 技术栈定义
│   └── {project}/
│       └── {feature}.md
└── features/                     # 阶段四：BDD 场景
    └── {feature}.feature
```

---

## 🎯 使用场景

### 场景 1: 新功能开发

```bash
# 完整流程
/oks-workflow 用户登录
```

### 场景 2: 快速原型

```bash
# 跳过 BDD 和优化
/oks-workflow 原型功能 --skip-bdd --skip-optimize
```

### 场景 3: 只补充设计

```bash
# 从设计阶段开始
/oks-workflow 某功能 --from=design
```

### 场景 4: 补写测试

```bash
# 从 TDD 阶段开始
/oks-workflow 某功能 --from=tdd
```

### 场景 5: 查看进度

```bash
/oks-workflow 某功能 --status
```

---

## 💡 最佳实践

| 实践           | 说明                     |
| -------------- | ------------------------ |
| **先写愿景**   | 每个项目先创建愿景文档   |
| **设计先行**   | 技术设计完成后再编码     |
| **测试驱动**   | TDD 确保代码质量         |
| **分阶段验证** | 每个阶段完成后运行测试   |
| **记录进度**   | 使用 `--status` 查看状态 |

---

## 🔗 相关命令

| 命令             | 说明                       |
| ---------------- | -------------------------- |
| `/oks-list`      | 查看所有项目               |
| `/oks-status`    | 查看项目状态               |
| `/oks-generator` | 创建新项目（NestJS/React） |

---

**OKS** = **O**penCode **K**nowledge **S**ystem

**版本**: 2.0.0  
**更新日期**: 2026-03-12
