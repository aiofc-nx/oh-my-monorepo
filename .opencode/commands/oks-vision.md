---
description: Manage project vision documents
agent: build
argument-hint: '[project-name]'
---

# 项目愿景管理

管理项目愿景文档，包括查看、创建和修改功能。

---

## 规则说明

1. **每个项目**（应用或依赖库）都应当有一份独立的愿景文档
2. 愿景文档命名格式：`{项目名称}-vision.md`
3. 愿景文档**统一存放**在：`docs/visions/` 目录
4. 愿景文档包含三个核心要素：
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
VISION_DIR="$REPO_ROOT/docs/visions"

# 创建愿景目录（如果不存在）

mkdir -p "$VISION_DIR"

echo ""
echo "## 📂 愿景文档清单"
echo ""

# 检查是否有愿景文档

if [ -z "$(ls -A "$VISION_DIR" 2>/dev/null)" ]; then
echo "⚠️ **暂无愿景文档**"
echo ""
echo "创建方式："
echo " /oks-vision <项目名称> # 创建新的愿景文档"
echo ""
else
echo "| 序号 | 项目名称 | 文档名称 | 最后修改时间 |"
echo "|------|----------|----------|--------------|"

index=1
for file in "$VISION_DIR"/*-vision.md; do
    if [ -f "$file" ]; then
filename=$(basename "$file")
project_name=$(echo "$filename" | sed 's/-vision\.md$//')
      mod_time=$(stat -c %y "$file" 2>/dev/null | cut -d. -f1 || stat -f "%Sm" "$file" 2>/dev/null)
echo "| $index | $project_name | $filename | $mod_time |"
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
```

#### 情况 B：已有参数 - 处理具体项目

!`bash -lc '
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
VISION_DIR="$REPO_ROOT/docs/visions"
ARGUMENTS="$ARGUMENTS"

# 解析参数

if [["$ARGUMENTS" == "新建"*]] || [["$ARGUMENTS" == "create"*]]; then

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

VISION_FILE="$VISION_DIR/${PROJECT_NAME}-vision.md"

if [ -f "$VISION_FILE" ]; then
echo ""
echo "⚠️ **项目 $PROJECT_NAME 的愿景文档已存在**"
echo ""
echo "查看或修改：/oks-vision $PROJECT_NAME"
echo ""
exit 0
fi

echo ""
echo "## 📝 创建愿景文档"
echo ""
echo "**项目名称**: $PROJECT_NAME"
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

VISION_FILE="$VISION_DIR/${PROJECT_NAME}-vision.md"

if [ ! -f "$VISION_FILE" ]; then
echo ""
echo "⚠️ **项目 $PROJECT_NAME 的愿景文档不存在**"
echo ""
echo "创建新文档：/oks-vision 新建 $PROJECT_NAME"
echo ""
exit 1
fi

echo ""
echo "## 📖 项目愿景：$PROJECT_NAME"
  echo ""
  cat "$VISION_FILE"
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
`

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

AI: [显示 user-center-vision.md 的内容]

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

AI: [根据信息生成 payment-gateway-vision.md]
```

### 示例 3：修改愿景文档

```
用户: /oks-vision user-center
     添加功能模块：用户行为分析，用于统计用户操作记录

AI: [更新 user-center-vision.md，在功能模块表中添加新行]
    ✅ 已添加功能模块：M-004 用户行为分析（P2）
```

---

## 🔗 集成检查

**创建新项目时的强制检查**：

在使用 `/oks-new` 创建新项目时，系统会自动检查：

1. `docs/visions/` 目录是否存在对应的愿景文档
2. 如果不存在，**必须先创建**愿景文档
3. 愿景文档创建完成后，才能继续项目初始化

如果缺少愿景文档，AI 将提示用户先执行 `/oks-vision 新建 <项目名>` 创建愿景文档。

---

## 📂 存储位置

所有愿景文档统一存放在 `docs/visions/` 目录下，文件命名格式为 `{项目名称}-vision.md`

---

## 📝 相关命令

| 命令                        | 说明                         |
| --------------------------- | ---------------------------- |
| `/oks-vision`               | 查看愿景文档列表             |
| `/oks-vision <项目名>`      | 查看/修改指定项目愿景        |
| `/oks-vision 新建 <项目名>` | 创建新的愿景文档             |
| `/oks-new`                  | 创建新项目（会检查愿景文档） |
| `/oks-status`               | 查看项目状态                 |
