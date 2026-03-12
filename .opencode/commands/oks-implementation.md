---
description: 实现服务层和应用层
agent: build
argument-hint: '<功能名称>'
---

## ⚠️ 参数验证

!`if [ -z "$ARGUMENTS" ]; then
  echo "❌ **错误: 缺少功能名称**"
  echo ""
  echo "**用法**: /oks-implementation <功能名称>"
  echo ""
  echo "**示例**: /oks-implementation 用户登录"
  exit 1
fi`

---

## 🔒 前置条件检查

!`

# 使用统一的前置检查脚本

RESULT=$(bash oks-coding-system/scripts/check-prerequisites.sh --json --stage=implementation --feature="$ARGUMENTS" 2>&1)
if echo "$RESULT" | grep -q '"error"'; then
  MISSING=$(echo "$RESULT" | grep -o '"missing":\[[^]]*\]' | sed 's/"missing":\[/缺失: /; s/\]//; s/", "/\n  - /g' | sed 's/"//g')
  SUGGEST=$(echo "$RESULT" | grep -o '"suggestions":\[[^]]\*\]' | sed 's/"suggestions":\[/建议: /; s/\]//; s/", "/\n → /g' | sed 's/"//g')
  echo ""
  echo "❌ **前置条件未满足**"
  echo ""
  echo "$MISSING"
echo ""
echo "$SUGGEST"
echo ""
echo "**解决方案**:"
echo " /oks-tdd $ARGUMENTS"
exit 1
fi
`

---

# 代码实现

实现服务层、控制器和数据访问层。

---

## 当前任务

功能名称: **$ARGUMENTS**

## 项目上下文

当前分支: !`git branch --show-current`
模块状态: !`find src/modules -name "*.ts" -type f 2>/dev/null | wc -l | xargs -I {} echo "{} 个模块文件" || echo "0 个模块文件"`

!`

# 检查 BDD 场景

if [ -f "features/$ARGUMENTS.feature" ]; then
echo "**BDD 场景**: ✅ features/$ARGUMENTS.feature"
elif [ -f "oks-coding-system/templates/$ARGUMENTS/bdd-scenarios.md" ]; then
echo "**BDD 场景**: ✅ oks-coding-system/templates/$ARGUMENTS/bdd-scenarios.md"
else
echo "**BDD 场景**: ⚠️ 不存在（可选，建议先运行 /oks-bdd $ARGUMENTS）"
fi
`

---

## 前置条件

- [ ] 核心实体/模型已完成（阶段三）
- [ ] 单元测试覆盖率 > 80%
- [ ] 所有核心测试通过

如果未完成，先运行：

```bash
/oks-tdd $ARGUMENTS
```

## 关联文档

!`
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
VISION_DIR="$REPO_ROOT/docs/visions"
PROJECT_NAME=""

# 尝试从 vision 文档获取项目名

for file in "$VISION_DIR"/*-vision.md; do
    if [ -f "$file" ] && grep -qi "$ARGUMENTS" "$file" 2>/dev/null; then
PROJECT_NAME=$(basename "$file" -vision.md)
break
fi
done

# 如果只有一个 vision，使用它

if [ -z "$PROJECT_NAME" ]; then
VISION*COUNT=$(ls -1 "$VISION_DIR"/*-vision.md 2>/dev/null | wc -l)
if [ "$VISION_COUNT" -eq 1 ]; then
PROJECT*NAME=$(basename $(ls -1 "$VISION_DIR"/*-vision.md | head -1) -vision.md)
fi
fi

# 检查设计文档

if [ -n "$PROJECT_NAME" ] && [ -f "$REPO_ROOT/docs/designs/$PROJECT_NAME/$ARGUMENTS.md" ]; then
echo "**技术设计**: ✅ docs/designs/$PROJECT_NAME/$ARGUMENTS.md"
echo ""
echo "从设计文档中获取："
echo "- API 接口定义 → 控制器和 DTO"
echo "- 数据库表结构 → Repository 映射"
echo "- 数据流设计 → 服务层调用链"
elif [ -f "$REPO_ROOT/docs/designs/$ARGUMENTS.md" ]; then
echo "**技术设计**: ✅ docs/designs/$ARGUMENTS.md"
else
echo "**技术设计**: ⚠️ 不存在（建议先运行 /oks-design $ARGUMENTS）"
fi
`

---

## 项目结构

```
src/
├── modules/
│   └── [module]/
│       ├── controllers/
│       │   ├── [module].controller.ts
│       │   └── [module].controller.spec.ts      # 控制器测试
│       ├── services/
│       │   ├── [module].service.ts
│       │   └── [module].service.spec.ts         # 服务测试（必需）
│       ├── entities/
│       │   └── [module].entity.ts
│       └── repositories/
│           ├── [module].repository.ts
│           └── [module].repository.spec.ts      # Repository 测试
└── common/
    └── ...
```

