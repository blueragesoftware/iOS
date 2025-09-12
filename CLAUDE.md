This file provides guidance to Claude Code (claude.ai/code) when working with
code in this repository.

# Project description

We creating the next generation of automation through an AI agents execution
environment. We believe that instead of complex programming, users simply
describe what they want accomplished, and our platform handles the rest. A
declartive approach. Anyone can create AI agents by connecting their existing
applications via tools and assembling a workflow. These agents run automatically
based on schedules or triggers, and can be easily shared. Our iOS app makes it
seamless to share content with your agents and trigger workflows on-the-go. We
serve both consumers looking to automate personal tasks and businesses needing
regular automation. It's a platform designed for rapid experimentation—launch
small automation ideas, see what works, and iterate quickly.

# Build & Development Commands

## Project Setup

```bash
# Initial setup (installs SwiftLint and pre-commit hooks)
make setup

# Install dependencies 
tuist install

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
swiftlint ./Bluerage/ --fix --strict

# Analyze with SwiftLint (includes more thorough checks)
swiftlint analyze ./Bluerage/
```

## Testing

```bash
# Run tests
tuist test
```

# Coding Style Guide

## General Principles

- **Explicit over implicit**: Always prefer explicit code that clearly shows
  intent
- **Single responsibility**: Each class/struct should have one clear purpose
- **Dependency injection**: Use FactoryKit (Swift package) for DI, never global
  singletons
- **Error handling**: Prefer `do-catch` over returning `nil`, never make
  throwing methods that return optionals
- **Async patterns**: Use Swift concurrency over GCD/Combine when possible
- **Always use explicit `self.`** in all method calls and property access

### File Naming Conventions

- **UIKit ViewControllers**: `{Name}Controller` (e.g., `WelcomeController`)
- **SwiftUI Views**: `{Name}View` (e.g., `LoginView`)
- **ViewModels**: `{Name}ViewModel` (e.g., `LoginViewModel`)
- **Extensions**: `{Target}+{Purpose}.swift` (e.g., `PlaceholderView+Ext.swift`)
- **Dependencies**: `{ServiceName}+Dependency.swift`
- **Use camelCase for all Swift/Objective-C naming**

### Project Structure

```
Sources/
├── Core/                    # Shared code, DI, extensions
├── Kit/               # Services, single source of truth
├── Generated/              # OpenAPI generations
└── UI/
    ├── Components/         # Reusable UI components
    └── Screens/           # Individual screens
Resources/                  # Assets, strings, etc.
```

### Code Organization Within Files

**Order of declarations:**

1. `open static` declarations
2. `open` declarations
3. `public static` declarations
4. `public` declarations
5. `internal static` declarations
6. `internal` declarations
7. `private static` declarations
8. `private` declarations

**UIKit ViewController structure:**

```swift
final class ExampleController: UIViewController {

    // MARK: - Properties
    
    private let containerView = UIView(frame: .zero)
    
    @Injected(\.authSession) private var authSession

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.containerView)
        
        self.setUpSelf()
        self.setUpContainerView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.containerView.pin
            .all()
    }

    // MARK: - Setup
    
    private func setUpSelf() {
        self.view.backgroundColor = UIColor.res.black
    }
    
    private func setUpContainerView() {
        // View setup code
    }

    // MARK: - Actions
    
    private func didTapButton() {
        // Action handling
    }

}
```

### Swift Coding Patterns

**Always use explicit `self.`:**

```swift
// ✅ Preferred
self.view.addSubview(self.containerView)
self.setUpViews()

// ❌ Avoid
view.addSubview(containerView)
setUpViews()
```

**Prefer guard statements over if-let:**

```swift
// ✅ Preferred
guard let userId = self.authSession.state.userId else {
    return
}

// ❌ Avoid
if let userId = self.authSession.state.userId {
    // continue with logic
}
```

**Use do-catch for error handling:**

```swift
// ✅ Preferred
do {
    let result = try await service.fetchData()
    // handle result
} catch {
    Logger.domain.error("Error fetching data: \(error)")
}

// ❌ Never do this
func fetchData() throws -> Result? {
    // Don't make throwing methods return optionals
}
```

### SwiftUI Architecture & Patterns

**Use MVVM + State with Observation:**

- NEVER use ObservableObject

```swift
@MainActor
@Observable
final class ExampleViewModel {
    enum State {
        case skeleton
        case loaded(data: [Item])
        case empty
        case error(Error)
    }
    
    private(set) var state: State = .skeleton
    
    @ObservationIgnored
    @Injected(\.dataService) private var dataService
    
    func loadData() async {
        withAnimation {
            self.state = .skeleton
        }
        
        do {
            let data = try await self.dataService.fetchData()
            withAnimation {
                self.state = data.isEmpty ? .empty : .loaded(data: data)
            }
        } catch {
            withAnimation {
                self.state = .error(error)
            }
        }
    }
}
```

