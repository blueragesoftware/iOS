import FactoryKit
import ConvexMobile
import OSLog
import SwiftUI
import Foundation

@MainActor
@Observable
final class MCPServerLoadedViewModel {

    enum Result: Codable {

        private enum CodingKeys: String, CodingKey {
            case status
            case redirectUrl
        }

        private enum Status: String {
            case authorized
            case redirect
            case rediect
        }

        case authorized
        case redirect(URL)

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let statusValue = try container.decode(String.self, forKey: .status)

            guard let status = Status(rawValue: statusValue) else {
                throw DecodingError.dataCorruptedError(forKey: .status,
                                                       in: container,
                                                       debugDescription: "Unsupported status: \(statusValue)")
            }

            switch status {
            case .authorized:
                self = .authorized
            case .redirect, .rediect:
                let redirectString = try container.decodeIfPresent(String.self, forKey: .redirectUrl)
                guard let redirectString,
                      let redirectURL = URL(string: redirectString) else {
                    throw DecodingError.dataCorruptedError(forKey: .redirectUrl,
                                                           in: container,
                                                           debugDescription: "Missing or invalid redirect URL for redirect status")
                }

                self = .redirect(redirectURL)
            }
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            switch self {
            case .authorized:
                try container.encode(Status.authorized.rawValue, forKey: .status)
            case .redirect(let url):
                try container.encode(Status.redirect.rawValue, forKey: .status)
                try container.encode(url.absoluteString, forKey: .redirectUrl)
            }
        }

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

    private struct MCPUpdateRequest: UpdateRequest, Encodable, ConvexEncodable {
        var name: String?
        var url: String?
        var apiKey: String??

        static var empty: MCPUpdateRequest {
            MCPUpdateRequest()
        }

        var hasUpdates: Bool {
            return self.name != nil
            || self.url != nil
            || self.apiKey != nil
        }

        mutating func merge(with other: MCPUpdateRequest) {
            if let otherName = other.name { self.name = otherName }
            if let otherUrl = other.url { self.url = otherUrl }
            if let otherApiKey = other.apiKey { self.apiKey = otherApiKey }
        }
    }

    var alertError: Swift.Error?

    let mcpServer: MCPServer

    private(set) var isConnecting = false

    @ObservationIgnored
    @Injected(\.convex) private var convex

    @ObservationIgnored
    private let queuedUpdater: QueuedUpdater<MCPUpdateRequest>

    @ObservationIgnored
    @Injected(\.env) private var env

    @ObservationIgnored
    @Injected(\.keyedExecutor) private var keyedExecutor

    // MARK: - Initialization

    init(mcpServer: MCPServer) {
        self.mcpServer = mcpServer

        weak var weakSelf: MCPServerLoadedViewModel?

        self.queuedUpdater = QueuedUpdater<MCPUpdateRequest> { request in
            guard let self = weakSelf else {
                return false
            }

            return await self.performUpdate(request: request)
        }

        weakSelf = self
    }

    // MARK: - Public Methods

    func updateMCPServer(name: String? = nil,
                         url: String? = nil,
                         apiKey: String?? = nil) {
        let request = MCPUpdateRequest(
            name: name,
            url: url,
            apiKey: apiKey
        )

        self.queuedUpdater.enqueue(request)
    }

    func flush() {
        self.queuedUpdater.flush()
    }

    func connect() async throws -> Result {
        self.isConnecting = true

        defer {
            self.isConnecting = false
        }

        await self.queuedUpdater.flushAsync()

        let params = [
            "id": self.mcpServer.id,
            "callbackUrl": self.callbackUrl(for: self.mcpServer.id)
        ]

        return try await self.keyedExecutor.executeOperation(for: "mcpServer/connect:withId/\(self.mcpServer.id)") {
            return try await self.convex.action("mcpServer/connect:withId", with: params)
        }
    }

    func handle(oauthResult: MCPOAuthURLHandler.OAuthResult) {
        Task {
            self.isConnecting = true

            defer {
                self.isConnecting = false
            }

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

            do {
                try await self.keyedExecutor.executeOperation(for: "mcpServer/connect/withId/\(self.mcpServer.id)") {
                    let _: Result = try await self.convex.action("mcpServer/connect:withId", with: params)
                }
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

    private func performUpdate(request: MCPUpdateRequest) async -> Bool {
        var mcpServerData: [String: any ConvexEncodable] = [:]

        if let name = request.name { mcpServerData["name"] = name }
        if let url = request.url { mcpServerData["url"] = url }
        if let apiKey = request.apiKey { mcpServerData["apiKey"] = apiKey }

        guard !mcpServerData.isEmpty else {
            return true
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

            return true
        } catch {
            Logger.customModels.error("Failed to update MCP server: \(error.localizedDescription, privacy: .public)")

            self.alertError = error

            return false
        }
    }

}
