import SwiftUI

struct AgentScreenErrorView: View {

    private let action: () -> Void

    init(action: @escaping () -> Void) {
        self.action = action
    }

    var body: some View {
        PlaceholderView(imageSystemName: "exclamationmark.circle",
                        title: "agent_error_placeholder_title",
                        description: "agent_error_placeholder_description") {
            self.action()
        } buttonLabel: {
            Text("common_refresh")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(UIColor.label.swiftUI)
                .padding(.vertical, 8)
                .padding(.horizontal, 20)
                .fixedSize()
        }
        .buttonStyle(.borderGradientProminentButtonStyle)
    }

}
