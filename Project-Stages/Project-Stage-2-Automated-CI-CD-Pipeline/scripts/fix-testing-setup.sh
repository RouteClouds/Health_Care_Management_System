#!/bin/bash
set -e

echo "🔧 Fixing Testing Setup for Stage-2"
echo "=================================="

# Get current directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SRC_CODE_DIR="$PROJECT_ROOT/src-code"

echo "📍 Project root: $PROJECT_ROOT"
echo "📍 Source code directory: $SRC_CODE_DIR"

# Check Node.js version
NODE_VERSION=$(node --version)
echo "📋 Current Node.js version: $NODE_VERSION"

# Extract major version number
NODE_MAJOR=$(echo $NODE_VERSION | cut -d'.' -f1 | sed 's/v//')

if [ "$NODE_MAJOR" -lt 20 ]; then
    echo "⚠️  Node.js version is $NODE_VERSION, but selenium-webdriver requires >= 20.0.0"
    echo "🔄 Upgrading to Node.js 20 LTS..."
    
    # Upgrade Node.js
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
    
    # Verify upgrade
    NEW_NODE_VERSION=$(node --version)
    echo "✅ Node.js upgraded to: $NEW_NODE_VERSION"
else
    echo "✅ Node.js version is compatible"
fi

# Clean up any incorrect installations
echo "🧹 Cleaning up incorrect installations..."
cd "$PROJECT_ROOT"
if [ -d "node_modules" ]; then
    echo "   Removing node_modules from project root..."
    rm -rf node_modules package-lock.json
fi

if [ -d "scripts/node_modules" ]; then
    echo "   Removing node_modules from scripts directory..."
    rm -rf scripts/node_modules scripts/package-lock.json
fi

# Navigate to src-code directory
echo "📂 Setting up testing in src-code directory..."
cd "$SRC_CODE_DIR"

# Create package.json if it doesn't exist
if [ ! -f package.json ]; then
    echo "📦 Creating package.json..."
    npm init -y
    
    # Update package.json with project details
    npm pkg set name="healthcare-management-system"
    npm pkg set version="1.0.0"
    npm pkg set description="Healthcare Management System - Stage 2 CI/CD"
    npm pkg set main="index.js"
    npm pkg set scripts.start="node index.js"
fi

# Install testing dependencies
echo "📦 Installing testing dependencies..."
echo "   Installing Jest and React Testing Library..."
npm install --save-dev jest @testing-library/react @testing-library/jest-dom @testing-library/user-event jest-environment-jsdom

echo "   Installing Selenium WebDriver..."
if [ "$NODE_MAJOR" -ge 20 ]; then
    npm install --save-dev selenium-webdriver chromedriver
else
    echo "   ⚠️  Installing with --force due to Node.js version..."
    npm install --save-dev selenium-webdriver chromedriver --force
fi

# Configure test scripts
echo "⚙️  Configuring test scripts..."
npm pkg set scripts.test="jest"
npm pkg set scripts.test:watch="jest --watch"
npm pkg set scripts.test:coverage="jest --coverage"
npm pkg set scripts.test:e2e="jest tests/e2e --testTimeout=30000"

# Create Jest configuration
echo "⚙️  Creating Jest configuration..."
cat > jest.config.js << 'EOF'
module.exports = {
  testEnvironment: 'jsdom',
  setupFilesAfterEnv: ['<rootDir>/src/test/setup.js'],
  moduleNameMapping: {
    '\\.(css|less|scss|sass)$': 'identity-obj-proxy',
  },
  collectCoverageFrom: [
    'src/**/*.{js,jsx,ts,tsx}',
    '!src/index.js',
    '!src/test/**',
  ],
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80,
    },
  },
};
EOF

# Create test setup directory and file
echo "📁 Creating test setup..."
mkdir -p src/test
cat > src/test/setup.js << 'EOF'
import '@testing-library/jest-dom';

// Mock environment variables
process.env.REACT_APP_API_URL = 'http://localhost:3002/api';
process.env.NODE_ENV = 'test';
EOF

# Create tests directory structure
echo "📁 Creating test directories..."
mkdir -p tests/e2e

# Create Selenium configuration
cat > tests/e2e/config.js << 'EOF'
const { Builder, By, until } = require('selenium-webdriver');
const chrome = require('selenium-webdriver/chrome');

const createDriver = () => {
  const options = new chrome.Options();
  options.addArguments('--headless');
  options.addArguments('--no-sandbox');
  options.addArguments('--disable-dev-shm-usage');
  
  return new Builder()
    .forBrowser('chrome')
    .setChromeOptions(options)
    .build();
};

module.exports = { createDriver, By, until };
EOF

# Create sample E2E test
cat > tests/e2e/healthcare.test.js << 'EOF'
const { createDriver, By, until } = require('./config');

describe('Healthcare Application E2E Tests', () => {
  let driver;
  
  beforeAll(async () => {
    driver = createDriver();
  });
  
  afterAll(async () => {
    if (driver) {
      await driver.quit();
    }
  });
  
  test('should load homepage', async () => {
    await driver.get('http://localhost:3000');
    const title = await driver.getTitle();
    expect(title).toContain('Healthcare');
  });
  
  test('should navigate to doctor search', async () => {
    await driver.get('http://localhost:3000');
    const searchButton = await driver.findElement(By.css('[data-testid="find-doctor"]'));
    await searchButton.click();
    
    await driver.wait(until.urlContains('/doctors'), 5000);
    const currentUrl = await driver.getCurrentUrl();
    expect(currentUrl).toContain('/doctors');
  });
});
EOF

# Verify installation
echo "✅ Verifying installation..."
echo "📋 Node.js version: $(node --version)"
echo "📋 NPM version: $(npm --version)"

if command -v npx >/dev/null 2>&1; then
    echo "📋 Jest version: $(npx jest --version)"
else
    echo "⚠️  npx not available, but Jest should be installed locally"
fi

# Test the setup
echo "🧪 Testing setup..."
npm test -- --passWithNoTests

echo ""
echo "✅ Testing setup completed successfully!"
echo ""
echo "📋 Next steps:"
echo "   1. Navigate to src-code directory: cd $SRC_CODE_DIR"
echo "   2. Run tests: npm test"
echo "   3. Run tests with coverage: npm run test:coverage"
echo "   4. Run E2E tests: npm run test:e2e"
echo ""
echo "📁 Files created:"
echo "   - jest.config.js"
echo "   - src/test/setup.js"
echo "   - tests/e2e/config.js"
echo "   - tests/e2e/healthcare.test.js"
echo ""
echo "🎉 Ready for Stage-2 CI/CD pipeline development!"
