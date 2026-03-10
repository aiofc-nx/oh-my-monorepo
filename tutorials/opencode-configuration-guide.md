# OpenCode 配置指南（基于 `tutorials/config.json`）

这份文档用于说明如何编写和维护 `opencode.json`。

`opencode.json` 通过：

```json
"$schema": "https://opencode.ai/config.json"
```

关联到 Schema，实现字段校验、自动补全和错误提示。

---

## 1. 最小可用配置

```json
{
  "$schema": "https://opencode.ai/config.json",
  "model": "anthropic/claude-2",
  "instructions": [
    "CONTRIBUTING.md",
    "docs/guidelines.md",
    ".cursor/rules/*.md"
  ]
}
```

说明：
- `model` 推荐使用 `provider/model` 格式。
- `instructions` 可填文件路径或 glob 模式。
- 根级 `additionalProperties` 为 `false`，不要随意增加未定义字段。

---

## 2. 配置文件结构总览

常见顶层字段（按使用频率）：

- 基础：`logLevel`、`model`、`small_model`、`default_agent`、`username`
- 行为：`share`、`autoupdate`、`snapshot`
- 能力扩展：`agent`、`provider`、`mcp`、`skills`
- 工具与权限：`permission`、`tools`
- 开发支持：`formatter`、`lsp`、`watcher`
- 其他：`compaction`、`experimental`、`enterprise`

已弃用字段（建议不要新用）：
- `autoshare`（用 `share`）
- `mode`（用 `agent`）
- `layout`（已固定 stretch）

---

## 3. 常用字段详解

## 3.1 基础字段

- `logLevel`: 日志级别（`DEBUG`/`INFO`/`WARN`/`ERROR`）
- `model`: 默认主模型
- `small_model`: 小模型（如标题生成等轻量任务）
- `default_agent`: 未指定时默认 agent（无效时回退到 `build`）
- `username`: 对话中展示的用户名

示例：

```json
{
  "logLevel": "INFO",
  "model": "anthropic/claude-2",
  "small_model": "openai/gpt-4o-mini",
  "default_agent": "build",
  "username": "alice"
}
```

## 3.2 分享与更新

- `share`: `manual | auto | disabled`
- `autoupdate`: `true | false | "notify"`
- `snapshot`: 是否启用快照能力（布尔）

示例：

```json
{
  "share": "manual",
  "autoupdate": "notify",
  "snapshot": true
}
```

---

## 4. `agent` 配置（推荐替代旧 `mode`）

`agent` 是一个对象，键名是 agent 名称（如 `build`、`plan`、`summary`，也可自定义），每个 agent 支持：

- `model` / `variant`
- `temperature` / `top_p`
- `prompt`
- `disable`
- `description`
- `mode`: `subagent | primary | all`
- `hidden`
- `color`: `#RRGGBB` 或主题色（`primary`、`secondary` 等）
- `steps`（`maxSteps` 已弃用）
- `permission`（强烈建议使用）

示例：

```json
{
  "agent": {
    "build": {
      "model": "anthropic/claude-2",
      "description": "默认实现型 agent",
      "mode": "primary",
      "color": "primary",
      "steps": 20
    },
    "reviewer": {
      "model": "openai/gpt-4.1",
      "description": "代码审查与风险提示",
      "mode": "subagent",
      "hidden": false,
      "color": "#FF5733"
    }
  }
}
```

---

## 5. `permission` 配置（安全关键）

动作值统一为：
- `ask`: 每次询问
- `allow`: 允许
- `deny`: 禁止

可在根级或 agent 内配置。支持两种方式：
- 直接字符串（全局规则）
- 对象（按工具粒度，或按模式细分）

常见权限键：
- `read`、`edit`、`glob`、`grep`、`list`、`bash`、`task`
- `lsp`、`skill`、`webfetch`、`websearch`
- `todowrite`、`todoread`、`question` 等

示例（根级）：

```json
{
  "permission": {
    "read": "allow",
    "edit": "ask",
    "bash": "ask",
    "websearch": "deny"
  }
}
```

---

## 6. `mcp` 配置（本地 / 远程）

