---
description: 使用 @oksai/nest 和 @oksai/react 创建新项目
agent: build
argument-hint: '<项目名称>'
---

> **🎯 核心约定（必须遵守）**：
>
> - **应用（App）** → `apps/<name>`
> - **内部库（Internal Lib）** → `libs/<name>`（私有，仅供内部使用）
> - **公共包（Public Package）** → `packages/<name>`（可发布，供外部使用）
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

使用 `@oksai/nest` 和 `@oksai/react` 创建应用或依赖库。

**项目名称**: **$ARGUMENTS**

---

## 📋 可用生成器

| 类型            | 说明     | 生成器                           | 技术栈                   |
| --------------- | -------- | -------------------------------- | ------------------------ |
| **NestJS 应用** | 后端服务 | `@oksai/nest:nestjs-application` | Webpack + Vitest + Biome |
| **NestJS 库**   | 后端库   | `@oksai/nest:nestjs-library`     | TypeScript + Vitest      |
| **React 应用**  | 前端应用 | `@oksai/react:application`       | Vite + Vitest + Biome    |
| **React 库**    | 前端库   | `@oksai/react:library`           | Vite + TypeScript        |

---

## 📁 当前项目结构

!`echo "**应用 (apps/)**:"
ls -1 apps/ 2>/dev/null | sed 's/^/  - /' || echo "  (空)"
echo ""
echo "**内部库 (libs/)**:"
ls -1 libs/ 2>/dev/null | grep -v "^\.gitkeep$" | sed 's/^/  - /' || echo "  (空)"
echo ""
echo "**公共包 (packages/)**:"
ls -1 packages/ 2>/dev/null | sed 's/^/  - /' || echo "  (空)"`

---

## ⚡ 重要约定

**必须遵守的目录规则**：

- **应用（Application）** → 必须放在 `apps/` 目录
- **内部库（Internal Library）** → 必须放在 `libs/` 目录
- **公共包（Public Package）** → 必须放在 `packages/` 目录

**目录用途说明**：

| 目录        | 用途       | 特点                         | 示例                               |
| ----------- | ---------- | ---------------------------- | ---------------------------------- |
| `apps/`     | 应用程序   | 可部署的服务、前端应用       | `api`, `web`, `admin`              |
| `libs/`     | 内部私有库 | 仅供项目内部使用，不对外发布 | `shared`, `utils`, `domain`        |
| `packages/` | 外部公共包 | 可发布到 npm，供外部使用     | `tsconfig`, `sdk`, `ui-components` |

所有生成器命令**必须显式指定** `--directory` 参数，双重保障目录正确性。

---

## ✅ AI 执行指南

### 步骤 1: 确认项目名称

项目名称已设置为：**$ARGUMENTS**

### 步骤 2: 询问项目配置

请向用户询问以下信息（使用交互式问题）：

#### 2.1 项目类型选择

**问题**: 请选择要创建的项目类型：

| 选项            | 说明       | 目录位置      | 技术栈                            |
| --------------- | ---------- | ------------- | --------------------------------- |
| **NestJS 应用** | 后端服务   | `apps/<name>` | NestJS + Webpack + Vitest + Biome |
| **NestJS 库**   | 后端共享库 | `libs/<name>` | NestJS + TypeScript + Vitest      |
| **React 应用**  | 前端应用   | `apps/<name>` | React + Vite + Vitest + Biome     |
| **React 库**    | 前端共享库 | `libs/<name>` | React + Vite + TypeScript         |

#### 2.2 React 项目配置（仅当选择 React 项目时）

**样式方案选择**:

| 选项                  | 说明         | 适用场景                       |
| --------------------- | ------------ | ------------------------------ |
| **CSS**               | 默认样式     | 简单项目，快速开发             |
| **SCSS**              | CSS 预处理器 | 需要变量、嵌套、混入等高级特性 |
| **styled-components** | CSS-in-JS    | 组件化样式，动态样式           |
| **none**              | 不使用样式   | 无样式项目                     |

