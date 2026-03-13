# @oksai/react

React generators for Nx monorepo with Vite, Vitest and Biome.

## Overview

This plugin provides generators for creating React applications, libraries, components, and more with:

- **Vite** - Fast build tool and dev server
- **Vitest** - Fast unit testing with jsdom
- **Biome** - Fast linting and formatting
- **Playwright** - E2E testing
- **Storybook** - Component documentation
- **State Management** - Redux Toolkit and Zustand

## Installation

```bash
pnpm add -D @oksai/react
```

## Generators

### application

Create a React application.

```bash
pnpm nx g @oksai/react:application --directory=apps/web
```

**Aliases:** `app`

#### Options

| Option            | Type    | Default | Description                                  |
| ----------------- | ------- | ------- | -------------------------------------------- |
| `directory`       | string  | -       | Directory path (required)                    |
| `name`            | string  | -       | Application name                             |
| `style`           | string  | `css`   | Style format (`css`, `scss`, `less`, `none`) |
| `tags`            | string  | -       | Project tags (comma-separated)               |
| `skipFormat`      | boolean | `false` | Skip formatting                              |
| `skipPackageJson` | boolean | `false` | Skip adding dependencies                     |

---

### library

Create a React library.

```bash
pnpm nx g @oksai/react:library --directory=libs/shared
```

**Aliases:** `lib`

#### Options

| Option       | Type    | Default | Description               |
| ------------ | ------- | ------- | ------------------------- |
| `directory`  | string  | -       | Directory path (required) |
| `name`       | string  | -       | Library name              |
| `style`      | string  | `css`   | Style format              |
| `skipTests`  | boolean | `false` | Skip test files           |
| `skipFormat` | boolean | `false` | Skip formatting           |

---

### component

Create a React component in an existing project.

```bash
pnpm nx g @oksai/react:component --name=Button --project=my-app
```

**Aliases:** `c`

#### Options

| Option            | Type    | Default | Description                                                                          |
| ----------------- | ------- | ------- | ------------------------------------------------------------------------------------ |
| `name`            | string  | -       | Component name (required)                                                            |
| `project`         | string  | -       | Project name (required)                                                              |
| `directory`       | string  | -       | Directory within project                                                             |
| `style`           | string  | `css`   | Style format (`css`, `scss`, `less`, `styled-components`, `@emotion/styled`, `none`) |
| `skipTests`       | boolean | `false` | Skip test files                                                                      |
| `export`          | boolean | `true`  | Export from index.ts                                                                 |
| `flat`            | boolean | `false` | Create in source root                                                                |
| `pascalCaseFiles` | boolean | `false` | Use PascalCase for file names                                                        |

#### Examples

```bash
# Basic component
pnpm nx g @oksai/react:component Button --project=my-app

# With SCSS styles
pnpm nx g @oksai/react:component Button --project=my-app --style=scss

# Skip tests
pnpm nx g @oksai/react:component Button --project=my-app --skipTests

# Flat structure
pnpm nx g @oksai/react:component Button --project=my-app --flat
```

---

### routing

Add routing to a React application.

```bash
pnpm nx g @oksai/react:routing --project=my-app
```

#### Options

| Option            | Type    | Default        | Description                                     |
| ----------------- | ------- | -------------- | ----------------------------------------------- |
| `project`         | string  | -              | Project name (required)                         |
| `directory`       | string  | `src/routes`   | Directory for routes                            |
| `type`            | string  | `react-router` | Router type (`react-router`, `tanstack-router`) |
| `skipFormat`      | boolean | `false`        | Skip formatting                                 |
| `skipPackageJson` | boolean | `false`        | Skip adding dependencies                        |

---

### hook

Create a React hook in an existing project.

```bash
pnpm nx g @oksai/react:hook --name=useCounter --project=my-app
```

**Aliases:** `h`

#### Options

| Option       | Type    | Default | Description              |
| ------------ | ------- | ------- | ------------------------ |
| `name`       | string  | -       | Hook name (required)     |
| `project`    | string  | -       | Project name (required)  |
| `directory`  | string  | `hooks` | Directory within project |
| `skipTests`  | boolean | `false` | Skip test file           |
| `skipFormat` | boolean | `false` | Skip formatting          |

