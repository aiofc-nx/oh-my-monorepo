---
title: 在循环中缓存属性访问
impact: LOW-MEDIUM
impactDescription: 减少重复查找
tags: javascript, loops, optimization, caching
---

## 在循环中缓存属性访问

在热路径循环中，把深层属性和数组长度提前缓存到局部变量。

- 错误模式：每次迭代都访问 `obj.a.b.c` 与 `arr.length`。
- 正确模式：循环前 `const value = ...`、`const len = ...`。
- 能减少属性链解析与边界检查开销。