#### 2.3 NestJS 库配置（仅当选择 NestJS 库时）

**需要哪些功能**:

| 选项              | 说明                         |
| ----------------- | ---------------------------- |
| **Controller**    | 添加控制器（处理 HTTP 请求） |
| **Service**       | 添加服务（业务逻辑）         |
| **Global Module** | 创建全局模块                 |

#### 2.4 库的用途（仅当选择库类型时）

**决策指南**:

| 场景               | 推荐选择                     | 说明                      |
| ------------------ | ---------------------------- | ------------------------- |
| 主要受众是内部团队 | ✅ `libs/` (生成器)          | 仅供 monorepo 内部使用    |
| 主要受众是外部社区 | ✅ `packages/` (手动创建)    | 需要发布到 npm 供外部使用 |
| 偶尔发布到 npm     | ✅ `libs/` + `--publishable` | 版本跟随 monorepo         |
| 定期独立发布       | ✅ `packages/` (手动创建)    | 需要独立版本管理          |

**重要提示**:

- 如果用户选择创建**公共包 (packages/)**，告知用户这需要手动创建，生成器仅支持 `apps/` 和 `libs/`
- 推荐使用 `libs/` + `--publishable` 选项，除非有特殊的独立发布需求

### 步骤 3: 生成项目配置摘要

在执行生成器之前，向用户展示配置摘要：

```
📝 项目配置摘要
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
项目名称: <name>
项目类型: <NestJS 应用 / NestJS 库 / React 应用 / React 库>
目录位置: <apps/ 或 libs/><name>
样式方案: <仅 React>
附加选项: <Controller / Service / Global Module - 仅 NestJS 库>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

确认创建吗？
```

### 步骤 4: 使用生成器

#### NestJS 应用

```bash
# 创建 NestJS 应用
pnpm nx g @oksai/nest:nestjs-application --directory=apps/<name>
```

**自动配置**:

- ✅ Webpack 构建
- ✅ Vitest 测试（unplugin-swc 装饰器支持）
- ✅ Biome Lint
- ✅ TypeScript 装饰器支持

#### NestJS 库

```bash
# 创建 NestJS 库
pnpm nx g @oksai/nest:nestjs-library --directory=libs/<name>

# 创建带 controller 和 service 的库
pnpm nx g @oksai/nest:nestjs-library --directory=libs/<name> --service --controller

# 创建全局模块
pnpm nx g @oksai/nest:nestjs-library --directory=libs/<name> --service --global
```

**别名**: `nestjs-application` → `nest-app`, `na`
**别名**: `nestjs-library` → `nest-lib`, `nl`

#### React 应用

```bash
# 创建 React 应用（默认 CSS）
pnpm nx g @oksai/react:application --directory=apps/<name>

# 创建带 SCSS 的 React 应用
pnpm nx g @oksai/react:application --directory=apps/<name> --style=scss

# 创建带 styled-components 的 React 应用
pnpm nx g @oksai/react:application --directory=apps/<name> --style=styled-components
```

**自动配置**:

- ✅ Vite 构建
- ✅ Vitest 测试
- ✅ Biome Lint
- ✅ TypeScript 严格模式
- ✅ Testing Library

**别名**: `application` → `app`

#### React 库

```bash
# 创建 React 库
pnpm nx g @oksai/react:library --directory=libs/<name>
```

**别名**: `library` → `lib`

