---
title: 基于依赖关系并行化
impact: CRITICAL
impactDescription: 2-10× 性能提升
tags: async, parallelization, dependencies, better-all
---

## 基于依赖关系并行化

当任务只有“部分依赖”时，不应简单串行或粗粒度 `Promise.all`。使用 `better-all` 可以让每个任务在最早可执行时刻启动。

- 错误模式：`profile` 无谓等待 `config`。
- 正确模式：`user`、`config` 先并行，`profile` 仅依赖 `user`。
- 参考：`https://github.com/shuding/better-all`