---

## ⚠️ 测试优先原则

> **重要**: 本阶段必须保证单元测试覆盖率

| 层级           | 测试要求                   | 覆盖率目标 |
| -------------- | -------------------------- | ---------- |
| **服务层**     | ✅ **必需** - 所有公共方法 | > 80%      |
| **控制器**     | ✅ **必需** - 所有端点     | > 70%      |
| **Repository** | ⚠️ 推荐 - 复杂映射逻辑     | > 60%      |

**测试优先流程**:

```
1. 编写服务测试 → 2. 实现服务 → 3. 运行测试通过
                ↓
4. 编写控制器测试 → 5. 实现控制器 → 6. 运行测试通过
```

**每个实现文件必须有对应的测试文件**:

```
[module].service.ts      → [module].service.spec.ts      ✅
[module].controller.ts   → [module].controller.spec.ts   ✅
```

---

## 执行步骤

### 1. 服务层实现

#### 1.1 编写服务测试

**文件**: `src/modules/[module]/services/[module].service.spec.ts`

```typescript
import { describe, it, expect, beforeEach, vi } from 'vitest';
import { UserService } from './user.service';
import { UserRepository } from '../repositories/user.repository';

describe('UserService', () => {
  let service: UserService;
  let mockRepo: UserRepository;

  beforeEach(() => {
    mockRepo = {
      findById: vi.fn(),
      findByEmail: vi.fn(),
      save: vi.fn(),
      delete: vi.fn(),
    } as any;
    service = new UserService(mockRepo);
  });

  describe('create', () => {
    it('should create user successfully', async () => {
      const dto = {
        email: 'test@example.com',
        password: 'Password123',
      };

      const result = await service.create(dto);

      expect(result).toBeDefined();
      expect(result.email).toBe(dto.email);
      expect(mockRepo.save).toHaveBeenCalled();
    });

    it('should fail when email already exists', async () => {
      vi.mocked(mockRepo.findByEmail).mockResolvedValue({ id: '1' } as any);

      const dto = {
        email: 'test@example.com',
        password: 'Password123',
      };

      await expect(service.create(dto)).rejects.toThrow('邮箱已存在');
    });
  });

  describe('login', () => {
    it('should return token on successful login', async () => {
      vi.mocked(mockRepo.findByEmail).mockResolvedValue({
        id: '1',
        email: 'test@example.com',
        password: 'hashedPassword',
        loginAttempts: 0,
        isLocked: false,
      } as any);

      const result = await service.login('test@example.com', 'Password123');

      expect(result.token).toBeDefined();
      expect(result.expiresIn).toBe(24 * 60 * 60 * 1000);
    });
  });
});
```

#### 1.2 实现服务

**文件**: `src/modules/[module]/services/[module].service.ts`

```typescript
import { Injectable } from '@nestjs/common';
import { UserRepository } from '../repositories/user.repository';
import { User } from '../entities/user.entity';
import * as bcrypt from 'bcrypt';
import * as jwt from 'jsonwebtoken';

@Injectable()
export class UserService {
  constructor(private readonly userRepo: UserRepository) {}

  async create(dto: CreateUserDto): Promise<User> {
    // 1. 检查邮箱是否已存在
    const existing = await this.userRepo.findByEmail(dto.email);
    if (existing) {
      throw new Error('邮箱已存在');
    }

    // 2. 加密密码（基础设施关注点）
    const hashedPassword = await bcrypt.hash(dto.password, 10);

    // 3. 创建用户（领域逻辑）
    const user = User.create({
      email: dto.email,
      hashedPassword,
    });

    // 4. 保存
    await this.userRepo.save(user);

    return user;
  }

  async login(email: string, password: string): Promise<LoginResponse> {
    // 1. 查找用户
    const user = await this.userRepo.findByEmail(email);
    if (!user) {
      throw new Error('邮箱或密码错误');
    }

    // 2. 验证密码（基础设施关注点）
    const isPasswordValid = await bcrypt.compare(password, user.HashedPassword);

    // 3. 调用领域逻辑（业务规则在实体中）
    const result = user.login(isPasswordValid);

    if (!result.success) {
      await this.userRepo.save(user); // 保存状态变更（锁定、尝试次数）
      throw new Error(result.error);
    }

    // 4. 生成 Token（基础设施关注点）
    const token = jwt.sign(
      { userId: user.Id, email: user.Email },
      process.env.JWT_SECRET!,
      { expiresIn: '24h' },
    );

    // 5. 保存状态变更
    await this.userRepo.save(user);

    return {
      token,
      expiresIn: 24 * 60 * 60 * 1000,
      user: {
        id: user.Id,
        email: user.Email,
      },
    };
  }
}

interface CreateUserDto {
  email: string;
  password: string;
}

interface LoginResponse {
  token: string;
  expiresIn: number;
  user: {
    id: string;
    email: string;
  };
}
```

