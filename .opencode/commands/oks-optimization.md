---
description: 代码优化和性能调优
agent: build
argument-hint: '<功能名称>'
---

## ⚠️ 参数验证

!`if [ -z "$ARGUMENTS" ]; then
  echo "❌ **错误: 缺少功能名称**"
  echo ""
  echo "**用法**: /oks-optimization <功能名称>"
  echo ""
  echo "**示例**: /oks-optimization 用户登录"
  exit 1
fi`

---

## 🔒 前置条件检查

!`

# 使用统一的前置检查脚本

RESULT=$(bash oks-coding-system/scripts/check-prerequisites.sh --json --stage=optimization --feature="$ARGUMENTS" 2>&1)
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
echo " /oks-implementation $ARGUMENTS"
exit 1
fi
`

---

# 代码优化

提升代码质量和性能。

---

## 当前任务

功能名称: **$ARGUMENTS**

## 项目上下文

当前分支: !`git branch --show-current`
测试覆盖率: !`pnpm vitest run --coverage 2>&1 | grep "All files" || echo "未运行覆盖率测试"`
模块文件数: !`find src/modules -name "*.ts" -type f 2>/dev/null | wc -l | xargs -I {} echo "{} 个文件" || echo "0 个文件"`

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

# 检查设计文档中的性能目标

if [ -n "$PROJECT_NAME" ] && [ -f "$REPO_ROOT/<project>/docs/specify/$PROJECT_NAME/$ARGUMENTS.md" ]; then
echo "**技术设计**: ✅ <project>/docs/specify/$PROJECT_NAME/$ARGUMENTS.md"
echo ""
echo "从设计文档中获取性能目标："
grep -A 5 "性能目标\|性能设计" "$REPO_ROOT/<project>/docs/specify/$PROJECT_NAME/$ARGUMENTS.md" 2>/dev/null | head -10 || echo "- 未找到性能目标定义"
elif [ -f "$REPO_ROOT/<project>/docs/specify/$ARGUMENTS.md" ]; then
    echo "**技术设计**: ✅ <project>/docs/specify/$ARGUMENTS.md"
else
echo "**技术设计**: ⚠️ 不存在"
fi
`

---

## ⚠️ 优化前必须完成

> **重要**: 优化前必须确保所有测试通过，否则无法验证优化是否引入问题

!`echo "**测试状态检查**:"
if pnpm vitest run 2>&1 | grep -q "passed"; then
    echo "✅ 所有测试通过，可以开始优化"
else
    echo "❌ 存在失败测试，请先修复后再优化"
    echo ""
    echo "运行: pnpm vitest run 查看详情"
fi`

---

## 优化维度

| 维度         | 目标             | 优先级 |
| ------------ | ---------------- | ------ |
| **性能优化** | 响应时间 < 200ms | 高     |
| **代码质量** | 重复率 < 5%      | 高     |
| **架构优化** | 耦合度 < 0.3     | 中     |
| **安全加固** | 0 安全漏洞       | 高     |

> **性能目标来源**: 从设计文档 `<project>/docs/specify/{project}/{feature}.md` 的"性能设计"章节获取

---

## 📊 优化基准记录

> **重要**: 优化前必须记录基准数据，用于对比优化效果

### 优化前基准

| 指标         | 优化前值  | 优化后值  | 改善幅度 |
| ------------ | --------- | --------- | -------- |
| API 响应时间 | \_\_\_ ms | \_\_\_ ms | \_\_\_%  |
| 测试覆盖率   | \_\_\_%   | \_\_\_%   | \_\_\_%  |
| 代码重复率   | \_\_\_%   | \_\_\_%   | \_\_\_%  |
| 代码复杂度   | \_\_\_    | \_\_\_    | \_\_\_%  |
| Bundle 大小  | \_\_\_ KB | \_\_\_ KB | \_\_\_%  |

### 记录命令

```bash
# 记录优化前基准
echo "## 优化前基准 ($(date '+%Y-%m-%d %H:%M'))" > optimization-baseline.md
echo "" >> optimization-baseline.md
echo "| 指标 | 值 |" >> optimization-baseline.md
echo "|------|----|" >> optimization-baseline.md

