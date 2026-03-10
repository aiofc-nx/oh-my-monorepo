---
title: 用 toSorted() 替代 sort() 保持不可变
impact: MEDIUM-HIGH
impactDescription: 防止 React 状态突变问题
tags: javascript, arrays, immutability, react, state, mutation
---

## 用 toSorted() 替代 sort() 保持不可变

`.sort()` 会原地修改数组，可能破坏 React 的不可变约定。优先使用 `.toSorted()` 生成新数组。

- 错误模式：在 `props/state` 上直接 `sort()`。
- 正确模式：`toSorted()` 或 `[...arr].sort(...)`。
- 可避免突变引发的闭包/渲染 bug。
