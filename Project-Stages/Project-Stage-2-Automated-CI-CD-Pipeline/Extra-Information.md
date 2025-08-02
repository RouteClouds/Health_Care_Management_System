# 📚 **Extra Information: Stage 2 Deep Dive**
## **Testing Tools, Alternatives & Advanced Configurations**

### **🎯 Purpose**
This document provides comprehensive analysis of testing tools, alternatives, and advanced configurations for Stage 2 automated CI/CD pipeline. Use this for tool selection, advanced setups, and understanding the complete ecosystem.

---

## **🔄 Stage 1 vs Stage 2 Transformation Analysis**

### **📊 Manual vs Automated Workflow Comparison**

#### **Stage 1 (Manual Process) - 15 Steps**
```bash
# Developer had to do manually:
1. git add .
2. git commit -m "Add feature"
3. git push origin main
4. cd src-code
5. npm test                                    # Manual testing
6. docker build -f Dockerfile.backend -t backend:v1.1 .
7. docker build -f Dockerfile.frontend -t frontend:v1.1 .
8. docker push backend:v1.1
9. docker push frontend:v1.1
10. cd ../Project-Stages/Project-Stage-1-Basic-CI-CD-Deploy
11. kubectl set image deployment/backend backend=backend:v1.1
12. kubectl set image deployment/frontend frontend=frontend:v1.1
13. kubectl rollout status deployment/backend
14. kubectl rollout status deployment/frontend
15. curl http://app-url/api/health            # Manual verification

⏱️ Time Required: 20-30 minutes per deployment
🐛 Error Prone: Human mistakes in commands, version tags, etc.
📊 Scalability: Doesn't scale with team size
```

#### **Stage 2 (Automated Process) - 3 Steps**
```bash
# Developer workflow:
1. git add .
2. git commit -m "Add feature"
3. git push origin main

# Everything else happens automatically:
✅ Tests run (Jest unit tests, integration tests)
✅ Code quality checks (ESLint, Prettier)
✅ Security scanning (if configured)
✅ Docker images build with auto-generated tags
✅ Images push to Docker Hub automatically
✅ Deployment to staging environment
✅ E2E tests run against staging (Cypress)
✅ Slack/email notification sent
✅ Production deployment awaits manual approval

⏱️ Time Required: 5-10 minutes (mostly automated)
🎯 Reliable: Consistent, repeatable process
📈 Scalable: Same process for 1 or 100 developers
```

---

## **🧪 Testing Tools Deep Dive & Alternatives**

### **1. Unit Testing Frameworks**

#### **Jest (Current Choice)**
```javascript
// jest.config.js
module.exports = {
  testEnvironment: 'node',
  collectCoverage: true,
  coverageDirectory: 'coverage',
  coverageReporters: ['text', 'lcov', 'html'],
  testMatch: ['**/__tests__/**/*.js', '**/?(*.)+(spec|test).js'],
  setupFilesAfterEnv: ['<rootDir>/tests/setup.js'],
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80
    }
  }
};

// Example test
describe('Healthcare API', () => {
  test('should return health status', async () => {
    const response = await request(app).get('/api/health');
    expect(response.status).toBe(200);
    expect(response.body).toEqual({
      status: 'healthy',
      database: 'connected',
      timestamp: expect.any(String)
    });
  });
});
```

**Pros**: 
- Mature ecosystem with extensive documentation
- Built-in mocking, coverage, and assertion library
- Great IDE integration and debugging support
- Large community and plugin ecosystem

**Cons**: 
- Can be slower than newer alternatives
- Heavy configuration for complex setups
- Memory usage can be high for large test suites

#### **Vitest (Modern Alternative)**
```javascript
// vitest.config.js
import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    environment: 'node',
    coverage: {
      reporter: ['text', 'json', 'html'],
      threshold: {
        global: {
          branches: 80,
          functions: 80,
          lines: 80,
          statements: 80
        }
      }
    },
    globals: true,
    setupFiles: ['./tests/setup.js']
  }
})

// Example test (same API as Jest)
describe('Healthcare API', () => {
  test('should return health status', async () => {
    const response = await request(app).get('/api/health');
    expect(response.status).toBe(200);
    expect(response.body.status).toBe('healthy');
  });
});
```

**Pros**: 
- 2-5x faster than Jest
- Better TypeScript support out of the box
- Hot module replacement for tests
- Vite ecosystem integration

