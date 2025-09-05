import SwiftUI

struct ToolsSelectionLoadedView: View {

    private struct TrailingAccessory: View {

        private let tool: Tool

        init(tool: Tool) {
            self.tool = tool
        }

        var body: some View {
            switch self.tool.status {
            case .initializing, .initiated:
                ProgressView()
            case .active:
                Image(systemName: "plus")
            case .failed, .expired:
                Image(systemName: "exclamationmark.triangle.fill")
            case .inactive:
                Image(systemName: "link.badge.plus")
            }
        }

    }

    private let activeTools: [Tool]

    private let inactiveTools: [Tool]

    private let onActiveToolSelected: (Tool) -> Void

    private let onInactiveToolSelected: (Tool) -> Void

    init(activeTools: [Tool],
         inactiveTools: [Tool],
         onActiveToolSelected: @escaping (Tool) -> Void,
         onInactiveToolSelected: @escaping (Tool) -> Void) {
        self.activeTools = activeTools
        self.inactiveTools = inactiveTools
        self.onActiveToolSelected = onActiveToolSelected
        self.onInactiveToolSelected = onInactiveToolSelected
    }

    var body: some View {
        List {
            if !self.activeTools.isEmpty {
                Section {
                    ForEach(self.activeTools) { tool in
                        ToolCellView(tool: tool) { tool in
                            self.onActiveToolSelected(tool)
                        } trailingAccessory: { tool in
                            TrailingAccessory(tool: tool)
                        }
                    }
                } header: {
                    Text("Ready to Connect")
                }
            }

            if !self.inactiveTools.isEmpty {
                Section {
                    ForEach(self.inactiveTools) { tool in
                        ToolCellView(tool: tool) { tool in
                            self.onInactiveToolSelected(tool)
                        } trailingAccessory: { tool in
                            TrailingAccessory(tool: tool)
                        }
                    }
                } header: {
                    Text("Disconnected")
                }
            }
        }
    }

}
