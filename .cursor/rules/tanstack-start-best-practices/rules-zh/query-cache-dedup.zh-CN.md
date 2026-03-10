---
title: 查询缓存去重
impact: HIGH
impactDescription: 自动请求去重并降低网络负载
tags: query, tanstack-query, caching, deduplication
---

## 查询缓存去重

TanStack Query 会对相同 `queryKey` 自动去重，多组件并发读取同一数据时只发一次请求。

- 建议使用 Query Key Factory 保持 key 一致性。
- 利用 `initialData/placeholderData` 复用已有缓存。
- 结合精确失效与批量更新，保持缓存正确且高效。
