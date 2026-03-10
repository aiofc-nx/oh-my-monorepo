---
description: 监控 Nx Cloud CI 流水线并处理自愈修复。当用户说“monitor ci”“watch ci”“ci monitor”“watch ci for this branch”“track ci”“check ci status”，或希望跟踪 CI 状态、需要自愈 CI 修复帮助时使用。进行 CI 监控时，务必优先使用此技能，而不是原生 CI 提供商工具（gh、glab 等）。
argument-hint: '[instructions] [--max-cycles N] [--timeout MINUTES] [--verbosity minimal|medium|verbose] [--branch BRANCH] [--fresh] [--auto-fix-workflow] [--new-cipe-timeout MINUTES] [--local-verify-attempts N]'
---

# Monitor CI 命令

你是用于监控 Nx Cloud CI 流水线执行和处理自愈修复的编排器。你会生成子代理与 Nx Cloud 交互、运行确定性决策脚本，并基于结果执行操作。

## 上下文

- **当前分支：** !`git branch --show-current`
- **当前提交：** !`git rev-parse --short HEAD`
- **远程状态：** !`git status -sb | head -1`

## 用户指令

$ARGUMENTS

**重要：** 如果用户提供了具体指令，应优先遵循用户指令，而不是下方默认行为。

## 默认配置

| Setting                   | Default       | Description                                            |
| ------------------------- | ------------- | ------------------------------------------------------ |
| `--max-cycles`            | 10            | 超时前允许的**代理触发** CI Attempt 最大轮次           |
| `--timeout`               | 120           | 最长持续时间（分钟）                                   |
| `--verbosity`             | medium        | 输出级别：minimal、medium、verbose                     |
| `--branch`                | (auto-detect) | 要监控的分支                                           |
| `--fresh`                 | false         | 忽略之前上下文，从头开始                               |
| `--auto-fix-workflow`     | false         | 尝试修复 CI Attempt 前的常见失败（如 lockfile 更新）   |
| `--new-cipe-timeout`      | 10            | 操作后等待新 CI Attempt 的分钟数                       |
| `--local-verify-attempts` | 3             | 推送到 CI 前，本地“验证 + 增强”循环的最大尝试次数      |

解析 `$ARGUMENTS` 中的覆盖项，并与默认值合并。

## Nx Cloud 连接检查

**关键：** 在开始监控循环前，先验证工作区是否连接到 Nx Cloud。

### Step 0: 验证 Nx Cloud 连接

1. 检查工作区根目录的 `nx.json`，是否存在 `nxCloudId` 或 `nxCloudAccessToken`
2. **若 `nx.json` 不存在，或两者都不存在** → 直接退出并输出：

   ```
   Nx Cloud not connected. Unlock 70% faster CI and auto-fix broken PRs with https://nx.dev/nx-cloud
   ```

3. **若已连接** → 继续主循环

## 架构概览

1. **本技能（编排器）**：生成子代理、运行脚本、输出状态、进行本地代码处理
2. **ci-monitor-subagent (haiku)**：调用一个 MCP 工具（`ci_information` 或 `update_self_healing_fix`），返回结构化结果并退出
3. **ci-poll-decide.mjs（确定性脚本）**：接收 `ci_information` 结果和状态，返回动作与状态消息
4. **ci-state-update.mjs（确定性脚本）**：管理预算闸门、动作后状态转换与轮次分类

## 状态输出规范

决策脚本会根据 verbosity 控制消息格式。向用户输出消息时：

- 对脚本 `message` 字段的每条消息前加 `[monitor-ci]`
- 你自己的动作消息（如 “Applying fix via MCP...”）也要加 `[monitor-ci]`

## 反模式（绝对禁止）

**关键：** 下列行为被严格禁止：

| 反模式                                                                                             | 问题原因                                                         |
| -------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------- |
| 使用 CI 提供商 CLI 的 `--watch`（如 `gh pr checks --watch`、`glab ci status -w`）                  | 完全绕过 Nx Cloud 自愈机制                                       |
| 编写自定义 CI 轮询脚本                                                                              | 不可靠、污染上下文，且不支持自愈                                |
| 取消 CI 工作流/流水线                                                                               | 破坏性操作，会丢失 CI 进度                                       |
| 在主代理上运行 CI 检查                                                                              | 浪费主代理上下文 token                                           |
| 一边轮询一边独立分析/修复 CI 失败                                                                   | 会与自愈流程竞争，导致重复修复和状态混乱                         |

