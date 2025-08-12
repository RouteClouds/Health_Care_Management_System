# 🏗️ **Architecture Guide - System Design**

## 📖 **Architecture Index**

### 🎯 **System Overview**
- [High-Level Architecture](#high-level-architecture) - Complete system design
- [Component Diagram](#component-diagram) - Service interactions
- [Data Flow](#data-flow) - Information flow patterns

### 🔧 **Technical Stack**
- [Frontend Architecture](#frontend-architecture) - React/Vite application
- [Backend Architecture](#backend-architecture) - Node.js/Express services
- [Infrastructure Architecture](#infrastructure-architecture) - Kubernetes/EKS setup

### 🌍 **Deployment Architecture**
- [Multi-Environment Setup](#multi-environment-setup) - Dev/Staging/Production
- [CI/CD Pipeline Flow](#cicd-pipeline-flow) - Automated deployment process
- [Security Architecture](#security-architecture) - Security controls and measures

### 📊 **Diagrams & References**
- [Visual Diagrams](#visual-diagrams) - Architecture diagrams
- [Technical Specifications](#technical-specifications) - Detailed specs
- [Design Decisions](#design-decisions) - Architectural choices

---

## 🎯 **High-Level Architecture**

### **System Overview**
The Healthcare Management System follows a **microservices architecture** deployed on **Amazon EKS** with a **React frontend** and **Node.js backend**, implementing a **comprehensive CI/CD pipeline** with **GitHub Actions**.

```
┌─────────────────────────────────────────────────────────────────┐
│                    GitHub Actions CI/CD Pipeline                │
├─────────────────────────────────────────────────────────────────┤
│  Code Push → Tests → Build → Security Scan → Deploy → Verify   │
└─────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────┐
│                     Amazon EKS Cluster                         │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │    Dev      │  │   Staging   │  │ Production  │             │
│  │ Namespace   │  │ Namespace   │  │ Namespace   │             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
└─────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────┐
│                   Application Components                        │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │   React     │  │   Node.js   │  │  PostgreSQL │             │
│  │  Frontend   │  │   Backend   │  │  Database   │             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
└─────────────────────────────────────────────────────────────────┘
```

### **Key Architectural Principles**
- **Microservices**: Loosely coupled, independently deployable services
- **Container-First**: All components containerized with Docker
- **Cloud-Native**: Designed for Kubernetes orchestration
- **DevOps Integration**: Automated CI/CD with quality gates
- **Security by Design**: Security scanning and controls throughout

---

## 📊 **Component Diagram**

### **Service Interactions**
```
┌─────────────────┐    HTTP/HTTPS    ┌─────────────────┐
│                 │ ──────────────► │                 │
│   Load Balancer │                 │  Nginx Ingress  │
│   (AWS ALB)     │ ◄────────────── │   Controller    │
│                 │                 │                 │
└─────────────────┘                 └─────────────────┘
                                              │
                                              ▼
┌─────────────────┐    /api routes   ┌─────────────────┐
│                 │ ──────────────► │                 │
│  React Frontend │                 │  Node.js Backend│
│   (Port 80)     │ ◄────────────── │   (Port 3002)   │
│                 │                 │                 │
└─────────────────┘                 └─────────────────┘
                                              │
                                              ▼
┌─────────────────┐    SQL Queries   ┌─────────────────┐
│                 │ ──────────────► │                 │
│  Backend API    │                 │  PostgreSQL DB  │
│   Services      │ ◄────────────── │   (Port 5432)   │
│                 │                 │                 │
└─────────────────┘                 └─────────────────┘
```

### **Port Configuration**
- **Frontend**: Port 80 (Nginx serving React build)
- **Backend**: Port 3002 (Express.js API server)
- **Database**: Port 5432 (PostgreSQL)
- **Development**: Frontend on 5173 (Vite dev server)

---

## 🌊 **Data Flow**

### **Request Flow Pattern**
1. **User Request** → Load Balancer (AWS ALB)
2. **Load Balancer** → Nginx Ingress Controller
3. **Nginx** → Frontend (static files) OR Backend (/api routes)
4. **Backend** → PostgreSQL Database (if needed)
5. **Response** flows back through the same path

### **API Communication**
- **Frontend to Backend**: Relative URLs (`/api/...`)
- **Backend to Database**: Direct connection within cluster
- **External Services**: Through service mesh or direct HTTP

---

## 🔧 **Frontend Architecture**

### **Technology Stack**
- **Framework**: React 18 with TypeScript
- **Build Tool**: Vite (fast development and building)
- **Styling**: CSS Modules + Tailwind CSS
- **State Management**: React Context + Hooks
- **HTTP Client**: Axios for API communication
- **Testing**: Jest + React Testing Library

### **Component Structure**
```
src/
├── components/          # Reusable UI components
├── pages/              # Page-level components
├── services/           # API service layer
├── hooks/              # Custom React hooks
├── utils/              # Utility functions
├── types/              # TypeScript type definitions
└── test/               # Test utilities and setup
```

### **Build Process**
1. **Development**: Vite dev server on port 5173
2. **Production**: Static build served by Nginx on port 80
3. **Environment Variables**: `VITE_API_BASE_URL=/api`

---

## ⚙️ **Backend Architecture**

### **Technology Stack**
- **Runtime**: Node.js 18+ with TypeScript
- **Framework**: Express.js with middleware
- **Database**: PostgreSQL with connection pooling
- **Authentication**: JWT tokens
- **Validation**: Joi schema validation
- **Testing**: Jest + Supertest

### **Service Structure**
```
src/
├── controllers/        # Request handlers
├── services/          # Business logic layer
├── models/            # Database models
├── middleware/        # Express middleware
├── routes/            # API route definitions
├── utils/             # Utility functions
└── test/              # Test files
```

### **API Design**
- **RESTful**: Standard HTTP methods and status codes
- **Versioning**: `/api/v1/...` URL structure
- **Error Handling**: Consistent error response format
- **Logging**: Structured logging with correlation IDs

---

## ☸️ **Infrastructure Architecture**

### **Kubernetes Setup**
- **Cluster**: Amazon EKS with 3 worker nodes
- **Node Groups**: Auto-scaling groups for high availability
- **Networking**: VPC with public/private subnets
- **Storage**: EBS volumes for persistent data

### **Namespace Organization**
```
healthcare-dev          # Development environment
├── frontend-deployment
├── backend-deployment
├── database-deployment
└── services & ingress

healthcare-staging      # Staging environment
├── frontend-deployment
├── backend-deployment
├── database-deployment
└── services & ingress

healthcare-prod         # Production environment
├── frontend-deployment
├── backend-deployment
├── database-deployment
└── services & ingress
```

### **Resource Management**
- **CPU Requests**: 100m (frontend), 200m (backend)
- **Memory Requests**: 128Mi (frontend), 256Mi (backend)
- **Limits**: 2x requests for burstable workloads
- **Horizontal Pod Autoscaling**: Based on CPU/memory usage

---

## 🌍 **Multi-Environment Setup**

### **Environment Characteristics**
| Environment | Purpose | Deployment | Data | Access |
|-------------|---------|------------|------|--------|
| Development | Feature development | Automatic on PR | Test data | Internal |
| Staging | Pre-production testing | Automatic on main | Production-like | Internal |
| Production | Live system | Manual approval | Real data | Public |

### **Configuration Management**
- **Environment Variables**: Kubernetes ConfigMaps/Secrets
- **Database**: Separate instances per environment
- **Monitoring**: Environment-specific dashboards
- **Logging**: Centralized with environment tags

---

## 🚀 **CI/CD Pipeline Flow**

### **Pipeline Stages**
```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Trigger   │ ──►│    Build    │ ──►│    Test     │
│ (Git Push)  │    │ (Docker)    │    │ (Jest/E2E)  │
└─────────────┘    └─────────────┘    └─────────────┘
                                              │
                                              ▼
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Deploy    │ ◄──│   Security  │ ◄──│   Quality   │
│ (EKS)       │    │ (Trivy)     │    │ (SonarQube) │
└─────────────┘    └─────────────┘    └─────────────┘
```

### **Quality Gates**
- **Unit Tests**: Minimum 80% code coverage
- **E2E Tests**: Critical user journeys
- **Security Scan**: No high/critical vulnerabilities
- **Code Quality**: SonarQube quality gate pass
- **Performance**: Load testing in staging

---

## 🔒 **Security Architecture**

### **Security Layers**
1. **Network Security**: VPC, Security Groups, NACLs
2. **Cluster Security**: RBAC, Pod Security Standards
3. **Application Security**: Authentication, authorization
4. **Data Security**: Encryption at rest and in transit
5. **Pipeline Security**: Secret management, vulnerability scanning

### **Security Controls**
- **Authentication**: JWT tokens with refresh mechanism
- **Authorization**: Role-based access control (RBAC)
- **Secrets Management**: Kubernetes Secrets + AWS Secrets Manager
- **Network Policies**: Kubernetes NetworkPolicies
- **Image Scanning**: Trivy vulnerability scanning

---

## 📊 **Visual Diagrams**

### **Architecture Diagrams**
- **System Architecture**: Available in `Stage-2-Architecture/` directory
- **Network Diagram**: VPC and subnet configuration
- **Security Diagram**: Security controls and data flow
- **Deployment Diagram**: Kubernetes resource relationships

### **Monitoring Architecture**
- **Metrics**: Prometheus + Grafana
- **Logging**: ELK Stack (Elasticsearch, Logstash, Kibana)
- **Tracing**: Jaeger for distributed tracing
- **Alerting**: AlertManager with Slack integration

---

## 📋 **Technical Specifications**

### **Performance Requirements**
- **Response Time**: < 200ms for API calls
- **Throughput**: 1000 requests/second
- **Availability**: 99.9% uptime
- **Scalability**: Auto-scale 1-10 pods

### **Compliance Requirements**
- **HIPAA**: Healthcare data protection
- **SOC 2**: Security and availability controls
- **GDPR**: Data privacy and protection
- **PCI DSS**: Payment card data security

---

## 🎯 **Design Decisions**

### **Technology Choices**
- **React vs Angular**: React chosen for component reusability
- **Vite vs Webpack**: Vite for faster development builds
- **Express vs Fastify**: Express for ecosystem maturity
- **PostgreSQL vs MongoDB**: PostgreSQL for ACID compliance
- **EKS vs ECS**: EKS for Kubernetes ecosystem

### **Architectural Patterns**
- **Microservices**: For independent scaling and deployment
- **API Gateway**: Nginx for routing and load balancing
- **Event-Driven**: For asynchronous processing
- **CQRS**: Command Query Responsibility Segregation
- **Circuit Breaker**: For resilience and fault tolerance

---

**🏗️ This architecture provides a scalable, secure, and maintainable foundation for the Healthcare Management System with comprehensive automation and monitoring capabilities.**

**📞 Support**: For architecture questions, see [Master Setup Guide](MASTER-SETUP-GUIDE.md) or [Operations Guide](OPERATIONS.md).
