import SwiftUI

struct OpenButton: View {

    private let onOpen: () -> Void

    init(onOpen: @escaping () -> Void) {
        self.onOpen = onOpen
    }

    var body: some View {
        Button {
            self.onOpen()
        } label: {
            Text(BluerageStrings.commonOpen)
                .foregroundStyle(.primary)
                .font(.system(size: 15, weight: .semibold))
                .padding(.vertical, 6)
                .padding(.horizontal, 18)
                .fixedSize()
        }
        .buttonStyle(.borderGradientProminentButtonStyle)

    }

}