---

### storybook-configuration

Add Storybook to a React project.

```bash
pnpm nx g @oksai/react:storybook-configuration --project=my-app
```

#### Options

| Option                | Type    | Default | Description               |
| --------------------- | ------- | ------- | ------------------------- |
| `project`             | string  | -       | Project name (required)   |
| `configureTestRunner` | boolean | `false` | Add test-storybook target |
| `skipFormat`          | boolean | `false` | Skip formatting           |
| `skipPackageJson`     | boolean | `false` | Skip adding dependencies  |

#### Generated Files

```
apps/my-app/
└── .storybook/
    ├── main.ts        # Storybook configuration
    ├── preview.ts     # Global decorators/parameters
    └── tsconfig.json  # TypeScript config for stories
```

#### Added Targets

| Target            | Description                    |
| ----------------- | ------------------------------ |
| `storybook`       | Start Storybook dev server     |
| `build-storybook` | Build static Storybook site    |
| `test-storybook`  | Run Storybook tests (optional) |

#### Example

```bash
# Add Storybook with test runner
pnpm nx g @oksai/react:storybook-configuration --project=my-app --configureTestRunner

# Start Storybook
pnpm nx storybook my-app

# Build static site
pnpm nx build-storybook my-app
```

---

### story

Create a Storybook story for a component.

```bash
pnpm nx g @oksai/react:story --name=Button --project=my-app
```

#### Options

| Option       | Type    | Default | Description                          |
| ------------ | ------- | ------- | ------------------------------------ |
| `name`       | string  | -       | Component name (required)            |
| `project`    | string  | -       | Project name (required)              |
| `directory`  | string  | -       | Directory where component is located |
| `path`       | string  | -       | Full path for story file             |
| `skipFormat` | boolean | `false` | Skip formatting                      |

#### Example

```bash
# Create story for Button component
pnpm nx g @oksai/react:story --name=Button --project=my-app

# Create story in specific directory
pnpm nx g @oksai/react:story --name=Button --project=my-app --directory=components
```

#### Generated File

```typescript
// button.stories.tsx
import type { Meta, StoryObj } from '@storybook/react';
import { Button } from './Button';

const meta: Meta<typeof Button> = {
  title: 'Button',
  component: Button,
  tags: ['autodocs'],
  argTypes: {},
};

export default meta;
type Story = StoryObj<typeof Button>;

export const Default: Story = {
  args: {},
};
```

---

### redux

Add Redux Toolkit state management to a React project.

```bash
pnpm nx g @oksai/react:redux --project=my-app
```

#### Options

| Option            | Type    | Default | Description               |
| ----------------- | ------- | ------- | ------------------------- |
| `project`         | string  | -       | Project name (required)   |
| `directory`       | string  | `store` | Directory for store files |
| `skipFormat`      | boolean | `false` | Skip formatting           |
| `skipPackageJson` | boolean | `false` | Skip adding dependencies  |

#### Generated Files

```
apps/my-app/src/store/
├── index.ts           # Barrel exports
├── store.ts           # Store configuration
├── hooks.ts           # Typed hooks (useAppDispatch, useAppSelector)
└── counterSlice.ts    # Example slice
```

#### Usage

```tsx
import { useAppDispatch, useAppSelector } from './store';
import { increment, decrement } from './store/counterSlice';

function Counter() {
  const count = useAppSelector((state) => state.counter.value);
  const dispatch = useAppDispatch();

  return (
    <div>
      <button onClick={() => dispatch(decrement())}>-</button>
      <span>{count}</span>
      <button onClick={() => dispatch(increment())}>+</button>
    </div>
  );
}
```

---

### zustand

Add Zustand state management to a React project.

```bash
pnpm nx g @oksai/react:zustand --project=my-app
```

#### Options

