# Default target
all: setup

# Install SwiftLint using Homebrew
install-swiftlint:
	@echo "Installing SwiftLint..."
	@if ! command -v swiftlint &> /dev/null; then \
		brew install swiftlint; \
	else \
		echo "SwiftLint is already installed"; \
	fi

# Install pre-commit hooks
install-precommit:
	@echo "Installing pre-commit hooks..."
	@if ! command -v pipx &> /dev/null; then \
		echo "pipx not found. Installing pipx..."; \
		brew install pipx; \
		pipx ensurepath; \
	else \
		echo "pipx is already installed"; \
	fi
	@if ! command -v pre-commit &> /dev/null; then \
		pipx install pre-commit; \
	else \
		echo "pre-commit is already installed"; \
	fi
	@pre-commit install

# Main setup target that runs all installation steps
setup: install-swiftlint install-precommit
	@echo "Setup completed successfully! 🚀"

.PHONY: all setup install-swiftlint install-precommit
