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
    await driver.get('http://localhost:5173');
    const title = await driver.getTitle();
    expect(title).toContain('Healthcare');
  });

  test('should navigate to doctor search', async () => {
    await driver.get('http://localhost:5173');
    const searchButton = await driver.findElement(By.css('[data-testid="find-doctor"]'));
    await searchButton.click();
    
    await driver.wait(until.urlContains('/doctors'), 5000);
    const currentUrl = await driver.getCurrentUrl();
    expect(currentUrl).toContain('/doctors');
  });
});
