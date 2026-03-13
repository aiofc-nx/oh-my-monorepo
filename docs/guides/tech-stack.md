# 技术栈清单

> 基于当前仓库配置自动梳理（主要来源：`package.json`、`pnpm-workspace.yaml`、`nx.json`、`docker/docker-compose.yml`）
>
> 更新日期：2026-03-12

## 1. 架构与项目组织

- **Monorepo 管理**：Nx (`nx@22.x`)
- **包管理器**：pnpm (`pnpm-workspace.yaml` + workspace catalog)
- **模块规范**：ESM（应用包 `type: "module"`，本地导入使用 `.js` 后缀）
- **架构模式**：DDD + CQRS + EDA（按 `apps/*` 与 `libs/*` 分层）

## 2. 前端技术栈（Web Admin）

- **全栈前端框架**：TanStack Start
- **UI 框架**：React 19 + React DOM 19
- **路由**：TanStack Router
- **数据请求与缓存**：TanStack Query
- **表单**：React Hook Form + Zod + `@hookform/resolvers`
- **UI 组件基础**：Radix UI
- **样式体系**：Tailwind CSS 4 + `tailwind-merge` + `class-variance-authority` + `clsx`
- **图标与交互**：Lucide React + Sonner
- **构建工具**：Vite
- **SSR 相关运行时**：Nitro（alpha 版本）

## 3. 后端技术栈（Gateway）

- **后端框架**：NestJS 11（`@nestjs/common/core/platform-express` 等）
- **认证体系**：Better Auth + `@oksai/nestjs-better-auth` + `@better-auth/api-key`
- **鉴权能力**：Passport + JWT + Header API Key
- **接口文档**：Swagger（`@nestjs/swagger`）+ Scalar API Reference
- **限流与安全**：`@nestjs/throttler`
- **数据校验与转换**：`class-validator` + `class-transformer`
- **响应式编程**：RxJS

## 4. 数据与中间件

- **关系数据库**：PostgreSQL 16（`pgvector/pgvector:pg16`）
- **ORM**：MikroORM 6（Core + PostgreSQL + NestJS 适配）
- **向量能力**：pgvector（通过 Postgres 镜像提供）
- **缓存**：Redis 7
- **消息队列**：RabbitMQ 3（带管理控制台）
- **对象存储**：MinIO（S3 兼容）

## 5. 测试与质量保障

- **单元/集成测试**：Vitest
- **前端 E2E**：Playwright
- **代码规范与格式化**：Biome
- **Git Hook**：Husky + lint-staged

## 6. 构建与发布工具链

- **TypeScript**：5.9.x（严格模式）
- **构建加速/转译**：SWC（`@swc/core`、`@swc-node/register`）
- **库打包**：tsup（用于部分库）
- **本地私有 npm 仓库**：Verdaccio（Nx target）
- **容器编排**：Docker Compose

## 7. 运维与开发辅助服务

- **数据库管理**：pgAdmin 4
- **邮件调试**：MailHog
- **本地基础设施一键启动**：`docker/docker-compose.yml`

## 8. 内部业务库（Workspace Packages）

项目内部采用 `@oksai/*` 共享库体系，典型包括：

- **核心能力**：`@oksai/config`、`@oksai/logger`、`@oksai/context`、`@oksai/constants`、`@oksai/exceptions`
- **数据与基础设施**：`@oksai/database`、`@oksai/cache`
- **认证与租户**：`@oksai/iam-identity`、`@oksai/iam-tenancy`、`@oksai/multi-tenancy`
- **NestJS 集成**：`@oksai/nestjs-utils`、`@oksai/nestjs-better-auth`

## 9. 版本说明与维护建议

- 本文档优先反映“仓库当前实际依赖”，不等同于历史文档中的阶段性状态。
- 个别依赖（如 `drizzle-orm`）仍可能因兼容或迁移过渡存在，应以当前业务模块实际引用为准。
- 建议在每次框架升级或迁移完成后，同步更新本文档与 `docs/README.md` 索引。