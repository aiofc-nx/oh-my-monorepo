---
description: 使用 @oksai/generators 创建新项目（应用或依赖库）
agent: build
argument-hint: '<项目名称>'
---

> **🎯 核心约定（必须遵守）**：
>
> - 应用（App）→ `apps/<name>`
> - 库（Lib）→ `libs/<name>`
> - 所有命令必须显式指定 `--directory` 参数

---

## ⚠️ 参数验证

!`if [ -z "$ARGUMENTS" ]; then
  echo "❌ **错误: 缺少项目名称**"
  echo ""
  echo "**用法**: /oks-generator <项目名称>"
  echo ""
  echo "**示例**: /oks-generator my-app"
  echo "          /oks-generator shared-utils"
  exit 1
fi`

---

# 🚀 创建新项目

使用 `@oksai/generators` 创建应用或依赖库。

**项目名称**: **$ARGUMENTS**

---

## 📋 可用生成器

| 类型            | 说明     | 生成器                             | 技术栈                            |
| --------------- | -------- | ---------------------------------- | --------------------------------- |
| **NestJS 应用** | 后端服务 | `@oksai/generators:nestjs-app`     | Webpack + Vitest + SWC            |
| **NestJS 库**   | 后端库   | `@oksai/generators:nestjs-lib`     | TypeScript + Vitest               |
| **React 应用**  | 前端应用 | `@oksai/generators:vite-react-app` | Vite + TypeScript + Tailwind 可选 |
| **React 库**    | 前端库   | `@oksai/generators:vite-react-lib` | Vite + TypeScript                 |

---

## 📁 当前项目结构

!`echo "**应用 (apps/)**:"
ls -1 apps/ 2>/dev/null | sed 's/^/  - /' || echo "  (空)"
echo ""
echo "**库 (libs/)**:"
ls -1 libs/ 2>/dev/null | sed 's/^/  - /' || echo "  (空)"`

---

## ⚡ 重要约定

**必须遵守的目录规则**：

- **应用（Application）** → 必须放在 `apps/` 目录
- **库（Library）** → 必须放在 `libs/` 目录

所有生成器命令**必须显式指定** `--directory` 参数，双重保障目录正确性。

---

## ✅ AI 执行指南

### 步骤 1: 确定项目类型

**询问用户**:

1. 项目类型: NestJS / React 应用还是库?
2. 样式方案 (仅 React): CSS / Tailwind / None
3. 是否需要构建 (仅库): buildable / publishable

### 步骤 2: 使用 @oksai/generators（推荐）

#### NestJS 应用

```bash
# 一键创建，自动配置（推荐：显式指定目录）
pnpm nx g @oksai/generators:nestjs-app <name> --directory=apps/<name>
```

**自动配置**:

- ✅ Webpack 构建
- ✅ Vitest 测试
- ✅ SWC 编译器
- ✅ 使用 `@oksai/tsconfig/nestjs-esm.json`
- ✅ 默认目录：`apps/<name>`

#### NestJS 库

```bash
# 创建 NestJS 库（推荐：显式指定目录）
pnpm nx g @oksai/generators:nestjs-lib <name> --directory=libs/<name>

# 创建可构建的库
pnpm nx g @oksai/generators:nestjs-lib <name> --directory=libs/<name> --buildable

# 创建可发布的库
pnpm nx g @oksai/generators:nestjs-lib <name> --directory=libs/<name> --publishable --importPath=@myorg/<name>
```

#### React 应用

```bash
# 创建 React 应用（默认 CSS，推荐：显式指定目录）
pnpm nx g @oksai/generators:vite-react-app <name> --directory=apps/<name>

# 创建带 Tailwind 的 React 应用
pnpm nx g @oksai/generators:vite-react-app <name> --directory=apps/<name> --style=tailwind

# 创建带路由的 React 应用
pnpm nx g @oksai/generators:vite-react-app <name> --directory=apps/<name> --routing
```

**自动配置**:

- ✅ Vite 构建
- ✅ Vitest 测试
- ✅ TypeScript 严格模式
- ✅ CSS Modules / Tailwind CSS
- ✅ 默认目录：`apps/<name>`

#### React 库

```bash
# 创建 React 库（推荐：显式指定目录）
pnpm nx g @oksai/generators:vite-react-lib <name> --directory=libs/<name>

# 创建可构建的 React 库
pnpm nx g @oksai/generators:vite-react-lib <name> --directory=libs/<name> --buildable

# 创建可发布的 React 库
pnpm nx g @oksai/generators:vite-react-lib <name> --directory=libs/<name> --publishable --importPath=@myorg/<name>
```

