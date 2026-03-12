---
name: oksai-generators
description: Use @oksai/generators to scaffold NestJS and React applications with pre-configured best practices. TRIGGER when user wants to create new apps, libs, projects, or mentions scaffolding with @oksai generators. Trigger words - create app, create lib, new project, scaffold, generate, NestJS app, React app, Vite React, Tailwind React. ✨ Zero-config scaffolding with best practices for @oksai/generators.
---

# @oksai/generators

`@oksai/generators` is a custom collection of Nx generators optimized for modern web development with NestJS and React. It provides zero-config generators with best practices built-in.

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
- Set up projects with Vite, TypeScript, Vitest, and Tailwind CSS
- Generate production-ready code without manual configuration

## Available Generators

| Generator        | Description        | Tech Stack                              |
| ---------------- | ------------------ | --------------------------------------- |
| `nestjs-app`     | NestJS application | Webpack + Vitest + SWC                  |
| `nestjs-lib`     | NestJS library     | TypeScript + Vitest                     |
| `vite-react-app` | React application  | Vite + TypeScript + Tailwind (optional) |
| `vite-react-lib` | React library      | Vite + TypeScript                       |

## Key Advantages

| Feature            | Official @nx/xxx    | @oksai/generators      |
| ------------------ | ------------------- | ---------------------- |
| **Configuration**  | High (manual setup) | ✅ Low (zero-config)   |
| **Bundler**        | Multiple choices    | ✅ Best practices only |
| **Linter**         | ESLint              | ✅ Biome (faster)      |
| **Testing**        | Jest/Vitest         | ✅ Vitest (faster)     |
| **TypeScript**     | Manual config       | ✅ Auto-configured     |
| **Learning Curve** | Steep               | ✅ Gentle              |

## Steps

### 1. Identify Project Type

Ask the user:

1. **Framework**: NestJS or React?
2. **Artifact Type**: Application or library?
3. **Library Options** (if applicable):
   - Buildable? (has its own build step)
   - Publishable? (publishing to npm)
4. **React-specific Options**:
   - Style: CSS / Tailwind / None
   - Routing? (React Router)
   - In-source tests?

**Important**: Determine the correct directory based on artifact type:

- Application → `apps/<name>`
- Library → `libs/<name>`

### 2. Select Generator

Choose based on the user's needs:

```bash
# NestJS Application
@oksai/generators:nestjs-app

# NestJS Library
@oksai/generators:nestjs-lib

# React Application
@oksai/generators:vite-react-app

# React Library
@oksai/generators:vite-react-lib
```

### 3. Check Generator Options

View available options:

```bash
# List all generators
pnpm nx list @oksai/generators

# Get help for specific generator
pnpm nx g @oksai/generators:nestjs-app --help
pnpm nx g @oksai/generators:vite-react-app --help
```

### 4. Dry-Run First

**Always use `--dry-run` to preview changes:**

```bash
# NestJS app
pnpm nx g @oksai/generators:nestjs-app my-api --directory=apps/my-api --dry-run

# React app with Tailwind
pnpm nx g @oksai/generators:vite-react-app my-app --directory=apps/my-app --style=tailwind --dry-run

# Buildable React lib
pnpm nx g @oksai/generators:vite-react-lib my-lib --directory=libs/my-lib --buildable --dry-run

# NestJS lib
pnpm nx g @oksai/generators:nestjs-lib shared-types --directory=libs/shared-types --dry-run
```

Review the output carefully. Check:

- ✅ **File locations are in the correct directory** (`apps/` or `libs/`)
- ✅ Project name matches expectations
- ✅ Configuration files are included
- ✅ E2E project (for apps) is in correct location

### 5. Run Generator

Execute the generator with appropriate options. **ALWAYS specify `--directory` explicitly:**

#### NestJS Application

```bash
# Basic (explicit directory)
pnpm nx g @oksai/generators:nestjs-app my-api --directory=apps/my-api

# With tags
pnpm nx g @oksai/generators:nestjs-app my-api --directory=apps/my-api --tags=type:app,domain:user
```

**Auto-configured:**

