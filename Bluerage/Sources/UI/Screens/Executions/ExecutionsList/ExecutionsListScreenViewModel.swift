import Foundation
import FactoryKit
import ConvexMobile
import OSLog
import Combine

@MainActor
@Observable
final class ExecutionsListScreenViewModel {

    enum State {
        case loading
        case loaded(tasks: [ExecutionTask])
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

    private(set) var state: State = .loading

    @ObservationIgnored
    private let agentId: String

    @ObservationIgnored
    @Injected(\.convex) private var convex

    @ObservationIgnored
    private var connection: AnyCancellable?

    init(agentId: String) {
        self.agentId = agentId
    }

    func connect() {
        self.state = .loading

        self.connection?.cancel()
        self.connection = nil

        self.connection = self.convex.subscribe(to: "agent.tasks:getAllByAgentId",
                                                with: ["agentId": self.agentId],
                                                yielding: [ExecutionTask].self)
        .removeDuplicates()
        .map { tasks in
            if tasks.isEmpty {
                return State.empty
            }

            return State.loaded(tasks: tasks)
        }
        .catch { error in
            return Just(.error(error))
        }
        .receive(on: DispatchQueue.main)
        .sink { [weak self] state in
            self?.state = state
        }
    }

}
