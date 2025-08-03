/**
 * Jest Setup Configuration
 * Healthcare Management System - Stage 2
 * Global test environment setup and utilities
 */

// Import required testing utilities
import '@testing-library/jest-dom';

// Global test timeout
jest.setTimeout(10000);

// Mock console methods in test environment
const originalError = console.error;
const originalWarn = console.warn;

beforeAll(() => {
  // Suppress console.error and console.warn in tests unless explicitly needed
  console.error = (...args) => {
    if (
      typeof args[0] === 'string' &&
      args[0].includes('Warning: ReactDOM.render is deprecated')
    ) {
      return;
    }
    originalError.call(console, ...args);
  };

  console.warn = (...args) => {
    if (
      typeof args[0] === 'string' &&
      (args[0].includes('componentWillReceiveProps') ||
       args[0].includes('componentWillUpdate'))
    ) {
      return;
    }
    originalWarn.call(console, ...args);
  };
});

afterAll(() => {
  console.error = originalError;
  console.warn = originalWarn;
});

// Global test utilities
global.testUtils = {
  // Mock user data for testing
  mockUser: {
    id: 'test-user-123',
    email: 'test@healthcare.com',
    name: 'Test User',
    role: 'patient',
    createdAt: new Date('2025-01-01'),
    updatedAt: new Date('2025-01-01')
  },

  // Mock patient data
  mockPatient: {
    id: 'patient-123',
    firstName: 'John',
    lastName: 'Doe',
    email: 'john.doe@email.com',
    phone: '+1-555-0123',
    dateOfBirth: '1990-01-01',
    gender: 'male',
    address: {
      street: '123 Main St',
      city: 'Anytown',
      state: 'CA',
      zipCode: '12345',
      country: 'USA'
    },
    medicalHistory: [],
    appointments: []
  },

  // Mock appointment data
  mockAppointment: {
    id: 'appointment-123',
    patientId: 'patient-123',
    doctorId: 'doctor-123',
    date: '2025-08-15',
    time: '10:00',
    duration: 30,
    type: 'consultation',
    status: 'scheduled',
    notes: 'Regular checkup'
  },

  // Mock API responses
  mockApiResponse: {
    success: (data = {}) => ({
      success: true,
      data,
      message: 'Operation successful'
    }),
    error: (message = 'An error occurred', code = 500) => ({
      success: false,
      error: {
        message,
        code
      }
    })
  },

  // Test database utilities
  db: {
    // Mock database connection
    connect: jest.fn().mockResolvedValue(true),
    disconnect: jest.fn().mockResolvedValue(true),
    
    // Mock CRUD operations
    create: jest.fn(),
    findById: jest.fn(),
    findAll: jest.fn(),
    update: jest.fn(),
    delete: jest.fn(),
    
    // Mock transaction
    transaction: jest.fn((callback) => callback())
  },

  // HTTP request mocking utilities
  http: {
    // Mock successful responses
    mockSuccess: (data) => Promise.resolve({
      status: 200,
      data,
      headers: {}
    }),
    
    // Mock error responses
    mockError: (status = 500, message = 'Server Error') => Promise.reject({
      response: {
        status,
        data: { message }
      }
    }),
    
    // Mock network error
    mockNetworkError: () => Promise.reject(new Error('Network Error'))
  },

  // Authentication utilities
  auth: {
    // Mock JWT token
    mockToken: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ0ZXN0LXVzZXItMTIzIiwibmFtZSI6IlRlc3QgVXNlciIsImlhdCI6MTUxNjIzOTAyMn0.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c',
    
    // Mock authentication state
    mockAuthState: {
      isAuthenticated: true,
      user: global.testUtils.mockUser,
      token: 'mock-token'
    },
    
    // Mock login/logout functions
    mockLogin: jest.fn().mockResolvedValue(global.testUtils.mockUser),
    mockLogout: jest.fn().mockResolvedValue(true)
  },

  // Form validation utilities
  validation: {
    // Mock validation results
    mockValidationSuccess: () => ({
      isValid: true,
      errors: {}
    }),
    
    mockValidationError: (field, message) => ({
      isValid: false,
      errors: {
        [field]: message
      }
    })
  },

  // Date utilities for testing
  dates: {
    // Fixed date for consistent testing
    fixedDate: new Date('2025-08-02T12:00:00.000Z'),
    
    // Mock date functions
    mockNow: () => new Date('2025-08-02T12:00:00.000Z'),
    mockToday: () => '2025-08-02',
    mockTomorrow: () => '2025-08-03'
  }
};

// Mock environment variables for testing
process.env.NODE_ENV = 'test';
process.env.JWT_SECRET = 'test-jwt-secret';
process.env.DB_HOST = 'localhost';
process.env.DB_PORT = '5432';
process.env.DB_NAME = 'healthcare_test';
process.env.DB_USER = 'test_user';
process.env.DB_PASSWORD = 'test_password';

// Mock localStorage for browser environment tests
const localStorageMock = {
  getItem: jest.fn(),
  setItem: jest.fn(),
  removeItem: jest.fn(),
  clear: jest.fn(),
};
global.localStorage = localStorageMock;

// Mock sessionStorage
const sessionStorageMock = {
  getItem: jest.fn(),
  setItem: jest.fn(),
  removeItem: jest.fn(),
  clear: jest.fn(),
};
global.sessionStorage = sessionStorageMock;

// Mock window.location
delete window.location;
window.location = {
  href: 'http://localhost:3000',
  origin: 'http://localhost:3000',
  pathname: '/',
  search: '',
  hash: '',
  assign: jest.fn(),
  replace: jest.fn(),
  reload: jest.fn()
};

// Mock fetch API
global.fetch = jest.fn();

// Mock IntersectionObserver
global.IntersectionObserver = jest.fn().mockImplementation(() => ({
  observe: jest.fn(),
  unobserve: jest.fn(),
  disconnect: jest.fn(),
}));

// Mock ResizeObserver
global.ResizeObserver = jest.fn().mockImplementation(() => ({
  observe: jest.fn(),
  unobserve: jest.fn(),
  disconnect: jest.fn(),
}));

// Setup and teardown for each test
beforeEach(() => {
  // Clear all mocks before each test
  jest.clearAllMocks();
  
  // Reset localStorage and sessionStorage
  localStorageMock.getItem.mockClear();
  localStorageMock.setItem.mockClear();
  localStorageMock.removeItem.mockClear();
  localStorageMock.clear.mockClear();
  
  sessionStorageMock.getItem.mockClear();
  sessionStorageMock.setItem.mockClear();
  sessionStorageMock.removeItem.mockClear();
  sessionStorageMock.clear.mockClear();
  
  // Reset fetch mock
  fetch.mockClear();
});

afterEach(() => {
  // Clean up after each test
  jest.restoreAllMocks();
});

// Global error handler for unhandled promise rejections
process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason);
});

// Export test utilities for use in test files
export default global.testUtils;
