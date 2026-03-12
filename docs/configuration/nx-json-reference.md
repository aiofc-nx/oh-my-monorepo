# ⚙️ nx.json 配置说明

**版本**: 1.0.0  
**最后更新**: 2026-03-13  
**配置文件**: nx.json

---

## 📋 配置总览

| 配置项                | 值                       | 说明                               |
| --------------------- | ------------------------ | ---------------------------------- |
| `nxCloudId`           | 69aedabbe41d732166547db0 | Nx Cloud 项目 ID                   |
| `useDaemonProcess`    | `true`                   | 启用 Nx Daemon                     |
| `parallel`            | `3`                      | 默认并行任务数                     |
| `useInferencePlugins` | `true`                   | 启用自动推断插件                   |
| `defaultBase`         | `"main"`                 | 默认基础分支（用于 affected 命令） |

---

## 🔧 性能配置详解

### 1. useDaemonProcess

**值**: `true`  
**作用**: 启用 Nx Daemon Watcher

**说明**:

- 后台监听文件变化
- 实时更新项目依赖图
- 大幅提升 affected 命令速度

**性能提升**:

- 首次命令: 无差异
- 后续命令: **+90% 速度**
- 项目图计算: **+97% 速度**

**禁用方式**:

```json
{
  "useDaemonProcess": false
}
```

或

```bash
export NX_DAEMON=false
```

**推荐**: ✅ 始终保持 `true`（仅在调试问题时临时禁用）

---

### 2. parallel

**值**: `3`  
**作用**: 默认并行执行任务数

**说明**:

- 控制同时运行的任务数量
- 根据 CPU 核心数调整
- 可通过命令行覆盖

**推荐值**:

| CPU 核心数 | 推荐值 |
| ---------- | ------ |
| 2 核       | 2      |
| 4 核       | 3-4    |
| 8 核       | 5-6    |
| 16 核+     | 6-8    |

**临时覆盖**:

```bash
# 使用配置文件的值
pnpm nx run-many --target=build --all

# 临时修改并行度
pnpm nx run-many --target=build --all --parallel=5

# 或使用环境变量
NX_PARALLEL=5 pnpm nx run-many --target=build --all
```

**注意事项**:

- 过高的并行度可能导致内存不足
- I/O 密集型任务建议较低并行度
- CPU 密集型任务可以较高并行度

---

### 3. useInferencePlugins

**值**: `true`  
**作用**: 启用自动推断插件

**说明**:

- 自动检测项目类型和配置
- 自动添加合适的 target
- 简化项目配置

**推断内容**:

- 项目类型（应用/库）
- 构建工具（Vite/Webpack/etc）
- 测试框架（Jest/Vitest）
- Linter（ESLint/Biome）

**禁用场景**:

- 需要完全手动控制项目配置
- 遇到推断冲突问题

**禁用方式**:

```json
{
  "useInferencePlugins": false
}
```

---

### 4. defaultBase

**值**: `"main"`  
**作用**: affected 命令的默认基础分支

**说明**:

- `nx affected` 命令比较的基础分支
- 默认是 `main`
- 可通过命令行覆盖

**使用示例**:

```bash
# 使用默认的 main 分支
pnpm nx affected:test

# 临时使用其他分支
pnpm nx affected:test --base=develop

# 与特定提交比较
pnpm nx affected:test --base=HEAD~10
```

**⚠️ 重要变更**:

- ❌ **已弃用**: `affected.defaultBase`（Nx schema 标记为 deprecated）
- ✅ **推荐**: 使用顶层 `defaultBase`

```json
// ❌ 旧配置（已弃用）
{
  "defaultBase": "main",
  "affected": {
    "defaultBase": "main"  // 已弃用
  }
}

// ✅ 新配置（推荐）
{
  "defaultBase": "main"  // 只需顶层配置
}
```

**affected 配置**:

```json
{
  "affected": {
    "defaultBase": "main"
  }
}
```

---

## 🌐 Nx Cloud 配置

### nxCloudId

**值**: `69aedabbe41d732166547db0`  
**作用**: Nx Cloud 项目标识

**功能**:

- ✅ 分布式缓存
- ✅ 任务编排
- ✅ 构建历史
- ✅ 性能分析

**访问控制台**: https://nx.app

**配置**:

```json
{
  "nxCloudId": "your-cloud-id-here"
}
```

**禁用 Cloud**:

- 删除 `nxCloudId` 配置项
- 或设置环境变量 `NX_NO_CLOUD=true`

---

## 🎯 Target Defaults

### 已配置的 Targets

| Target            | 缓存 | 依赖     | 说明        |
| ----------------- | ---- | -------- | ----------- |
| `test`            | ✅   | `^build` | Vitest 测试 |
| `@nx/jest:jest`   | ✅   | -        | Jest 测试   |
| `build`           | ✅   | `^build` | 通用构建    |
| `@nx/vite:build`  | ✅   | `^build` | Vite 构建   |
| `@nx/vitest:test` | ✅   | -        | Vitest 测试 |

