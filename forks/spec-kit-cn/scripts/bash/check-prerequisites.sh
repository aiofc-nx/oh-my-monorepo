#!/usr/bin/env bash

# 统一的前置条件检查脚本
#
# 该脚本为规范驱动开发流程提供统一的前置条件检查。
# 它替代了此前分散在多个脚本中的同类功能。
#
# 用法：./check-prerequisites.sh [OPTIONS]
#
# 选项：
#   --json              以 JSON 格式输出
#   --require-tasks     要求 tasks.md 存在（实现阶段使用）
#   --include-tasks     在 AVAILABLE_DOCS 列表中包含 tasks.md
#   --paths-only        仅输出路径变量（不进行校验）
#   --help, -h          显示帮助信息
#
# 输出：
#   JSON 模式：{"FEATURE_DIR":"...", "AVAILABLE_DOCS":["..."]}
#   文本模式：FEATURE_DIR:... \n AVAILABLE_DOCS: \n ✓/✗ file.md
#   仅路径：REPO_ROOT: ... \n BRANCH: ... \n FEATURE_DIR: ... 等

set -e

# 解析命令行参数
JSON_MODE=false
REQUIRE_TASKS=false
INCLUDE_TASKS=false
PATHS_ONLY=false

for arg in "$@"; do
    case "$arg" in
        --json)
            JSON_MODE=true
            ;;
        --require-tasks)
            REQUIRE_TASKS=true
            ;;
        --include-tasks)
            INCLUDE_TASKS=true
            ;;
        --paths-only)
            PATHS_ONLY=true
            ;;
        --help|-h)
            cat << 'EOF'
Usage: check-prerequisites.sh [OPTIONS]

Consolidated prerequisite checking for Spec-Driven Development workflow.

OPTIONS:
  --json              Output in JSON format
  --require-tasks     Require tasks.md to exist (for implementation phase)
  --include-tasks     Include tasks.md in AVAILABLE_DOCS list
  --paths-only        Only output path variables (no prerequisite validation)
  --help, -h          Show this help message

EXAMPLES:
  # 检查任务阶段前置条件（需 plan.md）
  ./check-prerequisites.sh --json
  
  # 检查实现阶段前置条件（需 plan.md + tasks.md）
  ./check-prerequisites.sh --json --require-tasks --include-tasks
  
  # 仅获取特性路径（不做校验）
  ./check-prerequisites.sh --paths-only
  
EOF
            exit 0
            ;;
        *)
            echo "ERROR: Unknown option '$arg'. Use --help for usage information." >&2
            exit 1
            ;;
    esac
done

# 引入公共函数
SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# 获取特性路径并校验分支
eval $(get_feature_paths)
check_feature_branch "$CURRENT_BRANCH" "$HAS_GIT" || exit 1

# 若为仅路径模式，输出路径后退出（支持与 JSON 模式同时使用）
if $PATHS_ONLY; then
    if $JSON_MODE; then
        # 最小化 JSON 路径载荷（不执行校验）
        printf '{"REPO_ROOT":"%s","BRANCH":"%s","FEATURE_DIR":"%s","FEATURE_SPEC":"%s","IMPL_PLAN":"%s","TASKS":"%s"}\n' \
            "$REPO_ROOT" "$CURRENT_BRANCH" "$FEATURE_DIR" "$FEATURE_SPEC" "$IMPL_PLAN" "$TASKS"
    else
        echo "REPO_ROOT: $REPO_ROOT"
        echo "BRANCH: $CURRENT_BRANCH"
        echo "FEATURE_DIR: $FEATURE_DIR"
        echo "FEATURE_SPEC: $FEATURE_SPEC"
        echo "IMPL_PLAN: $IMPL_PLAN"
        echo "TASKS: $TASKS"
    fi
    exit 0
fi

# 校验必需目录与文件
if [[ ! -d "$FEATURE_DIR" ]]; then
    echo "ERROR: Feature directory not found: $FEATURE_DIR" >&2
    echo "Run /speckit.specify first to create the feature structure." >&2
    exit 1
fi

if [[ ! -f "$IMPL_PLAN" ]]; then
    echo "ERROR: plan.md not found in $FEATURE_DIR" >&2
    echo "Run /speckit.plan first to create the implementation plan." >&2
    exit 1
fi

# 若需要则检查 tasks.md
if $REQUIRE_TASKS && [[ ! -f "$TASKS" ]]; then
    echo "ERROR: tasks.md not found in $FEATURE_DIR" >&2
    echo "Run /speckit.tasks first to create the task list." >&2
    exit 1
fi

# 构建可用文档列表
docs=()

# 始终检查这些可选文档
[[ -f "$RESEARCH" ]] && docs+=("research.md")
[[ -f "$DATA_MODEL" ]] && docs+=("data-model.md")

# 检查 contracts 目录（仅在其存在且有文件时）
if [[ -d "$CONTRACTS_DIR" ]] && [[ -n "$(ls -A "$CONTRACTS_DIR" 2>/dev/null)" ]]; then
    docs+=("contracts/")
fi

[[ -f "$QUICKSTART" ]] && docs+=("quickstart.md")

# 若请求包含 tasks.md 且文件存在，则加入列表
if $INCLUDE_TASKS && [[ -f "$TASKS" ]]; then
    docs+=("tasks.md")
fi

# 输出结果
if $JSON_MODE; then
    # 构建文档 JSON 数组
    if [[ ${#docs[@]} -eq 0 ]]; then
        json_docs="[]"
    else
        json_docs=$(printf '"%s",' "${docs[@]}")
        json_docs="[${json_docs%,}]"
    fi
    
    printf '{"FEATURE_DIR":"%s","AVAILABLE_DOCS":%s}\n' "$FEATURE_DIR" "$json_docs"
else
    # 文本输出
    echo "FEATURE_DIR:$FEATURE_DIR"
    echo "AVAILABLE_DOCS:"
    
    # 显示每个候选文档的状态
    check_file "$RESEARCH" "research.md"
    check_file "$DATA_MODEL" "data-model.md"
    check_dir "$CONTRACTS_DIR" "contracts/"
    check_file "$QUICKSTART" "quickstart.md"
    
    if $INCLUDE_TASKS; then
        check_file "$TASKS" "tasks.md"
    fi
fi
