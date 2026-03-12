# 架构设计文档

本项目采用 **DDD + 六边形架构 + CQRS + EDA + Event Sourcing** 混合架构，构建企业级多租户 SaaS 数据分析平台。

---

## 架构概览

### 核心架构模式

| 模式                           | 解决的问题             | 对应目标              |
| ------------------------------ | ---------------------- | --------------------- |
| **DDD（领域驱动设计）**        | 复杂业务领域建模       | 所有目标              |
| **Hexagonal（六边形架构）**    | 业务核心与技术解耦     | 外部数据接入、AI 嵌入 |
| **CQRS（命令查询分离）**       | 读写分离，分析查询优化 | 数据分析              |
| **Event Sourcing（事件溯源）** | 完整审计，时间旅行     | 数据分析、数据仓库    |
| **EDA（事件驱动架构）**        | 松耦合跨域通信         | 所有目标              |

### 架构特点

| 特点              | 说明                                |
| ----------------- | ----------------------------------- |
| **领域纯净**      | 领域层无外部依赖，可独立测试        |
| **六边形边界**    | Primary/Secondary Port 清晰分离     |
| **CQRS 分离**     | 命令侧事件溯源，查询侧 ClickHouse   |
| **事件驱动**      | 模块间通过领域事件/集成事件通信     |
| **多租户隔离**    | 全链路租户上下文，行级数据隔离      |
| **Monorepo 统一** | pnpm workspace + Turborepo 统一管理 |

---

## 文档索引

| 文档                                                           | 内容                                |
| -------------------------------------------------------------- | ----------------------------------- |
| [archi-01-structure.md](./archi-01-structure.md)               | 项目结构与 Monorepo 组织            |
| [archi-02-domain.md](./archi-02-domain.md)                     | 领域层 - 聚合根、实体、值对象、Port |
| [archi-03-event-store.md](./archi-03-event-store.md)           | 事件存储与事件溯源实现              |
| [archi-04-read-model.md](./archi-04-read-model.md)             | 查询侧 - ClickHouse 读模型          |
| [archi-05-projection.md](./archi-05-projection.md)             | 投影（事件溯源 → 读模型）           |
| [archi-06-multi-tenant.md](./archi-06-multi-tenant.md)         | 多租户实现                          |
| [archi-07-command-handler.md](./archi-07-command-handler.md)   | 命令处理器与 CQRS                   |
| [archi-08-consumer.md](./archi-08-consumer.md)                 | 事件消费者与 Inbox 模式             |
| [archi-09-clickhouse.md](./archi-09-clickhouse.md)             | ClickHouse 表结构设计               |
| [archi-10-deployment.md](./archi-10-deployment.md)             | 部署架构                            |
| [archi-11-plugin-platform.md](./archi-11-plugin-platform.md)   | 插件系统与平台装配架构              |
| [archi-12-module-vs-plugin.md](./archi-12-module-vs-plugin.md) | NestJS 模块机制与项目插件机制对比   |

---

## 架构图

### 整体架构

```mermaid
flowchart TB
    subgraph Apps["Applications (应用入口)"]
        A1["platform-api<br/>(业务 API)"]
        A2["platform-admin-api<br/>(管理 API)"]
        A3["demo-api<br/>(演示)"]
    end

    subgraph Domains["Domains (领域模块)"]
        D1["job"]
        D2["tenant"]
        D3["identity"]
        D4["billing"]
        D5["data-ingestion"]
        D6["data-lake"]
        D7["data-warehouse"]
        D8["document"]
        D9["ai"]
    end

    subgraph Shared["Shared (共享基础设施)"]
        S1["event-store"]
        S2["cqrs"]
        S3["auth"]
        S4["authorization"]
        S5["database"]
        S6["messaging"]
        S7["kernel"]
        S8["ai-embeddings"]
    end

    Apps --> Domains
    Domains --> Shared
```

### 六边形架构（单个领域模块）

