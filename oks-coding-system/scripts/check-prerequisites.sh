#!/usr/bin/env bash

# Consolidated prerequisite checking script for coding workflow
#
# This script provides unified prerequisite checking for TDD/BDD workflow.
# It validates feature names, checks stage dependencies, and outputs paths.
#
# Usage: ./check-prerequisites.sh [OPTIONS]
#
# OPTIONS:
#   --json              Output in JSON format
#   --stage=<stage>     Check prerequisites for specific stage
#   --feature=<name>    Feature name (required)
#   --paths-only        Only output path variables (no validation)
#   --init              Initialize feature directory structure
#   --check-project     Validate project is initialized
#   --status            Show feature progress status
#   --help, -h          Show help message
#
# STAGES:
#   user-story, stage-1   No prerequisites
#   design, stage-2       Requires: user story document
#   bdd, stage-3          Requires: user story document (design recommended)
#   tdd, stage-4          Requires: user story + BDD scenarios (or --skip-bdd)
#   implementation, stage-5  Requires: user story + TDD module
#   optimization, stage-6    Requires: implementation code
#
# OUTPUTS:
#   JSON mode: {"FEATURE_DIR":"...", "USER_STORY":"...", ...}
#   Text mode: FEATURE_DIR: ... \n USER_STORY: ...

set -e

# Parse command line arguments
JSON_MODE=false
STAGE=""
FEATURE=""
PATHS_ONLY=false
INIT_MODE=false
STATUS_MODE=false
CHECK_PROJECT=false

for arg in "$@"; do
    case "$arg" in
        --json)
            JSON_MODE=true
            ;;
        --stage=*)
            STAGE="${arg#*=}"
            ;;
        --feature=*)
            FEATURE="${arg#*=}"
            ;;
        --paths-only)
            PATHS_ONLY=true
            ;;
        --init)
            INIT_MODE=true
            ;;
        --status)
            STATUS_MODE=true
            ;;
        --check-project)
            CHECK_PROJECT=true
            ;;
        --help|-h)
            cat << 'EOF'
Usage: check-prerequisites.sh [OPTIONS]

Consolidated prerequisite checking for TDD/BDD workflow.

OPTIONS:
  --json              Output in JSON format
  --stage=<stage>     Check prerequisites for specific stage
  --feature=<name>    Feature name (required)
  --paths-only        Only output path variables (no validation)
  --init              Initialize feature directory structure
  --status            Show feature progress status
  --help, -h          Show this help message

STAGES:
  user-story, stage-1    No prerequisites
  design, stage-2        Requires: user story document
  bdd, stage-3           Requires: user story document (design recommended)
  tdd, stage-4           Requires: user story + BDD scenarios
  implementation, stage-5   Requires: user story + TDD module
  optimization, stage-6     Requires: implementation code

EXAMPLES:
  # Check stage 2 prerequisites
  ./check-prerequisites.sh --json --stage=bdd --feature="user-login"
  
  # Get feature paths only
  ./check-prerequisites.sh --paths-only --feature="user-login"
  
  # Initialize feature directory
  ./check-prerequisites.sh --init --feature="user-login"
  
  # Show feature status
  ./check-prerequisites.sh --status --feature="user-login"

EOF
            exit 0
            ;;
        *)
            echo "ERROR: Unknown option '$arg'. Use --help for usage information." >&2
            exit 1
            ;;
    esac
done

# Source common functions
SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Validate feature name is provided
if [[ -z "$FEATURE" ]]; then
    if $JSON_MODE; then
        printf '{"error":"feature_required","message":"Feature name is required. Use --feature=<name>"}\n'
    else
        echo "ERROR: Feature name is required" >&2
        echo "Usage: check-prerequisites.sh --feature=<name> [--stage=<stage>] [--json]" >&2
    fi
    exit 1
fi

# Validate project is initialized (skip for user-story stage which can create new projects)
if [[ "$STAGE" != "user-story" ]] && [[ "$STAGE" != "stage-1" ]] && [[ -n "$STAGE" ]]; then
    if ! validate_project_initialized "$FEATURE" "$JSON_MODE"; then
        exit 1
    fi
fi

# Validate feature name format
if ! validate_feature_name "$FEATURE"; then
    if $JSON_MODE; then
        printf '{"error":"invalid_feature_name","message":"Feature name validation failed"}\n'
    fi
    exit 1
fi

# Get all paths
eval $(get_feature_paths "$FEATURE")

# If init mode, create directory structure
if $INIT_MODE; then
    mkdir -p "$FEATURE_DIR"
    mkdir -p "$(dirname "$USER_STORY")"
    mkdir -p "$(dirname "$BDD_FEATURE")"
    mkdir -p "$TDD_MODULE"
    mkdir -p "$(dirname "$WORKFLOW_STATE")"
    
    if $JSON_MODE; then
        printf '{"success":true,"message":"Feature directory initialized","FEATURE_DIR":"%s"}\n' "$FEATURE_DIR"
    else
        echo "✅ Feature directory initialized: $FEATURE_DIR"
    fi
    exit 0
fi

# If check-project mode, validate project is initialized
if $CHECK_PROJECT; then
    if validate_project_initialized "$FEATURE" "$JSON_MODE"; then
        if $JSON_MODE; then
            printf '{"success":true,"project":"%s","initialized":true}\n' "$FEATURE"
        else
            echo "✅ Project '$FEATURE' is initialized"
        fi
        exit 0
    else
        exit 1
    fi
