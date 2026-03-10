---
description: 阶段三 - TDD 红-绿-重构循环
agent: build
argument-hint: '<功能名称> [--entity=<实体名>]'
---

# 阶段三：TDD 开发循环

使用 Red-Green-Refactor 循环驱动代码设计。

---

## 当前任务

功能名称: **$ARGUMENTS**

## 项目上下文

当前分支: !`git branch --show-current`
测试状态: !`pnpm vitest run 2>&1 | tail -10 || echo "Tests not run yet"`

---

## TDD 循环

```
┌─────────────────────────────────────────┐
│  🔴 Red   → 编写失败的测试              │
│  🟢 Green → 用最简单的方式让测试通过    │
│  🔵 Refactor → 优化代码，保持测试通过   │
└─────────────────────────────────────────┘
```

---

## 🔴 Red: 编写失败的测试

### 目标

根据功能需求编写失败的单元测试。

### 测试文件位置

```
src/domain/[module]/[entity].aggregate.spec.ts
src/domain/[module]/[value-object].vo.spec.ts
src/application/commands/[command].handler.spec.ts
```

### 测试模板

```typescript
import { describe, it, expect, beforeEach } from 'vitest';

describe('[EntityName]', () => {
  describe('[MethodName]', () => {
    it('should [behavior] when [condition]', () => {
      // Arrange - 准备测试数据
      const props = {
        /* 测试数据 */
      };

      // Act - 执行被测试的代码
      const result = Entity.create(props);

      // Assert - 验证结果
      expect(result.isOk()).toBe(true);
      expect(result.value.property).toBe(expected);
    });

    it('should fail when [validation]', () => {
      const result = Entity.create({
        /* 无效数据 */
      });

      expect(result.isFail()).toBe(true);
      expect(result.value.message).toContain('错误信息');
    });
  });
});
```

### 验证

```bash
pnpm vitest run <file-path>
```

**期望**: ❌ 测试失败（实现不存在）

---

## 🟢 Green: 最简实现

### 目标

用最简单的代码让测试通过，不考虑优化。

### 实现原则

1. **最简实现** - 够用就行，不要过度设计
2. **硬编码可以** - 先让测试通过再说
3. **复制粘贴可以** - 后面再重构

### 实现模板

```typescript
export class Entity extends AggregateRoot<EntityProps> {
  static create(props: CreateProps): Result<Entity, ValidationError> {
    // 1. 验证
    if (!props.required) {
      return Result.fail(new ValidationError('必填字段不能为空', 'required'));
    }

    // 2. 创建实体
    const entity = new Entity({
      id: EntityId.generate(),
      ...props,
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    // 3. 触发事件
    entity.addDomainEvent(new EntityCreatedEvent(entity.id));

    return Result.ok(entity);
  }
}
```

### 验证

```bash
pnpm vitest run <file-path>
```

**期望**: ✅ 所有测试通过

---

## 🔵 Refactor: 优化代码

### 目标

在保持测试通过的前提下，优化代码结构。

### 重构原则

1. **测试必须一直通过** - 每次小改动后都运行测试
2. **小步前进** - 一次只改一个地方
3. **保持功能不变** - 只改结构，不改行为

### 重构示例

**重构前**:

```typescript
export class Entity extends AggregateRoot<EntityProps> {
  static create(props: CreateProps): Result<Entity, ValidationError> {
    if (!props.required) {
      return Result.fail(new ValidationError('必填字段不能为空', 'required'));
    }

    if (!props.email?.includes('@')) {
      return Result.fail(new ValidationError('邮箱格式不正确', 'email'));
    }

    const entity = new Entity({
      id: EntityId.generate(),
      ...props,
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    entity.addDomainEvent(new EntityCreatedEvent(entity.id));

    return Result.ok(entity);
  }
}
```

**重构后**:

```typescript
export class Entity extends AggregateRoot<EntityProps> {
  static create(props: CreateProps): Result<Entity, ValidationError> {
    const errors = this.validate(props);
    if (errors.length > 0) {
      return Result.fail(errors[0]);
    }

    const entity = new Entity(this.initializeProps(props));
    entity.emitCreatedEvent();

    return Result.ok(entity);
  }

  private static validate(props: CreateProps): ValidationError[] {
    const errors: ValidationError[] = [];

    if (!props.required?.trim()) {
      errors.push(new ValidationError('必填字段不能为空', 'required'));
    }

    if (!props.email?.includes('@')) {
      errors.push(new ValidationError('邮箱格式不正确', 'email'));
    }

    return errors;
  }

  private static initializeProps(props: CreateProps): EntityProps {
    return {
      id: EntityId.generate(),
      ...props,
      createdAt: new Date(),
      updatedAt: new Date(),
    };
  }

  private emitCreatedEvent(): void {
    this.addDomainEvent(new EntityCreatedEvent(this.id));
  }
}
```

