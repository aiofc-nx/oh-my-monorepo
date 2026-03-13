---
description: TDD 开发循环（Red-Green-Refactor）
agent: build
argument-hint: '<功能名称>'
---

## ⚠️ 参数验证

!`if [ -z "$ARGUMENTS" ]; then
  echo "❌ **错误: 缺少功能名称**"
  echo ""
  echo "**用法**: /oks-tdd <功能名称>"
  echo ""
  echo "**示例**: /oks-tdd 配置项管理"
  exit 1
fi`

---

## 🔒 前置条件检查

!`

# 使用统一的前置检查脚本（BDD 场景为可选）

RESULT=$(bash oks-coding-system/scripts/check-prerequisites.sh --json --stage=tdd --feature="$ARGUMENTS" 2>&1)
if echo "$RESULT" | grep -q '"error"'; then
  MISSING=$(echo "$RESULT" | grep -o '"missing":\[[^]]*\]' | sed 's/"missing":\[/缺失: /; s/\]//; s/", "/\n  - /g' | sed 's/"//g')
  SUGGEST=$(echo "$RESULT" | grep -o '"suggestions":\[[^]]\*\]' | sed 's/"suggestions":\[/建议: /; s/\]//; s/", "/\n → /g' | sed 's/"//g')

# 仅对用户故事缺失报错，BDD 场景为可选

if echo "$MISSING" | grep -q "用户故事"; then
    echo ""
    echo "❌ **前置条件未满足**"
    echo ""
    echo "$MISSING"
echo ""
echo "$SUGGEST"
echo ""
echo "**解决方案**:"
echo " /oks-user-story $ARGUMENTS"
exit 1
fi
fi

# 检查 BDD 场景（可选，仅提示）

if [ ! -f "features/$ARGUMENTS.feature" ] && [ ! -f "oks-coding-system/templates/$ARGUMENTS/bdd-scenarios.md" ]; then
echo ""
echo "⚠️ **提示: BDD 场景不存在**"
echo "TDD 阶段可以跳过 BDD 直接开发，但建议先设计 BDD 场景。"
echo "可选: /oks-bdd $ARGUMENTS"
echo ""
fi
`

---

# TDD 开发循环

使用 Red-Green-Refactor 循环驱动**领域模型**的代码设计。

> **注意**: 本阶段专注于领域层（Entity/Value Object），不涉及外部依赖。
>
> - ✅ 纯业务逻辑验证
> - ✅ 无数据库、网络、文件系统依赖
> - ❌ Service/Controller 实现属于 `/oks-implementation` 阶段

---

## 🎯 TDD 适用性判断

在开始 TDD 之前，请确认您的功能类型：

### ✅ 适合 TDD 的场景

| 场景类型     | 示例                         | 原因                   |
| ------------ | ---------------------------- | ---------------------- |
| **领域实体** | User、Order、Product         | 包含业务规则和状态转换 |
| **值对象**   | Email、Money、Address        | 需要验证逻辑           |
| **业务规则** | 登录锁定、库存扣减、价格计算 | 逻辑复杂，边界条件多   |
| **状态机**   | 订单状态、支付流程           | 状态转换规则需要验证   |
| **计算逻辑** | 折扣计算、评分算法           | 纯函数，易于测试       |

### ⚠️ 可能不需要 TDD 的场景

| 场景类型     | 示例                  | 建议                         |
| ------------ | --------------------- | ---------------------------- |
| **纯 CRUD**  | 简单的增删改查        | 直接用 `/oks-implementation` |
| **数据传递** | DTO、Request/Response | 无需测试或用类型检查         |
| **配置读取** | 环境变量、配置文件    | 集成测试覆盖                 |
| **代理转发** | API 网关、代理层      | 集成测试更合适               |
| **UI 组件**  | 表单、按钮、布局      | 使用组件测试而非 TDD         |

### 🤔 快速判断

