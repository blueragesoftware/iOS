import SwiftUI
import FactoryKit
import NavigatorUI

struct LoadedExecutionsListView: View {

    private let tasks: [ExecutionTask]

    @Environment(\.navigator) private var navigator

    @Injected(\.hapticManager) private var hapticManager

    init(tasks: [ExecutionTask]) {
        self.tasks = tasks
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

        self.navigator.navigate(to: ExecutionsListDestinations.execution(taskId: task.id, index: index))
    }

}
