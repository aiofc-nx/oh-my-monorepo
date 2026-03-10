---
title: 抽离为可记忆化组件
impact: MEDIUM
impactDescription: 允许早返回并减少无效计算
tags: rerender, memo, useMemo, optimization
---

## 抽离为可记忆化组件

把昂贵计算从父组件抽离到 `memo` 子组件中，可在父组件早返回时跳过计算。

- 错误模式：父组件中先 `useMemo` 计算，再判断 loading。
- 正确模式：`if (loading) return ...` 后再渲染记忆化子组件。
- 若启用 React Compiler，部分手动记忆化可由编译器接管。
