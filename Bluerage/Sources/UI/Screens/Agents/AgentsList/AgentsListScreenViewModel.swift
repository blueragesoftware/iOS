import FactoryKit
import ConvexMobile
import OSLog
import Combine
import SwiftUI

@MainActor
@Observable
final class AgentsListScreenViewModel {

    struct State {

        var main: LoadingViewModelState<[Agent]>

        var alertError: Error?

        var isCreatingNewAgent: Bool = false

    }

    private(set) var state: State = State(main: .loading)

    @ObservationIgnored
    @Injected(\.convex) private var convex

    @ObservationIgnored
    @Injected(\.keyedExecutor) private var keyedExecutor

    @ObservationIgnored
    private var connection: AnyCancellable?

    func connect() {
        self.state.main = .loading

        self.connection?.cancel()
        self.connection = nil

        self.connection = self.convex.subscribe(to: "agents:getAll", yielding: [Agent].self)
            .removeDuplicates()
            .map { agents in
                if agents.isEmpty {
                    return LoadingViewModelState.empty
                }

                return LoadingViewModelState.loaded(agents)
            }
            .catch { error in
                Logger.agents.error("Error loading all agents: \(error.localizedDescription, privacy: .public)")

                return Just(LoadingViewModelState<[Agent]>.error(error))
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] main in
                self?.state.main = main
            }
    }

    func createNewAgent() async throws -> Agent {
        withAnimation {
            self.state.isCreatingNewAgent = true
        }

        defer {
            withAnimation {
                self.state.isCreatingNewAgent = false
            }
        }

        return try await self.keyedExecutor.executeOperation(for: "agents/create") {
            try await self.convex.mutation("agents:create")
        }
    }

    func removeAgents(with ids: [String]) async throws {
        try await self.keyedExecutor.executeOperation(for: "agents/removeByIds/\(ids)") {
            try await self.convex.mutation("agents:removeByIds", with: ["ids": ids])
        }
    }

    func showErrorAlert(with error: Error) {
        self.state.alertError = error
    }

    func resetAlertError() {
        self.state.alertError = nil
    }

}
