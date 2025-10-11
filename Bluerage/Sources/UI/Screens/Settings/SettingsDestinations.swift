import SwiftUI
import NavigatorUI

enum SettingsDestinations: NavigationDestination {

    case customModels
    case mcpServers

    var body: some View {
        switch self {
        case .customModels:
            CustomModelsListScreenView()
        case .mcpServers:
            MCPServersListScreenView()
        }
    }

}
