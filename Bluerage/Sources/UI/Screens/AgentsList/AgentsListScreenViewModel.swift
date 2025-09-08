import FactoryKit
import ConvexMobile
import OSLog
import Combine

@MainActor
@Observable
final class AgentsListScreenViewModel {

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
            case loaded(agents: [Agent])
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
                    "common_loading".localized
                case .loaded:
                    "common_loaded".localized
                case .error:
                    "common_error".localized
                case .empty:
                    "common_empty".localized
                }
            }
        }

        var main: Main

        var alertError: Error?

    }

    private(set) var state: State = State(main: .loading)

    @ObservationIgnored
    @Injected(\.convex) private var convex

    @ObservationIgnored
    private var connection: AnyCancellable?

    func connect() {
        self.state.main = .loading

        self.connection?.cancel()
        self.connection = nil

        self.connection = self.convex.subscribe(to: "agents:getAll", yielding: [Agent].self)
            .removeDuplicates()
            .map { agents in
                if agents.isEmpty {
                    return State.Main.empty
                }

                return State.Main.loaded(agents: agents)
            }
            .catch { error in
                return Just(State.Main.error(error))
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] main in
                self?.state.main = main
            }
    }

    func createNewAgent() async throws -> Agent {
        return try await self.convex.mutation("agents:create")
    }

    func removeAgents(with ids: [String]) async throws {
        try await self.convex.mutation("agents:removeByIds", with: ["id": ids])
    }

    func showErrorAlert(with error: Error) {
        self.state.alertError = error
    }

    func resetAlertError() {
        self.state.alertError = nil
    }

}
