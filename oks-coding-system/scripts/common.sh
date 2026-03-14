#!/bin/bash
# Common functions and variables for coding workflow scripts
#
# This script provides unified path management and prerequisite checking
# for the TDD/BDD development workflow.
#
# Usage: source oks-coding-system/scripts/common.sh

# Get repository root with fallback
get_repo_root() {
    if git rev-parse --show-toplevel >/dev/null 2>&1; then
        git rev-parse --show-toplevel
    else
        local script_dir="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        (cd "$script_dir/../.." && pwd)
    fi
}

# Check if we have git available
has_git() {
    git rev-parse --show-toplevel >/dev/null 2>&1
}

# Find project name for a feature by searching vision documents
# Returns project name if found, empty string otherwise
find_project_for_feature() {
    local feature="$1"
    local repo_root="${2:-$(get_repo_root)}"
    local vision_dir="$repo_root/docs/visions"
    
    if [[ ! -d "$vision_dir" ]]; then
        return 0
    fi
    
    # Strategy 1: Check if feature name matches project name directly
    if [[ -f "$vision_dir/${feature}-vision.md" ]]; then
        echo "$feature"
        return 0
    fi
    
    # Strategy 2: Check if there's only one vision document (single project)
    local vision_count=$(ls -1 "$vision_dir"/*-vision.md 2>/dev/null | wc -l)
    if [[ "$vision_count" -eq 1 ]]; then
        local vision_file=$(ls -1 "$vision_dir"/*-vision.md 2>/dev/null | head -1)
        basename "$vision_file" -vision.md
        return 0
    fi
    
    # Strategy 3: Search for feature name in vision documents
    for vision_file in "$vision_dir"/*-vision.md; do
        if [[ -f "$vision_file" ]] && grep -qi "$feature" "$vision_file" 2>/dev/null; then
            basename "$vision_file" -vision.md
            return 0
        fi
    done
    
    # Strategy 4: Check user-stories directory structure
    for project_dir in "$repo_root/docs/user-stories"/*/; do
        if [[ -d "$project_dir" ]] && [[ -f "${project_dir}${feature}.md" ]]; then
            basename "$project_dir"
            return 0
        fi
    done
    
    return 0
}

# Normalize feature name to a valid directory/file name
normalize_feature_name() {
    local feature="$1"
    echo "$feature" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9\u4e00-\u9fa5]/-/g' | sed 's/-\+/-/g' | sed 's/^-//' | sed 's/-$//'
}

# Get all feature-related paths
# Usage: eval $(get_feature_paths "feature-name" ["project-name"])
get_feature_paths() {
    local feature="$1"
    local project="${2:-}"
    local repo_root=$(get_repo_root)
    local normalized=$(normalize_feature_name "$feature")
    
    # Feature directory (new mode)
    local feature_dir="$repo_root/features/$normalized"
    
    # Try to find project from vision if not provided
    if [[ -z "$project" ]]; then
        project=$(find_project_for_feature "$feature" "$repo_root")
    fi
    
    # If project found, use structured paths
    if [[ -n "$project" ]]; then
        local user_story="$repo_root/docs/user-stories/$project/$feature.md"
        local design_doc="$repo_root/docs/designs/$project/$feature.md"
    else
        # Fallback to flat structure
        local user_story="$repo_root/docs/user-stories/$feature.md"
        local design_doc="$repo_root/docs/designs/$feature.md"
    fi
    
    local bdd_feature="$repo_root/features/$feature.feature"
    local tdd_module="$repo_root/src/modules/$normalized"
    
    # Workflow state
    local workflow_state="$repo_root/oks-coding-system/state/$feature.json"
    
    cat <<EOF
REPO_ROOT='$repo_root'
FEATURE_NAME='$feature'
FEATURE_NORMALIZED='$normalized'
PROJECT_NAME='$project'
FEATURE_DIR='$feature_dir'
USER_STORY='$user_story'
DESIGN_DOC='$design_doc'
BDD_FEATURE='$bdd_feature'
TDD_MODULE='$tdd_module'
WORKFLOW_STATE='$workflow_state'
IMPL_STATUS='$feature_dir/implementation.md'
BDD_SCENARIOS='$feature_dir/bdd-scenarios.md'
DECISIONS='$feature_dir/decisions.md'
EOF
}

# Check if a file exists
check_file_exists() {
    local file="$1"
    local description="$2"
    
    if [[ -f "$file" ]]; then
        return 0
    else
        echo "ERROR: $description not found: $file" >&2
        return 1
    fi
}

# Check if a directory exists
check_dir_exists() {
    local dir="$1"
    local description="$2"
    
    if [[ -d "$dir" ]]; then
        return 0
    else
        echo "ERROR: $description not found: $dir" >&2
        return 1
    fi
}

