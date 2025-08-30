import SwiftUI
import FactoryKit

struct ErrorAgentsListView: View {

    private let refresh: () -> Void

    init(refresh: @escaping () -> Void) {
        self.refresh = refresh
    }

    var body: some View {
        ZStack {
            Spacer().containerRelativeFrame([.horizontal, .vertical])

            PlaceholderView(imageSystemName: "exclamationmark.circle",
                            title: "agents_list_error_placeholder_title",
                            description: "agents_list_error_placeholder_description") {
                self.refresh()
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

}
