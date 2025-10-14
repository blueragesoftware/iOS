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
                    .foregroundStyle(.primary)
                    .padding(.leading, 12)

                Spacer()

                HStack(alignment: .center, spacing: 8) {
                    Text(self.mcpServer.status.localized)
                        .foregroundStyle(.secondary)

                    Circle()
                        .fill(self.statusColor)
                        .opacity(0.5)
                        .frame(width: 6, height: 6)

                    Image(systemName: "chevron.forward")
                        .renderingMode(.template)
                        .foregroundStyle(.primary)
                        .font(.system(size: 13, weight: .semibold))
                        .fixedSize()
                }
            }
        }
    }

    private var statusColor: Color {
        switch self.mcpServer.status {
        case .connected:
                .green
        case .connecting:
                .blue
        case .disconnected:
                .black
        case .error:
                .red
        }
    }

}
