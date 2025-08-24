import SwiftUI
import UIKit
import PostHog
import Factory
import Sentry

final class AppDelegate: NSObject, UIApplicationDelegate {

    @Injected(\.postHog) private var postHog

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        self.setUpSentry()

        self.setUpPostHog()

        return true
    }

    private func setUpSentry() {
        SentrySDK.start { options in
            options.dsn = "get dsn"

            options.sendDefaultPii = true
            options.enableMetricKit = true

#if DEBUG
            options.environment = "debug"
#endif
        }
    }

    private func setUpPostHog() {
        let POSTHOG_API_KEY = "get posthog url"
        let POSTHOG_HOST = "https://us.i.posthog.com"

        let config = PostHogConfig(apiKey: POSTHOG_API_KEY, host: POSTHOG_HOST)

        config.captureScreenViews = true
        config.captureApplicationLifecycleEvents = true

        self.postHog.setup(config)
    }

}

@main
struct AgentOSApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

}
