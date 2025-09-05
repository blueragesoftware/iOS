import SwiftUI
import FactoryKit
import PostHog

struct RootScreenView: View {

    @State var viewModel = RootScreenViewModel()

    var body: some View {
        Group {
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
        .onAppear {
            self.viewModel.connect()
        }
    }

}
