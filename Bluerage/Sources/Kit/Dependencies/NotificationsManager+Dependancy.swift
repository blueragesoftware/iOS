import Foundation
import PostHog
import FactoryKit

extension Container {

    @MainActor
    var notificationsManager: Factory<NotificationsManager> {
        self {
            NotificationsManager()
        }.shared
    }

}
