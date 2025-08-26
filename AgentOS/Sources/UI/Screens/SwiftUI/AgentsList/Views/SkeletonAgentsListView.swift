import SwiftUI

struct SkeletonAgentsListView: View {

    var body: some View {
        ForEach(0...4, id: \.self) { _ in
            SkeletonAgentCellView()
                .padding(.bottom, 28)
                .padding(.horizontal, 20)
        }
    }

}
