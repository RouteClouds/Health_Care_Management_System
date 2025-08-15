/**
 * Prettier Configuration for Frontend
 * Healthcare Management System - Stage 2
 */

module.exports = {
  // Basic formatting
  semi: true,
  trailingComma: 'es5',
  singleQuote: true,
  doubleQuote: false,
  
  // Indentation
  tabWidth: 2,
  useTabs: false,
  
  // Line length
  printWidth: 80,
  
  // Bracket spacing
  bracketSpacing: true,
  bracketSameLine: false,
  
  // Arrow functions
  arrowParens: 'avoid',
  
  // End of line
  endOfLine: 'lf',
  
  // Quote props
  quoteProps: 'as-needed',
  
  // JSX specific
  jsxSingleQuote: true,
  
  // Override for specific file types
  overrides: [
    {
      files: '*.json',
      options: {
        printWidth: 120
      }
    },
    {
      files: '*.md',
      options: {
        printWidth: 100,
        proseWrap: 'always'
      }
    },
    {
      files: '*.css',
      options: {
        printWidth: 120
      }
    }
  ]
};
