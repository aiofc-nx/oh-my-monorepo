# AGENTS.md — 用户登录

> AI 助手专用指南：处理用户登录功能时的行为约束和参考

---

## 项目背景

实现用户登录功能，允许注册用户使用邮箱和密码登录系统，访问个人数据和功能。支持"记住我"功能和账户安全保护机制。

---

## 开始前必读

1. **阅读设计文档**: `features/user-login/design.md`
2. **查看当前进度**: `features/user-login/implementation.md`
3. **参考现有实现**:
   - `apps/tdd-test-app/src/app/` - 现有应用结构
   - `libs/` - 共享库模式
4. **检查决策记录**: `features/user-login/decisions.md`

---

## 代码模式

### 必须遵循的模式

- **实体设计**: 使用 DDD 实体模式，包含静态工厂方法和业务逻辑
- **服务层**: 遵循单一职责原则，服务层只协调业务逻辑
- **测试**: 使用 AAA 模式 (Arrange-Act-Assert)，所有公共方法必须有测试
- **错误处理**: 使用领域异常，提供明确的错误消息

### 参考实现

- `apps/tdd-test-app/src/app/app.service.ts`: 服务层模式
- `apps/tdd-test-app/src/app/app.controller.ts`: 控制器模式
- `apps/tdd-test-app/src/app/app.service.spec.ts`: 测试模式

---

## 技术栈

- **框架**: NestJS
- **测试框架**: Jest
- **ORM**: Prisma / TypeORM (待定)
- **UI 库**: React (如果需要前端)
- **认证**: JWT Token

---

## 测试要求

### 单元测试

- 每个公共方法必须有测试
- 覆盖率目标: > 80%
- 使用 AAA 模式 (Arrange-Act-Assert)
- 测试命名: `should {behavior} when {condition}`

### BDD 测试

- 参考 `features/user-login/bdd-scenarios.md`
- 所有场景必须通过
- 使用 Gherkin 语法
- 至少 5 个场景（Happy + Error + Edge）

### 测试命令

```bash
# 运行单元测试
pnpm test

# 运行 BDD 测试
pnpm test:e2e

# 检查覆盖率
pnpm test:coverage

# 特定模块测试
pnpm test user
```

---

## 约束和禁止项

### 必须做

- ✅ 遵循 `design.md` 中的设计
- ✅ 编写测试（TDD 方式）
- ✅ 更新 `implementation.md` 进度
- ✅ 记录重要决策到 `decisions.md`
- ✅ 保持代码覆盖率 > 80%
- ✅ 使用强密码加密（bcrypt）
- ✅ 实现登录失败计数和账户锁定
- ✅ 提供"记住我"功能（7 天免登录）

### 禁止做

- ❌ 添加 `design.md` 之外的功能（如第三方登录、多因素认证）
- ❌ 跳过测试
- ❌ 明文存储密码
- ❌ 忽略边界情况（空值、超长输入等）
- ❌ 提交未通过的测试
- ❌ 修改改期、注册等其他功能（超出范围）

---

## 常见任务提示词

参考 `features/user-login/prompts.md` 中的可复用提示词：

### 开始开发

```markdown
开始实现用户登录功能。

请先阅读：

1. features/user-login/design.md - 了解设计
2. features/user-login/implementation.md - 了解当前进度

然后从阶段三（TDD 循环）开始。
```

### 同步进度

```markdown
审查用户登录功能的已实现内容，更新 features/user-login/implementation.md。

检查：

1. User 实体是否已实现
2. 测试覆盖率是否达标
3. 服务层和控制器是否完成
```

### 运行测试

```markdown
运行用户登录的所有测试：

1. 单元测试: pnpm test user
2. BDD 测试: pnpm test:e2e features/user-login.feature
3. 覆盖率: pnpm test:coverage

修复所有失败的测试。
```

---

## 边界情况

参考 `design.md` 中的边界情况章节，确保以下场景已处理：

### 输入边界

- 邮箱为空/null
- 密码为空/null
- 邮箱格式不正确
- 密码超长

### 状态边界

- 用户不存在
- 密码错误
- 账户被锁定
- 登录失败 5 次

### 权限边界

- 账户未激活（如果需要激活）
- 账户被禁用

### 系统边界

- 数据库连接失败
- JWT 密钥缺失
- Token 生成失败

---

## 质量检查清单

在提交代码前，确保：

- [ ] 所有单元测试通过
- [ ] 所有 BDD 场景通过（至少 5 个）
- [ ] 代码覆盖率 > 80%
- [ ] 代码复杂度 < 10
- [ ] 无 TypeScript 错误
- [ ] 无 ESLint 错误
- [ ] `implementation.md` 已更新
- [ ] 重要决策已记录到 `decisions.md`
- [ ] 密码使用 bcrypt 加密
- [ ] 登录失败计数已实现
- [ ] "记住我"功能已实现

---

## 实现顺序建议

### 阶段三：TDD 循环

1. **User 实体**
   - 创建 `User` 实体类
   - 实现 `login()` 方法
   - 实现登录失败计数
   - 实现账户锁定逻辑
   - 覆盖率 > 80%

### 阶段四：代码实现

2. **服务层**
   - 实现 `UserService.login()`
   - 密码验证（bcrypt）
   - JWT Token 生成
   - "记住我"功能
   - 服务层测试

3. **数据访问层**
   - 定义 `UserRepository` 接口
   - 实现 `UserRepository`
   - Repository 测试

4. **控制器**
   - 实现 `POST /auth/login` 接口
   - 请求验证
   - 错误处理
   - 控制器测试

### 阶段五：代码优化

5. **优化**
   - 性能分析
   - 代码复杂度检查
   - 安全审查
   - 优化报告

---

## 相关资源

- [设计文档](./design.md)
- [实现进度](./implementation.md)
- [决策记录](./decisions.md)
- [BDD 场景](./bdd-scenarios.md)
- [提示词库](./prompts.md)

---

**最后更新**: 2026-03-11
