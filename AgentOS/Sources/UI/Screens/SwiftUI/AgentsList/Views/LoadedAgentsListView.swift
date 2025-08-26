import SwiftUI
import FactoryKit

struct LoadedAgentsListView: View {

    private let agents: [Agent]

    @Injected(\.hapticManager) private var hapticManager

    init(agents: [Agent]) {
        self.agents = agents
    }

    var body: some View {
        ForEach(self.agents, id: \.id) { agent in
            AgentCellView(agent: agent) {
                self.hapticManager.triggerSelectionFeedback()

//                self.onMiniAppOpen(miniApp)
            }
            .padding(.bottom, 28)
            .padding(.horizontal, 20)
        }
    }

}
