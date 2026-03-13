# @oksai/nest

NestJS generators for Nx monorepo with Vitest and Biome support.

## Overview

This plugin provides generators for creating NestJS applications and libraries with:

- **Vitest** - Fast unit testing with decorator support via `unplugin-swc`
- **Biome** - Fast linting and formatting
- **Webpack** - Build bundling with `ts-loader`
- **TypeScript decorators** - Full support for `experimentalDecorators` and `emitDecoratorMetadata`

## Installation

```bash
pnpm add -D @oksai/nest
```

## Generators

### nestjs-application

Create a NestJS application.

```bash
pnpm nx g @oksai/nest:nestjs-application --directory=apps/api
```

**Aliases:** `nest-app`, `na`

#### Options

| Option            | Type    | Default                                            | Description                     |
| ----------------- | ------- | -------------------------------------------------- | ------------------------------- |
| `directory`       | string  | -                                                  | Directory path (required)       |
| `name`            | string  | -                                                  | Application name                |
| `tags`            | string  | `type:app,framework:nest,test:vitest,linter:biome` | Project tags                    |
| `strict`          | boolean | `false`                                            | Enable strict TypeScript checks |
| `skipFormat`      | boolean | `false`                                            | Skip formatting files           |
| `skipPackageJson` | boolean | `false`                                            | Skip adding dependencies        |

#### Generated Structure

```
apps/api/
├── project.json           # Nx project config
├── tsconfig.json
├── tsconfig.app.json      # Decorator config
├── tsconfig.spec.json     # Test config
├── webpack.config.js      # Build config
├── vitest.config.ts       # Test config with unplugin-swc
└── src/
    ├── main.ts            # Entry point
    ├── assets/.gitkeep
    └── app/
        ├── app.module.ts
        ├── app.controller.ts
        ├── app.service.ts
        ├── app.controller.spec.ts
        └── app.service.spec.ts
```

#### Targets

| Target  | Executor                            | Description            |
| ------- | ----------------------------------- | ---------------------- |
| `build` | `@nx/webpack:webpack`               | Build with Webpack     |
| `serve` | `@nx/node:node`                     | Run development server |
| `test`  | `@nx/vitest:test`                   | Run Vitest tests       |
| `lint`  | `@berenddeboer/nx-biome:biome-lint` | Run Biome lint         |

---

### nestjs-library

Create a NestJS library.

```bash
pnpm nx g @oksai/nest:nestjs-library --directory=libs/my-feature
```

**Aliases:** `nest-lib`, `nl`

#### Options

| Option            | Type               | Default                                            | Description                             |
| ----------------- | ------------------ | -------------------------------------------------- | --------------------------------------- |
| `directory`       | string             | -                                                  | Directory path (required)               |
| `name`            | string             | -                                                  | Library name                            |
| `buildable`       | boolean            | `false`                                            | Generate buildable library              |
| `publishable`     | boolean            | `false`                                            | Generate publishable library            |
| `importPath`      | string             | -                                                  | NPM import path (e.g., `@myorg/my-lib`) |
| `controller`      | boolean            | `false`                                            | Include controller                      |
| `service`         | boolean            | `false`                                            | Include service                         |
| `global`          | boolean            | `false`                                            | Add `@Global()` decorator               |
| `unitTestRunner`  | `vitest` \| `none` | `vitest`                                           | Test runner                             |
| `tags`            | string             | `type:lib,framework:nest,test:vitest,linter:biome` | Project tags                            |
| `strict`          | boolean            | `true`                                             | Enable strict TypeScript checks         |
| `skipFormat`      | boolean            | `false`                                            | Skip formatting                         |
| `skipTsConfig`    | boolean            | `false`                                            | Skip tsconfig updates                   |
| `skipPackageJson` | boolean            | `false`                                            | Skip adding dependencies                |

#### Examples

```bash
# Basic library
pnpm nx g @oksai/nest:nestjs-library --directory=libs/shared

# With controller and service
pnpm nx g @oksai/nest:nestjs-library --directory=libs/user --service --controller

# Buildable library
pnpm nx g @oksai/nest:nestjs-library --directory=libs/utils --buildable

# Publishable library with custom import path
pnpm nx g @oksai/nest:nestjs-library --directory=libs/core --publishable --importPath=@myorg/core

# Global module with service
pnpm nx g @oksai/nest:nestjs-library --directory=libs/config --service --global
```

#### Generated Structure (with --service --controller)

```
libs/my-feature/
├── project.json
├── tsconfig.json
├── tsconfig.lib.json     # Decorator config
├── vitest.config.ts      # Test config with unplugin-swc
├── README.md
└── src/
    ├── index.ts          # Barrel exports
    └── lib/
        ├── my-feature.module.ts
        ├── my-feature.controller.ts
        ├── my-feature.controller.spec.ts
        ├── my-feature.service.ts
        └── my-feature.service.spec.ts
```

#### Targets

| Target  | Executor                            | Condition             | Description      |
| ------- | ----------------------------------- | --------------------- | ---------------- |
| `test`  | `@nx/vitest:test`                   | Always                | Run Vitest tests |
| `lint`  | `@berenddeboer/nx-biome:biome-lint` | Always                | Run Biome lint   |
| `build` | `@nx/js:tsc`                        | buildable/publishable | Build with tsc   |

---

### init

Initialize NestJS dependencies in the workspace.

```bash
pnpm nx g @oksai/nest:init
```

Usually called automatically by `nestjs-application` and `nestjs-library` generators.

#### Options

| Option            | Type    | Default | Description              |
| ----------------- | ------- | ------- | ------------------------ |
| `skipFormat`      | boolean | `false` | Skip formatting          |
| `skipPackageJson` | boolean | `false` | Skip adding dependencies |