**SwiftUI View structure - Use separate views for performance:**

```swift
struct ExampleView: View {

    @State private var viewModel = ExampleViewModel()
    
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            self.content
                .onFirstAppear {
                    Task {
                        await self.viewModel.loadData()
                    }
                }
        }
    }

@ViewBuilder
    var content: some View {
        switch self.viewModel.state {
        case .skeleton:
            ExampleSkeletonView()
        case .loaded(let data):
            ExampleLoadedView(data: data)
        case .empty:
            ExamplePlaceholderView()
        case .error:
            ExampleErrorView()
        }
    }

}

// Separate view files for each state
struct ExampleSkeletonView: View {
    
    var body: some View {
        // Skeleton implementation
    }
    
}

struct ExampleLoadedView: View {
    
    let data: [Item]
    
    var body: some View {
        // Loaded content implementation
    }
    
}

struct ExamplePlaceholderView: View {
    
    var body: some View {
        // Empty state implementation
    }
    
}

struct ExampleErrorView: View {
    
    var body: some View {
        // Error state implementation
    }
    
}
```

**SwiftUI View structure - Use different ViewModel for nested views if an action
can be performed inside it:**

```swift
// AgentScreenViewModel
@MainActor
@Observable
final class AgentScreenViewModel {

    enum State {
        case loading
        case loaded(AgentLoadedViewModel)
        case error(Error)
    }

    private(set) var state: State = .loading

    ...
}
```

```swift
struct AgentScreenView: View { 
    ...

    var body: some View {
        self.content
            .onFirstAppear {
                self.viewModel.connect()
            }
            .navigationDestination(AgentDestinations.self)
            .postHogScreenView("AgentScreenView", ["agentId": self.agentId])
    }

    @ViewBuilder
    private var content: some View {
        switch self.viewModel.state {
        case .loading:
            LoadingView()
                .transition(.blurReplace)
        case .loaded(let loadedViewModel):
            AgentLoadedView(viewModel: loadedViewModel)
                .transition(.blurReplace)
        case .error:
            PlaceholderView.error {
                self.viewModel.connect()
            }
            .transition(.blurReplace)
        }
    }
}
```

**State management rules:**

