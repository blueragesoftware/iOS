import FactoryKit
import ConvexMobile
import OSLog
import Combine
import SwiftUI

@MainActor
@Observable
final class AgentLoadedViewModel {

    private struct UpdateRequest: Equatable, Encodable, ConvexEncodable {
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

    private static func editableTools(from tools: [Tool]) -> [EditableToolItem] {
        var toolsList: [EditableToolItem] = tools.map { .content($0) }
        toolsList.append(.empty(id: UUID().uuidString))
        return toolsList
    }

    private static func editableSteps(from steps: [Agent.Step]) -> [EditableStepItem] {
        var stepsList: [EditableStepItem] = steps.map { .content($0) }
        stepsList.append(.empty(id: UUID().uuidString))
        return stepsList
    }

    var alertError: Error?

    @ObservationIgnored
    var focusedStepIndex: Int? {
        didSet {
            if self.focusedStepIndex == nil {
                self.cleanupEmptySteps()
            }
        }
    }

    let agentId: String

    let agent: Agent

    let model: Model

    let availableModels: [Model]

    private(set) var editableTools: [EditableToolItem]

    private(set) var editableSteps: [EditableStepItem]

    @ObservationIgnored
    private var updatesQueueCancellables = Set<AnyCancellable>()

    @ObservationIgnored
    @Injected(\.convex) private var convex

    @ObservationIgnored
    private let updateSubject = CurrentValueSubject<UpdateAction, Never>(.reset)

    @ObservationIgnored
    private let currentAccumulatedSubject = CurrentValueSubject<UpdateRequest, Never>(UpdateRequest())

    // MARK: - Initialization

    init(agentId: String,
         agent: Agent,
         model: Model,
         tools: [Tool],
         availableModels: [Model]) {
        self.agentId = agentId
        self.agent = agent
        self.model = model
        self.availableModels = availableModels

        self.editableTools = Self.editableTools(from: tools)
        self.editableSteps = Self.editableSteps(from: agent.steps)

        self.setupUpdatesQueue()
    }

    // MARK: - Public Methods

    func run() {
        Task {
            do {
                try await self.convex.mutation("executionTasks:create", with: ["agentId": self.agentId])
            } catch {
                Logger.agent.error("Error running agent: \(error.localizedDescription, privacy: .public)")

                self.alertError = error
            }
        }
    }

    func flush() {
        var currentRequest = self.currentAccumulatedSubject.value
        let queueRequest = self.updateSubject.value

        if case .merge(let queueRequest) = queueRequest {
            currentRequest.merge(with: queueRequest)
        }

        self.updateSubject.send(.reset)

        if currentRequest.hasUpdates {
            self.performUpdate(request: currentRequest)
        }
    }

    func addTool(_ tool: Tool) {
        if let lastIndex = self.editableTools.indices.last,
           case .empty = self.editableTools[lastIndex] {
            self.editableTools[lastIndex] = .content(tool)
            self.editableTools.append(.empty(id: UUID().uuidString))
        } else {
            self.editableTools.append(.content(tool))
            self.editableTools.append(.empty(id: UUID().uuidString))
        }

        self.notifyToolsChanged()
    }

    func removeTools(at offsets: IndexSet) {
        self.editableTools.remove(atOffsets: offsets)
        self.notifyToolsChanged()
    }

    func handleStepChange(at index: Int, newValue: String) {
        guard index < self.editableSteps.count else {
            return
        }

        let currentStepItem = self.editableSteps[index]
        let isLast = index == self.editableSteps.count - 1
        let isFocused = self.focusedStepIndex == index

        if newValue.isEmpty {
            if isLast {
                return
            } else if isFocused {
                let stepId = currentStepItem.id
                self.editableSteps[index] = .empty(id: stepId)
                return
            } else {
                self.editableSteps.remove(at: index)

                if let focusedIndex = self.focusedStepIndex, focusedIndex > index {
                    self.focusedStepIndex = focusedIndex - 1
                }

                self.notifyStepsChanged()
            }
        } else {
            let stepId = currentStepItem.id
            self.editableSteps[index] = .content(Agent.Step(id: stepId, value: newValue))

            if isLast {
                self.editableSteps.append(.empty(id: UUID().uuidString))
            }

            self.notifyStepsChanged()
        }
    }

    func moveSteps(from: IndexSet, to: Int) {
        self.editableSteps.move(fromOffsets: from, toOffset: to)
        self.notifyStepsChanged()
    }

    func removeSteps(at offsets: IndexSet) {
        self.editableSteps.remove(atOffsets: offsets)
        self.notifyStepsChanged()
    }

    func updateAgentHeader(params: AgentHeaderUpdateParams) {
        self.updateAgent(name: params.name, goal: params.goal, modelId: params.modelId)
    }

    private func updateAgent(name: String? = nil,
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
            tools: tools?.map { tool in
                return Agent.Tool(slug: tool.slug, name: tool.name)
            },
            steps: steps,
            modelId: modelId
        )

        self.updateSubject.send(.merge(request))
    }

    private func cleanupEmptySteps() {
        var indicesToRemove: [Int] = []

        for (index, step) in self.editableSteps.enumerated() {
            let isLast = index == self.editableSteps.count - 1

            if !isLast {
                switch step {
                case .empty:
                    indicesToRemove.append(index)
                case .content(let stepContent):
                    if stepContent.value.isEmpty {
                        indicesToRemove.append(index)
                    }
                }
            }
        }

        guard !indicesToRemove.isEmpty else {
            return
        }

        for index in indicesToRemove.reversed() {
            self.editableSteps.remove(at: index)
        }

        self.notifyStepsChanged()
    }

    private func notifyToolsChanged() {
        let contentTools = self.editableTools.compactMap { item in
            if case .content(let tool) = item {
                return tool
            }
            return nil
        }

        self.updateAgent(tools: contentTools)
    }

    private func notifyStepsChanged() {
        let contentSteps = self.editableSteps.compactMap { item in
            if case .content(let step) = item {
                return step
            }
            return nil
        }

        self.updateAgent(steps: contentSteps)
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
            .removeDuplicates()
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

                Logger.agent.info("Agent updated successfully with \(args.count - 1, privacy: .public) fields")
            } catch {
                Logger.agent.error("Failed to update agent: \(error.localizedDescription, privacy: .public)")
                self.alertError = error
            }
        }
    }

}
