import SwiftUI
import NavigatorUI

struct AgentToolSelectionHandler: Hashable {

    private let id = UUID()

    let onToolSelected: (Tool) -> Void

    init(onToolSelected: @escaping (Tool) -> Void) {
        self.onToolSelected = onToolSelected
    }

    static func == (lhs: AgentToolSelectionHandler, rhs: AgentToolSelectionHandler) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}

enum AgentDestinations: NavigationDestination {

    static func toolsSelection(agentToolsSlugSet: Set<String>,
                               handler: @escaping (Tool) -> Void) -> AgentDestinations {
        return .toolsSelection(agentToolsSlugSet: agentToolsSlugSet,
                               handler: AgentToolSelectionHandler(onToolSelected: handler))
    }

    case executionsList(agentId: String)
    case toolsSelection(agentToolsSlugSet: Set<String>, handler: AgentToolSelectionHandler)

    var body: some View {
        switch self {
        case .executionsList(let agentId):
            ExecutionsListScreenView(agentId: agentId)
        case .toolsSelection(let agentToolsSlugSet, let handler):
            ToolsSelectionScreenView(agentToolsSlugSet: agentToolsSlugSet, onToolSelected: handler.onToolSelected)
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
