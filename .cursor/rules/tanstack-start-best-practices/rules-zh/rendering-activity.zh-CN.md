---
title: 显隐场景使用 Activity 组件
impact: MEDIUM
impactDescription: 保留状态与 DOM
tags: rendering, activity, visibility, state-preservation
---

## 显隐场景使用 Activity 组件

对于频繁开关且渲染代价高的 UI，使用 `<Activity>` 在隐藏时保留状态与 DOM。

- 避免重复挂载带来的性能损耗。
- 防止内部状态丢失（滚动位置、输入内容等）。
- 适合菜单、抽屉、复杂面板等组件。
