import SwiftUI
import NavigatorUI

enum AgentDestinations: NavigationDestination {

    case executionsList(agentId: String)
    case toolsSelection(agentToolsSlugSet: Set<String>, callback: Callback<Tool>)

    var body: some View {
        switch self {
        case .executionsList(let agentId):
            ExecutionsListScreenView(agentId: agentId)
        case .toolsSelection(let agentToolsSlugSet, let callback):
            ToolsSelectionScreenView(agentToolsSlugSet: agentToolsSlugSet, onToolSelected: callback.handler)
        }
    }

    var method: NavigationMethod {
        switch self {
        case .executionsList:
            return .push
        case .toolsSelection:
            return .sheet
        }
    }

}
