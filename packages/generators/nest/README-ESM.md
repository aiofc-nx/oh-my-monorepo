# @oksai/nest

NestJS generators for Nx monorepo with ESM, Vitest, and Biome support.

## 🚀 What's New in Version 2.0

### ESM First
- **ESM by default**: All new projects use ES Modules
- **Modern module resolution**: NodeNext module resolution for better compatibility
- **Better tree-shaking**: Smaller bundle sizes with ESM

### Modern Tooling
- **Vite**: Recommended bundler for ESM projects (faster builds)
- **Vitest + SWC**: Fast testing with full decorator support
- **Standard Schema**: Support for Zod, Valibot, and ArkType

### NestJS 12 Ready
- Pre-configured for NestJS 12 ESM migration
- Standard Schema validation support
- Modern TypeScript 5.0+ features

---

## Installation

```bash
pnpm add -D @oksai/nest
```

---

## Quick Start

### Create a NestJS Application

```bash
# Create with defaults (ESM + Vite + Zod)
pnpm nx g @oksai/nest:nestjs-application --directory=apps/api

# With custom options
pnpm nx g @oksai/nest:nestjs-application \
  --directory=apps/api \
  --bundler=vite \
  --validation=zod \
  --strict
```

**Aliases:** `nest-app`, `na`

### Create a NestJS Library

```bash
# Basic library
pnpm nx g @oksai/nest:nestjs-library --directory=libs/shared

# With controller and service
pnpm nx g @oksai/nest:nestjs-library \
  --directory=libs/user \
  --service \
  --controller \
  --validation=zod
```

**Aliases:** `nest-lib`, `nl`

---

## Generator Options

### nestjs-application

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `directory` | string | - | Directory path (**required**) |
| `name` | string | - | Application name |
| `bundler` | `vite` \| `webpack` | `vite` | Build bundler (Vite recommended) |
| `validation` | `zod` \| `valibot` \| `arktype` \| `class-validator` | `zod` | Validation library |
| `strict` | boolean | `true` | Enable TypeScript strict mode |
| `tags` | string | auto | Project tags for linting |
| `skipFormat` | boolean | `false` | Skip formatting |
| `skipPackageJson` | boolean | `false` | Skip adding dependencies |

#### Examples

```bash
# Using Vite (recommended)
pnpm nx g @oksai/nest:nestjs-application \
  --directory=apps/api \
  --bundler=vite

# Using Webpack (legacy)
pnpm nx g @oksai/nest:nestjs-application \
  --directory=apps/api \
  --bundler=webpack

# With Valibot validation
pnpm nx g @oksai/nest:nestjs-application \
  --directory=apps/api \
  --validation=valibot
```

---

### nestjs-library

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `directory` | string | - | Directory path (**required**) |
| `name` | string | - | Library name |
| `buildable` | boolean | `false` | Generate buildable library |
| `publishable` | boolean | `false` | Generate publishable library |
| `importPath` | string | - | NPM import path (e.g., `@myorg/my-lib`) |
| `controller` | boolean | `false` | Include controller |
| `service` | boolean | `false` | Include service |
| `global` | boolean | `false` | Add `@Global()` decorator |
| `bundler` | `vite` \| `tsc` | `vite` | Build bundler for buildable libs |
| `validation` | `zod` \| `valibot` \| `arktype` \| `class-validator` | `zod` | Validation library |
| `unitTestRunner` | `vitest` \| `none` | `vitest` | Test runner |
| `strict` | boolean | `true` | Enable strict mode |
| `tags` | string | auto | Project tags |
| `skipFormat` | boolean | `false` | Skip formatting |
| `skipTsConfig` | boolean | `false` | Skip tsconfig updates |
| `skipPackageJson` | boolean | `false` | Skip adding dependencies |

#### Examples

```bash
# Buildable library with Vite
pnpm nx g @oksai/nest:nestjs-library \
  --directory=libs/utils \
  --buildable \
  --bundler=vite

# Publishable library with custom import path
pnpm nx g @oksai/nest:nestjs-library \
  --directory=libs/core \
  --publishable \
  --importPath=@myorg/core

# Global module with service
pnpm nx g @oksai/nest:nestjs-library \
  --directory=libs/config \
  --service \
  --global
```

