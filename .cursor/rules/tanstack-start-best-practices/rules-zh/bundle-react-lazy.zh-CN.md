---
title: 使用 React.lazy 而非 next/dynamic
impact: CRITICAL
impactDescription: 直接影响 TTI 与 LCP
tags: bundle, dynamic-import, code-splitting, react-lazy
---

## 使用 React.lazy 而非 next/dynamic

在 TanStack Start 中应使用 `React.lazy` + `Suspense` 做代码分割，不使用 Next.js 专属的 `next/dynamic`。

- 命名导出需手动映射到 `default`。
- 建议在用户意图出现时预加载（hover/focus）。
- 适用：编辑器、图表、地图、弹窗等重组件。
