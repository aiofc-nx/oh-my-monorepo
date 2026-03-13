---
name: oksai-generators
description: Use @oksai/nest and @oksai/react to scaffold NestJS and React applications with pre-configured best practices. TRIGGER when user wants to create new apps, libs, projects, or mentions scaffolding with @oksai generators. Trigger words - create app, create lib, new project, scaffold, generate, NestJS app, React app, Vite React. ✨ Zero-config scaffolding with best practices.
---

# @oksai/nest & @oksai/react

Custom Nx generators optimized for modern web development with NestJS and React. Provides zero-config generators with best practices built-in.

> **🎯 Core Convention (MUST follow)**:
>
> - **Applications (App)** → Must be in `apps/<name>`
> - **Internal Libraries (Lib)** → Must be in `libs/<name>` (private, internal use only)
> - **Public Packages (Package)** → Must be in `packages/<name>` (publishable, external use)
> - **ALWAYS specify `--directory` explicitly** for double guarantee
>
> **Directory Purpose**:
>
> - `apps/` - Deployable applications (API, web, admin, etc.)
> - `libs/` - Internal private libraries (shared utils, domain logic, etc.)
> - `packages/` - Public packages publishable to npm (SDKs, config packages, UI components, etc.)

## What This Skill Covers

Use this skill when the user wants to:

- Create a NestJS application or library
- Create a React application or library
- Create React components, hooks, stories
- Add state management (Redux, Zustand)
- Add Storybook, E2E testing
- Generate production-ready code without manual configuration

## Available Generators

### @oksai/nest

| Generator            | Aliases          | Description        | Tech Stack                  |
| -------------------- | ---------------- | ------------------ | --------------------------- |
| `nestjs-application` | `nest-app`, `na` | NestJS application | Webpack + Vitest + Biome    |
| `nestjs-library`     | `nest-lib`, `nl` | NestJS library     | TypeScript + Vitest + Biome |
| `init`               | -                | Initialize deps    | -                           |

### @oksai/react

| Generator                 | Aliases | Description            | Tech Stack            |
| ------------------------- | ------- | ---------------------- | --------------------- |
| `application`             | `app`   | React application      | Vite + Vitest + Biome |
| `library`                 | `lib`   | React library          | Vite + Vitest + Biome |
| `component`               | `c`     | React component        | -                     |
| `hook`                    | `h`     | React hook             | -                     |
| `routing`                 | -       | Add routing            | react-router          |
| `storybook-configuration` | -       | Add Storybook          | Storybook 8           |
| `story`                   | -       | Create component story | -                     |
| `redux`                   | -       | Add Redux Toolkit      | @reduxjs/toolkit      |
| `zustand`                 | -       | Add Zustand            | zustand               |
| `playwright-e2e`          | -       | Add Playwright E2E     | @playwright/test      |

## Key Advantages

| Feature               | Official @nx/xxx    | @oksai/nest & @oksai/react |
| --------------------- | ------------------- | -------------------------- |
| **Code Size**         | ~25,000+ lines      | ✅ ~3,000 lines            |
| **Configuration**     | High (manual setup) | ✅ Low (zero-config)       |
| **Linter**            | ESLint              | ✅ Biome (faster)          |
| **Testing**           | Jest/Vitest         | ✅ Vitest (faster)         |
| **Decorator Support** | Manual              | ✅ Auto-configured         |
| **TypeScript**        | Manual config       | ✅ Auto-configured         |
| **Learning Curve**    | Steep               | ✅ Gentle                  |

## Steps

### 1. Identify Project Type

Ask the user:

1. **Framework**: NestJS or React?
2. **Artifact Type**: Application or library?
3. **Library Options** (if applicable):
   - Buildable? (has its own build step)
   - Publishable? (publishing to npm)
   - Controller/Service? (NestJS only)
4. **React-specific Options**:
   - Style: CSS / SCSS / Less / styled-components / none
   - Add routing?
   - Add Storybook?
   - Add state management?

**Important**: Determine the correct directory based on artifact type:

- Application → `apps/<name>`
- Library → `libs/<name>`

