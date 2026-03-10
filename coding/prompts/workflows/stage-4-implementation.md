---
description: 阶段四 - 实现 Command Handler 和基础设施
agent: build
argument-hint: '<功能名称> [--handler=<handler名>]'
---

# 阶段四：代码实现

实现 Command Handler、Repository 和基础设施层。

---

## 当前任务

功能名称: **$ARGUMENTS**

## 项目上下文

当前分支: !`git branch --show-current`
领域模型状态: !`find src/domain -name "*.aggregate.ts" -type f | wc -l | xargs -I {} echo "{} 个聚合根"`

---

## 前置条件

- [ ] 领域模型已完成（阶段三）
- [ ] 单元测试覆盖率 > 80%
- [ ] 所有领域测试通过

如果未完成，先运行：

```bash
/stage-3-tdd $ARGUMENTS
```

---

## 实现层次结构

```
Application Layer (应用层)
    ├─ Commands (命令)
    │   ├─ create-user.command.ts
    │   └─ create-user.handler.ts
    └─ Queries (查询)
        ├─ get-user.query.ts
        └─ get-user.handler.ts

Infrastructure Layer (基础设施层)
    ├─ Repositories (仓储实现)
    │   └─ user.repository.impl.ts
    ├─ Event Bus (事件总线)
    │   └─ event.bus.ts
    └─ External Services (外部服务)
        └─ email.service.ts
```

---

## 执行步骤

### 1. Command Handler TDD

#### 1.1 编写 Handler 测试

**文件**: `src/application/commands/[command].handler.spec.ts`

```typescript
import { describe, it, expect, beforeEach } from 'vitest';
import { CreateHandler } from './create.handler';
import { CreateCommand } from './create.command';
import { MockRepository } from '../../../tests/mocks/repository.mock';
import { MockEventBus } from '../../../tests/mocks/event-bus.mock';

describe('CreateHandler', () => {
  let handler: CreateHandler;
  let mockRepo: MockRepository;
  let mockEventBus: MockEventBus;

  beforeEach(() => {
    mockRepo = new MockRepository();
    mockEventBus = new MockEventBus();
    handler = new CreateHandler(mockRepo, mockEventBus);
  });

  describe('execute', () => {
    it('should execute successfully', async () => {
      // Arrange
      const command = CreateCommandFixture.createDefault();

      // Act
      const result = await handler.execute(command);

      // Assert
      expect(result.isOk()).toBe(true);
      expect(mockRepo.saveCalls).toHaveLength(1);
    });

    it('should publish events after saving', async () => {
      const command = CreateCommandFixture.createDefault();

      await handler.execute(command);

      expect(mockEventBus.publishedEvents).toHaveLength(1);
      expect(mockEventBus.publishedEvents[0].constructor.name).toBe(
        'CreatedEvent',
      );
    });

    it('should fail when entity not found', async () => {
      const command = new CreateCommand({
        id: 'non-existent-id',
      });

      const result = await handler.execute(command);

      expect(result.isFail()).toBe(true);
      expect(result.value.code).toBe('NOT_FOUND');
    });
  });
});
```

#### 1.2 实现 Handler

**文件**: `src/application/commands/[command].handler.ts`

```typescript
import { CommandHandler, ICommandHandler } from '../command-bus';
import { CreateCommand } from './create.command';
import { Result } from '../../domain/result';
import { IRepository } from '../../domain/repository.interface';
import { IEventBus } from '../../infrastructure/event-bus.interface';
import { ApplicationError } from '../../application/errors/application.error';

@CommandHandler(CreateCommand)
export class CreateHandler
  implements ICommandHandler<CreateCommand, Result<string>>
{
  constructor(
    private readonly repository: IRepository,
    private readonly eventBus: IEventBus,
  ) {}

  async execute(
    command: CreateCommand,
  ): Promise<Result<string, ApplicationError>> {
    // 1. 业务验证
    const entity = await this.repository.findById(command.id);
    if (!entity) {
      return Result.fail(new ApplicationError('实体不存在', 'NOT_FOUND'));
    }

    // 2. 执行业务逻辑
    const result = entity.doSomething(command.params);
    if (result.isFail()) {
      return Result.fail(
        new ApplicationError(result.value.message, 'BUSINESS_ERROR'),
      );
    }

    // 3. 持久化
    await this.repository.save(entity);

    // 4. 发布领域事件
    await this.eventBus.publishAll(entity.domainEvents);
    entity.clearDomainEvents();

    return Result.ok(entity.id);
  }
}
```

---

### 2. Repository 实现

