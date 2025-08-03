/**
 * Jest Coverage Configuration
 * Healthcare Management System - Stage 2
 * Coverage requirements and reporting configuration
 */

module.exports = {
  // Coverage collection configuration
  collectCoverage: true,
  
  // Coverage directory
  coverageDirectory: '../../src-code/coverage',
  
  // Coverage reporters
  coverageReporters: [
    'text',           // Console output
    'text-summary',   // Summary in console
    'lcov',          // For SonarQube integration
    'html',          // HTML report for local viewing
    'json',          // JSON format for CI/CD
    'clover',        // XML format for CI/CD
    'cobertura'      // XML format for Azure DevOps/Jenkins
  ],
  
  // Files to collect coverage from
  collectCoverageFrom: [
    // Frontend coverage
    'frontend/src/**/*.{js,jsx,ts,tsx}',
    '!frontend/src/**/*.d.ts',
    '!frontend/src/**/*.stories.{js,jsx,ts,tsx}',
    '!frontend/src/**/*.test.{js,jsx,ts,tsx}',
    '!frontend/src/**/*.spec.{js,jsx,ts,tsx}',
    '!frontend/src/index.tsx',
    '!frontend/src/main.tsx',
    '!frontend/src/vite-env.d.ts',
    '!frontend/src/setupTests.ts',
    
    // Backend coverage
    'backend/src/**/*.{js,ts}',
    '!backend/src/**/*.d.ts',
    '!backend/src/**/*.test.{js,ts}',
    '!backend/src/**/*.spec.{js,ts}',
    '!backend/src/index.ts',
    '!backend/src/server.ts',
    '!backend/src/app.ts',
    
    // Exclude common patterns
    '!**/node_modules/**',
    '!**/dist/**',
    '!**/build/**',
    '!**/coverage/**',
    '!**/*.config.{js,ts}',
    '!**/*.setup.{js,ts}',
    '!**/migrations/**',
    '!**/seeds/**'
  ],
  
  // Coverage thresholds - Stage 2 requirement: >80%
  coverageThreshold: {
    // Global thresholds
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80
    },
    
    // Backend-specific thresholds (higher for critical components)
    './backend/src/controllers/': {
      branches: 85,
      functions: 90,
      lines: 85,
      statements: 85
    },
    
    './backend/src/services/': {
      branches: 85,
      functions: 90,
      lines: 85,
      statements: 85
    },
    
    './backend/src/models/': {
      branches: 80,
      functions: 85,
      lines: 80,
      statements: 80
    },
    
    './backend/src/middleware/': {
      branches: 85,
      functions: 85,
      lines: 85,
      statements: 85
    },
    
    './backend/src/utils/': {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80
    },
    
    // Frontend-specific thresholds
    './frontend/src/components/': {
      branches: 75,
      functions: 80,
      lines: 75,
      statements: 75
    },
    
    './frontend/src/pages/': {
      branches: 70,
      functions: 75,
      lines: 70,
      statements: 70
    },
    
    './frontend/src/hooks/': {
      branches: 80,
      functions: 85,
      lines: 80,
      statements: 80
    },
    
    './frontend/src/services/': {
      branches: 80,
      functions: 85,
      lines: 80,
      statements: 80
    },
    
    './frontend/src/utils/': {
      branches: 75,
      functions: 80,
      lines: 75,
      statements: 75
    }
  },
  
  // Coverage path ignore patterns
  coveragePathIgnorePatterns: [
    '/node_modules/',
    '/dist/',
    '/build/',
    '/coverage/',
    '\\.d\\.ts$',
    '\\.config\\.(js|ts)$',
    '\\.setup\\.(js|ts)$',
    '/migrations/',
    '/seeds/',
    '/fixtures/',
    '/mocks/',
    '__tests__/',
    '__mocks__/',
    '.stories.',
    '.story.'
  ],
  
  // Coverage provider
  coverageProvider: 'v8',
  
  // Transform ignore patterns for coverage
  transformIgnorePatterns: [
    'node_modules/(?!(.*\\.mjs$|@testing-library|@babel))'
  ]
};

// Export coverage validation function
const validateCoverage = (coverageResults) => {
  const { global } = coverageResults;
  const thresholds = module.exports.coverageThreshold.global;
  
  const failures = [];
  
  Object.keys(thresholds).forEach(metric => {
    const actual = global[metric].pct;
    const required = thresholds[metric];
    
    if (actual < required) {
      failures.push({
        metric,
        actual,
        required,
        message: `${metric} coverage ${actual}% is below threshold ${required}%`
      });
    }
  });
  
  return {
    passed: failures.length === 0,
    failures,
    summary: {
      branches: global.branches.pct,
      functions: global.functions.pct,
      lines: global.lines.pct,
      statements: global.statements.pct
    }
  };
};

// Export coverage report generator
const generateCoverageReport = (coverageResults) => {
  const validation = validateCoverage(coverageResults);
  
  console.log('\n📊 Coverage Report Summary:');
  console.log('================================');
  console.log(`Branches:   ${validation.summary.branches}%`);
  console.log(`Functions:  ${validation.summary.functions}%`);
  console.log(`Lines:      ${validation.summary.lines}%`);
  console.log(`Statements: ${validation.summary.statements}%`);
  
  if (validation.passed) {
    console.log('\n✅ All coverage thresholds met!');
  } else {
    console.log('\n❌ Coverage thresholds not met:');
    validation.failures.forEach(failure => {
      console.log(`   ${failure.message}`);
    });
  }
  
  return validation;
};

module.exports.validateCoverage = validateCoverage;
module.exports.generateCoverageReport = generateCoverageReport;
