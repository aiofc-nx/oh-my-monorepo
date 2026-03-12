---
description: 完整开发工作流（自动串联各阶段）
agent: build
argument-hint: '<功能名称> [选项]'
---

## ⚠️ 参数验证

!`if [ -z "$ARGUMENTS" ]; then
  echo "❌ **错误: 缺少功能名称**"
  echo ""
  echo "**用法**: /oks-workflow <功能名称> [选项]"
  echo ""
  echo "**示例**:"
  echo " /oks-workflow 用户登录"
  echo " /oks-workflow 购物车 --skip-bdd"
  echo " /oks-workflow 订单 --from=design"
  echo ""
  echo "**选项**:"
  echo " --skip-bdd       跳过 BDD 阶段"
  echo " --skip-optimize  跳过优化阶段"
  echo " --from=<阶段>    从指定阶段开始"
  echo " --status         查看当前进度"
  exit 1
fi`

---

# 开发工作流

自动串联各开发阶段，从愿景到优化一站式完成。

---

## 📊 工作流概览

```
阶段一: 愿景文档     /oks-vision
    ↓
阶段二: 用户故事     /oks-user-story
    ↓
阶段三: 技术设计     /oks-design
    ↓
阶段四: BDD 场景     /oks-bdd (可跳过)
    ↓
阶段五: TDD 开发     /oks-tdd
    ↓
阶段六: 服务实现     /oks-implementation
    ↓
阶段七: 代码优化     /oks-optimization (可跳过)
```

---

## 当前任务

!`

# 解析参数

FEATURE=""
SKIP_BDD=false
SKIP_OPTIMIZE=false
FROM_STAGE=""
SHOW_STATUS=false

for arg in $ARGUMENTS; do
  case "$arg" in
--skip-bdd) SKIP*BDD=true ;;
--skip-optimize) SKIP_OPTIMIZE=true ;;
--from=*) FROM*STAGE="${arg#*=}" ;;
--status) SHOW_STATUS=true ;;
\*) FEATURE="$arg" ;;
esac
done

echo "**功能名称**: $FEATURE"
echo ""

# 检查当前进度（基于文件存在性）

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

echo "**工作流状态**:"
echo ""

# 检查各阶段文件

VISION_DIR="$REPO_ROOT/docs/visions"
USER_STORY_DIR="$REPO_ROOT/docs/user-stories"
DESIGN_DIR="$REPO_ROOT/docs/designs"

# 阶段一：愿景

if ls "$VISION_DIR"/\*-vision.md 2>/dev/null | head -1 | xargs -I {} test -f {} 2>/dev/null; then
echo "✅ 阶段一: 愿景文档"
S1="✅"
else
echo "⬜ 阶段一: 愿景文档"
S1="⬜"
fi

# 阶段二：用户故事

FOUND_US=false
for dir in "$USER_STORY_DIR"/*/; do
    if [ -d "$dir" ] && [ -f "${dir}$FEATURE.md" ]; then
FOUND_US=true
break
fi
done
if $FOUND_US || [ -f "$USER_STORY_DIR/$FEATURE.md" ]; then
echo "✅ 阶段二: 用户故事"
S2="✅"
else
echo "⬜ 阶段二: 用户故事"
S2="⬜"
fi

# 阶段三：技术设计

FOUND_DESIGN=false
for dir in "$DESIGN_DIR"/*/; do
    if [ -d "$dir" ] && [ -f "${dir}$FEATURE.md" ]; then
FOUND_DESIGN=true
break
fi
done
if $FOUND_DESIGN || [ -f "$DESIGN_DIR/$FEATURE.md" ]; then
echo "✅ 阶段三: 技术设计"
S3="✅"
else
echo "⬜ 阶段三: 技术设计"
S3="⬜"
fi

# 阶段四：BDD

if [ -f "$REPO_ROOT/features/$FEATURE.feature" ]; then
echo "✅ 阶段四: BDD 场景"
S4="✅"
else
if $SKIP_BDD; then
echo "⏭️ 阶段四: BDD 场景 (已跳过)"
S4="⏭️"
else
echo "⬜ 阶段四: BDD 场景"
S4="⬜"
fi
fi

# 阶段五：TDD

NORMALIZED=$(echo "$FEATURE" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9\u4e00-\u9fa5]/-/g')
if [ -d "$REPO_ROOT/src/modules/$NORMALIZED" ]; then
echo "✅ 阶段五: TDD 开发"
S5="✅"
else
echo "⬜ 阶段五: TDD 开发"
S5="⬜"
fi

# 阶段六：实现

if [ -f "$REPO_ROOT/src/modules/$NORMALIZED/services" ] 2>/dev/null || \
 find "$REPO_ROOT/src/modules/$NORMALIZED" -name "\*.service.ts" 2>/dev/null | head -1 | grep -q .; then
echo "✅ 阶段六: 服务实现"
S6="✅"
else
echo "⬜ 阶段六: 服务实现"
S6="⬜"
fi

# 阶段七：优化

if $SKIP_OPTIMIZE; then
echo "⏭️ 阶段七: 代码优化 (已跳过)"
S7="⏭️"
else
echo "⬜ 阶段七: 代码优化"
S7="⬜"
fi

echo ""
echo "进度条: $S1$S2$S3$S4$S5$S6$S7"

# 如果只是查看状态，退出

if $SHOW_STATUS; then
echo ""
echo "继续开发: /oks-workflow $FEATURE"
exit 0
fi
`

