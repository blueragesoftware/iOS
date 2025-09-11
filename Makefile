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

# Check and setup pre-commit hooks
check-precommit:
	@echo "Checking pre-commit..."
	@if ! command -v pre-commit &> /dev/null; then \
		echo "❌ pre-commit is not installed. Please install it with: pipx install pre-commit"; \
		exit 1; \
	else \
		echo "✅ pre-commit is installed"; \
	fi
	@echo "Installing pre-commit hooks..."
	@pre-commit install

# Main setup target that checks dependencies and sets up hooks
setup: check-swiftlint check-precommit
	@echo "Setup completed successfully! 🚀"

.PHONY: all setup check-swiftlint check-precommit