**Cons**: 
- Newer ecosystem, fewer plugins
- Less community support
- Some Jest plugins may not work

#### **Mocha + Chai (Flexible Alternative)**
```javascript
// mocha.opts
--require tests/setup.js
--recursive tests/
--timeout 5000

// test/api.test.js
const chai = require('chai');
const chaiHttp = require('chai-http');
const expect = chai.expect;

chai.use(chaiHttp);

describe('Healthcare API', () => {
  it('should return health status', (done) => {
    chai.request(app)
      .get('/api/health')
      .end((err, res) => {
        expect(res).to.have.status(200);
        expect(res.body.status).to.equal('healthy');
        done();
      });
  });
});
```

**Pros**: 
- Highly flexible and modular
- Choose your own assertion library
- Excellent for complex test scenarios
- Mature and stable

**Cons**: 
- Requires more configuration
- Need to choose and configure multiple libraries
- Steeper learning curve

### **2. End-to-End Testing Frameworks**

#### **Cypress (Current Choice)**
```javascript
// cypress.config.js
const { defineConfig } = require('cypress')

module.exports = defineConfig({
  e2e: {
    baseUrl: 'http://localhost:3000',
    supportFile: 'cypress/support/e2e.js',
    specPattern: 'cypress/e2e/**/*.cy.{js,jsx,ts,tsx}',
    video: true,
    screenshotOnRunFailure: true,
    viewportWidth: 1280,
    viewportHeight: 720,
    defaultCommandTimeout: 10000,
    requestTimeout: 10000,
    responseTimeout: 10000,
    retries: {
      runMode: 2,
      openMode: 0
    }
  }
})

// cypress/e2e/user-registration.cy.js
describe('User Registration Flow', () => {
  beforeEach(() => {
    cy.visit('/register');
  });

  it('should register a new user successfully', () => {
    cy.get('[data-cy=firstName]').type('John');
    cy.get('[data-cy=lastName]').type('Doe');
    cy.get('[data-cy=email]').type('john.doe@example.com');
    cy.get('[data-cy=password]').type('SecurePassword123!');
    cy.get('[data-cy=confirmPassword]').type('SecurePassword123!');
    cy.get('[data-cy=submit]').click();
    
    cy.contains('Registration successful').should('be.visible');
    cy.url().should('include', '/dashboard');
  });

  it('should show validation errors for invalid data', () => {
    cy.get('[data-cy=email]').type('invalid-email');
    cy.get('[data-cy=submit]').click();
    
    cy.contains('Please enter a valid email').should('be.visible');
  });
});
```

**Pros**: 
- Excellent developer experience with time-travel debugging
- Real browser testing
- Great documentation and community
- Built-in waiting and retry logic

**Cons**: 
- Only supports Chromium-based browsers (Chrome, Edge)
- Can be slower than alternatives
- Limited parallel execution in free version

#### **Playwright (Recommended Alternative)**
```javascript
// playwright.config.js
const { defineConfig, devices } = require('@playwright/test');

module.exports = defineConfig({
  testDir: './tests/e2e',
  timeout: 30000,
  expect: {
    timeout: 5000
  },
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure'
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },
    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
    }
  ]
});

// tests/e2e/user-registration.spec.js
import { test, expect } from '@playwright/test';

test.describe('User Registration Flow', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/register');
  });

  test('should register a new user successfully', async ({ page }) => {
    await page.fill('[data-cy=firstName]', 'John');
    await page.fill('[data-cy=lastName]', 'Doe');
    await page.fill('[data-cy=email]', 'john.doe@example.com');
    await page.fill('[data-cy=password]', 'SecurePassword123!');
    await page.fill('[data-cy=confirmPassword]', 'SecurePassword123!');
    await page.click('[data-cy=submit]');
    
    await expect(page.locator('text=Registration successful')).toBeVisible();
    await expect(page).toHaveURL(/.*dashboard/);
  });

  test('should show validation errors for invalid data', async ({ page }) => {
    await page.fill('[data-cy=email]', 'invalid-email');
    await page.click('[data-cy=submit]');
    
    await expect(page.locator('text=Please enter a valid email')).toBeVisible();
  });
});
```

**Pros**: 
- Multi-browser support (Chrome, Firefox, Safari)
- Faster execution than Cypress
- Better parallel execution
- Excellent debugging tools

