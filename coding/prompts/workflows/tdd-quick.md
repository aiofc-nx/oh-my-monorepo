---
description: 快速 TDD 工作流（US → TDD → 实现，跳过 BDD 和优化）
agent: build
argument-hint: '<功能名称>'
---

# 快速工作流：US → TDD → 实现

适合快速原型开发和迭代。

---

## 当前任务

功能名称: **$ARGUMENTS**

---

## 工作流程

```
用户故事 → TDD 循环 → 代码实现
```

**预计时间**: 1-2 小时

---

## 阶段一：用户故事（10 分钟）

参考: `workflows/stage-1-user-story.md`

**产出**: `docs/user-stories/$ARGUMENTS.md`

**简化验收标准**:

- [ ] 核心功能明确
- [ ] INVEST 原则通过

---

## 阶段二：TDD 循环（30-40 分钟）

参考: `workflows/stage-3-tdd-cycle.md`

### 2.1 编写核心测试

**文件**: `src/modules/[module]/[entity].spec.ts`

```typescript
describe('[EntityName]', () => {
  it('should create successfully', () => {
    // 核心功能测试
  });

  it('should validate input', () => {
    // 验证测试
  });
});
```

### 2.2 实现

**文件**: `src/modules/[module]/[entity].ts`

```typescript
export class Entity {
  static create(props: CreateProps): Entity {
    // 实现
  }
}
```

**产出**:

- `src/modules/[module]/[entity].spec.ts`
- `src/modules/[module]/[entity].ts`

---

## 阶段三：代码实现（20-30 分钟）

参考: `workflows/stage-4-implementation.md`

### 3.1 服务层

**文件**: `src/modules/[module]/services/[module].service.ts`

```typescript
@Injectable()
export class Service {
  async execute(dto: Dto): Promise<Result> {
    // 1. 获取数据
    // 2. 执行业务逻辑
    // 3. 保存
    // 4. 返回结果
  }
}
```

### 3.2 数据访问层

**文件**: `src/modules/[module]/repositories/[module].repository.ts`

```typescript
@Injectable()
export class Repository {
  async findById(id: string): Promise<Entity | null> {
    // 实现
  }

  async save(entity: Entity): Promise<void> {
    // 实现
  }
}
```

**产出**:

- `src/modules/[module]/services/[module].service.ts`
- `src/modules/[module]/repositories/[module].repository.ts`

---

## 验证

```bash
# 运行测试
pnpm vitest run

# 检查覆盖率
pnpm vitest run --coverage
```

**目标**: 覆盖率 > 70%

---

## 完成检查清单

- [ ] 用户故事已创建
- [ ] 核心测试通过
- [ ] 实体/模型已实现
- [ ] 服务层已实现
- [ ] 数据访问层已实现
- [ ] 所有测试通过
- [ ] 覆盖率 > 70%

---

## 与完整工作流的区别

| 项目       | 完整工作流     | 快速工作流  |
| ---------- | -------------- | ----------- |
| 用户故事   | ✅ 完整 INVEST | ✅ 简化版   |
| BDD 场景   | ✅ 5+ 场景     | ❌ 跳过     |
| TDD        | ✅ 完整循环    | ✅ 核心测试 |
| 实现       | ✅ 完整        | ✅ 核心功能 |
| 优化       | ✅ 性能+质量   | ❌ 跳过     |
| **耗时**   | 2-4 小时       | 1-2 小时    |
| **覆盖率** | > 80%          | > 70%       |

---

## 适用场景

✅ **适合**:

- 原型开发
- 快速迭代
- 简单功能
- 时间紧张

❌ **不适合**:

- 生产环境
- 复杂业务
- 质量要求高
- 安全敏感

---

## 下一步

完成快速工作流后，如果需要补充：

1. **补充 BDD**: 运行 `/stage-2-bdd $ARGUMENTS`
2. **补充优化**: 运行 `/stage-5-optimization $ARGUMENTS`
3. **完整验证**: 运行 `/workflow $ARGUMENTS` 完整流程

---

## 示例

**功能**: `用户注册`

**阶段一**: 创建 `docs/user-stories/user-registration.md`

**阶段二**:

- `src/modules/user/user.entity.spec.ts`
- `src/modules/user/user.entity.ts`

**阶段三**:

- `src/modules/user/services/user.service.ts`
- `src/modules/user/repositories/user.repository.ts`

**总耗时**: 约 1.5 小时

---

**文档版本**: v1.1
