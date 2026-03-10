---
title: 缓存 Storage API 读取
impact: LOW-MEDIUM
impactDescription: 减少昂贵同步 I/O
tags: javascript, localStorage, storage, caching, performance
---

## 缓存 Storage API 读取

`localStorage`、`sessionStorage`、`document.cookie` 都是同步且昂贵的读取。应在内存中缓存访问结果。

- 用 `Map` 缓存 key-value，并在写入时保持同步。
- 监听 `storage`、`visibilitychange` 等事件做失效处理。
- 适合频繁读取配置、主题、登录态等场景。
