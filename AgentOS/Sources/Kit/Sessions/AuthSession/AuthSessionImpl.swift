import Foundation
import FactoryKit
import Combine
import ConvexMobile

final class AuthSessionImpl: AuthSession {

    private(set) var authState: AuthState {
        get {
            self.authStateSubject.value
        }

        set {
            self.authStateSubject.value = newValue
        }
    }

    let authStatePublisher: AnyPublisher<AuthState, Never>

    private var cancellables = Set<AnyCancellable>()

    @Injected(\.convex) private var convex

    @Injected(\.clerk) private var clerk

    private let authStateSubject: CurrentValueSubject<AuthState, Never>

    init() {
        let authStateSubject = CurrentValueSubject<AuthState, Never>(.loading)
        self.authStateSubject = authStateSubject
        self.authStatePublisher = authStateSubject.eraseToAnyPublisher()
    }

    func signInWithApple(idToken: String) async throws {
        try await self.convex.login(with: ClerkAuthProvider.AppleLoginParams(idToken: idToken))
    }

    func start() {
        self.convex.authState
            .map { convexState in
                switch convexState {
                case .authenticated:
                    return AuthState.authenticated
                case .loading:
                    return AuthState.loading
                case .unauthenticated:
                    return AuthState.unauthenticated
                }
            }
            .replaceError(with: AuthState.error)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] authState in
                self?.authState = authState
            }
            .store(in: &self.cancellables)

        Task {
            for event in self.clerk.authEventEmitter.events {

            }
        }

        Task {
            try await self.convex.loginFromCache()
        }
    }

    
}
