import SwiftUI

struct AgentLoadedAboutSectionView: View {

    @Binding private var name: String

    @Binding private var goal: String

    @Binding private var model: Model

    @FocusState.Binding private var isFocused: Bool

    let availableModels: [Model]

    private let onUpdate: (AgentHeaderUpdateParams) -> Void

    init(name: Binding<String>,
         goal: Binding<String>,
         model: Binding<Model>,
         availableModels: [Model],
         isFocused: FocusState<Bool>.Binding,
         onUpdate: @escaping (AgentHeaderUpdateParams) -> Void) {
        self._name = name
        self._goal = goal
        self._model = model
        self.availableModels = availableModels
        self._isFocused = isFocused
        self.onUpdate = onUpdate
    }

    var body: some View {
        Section {
            TextField("agent_name_placeholder", text: self.$name, axis: .vertical)
                .multilineTextAlignment(.leading)
                .onChange(of: self.name) { _, newValue in
                    self.onUpdate((newValue, nil, nil))
                }
                .focused(self.$isFocused)

            TextField("agent_goal_placeholder", text: self.$goal, axis: .vertical)
                .multilineTextAlignment(.leading)
                .onChange(of: self.goal) { _, newValue in
                    self.onUpdate((nil, newValue, nil))
                }
                .focused(self.$isFocused)

            Picker("agent_model_picker_title", selection: self.$model) {
                ForEach(self.availableModels) { model in
                    Text(model.name)
                        .tag(model)
                }
            }
            .onChange(of: self.model) { _, newValue in
                self.onUpdate((nil, nil, newValue.id))
            }
        } header: {
            Text("agent_about_section_header")
        }
    }

}
