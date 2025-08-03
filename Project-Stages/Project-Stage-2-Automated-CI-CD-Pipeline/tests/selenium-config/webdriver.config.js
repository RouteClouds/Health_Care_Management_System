/**
 * Selenium WebDriver Configuration
 * Healthcare Management System - Stage 2
 * Cross-browser E2E testing configuration
 */

const { Builder, By, until } = require('selenium-webdriver');
const chrome = require('selenium-webdriver/chrome');
const firefox = require('selenium-webdriver/firefox');

// Test configuration
const config = {
  // Application URLs
  baseUrl: process.env.TEST_BASE_URL || 'http://localhost:3000',
  apiUrl: process.env.TEST_API_URL || 'http://localhost:3001',
  
  // Test timeouts
  timeouts: {
    implicit: 10000,      // 10 seconds
    explicit: 30000,      // 30 seconds
    page: 60000,          // 1 minute
    script: 30000         // 30 seconds
  },
  
  // Browser configurations
  browsers: {
    chrome: {
      headless: process.env.CI === 'true',
      windowSize: { width: 1920, height: 1080 },
      args: [
        '--no-sandbox',
        '--disable-dev-shm-usage',
        '--disable-gpu',
        '--disable-extensions',
        '--disable-background-timer-throttling',
        '--disable-backgrounding-occluded-windows',
        '--disable-renderer-backgrounding'
      ]
    },
    firefox: {
      headless: process.env.CI === 'true',
      windowSize: { width: 1920, height: 1080 },
      prefs: {
        'dom.webnotifications.enabled': false,
        'media.navigator.permission.disabled': true
      }
    }
  },
  
  // Test data
  testData: {
    users: {
      patient: {
        email: 'patient@test.com',
        password: 'TestPassword123!',
        firstName: 'John',
        lastName: 'Doe'
      },
      doctor: {
        email: 'doctor@test.com',
        password: 'TestPassword123!',
        firstName: 'Dr. Jane',
        lastName: 'Smith'
      },
      admin: {
        email: 'admin@test.com',
        password: 'TestPassword123!',
        firstName: 'Admin',
        lastName: 'User'
      }
    },
    appointments: {
      future: {
        date: '2025-12-01',
        time: '10:00',
        type: 'consultation'
      },
      past: {
        date: '2025-01-01',
        time: '14:00',
        type: 'checkup'
      }
    }
  },
  
  // Screenshot configuration
  screenshots: {
    enabled: true,
    path: './test-results/screenshots',
    onFailure: true,
    onSuccess: false
  },
  
  // Video recording (if enabled)
  video: {
    enabled: false,
    path: './test-results/videos'
  },
  
  // Reporting
  reports: {
    path: './test-results/reports',
    formats: ['json', 'html']
  }
};

/**
 * WebDriver Factory
 * Creates WebDriver instances for different browsers
 */
class WebDriverFactory {
  /**
   * Create Chrome WebDriver
   */
  static createChromeDriver() {
    const options = new chrome.Options();
    
    // Set window size
    options.windowSize(config.browsers.chrome.windowSize);
    
    // Add Chrome arguments
    config.browsers.chrome.args.forEach(arg => {
      options.addArguments(arg);
    });
    
    // Set headless mode
    if (config.browsers.chrome.headless) {
      options.headless();
    }
    
    // Additional Chrome options for CI
    if (process.env.CI === 'true') {
      options.addArguments('--disable-web-security');
      options.addArguments('--allow-running-insecure-content');
    }
    
    return new Builder()
      .forBrowser('chrome')
      .setChromeOptions(options)
      .build();
  }
  
  /**
   * Create Firefox WebDriver
   */
  static createFirefoxDriver() {
    const options = new firefox.Options();
    
    // Set window size
    options.windowSize(config.browsers.firefox.windowSize);
    
    // Set preferences
    Object.keys(config.browsers.firefox.prefs).forEach(pref => {
      options.setPreference(pref, config.browsers.firefox.prefs[pref]);
    });
    
    // Set headless mode
    if (config.browsers.firefox.headless) {
      options.headless();
    }
    
    return new Builder()
      .forBrowser('firefox')
      .setFirefoxOptions(options)
      .build();
  }
  
