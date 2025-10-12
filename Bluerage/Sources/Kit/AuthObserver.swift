import Foundation
import FactoryKit
import Combine
import Knock
import PostHog
import OSLog
import Sentry
import Queue

final class AuthObserver {

    @Injected(\.authSession) private var authSession

    @Injected(\.knock) private var knock

    @Injected(\.postHog) private var postHog

    private let queue = AsyncQueue()

    private var connection: AnyCancellable?

    func start() {
        self.connection?.cancel()
        self.connection = nil

        self.connection = self.authSession.authStatePublisher
            .sink { [weak self] authState in
                self?.queue.addOperation { [ weak self] in
                    guard let self else {
                        return
                    }

                    if case .authenticated(let id) = authState {
                        await self.knock.signIn(userId: id, userToken: nil)

                        self.postHog.identify(id, userProperties: nil)

                        SentrySDK.setUser(User(userId: id))
                    } else if case .unauthenticated = authState {
                        do {
                            try await self.knock.signOut()
                        } catch {
                            Logger.default.error("Error signing out of knock")
                        }

                        self.postHog.reset()

                        SentrySDK.setUser(nil)
                    }
                }

            }
    }
}
