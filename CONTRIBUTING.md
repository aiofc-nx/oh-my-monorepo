# 贡献指南

## 贡献者

Abel - 本项目的主要开发者。

## 开发环境设置

### 前置要求

- Node.js >= 18
- pnpm >= 8

### 安装依赖

```bash
pnpm install
```

## 开发流程

### 1. 创建分支

```bash
git checkout -b feature/my-feature
```

### 2. 开发

```bash
# 构建插件
pnpm nx build @oksai/nest
pnpm nx build @oksai/react

# 测试生成器
pnpm nx g @oksai/react:application --directory=apps/test-app
```

### 3. 提交代码

使用语义化提交信息：

- `feat:` 新功能
- `fix:` 修复 bug
- `docs:` 文档更新
- `refactor:` 代码重构
- `test:` 测试相关
- `chore:` 构建/工具相关

```bash
git commit -m "feat(react): add story generator"
```

### 4. 推送并创建 PR

```bash
git push origin feature/my-feature
```

## 添加新生成器

### 目录结构

```
src/generators/my-generator/
├── my-generator.ts      # 主逻辑
├── schema.json          # CLI 选项定义
├── schema.d.ts          # TypeScript 类型
├── lib/                 # 辅助函数
│   ├── index.ts
│   └── normalize-options.ts
└── files/               # 模板文件
    └── __fileName__.ts__tmpl__
```

### 步骤

1. **创建目录和文件**

```bash
mkdir -p packages/generators/react/src/generators/my-generator/{lib,files}
```

2. **定义 schema.json**

```json
{
  "$schema": "https://json-schema.org/schema",
  "$id": "OksaiReactMyGenerator",
  "title": "My Generator",
  "type": "object",
  "properties": {
    "name": {
      "type": "string",
      "description": "Name",
      "$default": { "$source": "argv", "index": 0 }
    }
  },
  "required": ["name"]
}
```

3. **创建 TypeScript 类型 (schema.d.ts)**

```typescript
export interface MyGeneratorSchema {
  name: string;
}
```

4. **实现生成器 (my-generator.ts)**

```typescript
import type { Tree } from '@nx/devkit';
import {
  formatFiles,
  generateFiles,
  joinPathFragments,
  names,
} from '@nx/devkit';

export async function myGenerator(tree: Tree, options: MyGeneratorSchema) {
  generateFiles(tree, joinPathFragments(__dirname, 'files'), 'path/to/output', {
    ...names(options.name),
    tmpl: '',
  });

  await formatFiles(tree);
}

export default myGenerator;
```

5. **注册生成器 (generators.json)**

```json
{
  "generators": {
    "my-generator": {
      "factory": "./generators/my-generator/my-generator",
      "schema": "./generators/my-generator/schema.json",
      "description": "My generator description"
    }
  }
}
```

6. **导出生成器 (src/index.ts)**

```typescript
export { myGenerator } from './generators/my-generator/my-generator';
```

7. **更新构建脚本 (project.json)**

```json
{
  "targets": {
    "build": {
      "options": {
        "commands": [
          "mkdir -p packages/generators/react/dist/generators/my-generator",
          "cp packages/generators/react/src/generators/my-generator/schema.json packages/generators/react/dist/generators/my-generator/",
          "cp -r packages/generators/react/src/generators/my-generator/files packages/generators/react/dist/generators/my-generator/"
        ]
      }
    }
  }
}
```

## 代码规范

### TypeScript

- 使用严格模式
- 为所有函数添加类型
- 避免使用 `any`

### 命名规范

| 类型     | 命名风格                       | 示例                      |
| -------- | ------------------------------ | ------------------------- |
| 文件名   | kebab-case                     | `my-generator.ts`         |
| 类名     | PascalCase                     | `MyGenerator`             |
| 函数名   | camelCase                      | `normalizeOptions`        |
| 常量     | SCREAMING_SNAKE_CASE           | `DEFAULT_OPTIONS`         |
| 模板文件 | `__variableName__.ext__tmpl__` | `__fileName__.ts__tmpl__` |

### 模板文件

模板文件使用 EJS 风格的变量：

```typescript
// __fileName__.ts__tmpl__
export class <%= className %> {
  constructor() {}
}
```

可用变量：

- `<%= fileName %>` - 文件名
- `<%= className %>` - 类名
- `<%= propertyName %>` - 属性名

## 代码风格

使用 Biome 进行格式化和 Lint：

```bash
# 格式化
pnpm biome format --write .

# Lint
pnpm biome lint .
```

## 发布

```bash
# 构建
pnpm nx build @oksai/react

# 发布 (需要权限)
cd packages/generators/react/dist
npm publish
```

## 问题反馈

如果发现问题，请创建 Issue 并包含：

1. 问题描述
2. 复现步骤
3. 期望结果
4. 实际结果
5. 环境信息 (Node.js 版本, pnpm 版本)
