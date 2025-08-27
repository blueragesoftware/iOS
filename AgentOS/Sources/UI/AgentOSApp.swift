import SwiftUI

@main
struct AgentOSApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            AgentsListScreenView()
                .accentColor(.primary)
        }
    }

}