### 2. Select Generator

Choose based on the user's needs:

```bash
# NestJS
@oksai/nest:nestjs-application  # or: nest-app, na
@oksai/nest:nestjs-library      # or: nest-lib, nl

# React
@oksai/react:application        # or: app
@oksai/react:library            # or: lib
@oksai/react:component          # or: c
@oksai/react:hook               # or: h
@oksai/react:routing
@oksai/react:storybook-configuration
@oksai/react:story
@oksai/react:redux
@oksai/react:zustand
@oksai/react:playwright-e2e
```

### 3. Check Generator Options

View available options:

```bash
# List NestJS generators
pnpm nx list @oksai/nest

# List React generators
pnpm nx list @oksai/react

# Get help for specific generator
pnpm nx g @oksai/nest:nestjs-application --help
pnpm nx g @oksai/react:application --help
```

### 4. Dry-Run First

**Always use `--dry-run` to preview changes:**

```bash
# NestJS app
pnpm nx g @oksai/nest:nestjs-application --directory=apps/api --dry-run

# React app
pnpm nx g @oksai/react:application --directory=apps/web --dry-run

# React component
pnpm nx g @oksai/react:component --name=Button --project=web --dry-run
```

Review the output carefully. Check:

- ✅ **File locations are in the correct directory** (`apps/` or `libs/`)
- ✅ Project name matches expectations
- ✅ Configuration files are included

### 5. Run Generator

Execute the generator with appropriate options. **ALWAYS specify `--directory` explicitly:**

#### NestJS Application

```bash
# Basic
pnpm nx g @oksai/nest:nestjs-application --directory=apps/api

# With alias
pnpm nx g @oksai/nest:na --directory=apps/api

# With tags
pnpm nx g @oksai/nest:nestjs-application --directory=apps/api --tags=type:app,domain:user
```

**Auto-configured:**

- ✅ Webpack bundler + ts-loader
- ✅ Vitest testing with unplugin-swc (decorator support)
- ✅ Biome linting
- ✅ TypeScript decorators (`experimentalDecorators`, `emitDecoratorMetadata`)

#### NestJS Library

```bash
# Basic (non-buildable)
pnpm nx g @oksai/nest:nestjs-library --directory=libs/shared

# With controller and service
pnpm nx g @oksai/nest:nestjs-library --directory=libs/user --service --controller

# Global module
pnpm nx g @oksai/nest:nestjs-library --directory=libs/config --service --global

# Buildable
pnpm nx g @oksai/nest:nestjs-library --directory=libs/utils --buildable

# Publishable
pnpm nx g @oksai/nest:nestjs-library --directory=libs/core \
  --publishable --importPath=@myorg/core
```

#### React Application

```bash
# Basic (CSS)
pnpm nx g @oksai/react:application --directory=apps/web

# With SCSS
pnpm nx g @oksai/react:application --directory=apps/web --style=scss

# With styled-components
pnpm nx g @oksai/react:application --directory=apps/web --style=styled-components
```

**Auto-configured:**

- ✅ Vite bundler
- ✅ Vitest testing + Testing Library
- ✅ Biome linting
- ✅ TypeScript strict mode

#### React Library

```bash
# Basic
pnpm nx g @oksai/react:library --directory=libs/shared-ui

# With SCSS
pnpm nx g @oksai/react:library --directory=libs/shared-ui --style=scss
```

#### React Component

```bash
# Basic component
pnpm nx g @oksai/react:component --name=Button --project=web

# With styled-components
pnpm nx g @oksai/react:component --name=Button --project=web --style=styled-components

# Skip tests
pnpm nx g @oksai/react:component --name=Button --project=web --skipTests
```

#### React Hook

```bash
# Create hook
pnpm nx g @oksai/react:hook --name=useCounter --project=web
```

#### React Routing

```bash
# Add React Router
pnpm nx g @oksai/react:routing --project=web
```

#### Storybook

```bash
# Add Storybook
pnpm nx g @oksai/react:storybook-configuration --project=web

# Create story for component
pnpm nx g @oksai/react:story --name=Button --project=web
```