#### 2.1 Repository 接口（领域层）

**文件**: `src/domain/[module]/[entity].repository.ts`

```typescript
import { Entity } from './entity.aggregate';
import { EntityId } from '../value-objects/entity-id.vo';

export interface IEntityRepository {
  findById(id: EntityId): Promise<Entity | null>;
  findByIds(ids: EntityId[]): Promise<Entity[]>;
  save(entity: Entity): Promise<void>;
  delete(id: EntityId): Promise<void>;
}
```

#### 2.2 Repository 实现（基础设施层）

**文件**: `src/infrastructure/persistence/[entity].repository.impl.ts`

```typescript
import { Injectable } from '@nestjs/common';
import { IEntityRepository } from '../../domain/[module]/[entity].repository';
import { Entity } from '../../domain/[module]/[entity].aggregate';
import { EntityId } from '../../domain/value-objects/entity-id.vo';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class EntityRepository implements IEntityRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findById(id: EntityId): Promise<Entity | null> {
    const data = await this.prisma.entity.findUnique({
      where: { id: id.value },
    });

    if (!data) return null;

    return Entity.fromPersistence(data);
  }

  async findByIds(ids: EntityId[]): Promise<Entity[]> {
    const dataList = await this.prisma.entity.findMany({
      where: { id: { in: ids.map((id) => id.value) } },
    });

    return dataList.map((data) => Entity.fromPersistence(data));
  }

  async save(entity: Entity): Promise<void> {
    const data = entity.toPersistence();

    await this.prisma.entity.upsert({
      where: { id: data.id },
      update: data,
      create: data,
    });
  }

  async delete(id: EntityId): Promise<void> {
    await this.prisma.entity.delete({
      where: { id: id.value },
    });
  }
}
```

---

### 3. 验证 BDD 场景

运行 BDD 测试验证实现：

```bash
pnpm vitest run features/$ARGUMENTS.feature
```

**期望**: ✅ 所有 BDD 场景通过

---

## 代码实现检查清单

- [ ] Command Handler 测试覆盖率 > 80%
- [ ] 领域逻辑在聚合根/实体中
- [ ] 值对象不可变
- [ ] 领域事件正确触发
- [ ] 仓储接口定义在领域层
- [ ] 仓储实现在基础设施层
- [ ] 所有 BDD 场景通过

---

## 阶段完成条件

- [ ] Command Handler 实现完成
- [ ] Handler 测试覆盖率 > 80%
- [ ] Repository 实现完成
- [ ] 所有 BDD 场景通过
- [ ] 所有单元测试通过

验证命令:

```bash
# 运行单元测试
pnpm vitest run src/application/**/*.spec.ts

# 运行 BDD 测试
pnpm vitest run features/$ARGUMENTS.feature

# 运行所有测试
pnpm vitest run
```

---

## 示例

### Command: 用户登录

**Command**: `src/application/commands/login.command.ts`

```typescript
export class LoginCommand {
  constructor(
    public readonly email: string,
    public readonly password: string,
    public readonly rememberMe: boolean = false,
  ) {}
}
```

**Handler 测试**: `src/application/commands/login.handler.spec.ts`

```typescript
import { describe, it, expect, beforeEach } from 'vitest';
import { LoginHandler } from './login.handler';
import { LoginCommand } from './login.command';
import { MockUserRepository } from '../../../tests/mocks/user.repository';
import { MockEventBus } from '../../../tests/mocks/event.bus';
import { TokenService } from '../../infrastructure/auth/token.service';

describe('LoginHandler', () => {
  let handler: LoginHandler;
  let mockRepo: MockUserRepository;
  let mockEventBus: MockEventBus;
  let tokenService: TokenService;

  beforeEach(async () => {
    mockRepo = new MockUserRepository();
    mockEventBus = new MockEventBus();
    tokenService = new TokenService();
    handler = new LoginHandler(mockRepo, mockEventBus, tokenService);

    await mockRepo.createTestUser('test@example.com', 'Password123');
  });

  it('should return token on successful login', async () => {
    const command = new LoginCommand('test@example.com', 'Password123', false);

    const result = await handler.execute(command);

    expect(result.isOk()).toBe(true);
    expect(result.value.token).toBeDefined();
    expect(result.value.expiresIn).toBe(24 * 60 * 60 * 1000);
  });

  it('should return 7-day token with remember me', async () => {
    const command = new LoginCommand('test@example.com', 'Password123', true);

    const result = await handler.execute(command);

    expect(result.value.expiresIn).toBe(7 * 24 * 60 * 60 * 1000);
  });

  it('should publish UserLoggedIn event', async () => {
    const command = new LoginCommand('test@example.com', 'Password123', false);

    await handler.execute(command);

    expect(mockEventBus.publishedEvents).toHaveLength(1);
    expect(mockEventBus.publishedEvents[0].constructor.name).toBe(
      'UserLoggedInEvent',
    );
  });
});
```

