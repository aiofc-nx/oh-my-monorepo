#!/usr/bin/env bash

# 根据 plan.md 中的信息更新代理上下文文件
#
# 该脚本通过解析特性规范来维护 AI 代理上下文文件，
# 并将项目信息更新到代理专用配置文件中。
#
# 主要功能：
# 1. 环境校验
#    - 验证 git 仓库结构与分支信息
#    - 检查所需的 plan.md 文件与模板
#    - 校验文件权限与可访问性
#
# 2. 计划数据提取
#    - 解析 plan.md 文件并提取项目元数据
#    - 识别语言/版本、框架、数据库与项目类型
#    - 对缺失或不完整的规范数据进行稳健处理
#
# 3. 代理文件管理
#    - 需要时基于模板创建新的代理上下文文件
#    - 用新的项目信息更新已有代理文件
#    - 保留手工添加内容与自定义配置
#    - 支持多种 AI 代理格式和目录结构
#
# 4. 内容生成
#    - 生成语言相关的构建/测试命令
#    - 创建合适的项目目录结构
#    - 更新技术栈与最近变更章节
#    - 保持一致的格式与时间戳
#
# 5. 多代理支持
#    - 处理代理专用文件路径与命名约定
#    - 支持：Claude、Gemini、Copilot、Cursor、Qwen、opencode、Codex、Windsurf、Kilo Code、Auggie CLI、Roo Code、CodeBuddy CLI、Qoder CLI、Amp、SHAI、Kiro CLI、Antigravity
#    - 可更新单个代理或所有已存在代理文件
#    - 若不存在代理文件则创建默认 Claude 文件
#
# 用法：./update-agent-context.sh [agent_type]
# 代理类型：claude|gemini|copilot|cursor-agent|qwen|opencode|codex|windsurf|kilocode|auggie|roo|codebuddy|amp|shai|kiro-cli|agy|bob|qodercli
# 留空则更新所有已存在代理文件

set -e

# 启用严格错误处理
set -u
set -o pipefail

#==============================================================================
# 配置与全局变量
#==============================================================================

# 获取脚本目录并加载公共函数
SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# 从公共函数中获取所有路径与变量
eval $(get_feature_paths)

NEW_PLAN="$IMPL_PLAN"  # 为兼容现有代码保留的别名
AGENT_TYPE="${1:-}"

# 代理专用文件路径
CLAUDE_FILE="$REPO_ROOT/CLAUDE.md"
GEMINI_FILE="$REPO_ROOT/GEMINI.md"
COPILOT_FILE="$REPO_ROOT/.github/agents/copilot-instructions.md"
CURSOR_FILE="$REPO_ROOT/.cursor/rules/specify-rules.mdc"
QWEN_FILE="$REPO_ROOT/QWEN.md"
AGENTS_FILE="$REPO_ROOT/AGENTS.md"
WINDSURF_FILE="$REPO_ROOT/.windsurf/rules/specify-rules.md"
KILOCODE_FILE="$REPO_ROOT/.kilocode/rules/specify-rules.md"
AUGGIE_FILE="$REPO_ROOT/.augment/rules/specify-rules.md"
ROO_FILE="$REPO_ROOT/.roo/rules/specify-rules.md"
CODEBUDDY_FILE="$REPO_ROOT/CODEBUDDY.md"
QODER_FILE="$REPO_ROOT/QODER.md"
AMP_FILE="$REPO_ROOT/AGENTS.md"
SHAI_FILE="$REPO_ROOT/SHAI.md"
KIRO_FILE="$REPO_ROOT/AGENTS.md"
AGY_FILE="$REPO_ROOT/.agent/rules/specify-rules.md"
BOB_FILE="$REPO_ROOT/AGENTS.md"

# 模板文件
TEMPLATE_FILE="$REPO_ROOT/.specify/templates/agent-file-template.md"

# 解析 plan 数据的全局变量
NEW_LANG=""
NEW_FRAMEWORK=""
NEW_DB=""
NEW_PROJECT_TYPE=""

#==============================================================================
# 工具函数
#==============================================================================

log_info() {
    echo "INFO: $1"
}

log_success() {
    echo "✓ $1"
}

