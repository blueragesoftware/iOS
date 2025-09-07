# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project description

We creating the next generation of automation through an AI agents execution
environment. We believe that instead of complex programming, users simply describe what they want accomplished, and our platform handles the rest. A declartive approach. Anyone can create AI agents by connecting their existing applications via tools and assembling a workflow. These agents run automatically based on schedules or triggers, and can be easily shared.
Our iOS app makes it seamless to share content with your agents and trigger workflows on-the-go. We serve both consumers looking to automate personal tasks and businesses needing regular automation. It's a platform designed for rapid experimentation—launch small automation ideas, see what works, and iterate quickly.

## Build & Development Commands

### Project Setup
```bash
# Initial setup (installs SwiftLint and pre-commit hooks)
make setup

# Generate Xcode project files with Tuist
tuist generate

# Open the project in Xcode
tuist edit
```

### Build Commands
```bash
# Build the project
tuist build

# Clean build artifacts
tuist clean

# Warm cache for faster builds
tuist cache
```

### Code Quality
```bash
# Run SwiftLint
swiftlint ./AgentOS/ --fix --strict

# Analyze with SwiftLint (includes more thorough checks)
swiftlint analyze ./AgentOS/
```

### Testing
```bash
# Run tests
tuist test
```

## Architecture

### Project Structure
The project follows a modular architecture with clear separation of concerns:

- **AgentOS/Sources/Kit/Core/**: Core functionality, utilities, and dependency injection setup
  - Dependencies are defined using Factory pattern (e.g., `Posthog+Dependency.swift`)
- **AgentOS/Sources/UI/**: SwiftUI views and app lifecycle management
  - `AgentOSApp.swift`: Main app entry point with AppDelegate for service setup
  - Views follow SwiftUI patterns with preview providers

### Dependency Management
- Uses Tuist for managing Swift Package Manager dependencies (defined in `Tuist/Package.swift`)
- Key dependencies:
  - **ConvexMobile**: Backend integration
  - **Factory**: Dependency injection
  - **Nuke**: Image loading
  - **PinLayout**: Layout engine
  - **PostHog**: Analytics
  - **Sentry**: Crash reporting
  - **Shimmer**: Loading animations

### Dependency Injection Pattern
Dependencies are injected using Factory:
```swift
@Injected(\.postHog) private var postHog
```

Dependencies are defined in extension files following the pattern: `{ServiceName}+Dependency.swift`

### Environment Configuration
The project uses environment variables for sensitive data:
- `POSTHOG_API_KEY`: PostHog analytics key
- `POSTHOG_HOST`: PostHog server URL (default: https://us.i.posthog.com)
- `SENTRY_DSN`: Sentry crash reporting DSN

These are configured in the Tuist scheme (`Project.swift`) and should be set in the development environment.

### Code Style
- SwiftLint is configured with strict mode
- Pre-commit hooks automatically run SwiftLint with `--fix --strict` on all files in `AgentOS/`
- Nesting type level is limited to 3 (configured in `.swiftlint.yml`)

### Build Configuration
- Deployment target: iOS 17.0
- Bundle ID: com.ertembiyik.AgentOS
- Version management: Uses `agvtool` for automatic version bumping on archive

## Important Notes

- The project uses Tuist for project generation - never modify `.xcodeproj` files directly
- All Swift code should pass SwiftLint's strict mode
- Services initialization happens in AppDelegate (PostHog, Sentry)
- The app is in early development with authentication infrastructure being built using ConvexMobile
