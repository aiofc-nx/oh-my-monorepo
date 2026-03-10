---
title: 基于路由的代码分割
impact: CRITICAL
impactDescription: 减少初始包体并提升 TTI
tags: router, code-splitting, lazy-loading, performance
---

## 基于路由的代码分割

TanStack Router 支持路由级分割，能显著降低首包体积。

- 文件路由天然分割；重组件再用 `React.lazy + Suspense` 做二级分割。
- 可配合 `router.preloadRoute` 在用户意图出现时预加载。
- 建议对编辑器、图表、富文本等重模块按需加载。
