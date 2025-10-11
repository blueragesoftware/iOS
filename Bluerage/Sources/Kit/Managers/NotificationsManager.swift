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

    @Injected(\.keyedExecutor) private var keyedExecutor

    nonisolated override init() {
        super.init()

        UNUserNotificationCenter.current().delegate = self
    }

    func pushNotificationTapped(userInfo: [AnyHashable: Any]) {
        guard let messageId = self.getMessageId(userInfo: userInfo) else {
            return
        }

        Task {
            await self.updateMessageStatus(messageId: messageId, status: .interacted)
        }
    }

    func registerTokenForAPNS(with deviceToken: Data) {
        Task {
            let channelId = await Knock.shared.getPushChannelId()

            do {
                try await self.keyedExecutor.executeOperation(for: "notificationsManager/registerTokenForAPNS/\(channelId ?? "nil")") {
                    _ = try await Knock.shared.registerTokenForAPNS(channelId: channelId, token: Self.convertTokenToString(token: deviceToken))
                }
            } catch let error {
                Logger.notifications.error("Unable to register for push notification at this time, error: \(error.localizedDescription, privacy: .public)")
            }
        }
    }

    // MARK: - UNUserNotificationCenterDelegate

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        Logger.notifications.info("pushNotificationDeliveredInForeground")

        let options: UNNotificationPresentationOptions = [.sound, .badge, .banner]

        guard let messageId = self.getMessageId(userInfo: notification.request.content.userInfo) else {
            return options
        }

        await self.updateMessageStatus(messageId: messageId, status: .read)

        return options
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        Logger.notifications.info("pushNotificationTapped")

        guard let messageId = self.getMessageId(userInfo: response.notification.request.content.userInfo) else {
            return
        }

        await self.updateMessageStatus(messageId: messageId, status: .interacted)
    }

    private func updateMessageStatus(messageId: String, status: Knock.KnockMessageStatusUpdateType) async {
        do {
            try await self.keyedExecutor.executeOperation(for: "notificationsManager/updateMessageStatus/\(status.rawValue)/\(messageId)") {
                _ = try await self.knock.updateMessageStatus(messageId: messageId, status: status)
            }
        } catch {
            Logger.notifications.error("Failed to update messageId \(messageId, privacy: .public) to status \(status.rawValue, privacy: .public), error: \(error.localizedDescription, privacy: .public)")
        }
    }

    private func getMessageId(userInfo: [AnyHashable: Any]) -> String? {
        return userInfo["knock_message_id"] as? String
    }

}