| Option            | Type    | Default | Description                     |
| ----------------- | ------- | ------- | ------------------------------- |
| `project`         | string  | -       | Project name (required)         |
| `name`            | string  | `store` | Store name (used for hook name) |
| `directory`       | string  | `store` | Directory for store files       |
| `skipFormat`      | boolean | `false` | Skip formatting                 |
| `skipPackageJson` | boolean | `false` | Skip adding dependencies        |

#### Generated Files

```
apps/my-app/src/store/
├── index.ts           # Barrel exports
└── useStore.ts        # Zustand store hook
```

#### Usage

```tsx
import { useStore } from './store';

function Counter() {
  const { count, increment, decrement, reset } = useStore();

  return (
    <div>
      <button onClick={decrement}>-</button>
      <span>{count}</span>
      <button onClick={increment}>+</button>
      <button onClick={reset}>Reset</button>
    </div>
  );
}
```

#### Example with Custom Store Name

```bash
# Creates useCounterStore hook
pnpm nx g @oksai/react:zustand --project=my-app --name=counter
```

---

### playwright-e2e

Add Playwright E2E testing to a React project.

```bash
pnpm nx g @oksai/react:playwright-e2e --project=my-app
```

#### Options

| Option            | Type    | Default | Description              |
| ----------------- | ------- | ------- | ------------------------ |
| `project`         | string  | -       | Project name (required)  |
| `skipFormat`      | boolean | `false` | Skip formatting          |
| `skipPackageJson` | boolean | `false` | Skip adding dependencies |

#### Generated Files

```
apps/my-app/
├── playwright.config.ts   # Playwright configuration
└── e2e/
    └── app.spec.ts        # Example E2E test
```

#### Added Targets

| Target   | Description                  |
| -------- | ---------------------------- |
| `e2e`    | Run Playwright tests         |
| `e2e:ui` | Run Playwright tests with UI |

#### Usage

```bash
# Run E2E tests
pnpm nx e2e my-app

# Run with UI mode
pnpm nx e2e:ui my-app
```

#### Example Test

```typescript
// e2e/app.spec.ts
import { test, expect } from '@playwright/test';

test('has title', async ({ page }) => {
  await page.goto('/');
  await expect(page).toHaveTitle(/React/);
});
```

---

## Dependencies

### Production

| Package     | Version | Purpose       |
| ----------- | ------- | ------------- |
| `react`     | ^19.0.0 | React library |
| `react-dom` | ^19.0.0 | React DOM     |

### Development

| Package                       | Version | Purpose                  |
| ----------------------------- | ------- | ------------------------ |
| `vite`                        | ^6.0.0  | Build tool               |
| `@vitejs/plugin-react`        | ^4.3.0  | Vite React plugin        |
| `vitest`                      | ^4.0.0  | Test runner              |
| `@vitest/coverage-v8`         | ^4.0.0  | Code coverage            |
| `jsdom`                       | ^26.0.0 | DOM environment          |
| `@testing-library/react`      | ^16.0.0 | React testing utilities  |
| `@testing-library/jest-dom`   | ^6.6.0  | Jest DOM matchers        |
| `@playwright/test`            | ^1.50.0 | E2E testing              |
| `@storybook/react`            | ^8.6.0  | Storybook for React      |
| `@storybook/react-vite`       | ^8.6.0  | Storybook Vite builder   |
| `@storybook/addon-essentials` | ^8.6.0  | Storybook addons         |
| `@reduxjs/toolkit`            | ^2.5.0  | Redux Toolkit            |
| `react-redux`                 | ^9.2.0  | React bindings for Redux |
| `zustand`                     | ^5.0.0  | Zustand state management |

## Comparison with @nx/react

| Feature     | @oksai/react   | @nx/react                      |
| ----------- | -------------- | ------------------------------ |
| Bundler     | Vite only      | Webpack, Vite, Rspack, Rsbuild |
| Test Runner | Vitest only    | Jest, Vitest                   |
| E2E Runner  | Playwright     | Cypress, Playwright            |
| Linter      | Biome          | ESLint                         |
| Storybook   | Yes            | Yes                            |
| State       | Redux, Zustand | Redux, NgRx, etc.              |
| Complexity  | ~2,200 lines   | ~25,000+ lines                 |

## License

MIT
