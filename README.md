# AgentOS iOS

A native iOS application for managing and interacting with AI agents on the go.

## Prerequisites

- macOS 14+ with Xcode 15+
- [Tuist](https://tuist.io) for project generation
- Swift 5.9+

## Installation

1. Clone the repository and install Tuist:

```bash
git clone https://github.com/AgentOSS/iOS
cd iOS
curl -Ls https://install.tuist.io | bash
```

2. Install project dependencies:

```bash
tuist install
```

## Environment Setup

1. Generate the Xcode project with your bundle identifier:

```bash
TUIST_BUNDLE_ID=com.yourcompany.AgentOS tuist generate
```

2. Configure environment variables for services (optional):
   - `POSTHOG_API_KEY` - PostHog analytics key
   - `POSTHOG_HOST` - PostHog server URL (default: https://us.i.posthog.com)
   - `SENTRY_DSN` - Sentry crash reporting DSN

## Local Development

1. Generate and open the project:

```bash
TUIST_BUNDLE_ID=com.yourcompany.AgentOS tuist generate
open AgentOS.xcworkspace
```

2. Build and run the project in Xcode (⌘+R)

## Project Structure

```
AgentOS/
├── Sources/
│   ├── Kit/Core/        # Core functionality and dependency injection
│   └── UI/              # SwiftUI views and app lifecycle
├── Resources/           # Assets, strings, and configuration
└── Tuist/              # Tuist configuration and dependencies
```

## Build Commands

### Development
- `tuist generate` - Generate Xcode project files
- `tuist build` - Build the project from command line
- `tuist test` - Run unit tests
- `tuist clean` - Clean build artifacts
- `tuist cache` - Warm cache for faster builds

### Code Quality
- `swiftlint ./AgentOS/ --fix --strict` - Run and fix SwiftLint issues
- `swiftlint analyze ./AgentOS/` - Perform deeper code analysis

### Initial Setup
- `make setup` - Install SwiftLint and configure pre-commit hooks

## Architecture

### Dependency Management

The project uses Tuist for managing Swift Package Manager dependencies. Key dependencies include:
- **ConvexMobile** - Backend integration
- **Factory** - Dependency injection
- **Nuke** - Image loading
- **PostHog** - Analytics
- **Sentry** - Crash reporting

### Dependency Injection

Dependencies are injected using Factory pattern:

```swift
@Injected(\.postHog) private var postHog
```

Dependencies are defined in `AgentOS/Sources/Kit/Core/` following the pattern: `{ServiceName}+Dependency.swift`

### Code Style

- SwiftLint is configured with strict mode
- Pre-commit hooks automatically run SwiftLint
- Follow the coding guidelines in `CLAUDE.md`

## Configuration

### Build Settings

- Deployment Target: iOS 17.0+
- Swift Version: 5.9
- Bundle ID: Configurable via `TUIST_BUNDLE_ID` environment variable

### Environment Variables

Set these in your development environment or CI/CD pipeline:
- `TUIST_BUNDLE_ID` - Your app's bundle identifier (required)
- `POSTHOG_API_KEY` - Analytics tracking
- `POSTHOG_HOST` - Analytics server
- `SENTRY_DSN` - Crash reporting

## Troubleshooting

### Tuist Issues

1. Clear Tuist cache and regenerate:
   ```bash
   tuist clean
   rm -rf Derived/
   TUIST_BUNDLE_ID=com.yourcompany.AgentOS tuist generate
   ```

2. Update Tuist to latest version:
   ```bash
   tuist update
   ```

### Build Issues

1. Clean build folder in Xcode: Product → Clean Build Folder (⇧⌘K)

2. Reset Swift Package Manager cache:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   rm -rf .build/
   ```

### SwiftLint Issues

1. Install or update SwiftLint:
   ```bash
   brew install swiftlint
   # or
   brew upgrade swiftlint
   ```

2. Run SwiftLint with auto-fix:
   ```bash
   swiftlint ./AgentOS/ --fix --strict
   ```

## Support

For issues or questions:

1. Check the [Tuist documentation](https://docs.tuist.io/)
2. Review existing issues in the repository
3. Open a new issue with detailed information

## License

Apache License 2.0