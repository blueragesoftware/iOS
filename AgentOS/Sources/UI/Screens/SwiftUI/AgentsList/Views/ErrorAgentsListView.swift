import SwiftUI
import FactoryKit

struct ErrorAgentsListView: View {

    var body: some View {
        ZStack {
            Spacer().containerRelativeFrame([.horizontal, .vertical])

            PlaceholderView(imageSystemName: "exclamationmark.circle",
                            title: "An issue happened",
                            description: "Try refreshing the page or come back later") {

            } buttonLabel: {
                Text("Refresh")
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
