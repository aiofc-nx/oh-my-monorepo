---
title: 订阅派生状态而非原始连续值
impact: MEDIUM
impactDescription: 降低重渲染频率
tags: rerender, derived-state, media-query, optimization
---

## 订阅派生状态而非原始连续值

对“是否移动端”这类二值判断，应直接订阅布尔派生结果，而非持续变化的宽度值。

- 错误模式：订阅 `width`，每个像素变化都重渲染。
- 正确模式：订阅 `useMediaQuery(...)` 的布尔值。
- 可显著减少无意义更新。
