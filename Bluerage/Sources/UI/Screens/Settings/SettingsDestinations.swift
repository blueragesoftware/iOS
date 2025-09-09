import SwiftUI
import NavigatorUI

enum SettingsDestinations: NavigationDestination {

    case customModels

    var body: some View {
        switch self {
        case .customModels:
            CustomModelsListScreenView()
        }
    }

}
