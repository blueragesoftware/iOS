import Foundation
import SwiftUI

struct SettingRow: Identifiable, Hashable, Equatable {

    enum Style {
        case destructive
        case `default`
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

    let style: Style

    let actionType: ActionType

    let icon: Icon

    let action: () async throws -> Void

    init(title: String,
         icon: Icon,
         style: Style,
         actionType: ActionType,
         action: @escaping () async throws -> Void) {
        self.title = title
        self.icon = icon
        self.style = style
        self.actionType = actionType
        self.action = action
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }

}
