---
title: 用 Promise.all 执行独立异步操作
impact: CRITICAL
impactDescription: 2-10× 性能提升
tags: async, parallelization, promises, waterfalls
---

## 用 Promise.all 执行独立异步操作

当多个异步请求彼此独立时，应并发执行。

- 错误模式：多个 `await` 串行，形成瀑布流。
- 正确模式：`Promise.all([...])` 一次并发发起。
- 常见收益：减少总等待时长，降低首屏和交互延迟。
