import Foundation
import FactoryKit
import ConvexMobile
import Combine
import SwiftUI

@MainActor
@Observable
final class ExecutionScreenViewModel {

    enum State {
        case loaded(task: ExecutionTask)
        case loading
        case error(Error)
    }

    private(set) var state: State = .loading

    @ObservationIgnored
    private let taskId: String

    @ObservationIgnored
    @Injected(\.convex) private var convex

    @ObservationIgnored
    private var connection: AnyCancellable?

    init(taskId: String) {
        self.taskId = taskId
    }

    func connect() {
        self.state = .loading

        self.connection?.cancel()
        self.connection = nil

        self.connection = self.convex.subscribe(to: "executionTasks:getById",
                                                with: ["id": self.taskId],
                                                yielding: ExecutionTask.self)
        .removeDuplicates()
        .map { task in
            return State.loaded(task: task)
        }
        .catch { error in
            return Just(State.error(error))
        }
        .receive(on: DispatchQueue.main)
        .sink { [weak self] state in
            withAnimation {
                self?.state = state
            }
        }
    }

}
