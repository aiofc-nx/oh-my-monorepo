#!/usr/bin/env bash

set -e

JSON_MODE=false
SHORT_NAME=""
BRANCH_NUMBER=""
ARGS=()
i=1
while [ $i -le $# ]; do
    arg="${!i}"
    case "$arg" in
        --json) 
            JSON_MODE=true 
            ;;
        --short-name)
            if [ $((i + 1)) -gt $# ]; then
                echo 'Error: --short-name requires a value' >&2
                exit 1
            fi
            i=$((i + 1))
            next_arg="${!i}"
            # 检查下一个参数是否是另一个选项（以 -- 开头）
            if [[ "$next_arg" == --* ]]; then
                echo 'Error: --short-name requires a value' >&2
                exit 1
            fi
            SHORT_NAME="$next_arg"
            ;;
        --number)
            if [ $((i + 1)) -gt $# ]; then
                echo 'Error: --number requires a value' >&2
                exit 1
            fi
            i=$((i + 1))
            next_arg="${!i}"
            if [[ "$next_arg" == --* ]]; then
                echo 'Error: --number requires a value' >&2
                exit 1
            fi
            BRANCH_NUMBER="$next_arg"
            ;;
        --help|-h) 
            echo "Usage: $0 [--json] [--short-name <name>] [--number N] <feature_description>"
            echo ""
            echo "Options:"
            echo "  --json              Output in JSON format"
            echo "  --short-name <name> Provide a custom short name (2-4 words) for the branch"
            echo "  --number N          Specify branch number manually (overrides auto-detection)"
            echo "  --help, -h          Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0 'Add user authentication system' --short-name 'user-auth'"
            echo "  $0 'Implement OAuth2 integration for API' --number 5"
            exit 0
            ;;
        *) 
            ARGS+=("$arg") 
            ;;
    esac
    i=$((i + 1))
done

FEATURE_DESCRIPTION="${ARGS[*]}"
if [ -z "$FEATURE_DESCRIPTION" ]; then
    echo "Usage: $0 [--json] [--short-name <name>] [--number N] <feature_description>" >&2
    exit 1
fi

# 去除首尾空白并校验描述非空（例如用户只输入了空白字符）
FEATURE_DESCRIPTION=$(echo "$FEATURE_DESCRIPTION" | xargs)
if [ -z "$FEATURE_DESCRIPTION" ]; then
    echo "Error: Feature description cannot be empty or contain only whitespace" >&2
    exit 1
fi

# 通过搜索现有项目标记来定位仓库根目录
find_repo_root() {
    local dir="$1"
    while [ "$dir" != "/" ]; do
        if [ -d "$dir/.git" ] || [ -d "$dir/.specify" ]; then
            echo "$dir"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    return 1
}

