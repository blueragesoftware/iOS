import FactoryKit
import ConvexMobile
import OSLog
import Combine

@MainActor
@Observable
final class MCPServersListScreenViewModel {

    struct State {

        var main: LoadingViewModelState<[MCPServer]>

        var alertError: Error?

    }

    private(set) var state = State(main: .loading)

    @ObservationIgnored
    @Injected(\.convex) private var convex

    @ObservationIgnored
    @Injected(\.keyedExecutor) private var keyedExecutor

    @ObservationIgnored
    private var connection: AnyCancellable?

    func connect() {
        self.state.main = .loading

        self.connection?.cancel()
        self.connection = nil

        self.connection = self.convex.subscribe(to: "mcpServers:getAll",
                                                yielding: [MCPServer].self)
            .removeDuplicates()
            .map { mcpServers in
                if mcpServers.isEmpty {
                    return LoadingViewModelState.empty
                }

                return LoadingViewModelState.loaded(mcpServers)
            }
            .catch { error in
                Logger.mcpServers.error("Error receiving all servers: \(error.localizedDescription, privacy: .public)")

                return Just(LoadingViewModelState<[MCPServer]>.error(error))
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] main in
                self?.state.main = main
            }
    }

    func createNewMCPServer() async throws -> MCPServer {
        try await self.keyedExecutor.executeOperation(for: "mcpServers/create") {
            try await self.convex.mutation("mcpServers:create")
        }
    }

    func removeMCPServers(with ids: [String]) async throws {
        try await self.keyedExecutor.executeOperation(for: "mcpServers/removeByIds/\(ids)") {
            try await self.convex.mutation("mcpServers:removeByIds", with: ["ids": ids])
        }
    }

    func showErrorAlert(with error: Error) {
        self.state.alertError = error
    }

    func resetAlertError() {
        self.state.alertError = nil
    }

}
