# Health Care Management System - Docker Architecture (Mermaid)

## Container Communication Flow

```mermaid
graph TB
    subgraph "Host System (Ubuntu Linux)"
        subgraph "Docker Network: healthcare-network"
            subgraph "Frontend Container"
                F1[🌐 React App<br/>Vite Build]
                F2[📦 Nginx Server<br/>Port 80]
                F3[🔍 Health Check<br/>/health]
                F1 --> F2
                F2 --> F3
            end
            
            subgraph "Backend Container"
                B1[🔧 Node.js App<br/>Express Server]
                B2[🗃️ Prisma ORM<br/>Database Client]
                B3[🔍 Health Check<br/>/health]
                B4[📡 API Endpoints<br/>/api/*]
                B1 --> B2
                B1 --> B3
                B1 --> B4
            end
            
            subgraph "Database Container"
                D1[🗄️ PostgreSQL 15<br/>Alpine Linux]
                D2[🔍 Health Check<br/>pg_isready]
                D3[🔐 SCRAM-SHA-256<br/>Authentication]
                D1 --> D2
                D1 --> D3
            end
            
            subgraph "Docker Volume"
                V1[💾 postgres_data<br/>Persistent Storage]
            end
        end
        
        subgraph "Host Ports"
            P1[🌐 Port 5173<br/>Frontend Access]
            P2[🔧 Port 3002<br/>Backend API]
            P3[🗄️ Port 5432<br/>Database Access]
        end
    end
    
    subgraph "External Access"
        U1[👤 Users<br/>Web Browser]
        U2[🔧 Developers<br/>API Testing]
        U3[🗄️ Database<br/>Admin Tools]
    end
    
    %% External connections
    U1 -->|HTTP Requests| P1
    U2 -->|API Calls| P2
    U3 -->|SQL Queries| P3
    
    %% Port mappings
    P1 -->|5173:80| F2
    P2 -->|3002:3002| B1
    P3 -->|5432:5432| D1
    
    %% Internal communication
    F2 -->|API Proxy<br/>/api/*| B1
    B2 -->|SQL Queries<br/>Prisma Client| D1
    D1 -->|Data Storage| V1
    
    %% Health checks
    F3 -.->|30s interval| F2
    B3 -.->|30s interval| B1
    D2 -.->|30s interval| D1
    
    %% Styling
    classDef frontend fill:#61DAFB,stroke:#333,stroke-width:2px,color:#000
    classDef backend fill:#68A063,stroke:#333,stroke-width:2px,color:#fff
    classDef database fill:#336791,stroke:#333,stroke-width:2px,color:#fff
    classDef volume fill:#4ECDC4,stroke:#333,stroke-width:2px,color:#000
    classDef port fill:#FF8C42,stroke:#333,stroke-width:2px,color:#fff
    classDef user fill:#F7DC6F,stroke:#333,stroke-width:2px,color:#000
    
    class F1,F2,F3 frontend
    class B1,B2,B3,B4 backend
    class D1,D2,D3 database
    class V1 volume
    class P1,P2,P3 port
    class U1,U2,U3 user
```

## Service Architecture Details

```mermaid
graph LR
    subgraph "Request Flow"
        A[User Request] --> B[Frontend Container<br/>Nginx:80]
        B --> C{Request Type}
        C -->|Static Files| D[Serve React App]
        C -->|API Calls| E[Proxy to Backend]
        E --> F[Backend Container<br/>Express:3002]
        F --> G[Process Request]
        G --> H[Prisma ORM]
        H --> I[Database Container<br/>PostgreSQL:5432]
        I --> J[Query Database]
        J --> K[Return Data]
        K --> H
        H --> G
        G --> F
        F --> E
        E --> B
        B --> A
    end
    
    classDef process fill:#e1f5fe,stroke:#01579b,stroke-width:2px
    classDef container fill:#f3e5f5,stroke:#4a148c,stroke-width:2px
    classDef database fill:#e8f5e8,stroke:#1b5e20,stroke-width:2px
    
    class A,D,G,J,K process
    class B,E,F container
    class I database
```

