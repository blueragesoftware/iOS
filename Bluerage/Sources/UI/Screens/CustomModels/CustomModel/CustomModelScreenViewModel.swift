import FactoryKit
import ConvexMobile
import OSLog
import Combine
import SwiftUI

@MainActor
@Observable
final class CustomModelScreenViewModel {

    enum State {
        case loading
        case loaded(CustomModelLoadedViewModel)
        case error(Error)
    }

    private(set) var state: State = .loading

    let customModelId: String

    @ObservationIgnored
    @Injected(\.convex) private var convex

    @ObservationIgnored
    private var connection: AnyCancellable?

    init(customModelId: String) {
        self.customModelId = customModelId
    }

    func connect() {
        self.state = .loading

        self.connection?.cancel()
        self.connection = nil

        self.connection = self.convex.subscribe(to: "customModels:getById",
                                               with: ["id": self.customModelId],
                                               yielding: CustomModel.self)
        .removeDuplicates()
        .map { customModel in
            let loadedViewModel = CustomModelLoadedViewModel(customModel: customModel)

            return State.loaded(loadedViewModel)
        }
        .catch { error in
            Logger.customModels.error("Error receiving agent: \(error.localizedDescription, privacy: .public)")

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

}
