import UIKit
import FactoryKit
import OSLog

@MainActor
final class AppDelegate: UIResponder, UIApplicationDelegate {

    @Injected(\.notificationsManager) private var notificationsManager

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        return true
    }

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sceneConfig: UISceneConfiguration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = SceneDelegate.self
        return sceneConfig
    }

    // MARK: - Notifications

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: any Error) {
        Logger.notifications.error("Failed to register for notifications: \(error.localizedDescription, privacy: .public)")
    }

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Logger.notifications.info("didRegisterForRemoteNotifications")

        self.notificationsManager.registerTokenForAPNS(with: deviceToken)
    }

    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async -> UIBackgroundFetchResult {
        Logger.notifications.info("pushNotificationDeliveredSilently")

        return .noData
    }

}
