import SwiftUI

struct EmptyExecutionsListView: View {

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            PlaceholderView(imageName: BluerageAsset.Assets.emptyPlaceholderIcon100.name,
                            title: "execution_empty_placeholder_title",
                            description: "execution_empty_placeholder_description")

            Spacer()
        }
    }

}
