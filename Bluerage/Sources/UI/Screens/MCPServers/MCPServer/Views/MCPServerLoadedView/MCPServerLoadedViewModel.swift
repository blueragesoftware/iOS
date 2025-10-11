import FactoryKit
import ConvexMobile
import OSLog
import Combine
import SwiftUI
import Queue
import Foundation

@MainActor
@Observable
final class MCPServerLoadedViewModel {

    struct Result: Codable {
        let status: String
        let redirectUrl: String?
    }

    enum Error: LocalizedError {
        case mcpAuthError(String)

        var errorDescription: String? {
            switch self {
            case .mcpAuthError(let string):
                return string
            }
        }
    }

    private struct UpdateRequest: Equatable, Encodable, ConvexEncodable {
        var name: String?
        var url: String?
        var apiKey: String??

        var hasUpdates: Bool {
            return self.name != nil
            || self.url != nil
            || self.apiKey != nil
        }

        mutating func merge(with other: UpdateRequest) {
            if let otherName = other.name { self.name = otherName }
            if let otherUrl = other.url { self.url = otherUrl }
            if let otherApiKey = other.apiKey { self.apiKey = otherApiKey }
        }
    }

    private enum UpdateAction {
        case merge(UpdateRequest)
        case reset
    }

    var alertError: Swift.Error?

    let mcpServer: MCPServer

    @ObservationIgnored
    private var updatesQueueCancellables = Set<AnyCancellable>()

    @ObservationIgnored
    @Injected(\.convex) private var convex

    @ObservationIgnored
    private let updateSubject = CurrentValueSubject<UpdateAction, Never>(.reset)

    @ObservationIgnored
    private let currentAccumulatedSubject = CurrentValueSubject<UpdateRequest, Never>(UpdateRequest())

    @ObservationIgnored
    private let queue = AsyncQueue()

    @ObservationIgnored
    @Injected(\.env) private var env

    // MARK: - Initialization

    init(mcpServer: MCPServer) {
        self.mcpServer = mcpServer

        self.setupUpdatesQueue()
    }

    // MARK: - Public Methods

    func updateMCPServer(name: String? = nil,
                         url: String? = nil,
                         apiKey: String?? = nil) {
        let request = UpdateRequest(
            name: name,
            url: url,
            apiKey: apiKey
        )

        self.updateSubject.send(.merge(request))
    }

    func flush() {
        var currentRequest = self.currentAccumulatedSubject.value
        let queueRequest = self.updateSubject.value

        if case .merge(let queueRequest) = queueRequest {
            currentRequest.merge(with: queueRequest)
        }

        if currentRequest.hasUpdates {
            self.queue.cancelAllPendingTasks()

            Task {
                await self.performUpdate(request: currentRequest)
            }
        }
    }

    func connect() async throws -> Result {
        let params = [
            "id": self.mcpServer.id,
            "callbackUrl": self.callbackUrl(for: self.mcpServer.id)
        ]

        return try await self.convex.action("mcpServer/connect:withId", with: params)
    }

    func handle(oauthResult: MCPOAuthURLHandler.OAuthResult) {
        if let error = oauthResult.error {
            Logger.mcpServers.error("Received an error authenticating with code from mcp server with id \(self.mcpServer.id, privacy: .public): \(error, privacy: .public)")

            self.alertError = Error.mcpAuthError(error)

            return
        }

        guard let code = oauthResult.code else {
            Logger.mcpServers.error("Didn't receive code from mcp server with id \(self.mcpServer.id, privacy: .public)")

            return
        }

        let params = [
            "id": self.mcpServer.id,
            "callbackUrl": self.callbackUrl(for: self.mcpServer.id),
            "oauthCode": code
        ]

        Task {
            do {
                try await self.convex.action("mcpServer/connect:withId", with: params)
            } catch {
                Logger.mcpServers.error("Error authenticating with code for mcp server with id \(self.mcpServer.id, privacy: .public): \(error.localizedDescription, privacy: .public)")

                self.alertError = error
            }
        }
    }

    // MARK: - Private Methods

    private func callbackUrl(for serverId: String) -> String {
        "\(self.env.URL_SCHEME)://oauth/callback/\(serverId)"
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
                    self.queue.addOperation { [weak self] in
                        await self?.performUpdate(request: mergedRequest)
                    }
                }
            }
            .store(in: &self.updatesQueueCancellables)
    }

    private func performUpdate(request: UpdateRequest) async {
        var mcpServerData: [String: any ConvexEncodable] = [:]

        if let name = request.name { mcpServerData["name"] = name }
        if let url = request.url { mcpServerData["url"] = url }
        if let apiKey = request.apiKey { mcpServerData["apiKey"] = apiKey }

        guard !mcpServerData.isEmpty else {
            return
        }

        var args: [String: any ConvexEncodable] = [
            "id": self.mcpServer.id
        ]

        for (key, value) in mcpServerData {
            args[key] = value
        }

        do {
            try await self.convex.mutation("mcpServers:update", with: args)

            Logger.customModels.info("MCP server updated successfully with \(mcpServerData.count, privacy: .public) fields")

            self.updateSubject.send(.reset)
        } catch {
            Logger.customModels.error("Failed to update MCP server: \(error.localizedDescription, privacy: .public)")

            self.alertError = error
        }
    }

}