- ✅ Webpack bundler
- ✅ Vitest testing
- ✅ SWC compiler
- ✅ `@oksai/tsconfig/nestjs-esm.json`
- ✅ `vitest.config.ts`
- ✅ Default directory: `apps/<name>`

#### NestJS Library

```bash
# Basic (non-buildable)
pnpm nx g @oksai/generators:nestjs-lib my-lib --directory=libs/my-lib

# Buildable
pnpm nx g @oksai/generators:nestjs-lib my-lib --directory=libs/my-lib --buildable

# Publishable
pnpm nx g @oksai/generators:nestjs-lib my-lib \
  --directory=libs/my-lib \
  --publishable \
  --importPath=@myorg/my-lib
```

**Auto-configured:**

- ✅ TypeScript compilation
- ✅ Vitest testing
- ✅ `@oksai/tsconfig/nestjs-esm.json`
- ✅ Default directory: `libs/<name>`

#### React Application

```bash
# Basic (CSS)
pnpm nx g @oksai/generators:vite-react-app my-app --directory=apps/my-app

# With Tailwind CSS
pnpm nx g @oksai/generators:vite-react-app my-app --directory=apps/my-app --style=tailwind

# With routing
pnpm nx g @oksai/generators:vite-react-app my-app --directory=apps/my-app --routing

# With in-source tests
pnpm nx g @oksai/generators:vite-react-app my-app --directory=apps/my-app --inSourceTests

# Combined options
pnpm nx g @oksai/generators:vite-react-app my-app \
  --directory=apps/my-app \
  --style=tailwind \
  --routing
```

**Auto-configured:**

- ✅ Vite bundler
- ✅ Vitest testing
- ✅ TypeScript strict mode
- ✅ CSS Modules or Tailwind CSS
- ✅ Biome (no ESLint)
- ✅ Default directory: `apps/<name>`

#### React Library

```bash
# Basic (non-buildable)
pnpm nx g @oksai/generators:vite-react-lib my-lib --directory=libs/my-lib

# With Tailwind
pnpm nx g @oksai/generators:vite-react-lib my-lib --directory=libs/my-lib --style=tailwind

# Buildable
pnpm nx g @oksai/generators:vite-react-lib my-lib --directory=libs/my-lib --buildable

# Publishable
pnpm nx g @oksai/generators:vite-react-lib my-lib \
  --directory=libs/my-lib \
  --publishable \
  --importPath=@myorg/my-lib \
  --style=tailwind
```

**Auto-configured:**

- ✅ Vite bundler (if buildable)
- ✅ Vitest testing
- ✅ TypeScript strict mode
- ✅ Default directory: `libs/<name>`

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
pnpm nx g @oksai/generators:<generator> <name> --directory=<correct-directory>/<name>
```

**Then run verification targets:**

```bash
# Build (if applicable)
pnpm nx build <project-name>

# Test
pnpm nx test <project-name>

# Lint (using Biome)
pnpm nx lint <project-name>

# Type check
pnpm nx typecheck <project-name>
```

### 7. Modify as Needed

Generated code provides a solid foundation. Customize as needed:

- Add business logic
- Update configurations
- Add dependencies
- Create additional files

**Important:** If you remove generated test files, either write replacements or remove the `test` target from `project.json`.

### 8. Format Code

Format all generated/modified files:

```bash
# Format with Prettier (if configured)
pnpm nx format:write

# Or with Biome
pnpm biome format --write .
```

## Common Scenarios

### Scenario 1: Full-Stack App + API

```bash
# Create backend
pnpm nx g @oksai/generators:nestjs-app my-api --directory=apps/my-api

# Create frontend
pnpm nx g @oksai/generators:vite-react-app my-web --directory=apps/my-web --style=tailwind

# Verify
pnpm nx build my-api my-web
pnpm nx test my-api my-web
```

### Scenario 2: Shared Library for Monorepo

```bash
# Create shared types
pnpm nx g @oksai/generators:nestjs-lib shared-types --directory=libs/shared-types

# Create shared UI components
pnpm nx g @oksai/generators:vite-react-lib shared-ui --directory=libs/shared-ui --style=tailwind

