---
title: 把状态读取延迟到使用点
impact: MEDIUM
impactDescription: 避免无必要订阅
tags: rerender, searchParams, localStorage, optimization
---

## 把状态读取延迟到使用点

如果某个动态状态只在事件回调里读取，不要在组件渲染期订阅它。

- 错误模式：组件内先 `useSearchParams()`，导致参数变化就重渲染。
- 正确模式：点击回调里按需读取 `window.location.search`。
- 可显著减少与业务无关的重渲染。
