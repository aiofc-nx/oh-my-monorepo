---
title: 延迟 await 到真正需要时
impact: HIGH
impactDescription: 避免阻塞不需要的分支
tags: async, await, conditional, optimization
---

## 延迟 await 到真正需要时

把 `await` 放进实际会使用结果的分支中，避免无关路径被阻塞。

- 错误模式：函数一开始就 `await`，即使后续可能早返回。
- 正确模式：先判断是否需要该数据，再执行 `await`。
- 当“跳过分支”命中率高或被延迟操作开销大时，收益最明显。
