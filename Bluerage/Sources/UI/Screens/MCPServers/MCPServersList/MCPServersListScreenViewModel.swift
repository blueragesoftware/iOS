import FactoryKit
import ConvexMobile
import OSLog
import Combine

@MainActor
@Observable
final class MCPServersListScreenViewModel {

    struct State {

        enum Main: Equatable {

            // MARK: - Equatable

            static func == (lhs: Main, rhs: Main) -> Bool {
                return lhs.isError && rhs.isError
                || lhs.isLoading && rhs.isLoading
                || lhs.isLoaded && rhs.isLoaded
                || lhs.isEmpty && rhs.isEmpty
            }

            // MARK: - Properties

            case loading
            case loaded(mcpServers: [MCPServer])
            case empty
            case error(Error)

            var isLoading: Bool {
                if case .loading = self {
                    true
                } else {
                    false
                }
            }

            var isError: Bool {
                if case .error = self {
                    true
                } else {
                    false
                }
            }

            var isLoaded: Bool {
                if case .loaded = self {
                    true
                } else {
                    false
                }
            }

            var isEmpty: Bool {
                if case .empty = self {
                    true
                } else {
                    false
                }
            }

            var title: String {
                switch self {
                case .loading:
                    BluerageStrings.commonLoading
                case .loaded:
                    BluerageStrings.commonLoaded
                case .error:
                    BluerageStrings.commonError
                case .empty:
                    BluerageStrings.commonEmpty
                }
            }
        }

        var main: Main

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
                    return State.Main.empty
                }

                return State.Main.loaded(mcpServers: mcpServers)
            }
            .catch { error in
                Logger.mcpServers.error("Error receiving all servers: \(error.localizedDescription, privacy: .public)")

                return Just(State.Main.error(error))
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