---

## 🚀 执行计划

根据当前进度和选项，将执行以下阶段：

!`

# 确定起始阶段

case "$FROM_STAGE" in
vision|1) START=1 ;;
user-story|2) START=2 ;;
design|3) START=3 ;;
bdd|4) START=4 ;;
tdd|5) START=5 ;;
implementation|6) START=6 ;;
optimization|7) START=7 ;;
\*) START=1 ;;
esac

echo "| 阶段 | 命令 | 状态 |"
echo "|------|------|------|"

[ $START -le 1 ] && echo "| 一 | /oks-vision | 待执行 |" || echo "| 一 | /oks-vision | 跳过 |"
[ $START -le 2 ] && echo "| 二 | /oks-user-story | 待执行 |" || echo "| 二 | /oks-user-story | 跳过 |"
[ $START -le 3 ] && echo "| 三 | /oks-design | 待执行 |" || echo "| 三 | /oks-design | 跳过 |"

if $SKIP_BDD; then
echo "| 四 | /oks-bdd | 已跳过 |"
else
[ $START -le 4 ] && echo "| 四 | /oks-bdd | 待执行 |" || echo "| 四 | /oks-bdd | 跳过 |"
fi

[ $START -le 5 ] && echo "| 五 | /oks-tdd | 待执行 |" || echo "| 五 | /oks-tdd | 跳过 |"
[ $START -le 6 ] && echo "| 六 | /oks-implementation | 待执行 |" || echo "| 六 | /oks-implementation | 跳过 |"

if $SKIP_OPTIMIZE; then
echo "| 七 | /oks-optimization | 已跳过 |"
else
[ $START -le 7 ] && echo "| 七 | /oks-optimization | 待执行 |" || echo "| 七 | /oks-optimization | 跳过 |"
fi
`

---

## 📝 各阶段说明

### 阶段一：愿景文档

**命令**: `/oks-vision`

**产出**: `docs/visions/{project}-vision.md`

**完成条件**: 愿景文档包含适用范围、使用人员、功能模块

---

### 阶段二：用户故事

**命令**: `/oks-user-story $ARGUMENTS`

**产出**: `docs/user-stories/{project}/{feature}.md`

**完成条件**: 符合 INVEST 原则，验收标准明确

---

### 阶段三：技术设计

**命令**: `/oks-design $ARGUMENTS`

**产出**: `docs/designs/{project}/{feature}.md`

**完成条件**: 数据库设计、API 设计、数据流设计完成

---

