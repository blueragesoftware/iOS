import FactoryKit
import ConvexMobile
import OSLog
import Combine

@MainActor
@Observable
final class CustomModelsListScreenViewModel {

    struct State {

        var main: LoadingViewModelState<[CustomModel]>

        var alertError: Error?

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

        self.connection = self.convex.subscribe(to: "customModels:getAll",
                                                yielding: [CustomModel].self)
            .removeDuplicates()
            .map { customModels in
                if customModels.isEmpty {
                    return LoadingViewModelState.empty
                }

                return LoadingViewModelState.loaded(customModels)
            }
            .catch { error in
                Logger.customModels.error("Error receiving all models: \(error.localizedDescription, privacy: .public)")

                return Just(LoadingViewModelState<[CustomModel]>.error(error))
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] main in
                self?.state.main = main
            }
    }

    func createNewCustomModel() async throws -> CustomModel {
        try await self.keyedExecutor.executeOperation(for: "customModels/create") {
            try await self.convex.mutation("customModels:create")
        }
    }

    func removeCustomModels(with ids: [String]) async throws {
        try await self.keyedExecutor.executeOperation(for: "customModels/removeByIds/\(ids)") {
            try await self.convex.mutation("customModels:removeByIds", with: ["ids": ids])
        }
    }

    func showErrorAlert(with error: Error) {
        self.state.alertError = error
    }

    func resetAlertError() {
        self.state.alertError = nil
    }

}
