---
description: Manage project vision documents
agent: build
argument-hint: '[project-name]'
---

# 项目愿景管理

本命令用于管理项目的愿景文档，包括查看、创建和修改功能。

**用户输入**

```text
$ARGUMENTS
```

在继续之前你需要通过用户的输入信息，确认用户的意图与本命令的使用范围一致。如果不一致，你应当通过交互方式引导用户。

1、如果用户没有提供项目的名称或者地址，你应该全面检索本项目的各子项目名称：

```bash
pnpm nx show projects
```

通过列举方式供用户选择。

如果项目尚未创建，你应当引导用户执行使用`.opencode/commands/oks-generator.md`命令。

---

## 规则说明

1. **每个项目**（应用或依赖库）都应当有一份独立的愿景文档
2. 愿景文档统一存放在：`<project>/docs/specfiy/vision.md`
3. 愿景文档包含三个核心要素：
   - **适用范围**：项目的业务边界和使用场景
   - **使用人员**：目标用户群体和角色
   - **功能模块**：核心功能清单及优先级

---

## ⚠️ 重要约束

**愿景文档必须纯粹描述业务和功能性内容，禁止包含：**

- ❌ 代码片段、伪代码
- ❌ 技术栈选型（如：React、Java、MySQL）
- ❌ 技术实现细节（如：API接口、数据库表结构）
- ❌ 技术架构图或系统架构描述
- ❌ 技术债务、性能优化等技术层面内容

**只允许描述业务和功能性内容：**

- ✅ 业务问题和业务目标
- ✅ 用户角色和使用场景
- ✅ 业务功能和业务流程
- ✅ 业务约束和业务规则

---

## 执行流程

### 第一步：列出愿景文档清单

!`bash -lc '
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

echo ""
echo "## 📂 愿景文档清单"
echo ""

# 获取所有项目列表

PROJECTS=$(cd "$REPO_ROOT" && pnpm nx show projects 2>/dev/null || echo "")

# 扫描项目内的愿景文档（<project>/docs/specfiy/vision.md）

has_visions=false
visions_list=""

if [ -n "$PROJECTS" ]; then
for project in $PROJECTS; do

# 获取项目根目录

PROJECT_ROOT=$(cd "$REPO_ROOT" && pnpm nx show project "$project" --json 2>/dev/null | grep -o "\"root\":\"[^\"]*\"" | head -1 | cut -d\" -f4)
  if [ -n "$PROJECT_ROOT" ] && [ "$PROJECT_ROOT" != "." ]; then
PROJECT_VISION="$REPO_ROOT/$PROJECT_ROOT/docs/specfiy/vision.md"
if [ -f "$PROJECT_VISION" ]; then
mod_time=$(stat -c %y "$PROJECT_VISION" 2>/dev/null | cut -d. -f1 || stat -f "%Sm" "$PROJECT_VISION" 2>/dev/null)
      visions_list="${visions_list}${project}|${PROJECT_ROOT}/docs/specfiy/vision.md|${mod_time}\n"
has_visions=true
fi
fi
done
fi

# 显示愿景文档列表

if [ "$has_visions" = false ]; then
echo "⚠️ **暂无愿景文档**"
echo ""
echo "创建方式："
echo " /oks-vision <项目名称> # 查看或创建愿景文档"
echo " /oks-vision 新建 <项目名称> # 创建新的愿景文档"
echo " /oks-generator <项目名称> # 创建新项目（自动创建开发文档）"
echo ""
else
echo "| 序号 | 项目名称 | 文档路径 | 最后修改时间 |"
echo "|------|----------|----------|--------------|"

index=1
echo -e "$visions_list" | grep -v "^$" | while IFS="|" read -r project path time; do
if [ -n "$project" ]; then
echo "| $index | $project | $path | $time |"
((index++))
fi
done

echo ""
fi

echo "---"
echo ""
`]

---

### 第二步：用户选择操作

根据 `$ARGUMENTS` 参数确定操作类型：

#### 情况 A：无参数 - 引导用户选择

如果 `$ARGUMENTS` 为空，请提示用户：

```
请选择操作：
1. 输入项目名称查看/修改愿景文档（例如：/oks-vision user-center）
2. 输入 "新建 <项目名称>" 创建新的愿景文档（例如：/oks-vision 新建 payment-gateway）
3. 如果项目尚未创建，请使用 /oks-generator 命令（会自动创建开发文档）
```

#### 情况 B：已有参数 - 处理具体项目