**Cons**: 
- Newer ecosystem
- Steeper learning curve
- Less community content

---

## **🔍 Code Quality & Security Tools Integration**

### **SonarQube (Code Quality Analysis)**

#### **Complete SonarQube Integration**
```yaml
# .github/workflows/sonarqube-analysis.yml
name: SonarQube Analysis

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  sonarqube:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      with:
        fetch-depth: 0  # Shallow clones should be disabled for better analysis
        
    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '20'
        cache: 'npm'
        
    - name: Install dependencies
      run: |
        cd src-code
        npm ci
        
    - name: Run tests with coverage
      run: |
        cd src-code
        npm run test:coverage
        
    - name: SonarQube Scan
      uses: sonarqube-quality-gate-action@master
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
      with:
        projectBaseDir: src-code
        args: >
          -Dsonar.projectKey=healthcare-management-system
          -Dsonar.organization=your-org
          -Dsonar.host.url=https://sonarcloud.io
          -Dsonar.javascript.lcov.reportPaths=coverage/lcov.info
          -Dsonar.coverage.exclusions=**/*.test.js,**/*.spec.js
          -Dsonar.cpd.exclusions=**/*.test.js,**/*.spec.js
```

#### **SonarQube Configuration**
```properties
# sonar-project.properties
sonar.projectKey=healthcare-management-system
sonar.projectName=Healthcare Management System
sonar.projectVersion=1.0

# Source code configuration
sonar.sources=src
sonar.tests=tests
sonar.test.inclusions=**/*.test.js,**/*.spec.js
sonar.coverage.exclusions=**/*.test.js,**/*.spec.js,**/node_modules/**

# JavaScript/TypeScript specific
sonar.javascript.lcov.reportPaths=coverage/lcov.info
sonar.typescript.lcov.reportPaths=coverage/lcov.info

# Quality gate thresholds
sonar.qualitygate.wait=true
```

**SonarQube Capabilities**:
- **Code Quality**: Detects bugs, code smells, duplications
- **Security**: OWASP Top 10, injection vulnerabilities
- **Maintainability**: Technical debt calculation
- **Coverage**: Test coverage analysis
- **Quality Gates**: Blocks deployment if thresholds not met

### **Trivy (Security Vulnerability Scanner)**

#### **Complete Trivy Integration**
```yaml
# .github/workflows/security-scan.yml
name: Security Scanning

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  trivy-fs-scan:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Run Trivy filesystem scan
      uses: aquasecurity/trivy-action@master
      with:
        scan-type: 'fs'
        scan-ref: 'src-code'
        format: 'sarif'
        output: 'trivy-fs-results.sarif'
        
    - name: Upload Trivy scan results to GitHub Security tab
      uses: github/codeql-action/upload-sarif@v2
      if: always()
      with:
        sarif_file: 'trivy-fs-results.sarif'

  trivy-image-scan:
    runs-on: ubuntu-latest
    needs: build  # Assumes build job creates Docker images
    steps:
    - name: Run Trivy image scan
      uses: aquasecurity/trivy-action@master
      with:
        image-ref: 'healthcare-backend:latest'
        format: 'sarif'
        output: 'trivy-image-results.sarif'
        
    - name: Upload image scan results
      uses: github/codeql-action/upload-sarif@v2
      if: always()
      with:
        sarif_file: 'trivy-image-results.sarif'

  trivy-k8s-scan:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Run Trivy Kubernetes scan
      uses: aquasecurity/trivy-action@master
      with:
        scan-type: 'config'
        scan-ref: 'k8s/'
        format: 'sarif'
        output: 'trivy-k8s-results.sarif'
        
    - name: Upload K8s scan results
      uses: github/codeql-action/upload-sarif@v2
      if: always()
      with:
        sarif_file: 'trivy-k8s-results.sarif'
```

**Trivy Capabilities**:
- **Filesystem Scanning**: Scans source code for vulnerable dependencies
- **Container Scanning**: Scans Docker images for OS and library vulnerabilities
- **Kubernetes Scanning**: Scans K8s manifests for misconfigurations
- **License Scanning**: Identifies license compliance issues
- **SBOM Generation**: Creates Software Bill of Materials

---

## **🎯 Recommended Tool Combinations**

