import SwiftUI
import NukeUI

struct AgentLoadedHeaderView: View {

    private static let iconSize: CGFloat = 120

    private let iconUrl: String

    init(iconUrl: String) {
        self.iconUrl = iconUrl
    }

    var body: some View {
        Section {

        } header: {
            LazyImage(url: URL(string: self.iconUrl)) { state in
                if let image = state.image {
                    image.resizable().aspectRatio(contentMode: .fit)
                } else {
                    UIColor.quaternarySystemFill.swiftUI
                }
            }
            .processors([.resize(height: Self.iconSize), .circle()])
            .clipShape(Circle())
            .frame(width: Self.iconSize, height: Self.iconSize)
            .fixedSize()
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }

}
