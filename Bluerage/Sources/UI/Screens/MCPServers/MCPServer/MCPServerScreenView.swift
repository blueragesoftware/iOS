import SwiftUI
import PostHog
import NavigatorUI

struct MCPServerScreenView: View {

    private let mcpServerId: String

    @State private var viewModel: MCPServerScreenViewModel

    init(mcpServerId: String) {
        self.mcpServerId = mcpServerId
        self.viewModel = MCPServerScreenViewModel(mcpServerId: mcpServerId)
    }

    var body: some View {
        self.content
            .onFirstAppear {
                self.viewModel.connect()
            }
            .onNavigationReceive { (oauthResult: MCPOAuthURLHandler.OAuthResult, navigator) in
                navigator.dismissAnyChildren()

                self.viewModel.handle(oauthResult: oauthResult)

                return .auto
            }
            .navigationDestination(MCPServerScreenViewDestinations.self)
            .postHogScreenView("MCPServerScreenView", ["mcpServerId": self.mcpServerId])
            .navigationTitle(BluerageStrings.mcpServerNavigationTitle)
            .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var content: some View {
        switch self.viewModel.state {
        case .loading:
            LoadingView()
                .transition(.blurReplace)
        case .loaded(let loadedViewModel):
            MCPServerLoadedView(viewModel: loadedViewModel)
                .transition(.blurReplace)
        case .error:
            PlaceholderView.error {
                self.viewModel.connect()
            }
            .transition(.blurReplace)
        }
    }

}
