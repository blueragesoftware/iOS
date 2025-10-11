import Foundation
import Combine

protocol AuthSession {

    var authState: AuthState { get }

    var authStatePublisher: AnyPublisher<AuthState, Never> { get }

    func signInWithApple(idToken: String) async throws

    func start()

    func signOut() async throws

    func deleteAccount() async throws

}
