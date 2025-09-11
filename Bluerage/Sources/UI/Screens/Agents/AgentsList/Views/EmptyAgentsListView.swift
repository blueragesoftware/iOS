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
                            title: BluerageStrings.agentsListEmptyPlaceholderTitle,
                            description: BluerageStrings.agentsListEmptyPlaceholderDescription) {
                self.action()
            } buttonLabel: {
                Text(BluerageStrings.agentsListEmptyActionButtonTitle)
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
