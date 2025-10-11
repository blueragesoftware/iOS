import UIKit
import Knock
import FactoryKit
import OSLog
import Sentry
import PostHog
import Nuke
import SwiftUI
import NavigatorUI

@main
struct BluerageApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @Injected(\.postHog) private var postHog

    @Injected(\.clerk) private var clerk

    @Injected(\.env) private var env

    @Injected(\.authSession) private var authSession

    @Injected(\.knock) private var knock

    @Injected(\.notificationsManager) private var notificationsManager

    @Injected(\.convex) private var convex

    private let authObserver = AuthObserver()

    private let navigator: Navigator = {
        let configuration: NavigationConfiguration = .init(
            verbosity: .info
        )

        return Navigator(configuration: configuration)
    }()

    init() {
        self.setUpClerk()

        self.setUpKnock()

        self.setUpSentry()

        self.setUpPostHog()

        self.setUpAuthObserver()

        self.setUpAuthSession()

        self.setUpNuke()

        self.setUpBarButtonTintColor()
    }

    var body: some Scene {
        WindowGroup {
            RootScreenView()
                .onNavigationOpenURL(MCPOAuthURLHandler())
                .navigationRoot(self.navigator)
                .tint(.primary)
                .onReceive(NotificationCenter.default.publisher(for: UIScene.willConnectNotification)) { notification in
                    guard let userInfo = notification.userInfo else {
                        return
                    }

                    self.handleNotificationTap(with: userInfo)
                }
        }
        .windowResizability(.contentMinSize)
    }

    // MARK: - Private Methods

    private func setUpAuthObserver() {
        self.authObserver.start()
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
        self.knock.requestAndRegisterForPushNotifications()

        Task {
            do {
                try await self.knock.setup(publishableKey: self.env.KNOCK_PUBLISHABLE_KEY,
                                           pushChannelId: self.env.KNOCK_CHANNEL_ID)
            } catch {
                Logger.default.error("Error setting up remote notifications: \(error.localizedDescription, privacy: .public)")
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

    private func handleNotificationTap(with userInfo: [AnyHashable: Any]) {
        Logger.notifications.info("pushNotificationTapped")
        self.notificationsManager.pushNotificationTapped(userInfo: userInfo)
    }

}
