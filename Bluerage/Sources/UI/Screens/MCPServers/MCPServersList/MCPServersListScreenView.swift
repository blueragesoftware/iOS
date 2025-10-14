import SwiftUI
import OSLog
import PostHog
import NavigatorUI
import FactoryKit

struct MCPServersListScreenView: View {

    @State private var viewModel = MCPServersListScreenViewModel()

    @Injected(\.hapticManager) private var hapticManager

    @Environment(\.navigator) private var navigator

    var body: some View {
        self.content
            .transition(.blurReplace)
            .navigationDestinationAutoReceive(MCPServersListDestinations.self)
            .safeAreaInset(edge: .bottom) {
                if self.viewModel.state.main.isLoaded {
                    ActionButton(title: BluerageStrings.mcpServersCreateButtonTitle) {
                        self.createNewMCPServer()
                    }
                    .isLoading(self.viewModel.state.isCreatingNewMCPServer)
                    .padding(.horizontal, 20)
                }
            }
            .scrollDisabled(self.viewModel.state.main.isLoading || self.viewModel.state.main.isError)
            .onFirstAppear {
                self.viewModel.connect()
            }
            .navigationTitle(BluerageStrings.mcpServersNavigationTitle)
            .toolbarTitleDisplayMode(.inline)
            .background(UIColor.systemGroupedBackground.swiftUI)
            .errorAlert(error: self.viewModel.state.alertError) {
                self.viewModel.resetAlertError()
            }
            .postHogScreenView("MCPServersListScreenView")
    }

    @ViewBuilder
    private var content: some View {
        switch self.viewModel.state.main {
        case .loading:
            SkeletonMCPServersListView()
        case .loaded(let mcpServers):
            LoadedMCPServersListView(mcpServers: mcpServers,
                                     onRemove: { ids in
                self.removeMCPServers(with: ids)
            })
        case .empty:
            EmptyMCPServersListView {
                self.createNewMCPServer()
            }
        case .error:
            ErrorMCPServersListView {
                self.viewModel.connect()
            }
        }
    }

    private func createNewMCPServer() {
        self.hapticManager.triggerSelectionFeedback()

        Task {
            do {
                let mcpServer = try await self.viewModel.createNewMCPServer()

                self.navigator.navigate(to: MCPServersListDestinations.mcpServer(id: mcpServer.id))
            } catch {
                Logger.customModels.error("Error creating new mcp server: \(error.localizedDescription, privacy: .public)")

                self.viewModel.showErrorAlert(with: error)
            }
        }
    }

    private func removeMCPServers(with ids: [String]) {
        Task {
            do {
                try await self.viewModel.removeMCPServers(with: ids)
            } catch {
                Logger.mcpServers.error("Error removing servers: \(error.localizedDescription, privacy: .public)")

                self.viewModel.showErrorAlert(with: error)
            }
        }
    }

}
