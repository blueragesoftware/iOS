import SwiftUI
import NukeUI

struct AgentLoadedHeaderView: View {
    
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
            .processors([.resize(height: AgentSizeProvider.iconSize), .circle()])
            .clipShape(Circle())
            .frame(width: AgentSizeProvider.iconSize, height: AgentSizeProvider.iconSize)
            .fixedSize()
            .padding(.trailing, 16)
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
    
}
