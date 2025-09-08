import Foundation
import FactoryKit
import ConvexMobile
import Combine
import SwiftUI

@MainActor
@Observable
final class RootScreenViewModel {

    private(set) var authState: AuthState

    @ObservationIgnored
    @Injected(\.authSession) private var authSession

    init() {
        @Injected(\.authSession) var authSession

        self.authState = authSession.authState
    }

    @ObservationIgnored
    private var connection: AnyCancellable?

    func connect() {
        self.connection?.cancel()
        self.connection = nil

        self.connection = self.authSession.authStatePublisher
            .sink { [weak self] authState in
                withAnimation {
                    self?.authState = authState
                }
            }
    }

    func reconnect() {
        self.authSession.start()

        self.connect()
    }

}
