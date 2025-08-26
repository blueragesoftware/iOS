import SwiftUI
import FactoryKit

struct EmptyAgentsListView: View {

    var body: some View {
        ZStack {
            Spacer().containerRelativeFrame([.horizontal, .vertical])

            PlaceholderView(imageSystemName: "eyes.inverse",
                            title: "agents_list_empty_placeholder_title",
                            description: "agents_list_empty_placeholder_description") {

            } buttonLabel: {
                Text("agents_list_empty_action_button_title")
                    .foregroundStyle(UIColor.label.swiftUI)
                    .font(.system(size: 15, weight: .semibold))
                    .padding(.vertical, 8)
                    .padding(.horizontal, 20)
                    .fixedSize()
            }
            .buttonStyle(.borderGradientProminentButtonStyle)
        }
    }

}
