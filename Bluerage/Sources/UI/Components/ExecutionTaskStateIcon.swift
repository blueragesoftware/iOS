import SwiftUI

struct ExecutionTaskStateIcon: View {

    private let state: ExecutionTask.State

    init(state: ExecutionTask.State) {
        self.state = state
    }

    var body: some View {
        switch self.state {
        case .registered:
            Image(systemName: "circle.dotted")
                .resizable()
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.gray)
        case .running:
            Image(systemName: "smallcircle.filled.circle.fill")
                .resizable()
                .symbolRenderingMode(.hierarchical)
                .symbolEffect(.pulse)
                .foregroundStyle(.blue)
        case .error:
            Image(systemName: "x.circle")
                .resizable()
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.red)
        case .success:
            Image(systemName: "checkmark.circle")
                .resizable()
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.green)
        }
    }

}
