# OpenCode 开发规范文档

本目录包含 OpenCode 命令和模版系统的详细编写规范文档。

## 文档列表

### 1. [命令文件编写规范](./命令文件编写规范.md)

详细阐述 `.opencode/commands` 目录中命令文件的编写规范。

**主要内容：**

- 文件格式与编码
- Frontmatter 配置（description, agent, model, subtask 等）
- 特殊符号与占位符（$ARGUMENTS, $1, $2, Shell 命令, 文件引用）
- 配置选项详解
- 完整示例与最佳实践
- 调试与测试指南

**适用场景：**

- 创建自定义命令
- 自动化重复性任务
- 定义工作流程

### 2. [模版文件编写规范](./模版文件编写规范.md)

详细阐述模版文件的编写规范及其与命令文件的协同工作。

**主要内容：**

- 模版系统架构
- 占位符系统（通用、结构化、条件占位符）
- 注释与指令（HTML 注释、特殊标记）
- 各类模版结构规范（功能规范、实施计划、任务列表、检查清单、章程、代理文件）
- 特殊语法与标记
- 模版与命令的交互
- 完整示例与最佳实践

**适用场景：**

- 创建项目文档模版
- 定义标准化工作流
- 生成开发制品

## 快速开始

### 创建自定义命令

1. 在 `.opencode/commands/` 目录创建 Markdown 文件
2. 添加 frontmatter 配置
3. 编写提示词模板
4. 使用 `$ARGUMENTS` 接收参数

**示例：**

```markdown
---
description: 创建新组件
---

创建一个名为 $ARGUMENTS 的 React 组件，包含 TypeScript 支持和基本测试。
```

### 创建自定义模版

1. 在模版目录创建模版文件（如 `templates/`）
2. 使用 `[PLACEHOLDER]` 定义占位符
3. 使用 HTML 注释提供指导
4. 在命令文件中引用模版

**示例：**

```markdown
# 功能规范: [FEATURE NAME]

**创建时间**: [DATE]
**输入**: 用户描述: "$ARGUMENTS"

## 用户场景与测试

### 用户故事 1 - [标题] (优先级: P1)

[描述用户旅程]
```

## 系统架构

### 命令与模版的关系

```
用户输入
    ↓
命令文件 (commands/*.md)
    ↓
读取模版 (templates/*.md)
    ↓
填充占位符
    ↓
生成文档 (docs/*/...)
```

### 目录结构

```
项目根目录/
├── commands/              # 命令文件目录
│   ├── monitor-ci.md     # CI 监控命令
│   ├── create-spec.md    # 创建规范命令
│   └── ...               # 其他命令
├── templates/            # 模版文件目录
│   ├── spec-template.md  # 规范文档模版
│   ├── plan-template.md  # 计划文档模版
│   └── ...               # 其他模版
└── docs/                 # 规范文档（本目录）
    ├── README.md
    ├── 命令文件编写规范.md
    └── 模版文件编写规范.md
```

## 核心概念

### 占位符系统

| 系统       | 语法                          | 示例                 |
| ---------- | ----------------------------- | -------------------- |
| 命令参数   | `$ARGUMENTS`, `$1`, `$2`      | `/command arg1 arg2` |
| Shell 输出 | `!`command``                  | `!`git status``      |
| 文件引用   | `@filepath`                   | `@src/index.ts`      |
| 模版占位符 | `[PLACEHOLDER]`               | `[FEATURE NAME]`     |
| 条件标记   | `[NEEDS CLARIFICATION: desc]` | 需要澄清的内容       |

### 特殊标记

| 标记       | 用途             | 示例                      |
| ---------- | ---------------- | ------------------------- |
| `[P]`      | 可并行执行的任务 | `- [ ] T003 [P] 配置工具` |
| `[US#]`    | 用户故事编号     | `[US1]`                   |
| `🎯 MVP`   | MVP 标记         | 优先级最高的功能          |
| `⚠️`       | 警告             | 重要注意事项              |
| `*(必填)*` | 必填章节         | 必需的内容                |

## 工作流程示例

### 1. 功能开发流程

```bash
# 1. 创建功能规范
/create-spec 实现用户认证系统

# 2. 生成实施计划
/create-plan

# 3. 创建任务列表
/create-tasks

# 4. 执行实施
/implement
```

### 2. CI 监控流程

```bash
# 监控 CI 状态
/monitor-ci

# 带参数监控
/monitor-ci --max-cycles 5 --timeout 60 --auto-fix-workflow
```

## 最佳实践

### 命令文件

1. **清晰的描述**：提供详细的 `description`，包含触发词
2. **参数提示**：使用 `argument-hint` 说明参数用法
3. **上下文注入**：使用 Shell 命令和文件引用提供上下文
4. **结构化输出**：使用 Markdown 格式化输出内容
5. **错误处理**：处理参数为空等边界情况

### 模版文件

1. **清晰的占位符**：使用描述性的占位符名称
2. **详细的注释**：用 HTML 注释提供填充指导
3. **示例说明**：在注释中提供示例
4. **可选区块**：明确标记可选内容
5. **检查点**：添加检查点便于跟踪进度

## 常见问题

### Q: 如何调试命令？

A: 在 TUI 中输入命令并查看输出。检查：

- Frontmatter 格式是否正确
- 占位符是否被替换
- Shell 命令是否执行成功

### Q: 如何调试模版？

A: 检查：

- 占位符格式：`[PLACEHOLDER_NAME]`
- HTML 注释格式：`<!-- 注释 -->`
- 命令是否正确读取模版

### Q: 如何保护手动添加的内容？

A: 使用保护区标记：

```markdown
<!-- MANUAL ADDITIONS START -->

[手动添加的内容]

<!-- MANUAL ADDITIONS END -->
```

## 参考资源

- [OpenCode 官方文档](https://opencode.ai/docs/)
- [OpenCode Commands 文档](https://opencode.ai/docs/commands/)
- [Markdown 语法指南](https://www.markdownguide.org/)

## 贡献

如果您发现文档有误或需要补充，请：

1. 提交 Issue 描述问题
2. 提交 Pull Request 改进文档

## 版本历史

- **v1.0** (2026-03-11): 初始版本，包含命令文件和模版文件编写规范
