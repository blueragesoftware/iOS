import SwiftUI
import OSLog
import NavigatorUI

struct ExecutionsListScreenView: View {

    @State private var viewModel: ExecutionsListScreenViewModel

    @Environment(\.navigator) private var navigator

    init(agentId: String) {
        self.viewModel = ExecutionsListScreenViewModel(agentId: agentId)
    }

    var body: some View {
        self.content
            .scrollDisabled(self.viewModel.state.isLoading || self.viewModel.state.isError)
            .onFirstAppear {
                self.viewModel.connect()
            }
            .background(UIColor.systemGroupedBackground.swiftUI)
            .navigationTitle(BluerageStrings.executionsListTitle)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestinationAutoReceive(ExecutionsListDestinations.self)
    }

    @ViewBuilder
    private var content: some View {
        switch self.viewModel.state {
        case .loading:
            SkeletonExecutionsListView()
                .transition(.blurReplace)
        case .loaded(let tasks):
            LoadedExecutionsListView(tasks: tasks)
                .transition(.blurReplace)
        case .empty:
            EmptyExecutionsListView()
                .transition(.blurReplace)
        case .error:
            PlaceholderView.error {
                self.viewModel.connect()
            }
            .transition(.blurReplace)
        }
    }

}