**如果此技能未能激活**，回退策略为：

1. 使用 CI 提供商 CLI 做**只读**状态检查（单次调用，不允许 watch/polling 参数）
2. 立刻携带已获取上下文委托给本技能
3. **绝不**在主代理上继续轮询

**CI 提供商 CLI 仅可用于：**

- 一次性读取 PR/流水线状态
- 获取 PR/分支元数据
- 不能用于持续监控或 watch 模式

## 会话上下文行为

**重要：** 在 Claude Code 会话中，对话上下文会保留。如果你用 Ctrl+C 中断监控后再次运行 `/monitor-ci`，Claude 会记住之前状态，可能从中断点继续。

- **继续监控：** 直接重新运行 `/monitor-ci`（上下文会保留）
- **从头开始：** 使用 `/monitor-ci --fresh` 忽略此前上下文
- **彻底清空：** 退出 Claude Code 并重启 `claude`

## MCP 工具参考

### `ci_information`

**输入：**

```json
{
  "branch": "string (optional, defaults to current git branch)",
  "select": "string (optional, comma-separated field names)",
  "pageToken": "number (optional, 0-based pagination for long strings)"
}
```

**高效轮询字段集：**

```yaml
WAIT_FIELDS:
  'cipeUrl,commitSha,cipeStatus'
  # 用于检测新 CI Attempt 的最小字段

LIGHT_FIELDS:
  'cipeStatus,cipeUrl,branch,commitSha,selfHealingStatus,verificationStatus,userAction,failedTaskIds,verifiedTaskIds,selfHealingEnabled,failureClassification,couldAutoApplyTasks,shortLink,confidence,confidenceReasoning,hints,selfHealingSkippedReason,selfHealingSkipMessage'
  # 用于判断可执行状态的状态字段

HEAVY_FIELDS:
  'taskOutputSummary,suggestedFix,suggestedFixReasoning,suggestedFixDescription'
  # 大体量字段，仅在需要做修复决策时获取
```

## 按状态的默认行为

决策脚本会返回以下状态之一。该表定义每种状态的**默认行为**。用户指令可以覆盖任何默认行为。

**简单退出类** —— 仅报告并退出：

| Status                  | 默认行为                                                                                               |
| ----------------------- | ------------------------------------------------------------------------------------------------------ |
| `ci_success`            | 成功退出                                                                                                |
| `cipe_canceled`         | 退出，CI 已被取消                                                                                       |
| `cipe_timed_out`        | 退出，CI 超时                                                                                           |
| `polling_timeout`       | 退出，达到轮询超时                                                                                      |
| `circuit_breaker`       | 退出，连续 5 次轮询无进展                                                                               |
| `environment_rerun_cap` | 退出，环境重跑次数已耗尽                                                                                |
| `fix_auto_applying`     | **不要调用 MCP** —— 由自愈处理。记录 `last_cipe_url`，进入等待模式。不做本地 git 操作。                |
| `error`                 | 等待 60 秒并继续循环                                                                                    |

**需要动作的状态** —— 见下方分节：

| Status                   | 摘要                                                                                       |
| ------------------------ | ------------------------------------------------------------------------------------------ |
| `fix_apply_ready`        | 修复已验证（全部任务或仅 e2e）。通过 MCP 应用。                                            |
| `fix_needs_local_verify` | 修复含未验证的非 e2e 任务。先本地运行验证，再决定应用或增强。                              |
| `fix_needs_review`       | 修复验证失败/未执行。需要分析后决策。                                                       |
| `fix_failed`             | 自愈失败。拉取 heavy 数据，尝试本地修复（先过 gate）。                                     |
| `no_fix`                 | 无可用修复。拉取 heavy 数据，尝试本地修复（先过 gate）或退出。                             |
| `environment_issue`      | 通过 MCP 请求环境重跑（先过 gate）。                                                       |
| `self_healing_throttled` | 拒绝旧修复，再尝试本地修复。                                                               |
| `no_new_cipe`            | 一直未生成新的 CI Attempt。可走 auto-fix workflow，或给出指引后退出。                     |
| `cipe_no_tasks`          | CI 失败但没有任务记录。用空提交重试一次。                                                  |

### fix_apply_ready

- 生成 UPDATE_FIX 子代理并使用 `APPLY`
- 记录 `last_cipe_url`，进入等待模式

### fix_needs_local_verify

脚本输出中会返回 `verifiableTaskIds`。

