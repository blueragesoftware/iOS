import FactoryKit
import ConvexMobile
import OSLog
import Combine
import SwiftUI

@MainActor
@Observable
final class MCPServerScreenViewModel {

    enum State: CustomStringConvertible {
        case loading
        case loaded(MCPServerLoadedViewModel)
        case error(Error)

        var description: String {
            switch self {
            case .loading:
                "Loading"
            case .loaded:
                "Loaded"
            case .error:
                "Error"
            }
        }
    }

    private(set) var state: State = .loading

    let mcpServerId: String

    @ObservationIgnored
    @Injected(\.convex) private var convex

    @ObservationIgnored
    private var connection: AnyCancellable?

    init(mcpServerId: String) {
        self.mcpServerId = mcpServerId
    }

    func connect() {
        self.state = .loading

        self.connection?.cancel()
        self.connection = nil

        self.connection = self.convex.subscribe(to: "mcpServers:getById",
                                                with: ["id": self.mcpServerId],
                                                yielding: MCPServer.self)
        .removeDuplicates()
        .map { mcpServer in
            let loadedViewModel = MCPServerLoadedViewModel(mcpServer: mcpServer)

            return State.loaded(loadedViewModel)
        }
        .catch { error in
            Logger.mcpServers.error("Error receiving agent: \(error.localizedDescription, privacy: .public)")

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

    func handle(oauthResult: MCPOAuthURLHandler.OAuthResult) {
        guard case .loaded(let loadedViewModel) = self.state else {
            Logger.mcpServers.error("Unable to handle oauthResult, since view models is in \(self.state, privacy: .public) state")

            return
        }

        loadedViewModel.handle(oauthResult: oauthResult)
    }

}
