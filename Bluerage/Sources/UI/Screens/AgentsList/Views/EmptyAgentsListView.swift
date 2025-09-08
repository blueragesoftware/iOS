import SwiftUI

struct EmptyAgentsListView: View {

    private let action: () -> Void

    init(action: @escaping () -> Void) {
        self.action = action
    }

    var body: some View {
        ZStack {
            Spacer().containerRelativeFrame([.horizontal, .vertical])

            PlaceholderView(imageName: BluerageAsset.Assets.emptyPlaceholderIcon100.name,
                            title: "agents_list_empty_placeholder_title",
                            description: "agents_list_empty_placeholder_description") {
                self.action()
            } buttonLabel: {
                Text("agents_list_empty_action_button_title")
                    .foregroundStyle(.primary)
                    .font(.system(size: 15, weight: .semibold))
                    .padding(.vertical, 8)
                    .padding(.horizontal, 20)
                    .fixedSize()
            }
            .buttonStyle(.borderGradientProminentButtonStyle)
        }
    }

}
