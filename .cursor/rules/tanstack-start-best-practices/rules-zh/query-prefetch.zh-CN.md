---
title: Query 预取策略
impact: HIGH
impactDescription: 接近即时导航与更好体验
tags: query, tanstack-query, prefetch, performance
---

## Query 预取策略

在用户真正进入页面前预取数据，可显著降低体感等待。

- 常见触发：悬停、聚焦、元素进入视口、路由加载。
- 可结合网络状态与行为信号做“智能预取”，避免过度预取。
- 合理设置 `staleTime`，让预取结果在短期内可直接命中。
