import SwiftUI
import NavigatorUI

enum CustomModelsListDestinations: NavigationDestination {

    case customModel(id: String)

    var body: some View {
        switch self {
        case .customModel(let id):
            CustomModelScreenView(customModelId: id)
        }
    }

}