# Verify
pnpm nx test shared-types shared-ui
```

### Scenario 3: Publishable Library (Internal)

**Note**: This creates a library for internal monorepo sharing with publish capability. For external public packages, see Scenario 4.

```bash
# Create library with publish capability (still in libs/)
pnpm nx g @oksai/generators:vite-react-lib my-component-lib \
  --directory=libs/my-component-lib \
  --publishable \
  --importPath=@myorg/my-component-lib \
  --style=tailwind

# Build
pnpm nx build my-component-lib

# Publish to npm (optional, for internal sharing)
cd dist/libs/my-component-lib
npm publish
```

### Scenario 4: Public Package (External)

**For packages intended for external/public use**, create them manually in `packages/`:

```bash
# 1. Create directory structure
mkdir -p packages/my-sdk/src

# 2. Create package.json
cat > packages/my-sdk/package.json <<'EOF'
{
  "name": "@myorg/my-sdk",
  "version": "1.0.0",
  "main": "dist/index.js",
  "types": "dist/index.d.ts",
  "files": ["dist"]
}
EOF

# 3. Create source files
echo "export const hello = () => 'Hello';" > packages/my-sdk/src/index.ts

# 4. Configure tsconfig.json
cat > packages/my-sdk/tsconfig.json <<'EOF'
{
  "extends": "@oksai/tsconfig/base.json",
  "compilerOptions": {
    "outDir": "dist",
    "rootDir": "src"
  },
  "include": ["src/**/*"]
}
EOF

# 5. Build and publish
cd packages/my-sdk
npx tsc
npm publish
```

**When to use `packages/` vs `libs/`**:

- **Use `libs/`** + `--publishable`:
  - Shared within monorepo, occasionally published to npm
  - Managed by Nx generators
  - Version follows monorepo conventions

- **Use `packages/`** (manual):
  - Designed for external/public use
  - Independent versioning and release cycle
  - Examples: SDKs, config packages, UI component libraries

## Generator Options Reference

### NestJS App Options

| Option       | Type    | Default                   | Description                                     |
| ------------ | ------- | ------------------------- | ----------------------------------------------- |
| `name`       | string  | -                         | Application name (required)                     |
| `directory`  | string  | `apps/<name>`             | Output directory (**recommend explicit value**) |
| `tags`       | string  | `type:app,framework:nest` | Project tags                                    |
| `skipFormat` | boolean | `false`                   | Skip formatting                                 |

### NestJS Lib Options

| Option        | Type    | Default                   | Description                                     |
| ------------- | ------- | ------------------------- | ----------------------------------------------- |
| `name`        | string  | -                         | Library name (required)                         |
| `directory`   | string  | `libs/<name>`             | Output directory (**recommend explicit value**) |
| `buildable`   | boolean | `false`                   | Add build target                                |
| `publishable` | boolean | `false`                   | Configure for npm publishing                    |
| `importPath`  | string  | -                         | npm package name (required if publishable)      |
| `tags`        | string  | `type:lib,framework:nest` | Project tags                                    |

### React App Options

| Option          | Type    | Default                                 | Description                                     |
| --------------- | ------- | --------------------------------------- | ----------------------------------------------- |
| `name`          | string  | -                                       | Application name (required)                     |
| `directory`     | string  | `apps/<name>`                           | Output directory (**recommend explicit value**) |
| `style`         | string  | `css`                                   | Style: `css` / `tailwind` / `none`              |
| `routing`       | boolean | `false`                                 | Add React Router                                |
| `inSourceTests` | boolean | `false`                                 | In-source testing                               |
| `tags`          | string  | `type:app,framework:react,bundler:vite` | Project tags                                    |

### React Lib Options

| Option        | Type    | Default                                 | Description                                     |
| ------------- | ------- | --------------------------------------- | ----------------------------------------------- |
| `name`        | string  | -                                       | Library name (required)                         |
| `directory`   | string  | `libs/<name>`                           | Output directory (**recommend explicit value**) |
| `style`       | string  | `css`                                   | Style: `css` / `tailwind` / `none`              |
| `buildable`   | boolean | `false`                                 | Add build target                                |
| `publishable` | boolean | `false`                                 | Configure for npm publishing                    |
| `importPath`  | string  | -                                       | npm package name (required if publishable)      |
| `tags`        | string  | `type:lib,framework:react,bundler:vite` | Project tags                                    |

## Troubleshooting

### Project Generated in Wrong Directory

**Symptom**: Project created in root directory instead of `apps/` or `libs/`

**Cause**: Missing or incorrect `--directory` parameter

**Solution**:

```bash
# 1. Delete incorrectly placed project
rm -rf <name> <name>-e2e

