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
        Button {
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
        } label: {
            HStack(spacing: 0) {
                self.icon
                    .foregroundStyle(.white)
                    .fixedSize()
                    .background {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(self.row.fillColor)
                            .frame(width: 28, height: 28)
                    }
                    .frame(width: 28, height: 28)

                Text(self.row.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                    .padding(.leading, 12)

                Spacer()

                Image(systemName: self.actionIconName)
                    .renderingMode(.template)
                    .foregroundStyle(.primary)
                    .font(.system(size: 13, weight: .semibold))
                    .fixedSize()
                    .rotationEffect(self.row.actionType == .inApp ? Angle(degrees: 90) : .zero)
            }
        }
    }

    @ViewBuilder
    private var icon: some View {
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
