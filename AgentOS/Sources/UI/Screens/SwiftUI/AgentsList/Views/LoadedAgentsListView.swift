import SwiftUI
import FactoryKit

struct LoadedAgentsListView: View {

    private let agents: [Agent]
    @Binding private var selectedAgent: Agent?

    @Injected(\.hapticManager) private var hapticManager

    init(agents: [Agent], selectedAgent: Binding<Agent?>) {
        self.agents = agents
        self._selectedAgent = selectedAgent
    }

    var body: some View {
        ForEach(self.agents, id: \.id) { agent in
            AgentCellView(agent: agent) {
                self.hapticManager.triggerSelectionFeedback()
                self.selectedAgent = agent
            }
            .padding(.bottom, 28)
            .padding(.horizontal, 20)
        }
    }

}
