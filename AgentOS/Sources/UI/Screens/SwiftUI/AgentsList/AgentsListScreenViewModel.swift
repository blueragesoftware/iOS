import SwiftUI
import FactoryKit
import ConvexMobile
import OSLog
import Combine

@Observable
@MainActor
final class AgentsListScreenViewModel {

    enum State: CustomStringConvertible {
        case skeleton
        case loaded(agents: [Agent])
        case empty
        case error(Error)

        var isSkeleton: Bool {
            switch self {
            case .skeleton:
                true
            default:
                false
            }
        }

        var isError: Bool {
            switch self {
            case .error:
                true
            default:
                false
            }
        }

        // MARK: - CustomStringConvertible

        var description: String {
            switch self {
            case .skeleton:
                "Skeleton"
            case .loaded:
                "Loaded"
            case .error:
                "Error"
            case .empty:
                "Empty"
            }
        }
    }

    private(set) var state: State = .skeleton

    @ObservationIgnored
    @Injected(\.convex) private var convex

    @ObservationIgnored
    private var cancellables = Set<AnyCancellable>()

    @ObservationIgnored
    private var hasLoaded = false

    func load() {
        if self.hasLoaded {
            return
        }

        self.convex.subscribe(to: "agents:getAll", yielding: [Agent].self)
            .removeDuplicates()
            .map { agents in
                return State.loaded(agents: agents)
            }
            .replaceEmpty(with: .empty)
            .replaceNil(with: .empty)
            .catch { error in
                return Just(.error(error))
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.state = state
            }
            .store(in: &self.cancellables)

        self.hasLoaded = true
    }


}