> **设计原则**:
>
> - 密码加密/验证由服务层调用 bcrypt 完成（基础设施关注点）
> - 业务规则（锁定、尝试次数）由领域实体 `user.login()` 处理
> - 服务层只做协调，不包含业务规则

---

### 2. 数据访问层实现

#### 2.1 Repository 接口

**文件**: `src/modules/[module]/repositories/[module].repository.interface.ts`

```typescript
import { User } from '../entities/user.entity';

export interface UserRepository {
  findById(id: string): Promise<User | null>;
  findByEmail(email: string): Promise<User | null>;
  findAll(): Promise<User[]>;
  save(user: User): Promise<void>;
  delete(id: string): Promise<void>;
}
```

#### 2.2 Repository 实现 (MikroORM)

**文件**: `src/modules/[module]/repositories/[module].repository.ts`

```typescript
import { Injectable } from '@nestjs/common';
import { EntityManager } from '@mikro-orm/postgresql';
import { UserRepository } from './user.repository.interface';
import { User } from '../entities/user.entity';
import { UserEntity } from '../entities/user.orm-entity';

@Injectable()
export class UserRepositoryImpl implements UserRepository {
  constructor(private readonly em: EntityManager) {}

  async findById(id: string): Promise<User | null> {
    const entity = await this.em.findOne(UserEntity, { id });
    return entity ? this.mapToUser(entity) : null;
  }

  async findByEmail(email: string): Promise<User | null> {
    const entity = await this.em.findOne(UserEntity, { email });
    return entity ? this.mapToUser(entity) : null;
  }

  async findAll(): Promise<User[]> {
    const entities = await this.em.find(UserEntity, {});
    return entities.map((e) => this.mapToUser(e));
  }

  async save(user: User): Promise<void> {
    const entity = this.mapToEntity(user);
    this.em.persist(entity);
    await this.em.flush();
  }

  async delete(id: string): Promise<void> {
    const entity = await this.em.findOne(UserEntity, { id });
    if (entity) {
      await this.em.removeAndFlush(entity);
    }
  }

  private mapToUser(entity: UserEntity): User {
    return User.create({
      id: entity.id,
      email: entity.email,
      password: entity.password,
      loginAttempts: entity.loginAttempts,
      isLocked: entity.isLocked,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    });
  }

  private mapToEntity(user: User): UserEntity {
    const entity = new UserEntity();
    entity.id = user.id;
    entity.email = user.email;
    entity.password = user.password;
    entity.loginAttempts = user.loginAttempts;
    entity.isLocked = user.isLocked;
    entity.updatedAt = new Date();
    return entity;
  }
}
```

---

### 3. 控制器实现

#### 3.1 编写控制器测试

**文件**: `src/modules/[module]/controllers/[module].controller.spec.ts`

```typescript
import { describe, it, expect, beforeEach, vi } from 'vitest';
import { UserController } from './user.controller';
import { UserService } from '../services/user.service';

describe('UserController', () => {
  let controller: UserController;
  let mockService: UserService;

  beforeEach(() => {
    mockService = {
      create: vi.fn(),
      login: vi.fn(),
    } as any;
    controller = new UserController(mockService);
  });

  describe('POST /users', () => {
    it('should create user', async () => {
      vi.mocked(mockService.create).mockResolvedValue({
        id: '1',
        email: 'test@example.com',
      } as any);

      const result = await controller.create({
        email: 'test@example.com',
        password: 'Password123',
      });

      expect(result.email).toBe('test@example.com');
    });
  });

  describe('POST /users/login', () => {
    it('should return token', async () => {
      vi.mocked(mockService.login).mockResolvedValue({
        token: 'jwt-token',
        expiresIn: 86400000,
      } as any);

      const result = await controller.login({
        email: 'test@example.com',
        password: 'Password123',
      });

      expect(result.token).toBe('jwt-token');
    });
  });
});
```

#### 3.2 实现控制器

**文件**: `src/modules/[module]/controllers/[module].controller.ts`

```typescript
import { Controller, Post, Body } from '@nestjs/common';
import { UserService } from '../services/user.service';

@Controller('users')
export class UserController {
  constructor(private readonly userService: UserService) {}

  @Post()
  async create(@Body() dto: CreateUserDto) {
    const user = await this.userService.create(dto);
    return {
      id: user.id,
      email: user.email,
    };
  }

  @Post('login')
  async login(@Body() dto: LoginDto) {
    return this.userService.login(dto.email, dto.password);
  }
}

interface CreateUserDto {
  email: string;
  password: string;
}

interface LoginDto {
  email: string;
  password: string;
}
```

---

### 4. 验证 BDD 场景