#### State Management

```bash
# Add Redux Toolkit
pnpm nx g @oksai/react:redux --project=web

# Add Zustand
pnpm nx g @oksai/react:zustand --project=web --name=counter
```

#### E2E Testing

```bash
# Add Playwright E2E
pnpm nx g @oksai/react:playwright-e2e --project=web
```

### 6. Verify Generated Code

**First, verify the project is in the correct directory:**

```bash
# For applications
ls apps/<name> && echo "✅ App directory correct" || echo "❌ ERROR: App should be in apps/<name>"

# For libraries
ls libs/<name> && echo "✅ Lib directory correct" || echo "❌ ERROR: Lib should be in libs/<name>"

# Check project configuration
pnpm nx show project <project-name>
```

**If directory is wrong, immediately delete and regenerate:**

```bash
# Delete incorrect project
rm -rf <name> <name>-e2e

# Regenerate with explicit directory
pnpm nx g @oksai/<package>:<generator> --directory=<correct-directory>/<name>
```

**Then run verification targets:**

```bash
# Build (if applicable)
pnpm nx build <project-name>

# Test
pnpm nx test <project-name>

# Lint (using Biome)
pnpm nx lint <project-name>

# Serve (for apps)
pnpm nx serve <project-name>
```

### 7. Format Code

Format all generated/modified files:

```bash
pnpm biome format --write .
```

## Common Scenarios

### Scenario 1: Full-Stack App + API

```bash
# Create backend
pnpm nx g @oksai/nest:nestjs-application --directory=apps/api

# Create frontend
pnpm nx g @oksai/react:application --directory=apps/web

# Add Storybook to frontend
pnpm nx g @oksai/react:storybook-configuration --project=web

# Verify
pnpm nx build api web
pnpm nx test api web
```

### Scenario 2: Shared Library for Monorepo

```bash
# Create shared NestJS library
pnpm nx g @oksai/nest:nestjs-library --directory=libs/shared --service --controller

# Create shared React UI library
pnpm nx g @oksai/react:library --directory=libs/shared-ui

# Verify
pnpm nx test shared shared-ui
```

### Scenario 3: React App with All Features

```bash
# Create app
pnpm nx g @oksai/react:application --directory=apps/web

# Add features
pnpm nx g @oksai/react:routing --project=web
pnpm nx g @oksai/react:storybook-configuration --project=web
pnpm nx g @oksai/react:redux --project=web
pnpm nx g @oksai/react:playwright-e2e --project=web

# Create components
pnpm nx g @oksai/react:component --name=Button --project=web
pnpm nx g @oksai/react:story --name=Button --project=web

# Create hooks
pnpm nx g @oksai/react:hook --name=useAuth --project=web
```

## Generator Options Reference

### @oksai/nest - NestJS App Options

| Option       | Type    | Default | Description                     |
| ------------ | ------- | ------- | ------------------------------- |
| `directory`  | string  | -       | Output directory (**required**) |
| `name`       | string  | -       | Application name                |
| `tags`       | string  | -       | Project tags                    |
| `strict`     | boolean | `false` | TypeScript strict mode          |
| `skipFormat` | boolean | `false` | Skip formatting                 |

### @oksai/nest - NestJS Lib Options

| Option        | Type    | Default | Description                     |
| ------------- | ------- | ------- | ------------------------------- |
| `directory`   | string  | -       | Output directory (**required**) |
| `name`        | string  | -       | Library name                    |
| `buildable`   | boolean | `false` | Add build target                |
| `publishable` | boolean | `false` | Configure for npm publishing    |
| `importPath`  | string  | -       | npm package name                |
| `controller`  | boolean | `false` | Add controller                  |
| `service`     | boolean | `false` | Add service                     |
| `global`      | boolean | `false` | Global module                   |

### @oksai/react - React App Options

| Option       | Type    | Default | Description                                         |
| ------------ | ------- | ------- | --------------------------------------------------- |
| `directory`  | string  | -       | Output directory (**required**)                     |
| `name`       | string  | -       | Application name                                    |
| `style`      | string  | `css`   | Style: css / scss / less / styled-components / none |
| `tags`       | string  | -       | Project tags                                        |
| `skipFormat` | boolean | `false` | Skip formatting                                     |

