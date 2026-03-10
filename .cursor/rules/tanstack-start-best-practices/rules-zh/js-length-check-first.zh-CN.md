---
title: 数组比较先检查长度
impact: MEDIUM-HIGH
impactDescription: 长度不同时避免昂贵比较
tags: javascript, arrays, performance, optimization, comparison
---

## 数组比较先检查长度

在排序、深比较、序列化等昂贵比较前，先判断 `length`。

- 长度不同可直接判定“不相等/有变化”。
- 只有长度相同时再进入排序或逐项比较。
- 同时应避免修改原数组，优先用不可变方法（如 `toSorted()`）。
