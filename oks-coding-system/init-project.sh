#!/bin/bash

# 项目结构初始化脚本
# 为 coding/prompts 工作流创建必要的目录结构

set -e

echo "🚀 初始化项目结构..."
echo ""

# 创建功能开发所需的目录结构
DIRECTORIES=(
    "docs/visions"
    "docs/user-stories"
    "docs/designs"
    "features"
    "features/step-definitions"
    "src/modules"
)

echo "📁 创建目录结构..."
for dir in "${DIRECTORIES[@]}"; do
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        echo "  ✅ $dir"
    else
        echo "  ⏭️  $dir (已存在)"
    fi
done

echo ""
echo "📝 创建配置文件..."

# 创建 features/README.md
if [ ! -f "features/README.md" ]; then
    cat > features/README.md << 'MDEOF'
# Features 目录

本目录包含 BDD 特性文件和步骤定义。

## 目录结构

```
features/
├── *.feature              # Gherkin 特性文件
├── step-definitions/      # 步骤定义
│   └── *.steps.ts
└── support/              # 测试支持文件（可选）
    └── *.ts
```

## 使用方式

1. 使用 `/workflow` 命令创建新功能
2. 特性文件会自动生成到本目录
3. 步骤定义在 `step-definitions/` 中

## 示例

```bash
# 创建新功能
/workflow 用户登录

# 运行 BDD 测试
pnpm test:e2e features/user-login.feature
```
MDEOF
    echo "  ✅ features/README.md"
else
    echo "  ⏭️  features/README.md (已存在)"
fi

echo ""
echo "✨ 项目结构初始化完成！"
echo ""
echo "📋 创建的目录:"
for dir in "${DIRECTORIES[@]}"; do
    echo "  - $dir"
done

echo ""
echo "📚 下一步:"
echo "  1. 使用 /workflow <功能名称> 开始开发新功能"
echo "  2. 或使用 /stage-1-user-story <功能名称> 创建用户故事"
echo "  3. 查看 coding/prompts/README.md 了解更多"
echo ""
