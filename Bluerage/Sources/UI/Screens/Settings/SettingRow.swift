import Foundation
import SwiftUI
import NavigatorUI

struct SettingRow: Identifiable, Hashable, Equatable {

    enum `Type` {
        case destructive(action: () async throws -> Void)
        case `default`(action: () async throws -> Void)
        case navigation(destination: SettingsDestinations)
    }

    enum ActionType {
        case redirect
        case inApp
    }

    enum Icon {
        case image(named: String, size: CGSize)
        case system(named: String, fontSize: CGFloat, fontWeight: Font.Weight)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }

    let id: String = UUID().uuidString

    let title: String

    let icon: Icon

    let fillColor: Color

    let type: `Type`

    let actionType: ActionType

    init(title: String,
         icon: Icon,
         fillColor: Color,
         type: `Type`,
         actionType: ActionType) {
        self.title = title
        self.icon = icon
        self.fillColor = fillColor
        self.type = type
        self.actionType = actionType
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }

}
