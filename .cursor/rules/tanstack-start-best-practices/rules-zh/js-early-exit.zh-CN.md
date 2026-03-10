---
title: 使用函数早返回
impact: LOW-MEDIUM
impactDescription: 避免不必要计算
tags: javascript, functions, optimization, early-return
---

## 使用函数早返回

当结果已经确定时尽早 `return`，不要继续执行无意义逻辑。

- 错误模式：发现错误后仍继续检查剩余项。
- 正确模式：命中首个错误即返回结果。
- 代码更快也更清晰，且更易维护。
