import SwiftUI

struct AgentLoadedToolsSectionView: View {
    
    private let viewModel: AgentLoadedViewModel

    private let onAddTool: () -> Void

    init(viewModel: AgentLoadedViewModel, onAddTool: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onAddTool = onAddTool
    }

    var body: some View {
        Section {
            ForEach(Array(zip(self.viewModel.tools.indices, self.viewModel.tools)), id: \.1.id) { index, toolItem in
                switch toolItem {
                case .content(let tool):
                    Text(tool.name)
                case .empty:
                    Button {
                        self.onAddTool()
                    } label: {
                        Text("Add a Tool")
                            .foregroundStyle(.link)
                    }
                    .deleteDisabled(true)
                }
            }
            .onDelete { offsets in
                self.viewModel.deleteTools(at: offsets)
            }
        } header: {
            Text("Tools")
        } footer: {
            Text("Swipe left to delete")
        }
    }
}
