import SwiftUI
import NavigatorUI

enum RootTabDestinations: Int, Identifiable, NavigationDestination {

    static let tabs: [RootTabDestinations] = [
        .agentsList,
        .settings
    ]

    case agentsList
    case settings

    var id: String {
        "\(self)"
    }

    var icon: String {
        switch self {
        case .agentsList:
            "house.fill"
        case .settings:
            "gear"
        }
    }

    var body: some View {
        switch self {
        case .agentsList:
            AgentsListScreenView()
        case .settings:
            SettingsScreenView()
        }
    }

}
