import SwiftUI

struct ExecutionTaskIndicator: View {

    private let task: ExecutionTask

    init(task: ExecutionTask) {
        self.task = task
    }

    var body: some View {
        Circle()
            .frame(width: 2, height: 2)
            .foregroundStyle(self.color)
    }

    private var color: Color {
        switch self.task.state {
        case .registered:
            Color.gray
        case .running:
                Color.blue
        case .error:
            Color.red
        case .success:
            Color.green
        }
    }

}


