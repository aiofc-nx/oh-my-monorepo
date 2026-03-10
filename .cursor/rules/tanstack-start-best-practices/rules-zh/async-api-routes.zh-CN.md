---
title: 在 API 路由中避免瀑布链
impact: CRITICAL
impactDescription: 2-10× 性能提升
tags: api-routes, server-actions, waterfalls, parallelization
---

## 在 API 路由中避免瀑布链

在 API Routes 和 Server Actions 里，彼此独立的异步操作应尽早启动，即使暂时不 `await`。

- 错误模式：先 `await auth()`，再取配置，再取数据，导致串行等待。
- 正确模式：先创建 `sessionPromise` 与 `configPromise`，再按依赖关系 `await`。
- 对更复杂依赖链，使用 `better-all` 自动最大化并行度（见依赖并行规则）。