```mermaid
flowchart TB
    subgraph External["外部世界"]
        E1["REST API<br/>Controller"]
        E2["GraphQL<br/>Resolver"]
        E3["消息消费者<br/>Consumer"]
    end

    subgraph PrimaryAdapters["Primary Adapters (驱动适配器)"]
        PA1["REST Adapter"]
        PA2["GraphQL Adapter"]
        PA3["Message Adapter"]
    end

    subgraph PrimaryPorts["Primary Ports (驱动端口 - 领域层定义)"]
        PP1["Command Port"]
        PP2["Query Port"]
        PP3["Event Port"]
    end

    subgraph Domain["领域层"]
        subgraph DomainModel["领域模型"]
            DM1["Aggregate"]
            DM2["Entity"]
            DM3["ValueObject"]
            DM4["Events"]
            DM5["Services"]
            DM6["Rules"]
        end
        subgraph SecondaryPorts["Secondary Ports (被驱动端口)"]
            SP1["Repository Port"]
            SP2["EventStore Port"]
            SP3["Notification Port"]
        end
    end

    subgraph SecondaryAdapters["Secondary Adapters (被驱动适配器)"]
        SA1["PostgreSQL<br/>Repository"]
        SA2["ClickHouse<br/>Repository"]
        SA3["Kafka/Redis<br/>EventBus"]
    end

    External --> PrimaryAdapters
    PrimaryAdapters --> PrimaryPorts
    PrimaryPorts --> Domain
    Domain --> SecondaryPorts
    SecondaryPorts --> SecondaryAdapters
```

---

## 分层职责

| 层级               | 职责               | 依赖方向        | 包含组件                                          |
| ------------------ | ------------------ | --------------- | ------------------------------------------------- |
| **Presentation**   | 接收请求，格式转换 | → Application   | Controller, Resolver, DTO                         |
| **Application**    | 用例编排，CQRS     | → Domain        | Command, Query, Handler, Application Service      |
| **Domain**         | 核心业务逻辑       | 无外部依赖      | Aggregate, Entity, ValueObject, DomainEvent, Port |
| **Infrastructure** | 技术实现           | → Domain (Port) | Repository 实现, Adapter, Projector               |

---

## 数据流

### 命令流（写操作）

```mermaid
flowchart TD
    A["HTTP Request"] --> B["Controller<br/>(Primary Adapter)"]
    B --> C["Command<br/>(Application Layer)"]
    C --> D["CommandHandler<br/>(Application Layer)"]
    D --> E["领域逻辑<br/>(Domain Layer)"]
    E --> F["产生领域事件"]
    D --> G["EventStore.append()<br/>(Secondary Adapter)"]
    D --> H["EventBus.publish()<br/>(Secondary Adapter)"]
    H --> I["Outbox Table"]
    I --> J["Kafka<br/>(集成事件)"]
```

### 查询流（读操作）

```mermaid
flowchart TD
    A["HTTP Request"] --> B["Controller<br/>(Primary Adapter)"]
    B --> C["Query<br/>(Application Layer)"]
    C --> D["QueryHandler<br/>(Application Layer)"]
    D --> E["ReadRepository.find()<br/>(Secondary Adapter)"]
    E --> F["ClickHouse<br/>(读模型)"]
    F --> G["DTO<br/>(返回)"]
```

### 事件投影流

```mermaid
flowchart TD
    A["DomainEvent<br/>(事件存储)"] --> B["Projector<br/>(Infrastructure Layer)"]
    B --> C["处理事件"]
    B --> D["更新读模型"]
    D --> E["ClickHouse<br/>(读模型表)"]
```

---

## 修订历史

| 版本 | 日期       | 变更说明                                                   |
| ---- | ---------- | ---------------------------------------------------------- |
| v2.2 | 2026-02-22 | 新增 archi-12：NestJS 模块机制与项目插件机制对比           |
| v2.1 | 2026-02-20 | 新增 archi-11：插件系统与平台装配架构                      |
| v2.0 | 2026-02-20 | 全面重构：统一 Monorepo 架构、规范六边形架构、统一命名规范 |
| v1.0 | \-         | 初始版本                                                   |
