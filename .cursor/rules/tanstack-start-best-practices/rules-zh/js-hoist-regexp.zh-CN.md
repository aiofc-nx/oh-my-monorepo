---
title: 提升 RegExp 创建位置
impact: LOW-MEDIUM
impactDescription: 避免重复创建
tags: javascript, regexp, optimization, memoization
---

## 提升 RegExp 创建位置

不要在渲染过程中反复 `new RegExp(...)`。应提升到模块作用域，或在组件内用 `useMemo`。

- 动态正则：随依赖变化再重建。
- 静态正则：模块级常量一次创建。
- 注意：带 `/g` 的全局正则有可变 `lastIndex` 状态。
