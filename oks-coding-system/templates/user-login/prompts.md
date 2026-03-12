# 用户登录提示词库

> 可复用的提示词集合，用于用户登录功能的常见任务

---

## 📋 目录

- [开发流程](#开发流程)
- [测试相关](#测试相关)
- [代码审查](#代码审查)
- [文档生成](#文档生成)
- [问题解决](#问题解决)

---

## 开发流程

### 开始用户登录功能

```markdown
我要开发用户登录功能。这是我的想法：

1. 允许用户使用邮箱和密码登录
2. 支持"记住我"功能（7 天免登录）
3. 连续失败 5 次后锁定账户 15 分钟

请审查代码库并填写 features/user-login/design.md，包括：

1. 技术设计（数据库、API、UI）
2. 用户故事（INVEST 原则）
3. 边界情况
4. 成功标准
```

---

### 继续开发用户登录

```markdown
继续开发用户登录功能。

请先阅读：

1. features/user-login/design.md - 了解设计
2. features/user-login/implementation.md - 了解当前进度

然后从上次中断的地方继续。
```

---

### 同步实现状态

```markdown
审查用户登录的已实现内容，并更新 features/user-login/implementation.md：

1. 检查哪些代码已经实现
2. 更新"已完成"部分
3. 更新"进行中"和"下一步"
4. 更新测试状态和覆盖率
```

---

### 完成用户登录开发

```markdown
用户登录功能开发完成。请：

1. 运行所有测试，确保通过
2. 更新 features/user-login/implementation.md 状态为"已完成"
3. 检查是否需要更新 design.md
4. 生成功能文档
```

---

## 测试相关

### 生成 User 实体测试

```markdown
为 User 实体编写单元测试，遵循：

1. 使用 AAA 模式 (Arrange-Act-Assert)
2. 覆盖所有公共方法：
   - User.create()
   - user.login()
   - user.incrementLoginAttempts()
   - user.resetLoginAttempts()
3. 包含正常、异常、边界情况
4. 测试命名: should {behavior} when {condition}

参考 features/user-login/bdd-scenarios.md 中的场景。
```

---

### 运行测试并修复

```markdown
运行用户登录的测试并修复所有失败的测试：

1. 运行 pnpm test user 查看失败测试
2. 分析失败原因（测试错误 or 实现错误）
3. 修复问题
4. 确保所有测试通过
```

---

### 检查测试覆盖率

```markdown
检查用户登录的测试覆盖率：

1. 运行 pnpm test:coverage
2. 识别未覆盖的代码
3. 补充测试以提高覆盖率到 80% 以上
4. 更新 features/user-login/implementation.md 中的覆盖率数据
```

---

### 运行 BDD 测试

```markdown
运行用户登录的 BDD 测试：

1. 运行 pnpm test:e2e features/user-login.feature
2. 检查所有场景是否通过（至少 7 个）
3. 修复失败的场景
4. 更新 implementation.md 中的 BDD 测试状态
```

---

## 代码审查

### 代码质量审查

```markdown
从以下角度审查用户登录的改动：

1. **类型安全**: 是否有 any 类型？类型定义是否完整？
2. **错误处理**: 是否处理了所有可能的错误？
   - 用户不存在
   - 密码错误
   - 账户锁定
3. **安全性**:
   - 密码是否使用 bcrypt 加密？
   - 是否防止暴力破解（登录失败计数）？
   - JWT Token 是否安全？
4. **边界情况**: 是否处理了边界情况？
   - 空值/null
   - 邮箱格式不正确
   - 超长输入
5. **代码复杂度**: 复杂度是否 < 10？
6. **代码重复**: 是否有重复代码？
```

---

### 性能审查

```markdown
审查用户登录的性能：

1. 是否有 N+1 查询问题？
2. 是否有不必要的重复计算？
3. bcrypt.compare() 性能是否可接受？
4. 响应时间是否满足要求（< 200ms）？
5. 是否有内存泄漏风险？
```

---

### 安全审查

```markdown
审查用户登录的安全性：

1. **输入验证**: 所有用户输入是否验证？
   - 邮箱格式
   - 密码长度
2. **权限检查**: 是否有权限控制？
3. **敏感数据**:
   - 密码是否加密存储？
   - JWT Token 是否安全传输？
4. **SQL 注入**: 是否使用参数化查询？
5. **暴力破解防护**:
   - 是否有登录失败计数？
   - 是否有账户锁定机制？
6. **会话管理**:
   - Token 有效期是否合理？
   - "记住我"功能是否安全？
```

---

## 文档生成

### 生成内部文档

```markdown
为用户登录生成带截图的文档：

1. 在浏览器中打开登录页面
2. 对关键 UI 状态截图：
   - 登录页面
   - 登录成功
   - 登录失败（密码错误）
   - 账户锁定
3. 将截图保存到 features/user-login/docs/screenshots/
4. 创建/更新 features/user-login/docs/README.md，包括：
   - 功能概览
   - 使用方式（带截图的分步说明）
   - 配置选项
   - 常见用例
   - 常见问题
```

---

### 更新 API 文档

```markdown
更新用户登录的 API 文档：

1. 列出所有 API：
   - POST /api/auth/login
2. 为每个 API 编写文档：
   - 请求方法和路径
   - 请求参数（email, password, rememberMe）
   - 响应格式（token, expiresIn, user）
   - 错误码（401, 400）
   - 示例
3. 更新 API 文档文件
```

---

## 问题解决

### 调试失败测试

```markdown
用户登录的测试失败了。请：

1. 运行 pnpm test user --reporter=verbose 查看详细错误
2. 分析失败原因：
   - 测试错误？（期望值不正确）
   - 实现错误？（代码逻辑不正确）
3. 修复问题
4. 确保所有测试通过
5. 更新 implementation.md
```

---

### 解决技术难题

```markdown
在实现用户登录时遇到问题：密码验证逻辑应该放在哪里？

请：

1. 分析问题原因（职责边界不清晰）
2. 提出多个解决方案：
   - 方案 A: 放在 User 实体
   - 方案 B: 放在 UserService 服务层
3. 评估各方案的优缺点
4. 推荐最佳方案（方案 B）
5. 记录决策到 features/user-login/decisions.md（ADR-001）
```

---

### 处理边界情况

```markdown
用户登录需要处理以下边界情况：

1. **输入为空**: 邮箱或密码为空
2. **邮箱格式不正确**: 不是有效的邮箱格式
3. **用户不存在**: 邮箱未注册
4. **密码错误**: 密码不正确
5. **账户锁定**: 连续失败 5 次

请：

1. 为每个边界情况编写测试
2. 实现相应的处理逻辑
3. 确保错误消息明确且安全（不暴露敏感信息）
4. 更新 bdd-scenarios.md
```

---

## 代码重构

### 重构 User 实体

```markdown
重构 User 实体以提高代码质量：

1. 检查代码复杂度（目标 < 10）
2. 检查代码重复（目标 < 5%）
3. 提取验证逻辑到独立方法：
   - validateEmail()
   - validatePassword()
4. 改善命名
5. 确保所有测试仍然通过
```

---

### 优化性能

```markdown
优化用户登录的性能：

1. 运行性能分析，识别瓶颈
2. 检查 bcrypt.compare() 性能
3. 检查数据库查询效率
4. 添加必要的索引（email 字段）
5. 验证性能提升（目标 < 200ms）
```

---

## 快捷提示词

| 任务     | 提示词                          |
| -------- | ------------------------------- |
| 开始功能 | `/workflow --init user-login`   |
| 继续功能 | `/workflow --resume user-login` |
| 同步进度 | `/workflow --sync user-login`   |
| 生成测试 | `/test user.entity`             |
| 代码审查 | `/review user-login`            |
| 生成文档 | `/docs user-login`              |
| 调试测试 | `/debug user-login-test`        |
| 重构代码 | `/refactor user.entity`         |

---

## 相关资源

- [设计文档](./design.md)
- [实现进度](./implementation.md)
- [决策记录](./decisions.md)
- [AI 助手指南](./AGENTS.md)
- [BDD 场景](./bdd-scenarios.md)

---

**创建日期**: 2026-03-11
**最后更新**: 2026-03-11