### 步骤 3: 验证项目生成（必须执行）

**验证项目是否在正确的目录**：

```bash
# 对于应用项目
ls apps/<name> && echo "✅ 应用目录正确" || echo "❌ 错误：应用应该在 apps/<name>"

# 对于库项目
ls libs/<name> && echo "✅ 库目录正确" || echo "❌ 错误：库应该在 libs/<name>"

# 验证项目配置
pnpm nx show project <name>
```

**如果目录错误**，立即删除并重新生成：

```bash
# 删除错误的项目
rm -rf <name> <name>-e2e

# 重新生成，显式指定目录
pnpm nx g @oksai/generators:<generator> <name> --directory=<correct-directory>/<name>
```

---

## 📝 配置选项

### NestJS 应用选项

| 选项         | 类型    | 默认值                    | 说明                         |
| ------------ | ------- | ------------------------- | ---------------------------- |
| `name`       | string  | -                         | 应用名称（必填）             |
| `directory`  | string  | `apps/<name>`             | 应用目录（**建议显式指定**） |
| `tags`       | string  | `type:app,framework:nest` | 项目标签                     |
| `skipFormat` | boolean | false                     | 跳过格式化                   |

### React 应用选项

| 选项            | 类型    | 默认值                                  | 说明                            |
| --------------- | ------- | --------------------------------------- | ------------------------------- |
| `name`          | string  | -                                       | 应用名称（必填）                |
| `directory`     | string  | `apps/<name>`                           | 应用目录（**建议显式指定**）    |
| `style`         | string  | `css`                                   | 样式方案：css / tailwind / none |
| `routing`       | boolean | false                                   | 添加 React Router               |
| `inSourceTests` | boolean | false                                   | 在源码中编写测试                |
| `tags`          | string  | `type:app,framework:react,bundler:vite` | 项目标签                        |

### 库选项（NestJS / React 通用）

| 选项          | 类型    | 默认值        | 说明                         |
| ------------- | ------- | ------------- | ---------------------------- |
| `name`        | string  | -             | 库名称（必填）               |
| `directory`   | string  | `libs/<name>` | 库目录（**建议显式指定**）   |
| `buildable`   | boolean | false         | 创建可构建的库               |
| `publishable` | boolean | false         | 创建可发布的库               |
| `importPath`  | string  | -             | npm 包名（publishable 必填） |

---

## 🎯 技术栈详情

### NestJS 技术栈

```
- 框架: NestJS
- 构建: Webpack（生产就绪）
- 测试: Vitest（快速）
- 编译: SWC（比 tsc 快 20x+）
- Linter: Biome（无 ESLint）
- 模块: ESM（面向 NestJS v12）
```

### React 技术栈

```
- 框架: React 19
- 构建: Vite（快速 HMR）
- 测试: Vitest（快速）
- 样式: CSS Modules / Tailwind CSS
- Linter: Biome（无 ESLint）
- TypeScript: 严格模式
```

---

## 🏷️ 标签建议

| 标签              | 说明         |
| ----------------- | ------------ |
| `type:app`        | 应用程序     |
| `type:lib`        | 库           |
| `type:e2e`        | E2E 测试项目 |
| `framework:nest`  | NestJS 框架  |
| `framework:react` | React 框架   |
| `bundler:vite`    | Vite 构建    |
| `bundler:webpack` | Webpack 构建 |
| `publishable`     | 可发布到 npm |
| `internal`        | 内部使用     |

---

## 📚 @oksai/tsconfig 可用配置

| 配置文件              | 适用场景            | 备注                        |
| --------------------- | ------------------- | --------------------------- |
| `nestjs-esm.json`     | NestJS 应用/库      | ⭐ 推荐，面向 NestJS 12 ESM |
| `node-library.json`   | Node.js 库/应用     | Express、Fastify 等         |
| `react-library.json`  | React 库/应用       | React 18+                   |
| `tanstack-start.json` | TanStack Start 应用 | Next.js 替代方案            |

---

## 🔍 验证生成的项目

```bash
# 检查项目是否正确创建
pnpm nx show project <name>

# 运行构建
pnpm nx build <name>

# 运行测试
pnpm nx test <name>

# 开发模式（应用）
pnpm nx serve <name>
```

---

## 📖 示例

### 创建 NestJS 应用

