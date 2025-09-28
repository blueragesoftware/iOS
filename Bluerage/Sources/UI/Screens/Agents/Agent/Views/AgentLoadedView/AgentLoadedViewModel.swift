import FactoryKit
import ConvexMobile
import OSLog
import Combine
import SwiftUI
import Get
import UniformTypeIdentifiers

@MainActor
@Observable
final class AgentLoadedViewModel {

    enum LocalFile {
        case image(name: String, data: Data, uTType: UTType?)
        case file(url: URL)
    }

    private enum Error: Swift.Error {
        case unableToAccessSecurelyScopedResource
    }

    private struct UpdateRequest: Equatable, Encodable, ConvexEncodable {
        var name: String?
        var description: String?
        var iconUrl: String?
        var goal: String?
        var tools: [Agent.Tool]?
        var steps: [Agent.Step]?
        var model: AgentModel?
        var files: [Agent.File]?

        var hasUpdates: Bool {
            return self.name != nil
            || self.description != nil
            || self.iconUrl != nil
            || self.goal != nil
            || self.tools != nil
            || self.steps != nil
            || self.model != nil
            || self.files != nil
        }

        mutating func merge(with other: UpdateRequest) {
            if let otherName = other.name { self.name = otherName }
            if let otherDescription = other.description { self.description = otherDescription }
            if let otherIconUrl = other.iconUrl { self.iconUrl = otherIconUrl }
            if let otherGoal = other.goal { self.goal = otherGoal }
            if let otherTools = other.tools { self.tools = otherTools }
            if let otherSteps = other.steps { self.steps = otherSteps }
            if let otherModel = other.model { self.model = otherModel }
            if let otherFiles = other.files { self.files = otherFiles }
        }
    }

    private enum UpdateAction {
        case merge(UpdateRequest)
        case reset
    }

    private struct UploadResponse: Decodable {
        let storageId: String
    }

    var alertError: Swift.Error?

    let agent: Agent

    let model: ModelUnion

    let availableModels: AllModelsResponse

    @ObservationIgnored
    let reload: () -> Void

    private(set) var isUploadingFile = false

    private(set) var tools: [Tool]

    private(set) var steps: [Agent.Step]

    private(set) var files: [Agent.File]

    @ObservationIgnored
    private var updatesQueueCancellables = Set<AnyCancellable>()

    @ObservationIgnored
    @Injected(\.convex) private var convex

    @ObservationIgnored
    @Injected(\.apiClient) private var apiClient

    @ObservationIgnored
    private let updateSubject = CurrentValueSubject<UpdateAction, Never>(.reset)

    @ObservationIgnored
    private let currentAccumulatedSubject = CurrentValueSubject<UpdateRequest, Never>(UpdateRequest())

    init(agent: Agent,
         model: ModelUnion,
         tools: [Tool],
         availableModels: AllModelsResponse,
         reload: @escaping () -> Void) {
        self.agent = agent
        self.model = model
        self.tools = tools
        self.steps = agent.steps
        self.files = agent.files
        self.availableModels = availableModels

        self.reload = reload

        self.setupUpdatesQueue()
    }

