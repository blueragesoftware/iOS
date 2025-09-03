import FactoryKit
import ConvexMobile
import OSLog
import Combine
import SwiftUI

@Observable
@MainActor
final class AgentScreenViewModel {

    enum State {
        case loaded(agent: Agent, model: Model, tools: [Tool], availableModels: [Model])
        case loading
        case error(Error)
    }
    
    private struct UpdateRequest: Equatable {
        var name: String?
        var description: String?
        var iconUrl: String?
        var goal: String?
        var tools: [Agent.Tool]?
        var steps: [Agent.Step]?
        var modelId: String?

        var hasUpdates: Bool {
            return self.name != nil
            || self.description != nil
            || self.iconUrl != nil
            || self.goal != nil
            || self.tools != nil
            || self.steps != nil
            || self.modelId != nil
        }

        mutating func merge(with other: UpdateRequest) {
            if let otherName = other.name { self.name = otherName }
            if let otherDescription = other.description { self.description = otherDescription }
            if let otherIconUrl = other.iconUrl { self.iconUrl = otherIconUrl }
            if let otherGoal = other.goal { self.goal = otherGoal }
            if let otherTools = other.tools { self.tools = otherTools }
            if let otherSteps = other.steps { self.steps = otherSteps }
            if let otherModelId = other.modelId { self.modelId = otherModelId }
        }
    }

    private enum UpdateAction {
        case merge(UpdateRequest)
        case reset
    }

    private(set) var state: State = .loading

    @ObservationIgnored
    @Injected(\.convex) private var convex

    @ObservationIgnored
    private var connection: AnyCancellable?

    @ObservationIgnored
    private var updatesQueueCancellables = Set<AnyCancellable>()

    @ObservationIgnored
    private let updateSubject = PassthroughSubject<UpdateAction, Never>()
    
    @ObservationIgnored
    private let currentAccumulatedSubject = CurrentValueSubject<UpdateRequest, Never>(UpdateRequest())

    @ObservationIgnored
    private let agentId: String

    init(agentId: String) {
        self.agentId = agentId

        self.setupUpdatesQueue()
    }

    func flush() {
        let currentRequest = self.currentAccumulatedSubject.value

        self.updateSubject.send(.reset)

        if currentRequest.hasUpdates {
            self.performUpdate(request: currentRequest)
        }
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
                    // TODO: return cache to not trigger the new fetch
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
            return State.loaded(agent: response.agent,
                                model: response.model,
                                tools: tools,
                                availableModels: models)
        }
        .catch { error in
            return Just(.error(error))
        }
        .receive(on: DispatchQueue.main)
        .sink { [weak self] state in
            withAnimation {
                self?.state = state
            }
        }
    }

    func updateAgent(name: String? = nil,
                     description: String? = nil,
                     iconUrl: String? = nil,
                     goal: String? = nil,
                     tools: [Tool]? = nil,
                     steps: [Agent.Step]? = nil,
                     modelId: String? = nil) {
        let request = UpdateRequest(
            name: name,
            description: description,
            iconUrl: iconUrl,
            goal: goal,
            tools: tools?.map { composioTool in
                return Agent.Tool(slug: composioTool.slug, name: composioTool.name)
            },
            steps: steps,
            modelId: modelId
        )

        self.updateSubject.send(.merge(request))
    }

    func run() {
        Task {
            do {
                try await self.convex.action("executeAgent:executeWithId", with: ["agentId": self.agentId])
            } catch {
                Logger.agent.error("Error running agent: \(error.localizedDescription)")
            }
        }
    }

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
                    let tools: [Tool] = try await self.convex.action("tools:getToolsBySlugsForUser", with: ["slugs": slugs])
                    promise(.success(tools))
                } catch {
                    promise(.failure(ClientError.ConvexError(data: error.localizedDescription)))
                }
            }
        }.eraseToAnyPublisher()
    }

    private func setupUpdatesQueue() {
        self.updateSubject
            .scan(UpdateRequest()) { accumulated, action in
                switch action {
                case .merge(let new):
                    var merged = accumulated
                    merged.merge(with: new)
                    return merged
                case .reset:
                    return UpdateRequest()
                }
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] accumulatedRequest in
                self?.currentAccumulatedSubject.send(accumulatedRequest)
            }
            .store(in: &self.updatesQueueCancellables)

        self.currentAccumulatedSubject
            .debounce(for: .seconds(2), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] mergedRequest in
                guard let self = self else {
                    return
                }

                if mergedRequest.hasUpdates {
                    self.performUpdate(request: mergedRequest)
                    self.updateSubject.send(.reset)
                }
            }
            .store(in: &self.updatesQueueCancellables)
    }
    
    private func performUpdate(request: UpdateRequest) {
        var args: [String: any ConvexEncodable] = ["id": self.agentId]

        if let name = request.name { args["name"] = name }
        if let description = request.description { args["description"] = description }
        if let iconUrl = request.iconUrl { args["iconUrl"] = iconUrl }
        if let goal = request.goal { args["goal"] = goal }
        if let tools = request.tools { args["tools"] = tools }
        if let steps = request.steps { args["steps"] = steps }
        if let modelId = request.modelId { args["modelId"] = modelId }
        
        guard args.count > 1 else {
            return
        }

        Task {
            do {
                try await self.convex.mutation("agents:update", with: args)
                Logger.agent.info("Agent updated successfully with \(args.count - 1) fields")
            } catch {
                Logger.agent.error("Failed to update agent: \(error.localizedDescription)")
            }
        }
    }

}
