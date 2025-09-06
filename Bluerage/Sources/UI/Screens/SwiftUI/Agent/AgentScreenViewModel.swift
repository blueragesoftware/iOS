import FactoryKit
import ConvexMobile
import OSLog
import Combine
import SwiftUI

@MainActor
@Observable
final class AgentScreenViewModel {

    enum State {
        case loading
        case loaded(AgentLoadedViewModel)
        case error(Error)
    }

    private(set) var state: State = .loading

    let agentId: String

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

        typealias AgentData = (response: GetByIdWithModelResponse, tools: [Tool])

        let agentWithResolvedTools: AnyPublisher<AgentData, ClientError> = self.getAgentByIdWithModelPublisher(agentId: self.agentId)
            .pairwise()
            .flatMap { previousResponse, newResponse in
                let previousSlugs = previousResponse?.agent.tools.map(\.slug)
                let newSlugs = newResponse.agent.tools.map(\.slug)

                if newSlugs.isEmpty {
                    return Future<AgentData, ClientError> { promise in
                        promise(.success((newResponse, [])))
                    }
                    .eraseToAnyPublisher()
                }

                if newSlugs != previousSlugs {
                    return self.getToolsBySlugsPublisher(slugs: newSlugs)
                        .map { tools in
                            return (newResponse, tools)
                        }
                        .eraseToAnyPublisher()
                } else {
                    // TODO: return cache to not trigger the new fetch or do polling + convex as source of truth for Tools
                    return self.getToolsBySlugsPublisher(slugs: newSlugs)
                        .map { tools in
                            return (newResponse, tools)
                        }
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()

        self.connection = Publishers.CombineLatest(agentWithResolvedTools,
                                                   self.getAllModelsPublisher())
        .map { (agentData, models) in
            let (response, tools) = agentData

            let loadedViewModel = AgentLoadedViewModel(agentId: response.agent.id,
                                                       agent: response.agent,
                                                       model: response.model,
                                                       tools: tools,
                                                       availableModels: models)

            return State.loaded(loadedViewModel)
        }
        .catch { error in
            return Just(State.error(error))
        }
        .receive(on: DispatchQueue.main)
        .sink { [weak self] state in
            guard let self = self else {
                return
            }

            withAnimation {
                self.state = state
            }
        }
    }

    // MARK: - Private Methods

    private func getAgentByIdWithModelPublisher(agentId: String) -> AnyPublisher<GetByIdWithModelResponse, ClientError> {
        return self.convex.subscribe(to: "agents:getByIdWithModel",
                                     with: ["id": self.agentId],
                                     yielding: GetByIdWithModelResponse.self)
        .removeDuplicates()
        .eraseToAnyPublisher()
    }

    private func getAllModelsPublisher() -> AnyPublisher<[Model], ClientError> {
        return self.convex.subscribe(to: "models:getAll", yielding: [Model].self)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    private func getToolsBySlugsPublisher(slugs: [String]) -> AnyPublisher<[Tool], ClientError> {
        return Future { promise in
            Task {
                do {
                    let tools: [Tool] = try await self.convex.action("tools:getBySlugsForUser", with: ["slugs": slugs])
                    promise(.success(tools))
                } catch {
                    promise(.failure(ClientError.ConvexError(data: error.localizedDescription)))
                }
            }
        }.eraseToAnyPublisher()
    }

}
