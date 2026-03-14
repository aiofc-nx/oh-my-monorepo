---
description: 查看所有项目和功能列表
agent: build
argument-hint: '[--features] [--docs]'
---

# 项目与功能列表

**本命令用途**：查看 monorepo 中所有项目、功能模块和文档状态。

**使用范围**：

- ✅ 列出所有应用（apps/）和库（libs/）
- ✅ 查看项目文档状态（vision.md、design.md 等）
- ✅ 显示测试文件数量
- ❌ 不适用于：创建项目（用 `/oks-generator`）
- ❌ 不适用于：查看命令帮助（用 `/oks-help`）

**用户输入**：`$ARGUMENTS`

---

## 📊 项目概览

!`bash -lc '
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

echo "## 📁 应用 (apps/)"
echo ""
if [ -d "$REPO_ROOT/apps" ]; then
for dir in "$REPO_ROOT/apps"/*/; do
    if [ -d "$dir" ]; then
name=$(basename "$dir")
echo "- **$name**"

      # 检查开发文档
      if [ -f "$dir/docs/specify/vision.md" ]; then
        echo "  - ✅ 愿景文档"
      fi
      if [ -f "$dir/docs/specify/design.md" ]; then
        echo "  - ✅ 设计文档"
      fi

      # 检查是否有测试
      if find "$dir" -name "*.spec.ts" -o -name "*.test.ts" 2>/dev/null | head -1 | grep -q .; then
        test_count=$(find "$dir" -name "*.spec.ts" -o -name "*.test.ts" 2>/dev/null | wc -l)
        echo "  - 🧪 $test_count 个测试文件"
      fi
    fi

done
else
echo "(空)"
fi

echo ""
echo "## 📚 内部库 (libs/)"
echo ""
if [ -d "$REPO_ROOT/libs" ]; then
has_libs=false
for dir in "$REPO_ROOT/libs"/*/; do
    if [ -d "$dir" ] && [ "$(basename "$dir")" != ".gitkeep" ]; then
has_libs=true
name=$(basename "$dir")
echo "- **$name**"
fi
done
if [ "$has_libs" = false ]; then
echo "(空)"
fi
else
echo "(空)"
fi

echo ""
echo "## 📦 公共包 (packages/)"
echo ""
if [ -d "$REPO_ROOT/packages" ]; then
for dir in "$REPO_ROOT/packages"/*/; do
    if [ -d "$dir" ]; then
name=$(basename "$dir")
echo "- **$name**"

      # 检查 package.json
      if [ -f "$dir/package.json" ]; then
        version=$(grep -o "\"version\": *\"[^\"]*\"" "$dir/package.json" | head -1 | cut -d\" -f4)
        echo "  - 版本: $version"
      fi
    fi

done
else
echo "(空)"
fi
'`

---

## 🚀 可用生成器

| 生成器                           | 说明            | 用法                                                               |
| -------------------------------- | --------------- | ------------------------------------------------------------------ |
| `@oksai/nest:nestjs-application` | NestJS 后端应用 | `pnpm nx g @oksai/nest:nestjs-application --directory=apps/<name>` |
| `@oksai/nest:nestjs-library`     | NestJS 共享库   | `pnpm nx g @oksai/nest:nestjs-library --directory=libs/<name>`     |
| `@oksai/react:application`       | React 前端应用  | `pnpm nx g @oksai/react:application --directory=apps/<name>`       |
| `@oksai/react:library`           | React 共享库    | `pnpm nx g @oksai/react:library --directory=libs/<name>`           |

---

## 🔧 常用命令

| 命令                                    | 说明             |
| --------------------------------------- | ---------------- |
| `pnpm nx show projects`                 | 列出所有项目     |
| `pnpm nx show project <name>`           | 查看项目详情     |
| `pnpm nx graph`                         | 可视化项目依赖图 |
| `pnpm nx run-many --target=build --all` | 构建所有项目     |
| `pnpm nx affected --target=test`        | 测试受影响项目   |

---

## 📝 相关命令

| 命令             | 说明         |
| ---------------- | ------------ |
| `/oks-help`      | 查看所有命令 |
| `/oks-generator` | 创建新项目   |
