import SwiftUI

struct ExecutionLoadedScreenView: View {

    private let task: ExecutionTask

    private let index: Int

    init(task: ExecutionTask, index: Int) {
        self.task = task
        self.index = index
    }

    var body: some View {
        Form {
            ExecutionLoadedHeaderView(state: self.task.state, index: self.index)

            Section {
                LabeledContent("Name", value: "# \(self.index)")
                LabeledContent("Status", value: "\(self.task.state.title)")
            }

            ExecutionLoadedContentView(state: self.task.state)
        }
    }

}
