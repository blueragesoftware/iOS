import SwiftUI
import FactoryKit
import NavigatorUI

struct LoadedAgentsListView: View {

    private let agents: [Agent]

    private let onRemove: ([String]) -> Void

    @Environment(\.navigator) private var navigator

    @Injected(\.hapticManager) private var hapticManager

    init(agents: [Agent],
         onRemove: @escaping ([String]) -> Void) {
        self.agents = agents
        self.onRemove = onRemove
    }

    var body: some View {
        List {
            ForEach(self.agents) { agent in
                AgentCellView(agent: agent) {
                    self.hapticManager.triggerSelectionFeedback()
                    self.navigator.navigate(to: AgentListDestinations.agent(agent))
                }
                .padding(.bottom, 28)
                .padding(.horizontal, 20)
            }
            .onDelete { offsets in
                let agents = self.agents

                let idsToRemove = offsets.compactMap { offset in
                    return agents[safeIndex: offset]?.id
                }

                self.onRemove(idsToRemove)
            }
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
    }

}
