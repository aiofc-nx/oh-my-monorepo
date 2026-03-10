---
title: 为重复查找建立索引 Map
impact: LOW-MEDIUM
impactDescription: 1M 操作降到 2K 操作
tags: javascript, map, indexing, optimization, performance
---

## 为重复查找建立索引 Map

当你反复按同一个 key 查找对象时，用 `Map` 替代多次 `.find()`。

- 错误模式：每次查找都是 O(n)。
- 正确模式：先构建 `Map`（O(n)），后续查找 O(1)。
- 特别适合“列表关联列表”的映射场景。
