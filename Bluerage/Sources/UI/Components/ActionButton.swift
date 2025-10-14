import SwiftUI

struct ActionButton: View {

    private var isLoading: Bool = false

    private let title: String

    private let action: () -> Void

    init(title: String,
         action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    var body: some View {
        Button {
            self.action()
        } label: {
            if self.isLoading {
                ProgressView()
                    .tint(UIColor.systemBackground.swiftUI)
                    .padding(.vertical, 15)
                    .frame(maxWidth: .infinity)
            } else {
                Text(self.title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(UIColor.systemBackground.swiftUI)
                    .padding(.vertical, 15)
                    .frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(.primaryButtonStyle)
        .allowsHitTesting(!self.isLoading)
    }

}

extension ActionButton {

    func isLoading(_ isLoading: Bool) -> ActionButton {
        var copy = self
        copy.isLoading = isLoading
        return copy
    }

}
