import UIKit
import PostHog
import FactoryKit
import Sentry

final class AppDelegate: NSObject, UIApplicationDelegate {

    @Injected(\.postHog) private var postHog

    @Injected(\.env) private var env

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        self.setUpSentry()

        self.setUpPostHog()

        return true
    }

    private func setUpSentry() {
        SentrySDK.start { options in
            print("SENTRY_DSN: " + self.env.SENTRY_DSN)
            options.dsn = self.env.SENTRY_DSN

            options.sendDefaultPii = true
            options.enableMetricKit = true

#if DEBUG
            options.environment = "debug"
#endif
        }
    }

    private func setUpPostHog() {
        let config = PostHogConfig(apiKey: self.env.POSTHOG_API_KEY, host: self.env.POSTHOG_HOST)

        config.captureScreenViews = true
        config.captureApplicationLifecycleEvents = true

        self.postHog.setup(config)
    }

}
