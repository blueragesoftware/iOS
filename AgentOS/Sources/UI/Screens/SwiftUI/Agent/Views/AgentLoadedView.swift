import SwiftUI
import NukeUI

struct AgentLoadedView: View {

    enum Emptyable<V: Identifiable>: Identifiable {
        case value(V)
        case empty

        var id: AnyHashable {
            switch self {
            case .value(let value):
                return AnyHashable(value.id)
            case .empty:
                return AnyHashable("Empty")
            }
        }
    }

    struct Tool: Identifiable {
        let id: String

        var name: String
    }

    struct Step: Identifiable {
        let id: String

        var name: String
    }

    @State private var name: String = ""

    @State private var goal: String = ""

    @State private var model: String = "Claude Sonnet 4"

    @State private var tools: [Tool] = [
        Tool(id: UUID().uuidString, name: ""),
        Tool(id: UUID().uuidString, name: "")
    ]

    @State private var steps: [Step] = [
        Step(id: UUID().uuidString, name: ""),
        Step(id: UUID().uuidString, name: "")
    ]


    private let agent: Agent

    init(agent: Agent) {
        self.agent = agent
    }

    var body: some View {
        Form {
            Section {
                
            } header: {
                LazyImage(url: URL(string: self.agent.iconUrl)) { state in
                    if let image = state.image {
                        image.resizable().aspectRatio(contentMode: .fit)
                    } else {
                        UIColor.quaternarySystemFill.swiftUI
                    }
                }
                .processors([.resize(height: AgentSizeProvider.iconSize), .circle()])
                .clipShape(Circle())
                .frame(width: AgentSizeProvider.iconSize, height: AgentSizeProvider.iconSize)
                .fixedSize()
                .padding(.trailing, 16)
                .frame(maxWidth: .infinity, alignment: .center)
            }

            Section {
                TextField("Name", text: self.$name)
                TextField("Goal", text: self.$goal)
                Picker("Model", selection: self.$model) {
                    ForEach(["Claude Sonnet 4", "GPT-5"], id: \.self) { option in
                        Text(option)
                    }
                }

            } header: {
                Text("About")
            }

            Section {
                ForEach(self.$tools) { $tool in
                    TextField(tool.id == self.tools.last?.id ? "Add a Tool" : "Tool", text: $tool.name)
                        .onChange(of: tool.name) { _, newValue in
                            // If this is the last tool and user started typing, add a new empty tool
                            if let lastTool = self.tools.last,
                               lastTool.id == tool.id,
                               !newValue.isEmpty {
                                self.tools.append(Tool(id: UUID().uuidString, name: ""))
                            }
                            // If this is the second-to-last tool and it became empty, remove the last empty tool
                            else if self.tools.count > 1,
                                    self.tools[self.tools.count - 2].id == tool.id,
                                    newValue.isEmpty,
                                    let lastTool = self.tools.last,
                                    lastTool.name.isEmpty {
                                self.tools.removeLast()
                            }
                        }
                }
            } header: {
                Text("Tools")
            }

            Section {
                ForEach(self.$steps) { $step in
                    TextField(step.id == self.steps.last?.id ? "Add a Step" : "Step", text: $step.name)
                        .onChange(of: step.name) { _, newValue in
                            // If this is the last step and user started typing, add a new empty step
                            if let lastStep = self.steps.last,
                               lastStep.id == step.id,
                               !newValue.isEmpty {
                                self.steps.append(Step(id: UUID().uuidString, name: ""))
                            }
                            // If this is the second-to-last step and it became empty, remove the last empty step
                            else if self.steps.count > 1,
                                    self.steps[self.steps.count - 2].id == step.id,
                                    newValue.isEmpty,
                                    let lastStep = self.steps.last,
                                    lastStep.name.isEmpty {
                                self.steps.removeLast()
                            }
                        }
                }
            } header: {
                Text("Steps")
            }

        }
        .background(UIColor.systemGroupedBackground.swiftUI)
        .overlay {
            VStack(spacing: 0) {
                Spacer()

                self.actionButtons
            }
            .ignoresSafeArea(.keyboard)
        }
    }

    @ViewBuilder private var actionButtons: some View {
        HStack(spacing: 10) {
            Button {

            } label: {
                Text("Executions")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(UIColor.label.swiftUI)
                    .padding(.vertical, 15)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderGradientProminentButtonStyle)

            Button {

            } label: {
                Text("Run Agent")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(UIColor.systemBackground.swiftUI)
                    .padding(.vertical, 15)
                    .frame(maxWidth: .infinity)
            }

            .buttonStyle(.primaryButtonStyle)
        }
        .padding(.horizontal, 20)
    }

}

#Preview {
    AgentLoadedView(agent: Agent(id: "", name: "Test Agent", description: "Test description", iconUrl: "", goal: "Goal", tools: ["aboba", "Biba"], steps: [], model: "gpt-4.1"))
}
