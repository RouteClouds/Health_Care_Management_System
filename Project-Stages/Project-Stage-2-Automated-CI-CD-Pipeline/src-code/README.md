# 💻 **Source Code - Quick Setup**

## 📖 **Quick Index**

### ⚡ **Automated Setup (Recommended)**
- [One-Command Setup](#one-command-setup) - Complete environment configuration
- [Validation](#validation) - Verify setup is correct

### 🔧 **Manual Setup (If Needed)**
- [Dependencies](#dependencies) - Install packages manually
- [Environment Configuration](#environment-configuration) - Manual config
- [Build & Test](#build-test) - Manual build and testing

### 🔍 **Validation Tools**
- [Setup Validation](#setup-validation) - Environment health check
- [Port Configuration](#port-configuration) - Frontend-backend communication
- [Build Verification](#build-verification) - Ensure builds work

---

## ⚡ **One-Command Setup**

### **Automated Environment Setup**
```bash
# Complete setup in one command
./setup-environment.sh

# This script automatically:
# ✅ Validates Node.js and npm versions
# ✅ Installs root workspace dependencies
# ✅ Installs frontend dependencies
# ✅ Installs backend dependencies
# ✅ Generates package-lock.json files
# ✅ Tests build processes
# ✅ Runs basic validation tests
```

---

## ✅ **Validation**

### **Quick Validation**
```bash
# Verify everything is working
./validate-setup.sh
./validate-port-config.sh

# Both should show all green checkmarks
```

### **What Gets Validated**
- ✅ Node.js and npm versions
- ✅ Project structure and dependencies
- ✅ Package lock files exist
- ✅ Build processes work
- ✅ Port configurations are correct
- ✅ Frontend-backend communication setup

---

## 🔧 **Manual Setup (If Needed)**

### **Dependencies**
```bash
# Install root dependencies
npm install

# Install frontend dependencies
cd frontend && npm install && cd ..

# Install backend dependencies
cd backend && npm install && cd ..
```

### **Environment Configuration**
```bash
# Frontend environment (already configured)
cat frontend/.env.k8s
# Should show: VITE_API_BASE_URL=/api

# Backend environment (already configured)
cat backend/.env.k8s
# Should show: PORT=3002
```

### **Build & Test**
```bash
# Test builds
cd frontend && npm run build && cd ..
cd backend && npm run build && cd ..

# Run tests
npm test -- --testPathIgnorePatterns=tests/e2e
```

---

## 🔍 **Validation Tools**

### **Setup Validation**
```bash
# Complete environment check
./validate-setup.sh

# Checks:
# ✅ Node.js version (18.x or 20.x)
# ✅ npm version (8.x+)
# ✅ Project structure
# ✅ Dependencies installed
# ✅ Package lock files
# ✅ Build processes
```

### **Port Configuration**
```bash
# Frontend-backend communication check
./validate-port-config.sh

# Checks:
# ✅ Frontend uses /api for backend calls
# ✅ Backend runs on port 3002
# ✅ No hardcoded localhost URLs
# ✅ Nginx proxy configuration
# ✅ Kubernetes service ports
```

### **Build Verification**
```bash
# Verify builds work
npm run build

# Run tests
npm test

# Check for issues
npm audit
```

---

## 🚀 **Development Commands**

### **Start Development Servers**
```bash
# Start frontend (port 5173)
cd frontend && npm run dev

# Start backend (port 3002)
cd backend && npm run dev

# Start both with Docker Compose
docker-compose up
```

### **Testing Commands**
```bash
# Unit tests only
npm test -- --testPathIgnorePatterns=tests/e2e

# All tests (requires running application)
npm test

# E2E tests (requires running application)
npm run test:e2e
```

### **Build Commands**
```bash
# Build frontend
cd frontend && npm run build

# Build backend
cd backend && npm run build

# Build Docker images
docker-compose build
```

---

## 📁 **Project Structure**
```
src-code/
├── frontend/           # React application
├── backend/            # Node.js API server
├── nginx/              # Nginx configuration
├── k8s/                # Kubernetes manifests
├── docker-compose.yml  # Local development
├── setup-environment.sh    # Automated setup
├── validate-setup.sh       # Environment validation
└── validate-port-config.sh # Port validation
```

---

## 🎯 **Success Indicators**

### **Setup Complete**
- [ ] `./setup-environment.sh` runs without errors
- [ ] `./validate-setup.sh` shows all green checkmarks
- [ ] `./validate-port-config.sh` shows all green checkmarks
- [ ] `npm test` passes (unit tests)
- [ ] `npm run build` succeeds

### **Ready for Development**
- [ ] Frontend starts on port 5173
- [ ] Backend starts on port 3002
- [ ] API calls work between frontend and backend
- [ ] Docker builds succeed

---

## 📞 **Support**

### **Common Issues**
- **Node.js Version**: Use Node.js 18.x or 20.x
- **Permission Errors**: Run `chmod +x *.sh` for script permissions
- **Port Conflicts**: Check if ports 5173 or 3002 are in use
- **Build Failures**: Run `./setup-environment.sh` to reset

### **Getting Help**
1. **First**: Run validation scripts to identify issues
2. **Second**: Check [Troubleshooting Guide](../docs/TROUBLESHOOTING.md)
3. **Third**: Review [Master Setup Guide](../docs/MASTER-SETUP-GUIDE.md)

---

**💻 This source code is ready for Stage 2 CI/CD pipeline deployment with comprehensive automation and validation.**

# This script will:
# ✅ Validate prerequisites
# ✅ Install all dependencies (root, frontend, backend)
# ✅ Generate required package-lock.json files
# ✅ Test build processes
# ✅ Verify environment is ready for CI/CD
```

### Option 2: Docker Compose (Zero Configuration)
```bash
# Start all services (database, backend, frontend)
docker compose up -d

# Wait for initialization (about 2-3 minutes)
# The system will automatically:
# ✅ Initialize database schema
# ✅ Seed with sample data (4 departments, 5 doctors)
# ✅ Start all services
```

### Validation
```bash
# Validate your setup anytime
./validate-setup.sh

# This will check:
# ✅ Node.js and npm versions
# ✅ Project structure
# ✅ Package lock files
# ✅ Dependencies installation
# ✅ Build processes
```

### Access the Application
- **Frontend**: http://localhost:5173
- **Backend API**: http://localhost:3002
- **Database**: localhost:5432 (PostgreSQL)

## 🎯 What's Included (Automatically)

### 📊 Sample Data
The system automatically creates:
- **4 Medical Departments**: Cardiology, Pulmonology, Neurology, Orthopedics
- **5 Doctors**: Complete profiles with specializations and consultation fees
- **Database Schema**: All tables for users, doctors, appointments, departments

### 🔐 Features Ready to Use
- ✅ **User Registration & Login**
- ✅ **Doctor Browsing & Search**
- ✅ **Appointment Booking System**
- ✅ **Department-based Doctor Filtering**
- ✅ **Responsive Web Interface**

## 🛠️ Development Setup

### Local Development
```bash
# Start in development mode with hot reload
docker compose -f docker-compose.yml up -d

# View logs
docker compose logs -f

# Stop services
docker compose down
```

### Database Management
```bash
# Access database directly
docker compose exec database psql -U healthcare_user -d healthcare_db

# Reset database (removes all data)
docker compose down -v
docker compose up -d
```

## 📁 Project Structure
```
src-code/
├── backend/                 # Node.js/Express API
│   ├── src/                # Source code
│   ├── prisma/             # Database schema
│   └── scripts/            # Auto-initialization scripts
├── frontend/               # React application
│   ├── src/                # Source code
│   └── public/             # Static assets
├── nginx/                  # Reverse proxy configuration
├── docker-compose.yml      # Service orchestration
└── README.md              # This file
```

## 🔧 Configuration

### Environment Variables
All environment variables are pre-configured in `docker-compose.yml`:
- **Database**: PostgreSQL with healthcare_db
- **Backend**: Node.js API on port 3002
- **Frontend**: React app served via Nginx on port 5173

### Customization
To modify the setup:
1. Edit `docker-compose.yml` for service configuration
2. Modify `backend/scripts/init-db.sh` for sample data
3. Update `backend/prisma/schema.prisma` for database schema

## 🚨 Troubleshooting

### Common Issues

#### 1. Port Already in Use
```bash
# Check what's using the ports
lsof -i :5173
lsof -i :3002
lsof -i :5432

# Stop conflicting services or change ports in docker-compose.yml
```

#### 2. Database Connection Issues
```bash
# Check database logs
docker compose logs database

# Restart database
docker compose restart database
```

#### 3. Backend Not Starting
```bash
# Check backend logs
docker compose logs backend

# Rebuild backend
docker compose build backend
docker compose up -d
```

#### 4. Frontend Not Loading
```bash
# Check frontend logs
docker compose logs frontend

# Check nginx logs
docker compose logs nginx
```

### Reset Everything
```bash
# Complete reset (removes all data)
docker compose down -v
docker system prune -f
docker compose up -d
```

## 📊 Health Checks

### Verify System Status
```bash
# Check all services
docker compose ps

# Test API endpoints
curl http://localhost:3002/health
curl http://localhost:3002/api/doctors

# Test frontend
curl http://localhost:5173
```

### Expected Output
```bash
# Health check
{"status":"healthy","timestamp":"2025-01-08T...","uptime":123.45}

# Doctors endpoint
{"success":true,"data":{"doctors":[...]}}
```

## 🎉 Success Indicators

When everything is working correctly, you should see:
- ✅ All containers showing "running" status
- ✅ Frontend loads at http://localhost:5173
- ✅ Can register new users
- ✅ Can login with credentials
- ✅ Can browse doctors and book appointments
- ✅ API endpoints responding correctly

## 🔄 Production Deployment

For production deployment, see:
- `Project-Stages/Project-Stage-1-Basic-CI-CD-Deploy/` for EKS deployment
- `Project-Stages/Project-Stage-1-Basic-CI-CD-Deploy/docs/` for detailed guides

## 📞 Support

If you encounter issues:
1. Check the troubleshooting section above
2. Review logs: `docker compose logs [service-name]`
3. Ensure Docker and Docker Compose are up to date
4. Check system resources (CPU, memory, disk space)

## 🏷️ Version Information
- **Backend**: Node.js 18, Express, Prisma ORM
- **Frontend**: React 18, TypeScript, Vite
- **Database**: PostgreSQL 15
- **Reverse Proxy**: Nginx
- **Containerization**: Docker & Docker Compose

---

**Happy Coding! 🚀** // Stage 2 CI/CD Pipeline Trigger - Mon Aug 12 2025 - Automated Testing & Deployment Active