### 验证

```bash
pnpm vitest run <file-path>
```

**期望**: ✅ 所有测试仍然通过

---

## 测试覆盖率目标

| 类型       | 目标  | 优先级 |
| ---------- | ----- | ------ |
| 语句覆盖率 | > 80% | 必需   |
| 分支覆盖率 | > 70% | 推荐   |
| 函数覆盖率 | > 90% | 推荐   |
| 行覆盖率   | > 80% | 必需   |

### 检查覆盖率

```bash
pnpm vitest run --coverage
```

---

## TDD 循环检查清单

- [ ] 🔴 先写失败的测试
- [ ] 🟢 用最简代码让测试通过
- [ ] 🔵 优化代码结构
- [ ] 测试覆盖所有业务规则
- [ ] 测试命名清晰表达意图
- [ ] 测试覆盖率 > 80%
- [ ] 代码复杂度 < 10

---

## 阶段完成条件

- [ ] 所有单元测试通过
- [ ] 测试覆盖率 > 80%
- [ ] 代码复杂度 < 10
- [ ] 所有边界条件已测试
- [ ] 所有验证规则已测试

---

## 示例

### 功能: 用户登录

**实体**: User

**测试**: `src/domain/user/user.aggregate.spec.ts`

```typescript
import { describe, it, expect, beforeEach } from 'vitest';
import { User } from './user.aggregate';
import { Email } from '../value-objects/email.vo';
import { Password } from '../value-objects/password.vo';

describe('User Aggregate', () => {
  let validEmail: Email;
  let validPassword: Password;

  beforeEach(() => {
    validEmail = Email.create('test@example.com').value;
    validPassword = Password.create('Password123').value;
  });

  describe('login', () => {
    it('should successfully login with correct password', () => {
      const user = User.create({
        email: validEmail,
        password: validPassword,
      }).value;

      const result = user.login('Password123');

      expect(result.isOk()).toBe(true);
      expect(user.loginAttempts).toBe(0);
    });

    it('should fail login with wrong password', () => {
      const user = User.create({
        email: validEmail,
        password: validPassword,
      }).value;

      const result = user.login('WrongPassword');

      expect(result.isFail()).toBe(true);
      expect(result.value.message).toContain('邮箱或密码错误');
      expect(user.loginAttempts).toBe(1);
    });

    it('should lock account after 5 failed attempts', () => {
      const user = User.create({
        email: validEmail,
        password: validPassword,
      }).value;

      for (let i = 0; i < 5; i++) {
        user.login('WrongPassword');
      }

      expect(user.isLocked).toBe(true);

      const result = user.login('Password123');
      expect(result.isFail()).toBe(true);
      expect(result.value.message).toContain('账户已锁定');
    });

    it('should reset attempts after successful login', () => {
      const user = User.create({
        email: validEmail,
        password: validPassword,
      }).value;

      user.login('WrongPassword');
      user.login('WrongPassword');
      expect(user.loginAttempts).toBe(2);

      user.login('Password123');
      expect(user.loginAttempts).toBe(0);
    });
  });
});
```

---

## 常见问题

### Q: 测试应该多细？

A: 测试应该覆盖：

- 所有公共方法
- 所有业务规则
- 所有边界条件
- 所有错误处理

不需要测试：

- 私有方法（通过公共方法测试）
- 简单的 getter/setter
- 第三方库

### Q: 什么时候重构？

A: 当看到以下情况时重构：

- 代码重复
- 方法过长（> 20 行）
- 类过大（> 300 行）
- 复杂度过高（> 10）
- 命名不清晰

### Q: 测试失败了怎么办？

A: 遵循以下步骤：

1. 运行 `pnpm vitest run --reporter=verbose` 查看详细错误
2. 检查测试是否正确表达需求
3. 检查实现是否符合测试期望
4. 如果测试错误，修改测试
5. 如果实现错误，修改实现

---

## 下一步

完成 TDD 循环后，可以：

1. **继续到阶段四**: 运行 `/stage-4-implementation $ARGUMENTS` 实现 Command Handler
2. **验证覆盖率**: 运行 `pnpm vitest run --coverage`
3. **运行所有测试**: 运行 `pnpm vitest run`

---

## 参考资源

- [TDD 最佳实践](https://testdriven.io/test-driven-development/)
- [单元测试指南](https://testingjavascript.com/)
- [重构指南](https://refactoring.guru/)
