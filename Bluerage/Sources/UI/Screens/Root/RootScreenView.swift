import SwiftUI
import FactoryKit
import PostHog

struct RootScreenView: View {

    @State private var viewModel = RootScreenViewModel()

    var body: some View {
        self.content
            .onFirstAppear {
                self.viewModel.connect()
            }
    }

    @ViewBuilder
    private var content: some View {
        switch self.viewModel.authState {
        case .loading:
            LoadingView()
                .transition(.blurReplace)
        case .error:
            PlaceholderView.error {
                self.viewModel.reconnect()
            }
            .transition(.blurReplace)
        case .unauthenticated:
            LoginScreenView()
                .transition(.blurReplace)
        case .authenticated:
            AgentsListScreenView()
                .transition(.blurReplace)
        }
    }

}