### **Option 1: Modern High-Performance Stack**
```yaml
# Recommended for new projects prioritizing speed
Testing:
  Unit Tests: Vitest (2-5x faster than Jest)
  E2E Tests: Playwright (multi-browser, faster)
  API Tests: Supertest (works with Vitest)

Quality & Security:
  Code Quality: SonarQube (comprehensive analysis)
  Security Scanning: Trivy (fast, accurate)
  Code Formatting: Prettier
  Linting: ESLint

Benefits:
  - Fastest test execution
  - Multi-browser E2E testing
  - Comprehensive security coverage
  - Modern tooling ecosystem
```

### **Option 2: Mature Enterprise Stack**
```yaml
# Recommended for enterprise environments
Testing:
  Unit Tests: Jest (mature, stable ecosystem)
  E2E Tests: Selenium WebDriver (cross-browser, enterprise)
  API Tests: Postman/Newman (GUI + automation)

Quality & Security:
  Code Quality: SonarQube Enterprise
  Security Scanning: Trivy + Snyk
  SAST: SonarQube Security
  DAST: OWASP ZAP

Benefits:
  - Proven enterprise tools
  - Extensive support and documentation
  - Compliance-ready
  - Maximum browser coverage
```

### **Option 3: Balanced Approach (Recommended for Healthcare Project)**
```yaml
# Best balance of performance, maturity, and features
Testing:
  Unit Tests: Jest (mature, great docs)
  E2E Tests: Playwright (better performance than Cypress)
  API Tests: Supertest (integrates well)

Quality & Security:
  Code Quality: SonarQube
  Security Scanning: Trivy
  Code Formatting: Prettier
  Linting: ESLint

Benefits:
  - Proven tools with good performance
  - Excellent documentation
  - Strong community support
  - Healthcare compliance ready
```

---

## **📊 Tool Comparison Matrix**

| Aspect | Jest | Vitest | Mocha+Chai | Cypress | Playwright | Selenium |
|--------|------|--------|------------|---------|------------|----------|
| **Speed** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ |
| **Ease of Use** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ |
| **Documentation** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Community** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Browser Support** | N/A | N/A | N/A | Chrome only | All browsers | All browsers |
| **Parallel Execution** | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Debugging** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ |

---

## **🚀 Implementation Recommendations**

### **For Healthcare Management System Stage 2**

#### **Immediate Implementation (Stage 2)**
```bash
# Start with proven, stable tools
Unit Testing: Jest (mature ecosystem)
E2E Testing: Playwright (better than Cypress)
Code Quality: SonarQube (industry standard)
Security: Trivy (fast, comprehensive)
```

#### **Future Upgrades (Stage 3+)**
```bash
# Consider these for advanced stages
Unit Testing: Migrate to Vitest (performance)
E2E Testing: Add cross-browser matrix
Security: Add DAST with OWASP ZAP
Monitoring: Add performance testing
```

**This balanced approach provides reliability for Stage 2 while positioning for advanced capabilities in future stages!** 🎯✨

---

## **🔧 Advanced Pipeline Configurations**

### **Complete GitHub Actions Workflow with All Tools**