### 步骤 5: 验证项目生成（必须执行）

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
pnpm nx g @oksai/<package>:<generator> --directory=<correct-directory>/<name>
```

### 步骤 6: 添加开发文档模板（必须执行）

> ⚠️ **重要**: 此步骤不可跳过，确保所有新项目都有开发文档模板

项目创建成功后，**必须**为新项目添加开发文档模板。

#### 6.1 默认配置

| 配置项   | 默认值                    | 说明               |
| -------- | ------------------------- | ------------------ |
| 模板     | `tp_nestjs_mvc`           | 通用开发文档模板   |
| 目标目录 | `<project>/docs/specify/` | 固定位置，统一管理 |

**默认模板包含**:

- `AGENTS.md` - AI 助手开发指南
- `design.md` - 设计文档
- `implementation.md` - 实现进度跟踪
- `decisions.md` - 架构决策记录（ADR）
- `bdd-scenarios.md` - BDD 测试场景
- `user-story.md` - 用户故事
- `vision.md` - 愿景文档

#### 6.2 用户选择（可选）

向用户询问模板选择：

> 📋 **开发文档模板配置**
>
> 默认使用 `tp_nestjs_mvc` 模板，目标位置: `<project>/docs/specify/`
>
> 是否使用默认配置？
>
> - ✅ **是** - 使用默认模板 `tp_nestjs_mvc`
> - 🔄 **选择其他模板** - 从可用模板中选择

#### 6.3 可用模板列表

!`echo "📋 **可用模板**:"
echo ""
ls -1 oks-coding-system/templates/ 2>/dev/null | grep -v "README\|NAMING" | while read dir; do
  if [ -d "oks-coding-system/templates/$dir" ]; then
    echo "- **$dir**"
  fi
done`

| 模板            | 适用场景           | 包含文件                                              |
| --------------- | ------------------ | ----------------------------------------------------- |
| `tp_nestjs_mvc` | NestJS 应用/库开发 | AGENTS.md, design.md, implementation.md, decisions.md |
| `user-login`    | 示例参考           | 完整功能示例                                          |

#### 6.4 执行步骤（必须执行）

**无论用户是否选择，都必须执行此步骤**：

1. **确定配置**：
   - 如果用户未选择 → 使用默认模板 `tp_nestjs_mvc`
   - 如果用户选择其他模板 → 使用用户选择的模板

2. **复制模板到固定目录**：

```bash
# 固定配置
TEMPLATE_NAME="tp_nestjs_mvc"  # 或用户选择的模板
PROJECT_PATH="<project-path>"  # apps/<name> 或 libs/<name>
TARGET_DIR="$PROJECT_PATH/docs/specify"

# 创建目标目录
mkdir -p "$TARGET_DIR"

