// Simple unit tests for backend without database dependencies

describe('Healthcare Backend - Basic Tests', () => {
  it('should pass basic math test', () => {
    expect(2 + 2).toBe(4);
  });

  it('should validate environment setup', () => {
    expect(process.env.NODE_ENV).toBeDefined();
  });

  it('should have correct package name', () => {
    const packageJson = require('../package.json');
    expect(packageJson.name).toBe('healthcare-backend-stage3');
    expect(packageJson.version).toBe('1.0.0');
  });
});
