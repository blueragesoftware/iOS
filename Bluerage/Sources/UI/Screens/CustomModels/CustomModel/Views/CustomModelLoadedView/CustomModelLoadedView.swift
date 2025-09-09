import SwiftUI

struct CustomModelLoadedView: View {

    @State private var viewModel: CustomModelLoadedViewModel

    @State private var name: String

    @State private var provider: String

    @State private var modelId: String

    @State private var apiKey: String

    @FocusState private var isFocused: Bool

    init(viewModel: CustomModelLoadedViewModel) {
        self._viewModel = State(wrappedValue: viewModel)

        self._name = State(wrappedValue: viewModel.customModel.name)
        self._provider = State(wrappedValue: viewModel.customModel.provider)
        self._modelId = State(wrappedValue: viewModel.customModel.modelId)

        let decryptedApiKey = EncryptionManager.decryptApiKey(viewModel.customModel.encryptedApiKey) ?? ""
        self._apiKey = State(wrappedValue: decryptedApiKey)
    }

    var body: some View {
        Form {
            CustomModelEditSectionView(
                name: self.$name,
                provider: self.$provider,
                modelId: self.$modelId,
                apiKey: self.$apiKey,
                isFocused: self.$isFocused,
                onUpdate: { name, provider, modelId, apiKey in
                    let encryptedApiKey = apiKey.isEmpty ? nil : EncryptionManager.encryptApiKey(apiKey)
                    self.viewModel.updateCustomModel(
                        name: name,
                        provider: provider,
                        modelId: modelId,
                        apiKey: encryptedApiKey
                    )
                }
            )
        }
        .scrollIndicators(.hidden)
        .background(UIColor.systemGroupedBackground.swiftUI)
        .safeAreaPadding(.bottom, 52)
        .overlay {
            KeyboardDismissView(isFocused: self.$isFocused)
        }
        .errorAlert(error: self.$viewModel.alertError)
        .onDisappear {
            self.viewModel.flush()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            self.viewModel.flush()
        }
        .navigationTitle("Custom Model")
        .navigationBarTitleDisplayMode(.inline)
    }

}
