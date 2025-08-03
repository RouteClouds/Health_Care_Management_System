/**
 * Firefox-specific Selenium Configuration
 * Healthcare Management System - Stage 2
 * Optimized Firefox WebDriver settings for E2E testing
 */

const { Builder } = require('selenium-webdriver');
const firefox = require('selenium-webdriver/firefox');

/**
 * Firefox WebDriver Configuration
 */
const firefoxConfig = {
  // Firefox-specific options
  options: {
    // Window settings
    windowSize: {
      width: 1920,
      height: 1080
    },
    
    // Firefox arguments
    args: [
      '--width=1920',
      '--height=1080',
      '--disable-dev-shm-usage',
      '--no-sandbox',
      '--disable-gpu'
    ],
    
    // Firefox preferences
    prefs: {
      // Disable notifications
      'dom.webnotifications.enabled': false,
      'dom.push.enabled': false,
      
      // Disable geolocation
      'geo.enabled': false,
      'geo.provider.use_gpsd': false,
      
      // Disable media permissions
      'media.navigator.permission.disabled': true,
      'media.navigator.enabled': false,
      
      // Disable password manager
      'signon.rememberSignons': false,
      'signon.autofillForms': false,
      
      // Disable form autofill
      'browser.formfill.enable': false,
      'extensions.formautofill.addresses.enabled': false,
      'extensions.formautofill.creditCards.enabled': false,
      
      // Disable updates
      'app.update.enabled': false,
      'app.update.auto': false,
      'app.update.mode': 0,
      'app.update.service.enabled': false,
      
      // Disable telemetry
      'toolkit.telemetry.enabled': false,
      'toolkit.telemetry.unified': false,
      'datareporting.healthreport.uploadEnabled': false,
      'datareporting.policy.dataSubmissionEnabled': false,
      
      // Disable safe browsing
      'browser.safebrowsing.enabled': false,
      'browser.safebrowsing.malware.enabled': false,
      'browser.safebrowsing.phishing.enabled': false,
      
      // Disable tracking protection
      'privacy.trackingprotection.enabled': false,
      'privacy.trackingprotection.pbmode.enabled': false,
      
      // Disable popup blocking for testing
      'dom.disable_open_during_load': false,
      'dom.popup_maximum': 0,
      
      // Performance optimizations
      'network.http.pipelining': true,
      'network.http.proxy.pipelining': true,
      'network.http.pipelining.maxrequests': 8,
      'content.notify.interval': 500000,
      'content.notify.ontimer': true,
      'content.switch.threshold': 500000,
      'browser.cache.use_new_backend': 1,
      'browser.cache.use_new_backend_temp': true,
      
      // Disable animations for faster testing
      'toolkit.cosmeticAnimations.enabled': false,
      'browser.fullscreen.animateUp': 0,
      'security.dialog_enable_delay': 0,
      
      // Disable extensions and plugins
      'extensions.autoDisableScopes': 14,
      'extensions.blocklist.enabled': false,
      'plugin.state.flash': 0,
      'plugin.state.java': 0,
      
      // Download settings
      'browser.download.folderList': 2,
      'browser.download.manager.showWhenStarting': false,
      'browser.download.dir': '/tmp',
      'browser.helperApps.neverAsk.saveToDisk': 'application/pdf,application/octet-stream,application/x-winexe,application/x-debian-package,application/x-www-form-urlencoded',
      
      // Security settings for testing
      'security.tls.insecure_fallback_hosts': 'localhost',
      'security.fileuri.strict_origin_policy': false,
      'network.stricttransportsecurity.preloadlist': false,
      'security.mixed_content.block_active_content': false,
      'security.mixed_content.block_display_content': false,
      
      // Logging
      'devtools.console.stdout.content': false,
      'browser.dom.window.dump.enabled': false,
      
      // Disable first run pages
      'browser.startup.homepage_override.mstone': 'ignore',
      'startup.homepage_welcome_url': 'about:blank',
      'startup.homepage_welcome_url.additional': '',
      'browser.startup.firstrunSkipsHomepage': true,
      
      // Disable session restore
      'browser.sessionstore.resume_from_crash': false,
      'browser.sessionstore.restore_on_demand': false,
      'browser.sessionstore.restore_tabs_lazily': false,
      
      // Disable new tab page
      'browser.newtabpage.enabled': false,
      'browser.newtab.url': 'about:blank',
      
      // Disable pocket
      'extensions.pocket.enabled': false,
      'browser.newtabpage.activity-stream.feeds.section.topstories': false,
      
      // Disable reader mode
      'reader.parse-on-load.enabled': false,
      
      // Disable accessibility services
      'accessibility.force_disabled': 1,
      
      // Disable WebRTC
      'media.peerconnection.enabled': false,
      'media.navigator.video.enabled': false,
      'media.navigator.audio.enabled': false
    },
    
    // Binary path (if custom Firefox installation)
    binaryPath: process.env.FIREFOX_BINARY || null,
    
    // Profile settings
    profile: {
      // Custom profile path
      path: null,
      
      // Profile preferences (same as above, but applied to profile)
      preferences: {}
    }
  },
  
  // Logging configuration
  logging: {
    level: 'SEVERE',
    prefs: {
      'browser': 'OFF',
      'driver': 'OFF'
    }
  },
  
  // Mobile emulation (limited support in Firefox)
  mobileEmulation: {
    enabled: false,
    userAgent: 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0 Mobile/15E148 Safari/604.1'
  }
};

