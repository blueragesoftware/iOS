import UIKit
import PostHog
import FactoryKit
import Sentry
import Clerk
import OSLog
import Nuke

final class AppDelegate: NSObject, UIApplicationDelegate {

    @Injected(\.postHog) private var postHog

    @Injected(\.clerk) private var clerk

    @Injected(\.env) private var env

    @Injected(\.authSession) private var authSession

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        self.setUpClerk()

        self.setUpSentry()

        self.setUpPostHog()

        self.setUpAuthSession()

        self.setUpNuke()

        return true
    }

    private func setUpSentry() {
        SentrySDK.start { options in
            options.dsn = self.env.SENTRY_DSN

            options.sendDefaultPii = true
            options.enableMetricKit = true

#if DEBUG
            options.environment = "debug"
#endif
        }
    }

    private func setUpClerk() {
        self.clerk.configure(publishableKey: self.env.CLERK_PUBLISHABLE_KEY)

        Task {
            do {
                try await self.clerk.load()
            } catch {
                Logger.default.error("Error loading clerk: \(error.localizedDescription)")
            }
        }
    }

    private func setUpPostHog() {
        let config = PostHogConfig(apiKey: self.env.POSTHOG_API_KEY, host: self.env.POSTHOG_HOST)

        config.captureScreenViews = true
        config.captureApplicationLifecycleEvents = true

        self.postHog.setup(config)
    }

    private func setUpAuthSession() {
        self.authSession.start()
    }

    private func setUpNuke() {
        ImageDecoders.registerSVGDecoder()
    }

}
