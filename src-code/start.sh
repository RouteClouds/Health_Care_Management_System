#!/bin/bash

# Health Care Management System - Startup Script
# This script starts the application and verifies everything is working

set -e

echo "🏥 Health Care Management System"
echo "================================"
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker and try again."
    exit 1
fi

echo "✅ Docker is running"

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose and try again."
    exit 1
fi

echo "✅ Docker Compose is available"

# Stop any existing containers
echo "🔄 Stopping any existing containers..."
docker compose down --volumes --remove-orphans 2>/dev/null || true

# Build and start services
echo "🚀 Building and starting services..."
docker compose up -d --build

echo ""
echo "⏳ Waiting for services to initialize..."
echo "This may take 2-3 minutes for the first run..."
echo ""

# Wait for database to be ready
echo "🗄️ Waiting for database..."
for i in {1..60}; do
    if docker compose exec -T database pg_isready -U healthcare_user -d healthcare_db > /dev/null 2>&1; then
        echo "✅ Database is ready"
        break
    fi
    if [ $i -eq 60 ]; then
        echo "❌ Database failed to start within 2 minutes"
        echo "Check logs with: docker compose logs database"
        exit 1
    fi
    echo "⏳ Waiting for database... ($i/60)"
    sleep 2
done

# Wait for backend to be ready
echo "🔧 Waiting for backend..."
for i in {1..60}; do
    if curl -s http://localhost:3002/health > /dev/null 2>&1; then
        echo "✅ Backend is ready"
        break
    fi
    if [ $i -eq 60 ]; then
        echo "❌ Backend failed to start within 2 minutes"
        echo "Check logs with: docker compose logs backend"
        exit 1
    fi
    echo "⏳ Waiting for backend... ($i/60)"
    sleep 2
done

# Wait for frontend to be ready
echo "🌐 Waiting for frontend..."
for i in {1..30}; do
    if curl -s http://localhost:5173 > /dev/null 2>&1; then
        echo "✅ Frontend is ready"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "❌ Frontend failed to start within 1 minute"
        echo "Check logs with: docker compose logs frontend"
        exit 1
    fi
    echo "⏳ Waiting for frontend... ($i/30)"
    sleep 2
done

echo ""
echo "🎉 All services are running!"
echo ""

# Test API endpoints
echo "🧪 Testing API endpoints..."

# Test health endpoint
if curl -s http://localhost:3002/health | grep -q "healthy"; then
    echo "✅ Health endpoint: Working"
else
    echo "❌ Health endpoint: Failed"
fi

# Test doctors endpoint
if curl -s http://localhost:3002/api/doctors | grep -q "success.*true"; then
    echo "✅ Doctors endpoint: Working"
else
    echo "❌ Doctors endpoint: Failed"
fi

# Test frontend
if curl -s http://localhost:5173 | grep -q "html"; then
    echo "✅ Frontend: Working"
else
    echo "❌ Frontend: Failed"
fi

echo ""
echo "🌐 Application URLs:"
echo "   Frontend: http://localhost:5173"
echo "   Backend API: http://localhost:3002"
echo "   Health Check: http://localhost:3002/health"
echo ""

echo "📊 Sample Data Available:"
echo "   - 4 Medical Departments"
echo "   - 5 Doctors with complete profiles"
echo "   - User registration and login ready"
echo "   - Appointment booking system ready"
echo ""

echo "🔧 Useful Commands:"
echo "   View logs: docker compose logs -f"
echo "   Stop services: docker compose down"
echo "   Restart: docker compose restart"
echo "   Reset everything: docker compose down -v && docker compose up -d"
echo ""

echo "🎯 Next Steps:"
echo "   1. Open http://localhost:5173 in your browser"
echo "   2. Register a new user account"
echo "   3. Browse doctors and book appointments"
echo "   4. Explore the healthcare management features"
echo ""

echo "✅ Setup complete! Your Health Care Management System is ready to use." 