  /**
   * Create WebDriver based on browser name
   */
  static createDriver(browserName = 'chrome') {
    switch (browserName.toLowerCase()) {
      case 'chrome':
        return this.createChromeDriver();
      case 'firefox':
        return this.createFirefoxDriver();
      default:
        throw new Error(`Unsupported browser: ${browserName}`);
    }
  }
}

/**
 * Base Test Class
 * Provides common functionality for E2E tests
 */
class BaseTest {
  constructor(browserName = 'chrome') {
    this.browserName = browserName;
    this.driver = null;
    this.testName = '';
  }
  
  /**
   * Setup test environment
   */
  async setup(testName) {
    this.testName = testName;
    this.driver = WebDriverFactory.createDriver(this.browserName);
    
    // Set timeouts
    await this.driver.manage().setTimeouts({
      implicit: config.timeouts.implicit,
      pageLoad: config.timeouts.page,
      script: config.timeouts.script
    });
    
    console.log(`🌐 Starting ${this.browserName} browser for test: ${testName}`);
  }
  
  /**
   * Teardown test environment
   */
  async teardown() {
    if (this.driver) {
      await this.driver.quit();
      console.log(`🔚 Closed ${this.browserName} browser for test: ${this.testName}`);
    }
  }
  
  /**
   * Navigate to URL
   */
  async navigateTo(path = '') {
    const url = `${config.baseUrl}${path}`;
    await this.driver.get(url);
    console.log(`📍 Navigated to: ${url}`);
  }
  
  /**
   * Wait for element to be present
   */
  async waitForElement(locator, timeout = config.timeouts.explicit) {
    return await this.driver.wait(until.elementLocated(locator), timeout);
  }
  
  /**
   * Wait for element to be visible
   */
  async waitForElementVisible(locator, timeout = config.timeouts.explicit) {
    const element = await this.waitForElement(locator, timeout);
    return await this.driver.wait(until.elementIsVisible(element), timeout);
  }
  
  /**
   * Wait for element to be clickable
   */
  async waitForElementClickable(locator, timeout = config.timeouts.explicit) {
    const element = await this.waitForElement(locator, timeout);
    return await this.driver.wait(until.elementIsEnabled(element), timeout);
  }
  
  /**
   * Take screenshot
   */
  async takeScreenshot(name) {
    if (!config.screenshots.enabled) return;
    
    const screenshot = await this.driver.takeScreenshot();
    const fs = require('fs');
    const path = require('path');
    
    // Ensure screenshots directory exists
    const screenshotDir = config.screenshots.path;
    if (!fs.existsSync(screenshotDir)) {
      fs.mkdirSync(screenshotDir, { recursive: true });
    }
    
    const filename = `${this.testName}-${name}-${Date.now()}.png`;
    const filepath = path.join(screenshotDir, filename);
    
    fs.writeFileSync(filepath, screenshot, 'base64');
    console.log(`📸 Screenshot saved: ${filepath}`);
  }
  
  /**
   * Login helper
   */
  async login(userType = 'patient') {
    const user = config.testData.users[userType];
    if (!user) {
      throw new Error(`Unknown user type: ${userType}`);
    }
    
    await this.navigateTo('/login');
    
    // Fill login form
    await this.driver.findElement(By.name('email')).sendKeys(user.email);
    await this.driver.findElement(By.name('password')).sendKeys(user.password);
    
    // Submit form
    await this.driver.findElement(By.css('button[type="submit"]')).click();
    
    // Wait for redirect
    await this.driver.wait(until.urlContains('/dashboard'), config.timeouts.explicit);
    
    console.log(`🔐 Logged in as ${userType}: ${user.email}`);
  }
  
  /**
   * Logout helper
   */
  async logout() {
    await this.driver.findElement(By.css('[data-testid="logout-button"]')).click();
    await this.driver.wait(until.urlContains('/login'), config.timeouts.explicit);
    console.log('🚪 Logged out successfully');
  }
}

module.exports = {
  config,
  WebDriverFactory,
  BaseTest,
  By,
  until
};