**Handler 实现**: `src/application/commands/login.handler.ts`

```typescript
import { CommandHandler, ICommandHandler } from '../command-bus';
import { LoginCommand } from './login.command';
import { Result } from '../../domain/result';
import { IUserRepository } from '../../domain/user/user.repository';
import { IEventBus } from '../../infrastructure/event-bus.interface';
import { TokenService } from '../../infrastructure/auth/token.service';
import { ApplicationError } from '../errors/application.error';

@CommandHandler(LoginCommand)
export class LoginHandler
  implements ICommandHandler<LoginCommand, Result<LoginResponse>>
{
  constructor(
    private readonly userRepo: IUserRepository,
    private readonly eventBus: IEventBus,
    private readonly tokenService: TokenService,
  ) {}

  async execute(
    command: LoginCommand,
  ): Promise<Result<LoginResponse, ApplicationError>> {
    // 1. 查找用户
    const user = await this.userRepo.findByEmail(command.email);
    if (!user) {
      return Result.fail(new ApplicationError('邮箱或密码错误', 'AUTH_FAILED'));
    }

    // 2. 验证登录
    const loginResult = user.login(command.password);
    if (loginResult.isFail()) {
      await this.userRepo.save(user);
      return Result.fail(
        new ApplicationError(loginResult.value.message, 'AUTH_FAILED'),
      );
    }

    // 3. 生成 Token
    const expiresIn = command.rememberMe
      ? 7 * 24 * 60 * 60 * 1000
      : 24 * 60 * 60 * 1000;

    const token = this.tokenService.generate(
      { userId: user.id, email: user.email.value },
      expiresIn,
    );

    // 4. 保存用户状态
    await this.userRepo.save(user);

    // 5. 发布事件
    await this.eventBus.publishAll(user.domainEvents);
    user.clearDomainEvents();

    return Result.ok({
      token,
      expiresIn,
      user: {
        id: user.id,
        email: user.email.value,
      },
    });
  }
}

export interface LoginResponse {
  token: string;
  expiresIn: number;
  user: {
    id: string;
    email: string;
  };
}
```

---

## 常见问题

### Q: Handler 应该包含什么逻辑？

A: Handler 职责：

- ✅ 协调领域对象
- ✅ 调用仓储
- ✅ 发布事件
- ✅ 返回结果
- ❌ 业务逻辑（应在领域层）
- ❌ 数据访问逻辑（应在仓储层）

### Q: 如何处理事务？

A: 使用 Unit of Work 模式：

```typescript
@Injectable()
export class UnitOfWork {
  constructor(private readonly prisma: PrismaService) {}

  async execute<T>(work: () => Promise<T>): Promise<T> {
    return this.prisma.$transaction(async () => {
      return work();
    });
  }
}

// 使用
await this.unitOfWork.execute(async () => {
  await this.repository.save(entity);
  await this.eventBus.publishAll(events);
});
```

### Q: 如何 Mock 依赖？

A: 创建 Mock 类：

```typescript
export class MockUserRepository implements IUserRepository {
  private users: Map<string, User> = new Map();
  public saveCalls: User[] = [];

  async findByEmail(email: string): Promise<User | null> {
    return (
      Array.from(this.users.values()).find((u) => u.email.value === email) ||
      null
    );
  }

  async save(user: User): Promise<void> {
    this.users.set(user.id, user);
    this.saveCalls.push(user);
  }

  async createTestUser(email: string, password: string): Promise<void> {
    const user = User.create({
      email: Email.create(email).value,
      password: Password.create(password).value,
    }).value;
    this.users.set(user.id, user);
  }
}
```

---

## 下一步

完成代码实现后，可以：

1. **继续到阶段五**: 运行 `/stage-5-optimization $ARGUMENTS` 进行代码优化
2. **运行所有测试**: 运行 `pnpm vitest run` 验证所有测试通过
3. **提交代码**: 运行 `git add . && git commit` 提交代码

---

## 参考资源

- [CQRS 模式](https://martinfowler.com/bliki/CQRS.html)
- [Repository 模式](https://martinfowler.com/eaaCatalog/repository.html)
- [DDD 分层架构](https://www.domainlanguage.com/)
