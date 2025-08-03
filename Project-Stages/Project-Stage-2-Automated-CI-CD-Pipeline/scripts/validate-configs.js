#!/usr/bin/env node

/**
 * Configuration Validation Script
 * Healthcare Management System - Stage 2
 * Validates all pipeline configurations
 */

const fs = require('fs');
const path = require('path');

console.log('🔍 Validating Stage 2 pipeline configurations...\n');

const errors = [];
const warnings = [];

// Configuration files to validate
const configFiles = [
  // GitHub Actions
  {
    path: '.github/workflows/stage2-ci-cd.yml',
    required: true,
    type: 'yaml'
  },
  
  // Jest configurations
  {
    path: 'tests/jest-config/jest.config.js',
    required: true,
    type: 'javascript'
  },
  {
    path: 'tests/jest-config/setup.js',
    required: true,
    type: 'javascript'
  },
  {
    path: 'tests/jest-config/coverage.config.js',
    required: true,
    type: 'javascript'
  },
  
  // Selenium configurations
  {
    path: 'tests/selenium-config/webdriver.config.js',
    required: true,
    type: 'javascript'
  },
  {
    path: 'tests/selenium-config/chrome.config.js',
    required: true,
    type: 'javascript'
  },
  {
    path: 'tests/selenium-config/firefox.config.js',
    required: true,
    type: 'javascript'
  },
  
  // SonarQube configurations
  {
    path: 'configs/quality-gates/sonar-project.properties',
    required: true,
    type: 'properties'
  },
  {
    path: 'configs/quality-gates/quality-gates.json',
    required: true,
    type: 'json'
  },
  
  // Trivy configurations
  {
    path: 'configs/security/trivy-config.yaml',
    required: true,
    type: 'yaml'
  },
  {
    path: 'configs/security/security-policies.yaml',
    required: true,
    type: 'yaml'
  }
];

// Source code configurations
const sourceCodeFiles = [
  {
    path: '../../src-code/package.json',
    required: true,
    type: 'json'
  },
  {
    path: '../../src-code/frontend/package.json',
    required: true,
    type: 'json'
  },
  {
    path: '../../src-code/backend/package.json',
    required: true,
    type: 'json'
  }
];

/**
 * Check if file exists and is readable
 */
function validateFileExists(filePath, required = true) {
  const fullPath = path.resolve(filePath);
  
  if (!fs.existsSync(fullPath)) {
    if (required) {
      errors.push(`❌ Required file missing: ${filePath}`);
    } else {
      warnings.push(`⚠️  Optional file missing: ${filePath}`);
    }
    return false;
  }
  
  try {
    fs.accessSync(fullPath, fs.constants.R_OK);
    console.log(`✅ ${filePath}`);
    return true;
  } catch (error) {
    errors.push(`❌ File not readable: ${filePath} - ${error.message}`);
    return false;
  }
}

/**
 * Validate JSON file syntax
 */
function validateJsonFile(filePath) {
  try {
    const content = fs.readFileSync(path.resolve(filePath), 'utf8');
    JSON.parse(content);
    return true;
  } catch (error) {
    errors.push(`❌ Invalid JSON in ${filePath}: ${error.message}`);
    return false;
  }
}

/**
 * Validate package.json scripts
 */
function validatePackageJsonScripts(filePath) {
  try {
    const content = fs.readFileSync(path.resolve(filePath), 'utf8');
    const pkg = JSON.parse(content);
    
    const requiredScripts = ['test', 'build', 'lint'];
    const missingScripts = requiredScripts.filter(script => !pkg.scripts || !pkg.scripts[script]);
    
    if (missingScripts.length > 0) {
      warnings.push(`⚠️  Missing scripts in ${filePath}: ${missingScripts.join(', ')}`);
    }
    
    return true;
  } catch (error) {
    errors.push(`❌ Error validating scripts in ${filePath}: ${error.message}`);
    return false;
  }
}

// Main validation
console.log('📋 Checking pipeline configuration files...\n');

// Validate pipeline configurations
configFiles.forEach(config => {
  if (validateFileExists(config.path, config.required)) {
    if (config.type === 'json') {
      validateJsonFile(config.path);
    }
  }
});

console.log('\n📋 Checking source code configurations...\n');

// Validate source code configurations
sourceCodeFiles.forEach(config => {
  if (validateFileExists(config.path, config.required)) {
    if (config.type === 'json') {
      validateJsonFile(config.path);
      validatePackageJsonScripts(config.path);
    }
  }
});

// Check for required directories
console.log('\n📁 Checking directory structure...\n');

const requiredDirs = [
  'tests',
  'tests/jest-config',
  'tests/selenium-config',
  'configs',
  'configs/quality-gates',
  'configs/security',
  'docs',
  '.github',
  '.github/workflows'
];

requiredDirs.forEach(dir => {
  if (fs.existsSync(path.resolve(dir))) {
    console.log(`✅ ${dir}/`);
  } else {
    errors.push(`❌ Required directory missing: ${dir}/`);
  }
});

// Summary
console.log('\n' + '='.repeat(50));
console.log('📊 VALIDATION SUMMARY');
console.log('='.repeat(50));

if (errors.length === 0 && warnings.length === 0) {
  console.log('🎉 All configurations are valid!');
  console.log('✅ Stage 2 pipeline is ready for use.');
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
    console.log('\n❌ Configuration validation failed. Please fix the errors above.');
    process.exit(1);
  } else {
    console.log('\n⚠️  Configuration validation completed with warnings.');
    console.log('✅ Pipeline should work but consider addressing warnings.');
  }
}

console.log('\n🔍 Validation complete.\n');
