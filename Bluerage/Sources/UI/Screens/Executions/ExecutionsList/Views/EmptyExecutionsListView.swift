import SwiftUI

struct EmptyExecutionsListView: View {

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            PlaceholderView(imageName: BluerageAsset.Assets.emptyPlaceholderIcon100.name,
                            title: BluerageStrings.executionEmptyPlaceholderTitle,
                            description: BluerageStrings.executionEmptyPlaceholderDescription)

            Spacer()
        }
    }

}
