import SwiftUI
import NavigatorUI

enum AgentListDestinations: NavigationDestination {

    case agent(Agent)
    case settings

    var body: some View {
        switch self {
        case .agent(let agent):
            AgentScreenView(agentId: agent.id)
        case .settings:
            SettingsScreenView()
        }
    }

    var method: NavigationMethod {
        switch self {
        case .agent:
                .push
        case .settings:
                .sheet
        }
    }

}
