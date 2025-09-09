import SwiftUI

struct CustomModelEditSectionView: View {

    typealias CustomModelUpdate = (name: String?, provider: String?, modelId: String?, encryptedApiKey: String?, baseUrl: String?)

    @Binding private var name: String

    @Binding private var provider: String

    @Binding private var modelId: String

    @Binding private var encryptedApiKey: String

    @Binding private var baseUrl: String

    private var isFocused: FocusState<Bool>.Binding

    private let onUpdate: (CustomModelUpdate) -> Void

    init(name: Binding<String>,
         provider: Binding<String>,
         modelId: Binding<String>,
         encryptedApiKey: Binding<String>,
         baseUrl: Binding<String>,
         isFocused: FocusState<Bool>.Binding,
         onUpdate: @escaping (CustomModelUpdate) -> Void) {
        self._name = name
        self._provider = provider
        self._modelId = modelId
        self._encryptedApiKey = encryptedApiKey
        self._baseUrl = baseUrl
        self.isFocused = isFocused
        self.onUpdate = onUpdate
    }

    var body: some View {
        Section {
            TextField("Model Name", text: self.$name)
                .focused(self.isFocused)
                .onChange(of: self.name) { _, newValue in
                    self.onUpdate((newValue, nil, nil, nil, nil))
                }

            Picker("Provider", selection: self.$provider) {
                Text("OpenAI")
                    .tag("openai")
            }
            .onChange(of: self.provider) { _, newValue in
                self.onUpdate((nil, newValue, nil, nil, nil))
            }

            TextField("Model ID", text: self.$modelId)
                .focused(self.isFocused)
                .onChange(of: self.modelId) { _, newValue in
                    self.onUpdate((nil, nil, newValue, nil, nil))
                }

            TextField("Base URL", text: self.$baseUrl)
                .focused(self.isFocused)
                .onChange(of: self.baseUrl) { _, newValue in
                    self.onUpdate((nil, nil, nil, nil, newValue.isEmpty ? nil : newValue))
                }
        } header: {
            Text("Model Configuration")
        }

        Section {
            SecureField("API Key", text: self.$encryptedApiKey, prompt: Text("sk-..."))
                .focused(self.isFocused)
                .onChange(of: self.encryptedApiKey) { _, newValue in
                    self.onUpdate((nil, nil, nil, newValue, nil))
                }
        } header: {
            Text("Authentication")
        } footer: {
            Text("Your API key will be stored securely on our servers.")
        }
    }

}