!`echo "请回答以下问题，判断是否适合 TDD："
echo ""
echo "1. 该功能是否包含业务规则（如验证、计算、状态转换）？"
echo "2. 该功能是否有多个边界条件需要测试？"
echo "3. 该功能是否可以独立于数据库/网络运行？"
echo ""
echo "**判断结果**:"
echo "- 3 个「是」→ ✅ 强烈推荐 TDD"
echo "- 2 个「是」→ ⚠️ 可以考虑 TDD（或跳过）"
echo "- 1 个或以下 → ❌ 建议跳过 TDD，直接用 /oks-implementation"`

---

## 当前任务

功能名称: **$ARGUMENTS**

## 项目上下文

当前分支: !`git branch --show-current`
测试状态: !`pnpm vitest run 2>&1 | tail -10 || echo "Tests not run yet"`

## 关联文档

!`
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
PROJECT_ROOT=$(get_project_root "$PROJECT_NAME")
VISION_FILE="$REPO_ROOT/$PROJECT_ROOT/docs/specify/vision.md"
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

if [ -n "$PROJECT_NAME" ] && [ -f "$REPO_ROOT/<project>/docs/specify/$PROJECT_NAME/$ARGUMENTS.md" ]; then
echo "**技术设计**: ✅ <project>/docs/specify/$PROJECT_NAME/$ARGUMENTS.md"
echo ""
echo "建议从设计文档中获取："
echo "- 数据库表结构 → 映射为实体属性"
echo "- 业务规则 → 编写测试用例"
echo "- 验证规则 → 实体验证逻辑"
elif [ -f "$REPO_ROOT/<project>/docs/specify/$ARGUMENTS.md" ]; then
echo "**技术设计**: ✅ <project>/docs/specify/$ARGUMENTS.md"
else
echo "**技术设计**: ⚠️ 不存在（建议先运行 /oks-design $ARGUMENTS）"
fi
`

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

> **TDD 阶段只针对领域层**

```
src/modules/[module]/entities/
├── [entity].entity.ts          # 领域实体
└── [entity].entity.spec.ts     # 实体测试

src/modules/[module]/value-objects/
├── [vo].value-object.ts        # 值对象
└── [vo].value-object.spec.ts   # 值对象测试
```

