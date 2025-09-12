# Default target
all: setup

# Check SwiftLint installation
check-swiftlint:
	@echo "Checking SwiftLint..."
	@if ! command -v swiftlint &> /dev/null; then \
		echo "❌ SwiftLint is not installed. Please install it with: brew install swiftlint"; \
		exit 1; \
	else \
		echo "✅ SwiftLint is installed"; \
	fi

# Install git hooks
install-git-hooks:
	@echo "Installing git hooks..."
	@cd "$(shell git rev-parse --show-toplevel)" && \
		rsync -a scripts/git-hooks/ "$$(git rev-parse --git-path hooks)/"
	@echo "✅ Git hooks installed successfully!"

# Check swift-package-list installation
check-swift-package-list:
	@echo "Checking swift-package-list..."
	@if ! command -v swift-package-list &> /dev/null; then \
		echo "❌ swift-package-list is not installed. Please install it with:"; \
		echo "   brew tap FelixHerrmann/tap"; \
		echo "   brew install swift-package-list"; \
		exit 1; \
	else \
		echo "✅ swift-package-list is installed"; \
	fi

# Generate Settings.bundle with package licenses
generate-licenses: check-swift-package-list
	@echo "Generating Settings.bundle with package licenses..."
	swift-package-list Tuist/Package.swift --custom-source-packages-path Tuist/.build --output-type settings-bundle --requires-license --output-path "Bluerage/Supporting\ Files/"
	@echo "✅ Generated Settings.bundle at Bluerage/Supporting Files/"

# Install Tuist dependencies
tuist-install:
	@echo "Installing Tuist dependencies..."
	tuist install
	@echo "✅ Tuist dependencies installed"

# Generate Xcode project with Tuist
tuist-generate:
	@echo "Generating Xcode project with Tuist..."
	tuist generate
	@echo "✅ Xcode project generated"

# Main setup target that checks dependencies and sets up hooks
setup: check-swiftlint install-git-hooks tuist-install tuist-generate
	@echo "Setup completed successfully! 🚀"

.PHONY: all setup check-swiftlint install-git-hooks check-swift-package-list generate-licenses tuist-install tuist-generate
