import SwiftUI
import OSLog

struct ExecutionsListScreenView: View {

    @State private var viewModel: ExecutionsListScreenViewModel

    @State private var selectedTaskInfo: ExecutionTaskInfo?

    init(agentId: String, selectedTaskInfo: ExecutionTaskInfo? = nil) {
        self.viewModel = ExecutionsListScreenViewModel(agentId: agentId)
        self.selectedTaskInfo = selectedTaskInfo
    }

    var body: some View {
        self.content
            .scrollDisabled(self.viewModel.state.isLoading || self.viewModel.state.isError)
            .onFirstAppear {
                self.viewModel.connect()
            }
            .background(UIColor.systemGroupedBackground.swiftUI)
            .navigationTitle("Executions")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(item: self.$selectedTaskInfo) { info in
                ExecutionScreenView(taskId: info.task.id, index: info.index)
            }
    }

    @ViewBuilder
    private var content: some View {
        switch self.viewModel.state {
        case .loading:
            SkeletonExecutionsListView()
                .transition(.blurReplace)
        case .loaded(let tasks):
            LoadedExecutionsListView(tasks: tasks,
                                     selectedTaskInfo: self.$selectedTaskInfo)
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