### 阶段四：BDD 场景

**命令**: `/oks-bdd $ARGUMENTS`

**产出**: `features/{feature}.feature`

**完成条件**: 至少 5 个场景（Happy/Error/Edge）

**可跳过**: 使用 `--skip-bdd` 跳过（适合简单功能）

---

### 阶段五：TDD 开发

**命令**: `/oks-tdd $ARGUMENTS`

**产出**: `src/modules/{module}/entities/`

**完成条件**: 领域实体测试覆盖率 > 80%

---

### 阶段六：服务实现

**命令**: `/oks-implementation $ARGUMENTS`

**产出**: `src/modules/{module}/services/`, `controllers/`, `repositories/`

**完成条件**: 服务层测试覆盖率 > 80%，所有 BDD 场景通过

---

### 阶段七：代码优化

**命令**: `/oks-optimization $ARGUMENTS`

**产出**: 优化后的代码 + 性能报告

**完成条件**: 性能提升 > 20%，无安全漏洞

**可跳过**: 使用 `--skip-optimize` 跳过（适合原型开发）

---

## ⚡ 快速模式

### 跳过 BDD 和优化

```bash
/oks-workflow <功能> --skip-bdd --skip-optimize
```

**适用场景**: 原型开发、快速验证

**流程**: 愿景 → 用户故事 → 设计 → TDD → 实现

---

### 从指定阶段开始

```bash
# 从设计阶段开始
/oks-workflow <功能> --from=design

# 从 TDD 阶段开始
/oks-workflow <功能> --from=tdd
```

**适用场景**: 补充缺失阶段、重新执行某阶段

---

### 查看进度

```bash
/oks-workflow <功能> --status
```

---

## 🎯 阶段依赖关系

```
vision (无依赖)
  ↓
user-story (依赖 vision)
  ↓
design (依赖 user-story)
  ↓
bdd (依赖 design) ← 可跳过
  ↓
tdd (依赖 design，推荐 bdd)
  ↓
implementation (依赖 tdd)
  ↓
optimization (依赖 implementation) ← 可跳过
```

---

## 🔄 中断恢复

工作流支持中断后继续：

1. 每完成一个阶段，自动记录进度
2. 再次运行 `/oks-workflow <功能>` 会从上次中断处继续
3. 或使用 `--from=<阶段>` 指定起始点

---

## 📋 执行检查清单

AI 执行工作流时，应按以下顺序：

- [ ] 阶段一：创建/更新愿景文档
- [ ] 阶段二：创建符合 INVEST 的用户故事
- [ ] 阶段三：完成技术设计（数据库/API/组件）
- [ ] 阶段四：编写 BDD 场景（如未跳过）
- [ ] 阶段五：TDD 开发领域实体
- [ ] 阶段六：实现服务层、控制器、Repository
- [ ] 阶段七：代码优化（如未跳过）
- [ ] 最终验证：所有测试通过

---

## 💡 使用建议

| 场景     | 命令                                              |
| -------- | ------------------------------------------------- |
| 正式项目 | `/oks-workflow <功能>`                            |
| 快速原型 | `/oks-workflow <功能> --skip-bdd --skip-optimize` |
| 只做核心 | `/oks-workflow <功能> --skip-optimize`            |
| 补充设计 | `/oks-workflow <功能> --from=design`              |
| 查看进度 | `/oks-workflow <功能> --status`                   |

---

## 相关命令

| 命令                  | 说明           |
| --------------------- | -------------- |
| `/oks-vision`         | 单独执行阶段一 |
| `/oks-user-story`     | 单独执行阶段二 |
| `/oks-design`         | 单独执行阶段三 |
| `/oks-bdd`            | 单独执行阶段四 |
| `/oks-tdd`            | 单独执行阶段五 |
| `/oks-implementation` | 单独执行阶段六 |
| `/oks-optimization`   | 单独执行阶段七 |
| `/oks-list`           | 查看所有项目   |
| `/oks-status`         | 查看项目状态   |
