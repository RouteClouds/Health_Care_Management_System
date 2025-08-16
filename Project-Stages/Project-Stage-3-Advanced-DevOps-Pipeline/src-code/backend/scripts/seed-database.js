#!/usr/bin/env node

/**
 * Database Seeding Script for Healthcare Management System Stage-3
 * 
 * This script automatically seeds the database with sample data including:
 * - Departments (Cardiology, Pediatrics, Orthopedics)
 * - Doctors with proper relationships to departments
 * - Sample users for testing
 * 
 * Usage:
 *   node scripts/seed-database.js
 *   npm run db:seed
 *   npx prisma db seed
 */

const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

// Sample data
const DEPARTMENTS = [
  {
    name: 'Cardiology',
    code: 'CARD',
    description: 'Heart and cardiovascular system'
  },
  {
    name: 'Pediatrics',
    code: 'PEDI',
    description: 'Medical care for infants, children, and adolescents'
  },
  {
    name: 'Orthopedics',
    code: 'ORTH',
    description: 'Musculoskeletal system disorders'
  },
  {
    name: 'Emergency Medicine',
    code: 'EMER',
    description: 'Emergency and urgent care'
  },
  {
    name: 'Internal Medicine',
    code: 'INTE',
    description: 'General internal medicine and primary care'
  }
];

const SAMPLE_USERS = [
  {
    username: 'john.patient',
    email: 'john.patient@example.com',
    password: '$2b$10$rOzJqQqQqQqQqQqQqQqQqOzJqQqQqQqQqQqQqQqQqOzJqQqQqQqQqQ', // 'password123'
    firstName: 'John',
    lastName: 'Patient',
    role: 'PATIENT'
  },
  {
    username: 'admin.user',
    email: 'admin@healthcare.com',
    password: '$2b$10$rOzJqQqQqQqQqQqQqQqQqOzJqQqQqQqQqQqQqQqQqOzJqQqQqQqQqQ', // 'admin123'
    firstName: 'Admin',
    lastName: 'User',
    role: 'ADMIN'
  }
];

async function seedDepartments() {
  console.log('🏥 Seeding departments...');
  
  const departments = await prisma.department.createMany({
    data: DEPARTMENTS,
    skipDuplicates: true
  });
  
  console.log(`✅ Created ${departments.count} departments`);
  return departments;
}

async function seedUsers() {
  console.log('👥 Seeding users...');
  
  const users = await prisma.user.createMany({
    data: SAMPLE_USERS,
    skipDuplicates: true
  });
  
  console.log(`✅ Created ${users.count} users`);
  return users;
}

async function seedDoctors() {
  console.log('👨‍⚕️ Seeding doctors...');
  
  // Get department IDs
  const cardiology = await prisma.department.findUnique({ where: { code: 'CARD' } });
  const pediatrics = await prisma.department.findUnique({ where: { code: 'PEDI' } });
  const orthopedics = await prisma.department.findUnique({ where: { code: 'ORTH' } });
  const emergency = await prisma.department.findUnique({ where: { code: 'EMER' } });
  const internal = await prisma.department.findUnique({ where: { code: 'INTE' } });
  
  if (!cardiology || !pediatrics || !orthopedics || !emergency || !internal) {
    throw new Error('Departments not found. Please run department seeding first.');
  }
  
  const doctorsData = [
    {
      firstName: 'John',
      lastName: 'Smith',
      email: 'john.smith@healthcare.com',
      specialization: 'Interventional Cardiology',
      departmentId: cardiology.id,
      qualifications: ['MD', 'FACC'],
      experienceYears: 15,
      consultationFee: 200.00
    },
    {
      firstName: 'Sarah',
      lastName: 'Johnson',
      email: 'sarah.johnson@healthcare.com',
      specialization: 'Pediatric Emergency Medicine',
      departmentId: pediatrics.id,
      qualifications: ['MD', 'FAAP'],
      experienceYears: 12,
      consultationFee: 180.00
    },
    {
      firstName: 'Michael',
      lastName: 'Brown',
      email: 'michael.brown@healthcare.com',
      specialization: 'Orthopedic Surgery',
      departmentId: orthopedics.id,
      qualifications: ['MD', 'FAAOS'],
      experienceYears: 18,
      consultationFee: 250.00
    },
    {
      firstName: 'Emily',
      lastName: 'Davis',
      email: 'emily.davis@healthcare.com',
      specialization: 'Emergency Medicine',
      departmentId: emergency.id,
      qualifications: ['MD', 'FACEP'],
      experienceYears: 10,
      consultationFee: 220.00
    },
    {
      firstName: 'Robert',
      lastName: 'Wilson',
      email: 'robert.wilson@healthcare.com',
      specialization: 'Internal Medicine',
      departmentId: internal.id,
      qualifications: ['MD', 'FACP'],
      experienceYears: 20,
      consultationFee: 150.00
    }
  ];
  
  const doctors = await prisma.doctor.createMany({
    data: doctorsData,
    skipDuplicates: true
  });
  
  console.log(`✅ Created ${doctors.count} doctors`);
  return doctors;
}

async function main() {
  console.log('🌱 Starting database seeding for Healthcare Management System Stage-3...');
  console.log('================================================================================');
  
  try {
    // Test database connection
    await prisma.$connect();
    console.log('✅ Database connection successful');
    
    // Seed in order (departments first, then users, then doctors)
    await seedDepartments();
    await seedUsers();
    await seedDoctors();
    
    console.log('');
    console.log('🎉 Database seeding completed successfully!');
    console.log('================================================================================');
    console.log('📊 Summary:');
    
    // Get final counts
    const departmentCount = await prisma.department.count();
    const userCount = await prisma.user.count();
    const doctorCount = await prisma.doctor.count();
    
    console.log(`   - Departments: ${departmentCount}`);
    console.log(`   - Users: ${userCount}`);
    console.log(`   - Doctors: ${doctorCount}`);
    console.log('');
    console.log('🔗 You can now test the API endpoints:');
    console.log('   - GET /api/health (health check)');
    console.log('   - GET /api/doctors (list doctors)');
    console.log('   - GET /api/departments (list departments)');
    console.log('');
    
  } catch (error) {
    console.error('❌ Database seeding failed:', error);
    process.exit(1);
  } finally {
    await prisma.$disconnect();
  }
}

// Run the seeding
if (require.main === module) {
  main();
}

module.exports = { main, seedDepartments, seedUsers, seedDoctors };
