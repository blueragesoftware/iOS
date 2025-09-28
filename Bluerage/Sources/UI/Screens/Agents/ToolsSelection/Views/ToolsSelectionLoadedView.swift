import SwiftUI

struct ToolsSelectionLoadedView: View {

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
                        }
                    }
                } header: {
                    Text(BluerageStrings.toolsSelectionReadyToConnectSectionHeader)
                }
            }

            if !self.inactiveTools.isEmpty {
                Section {
                    ForEach(self.inactiveTools) { tool in
                        ToolCellView(tool: tool) { tool in
                            self.onInactiveToolSelected(tool)
                        }
                    }
                } header: {
                    Text(BluerageStrings.toolsSelectionDisconnectedSectionHeader)
                }
            }
        }
    }

}
