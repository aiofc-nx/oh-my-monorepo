---
title: 避免 Barrel 文件导入
impact: CRITICAL
impactDescription: 降低导入开销并加快构建
tags: bundle, imports, tree-shaking, barrel-files, performance
---

## 避免 Barrel 文件导入

优先从具体源文件直接导入，而不是从 `index` 这类 barrel 入口导入，以减少无用模块加载。

- 错误模式：`import { X } from 'pkg'` 触发大量重导出解析。
- 正确模式：`import X from 'pkg/path/to/X'` 精确导入。
- Next.js 13.5+ 可用 `optimizePackageImports` 自动改写导入路径。
