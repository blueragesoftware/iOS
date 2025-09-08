import SwiftUI
import NavigatorUI

@main
struct AgentOSApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    private let navigator: Navigator = {
        let configuration: NavigationConfiguration = .init(
            verbosity: .info
        )

        return Navigator(configuration: configuration)
    }()

    var body: some Scene {
        WindowGroup {
            RootScreenView()
                .navigationRoot(self.navigator)
                .accentColor(.primary)
        }
    }

}
