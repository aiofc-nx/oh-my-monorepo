---
title: 优化 SVG 精度
impact: LOW
impactDescription: 减小文件体积
tags: rendering, svg, optimization, svgo
---

## 优化 SVG 精度

适度降低 SVG 坐标小数位可减少体积，通常不影响视觉效果。

- 错误模式：保留过多小数位。
- 正确模式：按需压到 1~2 位精度。
- 可用 `svgo` 自动处理：`npx svgo --precision=1 --multipass icon.svg`。
