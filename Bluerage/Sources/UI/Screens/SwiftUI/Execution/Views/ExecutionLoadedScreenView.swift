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
                LabeledContent("execution_name_field_title", value: "# \(self.index)")
                LabeledContent("execution_status_field_title", value: "\(self.task.state.title)")
            }

            ExecutionLoadedContentView(state: self.task.state)
        }
    }

}
