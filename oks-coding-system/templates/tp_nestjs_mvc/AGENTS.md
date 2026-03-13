# AGENTS.md — {功能名称}

> AI 助手专用指南：处理该功能时的行为约束和参考

---

## 项目背景

{简要说明该功能做什么，解决什么问题}

---

## 📂 文档管理约定

> **重要约定**：开发过程中创建的所有文档统一放入**各项目的 `/docs/` 目录下**，并根据功能分目录管理。

### 文档目录结构

```
<project>/
└── docs/
    ├── specfiy/                    # 规格文档（开发过程文档）
    │   ├── AGENTS.md              # AI 助手指南（本文件）
    │   ├── vision.md              # 项目愿景
    │   ├── user-story.md          # 用户故事
    │   ├── design.md              # 技术设计
    │   ├── implementation.md      # 实现进度
    │   ├── decisions.md           # 决策记录（ADR）
    │   └── bdd-scenarios.md       # BDD 场景
    │
    ├── api/                        # API 文档（自动生成）
    │   ├── openapi.yaml           # OpenAPI 规范
    │   └── swagger/               # Swagger UI
    │
    ├── guides/                     # 开发指南
    │   ├── setup.md               # 环境搭建
    │   ├── development.md         # 开发规范
    │   └── deployment.md          # 部署指南
    │
    ├── architecture/               # 架构文档
    │   ├── overview.md            # 架构概览
    │   └── diagrams/              # 架构图
    │
    └── README.md                   # 项目文档索引
```

### 目录用途说明

| 目录            | 用途     | 内容说明                           |
| --------------- | -------- | ---------------------------------- |
| `specfiy/`      | 规格文档 | 愿景、设计、实现等开发过程文档     |
| `api/`          | API 文档 | 接口文档、Swagger UI、OpenAPI 规范 |
| `guides/`       | 开发指南 | 环境搭建、开发规范、部署指南       |
| `architecture/` | 架构文档 | 系统架构、模块设计、技术选型       |

### 文档命名规范

- **文件名**: 使用 kebab-case（如 `user-story.md`）
- **中英文**: 优先使用英文，便于国际化
- **版本化**: 使用 Git 管理版本，不手动创建 `v1.md`、`v2.md`

### 文档更新规则

1. **每次修改代码时**，同步更新相关文档
2. **添加新功能时**，更新 `specfiy/implementation.md`
3. **做出技术决策时**，记录到 `specfiy/decisions.md`
4. **修改 API 时**，更新 `api/openapi.yaml`

---

## 开始前必读

1. **阅读愿景文档**: `docs/specfiy/vision.md`
2. **阅读用户故事**: `docs/specfiy/user-story.md`
3. **阅读技术设计**: `docs/specfiy/design.md`
4. **查看当前进度**: `docs/specfiy/implementation.md`（如存在）
5. **检查决策记录**: `docs/specfiy/decisions.md`（如存在）

---

## 代码模式

### 必须遵循的模式

- {模式 1}: {说明和参考位置}
- {模式 2}: {说明和参考位置}
- {模式 3}: {说明和参考位置}

### 参考实现

- {参考文件 1}: {说明}
- {参考文件 2}: {说明}

---

## 技术栈

- **框架**: NestJS (后端) / React (前端)
- **测试框架**: Vitest
- **ORM**: MikroORM
- **BDD**: Cucumber
- **Linter**: Biome

---

## 测试要求

### 单元测试

- 每个公共方法必须有测试
- 覆盖率目标: > 80%
- 使用 AAA 模式 (Arrange-Act-Assert)

### TDD 阶段（领域层）

- 测试文件: `src/modules/{module}/entities/*.entity.spec.ts`
- 只测试领域逻辑，无外部依赖
- 覆盖率目标: > 80%

### 服务层测试

- 测试文件: `src/modules/{module}/services/*.service.spec.ts`
- Mock 外部依赖（Repository、第三方服务）
- 覆盖率目标: > 80%

### BDD 测试

