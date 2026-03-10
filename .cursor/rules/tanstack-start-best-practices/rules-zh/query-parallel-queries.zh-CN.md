---
title: 使用 TanStack Query 并行查询
impact: HIGH
impactDescription: 消除瀑布加载并显著提速
tags: query, tanstack-query, parallel, data-fetching
---

## 使用 TanStack Query 并行查询

多个独立请求应并行执行，而不是顺序执行。

- 组件层用 `useQueries/useSuspenseQueries`。
- Loader 层用 `Promise.all + ensureQueryData`。
- 对部分失败单独处理，避免一个请求失败拖垮整个页面。