!`bash -lc '
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
ARGUMENTS="$ARGUMENTS"

# 获取项目根目录的辅助函数

get_project_root() {
local project_name="$1"
cd "$REPO_ROOT" && pnpm nx show project "$project_name" --json 2>/dev/null | grep -o "\"root\":\"[^\"]\*\"" | head -1 | cut -d\" -f4
}

# 解析参数

if [["$ARGUMENTS" == "新建"*]] || [["$ARGUMENTS" == "create"*]] || [["$ARGUMENTS" == "new"*]]; then

# 创建新模式

PROJECT_NAME=$(echo "$ARGUMENTS" | sed -E "s/^(新建|create|new)[[:space:]]+//" | sed "s/[[:space:]]/-/g")

if [ -z "$PROJECT_NAME" ]; then
echo ""
echo "⚠️ **请提供项目名称**"
echo ""
echo "用法：/oks-vision 新建 <项目名称>"
echo "示例：/oks-vision 新建 payment-gateway"
echo ""
exit 1
fi

# 获取项目根目录

PROJECT_ROOT=$(get_project_root "$PROJECT_NAME")

if [ -z "$PROJECT_ROOT" ] || [ "$PROJECT_ROOT" = "." ]; then
echo ""
echo "⚠️ **项目 $PROJECT_NAME 不存在**"
echo ""
echo "请先创建项目："
echo " /oks-generator $PROJECT_NAME"
echo ""
exit 1
fi

# 检查愿景文档是否存在

PROJECT_VISION="$REPO_ROOT/$PROJECT_ROOT/docs/specfiy/vision.md"

if [ -f "$PROJECT_VISION" ]; then
echo ""
echo "⚠️ **项目 $PROJECT_NAME 的愿景文档已存在**"
echo ""
echo "📄 文档位置: $PROJECT_ROOT/docs/specfiy/vision.md"
echo ""
echo "查看或修改：/oks-vision $PROJECT_NAME"
echo ""
exit 0
fi

echo ""
echo "## 📝 创建愿景文档"
echo ""
echo "**项目名称**: $PROJECT_NAME"
echo "**文档位置**: $PROJECT_ROOT/docs/specfiy/vision.md"
echo ""
echo "---"
echo ""
echo "请告诉 AI 以下信息，以便生成愿景文档："
echo ""
echo "1. **适用范围**：这个项目解决什么问题？业务边界是什么？"
echo "2. **使用人员**：谁会使用这个项目？（角色、岗位）"
echo "3. **功能模块**：包含哪些核心功能？"
echo ""
echo "示例："
echo "\`\`\`"
echo "适用范围：财务管理系统的核心模块，负责企业日常财务记账、报表生成和预算管理"
echo "使用人员：财务专员、财务主管、财务总监"
echo "功能模块："
echo "- 记账管理：收支记录、凭证管理"
echo "- 报表统计：日报、月报、年报"
echo "- 预算管理：预算设置、执行监控、超支预警"
echo "\`\`\`"
echo ""

else

# 查看/修改已有项目

PROJECT_NAME="$ARGUMENTS"

if [ -z "$PROJECT_NAME" ]; then
exit 0
fi

# 获取项目根目录

PROJECT_ROOT=$(get_project_root "$PROJECT_NAME")

if [ -z "$PROJECT_ROOT" ] || [ "$PROJECT_ROOT" = "." ]; then
echo ""
echo "⚠️ **项目 $PROJECT_NAME 不存在**"
echo ""
echo "请先创建项目："
echo " /oks-generator $PROJECT_NAME"
echo ""
exit 1
fi

# 检查愿景文档

PROJECT_VISION="$REPO_ROOT/$PROJECT_ROOT/docs/specfiy/vision.md"

if [ ! -f "$PROJECT_VISION" ]; then
echo ""
echo "⚠️ **项目 $PROJECT_NAME 的愿景文档不存在**"
echo ""
echo "📄 预期位置: $PROJECT_ROOT/docs/specfiy/vision.md"
echo ""
echo "创建方式："
echo ""
echo "1. 手动创建愿景文档："
echo " /oks-vision 新建 $PROJECT_NAME"
echo ""
echo "2. 如果项目刚创建，开发文档模板应该已包含 vision.md："
echo " ls $PROJECT_ROOT/docs/specfiy/"
echo ""
exit 1
fi

# 显示愿景文档

echo ""
echo "## 📖 项目愿景：$PROJECT_NAME"
echo ""
echo "📄 **文档位置**: $PROJECT_ROOT/docs/specfiy/vision.md"
echo ""
echo "---"
echo ""
cat "$PROJECT_VISION"
echo ""
echo "---"
echo ""
echo "## ✏️ 可用操作"
echo ""
echo "告诉 AI 您想要如何修改："
echo ""
echo "- **修改适用范围**：\"更新适用范围为...\""
echo "- **修改使用人员**：\"添加用户角色：数据分析师\""
echo "- **添加功能模块**：\"增加功能：审计日志\""
echo "- **调整优先级**：\"将预算管理调整为 P1 优先级\""
echo "- **完全重写**：\"重新生成愿景文档\""
echo ""
fi
`]

