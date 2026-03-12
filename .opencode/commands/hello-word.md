---
description: Hello Word 示例命令 - 根据名字输出问候
agent: build
argument-hint: '<name>'
---

# Hello Word 示例

## 用户输入

```text
$ARGUMENTS
```

## 处理规则

1. 如果 `$ARGUMENTS` 为空，先引导用户输入名字（例如：`请输入你的名字`）。
2. 如果 `$ARGUMENTS` 不为空，将其作为 `name`。
3. 最终只输出一行：

```text
hello <name> 加入Odoo前端重构-AI 优先 + React No OWL群
```

## 示例

- 输入：`/hello-word Tom`
- 输出：`hello Tom` 加入Odoo前端重构-AI 优先 + React No OWL群
