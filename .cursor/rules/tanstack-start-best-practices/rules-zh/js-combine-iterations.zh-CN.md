---
title: 合并多次数组遍历
impact: LOW-MEDIUM
impactDescription: 减少遍历次数
tags: javascript, arrays, loops, performance
---

## 合并多次数组遍历

多个 `.filter()`/`.map()` 连用会重复遍历同一数组。若逻辑相关，尽量合并为一次循环。

- 错误模式：对同一数组做多次条件筛选。
- 正确模式：单次 `for...of` 内按条件分别 `push`。
- 在大数组和高频场景下收益更明显。
