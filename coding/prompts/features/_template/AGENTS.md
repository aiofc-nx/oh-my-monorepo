# AGENTS.md — {功能名称}

> AI 助手专用指南：处理该功能时的行为约束和参考

---

## 项目背景

{简要说明该功能做什么，解决什么问题}

---

## 开始前必读

1. **阅读设计文档**: `features/{feature}/design.md`
2. **查看当前进度**: `features/{feature}/implementation.md`
3. **参考现有实现**: `{relevant directories}` 中的现有模式
4. **检查决策记录**: `features/{feature}/decisions.md`

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

- **框架**: {使用的框架}
- **测试框架**: {测试框架}
- **ORM**: {ORM}
- **UI 库**: {UI 库}

---

## 测试要求

### 单元测试

- 每个公共方法必须有测试
- 覆盖率目标: > 80%
- 使用 AAA 模式 (Arrange-Act-Assert)

### BDD 测试

- 参考 `features/{feature}/bdd-scenarios.md`
- 所有场景必须通过
- 使用 Gherkin 语法

### 测试命令

```bash
# 运行单元测试
pnpm test

# 运行 BDD 测试
pnpm test:e2e

# 检查覆盖率
pnpm test:coverage
```

---

## 约束和禁止项

### 必须做

- ✅ 遵循 `design.md` 中的设计
- ✅ 编写测试（TDD 方式）
- ✅ 更新 `implementation.md` 进度
- ✅ 记录重要决策到 `decisions.md`
- ✅ 保持代码覆盖率 > 80%

### 禁止做

- ❌ 添加 `design.md` 之外的功能
- ❌ 跳过测试
- ❌ 修改范围外的代码
- ❌ 忽略边界情况
- ❌ 提交未通过的测试

---

## 常见任务提示词

参考 `features/{feature}/prompts.md` 中的可复用提示词：

- 同步实现状态
- 生成测试
- 代码审查
- 继续开发功能

---

## 边界情况

参考 `design.md` 中的边界情况章节，确保以下场景已处理：

- {边界情况 1}
- {边界情况 2}
- {边界情况 3}

---

## 质量检查清单

在提交代码前，确保：

- [ ] 所有单元测试通过
- [ ] 所有 BDD 场景通过
- [ ] 代码覆盖率 > 80%
- [ ] 代码复杂度 < 10
- [ ] 无 TypeScript 错误
- [ ] 无 ESLint 错误
- [ ] `implementation.md` 已更新
- [ ] 重要决策已记录到 `decisions.md`

---

## 相关资源

- [设计文档](./design.md)
- [实现进度](./implementation.md)
- [决策记录](./decisions.md)
- [BDD 场景](./bdd-scenarios.md)
- [提示词库](./prompts.md)

---

**最后更新**: {日期}
