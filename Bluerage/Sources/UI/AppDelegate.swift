import UIKit
import PostHog
import FactoryKit
import Sentry
import Clerk
import OSLog
import Nuke
import Knock

final class AppDelegate: KnockAppDelegate {

    @Injected(\.postHog) private var postHog

    @Injected(\.clerk) private var clerk

    @Injected(\.env) private var env

    @Injected(\.authSession) private var authSession

    @Injected(\.knockManager) private var knockManager

    override func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        self.setUpClerk()

        self.setUpKnock()

        self.setUpSentry()

        self.setUpPostHog()

        self.setUpAuthSession()

        self.setUpNuke()

        self.setUpBarButtonTintColor()

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    override func pushNotificationTapped(userInfo: [AnyHashable: Any]) {
        super.pushNotificationTapped(userInfo: userInfo)

        if let deeplink = userInfo["link"] as? String, let url = URL(string: deeplink) {
            UIApplication.shared.open(url)
        }
    }

    override func pushNotificationDeliveredInForeground(notification: UNNotification) -> UNNotificationPresentationOptions {
        let options = super.pushNotificationDeliveredInForeground(notification: notification)

        return [options]
    }

    private func setUpClerk() {
        self.clerk.configure(publishableKey: self.env.CLERK_PUBLISHABLE_KEY)

        Task {
            do {
                try await self.clerk.load()
            } catch {
                Logger.default.error("Error loading clerk: \(error.localizedDescription, privacy: .public)")
            }
        }
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

    private func setUpKnock() {
        self.knockManager.start()

        Task {
            do {
                try await self.knockManager.setup(publishableKey: self.env.KNOCK_PUBLISHABLE_KEY,
                                           pushChannelId: self.env.KNOCK_CHANNEL_ID)
            } catch {
                Logger.knockManager.error("Error setting up remote notifications: \(error.localizedDescription, privacy: .public)")
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

    private func setUpBarButtonTintColor() {
        UIBarButtonItem.appearance().tintColor = .label
    }

}
