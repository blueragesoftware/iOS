import SwiftUI

struct ExecutionScreenView: View {

    @State private var viewModel: ExecutionScreenViewModel

    private let index: Int

    init(taskId: String, index: Int) {
        self.viewModel = ExecutionScreenViewModel(taskId: taskId)
        self.index = index
    }

    var body: some View {
        Group {
            switch self.viewModel.state {
            case .loaded(let task):
                ExecutionLoadedScreenView(task: task, index: self.index)
            case .loading:
                LoadingView()
            case .error:
                PlaceholderView.error {
                    self.viewModel.connect()
                }
            }
        }
        .onFirstAppear {
            self.viewModel.connect()
        }
    }

}