## Dependencies

### Production Dependencies

| Package                    | Version | Purpose                 |
| -------------------------- | ------- | ----------------------- |
| `@nestjs/common`           | ^11.0.0 | NestJS common utilities |
| `@nestjs/core`             | ^11.0.0 | NestJS core             |
| `@nestjs/platform-express` | ^11.0.0 | Express platform        |
| `reflect-metadata`         | ^0.1.13 | Decorator metadata      |
| `rxjs`                     | ^7.8.0  | Reactive extensions     |
| `tslib`                    | ^2.3.0  | TypeScript helpers      |

### Development Dependencies

| Package               | Version | Purpose                       |
| --------------------- | ------- | ----------------------------- |
| `@nestjs/schematics`  | ^11.0.0 | NestJS schematics             |
| `@nestjs/testing`     | ^11.0.0 | NestJS testing                |
| `vitest`              | ^4.0.0  | Test runner                   |
| `@vitest/coverage-v8` | ^4.0.0  | Code coverage                 |
| `ts-loader`           | ^9.5.2  | TypeScript loader for Webpack |
| `unplugin-swc`        | ^1.5.9  | SWC plugin for Vitest         |

## Decorator Support

### Why unplugin-swc?

Vitest uses esbuild by default, but esbuild doesn't support TypeScript decorator metadata (`emitDecoratorMetadata`). This plugin uses `unplugin-swc` to handle decorators correctly in tests.

### vitest.config.ts

```typescript
import { defineConfig } from 'vitest/config';
import { join } from 'path';
import swc from 'unplugin-swc';

export default defineConfig({
  test: {
    globals: true,
    environment: 'node',
    include: [join(__dirname, 'src/**/*.spec.ts')],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'lcov'],
    },
  },
  plugins: [
    swc.vite({
      jsc: {
        parser: {
          syntax: 'typescript',
          tsx: true,
          dynamicImport: true,
          decorators: true,
        },
        transform: {
          legacyDecorator: true,
          decoratorMetadata: true,
        },
      },
    }),
  ],
});
```

### tsconfig.lib.json

```json
{
  "extends": "./tsconfig.json",
  "compilerOptions": {
    "outDir": "../../dist/out-tsc",
    "declaration": true,
    "types": ["node"],
    "target": "es2021",
    "experimentalDecorators": true,
    "emitDecoratorMetadata": true,
    "strictNullChecks": true,
    "noImplicitAny": true,
    "strictBindCallApply": true,
    "forceConsistentCasingInFileNames": true,
    "noFallthroughCasesInSwitch": true
  },
  "include": ["src/**/*.ts"]
}
```

## Development

### Build

```bash
pnpm nx build @oksai/nest
```

### Project Structure

```
packages/generators/nest/
├── package.json           # Package config
├── project.json           # Nx project config
├── generators.json        # Generator registration
├── tsconfig.json          # TypeScript config
├── src/
│   ├── index.ts           # Public exports
│   ├── utils/
│   │   └── versions.ts    # Dependency versions
│   └── generators/
│       ├── init/          # Init generator
│       │   ├── init.ts
│       │   ├── schema.json
│       │   └── schema.d.ts
│       ├── nestjs-application/
│       │   ├── nestjs-application.ts
│       │   ├── schema.json
│       │   ├── schema.d.ts
│       │   ├── lib/
│       │   │   ├── index.ts
│       │   │   ├── normalize-options.ts
│       │   │   ├── create-files.ts
│       │   │   ├── update-tsconfig.ts
│       │   │   └── update-project.ts
│       │   └── files/     # Template files
│       └── nestjs-library/
│           ├── nestjs-library.ts
│           ├── schema.json
│           ├── schema.d.ts
│           ├── lib/
│           │   ├── index.ts
│           │   ├── normalize-options.ts
│           │   ├── create-files.ts
│           │   ├── delete-files.ts
│           │   ├── update-tsconfig.ts
│           │   ├── update-project.ts
│           │   └── add-exports-to-barrel.ts
│           └── files/
│               ├── common/
│               │   ├── vitest.config.ts__tmpl__
│               │   └── src/lib/__fileName__.module.ts__tmpl__
│               ├── controller/src/lib/
│               │   ├── __fileName__.controller.ts__tmpl__
│               │   └── __fileName__.controller.spec.ts__tmpl__
│               └── service/src/lib/
│                   ├── __fileName__.service.ts__tmpl__
│                   └── __fileName__.service.spec.ts__tmpl__
└── dist/                  # Build output
```

### Template Variables

Available variables in templates:

| Variable       | Description                              |
| -------------- | ---------------------------------------- |
| `fileName`     | File name (e.g., `my-feature`)           |
| `className`    | Class name (e.g., `MyFeature`)           |
| `propertyName` | Property name (e.g., `myFeature`)        |
| `projectName`  | Nx project name                          |
| `projectRoot`  | Project root path                        |
| `tmpl`         | Empty string (removes `__tmpl__` suffix) |

### Adding a New Generator

1. Create generator directory: `src/generators/my-generator/`
2. Create schema files: `schema.json`, `schema.d.ts`
3. Create main file: `my-generator.ts`
4. Create lib files in `lib/` directory
5. Create template files in `files/` directory
6. Register in `generators.json`
7. Export from `src/index.ts`
8. Update `project.json` build commands to copy schema files

## Comparison with @nx/nest

| Feature           | @oksai/nest         | @nx/nest |
| ----------------- | ------------------- | -------- |
| Test Runner       | Vitest              | Jest     |
| Linter            | Biome               | ESLint   |
| Decorator Support | unplugin-swc        | ts-jest  |
| Build             | Webpack + ts-loader | Webpack  |
| Node.js           | Node.js             | Node.js  |

## License

MIT
