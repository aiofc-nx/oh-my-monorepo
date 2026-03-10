---
title: 用 TanStack Router Loader 获取数据
impact: CRITICAL
impactDescription: 消除瀑布并支持并行加载
tags: router, loaders, data-fetching, parallel
---

## 用 TanStack Router Loader 获取数据

在 TanStack Start 中，优先把服务端数据获取放到 Router Loader，而不是页面内部临时串行请求。

- 统一通过 `queryClient.ensureQueryData` 读取并复用缓存。
- 多资源加载时用 `Promise.all` 并行化。
- 结合 `pendingComponent/errorComponent/preload` 完整处理加载与失败状态。