!`echo "**命令**: /oks-generator my-api"
echo ""
echo "AI 将执行:"
echo '```bash'
echo "# 创建 NestJS 应用（显式指定目录）"
echo "pnpm nx g @oksai/generators:nestjs-app my-api --directory=apps/my-api"
echo ""
echo "# 验证"
echo "pnpm nx build my-api"
echo "pnpm nx test my-api"
echo '```'`

---

### 创建 React 应用（Tailwind）

!`echo "**命令**: /oks-generator my-app --style=tailwind"
echo ""
echo "AI 将执行:"
echo '```bash'
echo "# 创建带 Tailwind 的 React 应用（显式指定目录）"
echo "pnpm nx g @oksai/generators:vite-react-app my-app --directory=apps/my-app --style=tailwind"
echo ""
echo "# 验证"
echo "pnpm nx build my-app"
echo "pnpm nx test my-app"
echo "pnpm nx serve my-app"
echo '```'`

---

### 创建可发布的 React 库

!`echo "**命令**: /oks-generator my-lib --publishable"
echo ""
echo "AI 将执行:"
echo '```bash'
echo "# 创建可发布的 React 库（显式指定目录）"
echo "pnpm nx g @oksai/generators:vite-react-lib my-lib \\"
echo "  --directory=libs/my-lib \\"
echo "  --publishable \\"
echo "  --importPath=@myorg/my-lib"
echo ""
echo "# 构建"
echo "pnpm nx build my-lib"
echo ""
echo "# 发布到 npm"
echo "cd dist/libs/my-lib && npm publish"
echo '```'`

---

### 创建 NestJS 库

!`echo "**命令**: /oks-generator shared-utils"
echo ""
echo "AI 将执行:"
echo '```bash'
echo "# 创建 NestJS 库（显式指定目录）"
echo "pnpm nx g @oksai/generators:nestjs-lib shared-utils --directory=libs/shared-utils"
echo ""
echo "# 验证"
echo "pnpm nx test shared-utils"
echo '```'`

---

## 🚫 已移除的手动步骤

使用 `@oksai/generators` 后，**无需手动更新**：

- ❌ ~~更新 tsconfig.json~~
- ❌ ~~配置 Vitest~~
- ❌ ~~添加 .babelrc~~
- ❌ ~~配置 SWC~~
- ❌ ~~创建 vitest.config.ts~~

**所有配置自动完成！**

---

## 📚 相关文档

- [Nx 官方文档](https://nx.dev)
- [NestJS 文档](https://docs.nestjs.com)
- [Vite 文档](https://vite.dev)
- [Vitest 文档](https://vitest.dev)
- [Tailwind CSS 文档](https://tailwindcss.com)

---

## 下一步

项目创建完成后：

1. **验证目录**: 确保项目在正确的位置

   ```bash
   # 应用应该在 apps/ 目录
   ls apps/<name>

   # 库应该在 libs/ 目录
   ls libs/<name>
   ```

2. **开发**: `pnpm nx serve <name>` (应用)
3. **构建**: `pnpm nx build <name>`
4. **测试**: `pnpm nx test <name>`
5. **代码检查**: `pnpm nx lint <name>` (使用 Biome)
6. **继续开发**: 使用 `/oks-tdd <功能名>` 开始 TDD 开发

---

## 🔧 故障排查

### 问题：项目生成在根目录而非 apps/ 或 libs/

**原因**: 未显式指定 `--directory` 参数

**解决方案**:

1. 删除错误的项目：

   ```bash
   rm -rf <name> <name>-e2e
   ```

2. 重新生成，显式指定目录：

   ```bash
   # 应用
   pnpm nx g @oksai/generators:nestjs-app <name> --directory=apps/<name>

   # 库
   pnpm nx g @oksai/generators:nestjs-lib <name> --directory=libs/<name>
   ```

### 问题：生成器提示目录已存在

**原因**: 之前生成的项目未清理干净

**解决方案**:

```bash
# 清理并重新生成
rm -rf apps/<name> apps/<name>-e2e
pnpm nx g @oksai/generators:nestjs-app <name> --directory=apps/<name>
```

---

## 🎉 @oksai/generators 的优势

| 特性             | 官方 @nx/xxx     | @oksai/generators           |
| ---------------- | ---------------- | --------------------------- |
| **配置复杂度**   | 高（需手动配置） | ✅ 低（一键生成）           |
| **Bundler 选择** | 多种选择         | ✅ 最佳实践（Vite/Webpack） |
| **Linter**       | ESLint           | ✅ Biome（更快）            |
| **测试框架**     | Jest/Vitest      | ✅ Vitest（更快）           |
| **TypeScript**   | 需手动配置       | ✅ 自动配置                 |
| **学习曲线**     | 陡峭             | ✅ 平缓                     |