    func run() {
        Task {
            do {
                try await self.convex.mutation("executionTasks:create", with: ["agentId": self.agent.id])
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

    func add(tool: Tool) {
        self.tools.append(tool)

        self.updateAgent(tools: self.tools)
    }

    func removeTools(at offsets: IndexSet) {
        self.tools.remove(atOffsets: offsets)

        self.updateAgent(tools: self.tools)
    }

    func add(localFile: LocalFile) {
        Task {
            do {
                withAnimation {
                    self.isUploadingFile = true
                }

                let uploadUrlAbsoluteString: String = try await self.convex.mutation("files:generateUploadUrl")

                guard let url = URL(string: uploadUrlAbsoluteString) else {
                    return
                }

                let response: UploadResponse
                let fileName: String
                let fileType: Agent.File.`Type`

                switch localFile {
                case .image(let name, let data, let utType):
                    fileName = name
                    fileType = .image

                    let headers: [String: String] = if let preferredMIMEType = utType?.preferredMIMEType {
                        ["Content-Type": preferredMIMEType]
                    } else {
                        [:]
                    }

                    let request = Request<UploadResponse>(url: url,
                                                          method: .post,
                                                          headers: headers)
                    response = try await self.apiClient.upload(for: request, from: data).value
                case .file(let fileUrl):
                    fileName = fileUrl.lastPathComponent
                    fileType = .file

                    let headers: [String: String] = if let preferredMIMEType = UTType(filenameExtension: fileUrl.pathExtension)?.preferredMIMEType {
                        ["Content-Type": preferredMIMEType]
                    } else {
                        [:]
                    }

                    let request = Request<UploadResponse>(url: url,
                                                          method: .post,
                                                          headers: headers)

                    let canAccess = fileUrl.startAccessingSecurityScopedResource()

                    if !canAccess {
                        throw Error.unableToAccessSecurelyScopedResource
                    }

                    let data = try Data(contentsOf: fileUrl)
                    fileUrl.stopAccessingSecurityScopedResource()

                    response = try await self.apiClient.upload(for: request, from: data).value
                }

                self.files.append(Agent.File(storageId: response.storageId, name: fileName, type: fileType))

                self.updateAgent(files: self.files)

                withAnimation {
                    self.isUploadingFile = false
                }
            } catch {
                withAnimation {
                    self.isUploadingFile = false
                }
                self.alertError = error

                Logger.agent.error("Error uploading file: \(error, privacy: .public)")
            }
        }

    }

    func removeFiles(at offsets: IndexSet) {
        self.files.remove(atOffsets: offsets)

        self.updateAgent(files: self.files)
    }

    func addStep() {
        self.steps.append(Agent.Step(id: UUID().uuidString, value: ""))

        self.updateAgent(steps: self.steps)
    }

    func handleStepChange(at index: Int, newValue: String) {
        guard let existingStep = self.steps[safeIndex: index] else {
            Logger.agent.warning("Editing a step with invalid index: \(index, privacy: .public), steps count: \(self.steps.count)")

            return
        }

        self.steps[index] = Agent.Step(id: existingStep.id, value: newValue)

        self.updateAgent(steps: self.steps)
    }

    func moveSteps(from: IndexSet, to: Int) {
        self.steps.move(fromOffsets: from, toOffset: to)

        self.notifyStepsChanged()
    }

    func removeSteps(at offsets: IndexSet) {
        self.steps.remove(atOffsets: offsets)

        self.notifyStepsChanged()
    }

    func updateAgentHeader(params: AgentHeaderUpdateParams) {
        self.updateAgent(name: params.name, goal: params.goal, model: params.model)
    }

    func connectTool(with authConfigId: String) async throws -> URL {
        let connectionResult: ConnectToolResponse = try await self.convex.action("tools:connectWithAuthConfigId", with: ["authConfigId": authConfigId])

        guard let url = URL(string: connectionResult.redirectUrl) else {
            throw URLError(.badURL)
        }

        return url
    }

    private func updateAgent(name: String? = nil,
                             description: String? = nil,
                             iconUrl: String? = nil,
                             goal: String? = nil,
                             tools: [Tool]? = nil,
                             steps: [Agent.Step]? = nil,
                             model: AgentModel? = nil,
                             files: [Agent.File]? = nil) {
        let request = UpdateRequest(
            name: name,
            description: description,
            iconUrl: iconUrl,
            goal: goal,
            tools: tools?.map { tool in
                return Agent.Tool(slug: tool.slug, name: tool.name)
            },
            steps: steps,
            model: model,
            files: files
        )

        self.updateSubject.send(.merge(request))
    }

    private func notifyToolsChanged() {
        self.updateAgent(tools: self.tools)
    }

    private func notifyStepsChanged() {
        self.updateAgent(steps: self.steps)
    }

    private func notifyFilesChanged() {
        self.updateAgent(files: self.files)
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
        var args: [String: any ConvexEncodable] = ["id": self.agent.id]

        if let name = request.name { args["name"] = name }
        if let description = request.description { args["description"] = description }
        if let iconUrl = request.iconUrl { args["iconUrl"] = iconUrl }
        if let goal = request.goal { args["goal"] = goal }
        if let tools = request.tools { args["tools"] = tools }
        if let steps = request.steps { args["steps"] = steps }
        if let model = request.model { args["model"] = model }
        if let files = request.files { args["files"] = files }

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
