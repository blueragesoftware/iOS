import Foundation
import SwiftUI
import FactoryKit
import ConvexMobile
import OSLog

@MainActor
@Observable
final class ToolsSelectionScreenViewModel {
    
    enum State {
        case loading
        case loaded(activeTools: [Tool], inactiveTools: [Tool])
        case empty
        case error(Error)
        case allToolsUsed
    }

    struct AuthUrlConfig: Identifiable {

        let id: String

        let url: URL

    }

    var authUrlConfig: AuthUrlConfig?

    private(set) var state: State = .loading

    @ObservationIgnored
    private let agentToolsSlugSet: Set<String>

    @ObservationIgnored
    @Injected(\.convex) private var convex

    init(agentToolsSlugSet: Set<String>) {
        self.agentToolsSlugSet = agentToolsSlugSet
    }

    func load() {
        self.state = .loading

        Task {
            do {
                let tools: [Tool] = try await self.convex.action("tools:getAllTools")

                let nonUsedTools = tools.filter { tool in
                    return !self.agentToolsSlugSet.contains(tool.slug)
                }

                if tools.isEmpty {
                    Logger.tools.warning("Received empty tools")
                    
                    self.state = .empty
                } else if nonUsedTools.isEmpty {
                    self.state = .allToolsUsed
                } else {
                    var activeTools = [Tool]()
                    var inactiveTools = [Tool]()
                    
                    for tool in nonUsedTools {
                        tool.status == .active ? activeTools.append(tool) : inactiveTools.append(tool)
                    }
                    
                    self.state = .loaded(activeTools: activeTools, inactiveTools: inactiveTools)
                }
            } catch {
                Logger.tools.error("Error loading tools: \(error.localizedDescription)")
                
                self.state = .error(error)
            }
        }
    }

    func connectTool(with authConfigId: String) async throws  {
        do {
            let connectionResult: ConnectToolResponse = try await self.convex.action("tools:connectToolWithAuthConfigId", with: ["authConfigId": authConfigId])

            guard let url = URL(string: connectionResult.redirectUrl) else {
                return
            }

            self.authUrlConfig = AuthUrlConfig(id: authConfigId, url: url)
        } catch {
            Logger.tools.error("Error connecting tool: \(error.localizedDescription)")

            throw error
        }
    }

}
