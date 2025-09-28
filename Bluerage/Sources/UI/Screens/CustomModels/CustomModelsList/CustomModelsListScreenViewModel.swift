import FactoryKit
import ConvexMobile
import OSLog
import Combine

@MainActor
@Observable
final class CustomModelsListScreenViewModel {

    struct State {

        enum Main: Equatable {

            // MARK: - Equatable

            static func == (lhs: Main, rhs: Main) -> Bool {
                return lhs.isError && rhs.isError
                || lhs.isLoading && rhs.isLoading
                || lhs.isLoaded && rhs.isLoaded
                || lhs.isEmpty && rhs.isEmpty
            }

            // MARK: - Properties

            case loading
            case loaded(customModels: [CustomModel])
            case empty
            case error(Error)

            var isLoading: Bool {
                if case .loading = self {
                    true
                } else {
                    false
                }
            }

            var isError: Bool {
                if case .error = self {
                    true
                } else {
                    false
                }
            }

            var isLoaded: Bool {
                if case .loaded = self {
                    true
                } else {
                    false
                }
            }

            var isEmpty: Bool {
                if case .empty = self {
                    true
                } else {
                    false
                }
            }

            var title: String {
                switch self {
                case .loading:
                    BluerageStrings.commonLoading
                case .loaded:
                    BluerageStrings.commonLoaded
                case .error:
                    BluerageStrings.commonError
                case .empty:
                    BluerageStrings.commonEmpty
                }
            }
        }

        var main: Main

        var alertError: Error?

    }

    private(set) var state: State = State(main: .loading)

    @ObservationIgnored
    @Injected(\.convex) private var convex

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
                    return State.Main.empty
                }

                return State.Main.loaded(customModels: customModels)
            }
            .catch { error in
                Logger.customModels.error("Error receiving all models: \(error.localizedDescription, privacy: .public)")

                return Just(State.Main.error(error))
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] main in
                self?.state.main = main
            }
    }

    func createNewCustomModel() async throws -> CustomModel {
        return try await self.convex.mutation("customModels:create")
    }

    func removeCustomModels(with ids: [String]) async throws {
        try await self.convex.mutation("customModels:removeByIds", with: ["ids": ids])
    }

    func showErrorAlert(with error: Error) {
        self.state.alertError = error
    }

    func resetAlertError() {
        self.state.alertError = nil
    }

}
