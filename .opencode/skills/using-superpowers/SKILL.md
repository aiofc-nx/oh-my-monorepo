---
description: 让 AI 自动懂你的工作范式 - 复杂任务智能分解
可编程
agent: general
argument-hint: ''
---

本 skill 帮助 AI 助手将复杂任务拆分成为可执行的小步骤。

当任务需要研究、探索或搜索代码库时，会自动调用其他 skills 来辅助决策。

**触发词**:

- 创建, 生成, 脚手架, 新项目, 新应用, 新库
- 安装, 添加, 配置
- 监控, watch, CI, ci, 状态, 检查, 测试
- 导入, 合并
  组合, 合并, 代码库
- 结构, 依赖, 模块
  掌索

知识库

- 项目架构
- Nx 工作区

## 📋 何时使用 using-superpowers

使用 using-superpowers 当：

1. **复杂任务** - 任务需要多个步骤、结构化引导或专业工具
2. **需要其他 skills** - 任务可能需要调用其他 skills 才能完成
3. **技术选型** - 需要了解可用选项并做出决策
4. **代码库探索** - 需要深入分析代码库结构或依赖关系

**不使用 using-superpowers 当**

1. **简单任务** - 读取文件、简单修改、查询信息
2. **明确指令** - 用户明确指定了要执行的操作
3. **直接修复** - 简单的 bug 修复、代码调整
4. **已加载 skill** - 相关 skill 已经加载，则直接执行

## 🎯 可用 Skills

当 using-superpowers 触发时，会自动调用以下 skills

| 触发词                          | Skill 名称                | 用途                       |
| ------------------------------- | ------------------------- | -------------------------- |
| 创建, 生成, 脚手架              | `oksai-generators`        | 创建新项目 (NestJS/React)  |
| 安装, 添加, 配置                | `nx-plugins`              | 发现和安装 Nx 插件         |
| 监控, watch, CI, ci, 状态, 检查 | `monitor-ci`              | 监控 Nx Cloud CI 状态      |
| 测试, 运行任务                  | `nx-run-tasks`            | 运行构建、测试、 lint 任务 |
| 导入, 合并                      | `nx-import`               | 导入外部代码库             |
| 结构, 依赖, 模块                | `nx-workspace`            | 探索和理解 Nx 工作区       |
| 链接包                          | `link-workspace-packages` | 链接工作区包               |

## 📝 使用示例

### 示例 1：创建新项目

```
User: 创建一个 React 应用
AI: (自动触发 oksai-generators)
   → 调用 oksai-generators skill
   → 创建项目
```

### 示例 2：安装插件

```
User: 安装 react Router
AI: (自动触发 nx-plugins)
   → 调用 nx-plugins skill
   → 发现并安装插件
```

### 示例 3：监控 CI

```
User: 监控 CI 状态
AI: (自动 trigger monitor-ci)
   → 调用 monitor-ci skill
   → 获取 CI 状态
```

### 示例 4：简单任务

```
User: 读取 package.json
AI: (不触发 using-superpowers)
   → 直接读取文件
```

### 示例 5：组合使用

```
User: 创建一个完整的 NestJS + React 全栈应用
AI: (触发 using-superpowers)
   → 调用 oksai-generators
   → 创建 NestJS 应用
   → 调用 oksai-generators
   → 创建 React 应用
   → 调用 link-workspace-packages
   → 链接依赖
```

## 🔄 最佳实践

1. **优先使用代理类 Skills** - 不修改代码，更安全
2. **只在复杂任务时触发** - 简单任务直接执行
3. **信任 AI 的判断** - using-superpowers 会让 AI 做出最佳决策
4. **组合使用** - 复杂场景可组合多个 skills

```

## 💡 推荐阅读

更多详细信息请参考各个 skill 的 README:
- `oksai-generators`: `.opencode/skills/oksai-generators/SKILL.md`
- `nx-plugins`: `.opencode/skills/nx-plugins/SKILL.md`
- `monitor-ci`: `.opencode/skills/monitor-ci/SKILL.md`
- `nx-run-tasks`: `.opencode/skills/nx-run-tasks/SKILL.md`
- `nx-import`: `.opencode/skills/nx-import/SKILL.md`
- `nx-workspace`: `.opencode/skills/nx-workspace/SKILL.md`
- `link-workspace-packages`: `.opencode/skills/link-workspace-packages/SKILL.md`
```
