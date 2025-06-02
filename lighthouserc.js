module.exports = {
  ci: {
    collect: {
      numberOfRuns: 1,
      staticDistDir: './site',
      url: ['http://localhost:8080'],
      settings: {
        chromeFlags: '--no-sandbox --headless --disable-gpu --disable-dev-shm-usage --disable-web-security'
      }
    },
    assert: {
      preset: 'lighthouse:recommended',
      assertions: {
        'categories:accessibility': ['warn', { minScore: 0.80 }],
        'categories:best-practices': ['warn', { minScore: 0.75 }],
        'categories:seo': ['warn', { minScore: 0.75 }],
        'categories:performance': 'off'
      }
    },
    upload: {
      target: 'temporary-public-storage'
    }
  }
};