---

## 愿景文档模板

创建新愿景文档时，AI 应使用以下模板：

```markdown
# {项目名称} - 项目愿景

## 📋 基本信息

- **项目名称**: {project-name}
- **文档版本**: v1.0
- **创建日期**: {YYYY-MM-DD}
- **最后更新**: {YYYY-MM-DD}

---

## 🎯 适用范围

### 业务边界

{描述项目解决的核心业务问题，业务范围和边界}

### 使用场景

{列出主要业务场景，从用户视角描述}

---

## 👥 使用人员

### 主要用户群体

| 角色    | 岗位职责 | 使用频率         |
| ------- | -------- | ---------------- |
| {角色1} | {职责}   | {高频/中频/低频} |
| {角色2} | {职责}   | {高频/中频/低频} |

### 权限划分

- **管理员**：{权限范围}
- **普通用户**：{权限范围}
- **访客**：{权限范围}

---

## 🔧 功能模块

### 核心功能

| 模块编号 | 模块名称 | 功能描述 | 优先级 | 状态   |
| -------- | -------- | -------- | ------ | ------ |
| M-001    | {模块名} | {描述}   | P1     | 规划中 |
| M-002    | {模块名} | {描述}   | P1     | 规划中 |
| M-003    | {模块名} | {描述}   | P2     | 规划中 |

### 功能说明

#### M-001: {模块名称}

- **功能点**：
  - {功能点1}
  - {功能点2}
- **业务价值**：{价值说明}
- **依赖关系**：{依赖的其他模块或系统}

---

## 🚀 发展规划

### 短期目标（1-3个月）

- {目标1}
- {目标2}

### 中期目标（3-6个月）

- {目标1}
- {目标2}

### 长期愿景（6-12个月）

- {愿景描述}

---

## 📌 注意事项

- {业务约束或限制}
- {合规要求}
- {业务风险提示}
```

---

## 使用示例

### 示例 1：查看愿景文档

```
用户: /oks-vision user-center

AI: [显示 user-center/docs/specfiy/vision.md 的内容]

    可用操作：
    - 修改适用范围
    - 修改使用人员
    - 添加功能模块
    - 调整优先级
```

### 示例 2：创建新愿景文档

```
用户: /oks-vision 新建 payment-gateway

AI: 请提供以下信息：
    1. 适用范围
    2. 使用人员
    3. 功能模块

用户: 这是一个支付网关服务，负责处理所有支付请求和回调通知。
     使用人员：财务专员、财务主管、运营人员。
     功能：支付请求处理、支付回调、退款处理、对账。

AI: [在 payment-gateway/docs/specfiy/vision.md 创建愿景文档]
```

### 示例 3：修改愿景文档

```
用户: /oks-vision user-center
     添加功能模块：用户行为分析，用于统计用户操作记录

AI: [更新 user-center/docs/specfiy/vision.md，在功能模块表中添加新行]
    ✅ 已添加功能模块：M-004 用户行为分析（P2）
```

---

## 📂 存储位置

所有愿景文档统一存放在各项目的 `docs/specfiy/` 目录下：

```
apps/<project>/
└── docs/
    └── specfiy/
        ├── vision.md         # 愿景文档
        ├── design.md         # 设计文档
        ├── implementation.md # 实现文档
        └── ...

libs/<project>/
└── docs/
    └── specfiy/
        ├── vision.md         # 愿景文档
        └── ...
```

---

## 📝 相关命令

| 命令                        | 说明                       |
| --------------------------- | -------------------------- |
| `/oks-vision`               | 查看愿景文档列表           |
| `/oks-vision <项目名>`      | 查看/修改指定项目愿景      |
| `/oks-vision 新建 <项目名>` | 创建新的愿景文档           |
| `/oks-generator`            | 创建新项目（NestJS/React） |
| `/oks-status`               | 查看项目状态               |
