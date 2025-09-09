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
            HStack(alignment: .center, spacing: 0) {
                self.icon
                    .foregroundStyle(self.foregroundStyle)
                    .fixedSize()
                    .background {
                        Circle()
                            .fill(UIColor.quaternarySystemFill.swiftUI)
                            .frame(width: 36, height: 36)
                    }
                    .frame(width: 36, height: 36)

                Text(self.row.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(self.foregroundStyle)
                    .padding(.leading, 12)

                Spacer()

                Image(systemName: self.row.actionType == .redirect ? "arrow.up.right" : "ellipsis")
                    .renderingMode(.template)
                    .foregroundStyle(UIColor.label.swiftUI)
                    .font(.system(size: 13, weight: .semibold))
                    .fixedSize()
                    .rotationEffect(self.row.actionType == .redirect ? .zero : Angle(degrees: 90))
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

    private var foregroundStyle: Color {
        if case .destructive = self.row.type {
            return .red
        }

        return .primary
    }

}
