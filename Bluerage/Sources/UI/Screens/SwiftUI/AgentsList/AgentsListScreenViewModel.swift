import FactoryKit
import ConvexMobile
import OSLog
import Combine

@Observable
@MainActor
final class AgentsListScreenViewModel {

    enum State: CustomStringConvertible, Equatable {

        static func == (lhs: State, rhs: State) -> Bool {
            return lhs.isError && rhs.isError
            || lhs.isLoading && rhs.isLoading
            || lhs.isLoaded && rhs.isLoaded
            || lhs.isEmpty && rhs.isEmpty
        }

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

        // MARK: - CustomStringConvertible

        var description: String {
            switch self {
            case .loading:
                "Loading"
            case .loaded:
                "Loaded"
            case .error:
                "Error"
            case .empty:
                "Empty"
            }
        }
    }

    private(set) var state: State = .loading

    @ObservationIgnored
    @Injected(\.convex) private var convex

    @ObservationIgnored
    private var connection: AnyCancellable?

    func connect() {
        self.state = .loading

        self.connection?.cancel()
        self.connection = nil

        self.connection = self.convex.subscribe(to: "agents:getAll",
                                                yielding: [Agent].self)
            .removeDuplicates()
            .map { agents in
                if agents.isEmpty {
                    return State.empty
                }

                return State.loaded(agents: agents)
            }
            .catch { error in
                return Just(.error(error))
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.state = state
            }
    }

    func createNewAgent() async throws -> Agent {
        return try await self.convex.mutation("agents:create")
    }

    func removeAgents(with ids: [String]) async throws {
        try await self.convex.mutation("agents:removeByIds", with: ["id": ids])
    }

}
