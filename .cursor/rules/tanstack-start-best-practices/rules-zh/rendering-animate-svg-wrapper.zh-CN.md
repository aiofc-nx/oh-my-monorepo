---
title: 动画应作用于 SVG 外层容器
impact: LOW
impactDescription: 更容易启用硬件加速
tags: rendering, svg, css, animation, performance
---

## 动画应作用于 SVG 外层容器

很多浏览器对 SVG 元素本体的 CSS3 动画加速有限。建议用 `<div>` 包裹 SVG，并对外层容器做动画。

- 错误模式：直接给 `<svg>` 加 `animate-spin`。
- 正确模式：给包裹 `<div>` 添加动画类。
- 适用于 `transform/opacity/translate/scale/rotate`。
