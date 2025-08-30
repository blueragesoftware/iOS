import SwiftUI

struct AgentLoadedAboutSectionView: View {
    
    @Binding var name: String
    
    @Binding var goal: String
    
    @Binding var modelId: String

    @FocusState.Binding var isFocused: Bool

    private let updateAgent: (_ name: String?, _ goal: String?, _ modelId: String?) -> Void

    init(name: Binding<String>,
         goal: Binding<String>,
         modelId: Binding<String>,
         isFocused: FocusState<Bool>.Binding,
         updateAgent: @escaping (_: String?, _: String?, _: String?) -> Void) {
        self._name = name
        self._goal = goal
        self._modelId = modelId
        self._isFocused = isFocused
        self.updateAgent = updateAgent
    }

    var body: some View {
        Section {
            TextField("Name", text: self.$name)
                .onChange(of: self.name) { _, newValue in
                    self.updateAgent(newValue, nil, nil)
                }
                .focused(self.$isFocused)

            TextField("Goal", text: self.$goal)
                .onChange(of: self.goal) { _, newValue in
                    self.updateAgent(nil, newValue, nil)
                }
                .focused(self.$isFocused)

            Picker("Model", selection: self.$modelId) {
                Text("Claude Sonnet 4")
                    .tag("claude-sonnet-4")
                
                Text("GPT-5")
                    .tag("gpt-5")
            }
            .onChange(of: self.modelId) { _, newValue in
                self.updateAgent(nil, nil, newValue)
            }
        } header: {
            Text("About")
        }
    }

}
