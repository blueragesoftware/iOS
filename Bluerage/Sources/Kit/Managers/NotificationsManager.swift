import Knock
import FactoryKit
import OSLog
import UIKit

@MainActor
final class NotificationsManager: NSObject, UNUserNotificationCenterDelegate {

    private static func convertTokenToString(token: Data) -> String {
        let tokenParts = token.map { data -> String in
            return String(format: "%02.2hhx", data)
        }

        return tokenParts.joined()
    }

    @Injected(\.knock) private var knock

    nonisolated override init() {
        super.init()

        UNUserNotificationCenter.current().delegate = self
    }

    func pushNotificationTapped(userInfo: [AnyHashable: Any]) {
        if let messageId = self.getMessageId(userInfo: userInfo) {
            Task {
                do {
                    _ = try await self.knock.updateMessageStatus(messageId: messageId, status: .interacted)
                } catch {
                    Logger.notifications.error("Error sending updating message status for messageId: \(messageId, privacy: .public), error: \(error.localizedDescription, privacy: .public)")
                }
            }
        }
    }

    func registerTokenForAPNS(with deviceToken: Data) {
        Task {
            let channelId = await Knock.shared.getPushChannelId()

            do {
                _ = try await Knock.shared.registerTokenForAPNS(channelId: channelId, token: Self.convertTokenToString(token: deviceToken))
            } catch let error {
                Logger.notifications.error("Unable to register for push notification at this time, error: \(error.localizedDescription, privacy: .public)")
            }
        }
    }

    // MARK: - UNUserNotificationCenterDelegate

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        Logger.notifications.info("pushNotificationDeliveredInForeground")

        if let messageId = getMessageId(userInfo: notification.request.content.userInfo) {
            self.knock.updateMessageStatus(messageId: messageId, status: .read) { _ in }
        }

        return [.sound, .badge, .banner]
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        Logger.notifications.info("pushNotificationTapped")

        if let messageId = getMessageId(userInfo: response.notification.request.content.userInfo) {
            Knock.shared.updateMessageStatus(messageId: messageId, status: .interacted) { _ in }
        }
    }

    private func getMessageId(userInfo: [AnyHashable: Any]) -> String? {
        return userInfo["knock_message_id"] as? String
    }

}