log_error() {
    echo "ERROR: $1" >&2
}

log_warning() {
    echo "WARNING: $1" >&2
}

# 临时文件清理函数
cleanup() {
    local exit_code=$?
    rm -f /tmp/agent_update_*_$$
    rm -f /tmp/manual_additions_$$
    exit $exit_code
}

# 设置清理 trap
trap cleanup EXIT INT TERM

#==============================================================================
# 校验函数
#==============================================================================

validate_environment() {
    # 检查当前分支/特性是否可用（git 或非 git）
    if [[ -z "$CURRENT_BRANCH" ]]; then
        log_error "Unable to determine current feature"
        if [[ "$HAS_GIT" == "true" ]]; then
            log_info "Make sure you're on a feature branch"
        else
            log_info "Set SPECIFY_FEATURE environment variable or create a feature first"
        fi
        exit 1
    fi
    
    # 检查 plan.md 是否存在
    if [[ ! -f "$NEW_PLAN" ]]; then
        log_error "No plan.md found at $NEW_PLAN"
        log_info "Make sure you're working on a feature with a corresponding spec directory"
        if [[ "$HAS_GIT" != "true" ]]; then
            log_info "Use: export SPECIFY_FEATURE=your-feature-name or create a new feature first"
        fi
        exit 1
    fi
    
    # 检查模板是否存在（创建新文件时需要）
    if [[ ! -f "$TEMPLATE_FILE" ]]; then
        log_warning "Template file not found at $TEMPLATE_FILE"
        log_warning "Creating new agent files will fail"
    fi
}

#==============================================================================
# 计划解析函数
#==============================================================================

extract_plan_field() {
    local field_pattern="$1"
    local plan_file="$2"
    
    grep "^\*\*${field_pattern}\*\*: " "$plan_file" 2>/dev/null | \
        head -1 | \
        sed "s|^\*\*${field_pattern}\*\*: ||" | \
        sed 's/^[ \t]*//;s/[ \t]*$//' | \
        grep -v "NEEDS CLARIFICATION" | \
        grep -v "^N/A$" || echo ""
}

parse_plan_data() {
    local plan_file="$1"
    
    if [[ ! -f "$plan_file" ]]; then
        log_error "Plan file not found: $plan_file"
        return 1
    fi
    
    if [[ ! -r "$plan_file" ]]; then
        log_error "Plan file is not readable: $plan_file"
        return 1
    fi
    
    log_info "Parsing plan data from $plan_file"
    
    NEW_LANG=$(extract_plan_field "Language/Version" "$plan_file")
    NEW_FRAMEWORK=$(extract_plan_field "Primary Dependencies" "$plan_file")
    NEW_DB=$(extract_plan_field "Storage" "$plan_file")
    NEW_PROJECT_TYPE=$(extract_plan_field "Project Type" "$plan_file")
    
    # 记录解析结果
    if [[ -n "$NEW_LANG" ]]; then
        log_info "Found language: $NEW_LANG"
    else
        log_warning "No language information found in plan"
    fi
    
    if [[ -n "$NEW_FRAMEWORK" ]]; then
        log_info "Found framework: $NEW_FRAMEWORK"
    fi
    
    if [[ -n "$NEW_DB" ]] && [[ "$NEW_DB" != "N/A" ]]; then
        log_info "Found database: $NEW_DB"
    fi
    
    if [[ -n "$NEW_PROJECT_TYPE" ]]; then
        log_info "Found project type: $NEW_PROJECT_TYPE"
    fi
}

