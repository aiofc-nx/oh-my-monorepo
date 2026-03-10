---
title: 路由预取策略
impact: HIGH
impactDescription: 降低感知延迟并接近即时导航
tags: router, prefetch, performance, user-experience
---

## 路由预取策略

在用户真正点击前预取路由资源和数据，可显著缩短跳转等待。

- 推荐优先使用 `Link preload="intent"`。
- 对关键路径补充 `router.preloadRoute()` 手动预取。
- 结合悬停、聚焦、视口进入等触发时机，并控制预取数量避免浪费。
