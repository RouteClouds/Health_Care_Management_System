# 🏥 Health Care Management System

A comprehensive healthcare management platform built with React, Node.js, and PostgreSQL, featuring user authentication, doctor management, and appointment booking.

## 🚀 Quick Start (Zero Configuration)

### Prerequisites
- Docker and Docker Compose installed
- Git

### Clone and Run
```bash
# Clone the repository
git clone <your-repo-url>
cd Health_Care_Management_System/src-code

# Start all services (database, backend, frontend)
docker compose up -d

# Wait for initialization (about 2-3 minutes)
# The system will automatically:
# ✅ Initialize database schema
# ✅ Seed with sample data (4 departments, 5 doctors)
# ✅ Start all services
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

**Happy Coding! 🚀** 