# 测试覆盖率
COVERAGE=$(pnpm vitest run --coverage 2>&1 | grep "All files" | awk '{print $NF}')
echo "| 测试覆盖率 | $COVERAGE |" >> optimization-baseline.md

# 文件数和行数
FILES=$(find src/modules -name "*.ts" | wc -l)
LINES=$(find src/modules -name "*.ts" -exec cat {} \; | wc -l)
echo "| 文件数 | $FILES |" >> optimization-baseline.md
echo "| 代码行数 | $LINES |" >> optimization-baseline.md

echo "基准已记录到 optimization-baseline.md"
```

---

## 执行步骤

### 1. 性能分析

#### 1.0 工具检查

!`
echo "**工具可用性检查**:"
echo ""

# 检查基础工具

if command -v pnpm &> /dev/null; then
echo "✅ pnpm"
else
echo "❌ pnpm - 请先安装"
fi

# 检查可选工具

if command -v jscpd &> /dev/null; then
echo "✅ jscpd (重复代码检测)"
else
echo "⚠️ jscpd - 未安装，可选: pnpm add -g jscpd"
fi

if command -v madge &> /dev/null; then
echo "✅ madge (循环依赖检测)"
else
echo "⚠️ madge - 未安装，可选: pnpm add -g madge"
fi

if command -v dependency-cruiser &> /dev/null; then
echo "✅ dependency-cruiser"
else
echo "⚠️ dependency-cruiser - 未安装，可选"
fi
`

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
pnpm biome check src/ --linter-enabled=true
```

#### 2.2 常见代码质量问题

| 问题         | 检测方法 | 解决方案     |
| ------------ | -------- | ------------ |
| **代码重复** | jscpd    | 提取公共方法 |
| **复杂度高** | biome    | 拆分方法     |
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

| 问题         | 症状           | 解决方案     |
| ------------ | -------------- | ------------ |
| **循环依赖** | 模块相互依赖   | 引入中间层   |
| **职责不清** | 类承担过多职责 | 单一职责原则 |
| **过度耦合** | 模块紧密耦合   | 依赖注入     |
| **层级混乱** | 跨层级直接调用 | 明确分层边界 |

### 4. 安全加固

#### 4.0 优化过程测试验证

> ⚠️ **每项优化后必须运行测试**

```bash
# 每次优化改动后运行
pnpm vitest run

# 如果测试失败，立即回滚
git checkout -- <modified-file>
```

**验证流程**:

1. 记录优化前基准
2. 执行一项优化
3. 运行测试 → 必须通过
4. 记录优化后数据
5. 对比效果，决定是否保留

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

### 示例 1: 缓存优化

```typescript
import { Injectable } from '@nestjs/common';

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
```

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
```

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
      throw new Error('客户ID不能为空');
    }
  }

  static validateItems(items: OrderItem[]): void {
    if (!items?.length) {
      throw new Error('订单项不能为空');
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
pnpm biome check src/       # 代码检查

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

## 💬 常用提示词

### 性能审查

```markdown
审查 {功能名称} 的性能：

1. 是否有 N+1 查询问题？
2. 是否有不必要的重复计算？
3. 是否可以添加缓存？
4. 响应时间是否满足要求（< 200ms）？
5. 是否有内存泄漏风险？
```

### 优化性能

```markdown
优化 {功能名称} 的性能：

1. 运行性能分析，识别瓶颈
2. 消除 N+1 查询
3. 添加缓存
4. 异步处理非关键路径
5. 验证性能提升（目标 > 20%）
6. 确保所有测试通过
```

### 代码重构

```markdown
重构 {模块名} 以提高代码质量：

1. 检查代码复杂度（目标 < 10）
2. 检查代码重复（目标 < 5%）
3. 拆分过长的方法（> 20 行）
4. 提取重复代码到公共方法
5. 改善命名
6. 确保所有测试仍然通过
```

### 安全审查

```markdown
审查 {功能名称} 的安全性：

1. **输入验证**: 所有用户输入是否验证？
2. **权限检查**: 是否有权限控制？
3. **敏感数据**: 敏感数据是否加密？
4. **SQL 注入**: 是否使用参数化查询？
5. **XSS**: 是否对输出进行编码？
6. **CSRF**: 是否有 CSRF 防护？
```

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
