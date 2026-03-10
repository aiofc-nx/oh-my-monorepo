---
description: 阶段五 - 代码质量与性能优化
agent: build
argument-hint: '<功能名称> [--focus=<优化维度>]'
---

# 阶段五：代码优化

提升代码质量和性能。

---

## 当前任务

功能名称: **$ARGUMENTS**

## 项目上下文

当前分支: !`git branch --show-current`
测试覆盖率: !`pnpm vitest run --coverage 2>&1 | grep "All files" || echo "未运行覆盖率测试"`

---

## 优化维度

| 维度         | 目标             | 优先级 |
| ------------ | ---------------- | ------ |
| **性能优化** | 响应时间 < 200ms | 高     |
| **代码质量** | 重复率 < 5%      | 高     |
| **架构优化** | 耦合度 < 0.3     | 中     |
| **安全加固** | 0 安全漏洞       | 高     |

---

## 执行步骤

### 1. 性能分析

#### 1.1 识别性能瓶颈

```bash
# 运行性能分析
pnpm vitest run --coverage

# 分析 Bundle 大小
pnpm build --analyze

# 检测内存泄漏
node --inspect-brk dist/main.js
```

#### 1.2 常见性能问题

| 问题           | 症状               | 解决方案 |
| -------------- | ------------------ | -------- |
| **N+1 查询**   | 循环中查询数据库   | 批量查询 |
| **重复计算**   | 相同计算执行多次   | 缓存结果 |
| **大对象创建** | 频繁创建大对象     | 对象池   |
| **同步阻塞**   | 同步操作阻塞主线程 | 异步处理 |

### 2. 代码质量优化

#### 2.1 检测代码重复

```bash
# 检测重复代码
pnpm jscpd src/

# 检测循环依赖
pnpm madge --circular src/

# 检测代码复杂度
pnpm eslint src/ --rule complexity
```

#### 2.2 常见代码质量问题

| 问题         | 检测方法 | 解决方案     |
| ------------ | -------- | ------------ |
| **代码重复** | jscpd    | 提取公共方法 |
| **复杂度高** | eslint   | 拆分方法     |
| **循环依赖** | madge    | 重构依赖关系 |
| **魔法数字** | 代码审查 | 提取常量     |

### 3. 架构优化

#### 3.1 检查架构问题

```bash
# 检查依赖方向
pnpm dependency-cruiser --validate

# 检查模块边界
pnpm ls-lint
```

#### 3.2 常见架构问题

| 问题         | 症状                 | 解决方案     |
| ------------ | -------------------- | ------------ |
| **反向依赖** | 领域层依赖基础设施层 | 依赖倒置     |
| **循环依赖** | 模块相互依赖         | 引入中间层   |
| **职责不清** | 类承担过多职责       | 单一职责原则 |
| **过度耦合** | 模块紧密耦合         | 依赖注入     |

### 4. 安全加固

#### 4.1 安全检查清单

- [ ] 输入验证（所有用户输入）
- [ ] 输出编码（防止 XSS）
- [ ] SQL 注入防护（使用参数化查询）
- [ ] CSRF 防护（Token 验证）
- [ ] 权限检查（所有敏感操作）
- [ ] 敏感数据加密（密码、Token）
- [ ] 日志脱敏（不记录敏感信息）

#### 4.2 常见安全问题

| 问题         | 风险     | 解决方案   |
| ------------ | -------- | ---------- |
| **SQL 注入** | 数据泄露 | 参数化查询 |
| **XSS**      | 脚本执行 | 输出编码   |
| **CSRF**     | 伪造请求 | Token 验证 |
| **弱密码**   | 账户被盗 | 强密码策略 |
| **明文存储** | 数据泄露 | 加密存储   |

---

## 优化示例

imports { Injectable } from '@nestjs/common';

@Injectable()
export class CachedTokenService extends TokenService {
private cache = new Map<string, CachedToken>();

generate(payload: TokenPayload, expiresIn: number): string {
const token = super.generate(payload, expiresIn);
this.cache.set(token, {
payload,
expiresAt: Date.now() + expiresIn,
});
return token;
}

verify(token: string): TokenPayload | null {
const cached = this.cache.get(token);

    if (cached && cached.expiresAt > Date.now()) {
      return cached.payload;
    }

    // 缓存过期或不存在，从父类验证
    const payload = super.verify(token);

    if (payload) {
      this.cache.set(token, {
        payload,
        expiresAt: Date.now() + 24 * 60 * 60 * 1000, // 1 天
      });
    }

    return payload;

}

invalidate(token: string): void {
this.cache.delete(token);
}
}

interface CachedToken {
payload: TokenPayload;
expiresAt: number;
}

````

**效果**: Token 验证从 50ms → 5ms（提升 90%）

### 示例 2: 批量查询优化

