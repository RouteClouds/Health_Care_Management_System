/**
 * Jest Test Setup for Backend
 * Healthcare Management System - Stage 2
 */

import { PrismaClient } from '@prisma/client';

// Global test configuration
declare global {
  var __PRISMA__: PrismaClient;
}

// Test database setup
beforeAll(async () => {
  // Initialize test database connection
  global.__PRISMA__ = new PrismaClient({
    datasources: {
      db: {
        url: process.env.TEST_DATABASE_URL || process.env.DATABASE_URL
      }
    }
  });
  
  // Connect to database
  await global.__PRISMA__.$connect();
  
  console.log('🔧 Test database connected');
});

// Cleanup after each test
afterEach(async () => {
  // Clean up test data
  if (global.__PRISMA__) {
    // Delete test data in reverse order of dependencies
    await global.__PRISMA__.appointment.deleteMany();
    await global.__PRISMA__.patient.deleteMany();
    await global.__PRISMA__.user.deleteMany();
  }
});

// Global cleanup
afterAll(async () => {
  // Disconnect from database
  if (global.__PRISMA__) {
    await global.__PRISMA__.$disconnect();
    console.log('🔧 Test database disconnected');
  }
});

// Mock environment variables for testing
process.env.NODE_ENV = 'test';
process.env.JWT_SECRET = 'test-jwt-secret-key-for-healthcare-system';
process.env.PORT = '3001';

// Increase timeout for healthcare system tests
jest.setTimeout(30000);

// Mock console methods in test environment
if (process.env.NODE_ENV === 'test') {
  global.console = {
    ...console,
    log: jest.fn(),
    debug: jest.fn(),
    info: jest.fn(),
    warn: jest.fn(),
    error: jest.fn()
  };
}
