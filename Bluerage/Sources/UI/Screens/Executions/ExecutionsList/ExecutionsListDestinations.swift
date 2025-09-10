import SwiftUI
import NavigatorUI

enum ExecutionsListDestinations: NavigationDestination {

    case execution(taskId: String, index: Int)

    var body: some View {
        switch self {
        case .execution(let taskId, let index):
            ExecutionScreenView(taskId: taskId, index: index)
        }
    }

}
