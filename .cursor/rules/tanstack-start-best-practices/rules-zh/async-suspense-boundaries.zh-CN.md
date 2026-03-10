---
title: 有策略地放置 Suspense 边界
impact: HIGH
impactDescription: 更快首屏渲染
tags: async, suspense, streaming, layout-shift
---

## 有策略地放置 Suspense 边界

不要在页面顶层组件先 `await` 数据再返回 JSX。应把异步读取下沉到需要数据的子组件，并用 `Suspense` 包裹。

- 这样 Sidebar/Header/Footer 可先渲染，数据区稍后流式到达。
- 可共享同一个 promise，避免重复请求。
- 需权衡：更快首屏 vs 可能布局抖动（layout shift）。
