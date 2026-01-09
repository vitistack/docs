##@ Help
.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Development
.PHONY: serve
serve: ## Start mkdocs development server with live reload
	mkdocs serve --livereload

.PHONY: serve-no-reload
serve-no-reload: ## Start mkdocs development server without live reload
	mkdocs serve

##@ Build
.PHONY: build
build: ## Build the documentation for production
	mkdocs build

##@ Setup
.PHONY: setup
setup: ## Setup Python virtual environment and install dependencies
	python3 -m venv venv
	. venv/bin/activate && pip install --upgrade pip && pip install -r mkdocs-requirements.txt
	npm install
	@echo ""
	@echo "Setup complete! To activate the virtual environment, run:"
	@echo "  source venv/bin/activate"
