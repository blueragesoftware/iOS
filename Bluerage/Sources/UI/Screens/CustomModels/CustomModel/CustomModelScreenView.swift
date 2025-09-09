import SwiftUI
import PostHog
import NavigatorUI

struct CustomModelScreenView: View {

    private let customModelId: String

    @State private var viewModel: CustomModelScreenViewModel

    init(customModelId: String) {
        self.customModelId = customModelId
        self.viewModel = CustomModelScreenViewModel(customModelId: customModelId)
    }

    var body: some View {
        self.content
            .onFirstAppear {
                self.viewModel.connect()
            }
            .postHogScreenView("CustomModelScreenView", ["customModelId": self.customModelId])
    }

    @ViewBuilder
    private var content: some View {
        switch self.viewModel.state {
        case .loading:
            LoadingView()
                .transition(.blurReplace)
        case .loaded(let loadedViewModel):
            CustomModelLoadedView(viewModel: loadedViewModel)
                .transition(.blurReplace)
        case .error:
            PlaceholderView.error {
                self.viewModel.connect()
            }
            .transition(.blurReplace)
        }
    }

}
