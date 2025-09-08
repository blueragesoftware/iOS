import SwiftUI

struct SettingCellView: View {

    private let row: SettingRow

    init(row: SettingRow) {
        self.row = row
    }

    var body: some View {
        Button {
            Task {
                do {
                    try await self.row.action()
                } catch {

                }
            }
        } label: {
            HStack(alignment: .center, spacing: 0) {
                self.icon
                    .foregroundStyle(self.row.style == .destructive ? .red : .primary)
                    .background {
                        Circle()
                            .fill(UIColor.quaternarySystemFill.swiftUI)
                            .frame(width: 36, height: 36)
                    }
                    .padding(.trailing, 12)

                Text(self.row.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(row.style == .destructive ? .red : .primary)

                Spacer()

                Image(systemName: self.row.actionType == .redirect ? "arrow.up.right" : "ellipsis")
                    .font(.system(size: 13, weight: .semibold))
                    .transformEffect(self.row.actionType == .redirect ? .identity : CGAffineTransformMakeRotation(.pi * 1 / 2))

            }
        }
    }

    @ViewBuilder
    private var icon: some View {
        switch self.row.icon {
        case .image(let named, let size):
            Image(named)
                .resizable()
                .frame(width: size.width, height: size.height)
        case .system(let named, let fontSize, let fontWeight):
            Image(systemName: named)
                .font(.system(size: fontSize, weight: fontWeight))
        }
    }

}
