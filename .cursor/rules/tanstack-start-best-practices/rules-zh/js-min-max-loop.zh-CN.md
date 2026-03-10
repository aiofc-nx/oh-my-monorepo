---
title: 求最值用循环而非排序
impact: LOW
impactDescription: O(n) 替代 O(n log n)
tags: javascript, arrays, performance, sorting, algorithms
---

## 求最值用循环而非排序

只需要最小/最大值时，不要对整个数组排序。

- 错误模式：排序后取首项/末项。
- 正确模式：单次遍历维护 `min/max`。
- 好处：更快、无拷贝、无多余排序开销。