# Validate feature name (not empty, not too short, not a stop word)
validate_feature_name() {
    local feature="$1"
    
    # Check if empty
    if [[ -z "$feature" ]]; then
        echo "ERROR: Feature name is required" >&2
        return 1
    fi
    
    # Trim whitespace
    feature=$(echo "$feature" | xargs)
    
    if [[ -z "$feature" ]]; then
        echo "ERROR: Feature name cannot be empty or contain only whitespace" >&2
        return 1
    fi
    
    # Check minimum length
    if [[ ${#feature} -lt 2 ]]; then
        echo "ERROR: Feature name too short (minimum 2 characters)" >&2
        return 1
    fi
    
    # Check stop words
    case "$feature" in
        "继续"|"测试"|"开发"|"test"|"dev"|"debug"|"temp"|"tmp"|"xxx"|"yyy"|"todo")
            echo "ERROR: '$feature' is not a valid feature name. Use a descriptive name like 'user-login' or 'shopping-cart'" >&2
            return 1
            ;;
    esac
    
    return 0
}

# Check stage prerequisites
# Maps stage names to their required files
check_stage_prerequisites() {
    local feature="$1"
    local stage="$2"
    local json_mode="${3:-false}"
    
    eval $(get_feature_paths "$feature")
    
    local missing=()
    local suggestions=()
    
    case "$stage" in
        user-story|stage-1)
            # Stage 1 has no prerequisites
            return 0
            ;;
            
        design|stage-2)
            if [[ ! -f "$USER_STORY" ]] && [[ ! -f "$DESIGN_DOC" ]]; then
                missing+=("User story document")
                suggestions+=("Run /oks-user-story $feature first")
            fi
            ;;
            
        bdd|stage-3)
            if [[ ! -f "$USER_STORY" ]] && [[ ! -f "$DESIGN_DOC" ]]; then
                missing+=("User story document")
                suggestions+=("Run /oks-user-story $feature first")
            fi
            # Design is recommended but not required for BDD
            if [[ ! -f "$DESIGN_DOC" ]]; then
                # Just a warning, not blocking
                :
            fi
            ;;
            
        tdd|stage-4)
            if [[ ! -f "$USER_STORY" ]] && [[ ! -f "$DESIGN_DOC" ]]; then
                missing+=("User story document")
                suggestions+=("Run /oks-user-story $feature first")
            fi
            if [[ ! -f "$BDD_FEATURE" ]] && [[ ! -f "$BDD_SCENARIOS" ]]; then
                missing+=("BDD scenarios")
                suggestions+=("Run /oks-bdd $feature first (or use --skip-bdd)")
            fi
            ;;
            
        implementation|stage-5)
            if [[ ! -f "$USER_STORY" ]] && [[ ! -f "$DESIGN_DOC" ]]; then
                missing+=("User story document")
                suggestions+=("Run /oks-user-story $feature first")
            fi
            if [[ ! -d "$TDD_MODULE" ]]; then
                missing+=("TDD module directory")
                suggestions+=("Run /oks-tdd $feature first")
            fi
            ;;
            
        optimization|stage-6)
            if [[ ! -d "$TDD_MODULE" ]]; then
                missing+=("TDD module directory")
                suggestions+=("Run /oks-tdd $feature first")
            fi
            # Check if there's actual code to optimize
            local has_code=false
            if [[ -d "$TDD_MODULE" ]]; then
                has_code=$(find "$TDD_MODULE" -name "*.ts" -o -name "*.js" 2>/dev/null | head -1 | wc -l)
            fi
            if [[ "$has_code" -eq 0 ]]; then
                missing+=("Implementation code")
                suggestions+=("Run /oks-implementation $feature first")
            fi
            ;;
            
        *)
            echo "ERROR: Unknown stage '$stage'" >&2
            return 1
            ;;
    esac
    
    # Report missing prerequisites
    if [[ ${#missing[@]} -gt 0 ]]; then
        if $json_mode; then
            printf '{"error":"prerequisites_missing","missing":['
            for i in "${!missing[@]}"; do
                [[ $i -gt 0 ]] && printf ','
                printf '"%s"' "${missing[$i]}"
            done
            printf '],"suggestions":['
            for i in "${!suggestions[@]}"; do
                [[ $i -gt 0 ]] && printf ','
                printf '"%s"' "${suggestions[$i]}"
            done
            printf ']}\n'
        else
            echo "ERROR: Missing prerequisites for stage '$stage':" >&2
            for i in "${!missing[@]}"; do
                echo "  - ${missing[$i]}" >&2
                echo "    → ${suggestions[$i]}" >&2
            done
        fi
        return 1
    fi
    
    return 0
}

# Get current workflow state for a feature (optional, not required)
get_workflow_state() {
    local feature="$1"
    local repo_root=$(get_repo_root)
    local state_file="$repo_root/oks-coding-system/state/$feature.json"
    
    if [[ -f "$state_file" ]]; then
        cat "$state_file"
    else
        echo "{}"
    fi
}

# Update workflow state (optional, not required)
update_workflow_state() {
    local feature="$1"
    local stage="$2"
    local status="$3"
    local repo_root=$(get_repo_root)
    local state_dir="$repo_root/oks-coding-system/state"
    
    # Ensure directory exists
    mkdir -p "$state_dir"
    
    # Note: For proper JSON updates, use jq or a proper JSON library
    # This is a simplified version - state tracking is optional
    echo "[workflow] Updated $feature: stage=$stage, status=$status" >&2
}

# Output helpers for JSON format
output_json_success() {
    local feature="$1"
    local stage="$2"
    local message="$3"
    
    eval $(get_feature_paths "$feature")
    
    printf '{"success":true,"feature":"%s","stage":"%s","message":"%s","paths":{"feature_dir":"%s","user_story":"%s","bdd_feature":"%s"}}\n' \
        "$feature" "$stage" "$message" "$FEATURE_DIR" "$USER_STORY" "$BDD_FEATURE"
}

output_json_error() {
    local message="$1"
    
    printf '{"success":false,"error":"%s"}\n' "$message"
}

# ==================== Project Management ====================
# NOTE: progress.json dependency has been removed.
# Project validation now uses Nx project configuration directly.

# Check if project exists in Nx workspace
check_project_exists() {
    local project="$1"
    local repo_root=$(get_repo_root)
    
    # Check if project exists in apps/ or libs/
    if [[ -d "$repo_root/apps/$project" ]] || [[ -d "$repo_root/libs/$project" ]]; then
        return 0
    fi
    
    # Check if project has package.json or project.json
    if [[ -f "$repo_root/apps/$project/package.json" ]] || [[ -f "$repo_root/libs/$project/package.json" ]]; then
        return 0
    fi
    
    if [[ -f "$repo_root/apps/$project/project.json" ]] || [[ -f "$repo_root/libs/$project/project.json" ]]; then
        return 0
    fi
    
    return 1
}

# Get project info from Nx or file system
get_project_info() {
    local project="$1"
    local repo_root=$(get_repo_root)
    local json_mode="${2:-false}"
    
    if ! check_project_exists "$project"; then
        if $json_mode; then
            printf '{"error":"project_not_found","message":"Project not found in workspace","suggestion":"Run /oks-new %s to create it"}\n' "$project"
        else
            echo "ERROR: Project '$project' not found in workspace" >&2
            echo "Run: /oks-new $project" >&2
        fi
        return 1
    fi
    
    # Return basic project info
    if $json_mode; then
        local project_type="unknown"
        if [[ -d "$repo_root/apps/$project" ]]; then
            project_type="application"
        elif [[ -d "$repo_root/libs/$project" ]]; then
            project_type="library"
        fi
        printf '{"project":"%s","type":"%s"}\n' "$project" "$project_type"
    fi
    
    return 0
}

# List all projects from Nx workspace
list_projects() {
    local repo_root=$(get_repo_root)
    local json_mode="${1:-false}"
    
    if $json_mode; then
        local projects=$({
            ls -1 "$repo_root/apps" 2>/dev/null
            ls -1 "$repo_root/libs" 2>/dev/null
        } | sort | uniq | tr '\n' ',' | sed 's/,$//')
        printf '{"projects":[%s]}\n' "$projects"
    else
        echo "📊 工作区项目:"
        echo ""
        if [[ -d "$repo_root/apps" ]]; then
            echo "**应用 (apps/)**:"
            ls -1 "$repo_root/apps" 2>/dev/null | sed 's/^/  - /'
            echo ""
        fi
        if [[ -d "$repo_root/libs" ]]; then
            echo "**库 (libs/)**:"
            ls -1 "$repo_root/libs" 2>/dev/null | sed 's/^/  - /'
        fi
    fi
    
    return 0
}

# Validate project exists in workspace
validate_project_initialized() {
    local project="$1"
    local json_mode="${2:-false}"
    
    # Simply check if project directory exists
    # This removes the dependency on progress.json
    if check_project_exists "$project"; then
        return 0
    fi
    
    if $json_mode; then
        printf '{"warning":"project_not_found","message":"Project not found in apps/ or libs/","suggestion":"If this is a new feature, you can proceed without project initialization"}\n'
    else
        # Only warn, don't block - allow creating new features without explicit project
        : # no-op
    fi
    
    return 0
}
