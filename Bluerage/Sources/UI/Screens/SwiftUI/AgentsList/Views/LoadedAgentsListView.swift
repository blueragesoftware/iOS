import SwiftUI
import FactoryKit

struct LoadedAgentsListView: View {

    private let agents: [Agent]

    @Binding private var selectedAgent: Agent?

    private let onDelete: ([String]) -> Void

    @Injected(\.hapticManager) private var hapticManager

    init(agents: [Agent],
         selectedAgent: Binding<Agent?>,
         onDelete: @escaping ([String]) -> Void) {
        self.agents = agents
        self._selectedAgent = selectedAgent
        self.onDelete = onDelete
    }

    var body: some View {
        ForEach(self.agents) { agent in
            AgentCellView(agent: agent) {
                self.hapticManager.triggerSelectionFeedback()
                self.selectedAgent = agent
            }
            .padding(.bottom, 28)
            .padding(.horizontal, 20)
        }
        .onDelete { offsets in
            let idsToDelete = offsets.compactMap { offset in
                return self.agents[safeIndex: offset]?.id
            }

            self.onDelete(idsToDelete)
        }
    }

}
