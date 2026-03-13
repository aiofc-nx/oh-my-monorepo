# oh-my-monorepo

自定义 Nx 插件包，用于简化 NestJS 和 React 项目开发。

## 包列表

| 包             | 描述                                 | 文档                                          |
| -------------- | ------------------------------------ | --------------------------------------------- |
| `@oksai/nest`  | NestJS 生成器 (Vitest + Biome)       | [README](packages/generators/nest/README.md)  |
| `@oksai/react` | React 生成器 (Vite + Vitest + Biome) | [README](packages/generators/react/README.md) |

## 特性

### 通用

- **Vite** - 快速的开发服务器和构建工具
- **Vitest** - 快速的单元测试框架
- **Biome** - 快速的 Linting 和格式化工具
- **TypeScript** - 严格模式

### @oksai/nest

- 装饰器支持 (通过 unplugin-swc)
- NestJS 应用和库生成
- Webpack + ts-loader 构建

### @oksai/react

- 多种样式方案 (CSS, SCSS, Less, styled-components, @emotion/styled)
- React Router 和 TanStack Router 支持
- Storybook 集成
- 状态管理 (Redux Toolkit, Zustand)
- Playwright E2E 测试

## 快速开始

### 安装

```bash
pnpm install
```

### 构建插件

```bash
pnpm nx build @oksai/nest
pnpm nx build @oksai/react
```

## 使用示例

### NestJS

```bash
# 创建 NestJS 应用
pnpm nx g @oksai/nest:nestjs-application --directory=apps/api

# 创建 NestJS 库
pnpm nx g @oksai/nest:nestjs-library --directory=libs/shared

# 创建带 controller 和 service 的库
pnpm nx g @oksai/nest:nestjs-library --directory=libs/user --service --controller
```

### React

```bash
# 创建 React 应用
pnpm nx g @oksai/react:application --directory=apps/web

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
pnpm nx g @oksai/react:zustand --project=web

# 添加 Playwright E2E 测试
pnpm nx g @oksai/react:playwright-e2e --project=web
```

## 生成器列表

### @oksai/nest (3 个生成器)

| 生成器               | 别名             | 描述               |
| -------------------- | ---------------- | ------------------ |
| `init`               | -                | 初始化 NestJS 依赖 |
| `nestjs-application` | `nest-app`, `na` | 创建 NestJS 应用   |
| `nestjs-library`     | `nest-lib`, `nl` | 创建 NestJS 库     |

### @oksai/react (10 个生成器)

| 生成器                    | 别名  | 描述                     |
| ------------------------- | ----- | ------------------------ |
| `application`             | `app` | 创建 React 应用          |
| `library`                 | `lib` | 创建 React 库            |
| `component`               | `c`   | 创建 React 组件          |
| `routing`                 | -     | 添加路由                 |
| `hook`                    | `h`   | 创建 React Hook          |
| `storybook-configuration` | -     | 添加 Storybook           |
| `story`                   | -     | 创建组件 Story           |
| `redux`                   | -     | 添加 Redux Toolkit       |
| `zustand`                 | -     | 添加 Zustand             |
| `playwright-e2e`          | -     | 添加 Playwright E2E 测试 |

## 与官方插件对比

### @oksai/nest vs @nx/nest

| 方面     | @oksai/nest | @nx/nest                       |
| -------- | ----------- | ------------------------------ |
| 代码量   | ~800 行     | ~25,000+ 行                    |
| 测试框架 | Vitest      | Jest, Vitest                   |
| Linter   | Biome       | ESLint                         |
| 构建工具 | Webpack     | Webpack, Vite, Rspack, Rsbuild |

### @oksai/react vs @nx/react

| 方面     | @oksai/react   | @nx/react                      |
| -------- | -------------- | ------------------------------ |
| 代码量   | ~2,200 行      | ~25,000+ 行                    |
| 测试框架 | Vitest         | Jest, Vitest                   |
| Linter   | Biome          | ESLint                         |
| 构建工具 | Vite           | Webpack, Vite, Rspack, Rsbuild |
| E2E 测试 | Playwright     | Cypress, Playwright            |
| 状态管理 | Redux, Zustand | Redux, NgRx 等                 |

## 项目结构

```
.
├── packages/
│   └── generators/
│       ├── nest/           # @oksai/nest 包
│       │   ├── src/
│       │   ├── package.json
│       │   ├── generators.json
│       │   └── README.md
│       └── react/          # @oksai/react 包
│           ├── src/
│           ├── package.json
│           ├── generators.json
│           └── README.md
├── pnpm-workspace.yaml
├── nx.json
├── package.json
└── README.md
```

## 开发

### 构建

```bash
pnpm nx build @oksai/nest
pnpm nx build @oksai/react
```

### 添加新生成器

1. 在 `src/generators/` 下创建生成器目录
2. 创建 `schema.json` 和 `schema.d.ts` 文件
3. 创建主文件 `my-generator.ts`
4. 在 `lib/` 目录下创建辅助函数
5. 在 `files/` 目录下创建模板文件
6. 在 `generators.json` 中注册生成器
7. 在 `src/index.ts` 中导出
8. 更新 `project.json` 构建命令

### 模板变量

| 变量           | 描述                            |
| -------------- | ------------------------------- |
| `fileName`     | 文件名 (如 `my-feature`)        |
| `className`    | 类名 (如 `MyFeature`)           |
| `propertyName` | 属性名 (如 `myFeature`)         |
| `projectName`  | Nx 项目名                       |
| `projectRoot`  | 项目根路径                      |
| `tmpl`         | 空字符串 (移除 `__tmpl__` 后缀) |

## License

MIT

 
