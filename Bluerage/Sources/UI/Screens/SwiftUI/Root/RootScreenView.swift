import SwiftUI
import FactoryKit

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