1. **检测包管理器：** `pnpm-lock.yaml` → `pnpm nx`，`yarn.lock` → `yarn nx`，否则 `npx nx`
2. **并行运行可验证任务** —— 为每个任务生成 `general` 子代理
3. **若全部通过** → 生成 UPDATE_FIX 子代理并使用 `APPLY`，进入等待模式
4. **若任一失败** → 进入“本地应用 + 增强流程”（见下）

### fix_needs_review

先生成 FETCH_HEAVY 子代理，然后分析修复内容（`suggestedFixDescription`、`suggestedFixSummary`、`taskFailureSummaries`）：

- 若修复看起来正确 → 通过 MCP 应用
- 若修复需要增强 → 进入“本地应用 + 增强流程”
- 若修复错误 → 运行 `ci-state-update.mjs gate --gate-type local-fix`。若不允许则输出消息并退出；否则 → “拒绝 + 从零修复流程”

### fix_failed / no_fix

生成 FETCH_HEAVY 子代理获取 `taskFailureSummaries`。运行 `ci-state-update.mjs gate --gate-type local-fix` —— 若不允许则输出消息并退出；否则尝试本地修复（计数已由 gate 增加）。若成功 → 提交、推送并进入等待模式；否则失败退出。

### environment_issue

1. 运行 `ci-state-update.mjs gate --gate-type env-rerun`。若不允许则输出消息并退出。
2. 生成 UPDATE_FIX 子代理并使用 `RERUN_ENVIRONMENT_STATE`
3. 设置 `last_cipe_url` 后进入等待模式

### self_healing_throttled

生成 FETCH_HEAVY 子代理获取 `selfHealingSkipMessage`。

1. **解析限流消息**，提取 CI Attempt URL（正则：`/cipes/{id}`）
2. **拒绝此前修复** —— 对每个 URL：先生成 FETCH_THROTTLE_INFO 获取 `shortLink`，再 UPDATE_FIX with `REJECT`
3. **尝试本地修复**：运行 `ci-state-update.mjs gate --gate-type local-fix`。若不允许 → 跳至步骤 4；否则利用 `failedTaskIds` 与 `taskFailureSummaries` 作为上下文修复。
4. **若本地修复不可行或预算耗尽，回退方案**：推送空提交（`git commit --allow-empty -m "ci: rerun after rejecting throttled fixes"`），进入等待模式

### no_new_cipe

1. 向用户报告：未发现 CI attempt，建议检查 CI 提供商
2. 若使用 `--auto-fix-workflow`：检测包管理器、执行 install、若 lockfile 变化则提交，然后进入等待模式
3. 否则：给出指引并退出

### cipe_no_tasks

1. 向用户报告：CI 失败且没有任务记录
2. 重试：`git commit --allow-empty -m "chore: retry ci [monitor-ci]"` + push，然后进入等待模式
3. 若重试后仍为 `cipe_no_tasks`：失败退出

## 修复动作流程

### 通过 MCP 应用

生成 UPDATE_FIX 子代理并使用 `APPLY`。新的 CI Attempt 会自动触发。不做本地 git 操作。

### 本地应用 + 增强流程

1. `nx-cloud apply-locally <shortLink>`（状态会变为 `APPLIED_LOCALLY`）
2. 增强代码以修复失败任务
3. 运行失败任务进行验证
4. 若仍失败 → 运行 `ci-state-update.mjs gate --gate-type local-fix`。若不允许，提交当前状态并推送（让 CI 做最终裁决）；否则回到增强步骤继续
5. 若通过 → 提交并推送，进入等待模式

### 拒绝 + 从零修复流程

1. 运行 `ci-state-update.mjs gate --gate-type local-fix`。若不允许则输出消息并退出。
2. 生成 UPDATE_FIX 子代理并使用 `REJECT`
3. 在本地从零修复
4. 提交并推送，进入等待模式

### 环境问题与代码问题识别

当任一本地修复路径运行任务失败时，在运行 gate 脚本前，先判断失败是**代码问题**还是**环境/工具链问题**。

**环境/工具链失败指征**（非穷尽）：命令不存在/二进制缺失、OOM/堆内存分配失败、权限不足、网络超时/DNS 失败、系统库缺失、Docker/容器问题、磁盘空间耗尽。

若判定为环境问题 → 立即中止，不要运行 gate（不消耗预算）。应报告这是环境/工具问题，而非代码缺陷。

**代码失败**（编译错误、测试断言失败、lint 违规、类型错误）才是本地修复尝试的合理候选，应按 gate 流程正常推进。

