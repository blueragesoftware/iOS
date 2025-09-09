import SwiftUI

struct AgentLoadedToolsSectionView: View {

    private let tools: [EditableToolItem]

    private let onRemove: (IndexSet) -> Void

    private let onAdd: () -> Void

    init(tools: [EditableToolItem],
         onRemove: @escaping (IndexSet) -> Void,
         onAdd: @escaping () -> Void) {
        self.tools = tools
        self.onRemove = onRemove
        self.onAdd = onAdd
    }

    var body: some View {
        Section {
            ForEach(Array(zip(self.tools.indices, self.tools)), id: \.1.id) { _, toolItem in
                switch toolItem {
                case .content(let tool):
                    ToolCellView(tool: tool)
                        .selectionDisabled()
                case .empty:
                    Button {
                        self.onAdd()
                    } label: {
                        Text("agent_add_a_tool_button_title")
                            .foregroundStyle(.link)
                    }
                    .deleteDisabled(true)
                }
            }
            .onDelete { offsets in
                self.onRemove(offsets)
            }
        } header: {
            Text("agent_tools_section_header")
        } footer: {
            Text("agent_section_footer")
        }
    }

}
