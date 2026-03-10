---
title: 使用懒初始化状态
impact: MEDIUM
impactDescription: 避免每次渲染重复计算
tags: react, hooks, useState, performance, initialization
---

## 使用懒初始化状态

初始化值计算昂贵时，给 `useState` 传函数而不是直接传结果。

- 错误模式：`useState(expensive())` 每次渲染都执行 `expensive()`。
- 正确模式：`useState(() => expensive())` 仅首渲染执行一次。
- 典型场景：读取本地存储、构建索引、重型数据转换。
