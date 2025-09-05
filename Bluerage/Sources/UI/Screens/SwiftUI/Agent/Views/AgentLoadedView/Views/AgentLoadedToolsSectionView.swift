import SwiftUI

struct AgentLoadedToolsSectionView: View {
    
    private let tools: [EditableToolItem]

    private let onRemove: ([String]) -> Void

    private let onAdd: () -> Void

    init(tools: [EditableToolItem],
         onRemove: @escaping ([String]) -> Void,
         onAdd: @escaping () -> Void) {
        self.tools = tools
        self.onRemove = onRemove
        self.onAdd = onAdd
    }

    var body: some View {
        Section {
            ForEach(Array(zip(self.tools.indices, self.tools)), id: \.1.id) { index, toolItem in
                switch toolItem {
                case .content(let tool):
                    ToolCellView(tool: tool)
                        .selectionDisabled()
                case .empty:
                    Button {
                        self.onAdd()
                    } label: {
                        Text("Add a Tool")
                            .foregroundStyle(.link)
                    }
                    .deleteDisabled(true)
                }
            }
            .onDelete { offsets in
                let tools = self.tools

                let idsToRemove = offsets.compactMap { offset in
                    return tools[safeIndex: offset]?.id
                }

                self.onRemove(idsToRemove)
            }
        } header: {
            Text("Tools")
        } footer: {
            Text("Swipe left to delete")
        }
    }
}
