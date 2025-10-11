import SwiftUI
import NavigatorUI

enum MCPServerScreenViewDestinations: NavigationDestination {

    case authWebView(url: URL)

    var body: some View {
        switch self {
        case .authWebView(let url):
            SafariView(url: url)
        }
    }

    var method: NavigationMethod {
        switch self {
        case .authWebView:
            return .sheet
        }
    }

}
