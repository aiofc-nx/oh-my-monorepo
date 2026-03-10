---
title: 长列表使用 CSS content-visibility
impact: HIGH
impactDescription: 提升初始渲染速度
tags: rendering, css, content-visibility, long-lists
---

## 长列表使用 CSS content-visibility

对长列表项设置 `content-visibility: auto`，可延后屏幕外元素的布局与绘制。

- 配合 `contain-intrinsic-size` 预留占位尺寸。
- 初始渲染时可跳过大量离屏节点计算。
- 对消息流、评论流、时间线等场景很有效。
