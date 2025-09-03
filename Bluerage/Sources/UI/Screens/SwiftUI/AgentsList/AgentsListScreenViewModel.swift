import FactoryKit
import ConvexMobile
import OSLog
import Combine

@Observable
@MainActor
final class AgentsListScreenViewModel {

    enum State: CustomStringConvertible {
        case loading
        case loaded(agents: [Agent])
        case empty
        case error(Error)

        var isLoading: Bool {
            switch self {
            case .loading:
                true
            default:
                false
            }
        }

        var isError: Bool {
            switch self {
            case .error:
                true
            default:
                false
            }
        }

        var isLoaded: Bool {
            switch self {
            case .loaded:
                true
            default:
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

        self.connection = self.convex.subscribe(to: "agents:getAll", yielding: [Agent].self)
            .removeDuplicates()
            .map { agents in
                return State.loaded(agents: agents)
            }
            .replaceEmpty(with: .empty)
            .replaceNil(with: .empty)
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
