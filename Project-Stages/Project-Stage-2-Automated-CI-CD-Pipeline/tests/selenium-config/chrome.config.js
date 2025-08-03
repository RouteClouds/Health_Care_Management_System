/**
 * Chrome-specific Selenium Configuration
 * Healthcare Management System - Stage 2
 * Optimized Chrome WebDriver settings for E2E testing
 */

const { Builder } = require('selenium-webdriver');
const chrome = require('selenium-webdriver/chrome');

/**
 * Chrome WebDriver Configuration
 */
const chromeConfig = {
  // Chrome-specific options
  options: {
    // Window settings
    windowSize: {
      width: 1920,
      height: 1080
    },
    
    // Chrome arguments for optimal testing
    args: [
      '--no-sandbox',                              // Required for CI environments
      '--disable-dev-shm-usage',                   // Overcome limited resource problems
      '--disable-gpu',                             // Disable GPU acceleration
      '--disable-extensions',                      // Disable extensions
      '--disable-background-timer-throttling',     // Disable background timer throttling
      '--disable-backgrounding-occluded-windows',  // Disable backgrounding occluded windows
      '--disable-renderer-backgrounding',          // Disable renderer backgrounding
      '--disable-features=TranslateUI',            // Disable translate UI
      '--disable-ipc-flooding-protection',         // Disable IPC flooding protection
      '--disable-web-security',                    // Disable web security (for testing)
      '--allow-running-insecure-content',          // Allow insecure content
      '--disable-blink-features=AutomationControlled', // Hide automation indicators
      '--disable-infobars',                        // Disable infobars
      '--disable-notifications',                   // Disable notifications
      '--disable-popup-blocking',                  // Disable popup blocking
      '--disable-save-password-bubble',            // Disable save password bubble
      '--disable-translate',                       // Disable translate
      '--disable-default-apps',                    // Disable default apps
      '--disable-sync',                           // Disable sync
      '--disable-background-networking',           // Disable background networking
      '--disable-component-extensions-with-background-pages', // Disable component extensions
      '--disable-client-side-phishing-detection', // Disable phishing detection
      '--disable-hang-monitor',                    // Disable hang monitor
      '--disable-prompt-on-repost',               // Disable prompt on repost
      '--disable-domain-reliability',             // Disable domain reliability
      '--disable-features=VizDisplayCompositor',  // Disable viz display compositor
      '--disable-features=VizServiceDisplayCompositor', // Disable viz service display compositor
      '--disable-logging',                        // Disable logging
      '--silent',                                 // Silent mode
      '--log-level=3',                           // Reduce log level
      '--disable-dev-tools',                     // Disable dev tools
      '--disable-plugins',                       // Disable plugins
      '--disable-images',                        // Disable images (for faster loading)
      '--disable-javascript',                    // Disable JavaScript (enable only when needed)
      '--disable-plugins-discovery',             // Disable plugins discovery
      '--disable-preconnect',                    // Disable preconnect
      '--disable-prefetch',                      // Disable prefetch
    ],
    
    // Chrome preferences
    prefs: {
      'profile.default_content_setting_values': {
        'notifications': 2,                       // Block notifications
        'geolocation': 2,                        // Block location requests
        'media_stream': 2,                       // Block camera/microphone
        'plugins': 2,                            // Block plugins
        'popups': 2,                             // Block popups
        'automatic_downloads': 2,                // Block automatic downloads
        'mixed_script': 2,                       // Block mixed content
        'protocol_handlers': 2,                  // Block protocol handlers
        'push_messaging': 2,                     // Block push messaging
        'ssl_cert_decisions': 2,                 // Block SSL cert decisions
        'metro_switch_to_desktop': 2,            // Block metro switch
        'protected_media_identifier': 2,         // Block protected media
        'app_banner': 2,                         // Block app banner
        'site_engagement': 2,                    // Block site engagement
        'durable_storage': 2                     // Block durable storage
      },
      'profile.default_content_settings': {
        'popups': 0,                             // Allow popups (for testing)
        'notifications': 2,                      // Block notifications
        'geolocation': 2,                        // Block geolocation
        'media_stream': 2                        // Block media stream
      },
      'profile.managed_default_content_settings': {
        'images': 1                              // Allow images
      },
      'profile.password_manager_enabled': false,  // Disable password manager
      'credentials_enable_service': false,        // Disable credentials service
      'password_manager_enabled': false,          // Disable password manager
      'autofill.profile_enabled': false,          // Disable autofill
      'autofill.credit_card_enabled': false,      // Disable credit card autofill
      'translate.enabled': false,                 // Disable translate
      'safebrowsing.enabled': false,             // Disable safe browsing
      'download.default_directory': '/tmp',       // Set download directory
      'download.prompt_for_download': false,      // Don't prompt for downloads
      'download.directory_upgrade': true,         // Allow directory upgrade
      'plugins.always_open_pdf_externally': true, // Open PDFs externally
      'plugins.plugins_disabled': [               // Disable specific plugins
        'Adobe Flash Player',
        'Chrome PDF Plugin'
      ]
    },
    
    // Experimental options
    experimentalOptions: {
      'useAutomationExtension': false,           // Disable automation extension
      'excludeSwitches': [                       // Exclude switches
        'enable-automation',
        'enable-logging'
      ],
      'detach': false,                          // Don't detach browser
      'debuggerAddress': null                   // No debugger address
    }
  },
  
  // Performance settings
  performance: {
    // Network throttling (for testing slow connections)
    networkThrottling: {
      enabled: false,
      downloadThroughput: 1.5 * 1024 * 1024,  // 1.5 Mbps
      uploadThroughput: 750 * 1024,            // 750 Kbps
      latency: 40                              // 40ms latency
    },
    
    // CPU throttling
    cpuThrottling: {
      enabled: false,
      rate: 4                                  // 4x slower
    }
  },
  
  // Mobile emulation settings
  mobileEmulation: {
    enabled: false,
    deviceName: 'iPhone 12 Pro',
    userAgent: 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0 Mobile/15E148 Safari/604.1'
  },
  
  // Logging configuration
  logging: {
    level: 'SEVERE',                           // Only log severe errors
    prefs: {
      'browser': 'OFF',
      'driver': 'OFF',
      'performance': 'OFF'
    }
  }
};

