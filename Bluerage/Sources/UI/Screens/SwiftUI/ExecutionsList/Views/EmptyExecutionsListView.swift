import SwiftUI

struct EmptyExecutionsListView: View {

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            PlaceholderView(imageName: "empty_placeholder_icon_100",
                            title: "No Executions Yet",
                            description: "Run the agent to see execution history here")

            Spacer()
        }
    }

}
