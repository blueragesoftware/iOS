import SwiftUI

struct CustomModelEditSectionView: View {

    @Binding private var name: String

    @Binding private var provider: String

    @Binding private var modelId: String

    @Binding private var apiKey: String

    private var isFocused: FocusState<Bool>.Binding

    private let onUpdate: (String, String, String, String) -> Void

    init(name: Binding<String>,
         provider: Binding<String>,
         modelId: Binding<String>,
         apiKey: Binding<String>,
         isFocused: FocusState<Bool>.Binding,
         onUpdate: @escaping (String, String, String, String) -> Void) {
        self._name = name
        self._provider = provider
        self._modelId = modelId
        self._apiKey = apiKey
        self.isFocused = isFocused
        self.onUpdate = onUpdate
    }

    var body: some View {
        Section {
            TextField("Model Name", text: self.$name, prompt: Text("e.g., GPT-5"))
                .focused(self.isFocused)
                .onChange(of: self.name) { _, newValue in
                    self.onUpdate(newValue, self.provider, self.modelId, self.apiKey)
                }

            Picker("Provider", selection: self.$provider) {
                Text("OpenAI")
                    .tag("openai")
            }
            .onChange(of: self.provider) { _, newValue in
                self.onUpdate(self.name, newValue, self.modelId, self.apiKey)
            }

            TextField("Model ID", text: self.$modelId, prompt: Text("e.g., gpt-5"))
                .focused(self.isFocused)
                .onChange(of: self.modelId) { _, newValue in
                    self.onUpdate(self.name, self.provider, newValue, self.apiKey)
                }
        } header: {
            Text("Model Configuration")
        }

        Section {
            SecureField("API Key", text: self.$apiKey, prompt: Text("sk-..."))
                .focused(self.isFocused)
                .onChange(of: self.apiKey) { _, newValue in
                    self.onUpdate(self.name, self.provider, self.modelId, newValue)
                }
        } header: {
            Text("Authentication")
        } footer: {
            Text("Your API key will be encrypted and stored securely.")
        }
    }

}
