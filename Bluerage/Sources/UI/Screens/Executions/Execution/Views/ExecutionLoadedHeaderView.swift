import SwiftUI
import NukeUI

struct ExecutionLoadedHeaderView: View {

    private static let iconSize: CGFloat = 120

    private let state: ExecutionTask.State

    private let index: Int

    init(state: ExecutionTask.State, index: Int) {
        self.state = state
        self.index = index
    }

    var body: some View {
        Section {

        } header: {
            VStack {
                ExecutionTaskStateIcon(state: self.state)
                    .frame(width: Self.iconSize, height: Self.iconSize)
                    .fixedSize()
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }

}