## Container Health Monitoring

```mermaid
graph TD
    subgraph "Health Check System"
        H1[Docker Compose<br/>Health Orchestrator]
        
        subgraph "Frontend Health"
            FH1[Nginx Health Check]
            FH2[curl -f localhost:80/]
            FH3[30s interval, 3 retries]
            FH1 --> FH2 --> FH3
        end
        
        subgraph "Backend Health"
            BH1[Express Health Check]
            BH2[curl -f localhost:3002/health]
            BH3[30s interval, 3 retries]
            BH1 --> BH2 --> BH3
        end
        
        subgraph "Database Health"
            DH1[PostgreSQL Health Check]
            DH2[pg_isready -U healthcare_user]
            DH3[30s interval, 5 retries]
            DH1 --> DH2 --> DH3
        end
        
        H1 --> FH1
        H1 --> BH1
        H1 --> DH1
        
        FH3 --> S1[✅ Healthy]
        BH3 --> S2[✅ Healthy]
        DH3 --> S3[✅ Healthy]
        
        S1 --> R1[Auto-restart if unhealthy]
        S2 --> R2[Auto-restart if unhealthy]
        S3 --> R3[Auto-restart if unhealthy]
    end
    
    classDef health fill:#c8e6c9,stroke:#2e7d32,stroke-width:2px
    classDef status fill:#a5d6a7,stroke:#388e3c,stroke-width:2px
    classDef restart fill:#ffcdd2,stroke:#d32f2f,stroke-width:2px
    
    class FH1,FH2,FH3,BH1,BH2,BH3,DH1,DH2,DH3 health
    class S1,S2,S3 status
    class R1,R2,R3 restart
```

## Docker Compose Configuration

```mermaid
graph TB
    subgraph "docker-compose.yml"
        subgraph "Services"
            S1[frontend:<br/>healthcare-frontend]
            S2[backend:<br/>healthcare-backend]
            S3[database:<br/>healthcare-db]
        end
        
        subgraph "Networks"
            N1[healthcare-network<br/>Custom Bridge]
        end
        
        subgraph "Volumes"
            V1[postgres_data<br/>Named Volume]
        end
        
        subgraph "Environment Variables"
            E1[DATABASE_URL<br/>Connection String]
            E2[NODE_ENV<br/>development]
            E3[POSTGRES_DB<br/>healthcare_db]
            E4[POSTGRES_USER<br/>healthcare_user]
        end
        
        S1 --> N1
        S2 --> N1
        S3 --> N1
        S3 --> V1
        S2 --> E1
        S2 --> E2
        S3 --> E3
        S3 --> E4
    end
    
    classDef service fill:#e3f2fd,stroke:#0277bd,stroke-width:2px
    classDef network fill:#fff3e0,stroke:#ef6c00,stroke-width:2px
    classDef volume fill:#f1f8e9,stroke:#558b2f,stroke-width:2px
    classDef env fill:#fce4ec,stroke:#c2185b,stroke-width:2px
    
    class S1,S2,S3 service
    class N1 network
    class V1 volume
    class E1,E2,E3,E4 env
```

## Performance & Resource Usage

| Component | Memory Usage | Image Size | Startup Time | Port Mapping |
|-----------|-------------|------------|--------------|--------------|
| Frontend | ~15MB | ~45MB | ~3 seconds | 5173:80 |
| Backend | ~45MB | ~180MB | ~4 seconds | 3002:3002 |
| Database | ~25MB | ~240MB | ~3 seconds | 5432:5432 |
| **Total** | **~85MB** | **~465MB** | **<10 seconds** | **3 ports** |

## Key Features

- ✅ **Multi-stage builds** for optimized image sizes
- ✅ **Health checks** with automatic restart policies
- ✅ **Custom Docker network** for service isolation
- ✅ **Persistent volumes** for database data
- ✅ **Non-root users** for security hardening
- ✅ **Alpine Linux** base images for minimal footprint
- ✅ **API proxy** configuration in Nginx
- ✅ **Environment-based** configuration management
