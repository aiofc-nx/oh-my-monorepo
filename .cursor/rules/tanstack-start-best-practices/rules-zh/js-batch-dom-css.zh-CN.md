---
title: 批量修改 DOM CSS
impact: MEDIUM
impactDescription: 减少重排与重绘
tags: javascript, dom, css, performance, reflow
---

## 批量修改 DOM CSS

避免逐条设置 `style`。应通过切换 class 或一次性写入 `cssText` 合并修改，减少浏览器 reflow。

- 错误模式：每一行 `element.style.xxx = ...`。
- 正确模式：`classList.add(...)` 或统一 `cssText`。
- 在 React 中优先用 `className` 切换。
