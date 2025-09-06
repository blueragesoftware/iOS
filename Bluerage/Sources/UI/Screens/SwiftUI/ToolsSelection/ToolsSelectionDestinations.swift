import SwiftUI
import NavigatorUI

enum ToolsSelectionDestinations: NavigationDestination {

    case authWebView(url: URL, callback: Callback<Void>)

    var body: some View {
        switch self {
        case .authWebView(let url, let callback):
            SafariView(url: url)
                .onDisappear {
                    callback(())
                }
        }
    }

    var method: NavigationMethod {
        switch self {
        case .authWebView:
            return .sheet
        }
    }

}
