---
title: 使用显式条件渲染
impact: LOW
impactDescription: 防止渲染 0 或 NaN
tags: rendering, conditional, jsx, falsy-values
---

## 使用显式条件渲染

当条件值可能是 `0`、`NaN` 等可渲染假值时，优先用三元表达式 `? :`，不要直接用 `&&`。

- 错误模式：`count && <Badge />` 可能渲染出 `0`。
- 正确模式：`count > 0 ? <Badge /> : null`。
- 可避免隐藏的显示错误。
