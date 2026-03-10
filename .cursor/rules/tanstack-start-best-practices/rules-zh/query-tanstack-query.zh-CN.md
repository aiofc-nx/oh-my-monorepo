---
title: 使用 TanStack Query 替代 SWR
impact: MEDIUM-HIGH
impactDescription: 自动去重与更强缓存能力
tags: query, tanstack-query, data-fetching, caching
---

## 使用 TanStack Query 替代 SWR

在 TanStack Start 项目中，数据获取首选 TanStack Query（React Query）。

- 统一使用 `useQuery/useMutation` 与结构化 `queryKey`。
- 充分利用自动请求去重、预取、并行查询、乐观更新与 DevTools。
- 与 Router Loader 结合可进一步消除瀑布并提升导航体验。
