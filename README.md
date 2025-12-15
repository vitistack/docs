# Vitistack Documentation

Welcome to the Vitistack documentation repository! This site is built with MkDocs Material and features a custom accessibility-focused theme.

## 🚀 Quick Start

### Development
```bash
# Setup Python virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install --upgrade pip
pip install -r mkdocs-requirements.txt
npm install

# Serve locally
mkdocs serve

# or with live reload
mkdocs serve --livereload

# Build for production
mkdocs build
```

### Testing
```bash
# Run accessibility tests (automatically sets up venv)
./test-accessibility.sh

# Manual setup with venv
source venv/bin/activate
npm run test:axe
npm run test:pa11y
npm run test:lighthouse
```

## ✨ Features

- **Custom Viti Theme**: Brand-aligned colors and styling
- **Accessibility First**: WCAG 2.1 AA compliant
- **Dark Mode Support**: Full theme with accessibility considerations
- **Responsive Design**: Mobile-first approach
- **CI/CD Pipeline**: Automated accessibility testing

## 🔍 Accessibility

This documentation is built with accessibility as a core principle:

- ✅ WCAG 2.1 AA compliance
- ✅ Screen reader support
- ✅ Keyboard navigation
- ✅ High contrast mode
- ✅ Reduced motion support

For detailed information about our accessibility features and testing, see [ACCESSIBILITY.md](ACCESSIBILITY.md).

## 🛠️ Technology Stack

- **Static Site Generator**: MkDocs
- **Theme**: Material for MkDocs (customized)
- **Accessibility Testing**: Axe Core, Pa11y, Lighthouse
- **CI/CD**: GitHub Actions
- **Hosting**: GitHub Pages

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run accessibility tests: `./test-accessibility.sh`
5. Submit a pull request

All contributions are automatically tested for accessibility compliance.

## 📄 License

This project is licensed under the terms specified in the [LICENSE](LICENSE) file.