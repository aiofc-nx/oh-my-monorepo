---
title: 路由生命周期钩子
impact: MEDIUM
impactDescription: 支持非阻塞操作并提升体验
tags: router, lifecycle, hooks, server-functions
---

## 路由生命周期钩子

利用 `beforeLoad/loader/onEnter/useBlocker` 等机制，把权限、数据加载、埋点和离开确认放到合适阶段。

- 核心请求应保证主流程返回速度，日志/通知可改为非阻塞后台执行。
- 在 `beforeLoad` 做认证与重定向，避免无效加载。
- 用错误边界和加载态组件完善导航体验。
