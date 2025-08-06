#!/bin/bash

# Database initialization script for backend container
# This script runs automatically when the backend container starts

set -e

echo "🗄️ Backend Database Initialization"
echo "=================================="

# Wait for database to be ready
echo "⏳ Waiting for database connection..."
for i in {1..30}; do
    if npx prisma db push --accept-data-loss > /dev/null 2>&1; then
        echo "✅ Database connection established"
        break
    else
        echo "⏳ Attempt $i/30: Waiting for database to be ready..."
        sleep 2
    fi
done

# Final attempt with error handling
if ! npx prisma db push --accept-data-loss; then
    echo "❌ Database initialization failed after 30 attempts"
    echo "💡 This might be due to:"
    echo "   - Database container not ready"
    echo "   - Network connectivity issues"
    echo "   - Database credentials mismatch"
    exit 1
fi

echo "✅ Database schema synchronized"

# Check if database has data
echo "🔍 Checking for existing data..."
DOCTOR_COUNT=$(node -e "
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
prisma.doctor.count().then(count => {
    console.log(count);
    prisma.\$disconnect();
}).catch(() => {
    console.log('0');
    prisma.\$disconnect();
});
")

if [ "$DOCTOR_COUNT" -eq 0 ]; then
    echo "🌱 No data found, seeding database..."
    
    node -e "
    (async () => {
      const { PrismaClient } = require('@prisma/client');
      const prisma = new PrismaClient();
      
      try {
        console.log('🏢 Creating departments...');
        
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
        
        console.log('✅ Database seeded with 4 departments and 5 doctors');
        
      } catch (error) {
        console.error('❌ Seeding error:', error.message);
        // Don't exit with error - let the app start anyway
      } finally {
        await prisma.\$disconnect();
      }
    })();
    "
    
    echo "✅ Database seeding completed"
else
    echo "✅ Database already has $DOCTOR_COUNT doctors, skipping seed"
fi

echo "🚀 Database initialization complete, starting application..."
