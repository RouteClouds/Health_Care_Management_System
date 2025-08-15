/**
 * Jest Global Setup for Backend
 * Healthcare Management System - Stage 2
 */

import { PrismaClient } from '@prisma/client';

export default async (): Promise<void> => {
  console.log('🚀 Setting up test environment...');
  
  // Set test environment variables
  process.env.NODE_ENV = 'test';
  process.env.JWT_SECRET = 'test-jwt-secret-key-for-healthcare-system';
  process.env.PORT = '3001';
  
  // Initialize test database
  const prisma = new PrismaClient({
    datasources: {
      db: {
        url: process.env.TEST_DATABASE_URL || process.env.DATABASE_URL
      }
    }
  });
  
  try {
    // Connect to database
    await prisma.$connect();
    
    // Run database migrations for test environment
    console.log('🔧 Running database migrations...');
    
    // Clean up any existing test data
    await prisma.appointment.deleteMany();
    await prisma.patient.deleteMany();
    await prisma.user.deleteMany();
    
    console.log('✅ Test environment setup complete');
    
  } catch (error) {
    console.error('❌ Test environment setup failed:', error);
    throw error;
  } finally {
    await prisma.$disconnect();
  }
};
