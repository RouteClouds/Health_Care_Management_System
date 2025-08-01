#!/bin/bash

# Database Initialization Script for Healthcare Management System
# This script initializes the PostgreSQL database with schema and sample data

set -e

echo "🗄️ Initializing Healthcare Database..."
echo "========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Get backend pod
print_info "Finding backend pod..."
BACKEND_POD=$(kubectl get pods -n healthcare -l app=healthcare-backend -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ -z "$BACKEND_POD" ]; then
    print_error "No backend pod found"
    print_info "Make sure the backend deployment is running:"
    print_info "kubectl get pods -n healthcare -l app=healthcare-backend"
    exit 1
fi

print_status "Found backend pod: $BACKEND_POD"

# Check if pod is ready
POD_STATUS=$(kubectl get pod $BACKEND_POD -n healthcare -o jsonpath='{.status.phase}')
if [ "$POD_STATUS" != "Running" ]; then
    print_error "Backend pod is not running (status: $POD_STATUS)"
    exit 1
fi

# Initialize schema
print_info "Pushing database schema..."
if kubectl exec $BACKEND_POD -n healthcare -- npx prisma db push; then
    print_status "Database schema initialized successfully"
else
    print_error "Failed to initialize database schema"
    exit 1
fi

# Seed database
print_info "Seeding database with sample data..."
kubectl exec $BACKEND_POD -n healthcare -- node -e "
(async () => {
  const { PrismaClient } = require('@prisma/client');
  const prisma = new PrismaClient();
  
  try {
    console.log('🔍 Checking existing data...');
    
    // Check if data already exists
    const existingDoctors = await prisma.doctor.count();
    const existingDepartments = await prisma.department.count();
    
    if (existingDoctors > 0) {
      console.log('✅ Database already has ' + existingDoctors + ' doctors, skipping seed');
      return;
    }
    
    console.log('🏢 Creating departments...');
    
    // Create departments
    const cardiology = await prisma.department.create({
      data: { 
        name: 'Cardiology', 
        code: 'CARD', 
        description: 'Heart and cardiovascular system' 
      }
    });
    
    const pulmonology = await prisma.department.create({
      data: { 
        name: 'Pulmonology', 
        code: 'PULM', 
        description: 'Lungs and respiratory system' 
      }
    });
    
    const neurology = await prisma.department.create({
      data: { 
        name: 'Neurology', 
        code: 'NEUR', 
        description: 'Brain and nervous system' 
      }
    });
    
    const orthopedics = await prisma.department.create({
      data: { 
        name: 'Orthopedics', 
        code: 'ORTH', 
        description: 'Bones, joints, and muscles' 
      }
    });
    
    console.log('👨‍⚕️ Creating doctors...');
    
    // Create doctors
    await prisma.doctor.create({
      data: {
        firstName: 'John',
        lastName: 'Smith',
        email: 'john.smith@hospital.com',
        specialization: 'Cardiologist',
        departmentId: cardiology.id,
        qualifications: ['MD', 'FACC'],
        experienceYears: 10,
        consultationFee: 200.0
      }
    });
    
    await prisma.doctor.create({
      data: {
        firstName: 'Sarah',
        lastName: 'Johnson',
        email: 'sarah.johnson@hospital.com',
        specialization: 'Pulmonologist',
        departmentId: pulmonology.id,
        qualifications: ['MD', 'FCCP'],
        experienceYears: 8,
        consultationFee: 180.0
      }
    });
    
    await prisma.doctor.create({
      data: {
        firstName: 'Michael',
        lastName: 'Brown',
        email: 'michael.brown@hospital.com',
        specialization: 'Neurologist',
        departmentId: neurology.id,
        qualifications: ['MD', 'PhD'],
        experienceYears: 15,
        consultationFee: 250.0
      }
    });
    
    await prisma.doctor.create({
      data: {
        firstName: 'Emily',
        lastName: 'Davis',
        email: 'emily.davis@hospital.com',
        specialization: 'Orthopedic Surgeon',
        departmentId: orthopedics.id,
        qualifications: ['MD', 'FAAOS'],
        experienceYears: 12,
        consultationFee: 300.0
      }
    });
    
    await prisma.doctor.create({
      data: {
        firstName: 'David',
        lastName: 'Wilson',
        email: 'david.wilson@hospital.com',
        specialization: 'Interventional Cardiologist',
        departmentId: cardiology.id,
        qualifications: ['MD', 'FACC', 'FSCAI'],
        experienceYears: 18,
        consultationFee: 350.0
      }
    });
    
    console.log('✅ Database seeded successfully!');
    console.log('📊 Created: 4 departments, 5 doctors');
    
  } catch (error) {
    console.error('❌ Seeding error:', error.message);
    process.exit(1);
  } finally {
    await prisma.\$disconnect();
  }
})();
"

if [ $? -eq 0 ]; then
    print_status "Database seeded successfully"
else
    print_error "Failed to seed database"
    exit 1
fi

# Test API endpoints
print_info "Testing API endpoints..."
EXTERNAL_URL=$(kubectl get service frontend-service -n healthcare -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)

if [ ! -z "$EXTERNAL_URL" ] && [ "$EXTERNAL_URL" != "null" ]; then
    print_info "Testing: http://$EXTERNAL_URL/api/doctors"
    
    # Test doctors endpoint
    RESPONSE=$(curl -s "http://$EXTERNAL_URL/api/doctors" | jq -r '.success' 2>/dev/null)
    
    if [ "$RESPONSE" = "true" ]; then
        print_status "API endpoints working correctly"
        
        # Get doctor count
        DOCTOR_COUNT=$(curl -s "http://$EXTERNAL_URL/api/doctors" | jq -r '.data.pagination.total' 2>/dev/null)
        print_info "Total doctors in database: $DOCTOR_COUNT"
        
        print_status "Database initialization complete!"
        echo ""
        print_info "🌐 Application URL: http://$EXTERNAL_URL"
        print_info "🔗 API Docs: http://$EXTERNAL_URL/api/"
        print_info "👨‍⚕️ Doctors: http://$EXTERNAL_URL/api/doctors"
        
    else
        print_warning "API test failed, but database was initialized"
        print_info "Try testing manually: curl http://$EXTERNAL_URL/api/doctors"
    fi
else
    print_warning "External URL not ready yet"
    print_info "Check load balancer status: kubectl get services -n healthcare"
fi

echo ""
print_status "Database initialization script completed successfully!"
