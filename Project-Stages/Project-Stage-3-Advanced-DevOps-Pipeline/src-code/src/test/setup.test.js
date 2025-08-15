// Simple test to verify Jest setup is working
describe('Jest Setup Verification', () => {
  test('should be able to run basic tests', () => {
    expect(1 + 1).toBe(2);
  });

  test('should have access to testing environment variables', () => {
    expect(process.env.NODE_ENV).toBe('test');
    expect(process.env.REACT_APP_API_URL).toBe('http://localhost:3002/api');
  });

  test('should have jest-dom matchers available', () => {
    // Create a simple DOM element to test jest-dom matchers
    const element = document.createElement('div');
    element.textContent = 'Hello World';
    document.body.appendChild(element);
    
    expect(element).toBeInTheDocument();
    expect(element).toHaveTextContent('Hello World');
    
    // Clean up
    document.body.removeChild(element);
  });
});
