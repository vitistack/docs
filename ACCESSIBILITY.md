# Accessibility Testing

This project includes comprehensive accessibility testing to ensure our documentation meets WCAG 2.1 AA standards and provides an inclusive experience for all users.

## 🔍 Testing Tools

Our accessibility testing pipeline uses multiple industry-standard tools:

### 1. **Axe Core**
- **Purpose**: Automated accessibility testing engine
- **Coverage**: WCAG 2.0/2.1 guidelines, best practices
- **Focus**: Color contrast, ARIA labels, keyboard navigation

### 2. **Pa11y**
- **Purpose**: Command-line accessibility testing tool
- **Coverage**: HTML_CodeSniffer rules, WCAG 2.1 AA
- **Focus**: Semantic HTML, heading structure, form labels

### 3. **Lighthouse**
- **Purpose**: Google's web quality auditing tool
- **Coverage**: Accessibility, performance, SEO, best practices
- **Focus**: Progressive enhancement, mobile accessibility

### 4. **HTML_CodeSniffer**
- **Purpose**: Client-side accessibility auditing
- **Coverage**: WCAG 2.0/2.1, Section 508
- **Focus**: Code quality, standards compliance

## 🚀 Running Tests

### Automated (CI/CD)
Accessibility tests run automatically on:
- **Pull Requests**: Provides feedback on accessibility impacts
- **Main Branch**: Ensures deployment meets accessibility standards

### Local Development
```bash
# Run all accessibility tests (automatically sets up venv)
./test-accessibility.sh

# Or manually with virtual environment
python3 -m venv venv
source venv/bin/activate
pip install -r mkdocs-requirements.txt
npm install

# Run individual tools
npm run test:axe      # Axe Core tests
npm run test:pa11y    # Pa11y tests
npm run test:lighthouse # Lighthouse audit
```

### Prerequisites
- Node.js 16+
- Python 3.7+
- Virtual environment support (venv module)

## 📊 Test Results

### CI Pipeline Results
- Results are posted as comments on pull requests
- Detailed reports are available as workflow artifacts
- Failed tests block deployment to prevent accessibility regressions

### Local Results
- Terminal output shows pass/fail status
- Detailed JSON reports generated for each tool
- Lighthouse generates HTML reports with visual insights

## 🎯 Accessibility Standards

Our documentation targets:

### WCAG 2.1 AA Compliance
- ✅ **Perceivable**: Color contrast ≥ 4.5:1, alt text for images
- ✅ **Operable**: Keyboard navigation, focus indicators
- ✅ **Understandable**: Clear language, consistent navigation
- ✅ **Robust**: Valid HTML, ARIA landmarks

### Key Features
- **High Contrast Mode**: Supports OS-level high contrast settings
- **Reduced Motion**: Respects user's motion preferences
- **Screen Reader Support**: Semantic HTML with proper ARIA labels
- **Keyboard Navigation**: Full site navigation without mouse
- **Touch Targets**: Minimum 44px touch targets for mobile
- **Print Accessibility**: Optimized for screen reader printing

## 🛠️ Accessibility Features in Theme

### Focus Management
```css
/* Enhanced focus indicators */
*:focus {
  outline: 2px solid var(--viti-secondary);
  outline-offset: 2px;
}
```

### Skip Links
- Hidden skip-to-content links for keyboard users
- Jump navigation for screen readers

### Color Contrast
- All text meets WCAG AA contrast ratios (4.5:1)
- High contrast mode support for enhanced visibility

### Responsive Design
- Mobile-first approach ensures accessibility across devices
- Touch targets meet minimum size requirements

## 🐛 Common Issues & Solutions

### Color Contrast
```css
/* Good: High contrast text */
.text { color: #1e293b; background: #ffffff; } /* 16.75:1 ratio */

/* Bad: Low contrast text */
.text { color: #94a3b8; background: #ffffff; } /* 2.53:1 ratio */
```

### Focus Indicators
```css
/* Good: Visible focus ring */
button:focus { outline: 2px solid #2563eb; }

/* Bad: Removed focus styles */
button:focus { outline: none; }
```

### Alt Text
```markdown
<!-- Good: Descriptive alt text -->
![Screenshot of the main dashboard showing user analytics](dashboard.png)

<!-- Bad: Generic alt text -->
![Image](dashboard.png)
```

## 📈 Continuous Improvement

### Regular Audits
- Monthly accessibility reviews
- User testing with assistive technologies
- Performance monitoring of accessibility features

### Community Feedback
- Accessibility issues can be reported via GitHub issues
- We welcome contributions to improve accessibility

### Training Resources
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [MDN Accessibility](https://developer.mozilla.org/en-US/docs/Web/Accessibility)
- [WebAIM Resources](https://webaim.org/)

## 🤝 Contributing

When contributing to the documentation:

1. **Run accessibility tests** before submitting PRs
2. **Include alt text** for all images
3. **Use semantic HTML** (headings, lists, landmarks)
4. **Test keyboard navigation** on your changes
5. **Check color contrast** for any custom styling

The CI pipeline will automatically test your changes and provide feedback on any accessibility issues.