`mcp` 的每个键代表一个 MCP 服务实例。

### 6.1 本地 MCP（`type: "local"`）

必填：
- `type`
- `command`（数组，命令与参数）

可选：
- `environment`
- `enabled`
- `timeout`

示例：

```json
{
  "mcp": {
    "nx-mcp": {
      "type": "local",
      "command": ["npx", "nx", "mcp"],
      "enabled": true,
      "timeout": 5000
    }
  }
}
```

### 6.2 远程 MCP（`type: "remote"`）

必填：
- `type`
- `url`

可选：
- `enabled`
- `headers`
- `oauth`（对象或 `false`）
- `timeout`

示例：

```json
{
  "mcp": {
    "remote-docs": {
      "type": "remote",
      "url": "https://example.com/mcp",
      "headers": {
        "Authorization": "Bearer ${TOKEN}"
      },
      "timeout": 5000
    }
  }
}
```

补充：也可仅写 `{ "enabled": false }` 作为禁用占位配置。

---

## 7. `provider` 配置（自定义模型与供应商）

`provider` 用于扩展/覆盖供应商行为，结构为 `provider.<name> = ProviderConfig`。

常用字段：
- 供应商级：`api`、`name`、`env`、`id`、`npm`
- 模型集合：`models`
- 筛选：`whitelist` / `blacklist`
- 运行选项：`options.apiKey`、`options.baseURL`、`options.timeout`

模型级（`provider.<name>.models.<model>`）常用字段：
- 元信息：`id`、`name`、`family`、`release_date`、`status`
- 能力开关：`attachment`、`reasoning`、`tool_call`、`temperature`
- 额度/成本：`limit`、`cost`
- 多模态：`modalities.input` / `modalities.output`
- 变体：`variants.<variant>.disabled`

示例：

```json
{
  "provider": {
    "my-provider": {
      "api": "openai-compatible",
      "options": {
        "baseURL": "https://api.example.com/v1",
        "apiKey": "${MY_PROVIDER_KEY}",
        "timeout": 120000
      },
      "models": {
        "my-model": {
          "name": "My Model",
          "tool_call": true,
          "limit": {
            "context": 128000,
            "output": 8192
          }
        }
      }
    }
  }
}
```

---

## 8. 其他常用模块

### 8.1 `command`

自定义命令模板，键名为命令名。每个命令对象中：
- 必填：`template`
- 可选：`description`、`agent`、`model`、`subtask`

```json
{
  "command": {
    "fix-bug": {
      "template": "定位并修复：{{input}}",
      "description": "快速修 bug",
      "agent": "build"
    }
  }
}
```

### 8.2 `skills`

- `paths`: 本地技能目录
- `urls`: 远程技能索引地址

### 8.3 `formatter`

- 可设为 `false` 全局关闭
- 或按名称配置：`command`、`environment`、`extensions`、`disabled`

### 8.4 `lsp`

- 可设为 `false` 全局关闭
- 或按名称配置：
  - 简单禁用：`{ "disabled": true }`
  - 正常配置：`command`（必填）+ `extensions`/`env`/`initialization`

### 8.5 `compaction`

- `auto`: 上下文满时自动压缩
- `prune`: 裁剪旧工具输出
- `reserved`: 预留 token 缓冲

### 8.6 `experimental`

- `batch_tool`
- `openTelemetry`
- `primary_tools`
- `continue_loop_on_deny`
- `mcp_timeout`

---

## 9. 与当前仓库配置对应关系

当前仓库 `opencode.json` 已使用：
- `$schema`
- `instructions`
- `mcp.nx-mcp`（本地 MCP）

可在此基础上逐步新增 `model`、`agent`、`permission`，形成更可控的默认行为。

---

## 10. 实践建议

- 优先使用 `agent`，不要新增旧 `mode` 配置。
- 优先使用 `steps`，不要新增 `maxSteps`。
- 权限先从保守策略开始：`edit`/`bash` 用 `ask`，再逐步放宽。
- `mcp`/`provider` 涉及密钥时，优先用环境变量而不是明文。
- 变更配置后，依赖 schema 报错信息快速回归检查。

