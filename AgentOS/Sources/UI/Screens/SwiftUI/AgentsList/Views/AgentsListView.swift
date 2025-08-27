import SwiftUI

struct AgentsListView: View {

    private let state: AgentsListScreenViewModel.State
    @Binding private var selectedAgent: Agent?

    init(state: AgentsListScreenViewModel.State, selectedAgent: Binding<Agent?>) {
        self.state = state
        self._selectedAgent = selectedAgent
    }

    var body: some View {
        switch self.state {
        case .skeleton:
            SkeletonAgentsListView()
                .transition(.blurReplace)
        case .loaded(let agents):
            LoadedAgentsListView(agents: agents, selectedAgent: self.$selectedAgent)
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
