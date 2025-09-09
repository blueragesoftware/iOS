import SwiftUI

struct EmptyCustomModelsListView: View {

    private let action: () -> Void

    init(action: @escaping () -> Void) {
        self.action = action
    }

    var body: some View {
        ZStack {
            Spacer().containerRelativeFrame([.horizontal, .vertical])

            PlaceholderView(imageName: BluerageAsset.Assets.emptyPlaceholderIcon100.name,
                            title: "No Custom Models",
                            description: "Create your first custom model to get started with personalized AI experiences") {
                self.action()
            } buttonLabel: {
                Text("Create Custom Model")
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
