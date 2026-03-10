---
title: 提升静态 JSX 元素
impact: LOW
impactDescription: 避免重复创建
tags: rendering, jsx, static, optimization
---

## 提升静态 JSX 元素

把静态 JSX 抽到组件外部，避免每次渲染重新创建相同节点。

- 对大体积静态 SVG 或骨架节点收益明显。
- 如已启用 React Compiler，很多场景会自动优化。
- 原则：静态内容外提，动态内容留在组件内。
