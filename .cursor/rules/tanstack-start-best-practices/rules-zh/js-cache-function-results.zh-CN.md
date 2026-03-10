---
title: 缓存重复函数调用结果
impact: MEDIUM
impactDescription: 避免重复计算
tags: javascript, cache, memoization, performance
---

## 缓存重复函数调用结果

对于同参数会被频繁调用的函数，可在模块级用 `Map` 缓存结果。

- 典型场景：渲染列表时重复执行 `slugify`、格式化函数等。
- 读取命中缓存可直接返回，未命中才计算并写入。
- 外部状态变化时需主动失效缓存。
