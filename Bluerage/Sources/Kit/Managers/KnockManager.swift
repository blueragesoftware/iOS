import Foundation
import FactoryKit
import Combine
import Knock
import OSLog

final class KnockManager {

    @Injected(\.authSession) private var authSession

    private var connection: AnyCancellable?

    func start() {
        self.connection?.cancel()
        self.connection = nil

        self.connection = self.authSession.authStatePublisher
            .sink { authState in
                Task {
                    if case .authenticated(let id) = authState {
                        await Knock.shared.signIn(userId: id, userToken: nil)
                    } else if case .unauthenticated = authState {
                        do {
                            try await Knock.shared.signOut()
                        } catch {
                            Logger.knockManager.error("Error signing out of knock")
                        }
                    }
                }
            }
    }

    func setup(publishableKey: String, pushChannelId: String?, options: Knock.KnockStartupOptions? = nil) async throws {
        try await Knock.shared.setup(publishableKey: publishableKey, pushChannelId: pushChannelId, options: options)
    }

}
