import SwiftUI
import SwiftUIIntrospect

struct MCPServerEditSectionView: View {

    typealias MCPServerUpdate = (name: String?, url: String?, apiKey: String??)

    @Binding private var name: String

    @Binding private var url: String

    @Binding private var apiKey: String

    private var isFocused: FocusState<Bool>.Binding

    private let onUpdate: (MCPServerUpdate) -> Void

    init(name: Binding<String>,
         url: Binding<String>,
         apiKey: Binding<String>,
         isFocused: FocusState<Bool>.Binding,
         onUpdate: @escaping (MCPServerUpdate) -> Void) {
        self._name = name
        self._url = url
        self._apiKey = apiKey
        self.isFocused = isFocused
        self.onUpdate = onUpdate
    }

    var body: some View {
        Section {
            TextField(BluerageStrings.mcpServerNameFieldTitle, text: self.$name)
                .focused(self.isFocused)
                .onChange(of: self.name) { _, newValue in
                    self.onUpdate((newValue, nil, nil))
                }

            TextField(BluerageStrings.mcpServerUrlFieldTitle, text: self.$url)
                .focused(self.isFocused)
                .onChange(of: self.url) { _, newValue in
                    self.onUpdate((nil, newValue, nil))
                }
        } header: {
            Text(BluerageStrings.mcpServerConfigurationSectionTitle)
        }

        Section {
            SecureField(BluerageStrings.mcpServerAuthenticationFieldTitle,
                        text: self.$apiKey,
                        prompt: Text(BluerageStrings.mcpServerAuthenticationPlaceholder))
            .introspect(.secureField, on: .iOS(.v17, .v18, .v26)) { secureField in
                secureField.clearButtonMode = .whileEditing
                secureField.clearsOnInsertion = true
            }
            .focused(self.isFocused)
            .onChange(of: self.apiKey) { _, newValue in
                self.onUpdate((nil, nil, newValue.isEmpty ? Optional(nil) : newValue))
            }
        } header: {
            Text(BluerageStrings.mcpServerAuthenticationSectionTitle)
        }
    }

}
