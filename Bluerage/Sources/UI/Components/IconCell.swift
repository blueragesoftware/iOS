import SwiftUI

struct IconCell<Icon: View, TrailingView: View>: View {

    let title: String

    let iconForegroundColor: Color

    let iconBackgroundColor: Color

    @ViewBuilder
    let icon: () -> Icon

    @ViewBuilder
    let trailingView: () -> TrailingView

    let action: () -> Void

    init(title: String,
         iconForegroundColor: Color,
         iconBackgroundColor: Color,
         @ViewBuilder icon: @escaping () -> Icon,
         @ViewBuilder trailingView: @escaping () -> TrailingView,
         action: @escaping () -> Void) {
        self.icon = icon
        self.iconForegroundColor = iconForegroundColor
        self.iconBackgroundColor = iconBackgroundColor
        self.title = title
        self.trailingView = trailingView
        self.action = action
    }

    var body: some View {
        Button {
            self.action()
        } label: {
            HStack(spacing: 0) {
                self.icon()
                    .foregroundStyle(self.iconForegroundColor)
                    .fixedSize()
                    .background {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(self.iconBackgroundColor)
                            .frame(width: 28, height: 28)
                    }
                    .frame(width: 28, height: 28)

                Text(self.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                    .padding(.leading, 12)

                Spacer()

                self.trailingView()
            }
        }
    }

}
