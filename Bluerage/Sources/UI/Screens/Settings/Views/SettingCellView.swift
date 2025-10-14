import SwiftUI
import OSLog
import NavigatorUI

struct SettingCellView: View {

    private let row: SettingRow

    private let confirmAction: (String) async -> Bool

    @Environment(\.navigator) private var navigator

    init(row: SettingRow, confirmAction: @escaping (String) async -> Bool) {
        self.row = row
        self.confirmAction = confirmAction
    }

    var body: some View {
        IconCell(title: self.row.title,
                 iconForegroundColor: .white,
                 iconBackgroundColor: self.row.iconBackgroundColor,
                 icon: {
            switch self.row.icon {
            case .image(let named, let size):
                Image(named)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: size.width, height: size.height)
            case .system(let named, let fontSize, let fontWeight):
                Image(systemName: named)
                    .font(.system(size: fontSize, weight: fontWeight))
            }
        }, trailingView: {
            Image(systemName: self.actionIconName)
                .renderingMode(.template)
                .foregroundStyle(.primary)
                .font(.system(size: 13, weight: .semibold))
                .fixedSize()
                .rotationEffect(self.row.actionType == .inApp ? Angle(degrees: 90) : .zero)
        }, action: {
            Task {
                do {
                    switch self.row.type {
                    case .destructive(let action):
                        let result = await self.confirmAction(self.row.title)

                        if !result {
                            return
                        }

                        try await action()
                    case .default(let action):
                        try await action()
                    case .navigation(let navigationDestination):
                        self.navigator.navigate(to: navigationDestination)
                    }
                } catch {
                    Logger.settings.error("Error performing action \(self.row.title, privacy: .public): \(error.localizedDescription, privacy: .public)")
                }
            }
        })
    }

    private var actionIconName: String {
        switch self.row.actionType {
        case .redirect:
            "arrow.up.forward"
        case .inApp:
            "ellipsis"
        case .navigation:
            "chevron.forward"
        }
    }

}
