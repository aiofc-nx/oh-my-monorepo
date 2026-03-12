# AGENTS.md — {功能名称}

> AI 助手专用指南：处理该功能时的行为约束和参考

---

## 项目背景

{简要说明该功能做什么，解决什么问题}

---

## 开始前必读

1. **阅读愿景文档**: `docs/visions/{project}-vision.md`
2. **阅读用户故事**: `docs/user-stories/{project}/{feature}.md`
3. **阅读技术设计**: `docs/designs/{project}/{feature}.md`
4. **查看当前进度**: `features/{feature}/implementation.md`（如存在）
5. **检查决策记录**: `features/{feature}/decisions.md`（如存在）

---

## 文档结构

```
docs/
├── visions/
│   └── {project}-vision.md          # 项目愿景
├── user-stories/
│   └── {project}/
│       └── {feature}.md             # 用户故事
└── designs/
    └── {project}/
        └── {feature}.md             # 技术设计

features/
└── {feature}/
    ├── implementation.md            # 实现进度
    ├── decisions.md                 # 决策记录
    ├── bdd-scenarios.md             # BDD 场景
    └── AGENTS.md                    # 本文件
```

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

- 参考 `features/{feature}/bdd-scenarios.md`
- 所有场景必须通过
- 使用 Gherkin 语法

### 测试命令

```bash
# 运行所有单元测试
pnpm vitest run

# 运行特定模块测试
pnpm vitest run src/modules/{module}/

# 运行 BDD 测试
pnpm vitest run features/{feature}.feature

# 检查覆盖率
pnpm vitest run --coverage
```

---

## 约束和禁止项

### 必须做

- ✅ 遵循 `docs/designs/{project}/{feature}.md` 中的设计
- ✅ 编写测试（TDD 方式）
- ✅ 更新实现进度
- ✅ 记录重要决策到 `decisions.md`
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

| 阶段     | 命令                | 必需前置               |
| -------- | ------------------- | ---------------------- |
| 愿景     | /oks-vision         | 无                     |
| 用户故事 | /oks-user-story     | 愿景（推荐）           |
| 技术设计 | /oks-design         | 用户故事               |
| BDD 场景 | /oks-bdd            | 用户故事、设计（推荐） |
| TDD 开发 | /oks-tdd            | 用户故事、设计（推荐） |
| 服务实现 | /oks-implementation | TDD 阶段               |
| 代码优化 | /oks-optimization   | 服务实现               |

---

## 边界情况

参考 `docs/designs/{project}/{feature}.md` 中的边界情况章节，确保以下场景已处理：

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
- [ ] 代码复杂度 < 10
- [ ] 无 TypeScript 错误
- [ ] 无 ESLint 错误
- [ ] 实现进度已更新
- [ ] 重要决策已记录

---

## 相关资源

| 文档     | 路径                                       |
| -------- | ------------------------------------------ |
| 项目愿景 | `docs/visions/{project}-vision.md`         |
| 用户故事 | `docs/user-stories/{project}/{feature}.md` |
| 技术设计 | `docs/designs/{project}/{feature}.md`      |
| 实现进度 | `features/{feature}/implementation.md`     |
| 决策记录 | `features/{feature}/decisions.md`          |
| BDD 场景 | `features/{feature}/bdd-scenarios.md`      |

---

**最后更新**: {日期}
