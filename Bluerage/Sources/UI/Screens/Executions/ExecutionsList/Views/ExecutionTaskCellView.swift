import SwiftUI
import NukeUI

struct ExecutionTaskCellView: View {

    private let task: ExecutionTask

    private let index: Int

    private let onTap: () -> Void

    init(task: ExecutionTask,
         index: Int,
         onTap: @escaping () -> Void) {
        self.task = task
        self.index = index
        self.onTap = onTap
    }

    var body: some View {
        Button {
            self.onTap()
        } label: {
            HStack(spacing: 0) {
                ExecutionTaskStateIcon(state: self.task.state)
                    .frame(width: 40, height: 40)
                    .padding(.trailing, 16)

                VStack(alignment: .leading, spacing: 2) {
                    Text("# \(self.index)")
                        .font(.system(size: 16, weight: .semibold))
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                        .foregroundStyle(.primary)

                    Text(self.task.state.title)
                        .font(.system(size: 13, weight: .regular))
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                        .foregroundStyle(.tertiary)
                }

                Spacer()

                OpenButton(onOpen: self.onTap)
            }
        }
    }

}