- Use `@State` for local view state only
- Inject dependencies using FactoryKit
- Share global state through Sessions (single source of truth)
- Each ViewModel holds only its own state
- **Prefer smaller views over computed properties** for better performance
- **One class/struct per file** (except for ViewModels' State enums)

### Dependency Injection with FactoryKit

**Setting up dependencies:**

```swift
// AuthSession+Dependency.swift
extension Container {
    var authSession: Factory<AuthSession> {
        self { 
          AuthSessionImpl() 
        }.cached
    }
}
```

**Using dependencies:**

```swift
// In UIKit ViewControllers
@Injected(\.authSession) private var authSession

// In SwiftUI ViewModels
@ObservationIgnored
@Injected(\.authSession) private var authSession
```

**Session pattern for global state:**

```swift
protocol AuthSession: Sendable {

    var accessToken: String { get async throws }

    var state: AuthSessionState { get }

    var statePublisher: AnyPublisher<AuthSessionState, Never> { get }
    
    func start()

    func signInWithApple(idToken: String) async throws

    func logout() async throws

}

enum AuthSessionState: Sendable, Equatable {
    case loggedIn(userId: String)
    case loggedOut
}
```

### Logging Strategy

**Domain-based logging setup:**

```swift
// Logger+Category.swift in Sources/Core
extension Logger {

    static let miniApps = Logger(subsystem: Self.subsystem, category: "miniApps")

    static let login = Logger(subsystem: Self.subsystem, category: "login")

    static let explore = Logger(subsystem: Self.subsystem, category: "explore")

    static let galilei = Logger(subsystem: Self.subsystem, category: "galilei")

    static let root = Logger(subsystem: Self.subsystem, category: "root")

}
```

**Usage:**

```swift
Logger.login.error("Authentication failed: \(error.localizedDescription, privacy: .public)")
Logger.miniApps.info("Loading mini apps for user: \(userId, privacy: .private)")
```

**Logging rules:**

- Each screen/feature gets its own domain
- In multi-package projects, use one domain per package
- Always consider privacy levels for logged data

### Extensions & Custom Components

**SwiftUI extensions:**

```swift
// PlaceholderView+Ext.swift in Sources/Core
extension PlaceholderView where ButtonLabel == AnyView {

    static func error(action: @escaping () -> Void) -> some View {
        PlaceholderView(
            image: UIImage(named: "issue_placeholder_icon_100")!,
            title: "An issue happened",
            description: "Try refreshing the page or come back later"
        ) {
            action()
        } buttonLabel: {
            AnyView(Text("Refresh")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(UIColor.label.swiftUI)
                .padding(.vertical, 8)
                .padding(.horizontal, 20)
                .fixedSize())
        }
        .buttonStyle(.borderGradientSecondaryButtonStyle)
    }

}
```

### Navigation

**Use NavigatorUI library:**

```swift
import SwiftUI
import NavigatorUI

struct AgentScreenView: View {

    private let agentId: String

    @State private var viewModel: AgentScreenViewModel

    init(agentId: String) {
        self.agentId = agentId
        self.viewModel = AgentScreenViewModel(agentId: agentId)
    }

    var body: some View {
        self.content
            .onFirstAppear {
                self.viewModel.connect()
            }
            .navigationDestination(AgentDestinations.self)
            .postHogScreenView("AgentScreenView", ["agentId": self.agentId])
    }

    @ViewBuilder
    private var content: some View {
        switch self.viewModel.state {
        case .loading:
            LoadingView()
                .transition(.blurReplace)
        case .loaded(let loadedViewModel):
            AgentLoadedView(viewModel: loadedViewModel)
                .transition(.blurReplace)
        case .error:
            PlaceholderView.error {
                self.viewModel.connect()
            }
            .transition(.blurReplace)
        }
    }

}
```

```swift
import SwiftUI
import NavigatorUI

enum AgentDestinations: NavigationDestination {

    case executionsList(agentId: String)
    case toolsSelection(agentToolsSlugSet: Set<String>, callback: Callback<Tool>)

    var body: some View {
        switch self {
        case .executionsList(let agentId):
            ExecutionsListScreenView(agentId: agentId)
        case .toolsSelection(let agentToolsSlugSet, let callback):
            ToolsSelectionScreenView(agentToolsSlugSet: agentToolsSlugSet, onToolSelected: callback.handler)
        }
    }

    var method: NavigationMethod {
        switch self {
        case .executionsList:
            return .push
        case .toolsSelection:
            return .sheet
        }
    }

}
```

### Layout with PinLayout (UIKit)

**Layout in viewDidLayoutSubviews:**

```swift
override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    self.logoImageView.pin
        .size(CGSize(width: 174, height: 174))
        .top()
    
    self.titleLabel.pin
        .below(of: self.logoImageView, aligned: .center)
        .marginTop(20)
        .sizeToFit()
    
    self.continueButton.pin
        .horizontally(20)
        .bottom(self.view.pin.safeArea.bottom)
        .height(58)
}
```

### Swift Tools & Configuration

**Package Management:**

- **Tuist** for managing Swift Package Manager dependencies (defined in
  `Tuist/Package.swift`)

**Code Quality:**

- **SwiftLint** for formatting and style enforcement

**Key Libraries:**

- **Observation**: For passing data between ViewModel and View
- **FactoryKit**: Dependency injection (Swift package)
- **PinLayout**: UIKit frame-based layouts
- **Nuke**: Image loading
- **Convex**: Backend
- **PostHog**: Analytics
- **Sentry**: Observing
- **Clerk**: Authentication
- **Navigator**: Navigator

### Resources & Styling

**Resource access patterns:**

Use tuist generated synthesized files

```swift
// Strings
Text(BluerageStrings.agentAboutSectionHeader)

// Fonts
Text(BluerageStrings.loginTitle)
    .font(BluerageFontFamily.InstrumentSerif.regular.swiftUIFont(size: 60))

// Images
BluerageAsset.Assets.bluerageLoadingIcon164.swiftUIImage
    .resizable()

PlaceholderView(imageName: BluerageAsset.Assets.emptyPlaceholderIcon100.name,
                title: BluerageStrings.customModelsEmptyTitle,
                description: BluerageStrings.customModelsEmptyDescription)

// Bundle
guard let object = Bundle.module.object(forInfoDictionaryKey: key) else {
    throw Error.missingKey(key)
}
```

### Style Guide Compliance

**Follow
[Google Objective-C Style Guide](https://google.github.io/styleguide/objcguide.html):**

**Method naming:**

```swift
// ✅ Preferred - Descriptive method names
func setUpNavigationBar()
func handleUserDidTapButton()
func loadDataFromServer()

// ❌ Avoid - Abbreviated or unclear names
func setupNavBar()
func handleTap()
func loadData()
```

**Variable naming:**

```swift
// ✅ Preferred - Clear, descriptive names
private let userProfileImageView = UIImageView()
private let primaryActionButton = UIButton()
private let networkConnectionManager = NetworkManager()

// ❌ Avoid - Abbreviated or unclear names
private let imgView = UIImageView()
private let btn = UIButton()
private let netMgr = NetworkManager()
```

**Code organization principles:**

- Group related functionality together
- Use MARK comments to organize sections
- Keep methods focused and single-purpose
- Prefer explicit code over clever shortcuts
