#!/usr/bin/env node

/**
 * Test Configuration Validation Script
 * Healthcare Management System - Stage 2
 * Validates all test configurations and dependencies
 */

const fs = require('fs');
const path = require('path');

console.log('🧪 Validating Stage 2 test configurations...\n');

const errors = [];
const warnings = [];

/**
 * Check if Node.js modules are available
 */
function checkNodeModule(moduleName, location = '.') {
  try {
    require.resolve(moduleName, { paths: [path.resolve(location)] });
    return true;
  } catch (error) {
    return false;
  }
}

/**
 * Validate package.json dependencies
 */
function validateDependencies(packagePath, requiredDeps) {
  try {
    const content = fs.readFileSync(path.resolve(packagePath), 'utf8');
    const pkg = JSON.parse(content);
    
    const allDeps = {
      ...pkg.dependencies,
      ...pkg.devDependencies
    };
    
    const missing = requiredDeps.filter(dep => !allDeps[dep]);
    
    if (missing.length > 0) {
      warnings.push(`⚠️  Missing dependencies in ${packagePath}: ${missing.join(', ')}`);
    }
    
    console.log(`✅ Dependencies validated: ${packagePath}`);
    return missing.length === 0;
  } catch (error) {
    errors.push(`❌ Error reading ${packagePath}: ${error.message}`);
    return false;
  }
}

// Validate Jest configuration
console.log('📋 Validating Jest configuration...\n');

const jestFiles = [
  'tests/jest-config/jest.config.js',
  'tests/jest-config/setup.js',
  'tests/jest-config/coverage.config.js'
];

jestFiles.forEach(file => {
  if (fs.existsSync(path.resolve(file))) {
    console.log(`✅ ${file}`);
  } else {
    errors.push(`❌ Jest config file missing: ${file}`);
  }
});

// Validate Selenium configuration
console.log('\n📋 Validating Selenium configuration...\n');

const seleniumFiles = [
  'tests/selenium-config/webdriver.config.js',
  'tests/selenium-config/chrome.config.js',
  'tests/selenium-config/firefox.config.js'
];

seleniumFiles.forEach(file => {
  if (fs.existsSync(path.resolve(file))) {
    console.log(`✅ ${file}`);
  } else {
    errors.push(`❌ Selenium config file missing: ${file}`);
  }
});

// Validate source code test configurations
console.log('\n📋 Validating source code test configurations...\n');

// Frontend test configuration
const frontendTestFiles = [
  '../../src-code/frontend/vitest.config.ts',
  '../../src-code/frontend/src/test/setup.ts'
];

frontendTestFiles.forEach(file => {
  if (fs.existsSync(path.resolve(file))) {
    console.log(`✅ ${file}`);
  } else {
    errors.push(`❌ Frontend test config missing: ${file}`);
  }
});

// Backend test configuration
const backendTestFiles = [
  '../../src-code/backend/jest.config.js',
  '../../src-code/backend/tests/setup.ts',
  '../../src-code/backend/tests/globalSetup.ts',
  '../../src-code/backend/tests/globalTeardown.ts'
];

backendTestFiles.forEach(file => {
  if (fs.existsSync(path.resolve(file))) {
    console.log(`✅ ${file}`);
  } else {
    errors.push(`❌ Backend test config missing: ${file}`);
  }
});

// Validate dependencies
console.log('\n📦 Validating test dependencies...\n');

// Stage 2 pipeline dependencies
const stage2Deps = ['selenium-webdriver'];
if (fs.existsSync(path.resolve('package.json'))) {
  validateDependencies('package.json', stage2Deps);
}

// Frontend test dependencies
const frontendTestDeps = ['vitest', '@testing-library/react', '@testing-library/jest-dom'];
if (fs.existsSync(path.resolve('../../src-code/frontend/package.json'))) {
  validateDependencies('../../src-code/frontend/package.json', frontendTestDeps);
}

// Backend test dependencies
const backendTestDeps = ['jest', '@types/jest', 'supertest', 'ts-jest'];
if (fs.existsSync(path.resolve('../../src-code/backend/package.json'))) {
  validateDependencies('../../src-code/backend/package.json', backendTestDeps);
}

// Check for test scripts
console.log('\n📋 Validating test scripts...\n');

const testScripts = [
  {
    file: '../../src-code/package.json',
    scripts: ['test', 'test:unit', 'test:e2e', 'test:coverage']
  },
  {
    file: '../../src-code/frontend/package.json',
    scripts: ['test', 'test:coverage']
  },
  {
    file: '../../src-code/backend/package.json',
    scripts: ['test', 'test:coverage', 'test:integration']
  }
];

testScripts.forEach(({ file, scripts }) => {
  if (fs.existsSync(path.resolve(file))) {
    try {
      const content = fs.readFileSync(path.resolve(file), 'utf8');
      const pkg = JSON.parse(content);
      
      const missingScripts = scripts.filter(script => !pkg.scripts || !pkg.scripts[script]);
      
      if (missingScripts.length === 0) {
        console.log(`✅ Test scripts validated: ${file}`);
      } else {
        warnings.push(`⚠️  Missing test scripts in ${file}: ${missingScripts.join(', ')}`);
      }
    } catch (error) {
      errors.push(`❌ Error validating test scripts in ${file}: ${error.message}`);
    }
  }
});

// Check environment setup
console.log('\n🌍 Checking test environment...\n');

// Check Node.js version
const nodeVersion = process.version;
const majorVersion = parseInt(nodeVersion.slice(1).split('.')[0]);

if (majorVersion >= 18) {
  console.log(`✅ Node.js version: ${nodeVersion}`);
} else {
  warnings.push(`⚠️  Node.js version ${nodeVersion} may not be compatible. Recommended: >=18.0.0`);
}

// Check npm version
try {
  const { execSync } = require('child_process');
  const npmVersion = execSync('npm --version', { encoding: 'utf8' }).trim();
  console.log(`✅ npm version: ${npmVersion}`);
} catch (error) {
  warnings.push('⚠️  Could not determine npm version');
}

// Summary
console.log('\n' + '='.repeat(50));
console.log('📊 TEST VALIDATION SUMMARY');
console.log('='.repeat(50));

if (errors.length === 0 && warnings.length === 0) {
  console.log('🎉 All test configurations are valid!');
  console.log('✅ Testing pipeline is ready for use.');
} else {
  if (errors.length > 0) {
    console.log(`\n❌ ERRORS (${errors.length}):`);
    errors.forEach(error => console.log(`   ${error}`));
  }
  
  if (warnings.length > 0) {
    console.log(`\n⚠️  WARNINGS (${warnings.length}):`);
    warnings.forEach(warning => console.log(`   ${warning}`));
  }
  
  if (errors.length > 0) {
    console.log('\n❌ Test validation failed. Please fix the errors above.');
    process.exit(1);
  } else {
    console.log('\n⚠️  Test validation completed with warnings.');
    console.log('✅ Testing should work but consider addressing warnings.');
  }
}

console.log('\n🧪 Test validation complete.\n');
