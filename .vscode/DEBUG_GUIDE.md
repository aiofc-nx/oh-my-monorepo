# VSCode 调试配置使用指南

## 📋 可用配置

### 1. Debug App (NestJS)
- **用途**: 调试 NestJS 应用
- **端口**: 9229
- **使用场景**: 开发和调试后端 API

**使用步骤**:
1. 在 VSCode 中按 `F5` 或点击"运行和调试"
2. 选择 "Debug App (NestJS)"
3. 输入应用名称（如 `api`）
4. 在代码中设置断点
5. 开始调试

### 2. Debug App (React + Vite)
- **用途**: 调试 React 应用
- **端口**: 9230
- **使用场景**: 开发和调试前端应用

### 3. Debug Jest Tests
- **用途**: 调试 Jest 单元测试
- **端口**: 9250
- **使用场景**: 调试测试用例

**使用步骤**:
1. 打开测试文件
2. 在测试代码中设置断点
3. 按 `F5`，选择 "Debug Jest Tests"
4. 输入项目名称
5. 开始调试测试

### 4. Debug Vitest Tests
- **用途**: 调试 Vitest 单元测试
- **端口**: 9251
- **使用场景**: 调试 Vitest 测试用例

### 5. Attach to Node Process (9229)
- **用途**: 附加到已运行的 Node 进程
- **端口**: 9229
- **使用场景**: 调试生产环境或已启动的应用

**使用步骤**:
1. 启动应用时添加 `--inspect=9229` 参数
   ```bash
   NODE_OPTIONS="--inspect=9229" pnpm nx serve api
   ```
2. 在 VSCode 中按 `F5`
3. 选择 "Attach to Node Process (9229)"
4. 开始调试

### 6. Attach to Node Process (Custom Port)
- **用途**: 附加到指定端口的 Node 进程
- **使用场景**: 当需要使用非标准端口时

### 7. Debug E2E Tests
- **用途**: 调试 E2E 测试
- **端口**: 9252
- **使用场景**: 调试端到端测试

---

## 🔧 端口分配规则

| 端口范围 | 用途 | 示例 |
|---------|------|------|
| 9229-9249 | 应用调试 | NestJS: 9229, React: 9230 |
| 9250-9269 | 测试调试 | Jest: 9250, Vitest: 9251 |
| 9270-9289 | E2E 测试 | Cypress: 9270, Playwright: 9271 |

---

## 📝 如何添加新的调试配置

### 场景 1: 添加新的 NestJS 应用调试

**步骤**:
1. 打开 `.vscode/launch.json`
2. 复制 "Debug App (NestJS)" 配置
3. 修改以下字段：
   - `name`: 改为新应用名称
   - `NODE_OPTIONS`: 改为新端口（如 9231）
   - `outFiles`: 更新项目路径

**示例**:
```json
{
  "type": "node",
  "request": "launch",
  "name": "Debug admin (NestJS)",
  "runtimeExecutable": "pnpm exec",
  "runtimeArgs": ["nx", "serve", "admin"],
  "env": {
    "NODE_OPTIONS": "--inspect=9231"
  },
  "outFiles": [
    "${workspaceFolder}/apps/admin/dist/**/*.(m|c|)js",
    "!**/node_modules/**"
  ]
}
```

### 场景 2: 添加新的测试调试配置

**步骤**:
1. 打开 `.vscode/launch.json`
2. 复制 "Debug Jest Tests" 配置
3. 修改端口和项目名称

---

## 🎯 常见问题

### Q1: 端口冲突怎么办？

**原因**: 多个调试器使用相同端口

**解决方案**:
1. 检查是否有其他调试会话正在运行
2. 修改配置中的端口号
3. 重启 VSCode

### Q2: 断点不生效？

**可能原因**:
- Source maps 未正确配置
- 代码未编译
- 路径不匹配

**解决方案**:
1. 确保 `sourceMaps: true`
2. 检查 `outFiles` 路径是否正确
3. 先运行 `pnpm nx build <project>`

### Q3: 无法附加到进程？

**可能原因**:
- 进程未启动调试模式
- 端口不正确

**解决方案**:
1. 确保进程启动时添加了 `--inspect` 参数
2. 检查端口是否正确
3. 使用 "Attach to Node Process (Custom Port)" 配置

---

## 🔍 调试技巧

### 技巧 1: 条件断点
1. 右键点击断点
2. 选择"编辑断点"
3. 添加条件表达式（如 `i === 5`）

### 技巧 2: 日志点（Logpoint）
1. 右键点击代码行
2. 选择"添加日志点"
3. 输入要记录的表达式
4. 不会暂停执行，只会输出日志

### 技巧 3: 多会话调试
1. 同时启动多个调试配置
2. 在调试面板中切换不同的会话
3. 可以同时调试前端和后端

### 技巧 4: 使用调试控制台
1. 在调试时打开调试控制台
2. 可以执行任意 JavaScript 代码
3. 可以检查变量和调用函数

---

## 📚 相关资源

- [VSCode 调试文档](https://code.visualstudio.com/docs/editor/debugging)
- [Node.js 调试指南](https://nodejs.org/en/docs/guides/debugging-getting-started/)
- [Nx 调试最佳实践](https://nx.dev/more-concepts/vscode-debugging)

---

## 📊 配置对比

| 特性 | 旧版本 | 新版本 |
|-----|-------|-------|
| 配置数量 | 2 | 7 |
| 支持测试调试 | ❌ | ✅ |
| 支持附加到进程 | ❌ | ✅ |
| 使用输入变量 | ❌ | ✅ |
| 支持三目录架构 | ❌ | ✅ |
| 文档完善度 | 低 | 高 |
| 灵活性 | 低 | 高 |

---

## 🎉 新功能

1. **输入变量**: 自动选择项目，无需手动修改配置
2. **完整测试支持**: 支持 Jest 和 Vitest 测试调试
3. **Attach 模式**: 可以附加到运行中的进程
4. **三目录支持**: 支持 apps/, libs/, packages/
5. **详细注释**: 每个配置都有清晰的说明

---

## 💬 反馈

如有问题或建议，请：
1. 查看 `.vscode/launch.json` 中的注释
2. 参考本文档
3. 联系团队成员