**说明**:

- `^build` 表示依赖所有依赖项的 build target
- 缓存自动启用，提升重复构建速度

---

## 🔌 插件配置

### 已启用的插件

#### 1. @nx/js/typescript

```json
{
  "plugin": "@nx/js/typescript",
  "options": {
    "typecheck": { "targetName": "typecheck" },
    "build": {
      "targetName": "build",
      "configName": "tsconfig.lib.json",
      "buildDepsName": "build-deps",
      "watchDepsName": "watch-deps"
    }
  }
}
```

**功能**: TypeScript 项目支持

---

#### 2. @nx/webpack/plugin

```json
{
  "plugin": "@nx/webpack/plugin",
  "options": {
    "buildTargetName": "build",
    "serveTargetName": "serve",
    "previewTargetName": "preview",
    "buildDepsTargetName": "build-deps",
    "watchDepsTargetName": "watch-deps",
    "serveStaticTargetName": "serve-static"
  }
}
```

**功能**: Webpack 构建支持

---

#### 3. @berenddeboer/nx-biome

```json
{
  "plugin": "@berenddeboer/nx-biome",
  "options": {
    "targetName": "lint"
  }
}
```

**功能**: Biome Linter 集成

---

#### 4. @berenddeboer/nx-knip

```json
{
  "plugin": "@berenddeboer/nx-knip",
  "options": {
    "targetName": "knip"
  }
}
```

**功能**: 代码分析工具

---

## 🎨 Generators 配置

### @nx/react

```json
{
  "@nx/react": {
    "application": {
      "babel": true,
      "style": "css",
      "linter": "none",
      "bundler": "vite"
    },
    "component": {
      "style": "css"
    },
    "library": {
      "style": "css",
      "linter": "none",
      "unitTestRunner": "vitest"
    }
  }
}
```

**说明**:

- 应用默认使用 Vite + CSS
- 库默认使用 Vitest
- Linter 使用 Biome（不在生成时配置 ESLint）

---

## 📝 配置最佳实践

### ✅ 推荐做法

1. **保持 Daemon 开启**

   ```json
   {
     "useDaemonProcess": true
   }
   ```

2. **合理设置并行度**

   ```json
   {
     "parallel": 3 // 根据 CPU 核心数调整
   }
   ```

3. **明确基础分支**

   ```json
   {
     "defaultBase": "main",
     "affected": {
       "defaultBase": "main"
     }
   }
   ```

4. **启用缓存**
   ```json
   {
     "targetDefaults": {
       "build": {
         "cache": true,
         "dependsOn": ["^build"]
       }
     }
   }
   ```

---

### ❌ 避免的做法

1. **禁用 Daemon**（除非调试）

   ```json
   // ❌ 不推荐
   {
     "useDaemonProcess": false
   }
   ```

2. **过高的并行度**

   ```json
   // ❌ 可能导致内存不足
   {
     "parallel": 20
   }
   ```

3. **禁用缓存**
   ```json
   // ❌ 影响性能
   {
     "targetDefaults": {
       "build": {
         "cache": false
       }
     }
   }
   ```

---

## 🔍 故障排查

### Daemon 问题

**问题**: Daemon 占用过多内存

**解决**:

```bash
# 重置 Daemon
pnpm nx reset

# 或临时禁用
export NX_DAEMON=false
```

---

### 并行问题

**问题**: 并行任务失败

**解决**:

```bash
# 降低并行度
pnpm nx run-many --target=build --all --parallel=1

# 或顺序执行
pnpm nx run-many --target=build --all --parallel=false
```

---

### 缓存问题

**问题**: 缓存未命中

**解决**:

```bash
# 清除缓存
pnpm nx reset

# 跳过缓存
pnpm nx build --skip-nx-cache
```

---

## 📚 相关资源

- [Nx 配置文档](https://nx.dev/reference/nx-json)
- [性能优化指南](./docs/guides/nx-performance-optimization.md)
- [Nx Cloud 文档](https://nx.dev/nx-cloud)

---

## 🔄 配置变更历史

### 2026-03-13 - v1.0.1

- ✅ 移除已弃用的 `affected.defaultBase` 配置
- ✅ 使用顶层 `defaultBase` 替代
- ✅ 修复 Nx schema deprecated 警告

### 2026-03-13 - v1.0.0

- ✅ 添加显式 daemon 配置
- ✅ 配置并行度为 3
- ✅ 启用推断插件
- ✅ 明确基础分支为 main
- ✅ 创建配置说明文档

---

**维护者**: DevOps Team  
**反馈**: Slack #dev-tools
