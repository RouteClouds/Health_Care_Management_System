/**
 * Jest Global Teardown for Backend
 * Healthcare Management System - Stage 2
 */

import { PrismaClient } from '@prisma/client';

export default async (): Promise<void> => {
  console.log('🧹 Cleaning up test environment...');
  
  // Initialize test database connection
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
    
    // Clean up all test data
    console.log('🔧 Cleaning up test data...');
    
    await prisma.appointment.deleteMany();
    await prisma.patient.deleteMany();
    await prisma.user.deleteMany();
    
    console.log('✅ Test environment cleanup complete');
    
  } catch (error) {
    console.error('❌ Test environment cleanup failed:', error);
    // Don't throw error in teardown to avoid masking test failures
  } finally {
    await prisma.$disconnect();
  }
};