# 2. Regenerate with explicit directory
# For applications
pnpm nx g @oksai/generators:nestjs-app <name> --directory=apps/<name>

# For libraries
pnpm nx g @oksai/generators:nestjs-lib <name> --directory=libs/<name>

# 3. Verify location
ls apps/<name> || ls libs/<name>
```

### Generator Not Found

```bash
# Verify package is installed
pnpm nx list @oksai/generators

# Rebuild generators
cd tools/generators
pnpm build
```

### Tailwind Not Working

For React apps with `--style=tailwind`:

```bash
# Verify Tailwind config exists
cat apps/<name>/tailwind.config.js

# Check styles.css has Tailwind directives
cat apps/<name>/src/styles.css
```

### Build Failures

```bash
# Check project configuration
pnpm nx show project <name> --web

# Verify dependencies
pnpm install

# Clear cache and rebuild
pnpm nx reset
pnpm nx build <name> --skip-nx-cache
```

### Test Failures

```bash
# Run tests with verbose output
pnpm nx test <name> --reporter=verbose

# Check Vitest config
cat apps/<name>/vite.config.mts
```

### Directory Already Exists

**Symptom**: Generator reports directory already exists

**Cause**: Previous failed generation or incomplete cleanup

**Solution**:

```bash
# Remove all related directories
rm -rf apps/<name> apps/<name>-e2e libs/<name> packages/<name>

# Regenerate
pnpm nx g @oksai/generators:<generator> <name> --directory=<correct-directory>/<name>
```

### Unsure Whether to Use libs/ or packages/

**Question**: Should my library go in `libs/` or `packages/`?

**Decision Guide**:

| Criteria                       | Use `libs/`           | Use `packages/`        |
| ------------------------------ | --------------------- | ---------------------- |
| **Primary audience**           | Internal team         | External community     |
| **Publishing frequency**       | Rarely/Occasionally   | Regularly              |
| **Version management**         | Follows monorepo      | Independent            |
| **Documentation requirements** | Minimal               | Comprehensive          |
| **Breaking changes impact**    | Low (internal)        | High (external)        |
| **Examples**                   | Business logic, utils | SDKs, UI libs, configs |

**Recommendation**:

- Start in `libs/` with `--publishable` if needed
- Move to `packages/` when:
  - External users > internal users
  - Independent release cycle is required
  - Package becomes a standalone product

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
7. **Keep libs non-buildable by default** - Only add build steps when necessary
8. **Test after generating** - Verify generated code passes all checks
9. **Customize after generation** - Generators provide a foundation, not the final product

## Directory Convention Summary

| Artifact Type | Default Directory | Purpose              | Example Command                                                       |
| ------------- | ----------------- | -------------------- | --------------------------------------------------------------------- |
| NestJS App    | `apps/<name>`     | Deployable API       | `pnpm nx g @oksai/generators:nestjs-app api --directory=apps/api`     |
| React App     | `apps/<name>`     | Deployable frontend  | `pnpm nx g @oksai/generators:vite-react-app web --directory=apps/web` |
| NestJS Lib    | `libs/<name>`     | Internal private lib | `pnpm nx g @oksai/generators:nestjs-lib utils --directory=libs/utils` |
| React Lib     | `libs/<name>`     | Internal private lib | `pnpm nx g @oksai/generators:vite-react-lib ui --directory=libs/ui`   |

**Note**: For publishable packages intended for external use, manually create them in `packages/` directory (e.g., SDKs, shared configs, UI component libraries).

## Related Skills

- **link-workspace-packages** - Wire up workspace dependencies after generating
- **nx-workspace** - Explore workspace structure and dependencies
- **nx-plugins** - Discover and install additional Nx plugins