/**
 * Create optimized Firefox WebDriver
 */
function createFirefoxDriver(customOptions = {}) {
  const options = new firefox.Options();
  
  // Merge custom options with default config
  const config = { ...firefoxConfig, ...customOptions };
  
  // Set window size
  if (config.options.windowSize) {
    options.windowSize(config.options.windowSize);
  }
  
  // Add Firefox arguments
  config.options.args.forEach(arg => {
    options.addArguments(arg);
  });
  
  // Set preferences
  if (config.options.prefs) {
    Object.keys(config.options.prefs).forEach(pref => {
      options.setPreference(pref, config.options.prefs[pref]);
    });
  }
  
  // Set binary path if specified
  if (config.options.binaryPath) {
    options.setBinary(config.options.binaryPath);
  }
  
  // Set headless mode for CI
  if (process.env.CI === 'true' || process.env.HEADLESS === 'true') {
    options.headless();
    console.log('🤖 Running Firefox in headless mode');
  }
  
  // Enable mobile emulation if configured
  if (config.mobileEmulation.enabled) {
    options.setPreference('general.useragent.override', config.mobileEmulation.userAgent);
    console.log('📱 Mobile emulation enabled for Firefox');
  }
  
  // Create and return driver
  const driver = new Builder()
    .forBrowser('firefox')
    .setFirefoxOptions(options)
    .build();
  
  console.log('🦊 Firefox WebDriver created with optimized settings');
  return driver;
}

/**
 * Firefox-specific test utilities
 */
const firefoxUtils = {
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
        resourceCount: performance.getEntriesByType('resource').length,
        memoryUsage: performance.memory ? {
          usedJSHeapSize: performance.memory.usedJSHeapSize,
          totalJSHeapSize: performance.memory.totalJSHeapSize,
          jsHeapSizeLimit: performance.memory.jsHeapSizeLimit
        } : null
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
   * Set user agent
   */
  async setUserAgent(driver, userAgent) {
    await driver.executeScript(`
      Object.defineProperty(navigator, 'userAgent', {
        get: function() { return '${userAgent}'; }
      });
    `);
  },
  
  /**
   * Disable images for faster loading
   */
  async disableImages(driver) {
    await driver.executeScript(`
      const style = document.createElement('style');
      style.textContent = 'img { display: none !important; }';
      document.head.appendChild(style);
    `);
  },
  
  /**
   * Get browser logs
   */
  async getBrowserLogs(driver) {
    try {
      const logs = await driver.manage().logs().get('browser');
      return logs.map(log => ({
        level: log.level.name,
        message: log.message,
        timestamp: log.timestamp
      }));
    } catch (error) {
      console.warn('Could not retrieve browser logs:', error.message);
      return [];
    }
  }
};

module.exports = {
  firefoxConfig,
  createFirefoxDriver,
  firefoxUtils
};
