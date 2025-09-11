import SwiftUI

struct AgentLoadedAboutSectionView: View {

    @Binding private var name: String

    @Binding private var goal: String

    @Binding private var modelId: String

    @FocusState.Binding private var isFocused: Bool

    let availableModels: AllModelsResponse

    private let onUpdate: (AgentHeaderUpdateParams) -> Void

    init(name: Binding<String>,
         goal: Binding<String>,
         modelId: Binding<String>,
         availableModels: AllModelsResponse,
         isFocused: FocusState<Bool>.Binding,
         onUpdate: @escaping (AgentHeaderUpdateParams) -> Void) {
        self._name = name
        self._goal = goal
        self._modelId = modelId
        self.availableModels = availableModels
        self._isFocused = isFocused
        self.onUpdate = onUpdate
    }

    var body: some View {
        Section {
            TextField(BluerageStrings.agentNamePlaceholder, text: self.$name, axis: .vertical)
                .multilineTextAlignment(.leading)
                .onChange(of: self.name) { _, newValue in
                    self.onUpdate((newValue, nil, nil))
                }
                .focused(self.$isFocused)

            TextField(BluerageStrings.agentGoalPlaceholder, text: self.$goal, axis: .vertical)
                .multilineTextAlignment(.leading)
                .onChange(of: self.goal) { _, newValue in
                    self.onUpdate((nil, newValue, nil))
                }
                .focused(self.$isFocused)

            Picker(BluerageStrings.agentModelPickerTitle, selection: self.$modelId) {
                Section {
                    ForEach(self.availableModels.models) { model in
                        Text(model.name)
                            .tag(model.id)
                    }
                } header: {
                    Text("Default")
                }

                Section {
                    ForEach(self.availableModels.customModels) { customModel in
                        Text(customModel.name)
                            .tag(customModel.id)
                    }
                } header: {
                    Text("Custom")
                }
            }
            .onChange(of: self.modelId) { _, newValue in
                if let model = self.availableModels.models.first(where: { model in
                    return model.id == newValue
                }) {
                    self.onUpdate((nil, nil, .model(id: model.id)))
                } else if let customModel = self.availableModels.customModels.first(where: { customModel in
                    return customModel.id == newValue
                }) {
                    self.onUpdate((nil, nil, .customModel(id: customModel.id)))
                }
            }
        } header: {
            Text(BluerageStrings.agentAboutSectionHeader)
        }
    }

}
