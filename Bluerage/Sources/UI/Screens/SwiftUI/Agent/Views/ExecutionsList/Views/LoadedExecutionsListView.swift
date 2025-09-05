import SwiftUI
import FactoryKit

struct LoadedExecutionsListView: View {

    private let tasks: [ExecutionTask]

    @Binding private var selectedTaskInfo: ExecutionTaskInfo?

    @Injected(\.hapticManager) private var hapticManager

    init(tasks: [ExecutionTask],
         selectedTaskInfo: Binding<ExecutionTaskInfo?>) {
        self.tasks = tasks
        self._selectedTaskInfo = selectedTaskInfo
    }

    var body: some View {
        List {
            ForEach(Array(zip(self.tasks, self.tasks.indices.reversed())), id: \.0.id) { task, index in
                let clampedIndex = index + 1
                ExecutionTaskCellView(task: task, index: clampedIndex) {
                    self.open(task: task, index: clampedIndex)
                }
                .padding(.bottom, 28)
                .padding(.horizontal, 20)
            }
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
    }

    private func open(task: ExecutionTask, index: Int) {
        self.hapticManager.triggerSelectionFeedback()
        self.selectedTaskInfo = ExecutionTaskInfo(task: task, index: index)
    }

}
