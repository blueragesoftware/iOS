import SwiftUI
import FactoryKit

struct ErrorAgentsListView: View {

    var body: some View {
        ZStack {
            Spacer().containerRelativeFrame([.horizontal, .vertical])

            PlaceholderView(imageSystemName: "exclamationmark.circle",
                            title: "agents_list_error_placeholder_title",
                            description: "agents_list_error_placeholder_description") {

            } buttonLabel: {
                Text("agents_list_error_action_button_title")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(UIColor.label.swiftUI)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 20)
                    .fixedSize()
            }
            .buttonStyle(.borderGradientProminentButtonStyle)
        }
    }

}
