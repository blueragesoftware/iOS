import Foundation
import SwiftUI
import FactoryKit
import ConvexMobile
import OSLog
import NavigatorUI

@MainActor
@Observable
final class ToolsSelectionScreenViewModel {

    struct State {

        enum Main {
            case loading
            case loaded(activeTools: [Tool], inactiveTools: [Tool])
            case empty
            case error(Error)
            case allToolsUsed
        }

        var main: Main

        var alertError: Error?

    }

    private(set) var state: State = State(main: .loading, alertError: nil)

    @ObservationIgnored
    private let agentToolsSlugSet: Set<String>

    @ObservationIgnored
    @Injected(\.convex) private var convex

    @ObservationIgnored
    @Injected(\.keyedExecutor) private var keyedExecutor

    init(agentToolsSlugSet: Set<String>) {
        self.agentToolsSlugSet = agentToolsSlugSet
    }

    func load() {
        self.state.main = .loading

        Task {
            do {
                let tools: [Tool] = try await self.keyedExecutor.executeOperation(for: "tools/getAll") {
                    try await self.convex.action("tools:getAll")
                }

                let nonUsedTools = tools.filter { tool in
                    return !self.agentToolsSlugSet.contains(tool.slug)
                }

                if tools.isEmpty {
                    Logger.tools.warning("Received empty tools")

                    self.state.main = .empty
                } else if nonUsedTools.isEmpty {
                    Logger.tools.info("Received all tools are used")

                    self.state.main = .allToolsUsed
                } else {
                    var activeTools = [Tool]()
                    var inactiveTools = [Tool]()

                    for tool in nonUsedTools {
                        tool.status == .active ? activeTools.append(tool) : inactiveTools.append(tool)
                    }

                    self.state.main = .loaded(activeTools: activeTools, inactiveTools: inactiveTools)
                }
            } catch {
                Logger.tools.error("Error loading tools: \(error.localizedDescription, privacy: .public)")

                self.state.main = .error(error)
            }
        }
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

    func showErrorAlert(with error: Error) {
        self.state.alertError = error
    }

    func resetAlertError() {
        self.state.alertError = nil
    }

}
