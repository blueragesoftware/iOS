import SwiftUI

struct AgentLoadedToolsSectionView: View {

    private let tools: [Tool]

    private let onRemove: (IndexSet) -> Void

    private let onAdd: () -> Void

    private let onSelectTool: (Tool) -> Void

    init(tools: [Tool],
         onRemove: @escaping (IndexSet) -> Void,
         onAdd: @escaping () -> Void,
         onSelectTool: @escaping (Tool) -> Void) {
        self.tools = tools
        self.onRemove = onRemove
        self.onAdd = onAdd
        self.onSelectTool = onSelectTool
    }

    var body: some View {
        Section {
            ForEach(self.tools) { tool in
                ToolCellView(tool: tool) { tool in
                    self.onSelectTool(tool)
                }
            }
            .onDelete { offsets in
                self.onRemove(offsets)
            }

            Button {
                self.onAdd()
            } label: {
                Text(BluerageStrings.agentNewToolButtonTitle)
                    .foregroundStyle(.link)
            }
        } header: {
            Text(BluerageStrings.agentToolsSectionHeader)
        }
    }

}
