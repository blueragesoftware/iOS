import Foundation
import FactoryKit
import Combine
import ConvexMobile
import OSLog

final class AuthSessionImpl: AuthSession {

    enum Error: LocalizedError {
        case userInformationIsMissingForDelete

        var errorDescription: String? {
            switch self {
            case .userInformationIsMissingForDelete:
                "Delete account failure due to missing user session"
            }
        }
    }

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

    @Injected(\.env) private var env

    @Injected(\.keyedExecutor) private var keyedExecutor

    private let authStateSubject: CurrentValueSubject<AuthState, Never>

    init() {
        let authStateSubject = CurrentValueSubject<AuthState, Never>(.loading)
        self.authStateSubject = authStateSubject
        self.authStatePublisher = authStateSubject.eraseToAnyPublisher()
    }

    func signInWithApple(idToken: String) async throws {
        try await self.keyedExecutor.executeOperation(for: "authSession/signInWithApple/\(idToken)") {
            _ = try await self.convex.login(with: ClerkAuthProvider.AppleLoginParams(idToken: idToken))
        }
    }

    func start() {
        self.authState = .loading

        self.convex.authState
            .map { convexState in
                switch convexState {
                case .authenticated(let user):
                    return AuthState.authenticated(id: user.user.id)
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
            do {
                try await self.keyedExecutor.executeOperation(for: "authSession/loginFromCache") {
                    try await self.convex.loginFromCache()
                }
            } catch {
                Logger.auth.error("Error logging in from cache: \(error.localizedDescription, privacy: .public)")
            }
        }
    }

    @MainActor
    func signOut() async throws {
        try await self.keyedExecutor.executeOperation(for: "authSession/signOut") {
            try await self.convex.logout()
        }
    }

    @MainActor
    func deleteAccount() async throws {
        guard let user = self.clerk.user else {
            throw Error.userInformationIsMissingForDelete
        }

        try await self.keyedExecutor.executeOperation(for: "settings/deleteUser") {
            try await user.delete()
        }
    }

}