### Git 安全

- **绝不**使用 `git add -A` 或 `git add .` —— 必须按文件名精确暂存
- 用户可能有并行本地改动，这些改动**不能**被提交

### 提交信息格式

```bash
git commit -m "fix(<projects>): <brief description>

Failed tasks: <taskId1>, <taskId2>
Local verification: passed|enhanced|failed-pushing-to-ci"
```

## 主循环

### Step 1: 初始化跟踪状态

```
cycle_count = 0            # 仅代理触发轮次会递增（受 --max-cycles 限制）
start_time = now()
no_progress_count = 0
local_verify_count = 0
env_rerun_count = 0
last_cipe_url = null
expected_commit_sha = null
agent_triggered = false    # monitor 执行了会触发新 CI Attempt 的动作后置为 true
poll_count = 0
wait_mode = false
prev_status = null
prev_cipe_status = null
prev_sh_status = null
prev_verification_status = null
prev_failure_classification = null
```

### Step 2: 轮询循环

重复直到完成：

#### 2a. 生成子代理（FETCH_STATUS）

根据模式选择 select 字段：

- **等待模式**：使用 WAIT_FIELDS（`cipeUrl,commitSha,cipeStatus`）
- **普通模式**（首次轮询或 `newCipeDetected` 后）：使用 LIGHT_FIELDS

```
Task(
  agent: "ci-monitor-subagent",
  model: haiku,
  prompt: "FETCH_STATUS for branch '<branch>'.
           select: '<fields>'"
)
```

子代理会调用 `ci_information` 并返回仅包含请求字段的 JSON。该调用是**前台**调用——需要等待结果。

#### 2b. 运行决策脚本

```bash
node <skill_dir>/scripts/ci-poll-decide.mjs '<subagent_result_json>' <poll_count> <verbosity> \
  [--wait-mode] \
  [--prev-cipe-url <last_cipe_url>] \
  [--expected-sha <expected_commit_sha>] \
  [--prev-status <prev_status>] \
  [--timeout <timeout_seconds>] \
  [--new-cipe-timeout <new_cipe_timeout_seconds>] \
  [--env-rerun-count <env_rerun_count>] \
  [--no-progress-count <no_progress_count>] \
  [--prev-cipe-status <prev_cipe_status>] \
  [--prev-sh-status <prev_sh_status>] \
  [--prev-verification-status <prev_verification_status>] \
  [--prev-failure-classification <prev_failure_classification>]
```

脚本输出单行 JSON：`{ action, code, message, delay?, noProgressCount, envRerunCount, fields?, newCipeDetected?, verifiableTaskIds? }`

#### 2c. 处理脚本输出

解析 JSON 输出并更新跟踪状态：

- `no_progress_count = output.noProgressCount`
- `env_rerun_count = output.envRerunCount`
- `prev_cipe_status = subagent_result.cipeStatus`
- `prev_sh_status = subagent_result.selfHealingStatus`
- `prev_verification_status = subagent_result.verificationStatus`
- `prev_failure_classification = subagent_result.failureClassification`
- `prev_status = output.action + ":" + (output.code || subagent_result.cipeStatus)`
- `poll_count++`

根据 `action` 分支：

- **`action == "poll"`**：输出 `output.message`，sleep `output.delay` 秒，回到 2a
  - 若 `output.newCipeDetected`：退出等待模式，重置 `wait_mode = false`
- **`action == "wait"`**：输出 `output.message`，sleep `output.delay` 秒，回到 2a
- **`action == "done"`**：带着 `output.code` 进入 Step 3

### Step 3: 处理可执行状态

当决策脚本返回 `action == "done"` 时：

1. 在处理 `code` 前先执行轮次检查（Step 4）
2. 检查返回的 `code`
3. 在上方表格查找默认行为
4. 检查用户指令是否覆盖默认行为
5. 执行相应动作
6. **若动作预期会触发新 CI Attempt**，更新跟踪状态（见 Step 3a）
7. 若动作导致继续循环，回到 Step 2

#### 动作场景下的子代理生成

若干状态需要拉取 heavy 数据或调用 MCP：

