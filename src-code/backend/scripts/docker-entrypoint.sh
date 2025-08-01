#!/bin/bash

# Healthcare Backend Docker Entrypoint
# Ensures database is ready and seeded before starting the application

set -e

echo "🏥 Healthcare Backend Starting..."
echo "================================="

# Function to check database connection
check_database() {
    npx prisma db push --accept-data-loss 2>/dev/null
}

# Function to seed database
seed_database() {
    echo "🌱 Seeding database with sample data..."
    
    node -e "
    (async () => {
      const { PrismaClient } = require('@prisma/client');
      const prisma = new PrismaClient();
      
      try {
        console.log('🏢 Creating departments...');
        
        const cardiology = await prisma.department.upsert({
          where: { code: 'CARD' },
          update: {},
          create: { 
            name: 'Cardiology', 
            code: 'CARD', 
            description: 'Heart and cardiovascular system' 
          }
        });
        
        const pulmonology = await prisma.department.upsert({
          where: { code: 'PULM' },
          update: {},
          create: { 
            name: 'Pulmonology', 
            code: 'PULM', 
            description: 'Lungs and respiratory system' 
          }
        });
        
        const neurology = await prisma.department.upsert({
          where: { code: 'NEUR' },
          update: {},
          create: { 
            name: 'Neurology', 
            code: 'NEUR', 
            description: 'Brain and nervous system' 
          }
        });
        
        const orthopedics = await prisma.department.upsert({
          where: { code: 'ORTH' },
          update: {},
          create: { 
            name: 'Orthopedics', 
            code: 'ORTH', 
            description: 'Bones, joints, and muscles' 
          }
        });
        
        console.log('👨‍⚕️ Creating doctors...');
        
        await prisma.doctor.upsert({
          where: { email: 'john.smith@hospital.com' },
          update: {},
          create: {
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
        
        await prisma.doctor.upsert({
          where: { email: 'sarah.johnson@hospital.com' },
          update: {},
          create: {
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
        
        await prisma.doctor.upsert({
          where: { email: 'michael.brown@hospital.com' },
          update: {},
          create: {
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
        
        await prisma.doctor.upsert({
          where: { email: 'emily.davis@hospital.com' },
          update: {},
          create: {
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
        
        await prisma.doctor.upsert({
          where: { email: 'david.wilson@hospital.com' },
          update: {},
          create: {
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
        
        const doctorCount = await prisma.doctor.count();
        const deptCount = await prisma.department.count();
        
        console.log(\`✅ Database seeded successfully!\`);
        console.log(\`📊 Total: \${deptCount} departments, \${doctorCount} doctors\`);
        
      } catch (error) {
        console.error('❌ Seeding error:', error.message);
        // Don't exit - let the app start anyway
      } finally {
        await prisma.\$disconnect();
      }
    })();
    " || echo "⚠️ Seeding completed with warnings"
}

# Wait for database to be ready
echo "⏳ Waiting for database connection..."
RETRY_COUNT=0
MAX_RETRIES=30

until check_database; do
    RETRY_COUNT=$((RETRY_COUNT + 1))
    if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
        echo "❌ Database connection failed after $MAX_RETRIES attempts"
        exit 1
    fi
    echo "Database not ready, retrying in 3 seconds... (attempt $RETRY_COUNT/$MAX_RETRIES)"
    sleep 3
done

echo "✅ Database schema ready"

# Check if we need to seed the database
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
" 2>/dev/null || echo "0")

if [ "$DOCTOR_COUNT" -eq 0 ]; then
    echo "📊 No doctors found, seeding database..."
    seed_database
else
    echo "✅ Database already has $DOCTOR_COUNT doctors"
fi

echo "🚀 Starting Healthcare Management System API..."
echo "🌐 Server will be available on port 3002"
echo "📋 Health check: http://localhost:3002/health"
echo "🔗 API documentation: http://localhost:3002/api"
echo ""

# Start the application
exec npm start
