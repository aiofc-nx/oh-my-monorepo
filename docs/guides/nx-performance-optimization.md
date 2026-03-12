# 🚀 Nx 性能优化指南

**版本**: 1.0.0  
**最后更新**: 2026-03-13  
**适用项目**: oh-my-monorepo

---

## 📋 目录

- [Nx Daemon Watcher](#nx-daemon-watcher)
- [计算缓存](#计算缓存)
- [分布式缓存](#分布式缓存)
- [并行执行](#并行执行)
- [项目图优化](#项目图优化)
- [最佳实践](#最佳实践)
- [故障排查](#故障排查)

---

## 🔄 Nx Daemon Watcher

### 是什么？

**Nx Daemon Watcher** 是 Nx 在后台运行的**守护进程**，核心作用是**监听工作空间文件变化，并实时更新项目依赖关系图（Project Graph）**，从而极大提升 Nx 命令执行速度。

可以把它理解为 Nx 的"**记忆加速器**"。

---

### 解决的问题

在大型 monorepo 中，运行命令（如 `nx affected:test`）时，Nx 需要计算**项目关系图**才能确定：

- 哪些项目互相依赖
- 代码改动影响了哪些部分

随着项目规模增长，生成关系图的计算开销越来越大，导致速度变慢。

---

### 工作原理

```
┌─────────────┐
│  开发者     │
│  修改文件   │
└──────┬──────┘
       │
       ▼
┌─────────────────────┐
│  Nx Daemon Watcher  │  ◄─── 后台常驻
│  (守护进程)          │
├─────────────────────┤
│  ✅ 监听文件变化      │
│  ✅ 实时更新依赖图    │
│  ✅ 保存到内存        │
└──────┬──────────────┘
       │
       ▼
┌─────────────────────┐
│  执行 nx 命令        │
│  (nx affected:*)    │
├─────────────────────┤
│  ✅ 直接读取内存      │  ◄─── 近乎即时响应
│  ✅ 无需重新计算      │
└─────────────────────┘
```

---

### 主要特点

| 特性            | 说明                 |
| --------------- | -------------------- |
| **默认开启**    | 本地开发环境自动启用 |
| **智能休眠**    | 3小时无活动自动关闭  |
| **独立运行**    | 每个工作空间独立进程 |
| **CI 自动禁用** | 持续集成环境默认禁用 |

---

### 管理命令

#### 查看状态和日志

```bash
pnpm nx daemon
```

输出示例：

```
NX  Daemon is running (PID: 12345)
Logs: /Users/xxx/.nx/daemon.log
```

#### 重置 Daemon 和缓存

```bash
pnpm nx reset
```

使用场景：

- 遇到缓存问题
- 依赖图计算不准确
- 想强制重新计算

#### 禁用 Daemon

**方法 1: 环境变量**

```bash
export NX_DAEMON=false
pnpm nx affected:test
```

**方法 2: nx.json 配置**

```json
{
  "useDaemonProcess": false
}
```

---

### 性能对比

| 操作               | 无 Daemon | 有 Daemon | 提升    |
| ------------------ | --------- | --------- | ------- |
| 首次 affected 命令 | ~5s       | ~5s       | 0%      |
| 后续 affected 命令 | ~5s       | ~0.5s     | **90%** |
| 项目图计算         | 每次 ~3s  | ~0.1s     | **97%** |

---

## 💾 计算缓存

### Nx 缓存机制

Nx 会缓存命令执行结果，避免重复工作。

#### 缓存位置

```
node_modules/.cache/nx/
```

#### 缓存什么？

- ✅ 构建产物
- ✅ 测试结果
- ✅ Lint 结果
- ✅ 代码生成结果

#### 缓存键值

Nx 使用以下因素计算缓存键：

- 源代码内容
- 环境变量
- 配置文件
- 依赖版本

---

### 配置缓存

**nx.json**:

```json
{
  "targetDefaults": {
    "build": {
      "cache": true,
      "dependsOn": ["^build"]
    },
    "test": {
      "cache": true,
      "inputs": ["default", "^production"]
    }
  }
}
```

---

### 缓存命令

#### 清除缓存

```bash
pnpm nx reset
```

#### 跳过缓存

```bash
pnpm nx build api --skip-nx-cache
```

#### 仅使用缓存

```bash
pnpm nx build api --only-nx-cache
```

---

## ☁️ 分布式缓存

### Nx Cloud

本项目已配置 Nx Cloud：

```json
{
  "nxCloudId": "69aedabbe41d732166547db0"
}
```

### 优势

- 🌐 **跨机器共享**: 团队成员共享缓存
- ⚡ **CI/CD 加速**: PR 构建使用主分支缓存
- 📊 **分析工具**: 性能分析和可视化

### 使用方式

```bash
# 正常运行，自动使用云缓存
pnpm nx affected:test
```

---

## 🔀 并行执行

### 自动并行

Nx 自动并行执行独立任务：

```bash
# Nx 会并行运行独立的测试
pnpm nx run-many --target=test --all
```

### 配置并行度

**nx.json**:

```json
{
  "parallel": 3
}
```

或环境变量：

```bash
export NX_PARALLEL=3
```

### 性能建议

| CPU 核心数 | 推荐并行度 |
| ---------- | ---------- |
| 2 核       | 2          |
| 4 核       | 3          |
| 8 核       | 5          |
| 16 核+     | 6-8        |

---

## 📊 项目图优化

### 项目图（Project Graph）

Nx 维护的项目依赖关系图。

#### 查看项目图

```bash
# 生成可视化
pnpm nx graph

# 查看 Web 界面
pnpm nx graph --watch
```

#### 受影响的项目

```bash
# 查看受影响的项目
pnpm nx affected:graph

# 只测试受影响的项目
pnpm nx affected:test

# 只构建受影响的项目
pnpm nx affected:build
```

---

### 优化依赖关系

#### 避免循环依赖

❌ **错误**:

```
lib-a → lib-b → lib-a  // 循环依赖
```

✅ **正确**:

```
lib-a → lib-b → lib-c
```

#### 减少耦合

- 将共享代码提取到独立库
- 使用依赖注入
- 明确模块边界

---

## 🎯 最佳实践

### 1. 使用 affected 命令

❌ **不要**:

```bash
pnpm nx run-many --target=test --all
```

✅ **推荐**:

```bash
pnpm nx affected:test
```

**节省时间**: 50-90%

---

### 2. 合理使用缓存

**CI/CD 配置**:

```yaml
# .github/workflows/ci.yml
- name: Cache Nx
  uses: actions/cache@v3
  with:
    path: node_modules/.cache/nx
    key: nx-${{ hashFiles('**/package-lock.json') }}-${{ github.sha }}
    restore-keys: |
      nx-${{ hashFiles('**/package-lock.json') }}-
```

---

### 3. 优化项目结构

#### 按功能分组

```
libs/
├── feature-a/
│   ├── domain/
│   ├── application/
│   └── infrastructure/
├── feature-b/
│   ├── domain/
│   ├── application/
│   └── infrastructure/
└── shared/
    ├── utils/
    └── types/
```

#### 使用标签

**project.json**:

```json
{
  "tags": ["type:feature", "domain:user", "scope:frontend"]
}
```

**nx.json**:

```json
{
  "targetDefaults": {
    "build": {
      "dependsOn": ["^build"],
      "inputs": [
        {
          "tags": ["type:feature"]
        }
      ]
    }
  }
}
```

---

### 4. 使用增量构建

```bash
# 开发模式：监听文件变化
pnpm nx build api --watch

# 增量构建：只构建变化的部分
pnpm nx affected:build
```

---

### 5. 优化 CI 流程

```yaml
# .github/workflows/ci.yml
jobs:
  main:
    steps:
      # 1. 主分支: 运行所有测试
      - name: Test all
        if: github.ref == 'refs/heads/main'
        run: pnpm nx run-many --target=test --all

      # 2. PR: 只测试受影响的部分
      - name: Test affected
        if: github.ref != 'refs/heads/main'
        run: pnpm nx affected:test --base=origin/main
```

---

## 🔧 故障排查

### Daemon 问题

#### 症状 1: Daemon 不工作

**检查**:

```bash
pnpm nx daemon
```

**解决**:

```bash
# 重置
pnpm nx reset

# 或手动启动
pnpm nx daemon --start
```

---

#### 症状 2: 项目图不准确

**原因**: Daemon 缓存过期

**解决**:

```bash
# 重置 Daemon
pnpm nx reset

# 清除 node_modules
rm -rf node_modules

# 重新安装
pnpm install
```

---

### 缓存问题

#### 症状: 缓存不命中

**检查清单**:

1. **环境变量一致**

   ```bash
   echo $NODE_ENV
   ```

2. **文件哈希一致**

   ```bash
   pnpm nx build api --skip-nx-cache
   ```

3. **依赖版本一致**
   ```bash
   pnpm list --depth=0
   ```

---

### 性能问题

#### 症状: 命令执行慢

**诊断步骤**:

1. **检查并行度**

   ```bash
   pnpm nx run-many --target=build --all --parallel=5
   ```

2. **查看任务依赖**

   ```bash
   pnpm nx graph
   ```

3. **分析性能**
   ```bash
   NX_PERF_LOGGING=true pnpm nx build api
   ```

---

## 📊 性能监控

### Nx Cloud 分析

访问 [Nx Cloud](https://nx.app) 查看：

- 命令执行时间
- 缓存命中率
- 并行效率
- 热点分析

### 本地监控

```bash
# 启用性能日志
export NX_PERF_LOGGING=true

# 运行命令
pnpm nx build api

# 查看性能数据
cat .nx/perf.log
```

---

## 📚 相关资源

- [Nx 官方文档 - Performance](https://nx.dev/concepts/mental-model)
- [Nx Daemon 文档](https://nx.dev/concepts/nx-daemon)
- [Nx Cloud 文档](https://nx.dev/nx-cloud)
- [项目 Nx 配置](../nx.json)

---

## 🎓 培训和分享

### 团队培训

- **主题**: Nx 性能优化最佳实践
- **时长**: 30 分钟
- **内容**:
  1. Nx Daemon 介绍
  2. 缓存机制
  3. affected 命令使用
  4. 常见问题解决

### 知识分享

分享本指南给团队成员，确保大家都了解 Nx 的性能优化机制。

---

**文档维护**: DevOps Team  
**反馈渠道**: Slack #dev-tools  
**最后审查**: 2026-03-13