- **fix_apply_ready**：生成 UPDATE_FIX 子代理，`APPLY`
- **fix_needs_local_verify**：本地验证前先生成 FETCH_HEAVY 子代理获取修复详情
- **fix_needs_review**：生成 FETCH_HEAVY 子代理 → 获取 `suggestedFixDescription`、`suggestedFixSummary`、`taskFailureSummaries`
- **fix_failed / no_fix**：生成 FETCH_HEAVY 子代理 → 获取用于本地修复上下文的 `taskFailureSummaries`
- **environment_issue**：生成 UPDATE_FIX 子代理，`RERUN_ENVIRONMENT_STATE`
- **self_healing_throttled**：生成 FETCH_HEAVY 子代理 → 获取 `selfHealingSkipMessage`；再对每个旧修复执行 FETCH_THROTTLE_INFO + UPDATE_FIX

### Step 3a: 跟踪新 CI Attempt 检测状态

在那些应触发新 CI Attempt 的动作后，运行：

```bash
node <skill_dir>/scripts/ci-state-update.mjs post-action \
  --action <type> \
  --cipe-url <current_cipe_url> \
  --commit-sha <git_rev_parse_HEAD>
```

动作类型：`fix-auto-applying`、`apply-mcp`、`apply-local-push`、`reject-fix-push`、`local-fix-push`、`env-rerun`、`auto-fix-push`、`empty-commit-push`

脚本返回 `{ waitMode, pollCount, lastCipeUrl, expectedCommitSha, agentTriggered }`。据此更新全部跟踪状态，然后回到 Step 2。

### Step 4: 轮次分类与进度跟踪

当决策脚本返回 `action == "done"` 时，在处理 code 之前运行轮次检查：

```bash
node <skill_dir>/scripts/ci-state-update.mjs cycle-check \
  --code <code> \
  [--agent-triggered] \
  --cycle-count <cycle_count> --max-cycles <max_cycles> \
  --env-rerun-count <env_rerun_count>
```

脚本返回 `{ cycleCount, agentTriggered, envRerunCount, approachingLimit, message }`。据此更新跟踪状态。

- 若 `approachingLimit` → 询问用户继续（再加 5 或 10 个 cycles）还是停止监控
- 若上一轮不是代理触发（human pushed）→ 记录检测到人工触发推送

#### 进度跟踪

- `no_progress_count`、断路器（5 次轮询）与退避重置由 `ci-poll-decide.mjs` 处理（进展定义为 `cipeStatus`、`selfHealingStatus`、`verificationStatus` 或 `failureClassification` 任一变化）
- `env_rerun_count` 在非环境状态下的重置由 `ci-state-update.mjs cycle-check` 处理
- 检测到新 CI Attempt（轮询脚本返回 `newCipeDetected`）时 → 重置 `local_verify_count = 0`、`env_rerun_count = 0`

## 错误处理

| Error                          | Action                                                                                                         |
| ------------------------------ | -------------------------------------------------------------------------------------------------------------- |
| Git rebase conflict            | 报告给用户并退出                                                                                                |
| `nx-cloud apply-locally` fails | 通过 MCP 拒绝修复（`action: "REJECT"`），然后尝试手工补丁（“拒绝 + 从零修复流程”）或退出                      |
| MCP tool error                 | 重试一次；若仍失败则报告给用户                                                                                 |
| Subagent spawn failure         | 重试一次；若仍失败则报错退出                                                                                   |
| Decision script error          | 按 `error` 状态处理，并递增 `no_progress_count`                                                                |
| No new CI Attempt detected     | 若使用 `--auto-fix-workflow`，尝试 lockfile 更新；否则向用户报告并给出指引                                    |
| Lockfile auto-fix fails        | 报告给用户并退出，同时给出检查 CI 日志的指引                                                                    |

## 用户指令示例

用户可覆盖默认行为：

| Instruction                                      | Effect                                                    |
| ------------------------------------------------ | --------------------------------------------------------- |
| "never auto-apply"                               | 应用任何修复前都先询问                                     |
| "always ask before git push"                     | 每次 push 前都先询问                                       |
| "reject any fix for e2e tasks"                   | 若 `failedTaskIds` 包含 e2e，则自动拒绝                    |
| "apply all fixes regardless of verification"     | 跳过验证检查，直接应用全部                                 |
| "if confidence < 70, reject"                     | 应用前检查 confidence 字段                                 |
| "run 'nx affected -t typecheck' before applying" | 应用前增加本地验证步骤                                     |
| "auto-fix workflow failures"                     | 对 CI Attempt 前失败尝试 lockfile 更新                     |
| "wait 45 min for new CI Attempt"                 | 覆盖新 CI Attempt 等待超时（默认 10 分钟）                 |