**优化前**: N+1 查询
```typescript
async getOrderDetails(orderIds: string[]): Promise<OrderDetail[]> {
  const details: OrderDetail[] = [];

  for (const id of orderIds) {
    const order = await this.orderRepo.findById(id); // N 次查询
    const items = await this.itemRepo.findByOrderId(id); // N 次查询
    details.push({ order, items });
  }

  return details;
}
````

**优化后**: 批量查询

```typescript
async getOrderDetails(orderIds: string[]): Promise<OrderDetail[]> {
  // 1. 批量获取订单（1 次查询）
  const orders = await this.orderRepo.findByIds(orderIds);
  const orderMap = new Map(orders.map(o => [o.id, o]));

  // 2. 批量获取订单项（1 次查询）
  const allItems = await this.itemRepo.findByOrderIds(orderIds);
  const itemsByOrderId = this.groupItemsByOrderId(allItems);

  // 3. 在内存中组装
  return orderIds.map(id => ({
    order: orderMap.get(id)!,
    items: itemsByOrderId.get(id) || [],
  }));
}

private groupItemsByOrderId(items: OrderItem[]): Map<string, OrderItem[]> {
  const grouped = new Map<string, OrderItem[]>();

  for (const item of items) {
    const orderId = item.orderId;
    if (!grouped.has(orderId)) {
      grouped.set(orderId, []);
    }
    grouped.get(orderId)!.push(item);
  }

  return grouped;
}
```

**效果**: 2N 次查询 → 2 次查询（性能提升 90%+）

### 示例 3: 代码重复消除

**优化前**: 重复的验证逻辑

```typescript
async createOrder(props: CreateOrderProps) {
  if (!props.customerId) throw new Error('客户ID不能为空');
  if (!props.items?.length) throw new Error('订单项不能为空');
  // ...
}

async updateOrder(props: UpdateOrderProps) {
  if (!props.customerId) throw new Error('客户ID不能为空');
  if (!props.items?.length) throw new Error('订单项不能为空');
  // ...
}
```

**优化后**: 提取验证器

```typescript
class OrderValidator {
  static validateCustomer(customerId: string): void {
    if (!customerId?.trim()) {
      throw new ValidationError('客户ID不能为空', 'customerId');
    }
  }

  static validateItems(items: OrderItem[]): void {
    if (!items?.length) {
      throw new ValidationError('订单项不能为空', 'items');
    }
  }

  static validate(props: OrderProps): void {
    this.validateCustomer(props.customerId);
    this.validateItems(props.items);
  }
}

async createOrder(props: CreateOrderProps) {
  OrderValidator.validate(props);
  // ...
}

async updateOrder(props: UpdateOrderProps) {
  OrderValidator.validate(props);
  // ...
}
```

**效果**: 代码重复率从 15% → 2%

---

## 优化工具

```bash
# 性能分析
pnpm vitest run --coverage
pnpm build --analyze

# 代码质量
pnpm jscpd src/              # 重复代码检测
pnpm madge --circular src/  # 循环依赖检测
pnpm eslint src/            # 代码检查

# 架构检查
pnpm dependency-cruiser --validate
pnpm ls-lint

# 安全检查
pnpm audit
pnpm snyk test
```

---

## 优化检查清单

- [ ] 已进行性能分析，识别瓶颈
- [ ] 消除 N+1 查询问题
- [ ] 消除重复代码（重复率 < 5%）
- [ ] 添加必要的缓存策略
- [ ] 异步处理非关键路径
- [ ] 安全检查完成（输入验证、权限控制）
- [ ] 代码复杂度在可接受范围内（< 10）
- [ ] 无循环依赖
- [ ] 无内存泄漏

---

## 阶段完成条件

- [ ] 性能提升 > 20%（或满足业务要求）
- [ ] 代码重复率 < 5%
- [ ] 代码复杂度 < 10
- [ ] 无安全漏洞
- [ ] 无循环依赖
- [ ] 测试覆盖率 > 80%
- [ ] 所有测试通过

---

## 常见问题

### Q: 什么时候该优化？

A: **先测量，再优化**

1. 运行性能分析工具
2. 识别真正的瓶颈
3. 针对性优化
4. 验证优化效果

### Q: 优化会不会引入 Bug？

A: **优化时保持测试通过**

1. 每次小改动后运行测试
2. 确保所有测试仍然通过
3. 保持功能不变
4. 只改结构，不改行为

### Q: 优化优先级如何确定？

A: **根据影响程度排序**

1. **安全漏洞** - 最高优先级
2. **性能瓶颈** - 影响用户体验
3. **代码质量** - 影响可维护性
4. **架构问题** - 影响扩展性

---

## 下一步

完成代码优化后，可以：

1. **提交代码**: 运行 `git add . && git commit` 提交优化后的代码
2. **创建 PR**: 运行 `gh pr create` 创建 Pull Request
3. **运行完整测试**: 运行 `pnpm vitest run` 确保所有测试通过

---

## 参考资源

- [性能优化指南](https://web.dev/performance/)
- [代码重构技巧](https://refactoring.guru/)
- [安全最佳实践](https://owasp.org/)
- [代码质量指标](https://docs.codeclimate.com/docs/)
