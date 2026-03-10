---
title: 使用 setState 函数式更新
impact: MEDIUM
impactDescription: 避免闭包陈旧并减少回调重建
tags: react, hooks, useState, useCallback, callbacks, closures
---

## 使用 setState 函数式更新

当新状态依赖旧状态时，应使用 `setState(curr => ...)`。

- 可避免遗漏依赖导致的 stale closure。
- 让 `useCallback` 更稳定，减少子组件无效重渲染。
- 特别适用于列表增删改、异步回调中的状态更新。
