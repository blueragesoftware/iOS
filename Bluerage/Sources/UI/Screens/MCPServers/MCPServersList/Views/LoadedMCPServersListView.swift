import SwiftUI
import FactoryKit
import NavigatorUI

struct LoadedMCPServersListView: View {

    private let mcpServers: [MCPServer]

    private let onRemove: ([String]) -> Void

    @Environment(\.navigator) private var navigator

    @Injected(\.hapticManager) private var hapticManager

    init(mcpServers: [MCPServer],
         onRemove: @escaping ([String]) -> Void) {
        self.mcpServers = mcpServers
        self.onRemove = onRemove
    }

    var body: some View {
        List {
            ForEach(self.mcpServers) { mcpServer in
                MCPServerCellView(mcpServer: mcpServer) {
                    self.hapticManager.triggerSelectionFeedback()
                    self.navigator.navigate(to: MCPServersListDestinations.mcpServer(id: mcpServer.id))
                }
                .padding(.bottom, 28)
                .padding(.horizontal, 20)
            }
            .onDelete { offsets in
                let mcpServers = self.mcpServers

                let idsToRemove = offsets.compactMap { offset in
                    return mcpServers[safeIndex: offset]?.id
                }

                self.onRemove(idsToRemove)
            }
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
    }

}
