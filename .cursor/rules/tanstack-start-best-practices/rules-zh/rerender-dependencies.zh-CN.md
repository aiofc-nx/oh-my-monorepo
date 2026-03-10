---
title: 收窄 Effect 依赖项
impact: LOW
impactDescription: 减少 effect 重跑
tags: rerender, useEffect, dependencies, optimization
---

## 收窄 Effect 依赖项

`useEffect` 依赖应尽量使用原始值（如 `user.id`），避免依赖整个对象导致不必要重跑。

- 错误模式：`[user]`。
- 正确模式：`[user.id]`。
- 对阈值类逻辑可先派生布尔值，再将布尔值作为依赖。