- 参考 `docs/specfiy/bdd-scenarios.md`
- 所有场景必须通过
- 使用 Gherkin 语法

### 测试命令

```bash
# 运行所有单元测试
pnpm nx test {project-name}

# 运行特定模块测试
pnpm nx test {project-name} --grep "module-name"

# 运行 BDD 测试
pnpm nx test {project-name} --grep "e2e"

# 检查覆盖率
pnpm nx test {project-name} --coverage
```

---

## 约束和禁止项

### 必须做

- ✅ 遵循 `docs/specfiy/design.md` 中的设计
- ✅ 编写测试（TDD 方式）
- ✅ 更新实现进度到 `docs/specfiy/implementation.md`
- ✅ 记录重要决策到 `docs/specfiy/decisions.md`
- ✅ 保持代码覆盖率 > 80%

### 禁止做

- ❌ 添加设计文档之外的功能
- ❌ 跳过测试
- ❌ 修改范围外的代码
- ❌ 忽略边界情况
- ❌ 提交未通过的测试

---

## 阶段依赖

```
/oks-vision → /oks-user-story → /oks-design → /oks-bdd → /oks-tdd → /oks-implementation → /oks-optimization
```

| 阶段     | 命令                | 必需前置               | 产出文档                              |
| -------- | ------------------- | ---------------------- | ------------------------------------- |
| 愿景     | /oks-vision         | 无                     | `docs/specfiy/vision.md`              |
| 用户故事 | /oks-user-story     | 愿景（推荐）           | `docs/specfiy/user-story.md`          |
| 技术设计 | /oks-design         | 用户故事               | `docs/specfiy/design.md`              |
| BDD 场景 | /oks-bdd            | 用户故事、设计（推荐） | `docs/specfiy/bdd-scenarios.md`       |
| TDD 开发 | /oks-tdd            | 用户故事、设计（推荐） | `src/modules/{module}/entities/*.ts`  |
| 服务实现 | /oks-implementation | TDD 阶段               | `src/modules/{module}/services/*.ts`  |
| 代码优化 | /oks-optimization   | 服务实现               | 更新 `docs/specfiy/implementation.md` |

---

## 边界情况

参考 `docs/specfiy/design.md` 中的边界情况章节，确保以下场景已处理：

### 输入边界

- {边界情况 1}
- {边界情况 2}

### 业务边界

- {边界情况 3}
- {边界情况 4}

### 系统边界

- {边界情况 5}
- {边界情况 6}

---

## 质量检查清单

在提交代码前，确保：

- [ ] 所有单元测试通过
- [ ] 所有 BDD 场景通过（如适用）
- [ ] 代码覆盖率 > 80%
- [ ] 无 TypeScript 错误
- [ ] 无 Biome 错误
- [ ] 实现进度已更新（`docs/specfiy/implementation.md`）
- [ ] 重要决策已记录（`docs/specfiy/decisions.md`）

---

## 相关资源

| 文档     | 路径                             |
| -------- | -------------------------------- |
| 项目愿景 | `docs/specfiy/vision.md`         |
| 用户故事 | `docs/specfiy/user-story.md`     |
| 技术设计 | `docs/specfiy/design.md`         |
| 实现进度 | `docs/specfiy/implementation.md` |
| 决策记录 | `docs/specfiy/decisions.md`      |
| BDD 场景 | `docs/specfiy/bdd-scenarios.md`  |
| 文档索引 | `docs/README.md`                 |

---

## 文档维护命令

### 创建文档

```bash
# 查看愿景
/oks-vision {project-name}

# 创建用户故事
/oks-user-story {feature-name}

# 创建技术设计
/oks-design {feature-name}

# 创建 BDD 场景
/oks-bdd {feature-name}
```

### 更新文档

```bash
# 更新实现进度
# 直接编辑 docs/specfiy/implementation.md

# 记录技术决策
# 直接编辑 docs/specfiy/decisions.md
```

---

**最后更新**: {日期}
