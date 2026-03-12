#!/usr/bin/env bash
#
# create-feature.sh - 从模板创建新功能目录
#
# 用法:
#   bash oks-coding-system/scripts/create-feature.sh <功能名称>
#
# 示例:
#   bash oks-coding-system/scripts/create-feature.sh 用户登录
#   bash oks-coding-system/scripts/create-feature.sh shopping-cart
#
# 选项:
#   --json              输出 JSON 格式
#   --overwrite         覆盖已存在的功能目录
#   --help, -h          显示帮助信息

set -e

# Parse command line arguments
JSON_MODE=false
OVERWRITE=false
FEATURE_NAME=""

for arg in "$@"; do
    case "$arg" in
        --json)
            JSON_MODE=true
            ;;
        --overwrite)
            OVERWRITE=true
            ;;
        --help|-h)
            cat << 'EOF'
Usage: create-feature.sh [OPTIONS] <feature-name>

Create a new feature directory from template.

OPTIONS:
  --json              Output in JSON format
  --overwrite         Overwrite existing feature directory
  --help, -h          Show this help message

EXAMPLES:
  # Create new feature
  bash oks-coding-system/scripts/create-feature.sh 用户登录

  # Overwrite existing feature
  bash oks-coding-system/scripts/create-feature.sh --overwrite 用户登录

  # JSON output
  bash oks-coding-system/scripts/create-feature.sh --json 用户登录

EOF
            exit 0
            ;;
        *)
            if [[ ! "$arg" =~ ^-- ]]; then
                FEATURE_NAME="$arg"
            fi
            ;;
    esac
done

# Validate feature name
if [[ -z "$FEATURE_NAME" ]]; then
    if $JSON_MODE; then
        printf '{"error":"feature_name_required","message":"Feature name is required"}\n'
    else
        echo "ERROR: Feature name is required" >&2
        echo "Usage: create-feature.sh <feature-name>" >&2
    fi
    exit 1
fi

# Get script directory and repository root
SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Define paths
TEMPLATE_DIR="$REPO_ROOT/oks-coding-system/templates/tp_nestjs_mvc"
FEATURE_DIR="$REPO_ROOT/oks-coding-system/templates/$FEATURE_NAME"

# Check if template exists
if [[ ! -d "$TEMPLATE_DIR" ]]; then
    if $JSON_MODE; then
        printf '{"error":"template_not_found","message":"Template directory not found: %s"}\n' "$TEMPLATE_DIR"
    else
        echo "ERROR: Template directory not found: $TEMPLATE_DIR" >&2
    fi
    exit 1
fi

# Check if feature already exists
if [[ -d "$FEATURE_DIR" ]] && ! $OVERWRITE; then
    if $JSON_MODE; then
        printf '{"error":"feature_exists","message":"Feature directory already exists","path":"%s","suggestion":"Use --overwrite to replace it"}\n' "$FEATURE_DIR"
    else
        echo "ERROR: Feature directory already exists: $FEATURE_DIR" >&2
        echo "Use --overwrite to replace it" >&2
    fi
    exit 1
fi

# Create or overwrite feature directory
if [[ -d "$FEATURE_DIR" ]]; then
    rm -rf "$FEATURE_DIR"
fi

# Copy template
cp -r "$TEMPLATE_DIR" "$FEATURE_DIR"

# Replace placeholders in all markdown files
PLACEHOLDER_PATTERNS=(
    "{{FEATURE_NAME}}"
    "{{feature_name}}"
    "{{功能名称}}"
)

# Normalize feature name for file naming
NORMALIZED_NAME=$(echo "$FEATURE_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9\u4e00-\u9fa5]/-/g' | sed 's/-\+/-/g' | sed 's/^-//' | sed 's/-$//')

# Replace placeholders
for file in "$FEATURE_DIR"/*.md; do
    if [[ -f "$file" ]]; then
        sed -i "s/{{FEATURE_NAME}}/$FEATURE_NAME/g" "$file"
        sed -i "s/{{feature_name}}/$NORMALIZED_NAME/g" "$file"
        sed -i "s/{{功能名称}}/$FEATURE_NAME/g" "$file"
        sed -i "s/{{日期}}/$(date +%Y-%m-%d)/g" "$file"
        sed -i "s/{{时间}}/$(date +%H:%M:%S)/g" "$file"
        sed -i "s/{{datetime}}/$(date -Iseconds)/g" "$file"
    fi
done

# Create additional directories
mkdir -p "$REPO_ROOT/docs/user-stories"
mkdir -p "$REPO_ROOT/features"
mkdir -p "$REPO_ROOT/src/modules/$NORMALIZED_NAME"

# List created files
CREATED_FILES=$(find "$FEATURE_DIR" -type f -name "*.md" | sort)

# Output results
if $JSON_MODE; then
    FILES_JSON=$(echo "$CREATED_FILES" | sed 's/^/"/; s/$/",/' | sed '$ s/,$//' | tr '\n' '' | sed 's/""/","/g')
    printf '{"success":true,"feature":"%s","path":"%s","files":[%s],"message":"Feature directory created successfully"}\n' \
        "$FEATURE_NAME" "$FEATURE_DIR" "$FILES_JSON"
else
    echo "✅ Feature directory created: $FEATURE_DIR"
    echo ""
    echo "📁 Created files:"
    echo "$CREATED_FILES" | while read file; do
        echo "  - $(basename "$file")"
    done
    echo ""
    echo "🎯 Next steps:"
    echo "  1. Fill in the design document:"
    echo "     $FEATURE_DIR/design.md"
    echo ""
    echo "  2. Start the workflow:"
    echo "     /oks-workflow $FEATURE_NAME"
    echo ""
    echo "  3. Or begin with user story:"
    echo "     /oks-stage-1-user-story $FEATURE_NAME"
fi