#### **Master CI/CD Pipeline with Modern Stack**
```yaml
# .github/workflows/complete-ci-cd.yml
name: Complete CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

env:
  REGISTRY: docker.io
  IMAGE_NAME_FRONTEND: ${{ secrets.DOCKER_HUB_USERNAME }}/healthcare-frontend
  IMAGE_NAME_BACKEND: ${{ secrets.DOCKER_HUB_USERNAME }}/healthcare-backend
  NODE_VERSION: '20'

jobs:
  # ============================================================================
  # QUALITY ASSURANCE STAGE
  # ============================================================================
  code-quality:
    name: Code Quality & Security Analysis
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      with:
        fetch-depth: 0  # Required for SonarQube

    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: ${{ env.NODE_VERSION }}
        cache: 'npm'
        cache-dependency-path: src-code/package-lock.json

    - name: Install dependencies
      run: |
        cd src-code
        npm ci

    - name: Run ESLint
      run: |
        cd src-code
        npm run lint

    - name: Run Prettier check
      run: |
        cd src-code
        npm run format:check

    - name: Trivy filesystem scan
      uses: aquasecurity/trivy-action@master
      with:
        scan-type: 'fs'
        scan-ref: 'src-code'
        format: 'sarif'
        output: 'trivy-fs-results.sarif'

    - name: Upload Trivy results to GitHub Security
      uses: github/codeql-action/upload-sarif@v2
      if: always()
      with:
        sarif_file: 'trivy-fs-results.sarif'

  # ============================================================================
  # TESTING STAGE
  # ============================================================================
  test:
    name: Automated Testing Suite
    runs-on: ubuntu-latest
    needs: code-quality

    services:
      postgres:
        image: postgres:16-alpine
        env:
          POSTGRES_USER: test_user
          POSTGRES_PASSWORD: test_password
          POSTGRES_DB: test_healthcare_db
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432

    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: ${{ env.NODE_VERSION }}
        cache: 'npm'
        cache-dependency-path: src-code/package-lock.json

    - name: Install dependencies
      run: |
        cd src-code
        npm ci

    - name: Wait for PostgreSQL
      run: |
        until pg_isready -h localhost -p 5432; do
          echo "Waiting for PostgreSQL..."
          sleep 2
        done

    - name: Run unit tests
      env:
        NODE_ENV: test
        DATABASE_URL: postgresql://test_user:test_password@localhost:5432/test_healthcare_db
        JWT_SECRET: test_jwt_secret_key
      run: |
        cd src-code
        npm run test:coverage

    - name: Run integration tests
      env:
        NODE_ENV: test
        DATABASE_URL: postgresql://test_user:test_password@localhost:5432/test_healthcare_db
        JWT_SECRET: test_jwt_secret_key
      run: |
        cd src-code
        npm run test:integration

    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v3
      with:
        file: src-code/coverage/lcov.info
        flags: unittests
        name: codecov-umbrella

    - name: SonarQube analysis
      uses: sonarqube-quality-gate-action@master
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
      with:
        projectBaseDir: src-code

  # ============================================================================
  # BUILD STAGE
  # ============================================================================
  build:
    name: Build & Push Docker Images
    runs-on: ubuntu-latest
    needs: test
    if: github.ref == 'refs/heads/main'

    outputs:
      image-tag: ${{ steps.meta.outputs.tags }}
      image-digest: ${{ steps.build.outputs.digest }}

    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v3

    - name: Login to Docker Hub
      uses: docker/login-action@v3
      with:
        username: ${{ secrets.DOCKER_HUB_USERNAME }}
        password: ${{ secrets.DOCKER_HUB_ACCESS_TOKEN }}

    - name: Extract metadata
      id: meta
      uses: docker/metadata-action@v5
      with:
        images: |
          ${{ env.IMAGE_NAME_BACKEND }}
          ${{ env.IMAGE_NAME_FRONTEND }}
        tags: |
          type=ref,event=branch
          type=ref,event=pr
          type=sha,prefix={{branch}}-
          type=raw,value=latest,enable={{is_default_branch}}

    - name: Build and push backend image
      id: build-backend
      uses: docker/build-push-action@v5
      with:
        context: src-code
        file: src-code/Dockerfile.backend
        push: true
        tags: ${{ env.IMAGE_NAME_BACKEND }}:${{ github.sha }},${{ env.IMAGE_NAME_BACKEND }}:latest
        cache-from: type=gha
        cache-to: type=gha,mode=max

    - name: Build and push frontend image
      id: build-frontend
      uses: docker/build-push-action@v5
      with:
        context: src-code
        file: src-code/Dockerfile.frontend.k8s
        push: true
        tags: ${{ env.IMAGE_NAME_FRONTEND }}:${{ github.sha }},${{ env.IMAGE_NAME_FRONTEND }}:latest
        cache-from: type=gha
        cache-to: type=gha,mode=max

    - name: Trivy image scan - Backend
      uses: aquasecurity/trivy-action@master
      with:
        image-ref: ${{ env.IMAGE_NAME_BACKEND }}:${{ github.sha }}
        format: 'sarif'
        output: 'trivy-backend-results.sarif'

    - name: Trivy image scan - Frontend
      uses: aquasecurity/trivy-action@master
      with:
        image-ref: ${{ env.IMAGE_NAME_FRONTEND }}:${{ github.sha }}
        format: 'sarif'
        output: 'trivy-frontend-results.sarif'

    - name: Upload image scan results
      uses: github/codeql-action/upload-sarif@v2
      if: always()
      with:
        sarif_file: 'trivy-backend-results.sarif'

  # ============================================================================
  # DEPLOYMENT STAGE - STAGING
  # ============================================================================
  deploy-staging:
    name: Deploy to Staging Environment
    runs-on: ubuntu-latest
    environment: staging
    needs: build
    if: github.ref == 'refs/heads/main'

    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v4
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ secrets.AWS_DEFAULT_REGION }}

    - name: Update kubeconfig
      run: |
        aws eks update-kubeconfig --region ${{ secrets.EKS_CLUSTER_REGION }} --name ${{ secrets.EKS_CLUSTER_NAME }}

    - name: Deploy to staging
      run: |
        cd Project-Stages/Project-Stage-2-Automated-CI-CD-Pipeline
        ./scripts/deploy-staging.sh ${{ github.sha }}

    - name: Verify staging deployment
      run: |
        kubectl rollout status deployment/healthcare-backend -n healthcare-staging --timeout=300s
        kubectl rollout status deployment/healthcare-frontend -n healthcare-staging --timeout=300s
        kubectl get pods -n healthcare-staging

    - name: Get staging URL
      id: staging-url
      run: |
        STAGING_URL=$(kubectl get service frontend-service -n healthcare-staging -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
        echo "url=http://$STAGING_URL" >> $GITHUB_OUTPUT
        echo "Staging URL: http://$STAGING_URL"

  # ============================================================================
  # E2E TESTING STAGE
  # ============================================================================
  e2e-tests:
    name: End-to-End Testing
    runs-on: ubuntu-latest
    needs: deploy-staging
    if: github.ref == 'refs/heads/main'

    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: ${{ env.NODE_VERSION }}
        cache: 'npm'
        cache-dependency-path: src-code/package-lock.json

    - name: Install dependencies
      run: |
        cd src-code
        npm ci

    - name: Install Playwright browsers
      run: |
        cd src-code
        npx playwright install --with-deps

    - name: Run Playwright E2E tests
      env:
        STAGING_URL: ${{ needs.deploy-staging.outputs.staging-url }}
      run: |
        cd src-code
        npm run test:e2e -- --config baseURL=$STAGING_URL

    - name: Upload Playwright report
      uses: actions/upload-artifact@v3
      if: always()
      with:
        name: playwright-report
        path: src-code/playwright-report/
        retention-days: 30

  # ============================================================================
  # DEPLOYMENT STAGE - PRODUCTION
  # ============================================================================
  deploy-production:
    name: Deploy to Production Environment
    runs-on: ubuntu-latest
    environment: production
    needs: [build, e2e-tests]
    if: github.ref == 'refs/heads/main'

    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v4
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ secrets.AWS_DEFAULT_REGION }}

    - name: Update kubeconfig
      run: |
        aws eks update-kubeconfig --region ${{ secrets.EKS_CLUSTER_REGION }} --name ${{ secrets.EKS_CLUSTER_NAME }}

    - name: Deploy to production
      run: |
        cd Project-Stages/Project-Stage-2-Automated-CI-CD-Pipeline
        ./scripts/deploy-production.sh ${{ github.sha }}

    - name: Verify production deployment
      run: |
        kubectl rollout status deployment/healthcare-backend -n healthcare-prod --timeout=300s
        kubectl rollout status deployment/healthcare-frontend -n healthcare-prod --timeout=300s
        kubectl get pods -n healthcare-prod

    - name: Run production smoke tests
      run: |
        PROD_URL=$(kubectl get service frontend-service -n healthcare-prod -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
        curl -f http://$PROD_URL/api/health || exit 1
        echo "Production deployment successful: http://$PROD_URL"

    - name: Notify deployment success
      if: success()
      run: |
        echo "🎉 Production deployment successful!"
        echo "Application URL: http://$(kubectl get service frontend-service -n healthcare-prod -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
```

