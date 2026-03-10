---
title: 乐观更新
impact: MEDIUM
impactDescription: 提供即时 UI 反馈
tags: query, tanstack-query, optimistic-updates, mutation
---

## 乐观更新

在服务端响应前先更新 UI，若失败再回滚，可显著改善交互体感速度。

- `onMutate`：取消进行中查询、保存快照、写入乐观缓存。
- `onError`：基于快照回滚并提示用户。
- `onSettled`：最终失效查询，与服务端状态重新对齐。