# 复制模板文件
cp -r oks-coding-system/templates/$TEMPLATE_NAME/* "$TARGET_DIR/"

echo "✅ 已将模板文件复制到 $TARGET_DIR"
```

3. **自动替换占位符**：

**AI 助手必须自动执行占位符替换**：

| 占位符           | 替换为     | 获取方式                 |
| ---------------- | ---------- | ------------------------ |
| `{功能名称}`     | 项目名称   | 从步骤 1 获取            |
| `{功能名称英文}` | 项目英文名 | 同项目名称               |
| `{FEATURE}`      | 功能标识   | 同项目名称               |
| `{日期}`         | 创建日期   | `date +%Y-%m-%d`         |
| `{作者}`         | 作者名称   | 从 git config 获取或询问 |

```bash
# AI 助手执行：自动替换占位符
PROJECT_NAME="<name>"
DATE=$(date +%Y-%m-%d)
AUTHOR=$(git config user.name 2>/dev/null || echo "Developer")

# 替换所有 .md 文件中的占位符
find "$TARGET_DIR" -name "*.md" -type f -exec sed -i \
  -e "s/{功能名称}/$PROJECT_NAME/g" \
  -e "s/{功能名称英文}/$PROJECT_NAME/g" \
  -e "s/{FEATURE}/$PROJECT_NAME/g" \
  -e "s/{日期}/$DATE/g" \
  -e "s/{作者}/$AUTHOR/g" {} \;

echo "✅ 占位符替换完成"
```

#### 6.5 验证模板安装

```bash
# 验证模板是否成功安装
ls -la "<project-path>/docs/specify/"

# 应该看到以下文件:
# AGENTS.md
# design.md
# implementation.md
# decisions.md
# bdd-scenarios.md
# user-story.md
# vision.md
```

#### 6.6 完成提示

向用户展示：

```
✅ 开发文档模板已添加

📁 位置: <project>/docs/specify/
📝 模板: tp_nestjs_mvc
📄 文件: 7 个

下一步:
  1. 查看设计文档: cat <project>/docs/specify/design.md
  2. 填写需求: 告诉 AI "请审查代码库并填写 docs/specify/design.md"
  3. 开始开发: pnpm nx dev <name>
```

---

## 📝 配置选项

### NestJS 应用选项

| 选项         | 类型    | 默认值  | 说明                     |
| ------------ | ------- | ------- | ------------------------ |
| `directory`  | string  | -       | 应用目录（**必须指定**） |
| `name`       | string  | -       | 应用名称                 |
| `tags`       | string  | -       | 项目标签                 |
| `strict`     | boolean | `false` | 启用 TypeScript 严格模式 |
| `skipFormat` | boolean | `false` | 跳过格式化               |

### NestJS 库选项

| 选项          | 类型    | 默认值  | 说明                         |
| ------------- | ------- | ------- | ---------------------------- |
| `directory`   | string  | -       | 库目录（**必须指定**）       |
| `name`        | string  | -       | 库名称                       |
| `buildable`   | boolean | `false` | 创建可构建的库               |
| `publishable` | boolean | `false` | 创建可发布的库               |
| `importPath`  | string  | -       | npm 包名（publishable 必填） |
| `controller`  | boolean | `false` | 添加 controller              |
| `service`     | boolean | `false` | 添加 service                 |
| `global`      | boolean | `false` | 创建全局模块                 |

### React 应用选项

| 选项         | 类型    | 默认值  | 说明                                               |
| ------------ | ------- | ------- | -------------------------------------------------- |
| `directory`  | string  | -       | 应用目录（**必须指定**）                           |
| `name`       | string  | -       | 应用名称                                           |
| `style`      | string  | `css`   | 样式：css / scss / less / styled-components / none |
| `tags`       | string  | -       | 项目标签                                           |
| `skipFormat` | boolean | `false` | 跳过格式化                                         |

### React 库选项

| 选项        | 类型    | 默认值  | 说明                   |
| ----------- | ------- | ------- | ---------------------- |
| `directory` | string  | -       | 库目录（**必须指定**） |
| `name`      | string  | -       | 库名称                 |
| `style`     | string  | `css`   | 样式方案               |
| `skipTests` | boolean | `false` | 跳过测试文件           |

---

## 🎯 技术栈详情

### NestJS 技术栈

```
- 框架: NestJS
- 构建: Webpack + ts-loader
- 测试: Vitest + unplugin-swc（装饰器支持）
- Linter: Biome
- TypeScript: 装饰器支持（experimentalDecorators, emitDecoratorMetadata）
```

### React 技术栈

```
- 框架: React 19
- 构建: Vite
- 测试: Vitest + Testing Library
- 样式: CSS / SCSS / Less / styled-components / @emotion/styled
- Linter: Biome
- TypeScript: 严格模式
```

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
# React 应用使用 dev，NestJS 应用使用 serve
pnpm nx dev <name>      # React 应用
pnpm nx serve <name>    # NestJS 应用
```

---

## 📖 示例

### 创建 NestJS 应用

```bash
# 创建 NestJS 应用
pnpm nx g @oksai/nest:nestjs-application --directory=apps/api

# 验证
pnpm nx build api
pnpm nx test api
pnpm nx serve api
```

### 创建带 Controller 和 Service 的 NestJS 库

```bash
# 创建库
pnpm nx g @oksai/nest:nestjs-library --directory=libs/user --service --controller

# 验证
pnpm nx test user
```

### 创建 React 应用

```bash
# 创建 React 应用
pnpm nx g @oksai/react:application --directory=apps/web

# 验证
pnpm nx build web
pnpm nx test web
pnpm nx dev web    # 注意：React 使用 dev 而不是 serve
```

### 创建 React 库

```bash
# 创建 React 库
pnpm nx g @oksai/react:library --directory=libs/shared-ui

# 验证
pnpm nx test shared-ui
```

---

## 🚫 已移除的手动步骤

使用生成器后，**无需手动更新**：

- ❌ ~~更新 tsconfig.json~~
- ❌ ~~配置 Vitest~~
- ❌ ~~配置装饰器~~
- ❌ ~~创建 project.json~~

**所有配置自动完成！**

---

## 🔧 其他生成器

### @oksai/react 额外生成器

| 生成器                    | 别名 | 说明                     |
| ------------------------- | ---- | ------------------------ |
| `component`               | `c`  | 创建 React 组件          |
| `hook`                    | `h`  | 创建 React Hook          |
| `routing`                 | -    | 添加路由                 |
| `storybook-configuration` | -    | 添加 Storybook           |
| `story`                   | -    | 创建组件 Story           |
| `redux`                   | -    | 添加 Redux Toolkit       |
| `zustand`                 | -    | 添加 Zustand             |
| `playwright-e2e`          | -    | 添加 Playwright E2E 测试 |

```bash
# 创建组件
pnpm nx g @oksai/react:component --name=Button --project=web

# 创建 Hook
pnpm nx g @oksai/react:hook --name=useCounter --project=web

# 添加路由
pnpm nx g @oksai/react:routing --project=web

# 添加 Storybook
pnpm nx g @oksai/react:storybook-configuration --project=web

# 添加 Redux Toolkit
pnpm nx g @oksai/react:redux --project=web

# 添加 Zustand
pnpm nx g @oksai/react:zustand --project=web --name=counter

# 添加 E2E 测试
pnpm nx g @oksai/react:playwright-e2e --project=web
```

---

## 🎉 @oksai 插件的优势

| 特性           | 官方 @nx/xxx     | @oksai/nest & @oksai/react |
| -------------- | ---------------- | -------------------------- |
| **配置复杂度** | 高（需手动配置） | ✅ 低（一键生成）          |
| **代码量**     | ~25,000+ 行      | ✅ ~3,000 行               |
| **Linter**     | ESLint           | ✅ Biome（更快）           |
| **测试框架**   | Jest/Vitest      | ✅ Vitest（更快）          |
| **TypeScript** | 需手动配置       | ✅ 自动配置                |
| **装饰器支持** | 需手动配置       | ✅ 开箱即用                |
| **学习曲线**   | 陡峭             | ✅ 平缓                    |

---

## 📚 相关文档

- [Nx 官方文档](https://nx.dev)
- [@oksai/nest README](packages/generators/nest/README.md)
- [@oksai/react README](packages/generators/react/README.md)
- [NestJS 文档](https://docs.nestjs.com)
- [Vite 文档](https://vite.dev)
- [Vitest 文档](https://vitest.dev)

---

## 下一步

项目创建完成后：

1. **验证目录**: 确保项目在正确的位置

   ```bash
   # 应用应该在 apps/ 目录
   ls apps/<name>

   # 内部库应该在 libs/ 目录
   ls libs/<name>
   ```

2. **开发文档模板**: 如已添加，查看项目中的 `docs/` 目录

   ```bash
   # 查看文档模板
   cat apps/<name>/docs/AGENTS.md

   # 开始设计文档
   # 告诉 AI: "请审查代码库并填写 apps/<name>/docs/design.md"
   ```

3. **开发**: `pnpm nx dev <name>` (应用)
4. **构建**: `pnpm nx build <name>`
5. **测试**: `pnpm nx test <name>`
6. **代码检查**: `pnpm nx lint <name>` (使用 Biome)