fi

# If paths-only mode, output paths and exit
if $PATHS_ONLY; then
    if $JSON_MODE; then
        printf '{"REPO_ROOT":"%s","FEATURE_NAME":"%s","FEATURE_DIR":"%s","USER_STORY":"%s","BDD_FEATURE":"%s","TDD_MODULE":"%s"}\n' \
            "$REPO_ROOT" "$FEATURE_NAME" "$FEATURE_DIR" "$USER_STORY" "$BDD_FEATURE" "$TDD_MODULE"
    else
        echo "REPO_ROOT: $REPO_ROOT"
        echo "FEATURE_NAME: $FEATURE_NAME"
        echo "FEATURE_DIR: $FEATURE_DIR"
        echo "USER_STORY: $USER_STORY"
        echo "BDD_FEATURE: $BDD_FEATURE"
        echo "TDD_MODULE: $TDD_MODULE"
    fi
    exit 0
fi

# If stage specified, check stage prerequisites
if [[ -n "$STAGE" ]]; then
    if ! check_stage_prerequisites "$FEATURE" "$STAGE" "$JSON_MODE"; then
        exit 1
    fi
fi

# Build list of available documents
docs=()

# Check for existing files
check_and_add_doc() {
    local file="$1"
    local name="$2"
    
    if [[ -f "$file" ]]; then
        docs+=("$name")
        if ! $JSON_MODE; then
            echo "  ✓ $name"
        fi
        return 0
    else
        if ! $JSON_MODE; then
            echo "  ✗ $name (not found)"
        fi
        return 1
    fi
}

# Output results
if $JSON_MODE; then
    # Build JSON array of documents
    json_docs="[]"
    if [[ ${#docs[@]} -gt 0 ]]; then
        json_docs=$(printf '"%s",' "${docs[@]}")
        json_docs="[${json_docs%,}]"
    fi
    
    printf '{"success":true,"FEATURE_DIR":"%s","FEATURE_NAME":"%s","AVAILABLE_DOCS":%s,"PATHS":{"USER_STORY":"%s","BDD_FEATURE":"%s","TDD_MODULE":"%s","IMPL_STATUS":"%s"}}\n' \
        "$FEATURE_DIR" "$FEATURE_NAME" "$json_docs" "$USER_STORY" "$BDD_FEATURE" "$TDD_MODULE" "$IMPL_STATUS"
else
    echo "FEATURE_DIR: $FEATURE_DIR"
    echo "FEATURE_NAME: $FEATURE_NAME"
    echo ""
    echo "AVAILABLE_DOCS:"
    check_and_add_doc "$USER_STORY" "user-story.md"
    check_and_add_doc "$DESIGN_DOC" "design.md"
    check_and_add_doc "$BDD_FEATURE" "bdd.feature"
    check_and_add_doc "$BDD_SCENARIOS" "bdd-scenarios.md"
    check_and_add_doc "$IMPL_STATUS" "implementation.md"
    check_and_add_doc "$DECISIONS" "decisions.md"
    
    if [[ -d "$TDD_MODULE" ]]; then
        echo "  ✓ tdd-module/"
    else
        echo "  ✗ tdd-module/ (not found)"
    fi
fi

# Handle status mode - check actual file existence instead of progress.json
if $STATUS_MODE; then
    if $JSON_MODE; then
        # Check file existence to determine progress
        STAGE_1=$(test -f "$USER_STORY" && echo "completed" || echo "pending")
        STAGE_2=$(test -f "$BDD_FEATURE" && echo "completed" || echo "pending")
        STAGE_3=$(test -d "$TDD_MODULE" && echo "completed" || echo "pending")
        STAGE_4=$(test -f "$IMPL_STATUS" && echo "completed" || echo "pending")
        
        printf '{"success":true,"feature":"%s","stages":{"user-story":"%s","bdd":"%s","tdd":"%s","implementation":"%s"}}\n' \
            "$FEATURE_NAME" "$STAGE_1" "$STAGE_2" "$STAGE_3" "$STAGE_4"
    else
        echo ""
        echo "📊 Feature Progress: $FEATURE_NAME"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        
        # Show progress bar based on actual files
        STAGE_1=$(test -f "$USER_STORY" && echo "✅" || echo "⬜")
        STAGE_2=$(test -f "$BDD_FEATURE" && echo "✅" || echo "⬜")
        STAGE_3=$(test -d "$TDD_MODULE" && echo "✅" || echo "⬜")
        STAGE_4=$(test -f "$IMPL_STATUS" && echo "✅" || echo "⬜")
        
        COMPLETED=$(echo "$STAGE_1$STAGE_2$STAGE_3$STAGE_4" | grep -o "✅" | wc -l)
        PERCENT=$((COMPLETED * 25))
        
        echo ""
        echo "进度: $PERCENT%"
        echo ""
        echo "$STAGE_1 阶段一: 用户故事"
        echo "$STAGE_2 阶段二: BDD 场景"
        echo "$STAGE_3 阶段三: TDD 开发"
        echo "$STAGE_4 阶段四: 代码实现"
        echo "⬜ 阶段五: 代码优化"
        echo ""
        
        if [[ $PERCENT -lt 100 ]]; then
            echo "💡 继续开发: /oks-workflow $FEATURE_NAME"
        else
            echo "✅ 所有阶段已完成"
        fi
    fi
fi