format_technology_stack() {
    local lang="$1"
    local framework="$2"
    local parts=()
    
    # 添加非空部分
    [[ -n "$lang" && "$lang" != "NEEDS CLARIFICATION" ]] && parts+=("$lang")
    [[ -n "$framework" && "$framework" != "NEEDS CLARIFICATION" && "$framework" != "N/A" ]] && parts+=("$framework")
    
    # 按合适格式拼接
    if [[ ${#parts[@]} -eq 0 ]]; then
        echo ""
    elif [[ ${#parts[@]} -eq 1 ]]; then
        echo "${parts[0]}"
    else
        # 多个部分使用 " + " 连接
        local result="${parts[0]}"
        for ((i=1; i<${#parts[@]}; i++)); do
            result="$result + ${parts[i]}"
        done
        echo "$result"
    fi
}

#==============================================================================
# 模板与内容生成函数
#==============================================================================

get_project_structure() {
    local project_type="$1"
    
    if [[ "$project_type" == *"web"* ]]; then
        echo "backend/\\nfrontend/\\ntests/"
    else
        echo "src/\\ntests/"
    fi
}

get_commands_for_language() {
    local lang="$1"
    
    case "$lang" in
        *"Python"*)
            echo "cd src && pytest && ruff check ."
            ;;
        *"Rust"*)
            echo "cargo test && cargo clippy"
            ;;
        *"JavaScript"*|*"TypeScript"*)
            echo "npm test \\&\\& npm run lint"
            ;;
        *)
            echo "# Add commands for $lang"
            ;;
    esac
}

get_language_conventions() {
    local lang="$1"
    echo "$lang: Follow standard conventions"
}

create_new_agent_file() {
    local target_file="$1"
    local temp_file="$2"
    local project_name="$3"
    local current_date="$4"
    
    if [[ ! -f "$TEMPLATE_FILE" ]]; then
        log_error "Template not found at $TEMPLATE_FILE"
        return 1
    fi
    
    if [[ ! -r "$TEMPLATE_FILE" ]]; then
        log_error "Template file is not readable: $TEMPLATE_FILE"
        return 1
    fi
    
    log_info "Creating new agent context file from template..."
    
    if ! cp "$TEMPLATE_FILE" "$temp_file"; then
        log_error "Failed to copy template file"
        return 1
    fi
    
    # 替换模板占位符
    local project_structure
    project_structure=$(get_project_structure "$NEW_PROJECT_TYPE")
    
    local commands
    commands=$(get_commands_for_language "$NEW_LANG")
    
    local language_conventions
    language_conventions=$(get_language_conventions "$NEW_LANG")
    
    # 采用更安全的方式执行替换并进行错误检查
    # 通过不同分隔符或转义来处理 sed 特殊字符
    local escaped_lang=$(printf '%s\n' "$NEW_LANG" | sed 's/[\[\.*^$()+{}|]/\\&/g')
    local escaped_framework=$(printf '%s\n' "$NEW_FRAMEWORK" | sed 's/[\[\.*^$()+{}|]/\\&/g')
    local escaped_branch=$(printf '%s\n' "$CURRENT_BRANCH" | sed 's/[\[\.*^$()+{}|]/\\&/g')
    
    # 按条件构建技术栈与最近变更字符串
    local tech_stack
    if [[ -n "$escaped_lang" && -n "$escaped_framework" ]]; then
        tech_stack="- $escaped_lang + $escaped_framework ($escaped_branch)"
    elif [[ -n "$escaped_lang" ]]; then
        tech_stack="- $escaped_lang ($escaped_branch)"
    elif [[ -n "$escaped_framework" ]]; then
        tech_stack="- $escaped_framework ($escaped_branch)"
    else
        tech_stack="- ($escaped_branch)"
    fi

    local recent_change
    if [[ -n "$escaped_lang" && -n "$escaped_framework" ]]; then
        recent_change="- $escaped_branch: Added $escaped_lang + $escaped_framework"
    elif [[ -n "$escaped_lang" ]]; then
        recent_change="- $escaped_branch: Added $escaped_lang"
    elif [[ -n "$escaped_framework" ]]; then
        recent_change="- $escaped_branch: Added $escaped_framework"
    else
        recent_change="- $escaped_branch: Added"
    fi

    local substitutions=(
        "s|\[PROJECT NAME\]|$project_name|"
        "s|\[DATE\]|$current_date|"
        "s|\[EXTRACTED FROM ALL PLAN.MD FILES\]|$tech_stack|"
        "s|\[ACTUAL STRUCTURE FROM PLANS\]|$project_structure|g"
        "s|\[ONLY COMMANDS FOR ACTIVE TECHNOLOGIES\]|$commands|"
        "s|\[LANGUAGE-SPECIFIC, ONLY FOR LANGUAGES IN USE\]|$language_conventions|"
        "s|\[LAST 3 FEATURES AND WHAT THEY ADDED\]|$recent_change|"
    )
    
    for substitution in "${substitutions[@]}"; do
        if ! sed -i.bak -e "$substitution" "$temp_file"; then
            log_error "Failed to perform substitution: $substitution"
            rm -f "$temp_file" "$temp_file.bak"
            return 1
        fi
    done
    
    # 将 \n 序列转换为真实换行
    newline=$(printf '\n')
    sed -i.bak2 "s/\\\\n/${newline}/g" "$temp_file"

    # 清理备份文件
    rm -f "$temp_file.bak" "$temp_file.bak2"

    # 为 .mdc 文件前置 Cursor frontmatter，使规则自动生效
    if [[ "$target_file" == *.mdc ]]; then
        local frontmatter_file
        frontmatter_file=$(mktemp) || return 1
        printf '%s\n' "---" "description: Project Development Guidelines" "globs: [\"**/*\"]" "alwaysApply: true" "---" "" > "$frontmatter_file"
        cat "$temp_file" >> "$frontmatter_file"
        mv "$frontmatter_file" "$temp_file"
    fi

    return 0
}




update_existing_agent_file() {
    local target_file="$1"
    local current_date="$2"
    
    log_info "Updating existing agent context file..."
    
    # 使用单个临时文件进行原子更新
    local temp_file
    temp_file=$(mktemp) || {
        log_error "Failed to create temporary file"
        return 1
    }
    
    # 单次遍历处理文件
    local tech_stack=$(format_technology_stack "$NEW_LANG" "$NEW_FRAMEWORK")
    local new_tech_entries=()
    local new_change_entry=""
    
    # 准备新增技术条目
    if [[ -n "$tech_stack" ]] && ! grep -q "$tech_stack" "$target_file"; then
        new_tech_entries+=("- $tech_stack ($CURRENT_BRANCH)")
    fi
    
    if [[ -n "$NEW_DB" ]] && [[ "$NEW_DB" != "N/A" ]] && [[ "$NEW_DB" != "NEEDS CLARIFICATION" ]] && ! grep -q "$NEW_DB" "$target_file"; then
        new_tech_entries+=("- $NEW_DB ($CURRENT_BRANCH)")
    fi
    
    # 准备新增变更条目
    if [[ -n "$tech_stack" ]]; then
        new_change_entry="- $CURRENT_BRANCH: Added $tech_stack"
    elif [[ -n "$NEW_DB" ]] && [[ "$NEW_DB" != "N/A" ]] && [[ "$NEW_DB" != "NEEDS CLARIFICATION" ]]; then
        new_change_entry="- $CURRENT_BRANCH: Added $NEW_DB"
    fi
    
    # 检查文件中是否存在相应章节
    local has_active_technologies=0
    local has_recent_changes=0
    
    if grep -q "^## Active Technologies" "$target_file" 2>/dev/null; then
        has_active_technologies=1
    fi
    
    if grep -q "^## Recent Changes" "$target_file" 2>/dev/null; then
        has_recent_changes=1
    fi
    
    # 逐行处理文件
    local in_tech_section=false
    local in_changes_section=false
    local tech_entries_added=false
    local changes_entries_added=false
    local existing_changes_count=0
    local file_ended=false
    
    while IFS= read -r line || [[ -n "$line" ]]; do
        # 处理 Active Technologies 章节
        if [[ "$line" == "## Active Technologies" ]]; then
            echo "$line" >> "$temp_file"
            in_tech_section=true
            continue
        elif [[ $in_tech_section == true ]] && [[ "$line" =~ ^##[[:space:]] ]]; then
            # 在章节结束前插入新增技术条目
            if [[ $tech_entries_added == false ]] && [[ ${#new_tech_entries[@]} -gt 0 ]]; then
                printf '%s\n' "${new_tech_entries[@]}" >> "$temp_file"
                tech_entries_added=true
            fi
            echo "$line" >> "$temp_file"
            in_tech_section=false
            continue
        elif [[ $in_tech_section == true ]] && [[ -z "$line" ]]; then
            # 在技术章节空行前插入新增技术条目
            if [[ $tech_entries_added == false ]] && [[ ${#new_tech_entries[@]} -gt 0 ]]; then
                printf '%s\n' "${new_tech_entries[@]}" >> "$temp_file"
                tech_entries_added=true
            fi
            echo "$line" >> "$temp_file"
            continue
        fi
        
        # 处理 Recent Changes 章节
        if [[ "$line" == "## Recent Changes" ]]; then
            echo "$line" >> "$temp_file"
            # 在标题后立即添加新变更条目
            if [[ -n "$new_change_entry" ]]; then
                echo "$new_change_entry" >> "$temp_file"
            fi
            in_changes_section=true
            changes_entries_added=true
            continue
        elif [[ $in_changes_section == true ]] && [[ "$line" =~ ^##[[:space:]] ]]; then
            echo "$line" >> "$temp_file"
            in_changes_section=false
            continue
        elif [[ $in_changes_section == true ]] && [[ "$line" == "- "* ]]; then
            # 仅保留前 2 条已有变更
            if [[ $existing_changes_count -lt 2 ]]; then
                echo "$line" >> "$temp_file"
                ((existing_changes_count++))
            fi
            continue
        fi
        
        # 更新时间戳
        if [[ "$line" =~ \*\*Last\ updated\*\*:.*[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] ]]; then
            echo "$line" | sed "s/[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]/$current_date/" >> "$temp_file"
        else
            echo "$line" >> "$temp_file"
        fi
    done < "$target_file"
    
    # 循环后检查：若仍在 Active Technologies 章节且尚未添加新条目
    if [[ $in_tech_section == true ]] && [[ $tech_entries_added == false ]] && [[ ${#new_tech_entries[@]} -gt 0 ]]; then
        printf '%s\n' "${new_tech_entries[@]}" >> "$temp_file"
        tech_entries_added=true
    fi
    
    # 若章节不存在，则追加到文件末尾
    if [[ $has_active_technologies -eq 0 ]] && [[ ${#new_tech_entries[@]} -gt 0 ]]; then
        echo "" >> "$temp_file"
        echo "## Active Technologies" >> "$temp_file"
        printf '%s\n' "${new_tech_entries[@]}" >> "$temp_file"
        tech_entries_added=true
    fi
    
    if [[ $has_recent_changes -eq 0 ]] && [[ -n "$new_change_entry" ]]; then
        echo "" >> "$temp_file"
        echo "## Recent Changes" >> "$temp_file"
        echo "$new_change_entry" >> "$temp_file"
        changes_entries_added=true
    fi
    
    # 确保 Cursor .mdc 文件包含用于自动生效的 YAML frontmatter
    if [[ "$target_file" == *.mdc ]]; then
        if ! head -1 "$temp_file" | grep -q '^---'; then
            local frontmatter_file
            frontmatter_file=$(mktemp) || { rm -f "$temp_file"; return 1; }
            printf '%s\n' "---" "description: Project Development Guidelines" "globs: [\"**/*\"]" "alwaysApply: true" "---" "" > "$frontmatter_file"
            cat "$temp_file" >> "$frontmatter_file"
            mv "$frontmatter_file" "$temp_file"
        fi
    fi

    # 以原子方式将临时文件移动到目标文件
    if ! mv "$temp_file" "$target_file"; then
        log_error "Failed to update target file"
        rm -f "$temp_file"
        return 1
    fi

    return 0
}
#==============================================================================
# 代理文件更新主函数
#==============================================================================

update_agent_file() {
    local target_file="$1"
    local agent_name="$2"
    
    if [[ -z "$target_file" ]] || [[ -z "$agent_name" ]]; then
        log_error "update_agent_file requires target_file and agent_name parameters"
        return 1
    fi
    
    log_info "Updating $agent_name context file: $target_file"
    
    local project_name
    project_name=$(basename "$REPO_ROOT")
    local current_date
    current_date=$(date +%Y-%m-%d)
    
    # 若目录不存在则创建
    local target_dir
    target_dir=$(dirname "$target_file")
    if [[ ! -d "$target_dir" ]]; then
        if ! mkdir -p "$target_dir"; then
            log_error "Failed to create directory: $target_dir"
            return 1
        fi
    fi
    
    if [[ ! -f "$target_file" ]]; then
        # 基于模板创建新文件
        local temp_file
        temp_file=$(mktemp) || {
            log_error "Failed to create temporary file"
            return 1
        }
        
        if create_new_agent_file "$target_file" "$temp_file" "$project_name" "$current_date"; then
            if mv "$temp_file" "$target_file"; then
                log_success "Created new $agent_name context file"
            else
                log_error "Failed to move temporary file to $target_file"
                rm -f "$temp_file"
                return 1
            fi
        else
            log_error "Failed to create new agent file"
            rm -f "$temp_file"
            return 1
        fi
    else
        # 更新已有文件
        if [[ ! -r "$target_file" ]]; then
            log_error "Cannot read existing file: $target_file"
            return 1
        fi
        
        if [[ ! -w "$target_file" ]]; then
            log_error "Cannot write to existing file: $target_file"
            return 1
        fi
        
        if update_existing_agent_file "$target_file" "$current_date"; then
            log_success "Updated existing $agent_name context file"
        else
            log_error "Failed to update existing agent file"
            return 1
        fi
    fi
    
    return 0
}

#==============================================================================
# 代理选择与处理
#==============================================================================

update_specific_agent() {
    local agent_type="$1"
    
    case "$agent_type" in
        claude)
            update_agent_file "$CLAUDE_FILE" "Claude Code"
            ;;
        gemini)
            update_agent_file "$GEMINI_FILE" "Gemini CLI"
            ;;
        copilot)
            update_agent_file "$COPILOT_FILE" "GitHub Copilot"
            ;;
        cursor-agent)
            update_agent_file "$CURSOR_FILE" "Cursor IDE"
            ;;
        qwen)
            update_agent_file "$QWEN_FILE" "Qwen Code"
            ;;
        opencode)
            update_agent_file "$AGENTS_FILE" "opencode"
            ;;
        codex)
            update_agent_file "$AGENTS_FILE" "Codex CLI"
            ;;
        windsurf)
            update_agent_file "$WINDSURF_FILE" "Windsurf"
            ;;
        kilocode)
            update_agent_file "$KILOCODE_FILE" "Kilo Code"
            ;;
        auggie)
            update_agent_file "$AUGGIE_FILE" "Auggie CLI"
            ;;
        roo)
            update_agent_file "$ROO_FILE" "Roo Code"
            ;;
        codebuddy)
            update_agent_file "$CODEBUDDY_FILE" "CodeBuddy CLI"
            ;;
        qodercli)
            update_agent_file "$QODER_FILE" "Qoder CLI"
            ;;
        amp)
            update_agent_file "$AMP_FILE" "Amp"
            ;;
        shai)
            update_agent_file "$SHAI_FILE" "SHAI"
            ;;
        kiro-cli)
            update_agent_file "$KIRO_FILE" "Kiro CLI"
            ;;
        agy)
            update_agent_file "$AGY_FILE" "Antigravity"
            ;;
        bob)
            update_agent_file "$BOB_FILE" "IBM Bob"
            ;;
        generic)
            log_info "Generic agent: no predefined context file. Use the agent-specific update script for your agent."
            ;;
        *)
            log_error "Unknown agent type '$agent_type'"
            log_error "Expected: claude|gemini|copilot|cursor-agent|qwen|opencode|codex|windsurf|kilocode|auggie|roo|codebuddy|amp|shai|kiro-cli|agy|bob|qodercli|generic"
            exit 1
            ;;
    esac
}

update_all_existing_agents() {
    local found_agent=false
    
    # 检查每个可能的代理文件，存在则更新
    if [[ -f "$CLAUDE_FILE" ]]; then
        update_agent_file "$CLAUDE_FILE" "Claude Code"
        found_agent=true
    fi
    
    if [[ -f "$GEMINI_FILE" ]]; then
        update_agent_file "$GEMINI_FILE" "Gemini CLI"
        found_agent=true
    fi
    
    if [[ -f "$COPILOT_FILE" ]]; then
        update_agent_file "$COPILOT_FILE" "GitHub Copilot"
        found_agent=true
    fi
    
    if [[ -f "$CURSOR_FILE" ]]; then
        update_agent_file "$CURSOR_FILE" "Cursor IDE"
        found_agent=true
    fi
    
    if [[ -f "$QWEN_FILE" ]]; then
        update_agent_file "$QWEN_FILE" "Qwen Code"
        found_agent=true
    fi
    
    if [[ -f "$AGENTS_FILE" ]]; then
        update_agent_file "$AGENTS_FILE" "Codex/opencode"
        found_agent=true
    fi
    
    if [[ -f "$WINDSURF_FILE" ]]; then
        update_agent_file "$WINDSURF_FILE" "Windsurf"
        found_agent=true
    fi
    
    if [[ -f "$KILOCODE_FILE" ]]; then
        update_agent_file "$KILOCODE_FILE" "Kilo Code"
        found_agent=true
    fi

    if [[ -f "$AUGGIE_FILE" ]]; then
        update_agent_file "$AUGGIE_FILE" "Auggie CLI"
        found_agent=true
    fi
    
    if [[ -f "$ROO_FILE" ]]; then
        update_agent_file "$ROO_FILE" "Roo Code"
        found_agent=true
    fi

    if [[ -f "$CODEBUDDY_FILE" ]]; then
        update_agent_file "$CODEBUDDY_FILE" "CodeBuddy CLI"
        found_agent=true
    fi

    if [[ -f "$SHAI_FILE" ]]; then
        update_agent_file "$SHAI_FILE" "SHAI"
        found_agent=true
    fi

    if [[ -f "$QODER_FILE" ]]; then
        update_agent_file "$QODER_FILE" "Qoder CLI"
        found_agent=true
    fi

    if [[ -f "$KIRO_FILE" ]]; then
        update_agent_file "$KIRO_FILE" "Kiro CLI"
        found_agent=true
    fi

    if [[ -f "$AGY_FILE" ]]; then
        update_agent_file "$AGY_FILE" "Antigravity"
        found_agent=true
    fi
    if [[ -f "$BOB_FILE" ]]; then
        update_agent_file "$BOB_FILE" "IBM Bob"
        found_agent=true
    fi
    
    # 若不存在代理文件，则创建默认 Claude 文件
    if [[ "$found_agent" == false ]]; then
        log_info "No existing agent files found, creating default Claude file..."
        update_agent_file "$CLAUDE_FILE" "Claude Code"
    fi
}
print_summary() {
    echo
    log_info "Summary of changes:"
    
    if [[ -n "$NEW_LANG" ]]; then
        echo "  - Added language: $NEW_LANG"
    fi
    
    if [[ -n "$NEW_FRAMEWORK" ]]; then
        echo "  - Added framework: $NEW_FRAMEWORK"
    fi
    
    if [[ -n "$NEW_DB" ]] && [[ "$NEW_DB" != "N/A" ]]; then
        echo "  - Added database: $NEW_DB"
    fi
    
    echo

    log_info "Usage: $0 [claude|gemini|copilot|cursor-agent|qwen|opencode|codex|windsurf|kilocode|auggie|roo|codebuddy|amp|shai|kiro-cli|agy|bob|qodercli]"
}

#==============================================================================
# 主执行流程
#==============================================================================

main() {
    # 执行前先校验环境
    validate_environment
    
    log_info "=== Updating agent context files for feature $CURRENT_BRANCH ==="
    
    # 解析 plan 文件以提取项目信息
    if ! parse_plan_data "$NEW_PLAN"; then
        log_error "Failed to parse plan data"
        exit 1
    fi
    
    # 根据代理类型参数执行对应流程
    local success=true
    
    if [[ -z "$AGENT_TYPE" ]]; then
        # 未指定代理：更新所有已存在的代理文件
        log_info "No agent specified, updating all existing agent files..."
        if ! update_all_existing_agents; then
            success=false
        fi
    else
        # 指定了代理：仅更新该代理
        log_info "Updating specific agent: $AGENT_TYPE"
        if ! update_specific_agent "$AGENT_TYPE"; then
            success=false
        fi
    fi
    
    # 打印摘要
    print_summary
    
    if [[ "$success" == true ]]; then
        log_success "Agent context update completed successfully"
        exit 0
    else
        log_error "Agent context update completed with errors"
        exit 1
    fi
}

# 若脚本被直接执行，则调用主函数
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