运行 BDD 测试验证实现：

```bash
pnpm vitest run features/$ARGUMENTS.feature
```

**期望**: ✅ 所有 BDD 场景通过

---

## 代码实现检查清单

### 测试（必需）

- [ ] 服务层测试文件已创建 `[module].service.spec.ts`
- [ ] 服务层测试覆盖率 > 80%
- [ ] 控制器测试文件已创建 `[module].controller.spec.ts`
- [ ] 控制器测试覆盖率 > 70%
- [ ] 所有单元测试通过 `pnpm vitest run src/modules/`

### 实现

- [ ] 业务逻辑在服务层中
- [ ] 数据访问层接口清晰
- [ ] 控制器只做请求/响应处理

### 集成验证

- [ ] 所有 BDD 场景通过 `pnpm vitest run features/`

---

## 阶段完成条件

- [ ] 服务层实现完成
- [ ] 服务层测试覆盖率 > 80%
- [ ] 数据访问层实现完成
- [ ] 控制器实现完成
- [ ] 所有 BDD 场景通过
- [ ] 所有单元测试通过

验证命令:

```bash
# 运行单元测试（必需）
pnpm vitest run src/modules/

# 运行 BDD 测试（必需）
pnpm vitest run features/$ARGUMENTS.feature

# 检查测试覆盖率（必需）
pnpm vitest run --coverage

# 运行所有测试
pnpm vitest run
```

> ⚠️ **注意**: 如果覆盖率不达标（服务层 < 80%），必须补充测试后才能进入下一阶段

> ⚠️ **注意**: 如果覆盖率不达标（<80%），必须补充测试后才能进入下一阶段

---

## 常见问题

### Q: 服务层应该包含什么逻辑？

A: 服务层职责：

- ✅ 业务逻辑协调
- ✅ 数据访问调用
- ✅ 事务管理
- ✅ 返回结果
- ❌ HTTP 处理（应在控制器层）
- ❌ 数据库操作细节（应在 Repository 层）

### Q: 如何处理事务？

A: 使用 MikroORM 事务：

```typescript
@Injectable()
export class UserService {
  constructor(
    private readonly em: EntityManager,
    private readonly userRepo: UserRepository,
  ) {}

  async transfer(fromId: string, toId: string, amount: number) {
    await this.em.transactional(async (em) => {
      const from = await this.userRepo.findById(fromId);
      const to = await this.userRepo.findById(toId);

      from.debit(amount);
      to.credit(amount);

      await this.userRepo.save(from);
      await this.userRepo.save(to);
    });
  }
}
```

### Q: 如何 Mock 依赖？

A: 使用 vitest 的 vi.fn():

```typescript
const mockRepo = {
  findById: vi.fn(),
  save: vi.fn(),
} as any;

vi.mocked(mockRepo.findById).mockResolvedValue({ id: '1' });
```

---

## 💬 常用提示词

### 编写服务测试

```markdown
为 {服务名} 编写服务层测试：

1. Mock 所有外部依赖（Repository、第三方服务）
2. 使用 AAA 模式 (Arrange-Act-Assert)
3. 覆盖所有公共方法
4. 包含正常、异常、边界情况
5. 验证业务逻辑协调正确
```

### 代码质量审查

```markdown
从以下角度审查 {功能名称} 的改动：

1. **类型安全**: 是否有 any 类型？类型定义是否完整？
2. **错误处理**: 是否处理了所有可能的错误？
3. **安全性**: 是否有安全漏洞？（XSS、SQL 注入等）
4. **边界情况**: 是否处理了边界情况？
5. **代码复杂度**: 复杂度是否 < 10？
6. **代码重复**: 是否有重复代码？
```

### 安全审查

```markdown
审查 {功能名称} 的安全性：

1. **输入验证**: 所有用户输入是否验证？
2. **权限检查**: 是否有权限控制？
3. **敏感数据**: 敏感数据是否加密？
4. **SQL 注入**: 是否使用参数化查询？
5. **XSS**: 是否对输出进行编码？
```

### 运行测试并修复

```markdown
运行测试并修复所有失败的测试：

1. 运行 pnpm vitest run 查看失败测试
2. 分析失败原因
3. 修复问题（测试错误或实现错误）
4. 确保所有测试通过
```

---

## 下一步

完成代码实现后，可以：

1. **继续优化**: 运行 `/oks-optimization $ARGUMENTS` 进行代码优化
2. **运行所有测试**: 运行 `pnpm vitest run` 验证所有测试通过
3. **提交代码**: 运行 `git add . && git commit` 提交代码

---

## 参考资源

- [NestJS 文档](https://docs.nestjs.com/)
- [MikroORM 文档](https://mikro-orm.io/)
- [Service Layer 模式](https://martinfowler.com/eaaCatalog/serviceLayer.html)
