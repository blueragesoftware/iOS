import FactoryKit
import ConvexMobile
import OSLog
import Combine

@Observable
@MainActor
final class AgentScreenViewModel {

    enum State {
        case loaded(agent: Agent)
        case error(Error)
    }

    private(set) var state: State

    @ObservationIgnored
    @Injected(\.convex) private var convex

    @ObservationIgnored
    private var cancellables = Set<AnyCancellable>()

    @ObservationIgnored
    private let agentId: String

    init(agent: Agent) {
        self.agentId = agent.id
        self.state = .loaded(agent: agent)
    }

    func connect() {
        self.convex.subscribe(to: "agents:getById", with: ["id": self.agentId], yielding: Agent.self)
            .removeDuplicates()
            .map { agent in
                return State.loaded(agent: agent)
            }
            .catch { error in
                return Just(.error(error))
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.state = state
            }
            .store(in: &self.cancellables)
    }


}