---

## Generated Structure

### Application

```
apps/api/
├── project.json           # Nx project config
├── package.json           # ESM configuration
├── tsconfig.json          # TypeScript config
├── tsconfig.app.json      # Application config
├── tsconfig.spec.json     # Test config
├── vite.config.ts         # Vite build config (if bundler=vite)
├── webpack.config.js      # Webpack config (if bundler=webpack)
├── vitest.config.ts       # Test config with SWC
└── src/
    ├── main.ts            # Entry point
    └── app/
        ├── app.module.ts
        ├── app.controller.ts
        ├── app.service.ts
        ├── app.controller.spec.ts
        └── app.service.spec.ts
```

### Library

```
libs/my-feature/
├── project.json
├── package.json           # (if buildable/publishable)
├── tsconfig.json
├── tsconfig.lib.json
├── vitest.config.ts
├── README.md
└── src/
    ├── index.ts           # Barrel exports
    └── lib/
        ├── my-feature.module.ts
        ├── my-feature.controller.ts (if --controller)
        ├── my-feature.service.ts (if --service)
        └── *.spec.ts
```

---

## ESM Configuration

### package.json

```json
{
  "type": "module",
  "exports": {
    ".": {
      "import": "./dist/main.js",
      "types": "./dist/main.d.ts"
    }
  }
}
```

### tsconfig.json

```json
{
  "extends": "@oksai/tsconfig/nestjs-12-esm.json",
  "compilerOptions": {
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "verbatimModuleSyntax": true
  }
}
```

---

## Validation with Standard Schema

### Using Zod (Default)

```typescript
import { Body, Controller, Post } from '@nestjs/common';
import { z } from 'zod';

const CreateUserSchema = z.object({
  name: z.string(),
  email: z.string().email(),
});

@Controller('users')
export class UsersController {
  @Post()
  create(
    @Body({ schema: CreateUserSchema }) body: z.infer<typeof CreateUserSchema>
  ) {
    // ✅ Fully typed and validated
    return { id: 1, ...body };
  }
}
```

### Using Valibot

```typescript
import { Body, Controller, Post } from '@nestjs/common';
import * as v from 'valibot';

const CreateUserSchema = v.object({
  name: v.string(),
  email: v.string([v.email()]),
});

@Controller('users')
export class UsersController {
  @Post()
  create(
    @Body({ schema: CreateUserSchema }) body: v.InferOutput<typeof CreateUserSchema>
  ) {
    return { id: 1, ...body };
  }
}
```

---

## Comparison with @nx/nest

| Feature | @oksai/nest | @nx/nest |
|---------|-------------|----------|
| **Module System** | ESM (default) | CommonJS |
| **Test Runner** | Vitest | Jest |
| **Linter** | Biome | ESLint |
| **Bundler** | Vite / Webpack | Webpack |
| **Validation** | Standard Schema | class-validator |
| **Decorator Support** | SWC | ts-jest |
| **Node.js Support** | 18+ | 16+ |

---

## Migration from v1.x

### Breaking Changes

1. **ESM by default**: All new projects use `"type": "module"`
2. **Vite recommended**: Webpack still available but not recommended
3. **Zod by default**: class-validator still available as fallback
4. **Node.js 18+ required**: For ESM support

### Migration Steps

```bash
# 1. Update package
pnpm update @oksai/nest

# 2. Create new ESM project
pnpm nx g @oksai/nest:nestjs-application --directory=apps/api-new

# 3. Migrate code manually
# - Update imports to include .js extensions
# - Replace class-validator with Zod schemas
# - Update tsconfig.json to extend nestjs-12-esm.json

# 4. Test thoroughly
pnpm nx test api-new
```

---

## Development

### Build

```bash
pnpm nx build @oksai/nest
```

### Test

```bash
pnpm nx test @oksai/nest
```

---

## License

MIT
