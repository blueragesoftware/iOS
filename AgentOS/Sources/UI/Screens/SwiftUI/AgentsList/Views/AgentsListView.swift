import SwiftUI

struct AgentsListView: View {

    private let state: AgentsListScreenViewModel.State

    init(state: AgentsListScreenViewModel.State) {
        self.state = state
    }

    var body: some View {
        switch self.state {
        case .skeleton:
            SkeletonAgentsListView()
                .transition(.blurReplace)
        case .loaded(let agents):
            LoadedAgentsListView(agents: agents)
                .transition(.blurReplace)
        case .empty:
            EmptyAgentsListView()
                .transition(.blurReplace)
        case .error:
            ErrorAgentsListView()
                .transition(.blurReplace)
        }
    }

}