/**
 * Create optimized Chrome WebDriver
 */
function createChromeDriver(customOptions = {}) {
  const options = new chrome.Options();
  
  // Merge custom options with default config
  const config = { ...chromeConfig, ...customOptions };
  
  // Set window size
  if (config.options.windowSize) {
    options.windowSize(config.options.windowSize);
  }
  
  // Add Chrome arguments
  config.options.args.forEach(arg => {
    options.addArguments(arg);
  });
  
  // Set preferences
  if (config.options.prefs) {
    Object.keys(config.options.prefs).forEach(pref => {
      options.setUserPreferences({ [pref]: config.options.prefs[pref] });
    });
  }
  
  // Set experimental options
  if (config.options.experimentalOptions) {
    Object.keys(config.options.experimentalOptions).forEach(option => {
      options.setExperimentalOption(option, config.options.experimentalOptions[option]);
    });
  }
  
  // Set headless mode for CI
  if (process.env.CI === 'true' || process.env.HEADLESS === 'true') {
    options.headless();
    console.log('🤖 Running Chrome in headless mode');
  }
  
  // Enable mobile emulation if configured
  if (config.mobileEmulation.enabled) {
    options.setMobileEmulation({
      deviceName: config.mobileEmulation.deviceName
    });
    console.log(`📱 Mobile emulation enabled: ${config.mobileEmulation.deviceName}`);
  }
  
  // Set logging preferences
  options.setLoggingPrefs(config.logging.prefs);
  
  // Create and return driver
  const driver = new Builder()
    .forBrowser('chrome')
    .setChromeOptions(options)
    .build();
  
  console.log('🚀 Chrome WebDriver created with optimized settings');
  return driver;
}

/**
 * Chrome-specific test utilities
 */
const chromeUtils = {
  /**
   * Enable performance monitoring
   */
  async enablePerformanceMonitoring(driver) {
    await driver.executeScript(`
      window.performance.mark('test-start');
      window.testMetrics = {
        navigationStart: performance.timing.navigationStart,
        loadEventEnd: performance.timing.loadEventEnd,
        domContentLoaded: performance.timing.domContentLoadedEventEnd
      };
    `);
  },
  
  /**
   * Get performance metrics
   */
  async getPerformanceMetrics(driver) {
    return await driver.executeScript(`
      const timing = performance.timing;
      return {
        pageLoadTime: timing.loadEventEnd - timing.navigationStart,
        domContentLoadedTime: timing.domContentLoadedEventEnd - timing.navigationStart,
        firstPaint: performance.getEntriesByType('paint')[0]?.startTime || 0,
        firstContentfulPaint: performance.getEntriesByType('paint')[1]?.startTime || 0,
        resourceCount: performance.getEntriesByType('resource').length
      };
    `);
  },
  
  /**
   * Clear browser data
   */
  async clearBrowserData(driver) {
    await driver.executeScript(`
      localStorage.clear();
      sessionStorage.clear();
      if ('caches' in window) {
        caches.keys().then(names => {
          names.forEach(name => caches.delete(name));
        });
      }
    `);
  },
  
  /**
   * Set network conditions
   */
  async setNetworkConditions(driver, conditions) {
    await driver.executeScript(`
      chrome.runtime.sendMessage({
        method: 'Network.emulateNetworkConditions',
        params: ${JSON.stringify(conditions)}
      });
    `);
  }
};

module.exports = {
  chromeConfig,
  createChromeDriver,
  chromeUtils
};
