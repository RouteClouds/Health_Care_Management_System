/**
 * Jest Configuration for Healthcare Management System
 * Stage 2: Automated CI/CD Pipeline
 * Unit Testing with Coverage Requirements
 */

module.exports = {
  // Test environment
  testEnvironment: 'node',
  
  // Root directory for tests (relative to Stage-2 root)
  rootDir: '../../src-code',
  
  // Test file patterns
  testMatch: [
    '<rootDir>/backend/src/**/__tests__/**/*.{js,ts}',
    '<rootDir>/backend/src/**/*.{test,spec}.{js,ts}',
    '<rootDir>/frontend/src/**/__tests__/**/*.{js,ts,jsx,tsx}',
    '<rootDir>/frontend/src/**/*.{test,spec}.{js,ts,jsx,tsx}'
  ],
  
  // Files to ignore
  testPathIgnorePatterns: [
    '<rootDir>/node_modules/',
    '<rootDir>/dist/',
    '<rootDir>/build/',
    '<rootDir>/coverage/',
    '<rootDir>/frontend/dist/',
    '<rootDir>/backend/dist/'
  ],
  
  // Module file extensions
  moduleFileExtensions: [
    'js',
    'jsx',
    'ts',
    'tsx',
    'json'
  ],
  
  // Transform files
  transform: {
    '^.+\\.(ts|tsx)$': 'ts-jest',
    '^.+\\.(js|jsx)$': 'babel-jest'
  },
  
  // Module name mapping for aliases
  moduleNameMapping: {
    '^@/(.*)$': '<rootDir>/src/$1',
    '^@frontend/(.*)$': '<rootDir>/frontend/src/$1',
    '^@backend/(.*)$': '<rootDir>/backend/src/$1',
    '^@shared/(.*)$': '<rootDir>/shared/$1'
  },
  
  // Setup files
  setupFilesAfterEnv: [
    '<rootDir>/../Project-Stages/Project-Stage-2-Automated-CI-CD-Pipeline/tests/jest-config/setup.js'
  ],
  
  // Coverage configuration
  collectCoverage: true,
  coverageDirectory: '<rootDir>/coverage',
  coverageReporters: [
    'text',
    'text-summary',
    'lcov',
    'html',
    'json',
    'clover'
  ],
  
  // Coverage collection patterns
  collectCoverageFrom: [
    'frontend/src/**/*.{js,jsx,ts,tsx}',
    'backend/src/**/*.{js,ts}',
    '!**/*.d.ts',
    '!**/node_modules/**',
    '!**/dist/**',
    '!**/build/**',
    '!**/coverage/**',
    '!**/*.config.{js,ts}',
    '!**/*.stories.{js,jsx,ts,tsx}',
    '!**/index.{js,ts}',
    '!**/main.{js,ts}',
    '!**/vite-env.d.ts'
  ],
  
  // Coverage thresholds (Stage 2 requirement: >80%)
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80
    },
    // Specific thresholds for critical modules
    './backend/src/controllers/': {
      branches: 85,
      functions: 85,
      lines: 85,
      statements: 85
    },
    './backend/src/services/': {
      branches: 85,
      functions: 85,
      lines: 85,
      statements: 85
    },
    './frontend/src/components/': {
      branches: 75,
      functions: 75,
      lines: 75,
      statements: 75
    }
  },
  
  // Test timeout
  testTimeout: 10000,
  
  // Verbose output
  verbose: true,
  
  // Clear mocks between tests
  clearMocks: true,
  
  // Restore mocks after each test
  restoreMocks: true,
  
  // Error on deprecated features
  errorOnDeprecated: true,
  
  // Globals
  globals: {
    'ts-jest': {
      useESM: true,
      tsconfig: {
        compilerOptions: {
          module: 'esnext',
          target: 'es2020',
          jsx: 'react-jsx'
        }
      }
    }
  },
  
  // Module directories
  moduleDirectories: [
    'node_modules',
    '<rootDir>/frontend/node_modules',
    '<rootDir>/backend/node_modules'
  ],
  
  // Preset for different environments
  projects: [
    {
      displayName: 'Backend Tests',
      testMatch: ['<rootDir>/backend/src/**/*.{test,spec}.{js,ts}'],
      testEnvironment: 'node',
      transform: {
        '^.+\\.ts$': 'ts-jest'
      }
    },
    {
      displayName: 'Frontend Tests',
      testMatch: ['<rootDir>/frontend/src/**/*.{test,spec}.{js,jsx,ts,tsx}'],
      testEnvironment: 'jsdom',
      transform: {
        '^.+\\.(ts|tsx)$': 'ts-jest',
        '^.+\\.(js|jsx)$': 'babel-jest'
      },
      moduleNameMapping: {
        '\\.(css|less|scss|sass)$': 'identity-obj-proxy',
        '\\.(jpg|jpeg|png|gif|eot|otf|webp|svg|ttf|woff|woff2|mp4|webm|wav|mp3|m4a|aac|oga)$': 'jest-transform-stub'
      }
    }
  ],
  
  // Watch plugins for development
  watchPlugins: [
    'jest-watch-typeahead/filename',
    'jest-watch-typeahead/testname'
  ],
  
  // Notification settings
  notify: false,
  notifyMode: 'failure-change',
  
  // Bail on first test failure in CI
  bail: process.env.CI ? 1 : 0,
  
  // Cache directory
  cacheDirectory: '<rootDir>/node_modules/.cache/jest',
  
  // Max workers for parallel execution
  maxWorkers: process.env.CI ? 2 : '50%',
  
  // Reporter configuration
  reporters: [
    'default',
    [
      'jest-junit',
      {
        outputDirectory: '<rootDir>/coverage',
        outputName: 'junit.xml',
        classNameTemplate: '{classname}',
        titleTemplate: '{title}',
        ancestorSeparator: ' › ',
        usePathForSuiteName: true
      }
    ]
  ]
};
