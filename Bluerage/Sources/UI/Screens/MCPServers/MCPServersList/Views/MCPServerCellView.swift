import SwiftUI

struct MCPServerCellView: View {

    private let mcpServer: MCPServer

    private let onOpen: () -> Void

    init(mcpServer: MCPServer,
         onOpen: @escaping () -> Void) {
        self.mcpServer = mcpServer
        self.onOpen = onOpen
    }

    var body: some View {
        Button {
            self.onOpen()
        } label: {
            HStack(spacing: 0) {
                Text(self.mcpServer.name)
                    .font(.system(size: 16, weight: .semibold))
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
                    .foregroundStyle(.primary)

                Spacer()

                OpenButton(onOpen: self.onOpen)
            }
        }
    }

}