---

## **📊 Performance Benchmarks & Metrics**

### **Pipeline Performance Targets**

#### **Build Performance**
```yaml
# Target metrics for Stage 2 pipeline
Build Times:
  - Unit Tests: < 2 minutes
  - Integration Tests: < 3 minutes
  - E2E Tests: < 5 minutes
  - Docker Build: < 4 minutes
  - Total Pipeline: < 15 minutes

Success Rates:
  - Build Success Rate: > 95%
  - Test Success Rate: > 98%
  - Deployment Success Rate: > 99%
  - E2E Test Success Rate: > 90%

Quality Metrics:
  - Code Coverage: > 80%
  - SonarQube Quality Gate: Pass
  - Security Vulnerabilities: 0 Critical/High
  - Code Duplication: < 3%
```

#### **Deployment Frequency Targets**
```yaml
# DevOps metrics (DORA metrics)
Deployment Frequency:
  - Development: Multiple times per day
  - Staging: Daily
  - Production: Weekly (or on-demand)

Lead Time:
  - Commit to Staging: < 30 minutes
  - Commit to Production: < 2 hours (including approvals)

Mean Time to Recovery:
  - Staging: < 10 minutes (automated rollback)
  - Production: < 30 minutes (manual intervention)

Change Failure Rate:
  - Target: < 5%
  - Measurement: Failed deployments requiring rollback
```

