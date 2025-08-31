import SwiftUI
import Shimmer

struct SkeletonAgentsListView: View {

    var body: some View {
        ForEach(0...4, id: \.self) { _ in
            SkeletonAgentCellView()
                .padding(.bottom, 28)
                .padding(.horizontal, 20)
        }
        .shimmering(active: true, gradient: self.shimmerGradient)
    }

    private var shimmerGradient: Gradient {
        Gradient(colors: [
            UIColor.black.swiftUI.opacity(0.6),
            UIColor.black.swiftUI,
            UIColor.black.swiftUI.opacity(0.6)
        ])
    }

}
