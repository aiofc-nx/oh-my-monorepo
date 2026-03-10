---
title: 使用 Set/Map 做 O(1) 查找
impact: LOW-MEDIUM
impactDescription: O(n) 降到 O(1)
tags: javascript, set, map, data-structures, performance
---

## 使用 Set/Map 做 O(1) 查找

当存在大量“是否包含”判断时，应先把数组转换成 `Set/Map`。

- 错误模式：在循环中反复 `includes`。
- 正确模式：`new Set(...)` 后使用 `has(...)`。
- 在大数据量过滤时效果显著。
