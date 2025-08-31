import SwiftUI

struct AgentLoadedAboutSectionView: View {
    
    @Binding var name: String
    
    @Binding var goal: String
    
    @Binding var model: Model

    let availableModels: [Model]

    @FocusState.Binding var isFocused: Bool

    private let updateAgent: (_ name: String?, _ goal: String?, _ modelId: String?) -> Void

    init(name: Binding<String>,
         goal: Binding<String>,
         model: Binding<Model>,
         availableModels: [Model],
         isFocused: FocusState<Bool>.Binding,
         updateAgent: @escaping (_: String?, _: String?, _: String?) -> Void) {
        self._name = name
        self._goal = goal
        self._model = model
        self.availableModels = availableModels
        self._isFocused = isFocused
        self.updateAgent = updateAgent
    }

    var body: some View {
        Section {
            TextField("Name", text: self.$name, axis: .vertical)
                .multilineTextAlignment(.leading)
                .onChange(of: self.name) { _, newValue in
                    self.updateAgent(newValue, nil, nil)
                }
                .focused(self.$isFocused)

            TextField("Goal", text: self.$goal, axis: .vertical)
                .multilineTextAlignment(.leading)
                .onChange(of: self.goal) { _, newValue in
                    self.updateAgent(nil, newValue, nil)
                }
                .focused(self.$isFocused)

            Picker("Model", selection: self.$model) {
                ForEach(self.availableModels) { model in
                    Text(model.name)
                        .tag(model)
                }
            }
            .onChange(of: self.model) { _, newValue in
                self.updateAgent(nil, nil, newValue.id)
            }
        } header: {
            Text("About")
        }
    }

}
