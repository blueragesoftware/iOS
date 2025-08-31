import SwiftUI

struct AgentsListView: View {

    @Binding private var selectedAgent: Agent?

    private let state: AgentsListScreenViewModel.State

    private let createNewAgent: () -> Void

    private let refresh: () -> Void

    init(state: AgentsListScreenViewModel.State,
         selectedAgent: Binding<Agent?>,
         createNewAgent: @escaping () -> Void,
         refresh: @escaping () -> Void) {
        self.state = state
        self._selectedAgent = selectedAgent
        self.createNewAgent = createNewAgent
        self.refresh = refresh
    }

    var body: some View {
        switch self.state {
        case .loading:
            SkeletonAgentsListView()
                .transition(.blurReplace)
        case .loaded(let agents):
            LoadedAgentsListView(agents: agents, selectedAgent: self.$selectedAgent)
                .transition(.blurReplace)
        case .empty:
            EmptyAgentsListView() {
                self.createNewAgent()
            }
                .transition(.blurReplace)
        case .error:
            ErrorAgentsListView {
                self.refresh()
            }
                .transition(.blurReplace)
        }
    }

}
