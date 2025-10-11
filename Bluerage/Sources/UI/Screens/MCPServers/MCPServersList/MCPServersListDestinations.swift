import SwiftUI
import NavigatorUI

enum MCPServersListDestinations: NavigationDestination {

    case mcpServer(id: String)

    var body: some View {
        switch self {
        case .mcpServer(let id):
            MCPServerScreenView(mcpServerId: id)
        }
    }

}
