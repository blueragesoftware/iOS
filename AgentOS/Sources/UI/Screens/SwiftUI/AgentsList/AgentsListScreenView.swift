import SwiftUI
import OSLog
import Shimmer

struct AgentsListScreenView: View {

    @State private var viewModel = AgentsListScreenViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    AgentsListView(state: self.viewModel.state)
                        .shimmering(active: self.viewModel.state.isSkeleton, gradient: self.shimmerGradient)
                }
            }
            .scrollIndicators(.hidden)
            .scrollDisabled(self.viewModel.state.isSkeleton || self.viewModel.state.isError)
            .onAppear() {
                self.viewModel.load()
            }
            .background(UIColor.systemGroupedBackground.swiftUI)
            .navigationTitle("agents_list_navigation_title")
        }
    }

    private var shimmerGradient: Gradient {
        Gradient(colors: [
            UIColor.black.swiftUI.opacity(0.6),
            UIColor.black.swiftUI,
            UIColor.black.swiftUI.opacity(0.6)
        ])
    }

}
