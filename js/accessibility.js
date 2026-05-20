// Accessibility enhancements for Vitistack MkDocs theme
document.addEventListener('DOMContentLoaded', function() {
    // Fix ARIA dialog name for search
    const searchDialog = document.querySelector('.md-search[role="dialog"]');
    if (searchDialog) {
        searchDialog.setAttribute('aria-label', 'Search dialog');
        searchDialog.setAttribute('aria-labelledby', 'search-title');
        
        // Create a hidden title for the search dialog
        const searchTitle = document.createElement('h2');
        searchTitle.id = 'search-title';
        searchTitle.className = 'sr-only';
        searchTitle.textContent = 'Search Documentation';
        searchDialog.insertBefore(searchTitle, searchDialog.firstChild);
    }
    
    // Fix ARIA label for search form
    const searchForm = document.querySelector('.md-search__form');
    if (searchForm) {
        searchForm.setAttribute('aria-label', 'Search documentation');
        searchForm.setAttribute('role', 'search');
    }
    
    // Fix ARIA label for search input
    const searchInput = document.querySelector('.md-search__input');
    if (searchInput && !searchInput.hasAttribute('aria-label')) {
        searchInput.setAttribute('aria-label', 'Search documentation');
        searchInput.setAttribute('placeholder', 'Search documentation...');
    }
    
    // Fix ARIA label for palette switcher
    const paletteForm = document.querySelector('.md-header__option[data-md-component="palette"]');
    if (paletteForm && !paletteForm.hasAttribute('aria-label')) {
        paletteForm.setAttribute('aria-label', 'Color theme switcher');
    }
    
    // Add proper labels to palette radio buttons
    const paletteInputs = document.querySelectorAll('.md-header__option input[type="radio"]');
    paletteInputs.forEach((input, index) => {
        if (!input.hasAttribute('aria-label')) {
            const theme = input.getAttribute('data-md-color-scheme') || 'theme-' + index;
            input.setAttribute('aria-label', `Switch to ${theme} theme`);
        }
    });
    
    // Add skip link if not present
    if (!document.querySelector('.skip-link')) {
        const skipLink = document.createElement('a');
        skipLink.href = '#main-content';
        skipLink.className = 'skip-link';
        skipLink.textContent = 'Skip to main content';
        skipLink.setAttribute('aria-label', 'Skip to main content');
        document.body.insertBefore(skipLink, document.body.firstChild);
    }
    
    // Ensure main content area has proper ID for skip link
    const mainContent = document.querySelector('main') || document.querySelector('.md-content');
    if (mainContent && !mainContent.hasAttribute('id')) {
        mainContent.setAttribute('id', 'main-content');
    }
    
    // Add role="main" to main content if missing
    if (mainContent && !mainContent.hasAttribute('role')) {
        mainContent.setAttribute('role', 'main');
    }
    
    // Fix heading hierarchy if needed
    const headings = document.querySelectorAll('h1, h2, h3, h4, h5, h6');
    let expectedLevel = 1;
    
    headings.forEach(heading => {
        const currentLevel = parseInt(heading.tagName.substring(1));
        
        // Skip if heading level is appropriate
        if (currentLevel <= expectedLevel + 1) {
            expectedLevel = currentLevel;
            return;
        }
        
        // Log accessibility warning for skipped heading levels
        console.warn(`Accessibility: Heading level ${currentLevel} follows level ${expectedLevel - 1}, which may confuse screen readers.`);
    });
    
    // Enhance keyboard navigation for mobile menu
    const menuButton = document.querySelector('[data-md-toggle="drawer"]');
    if (menuButton) {
        menuButton.addEventListener('keydown', function(e) {
            if (e.key === 'Enter' || e.key === ' ') {
                e.preventDefault();
                this.click();
            }
        });
    }
    
    // Enhance keyboard navigation for search
    const searchButton = document.querySelector('[data-md-toggle="search"]');
    if (searchButton) {
        searchButton.addEventListener('keydown', function(e) {
            if (e.key === 'Enter' || e.key === ' ') {
                e.preventDefault();
                this.click();
            }
        });
    }
    
    // Add escape key handler for search dialog
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            const searchToggle = document.querySelector('[data-md-toggle="search"]');
            const searchInput = document.querySelector('.md-search__input');
            
            if (searchInput && document.activeElement === searchInput) {
                searchToggle.click();
            }
        }
    });
    
    console.log('Vitistack accessibility enhancements loaded');
});
