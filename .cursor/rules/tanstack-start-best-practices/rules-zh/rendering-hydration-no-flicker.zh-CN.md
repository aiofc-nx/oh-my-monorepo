---
title: 无闪烁地避免 Hydration 不匹配
impact: MEDIUM
impactDescription: 避免视觉闪烁与 hydration 错误
tags: rendering, ssr, hydration, localStorage, flicker
---

## 无闪烁地避免 Hydration 不匹配

当 UI 依赖 `localStorage/cookie` 等仅客户端数据时，应避免 SSR 崩溃与水合后闪烁。

- 不要在服务端渲染阶段直接访问 `localStorage`。
- 不要只靠 `useEffect` 事后修正主题，会出现“先错后对”闪烁。
- 可在 hydration 前注入同步脚本，先把 DOM 修正到正确状态。