> Service/Controller 的测试属于 `/oks-implementation` 阶段

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
      expect(result).toBeDefined();
      expect(result.property).toBe(expected);
    });

    it('should fail when [validation]', () => {
      const result = Entity.create({
        /* 无效数据 */
      });

      expect(() => result).toThrow('错误信息');
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
export class Entity {
  private id: string;
  private props: EntityProps;

  static create(props: CreateProps): Entity {
    // 1. 验证
    if (!props.required) {
      throw new Error('必填字段不能为空');
    }

    // 2. 创建实体
    const entity = new Entity();
    entity.id = crypto.randomUUID();
    entity.props = {
      ...props,
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    return entity;
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
export class Entity {
  static create(props: CreateProps): Entity {
    if (!props.required) {
      throw new Error('必填字段不能为空');
    }

    if (!props.email?.includes('@')) {
      throw new Error('邮箱格式不正确');
    }

    const entity = new Entity();
    entity.id = crypto.randomUUID();
    entity.props = {
      ...props,
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    return entity;
  }
}
```

**重构后**:

```typescript
export class Entity {
  static create(props: CreateProps): Entity {
    this.validate(props);

    const entity = new Entity();
    entity.id = crypto.randomUUID();
    entity.props = this.initializeProps(props);

    return entity;
  }

  private static validate(props: CreateProps): void {
    if (!props.required?.trim()) {
      throw new Error('必填字段不能为空');
    }

    if (!props.email?.includes('@')) {
      throw new Error('邮箱格式不正确');
    }
  }

  private static initializeProps(props: CreateProps): EntityProps {
    return {
      ...props,
      createdAt: new Date(),
      updatedAt: new Date(),
    };
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

**文件**: `src/modules/user/entities/user.entity.ts`

> **设计原则**: 领域实体不依赖外部服务（如 bcrypt）。
> 密码验证由服务层调用密码服务完成，实体只处理业务规则。

```typescript
// user.entity.ts - 领域实体，无外部依赖
export class User {
  private constructor(
    private id: string,
    private email: string,
    private hashedPassword: string,
    private loginAttempts: number = 0,
    private lockedUntil: Date | null = null,
  ) {}

  static create(props: CreateProps): User {
    if (!props.email?.includes('@')) {
      throw new Error('邮箱格式不正确');
    }
    if (!props.hashedPassword) {
      throw new Error('密码不能为空');
    }
    return new User(
      crypto.randomUUID(),
      props.email,
      props.hashedPassword,
      0,
      null,
    );
  }

  /**
   * 验证登录 - 业务规则层
   * @param isPasswordValid 由服务层传入的密码验证结果
   * @returns 登录结果
   */
  login(isPasswordValid: boolean): LoginResult {
    // 检查账户锁定
    if (this.isLocked()) {
      return { success: false, error: '账户已锁定' };
    }

    // 检查密码
    if (!isPasswordValid) {
      this.incrementAttempts();
      if (this.loginAttempts >= 5) {
        this.lockUntil(new Date(Date.now() + 15 * 60 * 1000)); // 锁定 15 分钟
        return { success: false, error: '账户已锁定，请 15 分钟后再试' };
      }
      return { success: false, error: '邮箱或密码错误' };
    }

    // 登录成功
    this.resetAttempts();
    return { success: true };
  }

  isLocked(): boolean {
    if (this.lockedUntil && this.lockedUntil > new Date()) {
      return true;
    }
    // 锁定时间已过，自动解锁
    if (this.lockedUntil) {
      this.lockedUntil = null;
      this.loginAttempts = 0;
    }
    return false;
  }

  private incrementAttempts(): void {
    this.loginAttempts++;
  }

  private resetAttempts(): void {
    this.loginAttempts = 0;
    this.lockedUntil = null;
  }

  private lockUntil(date: Date): void {
    this.lockedUntil = date;
  }

  // Getters
  get Id() {
    return this.id;
  }
  get Email() {
    return this.email;
  }
  get LoginAttempts() {
    return this.loginAttempts;
  }
  get LockedUntil() {
    return this.lockedUntil;
  }
}

interface CreateProps {
  email: string;
  hashedPassword: string; // 已加密的密码，由服务层提供
}

interface LoginResult {
  success: boolean;
  error?: string;
}
```

**测试**: `src/modules/user/entities/user.entity.spec.ts`

```typescript
import { describe, it, expect, beforeEach } from 'vitest';
import { User } from './user.entity';

describe('User Entity', () => {
  const validEmail = 'test@example.com';
  const validHashedPassword = 'hashed_password_123';

  describe('create', () => {
    it('should create user with valid props', () => {
      const user = User.create({
        email: validEmail,
        hashedPassword: validHashedPassword,
      });

      expect(user.Id).toBeDefined();
      expect(user.Email).toBe(validEmail);
      expect(user.LoginAttempts).toBe(0);
    });

    it('should fail with invalid email', () => {
      expect(() =>
        User.create({
          email: 'invalid-email',
          hashedPassword: validHashedPassword,
        }),
      ).toThrow('邮箱格式不正确');
    });

    it('should fail without password', () => {
      expect(() =>
        User.create({
          email: validEmail,
          hashedPassword: '',
        }),
      ).toThrow('密码不能为空');
    });
  });

  describe('login', () => {
    it('should succeed with correct password', () => {
      const user = User.create({
        email: validEmail,
        hashedPassword: validHashedPassword,
      });

      const result = user.login(true); // 服务层已验证密码

      expect(result.success).toBe(true);
      expect(user.LoginAttempts).toBe(0);
    });

    it('should fail with wrong password', () => {
      const user = User.create({
        email: validEmail,
        hashedPassword: validHashedPassword,
      });

      const result = user.login(false); // 服务层验证失败

      expect(result.success).toBe(false);
      expect(result.error).toContain('邮箱或密码错误');
      expect(user.LoginAttempts).toBe(1);
    });

    it('should lock account after 5 failed attempts', () => {
      const user = User.create({
        email: validEmail,
        hashedPassword: validHashedPassword,
      });

      // 连续失败 5 次
      for (let i = 0; i < 5; i++) {
        user.login(false);
      }

      expect(user.isLocked()).toBe(true);

      // 即使密码正确，也被锁定
      const result = user.login(true);
      expect(result.success).toBe(false);
      expect(result.error).toContain('账户已锁定');
    });

    it('should reset attempts after successful login', () => {
      const user = User.create({
        email: validEmail,
        hashedPassword: validHashedPassword,
      });

      user.login(false);
      user.login(false);
      expect(user.LoginAttempts).toBe(2);

      user.login(true);
      expect(user.LoginAttempts).toBe(0);
    });
  });

  describe('isLocked', () => {
    it('should return false when not locked', () => {
      const user = User.create({
        email: validEmail,
        hashedPassword: validHashedPassword,
      });

      expect(user.isLocked()).toBe(false);
    });

    it('should auto-unlock after lock period', () => {
      const user = User.create({
        email: validEmail,
        hashedPassword: validHashedPassword,
      });

      // 触发锁定
      for (let i = 0; i < 5; i++) {
        user.login(false);
      }
      expect(user.isLocked()).toBe(true);

      // 模拟时间过去（实际测试中可以用 vi.useFakeTimers）
      // 这里只展示概念
    });
  });
});
```

> **关键点**:
>
> - 实体不调用 bcrypt，由服务层处理密码验证
> - `login(isPasswordValid)` 接收布尔参数，关注业务规则
> - 测试可以完全独立运行，无需 mock 任何外部依赖

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

### Q: 什么时候应该跳过 TDD？

A: 以下情况可以直接进入 `/oks-implementation`：

```typescript
// ❌ 不需要 TDD：纯数据传递
interface CreateUserDto {
  email: string;
  password: string;
}

// ❌ 不需要 TDD：简单的 CRUD Service
class UserService {
  constructor(private repo: UserRepository) {}

  async findById(id: string) {
    return this.repo.findById(id); // 无业务逻辑
  }

  async create(dto: CreateUserDto) {
    return this.repo.save(dto); // 仅转发
  }
}

// ✅ 需要 TDD：包含业务规则
class User {
  login(isPasswordValid: boolean): LoginResult {
    if (this.isLocked()) return { success: false, error: '账户已锁定' };
    if (!isPasswordValid) {
      this.incrementAttempts();
      if (this.loginAttempts >= 5) {
        this.lock(); // 业务规则：5次失败锁定
      }
      return { success: false };
    }
    this.resetAttempts();
    return { success: true };
  }
}
```

**跳过 TDD 时的建议**：

- 在 `/oks-implementation` 阶段增加集成测试
- 使用 BDD 场景覆盖主要流程

---

## 💬 常用提示词

### TDD 开发流程

```markdown
使用 TDD 方式实现 {功能名称}：

1. 🔴 Red: 先编写失败的测试
2. 🟢 Green: 用最简代码让测试通过
3. 🔵 Refactor: 优化代码，保持测试通过
4. 重复以上步骤
```

### 编写实体测试

```markdown
为 {实体名} 实体编写单元测试：

1. 使用 AAA 模式 (Arrange-Act-Assert)
2. 覆盖所有公共方法和业务规则
3. 包含正常、异常、边界情况
4. 测试命名清晰表达意图
5. 无外部依赖（数据库、网络）
```

### 检查测试覆盖率

```markdown
检查 {功能名称} 的测试覆盖率：

1. 运行 pnpm vitest run --coverage
2. 识别未覆盖的代码
3. 补充测试以提高覆盖率到 80% 以上
```

### 调试失败测试

```markdown
测试 {test-name} 失败了。请：

1. 运行测试查看详细错误信息
2. 分析失败原因（测试错误 or 实现错误）
3. 修复问题
4. 确保所有测试通过
```

---

## 下一步

完成 TDD 循环后，可以：

1. **继续到实现**: 运行 `/oks-implementation $ARGUMENTS` 实现服务层
2. **验证覆盖率**: 运行 `pnpm vitest run --coverage`
3. **运行所有测试**: 运行 `pnpm vitest run`

---

## 参考资源

- [TDD 最佳实践](https://testdriven.io/test-driven-development/)
- [单元测试指南](https://testingjavascript.com/)
- [重构指南](https://refactoring.guru/)
