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
    
    private struct UpdateRequest: Equatable {
        var name: String?
        var description: String?
        var iconUrl: String?
        var goal: String?
        var tools: [String]?
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

    private(set) var state: State

    @ObservationIgnored
    @Injected(\.convex) private var convex

    @ObservationIgnored
    private var cancellables = Set<AnyCancellable>()

    @ObservationIgnored
    private let updateSubject = PassthroughSubject<UpdateAction, Never>()
    
    @ObservationIgnored
    private let currentAccumulatedSubject = CurrentValueSubject<UpdateRequest, Never>(UpdateRequest())

    @ObservationIgnored
    private let agentId: String

    init(agent: Agent) {
        self.agentId = agent.id
        self.state = .loaded(agent: agent)

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
            tools: tools?.map(\.id),
            steps: steps,
            modelId: modelId
        )

        self.updateSubject.send(.merge(request))
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
            .store(in: &self.cancellables)

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
            .store(in: &self.cancellables)
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
