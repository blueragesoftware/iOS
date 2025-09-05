import SwiftUI
import NavigatorUI

enum AgentListDestinations: NavigationDestination {

    case agent(Agent)

    var body: some View {
        switch self {
        case .agent(let agent):
            return AgentScreenView(agentId: agent.id)
        }
    }

}
