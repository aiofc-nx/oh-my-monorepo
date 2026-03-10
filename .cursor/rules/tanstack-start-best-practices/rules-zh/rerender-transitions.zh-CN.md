---
title: 非紧急更新使用 Transition
impact: MEDIUM
impactDescription: 保持 UI 响应流畅
tags: rerender, transitions, startTransition, performance
---

## 非紧急更新使用 Transition

把高频但非关键的状态更新（如滚动位置、次要筛选）放进 `startTransition`。

- 可降低更新对主交互的阻塞。
- 高频事件中体感更平滑。
- 与防抖/节流可配合使用。
