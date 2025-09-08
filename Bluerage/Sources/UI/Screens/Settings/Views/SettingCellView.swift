import SwiftUI
import OSLog

struct SettingCellView: View {

    private let row: SettingRow

    private let confirmAction: (String) async -> Bool

    init(row: SettingRow, confirmAction: @escaping (String) async -> Bool) {
        self.row = row
        self.confirmAction = confirmAction
    }

    var body: some View {
        Button {
            Task {
                do {
                    if self.row.style == .destructive {
                        let result = await self.confirmAction(self.row.title)

                        if !result {
                            return
                        }
                    }

                    try await self.row.action()
                } catch {
                    Logger.settings.error("Error performing action \(self.row.title, privacy: .public): \(error.localizedDescription, privacy: .public)")
                }
            }
        } label: {
            HStack(alignment: .center, spacing: 0) {
                self.icon
                    .foregroundStyle(self.row.style == .destructive ? .red : .primary)
                    .fixedSize()
                    .background {
                        Circle()
                            .fill(UIColor.quaternarySystemFill.swiftUI)
                            .frame(width: 36, height: 36)
                    }
                    .frame(width: 36, height: 36)

                Text(self.row.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(row.style == .destructive ? .red : .primary)
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

}
