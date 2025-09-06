import SwiftUI

struct EmptyExecutionsListView: View {

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            PlaceholderView(imageName: "empty_placeholder_icon_100",
                            title: "execution_empty_placeholder_title",
                            description: "execution_empty_placeholder_description")

            Spacer()
        }
    }

}
