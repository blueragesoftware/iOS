import SwiftUI
import FactoryKit

struct EmptyAgentsListView: View {

    var body: some View {
        ZStack {
            Spacer().containerRelativeFrame([.horizontal, .vertical])

            PlaceholderView(imageSystemName: "eyes.inverse",
                            title: "No Agents yet",
                            description: "Time to create your first one") {

            } buttonLabel: {
                Text("Create Agent")
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
