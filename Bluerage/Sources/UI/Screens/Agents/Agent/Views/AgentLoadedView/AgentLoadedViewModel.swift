import FactoryKit
import ConvexMobile
import OSLog
import SwiftUI
import Get
import UniformTypeIdentifiers

@MainActor
@Observable
final class AgentLoadedViewModel {

    enum LocalFile {
        case image(id: String, name: String, data: Data, uTType: UTType?)
        case file(id: String, url: URL)

        var id: String {
            switch self {
            case .image(let id, _, _, _):
                id
            case .file(let id, _):
                id
            }
        }
    }

    private enum Error: LocalizedError {
        case unableToAccessSecurelyScopedResource
        case unableToConstructUrl

        var errorDescription: String? {
            switch self {
            case .unableToAccessSecurelyScopedResource:
                "Unable to access securely scoped resource"
            case .unableToConstructUrl:
                "Unable to construct url"
            }
        }
    }

    private struct AgentUpdateRequest: UpdateRequest, Encodable, ConvexEncodable {
        var name: String?
        var description: String?
        var iconUrl: String?
        var goal: String?
        var tools: [Agent.Tool]?
        var steps: [Agent.Step]?
        var model: AgentModel?
        var files: [Agent.File]?

        static var empty: AgentUpdateRequest {
            AgentUpdateRequest()
        }

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

        mutating func merge(with other: AgentUpdateRequest) {
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

    private struct UploadResponse: Decodable {
        let storageId: String
    }

    private struct CreateTaskResponse: Decodable {
        let taskId: String
    }

    var alertError: Swift.Error?

    var isCreatingNewRunTask = false

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
    @Injected(\.convex) private var convex

    @ObservationIgnored
    @Injected(\.apiClient) private var apiClient

    @ObservationIgnored
    @Injected(\.keyedExecutor) private var keyedExecutor

    @ObservationIgnored
    private let queuedUpdater: QueuedUpdater<AgentUpdateRequest>

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

        weak var weakSelf: AgentLoadedViewModel?

        self.queuedUpdater = QueuedUpdater<AgentUpdateRequest> { request in
            guard let self = weakSelf else {
                return false
            }

            return await self.performUpdate(request: request)
        }

        weakSelf = self
    }

    func createTask() async throws -> String {
        withAnimation {
            self.isCreatingNewRunTask = true
        }

        defer {
            withAnimation {
                self.isCreatingNewRunTask = false
            }
        }

        await self.queuedUpdater.flushAsync()

        let response: CreateTaskResponse = try await self.keyedExecutor.executeOperation(for: "agent/tasks/create/\(self.agent.id)") {
            try await self.convex.mutation("agent/tasks:create", with: ["agentId": self.agent.id])
        }

        return response.taskId
    }

    func flush() {
        self.queuedUpdater.flush()
    }

    func add(tool: Tool) {
        withAnimation {
            self.tools.append(tool)
        }

        self.updateAgent(tools: self.tools)
    }

    func removeTools(at offsets: IndexSet) {
        withAnimation {
            self.tools.remove(atOffsets: offsets)
        }

        self.updateAgent(tools: self.tools)
    }

    func add(localFile: LocalFile) {
        withAnimation {
            self.isUploadingFile = true
        }

        Task {
            defer {
                withAnimation {
                    self.isUploadingFile = false
                }
            }

            do {
                let (response, fileName, fileType) = try await self.keyedExecutor.executeOperation(for: "files/generateUploadUrl/\(localFile.id)") {
                    try await self.upload(localFile: localFile)
                }

                withAnimation {
                    self.files.append(Agent.File(storageId: response.storageId, name: fileName, type: fileType))
                }

                self.updateAgent(files: self.files)
            } catch {
                Logger.agents.error("Error uploading file: \(error, privacy: .public)")

                self.alertError = error
            }
        }

    }

    func removeFiles(at offsets: IndexSet) {
        withAnimation {
            self.files.remove(atOffsets: offsets)
        }

        self.updateAgent(files: self.files)
    }

    func addStep() {
        withAnimation {
            self.steps.append(Agent.Step(id: UUID().uuidString, value: ""))
        }

        self.updateAgent(steps: self.steps)
    }

    func handleStepChange(at index: Int, newValue: String) {
        guard let existingStep = self.steps[safeIndex: index] else {
            Logger.agents.warning("Editing a step with invalid index: \(index, privacy: .public), steps count: \(self.steps.count)")

            return
        }

        self.steps[index] = Agent.Step(id: existingStep.id, value: newValue)

        self.updateAgent(steps: self.steps)
    }

    func moveSteps(from: IndexSet, to: Int) {
        withAnimation {
            self.steps.move(fromOffsets: from, toOffset: to)
        }

        self.updateAgent(steps: self.steps)
    }

    func removeSteps(at offsets: IndexSet) {
        withAnimation {
            self.steps.remove(atOffsets: offsets)
        }

        self.updateAgent(steps: self.steps)
    }

    func updateAgentHeader(params: AgentHeaderUpdateParams) {
        self.updateAgent(name: params.name, goal: params.goal, model: params.model)
    }

    func connectTool(with authConfigId: String) async throws -> URL {
        let connectionResult: ConnectToolResponse = try await self.keyedExecutor.executeOperation(for: "tools/connectWithAuthConfigId/\(authConfigId)") {
            try await self.convex.action("tools:connectWithAuthConfigId", with: ["authConfigId": authConfigId])
        }

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
        let request = AgentUpdateRequest(
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

        self.queuedUpdater.enqueue(request)
    }

    private func performUpdate(request: AgentUpdateRequest) async -> Bool {
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
            return true
        }

        do {
            try await self.convex.mutation("agents:update", with: args)

            Logger.agents.info("Agent updated successfully with \(args.count - 1, privacy: .public) fields")

            return true
        } catch {
            Logger.agents.error("Failed to update agent: \(error.localizedDescription, privacy: .public)")

            self.alertError = error

            return false
        }
    }

    private func upload(localFile: LocalFile) async throws -> (response: UploadResponse,
                                                               fileName: String,
                                                               fileType: Agent.File.`Type`) {
        let uploadUrlAbsoluteString: String = try await self.convex.mutation("files:generateUploadUrl")

        guard let url = URL(string: uploadUrlAbsoluteString) else {
            throw Error.unableToConstructUrl
        }

        let response: UploadResponse
        let fileName: String
        let fileType: Agent.File.`Type`

        switch localFile {
        case .image(_, let name, let data, let utType):
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
        case .file(_, let fileUrl):
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

        return (response, fileName, fileType)
    }

}