# 获取 specs 目录中的最大编号
get_highest_from_specs() {
    local specs_dir="$1"
    local highest=0
    
    if [ -d "$specs_dir" ]; then
        for dir in "$specs_dir"/*; do
            [ -d "$dir" ] || continue
            dirname=$(basename "$dir")
            number=$(echo "$dirname" | grep -o '^[0-9]\+' || echo "0")
            number=$((10#$number))
            if [ "$number" -gt "$highest" ]; then
                highest=$number
            fi
        done
    fi
    
    echo "$highest"
}

# 从 git 分支中获取最大编号
get_highest_from_branches() {
    local highest=0
    
    # 获取所有分支（本地与远程）
    branches=$(git branch -a 2>/dev/null || echo "")
    
    if [ -n "$branches" ]; then
        while IFS= read -r branch; do
            # 清理分支名：移除前导标记和远程前缀
            clean_branch=$(echo "$branch" | sed 's/^[* ]*//; s|^remotes/[^/]*/||')
            
            # 若分支匹配 ###-* 模式，则提取特性编号
            if echo "$clean_branch" | grep -q '^[0-9]\{3\}-'; then
                number=$(echo "$clean_branch" | grep -o '^[0-9]\{3\}' || echo "0")
                number=$((10#$number))
                if [ "$number" -gt "$highest" ]; then
                    highest=$number
                fi
            fi
        done <<< "$branches"
    fi
    
    echo "$highest"
}

# 检查现有分支（本地与远程）并返回下一个可用编号
check_existing_branches() {
    local specs_dir="$1"

    # 拉取所有远程以获得最新分支信息（若无远程则忽略错误）
    git fetch --all --prune 2>/dev/null || true

    # 从所有分支中获取最大编号（不只匹配短名）
    local highest_branch=$(get_highest_from_branches)

    # 从所有 specs 中获取最大编号（不只匹配短名）
    local highest_spec=$(get_highest_from_specs "$specs_dir")

    # 取两者中的最大值
    local max_num=$highest_branch
    if [ "$highest_spec" -gt "$max_num" ]; then
        max_num=$highest_spec
    fi

    # 返回下一个编号
    echo $((max_num + 1))
}

# 清洗并格式化分支名
clean_branch_name() {
    local name="$1"
    echo "$name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/-\+/-/g' | sed 's/^-//' | sed 's/-$//'
}

# 解析仓库根目录。优先使用 git 信息；若不可用则回退到
# 搜索仓库标记，以保证在使用 --no-git 初始化的仓库中流程仍可运行。
SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if git rev-parse --show-toplevel >/dev/null 2>&1; then
    REPO_ROOT=$(git rev-parse --show-toplevel)
    HAS_GIT=true
else
    REPO_ROOT="$(find_repo_root "$SCRIPT_DIR")"
    if [ -z "$REPO_ROOT" ]; then
        echo "Error: Could not determine repository root. Please run this script from within the repository." >&2
        exit 1
    fi
    HAS_GIT=false
fi

cd "$REPO_ROOT"

SPECS_DIR="$REPO_ROOT/specs"
mkdir -p "$SPECS_DIR"

# 生成分支名：包含停用词过滤与长度过滤
generate_branch_name() {
    local description="$1"
    
    # 需要过滤的常见停用词
    local stop_words="^(i|a|an|the|to|for|of|in|on|at|by|with|from|is|are|was|were|be|been|being|have|has|had|do|does|did|will|would|should|could|can|may|might|must|shall|this|that|these|those|my|your|our|their|want|need|add|get|set)$"
    
    # 转为小写并拆分为单词
    local clean_name=$(echo "$description" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/ /g')
    
    # 过滤单词：去除停用词和长度小于 3 的词（除非原文中是大写缩写）
    local meaningful_words=()
    for word in $clean_name; do
        # 跳过空词
        [ -z "$word" ] && continue
        
        # 保留“非停用词”且（长度>=3 或可能是缩写）的词
        if ! echo "$word" | grep -qiE "$stop_words"; then
            if [ ${#word} -ge 3 ]; then
                meaningful_words+=("$word")
            elif echo "$description" | grep -q "\b${word^^}\b"; then
                # 若短词在原文中为大写形式则保留（很可能是缩写）
                meaningful_words+=("$word")
            fi
        fi
    done
    
    # 若存在有意义词，使用前 3-4 个
    if [ ${#meaningful_words[@]} -gt 0 ]; then
        local max_words=3
        if [ ${#meaningful_words[@]} -eq 4 ]; then max_words=4; fi
        
        local result=""
        local count=0
        for word in "${meaningful_words[@]}"; do
            if [ $count -ge $max_words ]; then break; fi
            if [ -n "$result" ]; then result="$result-"; fi
            result="$result$word"
            count=$((count + 1))
        done
        echo "$result"
    else
        # 若无有意义词，则回退到原始逻辑
        local cleaned=$(clean_branch_name "$description")
        echo "$cleaned" | tr '-' '\n' | grep -v '^$' | head -3 | tr '\n' '-' | sed 's/-$//'
    fi
}

# 生成分支名
if [ -n "$SHORT_NAME" ]; then
    # 使用提供的短名，仅做清洗
    BRANCH_SUFFIX=$(clean_branch_name "$SHORT_NAME")
else
    # 基于描述并通过智能过滤生成
    BRANCH_SUFFIX=$(generate_branch_name "$FEATURE_DESCRIPTION")
fi

# 确定分支编号
if [ -z "$BRANCH_NUMBER" ]; then
    if [ "$HAS_GIT" = true ]; then
        # 检查远程上的现有分支
        BRANCH_NUMBER=$(check_existing_branches "$SPECS_DIR")
    else
        # 回退到本地目录检查
        HIGHEST=$(get_highest_from_specs "$SPECS_DIR")
        BRANCH_NUMBER=$((HIGHEST + 1))
    fi
fi

# 强制按十进制解释，防止八进制转换（例如 010 在八进制为 8，但这里应为十进制 10）
FEATURE_NUM=$(printf "%03d" "$((10#$BRANCH_NUMBER))")
BRANCH_NAME="${FEATURE_NUM}-${BRANCH_SUFFIX}"

# GitHub 对分支名有 244 字节限制
# 必要时进行校验与截断
MAX_BRANCH_LENGTH=244
if [ ${#BRANCH_NAME} -gt $MAX_BRANCH_LENGTH ]; then
    # 计算后缀需要裁剪的长度
    # 需预留：特性编号(3) + 连字符(1) = 4 个字符
    MAX_SUFFIX_LENGTH=$((MAX_BRANCH_LENGTH - 4))
    
    # 尽可能在词边界处截断后缀
    TRUNCATED_SUFFIX=$(echo "$BRANCH_SUFFIX" | cut -c1-$MAX_SUFFIX_LENGTH)
    # 若截断后产生尾部连字符则移除
    TRUNCATED_SUFFIX=$(echo "$TRUNCATED_SUFFIX" | sed 's/-$//')
    
    ORIGINAL_BRANCH_NAME="$BRANCH_NAME"
    BRANCH_NAME="${FEATURE_NUM}-${TRUNCATED_SUFFIX}"
    
    >&2 echo "[specify] Warning: Branch name exceeded GitHub's 244-byte limit"
    >&2 echo "[specify] Original: $ORIGINAL_BRANCH_NAME (${#ORIGINAL_BRANCH_NAME} bytes)"
    >&2 echo "[specify] Truncated to: $BRANCH_NAME (${#BRANCH_NAME} bytes)"
fi

if [ "$HAS_GIT" = true ]; then
    if ! git checkout -b "$BRANCH_NAME" 2>/dev/null; then
        # 检查分支是否已存在
        if git branch --list "$BRANCH_NAME" | grep -q .; then
            >&2 echo "Error: Branch '$BRANCH_NAME' already exists. Please use a different feature name or specify a different number with --number."
            exit 1
        else
            >&2 echo "Error: Failed to create git branch '$BRANCH_NAME'. Please check your git configuration and try again."
            exit 1
        fi
    fi
else
    >&2 echo "[specify] Warning: Git repository not detected; skipped branch creation for $BRANCH_NAME"
fi

FEATURE_DIR="$SPECS_DIR/$BRANCH_NAME"
mkdir -p "$FEATURE_DIR"

TEMPLATE="$REPO_ROOT/.specify/templates/spec-template.md"
SPEC_FILE="$FEATURE_DIR/spec.md"
if [ -f "$TEMPLATE" ]; then cp "$TEMPLATE" "$SPEC_FILE"; else touch "$SPEC_FILE"; fi

# 为当前会话设置 SPECIFY_FEATURE 环境变量
export SPECIFY_FEATURE="$BRANCH_NAME"

if $JSON_MODE; then
    printf '{"BRANCH_NAME":"%s","SPEC_FILE":"%s","FEATURE_NUM":"%s"}\n' "$BRANCH_NAME" "$SPEC_FILE" "$FEATURE_NUM"
else
    echo "BRANCH_NAME: $BRANCH_NAME"
    echo "SPEC_FILE: $SPEC_FILE"
    echo "FEATURE_NUM: $FEATURE_NUM"
    echo "SPECIFY_FEATURE environment variable set to: $BRANCH_NAME"
fi