### @oksai/react - React Lib Options

| Option      | Type    | Default | Description                                         |
| ----------- | ------- | ------- | --------------------------------------------------- |
| `directory` | string  | -       | Output directory (**required**)                     |
| `name`      | string  | -       | Library name                                        |
| `style`     | string  | `css`   | Style: css / scss / less / styled-components / none |
| `skipTests` | boolean | `false` | Skip test files                                     |

### @oksai/react - Component Options

| Option      | Type    | Default | Description                                         |
| ----------- | ------- | ------- | --------------------------------------------------- |
| `name`      | string  | -       | Component name (**required**)                       |
| `project`   | string  | -       | Project name (**required**)                         |
| `directory` | string  | -       | Directory within project                            |
| `style`     | string  | `css`   | Style: css / scss / less / styled-components / none |
| `skipTests` | boolean | `false` | Skip test files                                     |
| `export`    | boolean | `true`  | Export from index.ts                                |
| `flat`      | boolean | `false` | Create in source root                               |

### @oksai/react - Hook Options

| Option      | Type    | Default | Description                 |
| ----------- | ------- | ------- | --------------------------- |
| `name`      | string  | -       | Hook name (**required**)    |
| `project`   | string  | -       | Project name (**required**) |
| `directory` | string  | `hooks` | Directory within project    |
| `skipTests` | boolean | `false` | Skip test file              |

## Troubleshooting

### Project Generated in Wrong Directory

**Solution**:

```bash
# 1. Delete incorrectly placed project
rm -rf <name> <name>-e2e

# 2. Regenerate with explicit directory
pnpm nx g @oksai/nest:nestjs-application --directory=apps/<name>
pnpm nx g @oksai/react:application --directory=apps/<name>

# 3. Verify location
ls apps/<name>
```

### Generator Not Found

```bash
# Verify packages are built
pnpm nx build @oksai/nest
pnpm nx build @oksai/react

# List available generators
pnpm nx list @oksai/nest
pnpm nx list @oksai/react
```

### Decorator Issues in NestJS Tests

The generators use `unplugin-swc` for decorator support in Vitest:

```typescript
// vitest.config.ts - auto-configured
plugins: [
  swc.vite({
    jsc: {
      parser: { syntax: 'typescript', decorators: true },
      transform: { legacyDecorator: true, decoratorMetadata: true },
    },
  }),
],
```

### Build Failures

```bash
# Check project configuration
pnpm nx show project <name>

# Clear cache and rebuild
pnpm nx reset
pnpm nx build <name> --skip-nx-cache
```

## Best Practices

1. **ALWAYS specify `--directory` explicitly** - Double guarantee correct project location
2. **Always dry-run first** - Verify file locations before generating
3. **Verify directory after generation** - Check project is in `apps/`, `libs/`, or `packages/`
4. **Use the right directory**:
   - `apps/` for deployable applications
   - `libs/` for internal private libraries (use generators)
   - `packages/` for public packages (create manually)
5. **Use tags** - Organize projects with meaningful tags
6. **Follow naming conventions** - Use kebab-case for project names
7. **Test after generating** - Verify generated code passes all checks

## Directory Convention Summary

| Artifact Type | Generator                            | Directory     |
| ------------- | ------------------------------------ | ------------- |
| NestJS App    | `@oksai/nest:nestjs-application`     | `apps/<name>` |
| NestJS Lib    | `@oksai/nest:nestjs-library`         | `libs/<name>` |
| React App     | `@oksai/react:application`           | `apps/<name>` |
| React Lib     | `@oksai/react:library`               | `libs/<name>` |
| Component     | `@oksai/react:component --project=X` | in project    |
| Hook          | `@oksai/react:hook --project=X`      | in project    |

## Related Skills

- **link-workspace-packages** - Wire up workspace dependencies after generating
- **nx-workspace** - Explore workspace structure and dependencies
- **nx-plugins** - Discover and install additional Nx plugins