---

## **🔧 Tool Configuration Examples**

### **Jest Configuration for Healthcare Project**
```javascript
// jest.config.js - Production-ready configuration
module.exports = {
  // Test environment
  testEnvironment: 'node',

  // Coverage configuration
  collectCoverage: true,
  coverageDirectory: 'coverage',
  coverageReporters: ['text', 'lcov', 'html', 'json'],
  collectCoverageFrom: [
    'src/**/*.{js,jsx}',
    '!src/**/*.test.{js,jsx}',
    '!src/**/*.spec.{js,jsx}',
    '!src/index.js',
    '!src/config/**',
    '!**/node_modules/**'
  ],

  // Coverage thresholds
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80
    },
    './src/controllers/': {
      branches: 90,
      functions: 90,
      lines: 90,
      statements: 90
    },
    './src/services/': {
      branches: 85,
      functions: 85,
      lines: 85,
      statements: 85
    }
  },

  // Test patterns
  testMatch: [
    '**/__tests__/**/*.{js,jsx}',
    '**/?(*.)+(spec|test).{js,jsx}'
  ],

  // Setup files
  setupFilesAfterEnv: ['<rootDir>/tests/setup.js'],

  // Module mapping for absolute imports
  moduleNameMapping: {
    '^@/(.*)$': '<rootDir>/src/$1',
    '^@tests/(.*)$': '<rootDir>/tests/$1'
  },

  // Test timeout
  testTimeout: 10000,

  // Verbose output
  verbose: true,

  // Transform configuration
  transform: {
    '^.+\\.jsx?$': 'babel-jest'
  },

  // Clear mocks between tests
  clearMocks: true,

  // Restore mocks after each test
  restoreMocks: true
};
```

### **Playwright Configuration for Healthcare Project**
```javascript
// playwright.config.js - Production-ready configuration
const { defineConfig, devices } = require('@playwright/test');

module.exports = defineConfig({
  // Test directory
  testDir: './tests/e2e',

  // Global timeout
  timeout: 30000,

  // Expect timeout
  expect: {
    timeout: 5000
  },

  // Run tests in parallel
  fullyParallel: true,

  // Fail the build on CI if you accidentally left test.only in the source code
  forbidOnly: !!process.env.CI,

  // Retry on CI only
  retries: process.env.CI ? 2 : 0,

  // Opt out of parallel tests on CI
  workers: process.env.CI ? 1 : undefined,

  // Reporter configuration
  reporter: [
    ['html'],
    ['json', { outputFile: 'test-results.json' }],
    ['junit', { outputFile: 'test-results.xml' }]
  ],

  // Shared settings for all projects
  use: {
    // Base URL for tests
    baseURL: process.env.STAGING_URL || 'http://localhost:3000',

    // Collect trace when retrying the failed test
    trace: 'on-first-retry',

    // Take screenshot on failure
    screenshot: 'only-on-failure',

    // Record video on failure
    video: 'retain-on-failure',

    // Global test timeout
    actionTimeout: 10000,

    // Navigation timeout
    navigationTimeout: 30000
  },

  // Configure projects for major browsers
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },
    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
    },

    // Mobile browsers
    {
      name: 'Mobile Chrome',
      use: { ...devices['Pixel 5'] },
    },
    {
      name: 'Mobile Safari',
      use: { ...devices['iPhone 12'] },
    },
  ],

  // Run local dev server before starting tests
  webServer: {
    command: 'npm run start',
    port: 3000,
    reuseExistingServer: !process.env.CI,
    timeout: 120000
  }
});
```

**This comprehensive analysis provides everything needed to make informed decisions about testing tools and pipeline configurations for Stage 2!** 🚀📊✨
